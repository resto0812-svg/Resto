-- =============================================================================
-- Resto — 010_espace_client
-- Côté client : fiches publiques des restaurants, recherche, carte publique
-- (avec photos), QR code par table, commandes en ligne (sur place via QR, à
-- emporter, livraison) acceptées ou refusées par le restaurant, suivi par le
-- client, adresses, favoris, avis vérifiés (une commande payée = un avis).
-- À coller APRÈS 009, puis supabase/tests/010_espace_client_tests.sql.
--
-- Consultation sans compte : uniquement par les fonctions public_* (données
-- publiques des établissements publiés). Commander, réserver, noter : compte
-- obligatoire. Paiement en ligne : phase 5 (ici, paiement au restaurant ou à
-- la livraison).
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Informations publiques
-- -----------------------------------------------------------------------------
alter table public.brands
  add column if not exists description text check (length(description) <= 1000),
  add column if not exists cuisines text[] not null default '{}' check (cardinality(cuisines) <= 10),
  add column if not exists price_level smallint check (price_level between 1 and 4);
grant update (description, cuisines, price_level) on public.brands to authenticated;

alter table public.branches
  add column if not exists accepts_online_orders boolean not null default false,
  add column if not exists accepts_delivery boolean not null default false,
  add column if not exists delivery_fee_minor bigint not null default 0 check (delivery_fee_minor >= 0),
  add column if not exists min_order_minor bigint not null default 0 check (min_order_minor >= 0);
grant insert (accepts_online_orders, accepts_delivery, delivery_fee_minor, min_order_minor),
  update (accepts_online_orders, accepts_delivery, delivery_fee_minor, min_order_minor) on public.branches to authenticated;

alter table public.profiles add column if not exists phone text check (length(phone) <= 40);
grant update (phone) on public.profiles to authenticated;

-- QR code de table : jeton aléatoire (122 bits) propre à chaque table.
alter table public.dining_tables
  add column if not exists qr_token text not null default replace(gen_random_uuid()::text, '-', '') unique;

-- -----------------------------------------------------------------------------
-- Photos des articles : bucket public « menu-images », écriture par
-- menus.manage sur toute l'organisation, dossier {organisation}/{article}/
-- -----------------------------------------------------------------------------
alter table public.menu_items add column if not exists image_path text
  check (image_path is null or (length(image_path) <= 300 and image_path ~ '^[0-9a-f-]{36}/[0-9a-f-]{36}/[A-Za-z0-9._-]+$'));
grant update (image_path) on public.menu_items to authenticated;

create or replace function app_private.check_item_image()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  if new.image_path is not null
     and new.image_path not like new.organization_id::text || '/' || new.id::text || '/%' then
    perform app_private.fail('resto.invalid_image');
  end if;
  return new;
end $$;
drop trigger if exists menu_items_check_image on public.menu_items;
create trigger menu_items_check_image before insert or update of image_path on public.menu_items
  for each row execute function app_private.check_item_image();

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('menu-images', 'menu-images', true, 2097152, array['image/jpeg', 'image/png', 'image/webp'])
on conflict (id) do update set public = true, file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists resto_menu_images_insert on storage.objects;
drop policy if exists resto_menu_images_update on storage.objects;
drop policy if exists resto_menu_images_delete on storage.objects;
create policy resto_menu_images_insert on storage.objects for insert to authenticated
  with check (bucket_id = 'menu-images'
    and (storage.foldername(name))[1] in (select x::text from app_private.org_ids_with('menus.manage') x));
create policy resto_menu_images_update on storage.objects for update to authenticated
  using (bucket_id = 'menu-images'
    and (storage.foldername(name))[1] in (select x::text from app_private.org_ids_with('menus.manage') x))
  with check (bucket_id = 'menu-images'
    and (storage.foldername(name))[1] in (select x::text from app_private.org_ids_with('menus.manage') x));
create policy resto_menu_images_delete on storage.objects for delete to authenticated
  using (bucket_id = 'menu-images'
    and (storage.foldername(name))[1] in (select x::text from app_private.org_ids_with('menus.manage') x));

-- -----------------------------------------------------------------------------
-- Commandes des clients
-- -----------------------------------------------------------------------------
alter table public.orders
  add column if not exists customer_user_id uuid references auth.users (id) on delete set null,
  add column if not exists acceptance text not null default 'accepted' check (acceptance in ('pending', 'accepted', 'rejected')),
  add column if not exists scheduled_for timestamptz,
  add column if not exists customer_name text check (length(customer_name) <= 120),
  add column if not exists contact_phone text check (length(contact_phone) <= 40),
  add column if not exists delivery_address text check (length(delivery_address) <= 500),
  add column if not exists delivery_instructions text check (length(delivery_instructions) <= 500),
  add column if not exists delivery_fee_minor bigint not null default 0 check (delivery_fee_minor >= 0),
  add column if not exists reject_reason text check (length(reject_reason) <= 500);
create index if not exists orders_customer_idx on public.orders (customer_user_id, opened_at desc) where customer_user_id is not null;
create index if not exists orders_pending_idx on public.orders (branch_id) where acceptance = 'pending' and status = 'open';

alter table public.order_items add column if not exists added_via text not null default 'staff'
  check (added_via in ('staff', 'customer'));

-- Le client voit ses propres commandes (et leur suivi en direct).
create policy orders_customer_read on public.orders for select to authenticated
  using (customer_user_id = (select auth.uid()));
create policy order_items_customer_read on public.order_items for select to authenticated
  using (order_id in (select o.id from public.orders o where o.customer_user_id = (select auth.uid())));
create policy order_item_modifiers_customer_read on public.order_item_modifiers for select to authenticated
  using (order_item_id in (select i.id from public.order_items i));

-- Totaux : lignes non annulées + frais de livraison.
create or replace function app_private.recompute_order(p_order uuid)
returns void language plpgsql volatile security definer set search_path = '' as $$
declare
  v public.orders;
  v_sub bigint;
  v_tax bigint;
begin
  select * into v from public.orders where id = p_order;
  select coalesce(sum(line_total_minor), 0) + v.delivery_fee_minor into v_sub
    from public.order_items where order_id = p_order and prep_status <> 'cancelled';
  if v.prices_include_tax then
    v_tax := v_sub - round(v_sub / (1 + v.tax_rate / 100));
    update public.orders set subtotal_minor = v_sub, tax_minor = v_tax, total_minor = v_sub, version = version + 1
     where id = p_order;
  else
    v_tax := round(v_sub * v.tax_rate / 100);
    update public.orders set subtotal_minor = v_sub, tax_minor = v_tax, total_minor = v_sub + v_tax, version = version + 1
     where id = p_order;
  end if;
end $$;

-- Ajout d'une ligne (prix et règles des options imposés par le serveur),
-- commun à la prise de commande et aux commandes des clients.
create or replace function app_private.insert_order_line(
  p_order public.orders, p_variant uuid, p_quantity integer, p_modifiers uuid[], p_note text, p_client_id uuid,
  p_added_via text)
returns uuid language plpgsql volatile security definer set search_path = '' as $$
declare
  v_variant public.item_variants;
  v_item public.menu_items;
  v_available boolean;
  v_price bigint;
  v_mods uuid[] := array(select distinct m from unnest(coalesce(p_modifiers, '{}')) m);
  v_mod_total bigint := 0;
  v_line_id uuid;
  r record;
begin
  if coalesce(p_quantity, 0) not between 1 and 999 then perform app_private.fail('resto.invalid_quantity'); end if;
  select * into v_variant from public.item_variants where id = p_variant and organization_id = p_order.organization_id;
  select * into v_item from public.menu_items where id = v_variant.item_id;
  select available into v_available from public.menu_item_branches where item_id = v_item.id and branch_id = p_order.branch_id;
  if v_variant.id is null or not v_variant.active or not v_item.active or v_item.brand_id <> p_order.brand_id
     or v_available is distinct from true then
    perform app_private.fail('resto.item_unavailable');
  end if;
  select amount_minor into v_price from public.prices
   where branch_id = p_order.branch_id and variant_id = p_variant and valid_to is null
     and channel in (p_order.channel, 'default')
   order by (channel = 'default') limit 1;
  if v_price is null then perform app_private.fail('resto.no_price'); end if;
  if exists (
    select 1 from unnest(v_mods) m
     where not exists (
       select 1 from public.modifiers mo
         join public.modifier_groups g on g.id = mo.group_id and g.active
         join public.item_modifier_groups img on img.group_id = g.id and img.item_id = v_item.id
        where mo.id = m and mo.active)) then
    perform app_private.fail('resto.options_invalid');
  end if;
  if exists (
    select 1 from public.item_modifier_groups img
      join public.modifier_groups g on g.id = img.group_id and g.active
     where img.item_id = v_item.id
       and ((select count(*) from public.modifiers mo where mo.group_id = g.id and mo.id = any (v_mods)) < g.min_select
         or (g.max_select is not null
             and (select count(*) from public.modifiers mo where mo.group_id = g.id and mo.id = any (v_mods)) > g.max_select))) then
    perform app_private.fail('resto.options_invalid');
  end if;
  select coalesce(sum(coalesce(
           (select p.amount_minor from public.prices p
             where p.branch_id = p_order.branch_id and p.modifier_id = mo.id and p.valid_to is null
               and p.channel in (p_order.channel, 'default')
             order by (p.channel = 'default') limit 1), 0)), 0)
    into v_mod_total
    from public.modifiers mo where mo.id = any (v_mods);

  insert into public.order_items (id, organization_id, branch_id, order_id, item_id, variant_id, item_name, variant_name,
                                  quantity, unit_price_minor, line_total_minor, note, added_by, added_via)
  values (coalesce(p_client_id, gen_random_uuid()), p_order.organization_id, p_order.branch_id, p_order.id, v_item.id,
          p_variant, v_item.name, v_variant.name, p_quantity, v_price + v_mod_total,
          (v_price + v_mod_total) * p_quantity, nullif(btrim(p_note), ''), auth.uid(), p_added_via)
  returning id into v_line_id;
  for r in
    select mo.id, mo.name, g.name as group_name,
           coalesce((select p.amount_minor from public.prices p
                      where p.branch_id = p_order.branch_id and p.modifier_id = mo.id and p.valid_to is null
                        and p.channel in (p_order.channel, 'default')
                      order by (p.channel = 'default') limit 1), 0) as price
      from public.modifiers mo join public.modifier_groups g on g.id = mo.group_id
     where mo.id = any (v_mods)
     order by g.sort_order, g.name, mo.sort_order, mo.name
  loop
    insert into public.order_item_modifiers (organization_id, branch_id, order_item_id, modifier_id, group_name,
                                             modifier_name, price_minor)
    values (p_order.organization_id, p_order.branch_id, v_line_id, r.id, r.group_name, r.name, r.price);
  end loop;
  perform app_private.log_order(p_order, 'item_added', v_line_id,
    jsonb_build_object('name', v_item.name, 'variant', v_variant.name, 'quantity', p_quantity, 'via', p_added_via));
  return v_line_id;
end $$;

-- La prise de commande du personnel utilise désormais la fonction commune.
create or replace function public.add_order_item(
  p_order uuid, p_variant uuid, p_quantity integer default 1, p_modifiers uuid[] default '{}',
  p_note text default null, p_client_id uuid default null)
returns uuid language plpgsql security definer set search_path = '' as $$
declare
  v_order public.orders;
  v_line uuid;
begin
  v_order := app_private.lock_open_order(p_order, 'orders.write');
  if p_client_id is not null and exists (select 1 from public.order_items where id = p_client_id and order_id = p_order) then
    return p_client_id;
  end if;
  v_line := app_private.insert_order_line(v_order, p_variant, p_quantity, p_modifiers, p_note, p_client_id, 'staff');
  perform app_private.recompute_order(p_order);
  return v_line;
end $$;

-- -----------------------------------------------------------------------------
-- Adresses, favoris, avis
-- -----------------------------------------------------------------------------
create table public.customer_addresses (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  label text check (length(label) <= 60),
  address text not null check (length(btrim(address)) between 3 and 500),
  city text check (length(city) <= 120),
  instructions text check (length(instructions) <= 500),
  created_at timestamptz not null default now()
);
create table public.customer_favorites (
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  branch_id uuid not null references public.branches (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_id, branch_id)
);
create table public.reviews (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null,
  branch_id uuid not null,
  order_id uuid not null unique,
  customer_user_id uuid references auth.users (id) on delete set null,
  rating smallint not null check (rating between 1 and 5),
  comment text check (length(comment) <= 1000),
  status text not null default 'published' check (status in ('published', 'hidden')),
  hidden_reason text check (length(hidden_reason) <= 500),
  created_at timestamptz not null default now(),
  foreign key (organization_id, order_id) references public.orders (organization_id, id) on delete restrict,
  foreign key (organization_id, branch_id) references public.branches (organization_id, id) on delete restrict
);
create index reviews_branch_idx on public.reviews (branch_id, created_at desc) where status = 'published';

do $$
declare t text;
begin
  foreach t in array array['customer_addresses', 'customer_favorites', 'reviews'] loop
    execute format('alter table public.%I enable row level security', t);
    execute format('revoke all on public.%I from anon, authenticated', t);
  end loop;
end $$;
create trigger reviews_audit after insert or update or delete on public.reviews
  for each row execute function app_private.audit_row();

grant select, insert (label, address, city, instructions), update (label, address, city, instructions), delete
  on public.customer_addresses to authenticated;
create policy customer_addresses_own on public.customer_addresses for all to authenticated
  using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));
grant select, insert (branch_id), delete on public.customer_favorites to authenticated;
create policy customer_favorites_own on public.customer_favorites for all to authenticated
  using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));
grant select on public.reviews to authenticated;
create policy reviews_read on public.reviews for select to authenticated
  using (customer_user_id = (select auth.uid()) or branch_id in (select app_private.branch_ids_with('orders.read')));

-- -----------------------------------------------------------------------------
-- Fonctions publiques (sans compte) : établissements publiés uniquement
-- -----------------------------------------------------------------------------
create or replace function app_private.is_open_now(p_branch uuid)
returns boolean language sql stable security definer set search_path = '' as $$
  with now_local as (
    select (now() at time zone b.timezone) as ts from public.branches b where b.id = p_branch)
  select exists (
    select 1 from public.branch_opening_hours h, now_local n
     where h.branch_id = p_branch and (
       (h.closes_at > h.opens_at and h.weekday = extract(isodow from n.ts)
          and n.ts::time >= h.opens_at and n.ts::time < h.closes_at)
       or (h.closes_at < h.opens_at and h.weekday = extract(isodow from n.ts) and n.ts::time >= h.opens_at)
       or (h.closes_at < h.opens_at and h.weekday = extract(isodow from n.ts - interval '1 day') and n.ts::time < h.closes_at)))
$$;

create or replace function public.public_search_branches(
  p_query text default null, p_country text default null, p_city text default null, p_limit integer default 50)
returns table (branch_id uuid, branch_name text, brand_name text, brand_slug text, city text, country_code text,
               address_line1 text, cuisines text[], price_level smallint, description text, currency char(3),
               rating numeric, reviews_count bigint, open_now boolean, accepts_online_orders boolean, accepts_delivery boolean)
language sql stable security definer set search_path = '' as $$
  select b.id, b.name, br.name, br.slug, b.city, b.country_code, b.address_line1, br.cuisines, br.price_level,
         br.description, b.currency,
         (select round(avg(r.rating), 1) from public.reviews r where r.branch_id = b.id and r.status = 'published'),
         (select count(*) from public.reviews r where r.branch_id = b.id and r.status = 'published'),
         app_private.is_open_now(b.id), b.accepts_online_orders, b.accepts_delivery
    from public.branches b
    join public.brands br on br.id = b.brand_id and br.status = 'active'
    join public.organizations o on o.id = b.organization_id and o.status = 'active'
   where b.is_published and b.status = 'active'
     and (p_country is null or b.country_code = upper(p_country))
     and (p_city is null or lower(b.city) = lower(btrim(p_city)))
     and (p_query is null or btrim(p_query) = ''
          or lower(br.name || ' ' || b.name || ' ' || b.city || ' ' || array_to_string(br.cuisines, ' ')) like '%' || lower(btrim(p_query)) || '%'
          or exists (select 1 from public.menu_items mi join public.menu_item_branches mib on mib.item_id = mi.id
                      where mib.branch_id = b.id and mi.active and lower(mi.name) like '%' || lower(btrim(p_query)) || '%'))
   order by app_private.is_open_now(b.id) desc, br.name, b.name
   limit least(greatest(coalesce(p_limit, 50), 1), 100)
$$;

-- Carte publique d'un établissement publié (ou de son propre établissement,
-- pour un membre qui prépare sa carte).
create or replace function public.public_branch_menu(p_branch uuid)
returns jsonb language plpgsql stable security definer set search_path = '' as $$
declare
  v_branch public.branches;
begin
  select * into v_branch from public.branches where id = p_branch;
  if v_branch.id is null or not (
       (v_branch.is_published and v_branch.status = 'active'
        and exists (select 1 from public.organizations o where o.id = v_branch.organization_id and o.status = 'active'))
    or exists (select 1 from app_private.member_branch_ids() x where x = p_branch)) then
    perform app_private.fail('resto.not_found');
  end if;
  return jsonb_build_object(
    'branch', jsonb_build_object('id', v_branch.id, 'name', v_branch.name, 'city', v_branch.city,
      'address_line1', v_branch.address_line1, 'phone', v_branch.phone, 'currency', v_branch.currency,
      'timezone', v_branch.timezone, 'default_locale', v_branch.default_locale,
      'accepts_online_orders', v_branch.accepts_online_orders, 'accepts_delivery', v_branch.accepts_delivery,
      'delivery_fee_minor', v_branch.delivery_fee_minor, 'min_order_minor', v_branch.min_order_minor,
      'prices_include_tax', v_branch.prices_include_tax, 'tax_rate', v_branch.tax_rate,
      'open_now', app_private.is_open_now(v_branch.id),
      'languages', coalesce((select jsonb_agg(locale) from public.branch_languages where branch_id = v_branch.id), '[]'::jsonb)),
    'brand', (select jsonb_build_object('name', br.name, 'slug', br.slug, 'description', br.description,
                'cuisines', br.cuisines, 'price_level', br.price_level)
                from public.brands br where br.id = v_branch.brand_id),
    'hours', coalesce((select jsonb_agg(jsonb_build_object('weekday', weekday, 'opens_at', opens_at, 'closes_at', closes_at)
                                       order by weekday, opens_at)
                         from public.branch_opening_hours where branch_id = v_branch.id), '[]'::jsonb),
    'rating', (select jsonb_build_object('average', round(avg(rating), 1), 'count', count(*))
                 from public.reviews where branch_id = v_branch.id and status = 'published'),
    'categories', coalesce((
      select jsonb_agg(jsonb_build_object(
               'id', c.id, 'name', c.name, 'description', c.description,
               'translations', coalesce((select jsonb_object_agg(t.locale, jsonb_build_object('name', t.name, 'description', t.description))
                                           from public.menu_category_translations t where t.category_id = c.id), '{}'::jsonb),
               'items', (
                 select coalesce(jsonb_agg(jsonb_build_object(
                          'id', mi.id, 'name', mi.name, 'description', mi.description, 'kind', mi.kind,
                          'image_path', mi.image_path, 'sold_out', not mib.available,
                          'allergens', coalesce((select jsonb_agg(a.allergen_code) from public.item_allergens a where a.item_id = mi.id), '[]'::jsonb),
                          'translations', coalesce((select jsonb_object_agg(t.locale, jsonb_build_object('name', t.name, 'description', t.description))
                                                      from public.menu_item_translations t where t.item_id = mi.id), '{}'::jsonb),
                          'variants', (
                            select coalesce(jsonb_agg(jsonb_build_object(
                                     'id', v.id, 'name', v.name,
                                     'translations', coalesce((select jsonb_object_agg(t.locale, t.name)
                                                                 from public.item_variant_translations t where t.variant_id = v.id), '{}'::jsonb),
                                     'prices', coalesce((select jsonb_object_agg(p.channel, p.amount_minor) from public.prices p
                                                          where p.branch_id = v_branch.id and p.variant_id = v.id and p.valid_to is null), '{}'::jsonb))
                                     order by v.sort_order, v.name), '[]'::jsonb)
                              from public.item_variants v
                             where v.item_id = mi.id and v.active
                               and exists (select 1 from public.prices p where p.branch_id = v_branch.id and p.variant_id = v.id and p.valid_to is null)),
                          'groups', (
                            select coalesce(jsonb_agg(jsonb_build_object(
                                     'id', g.id, 'name', g.name, 'min_select', g.min_select, 'max_select', g.max_select,
                                     'translations', coalesce((select jsonb_object_agg(t.locale, t.name)
                                                                 from public.modifier_group_translations t where t.group_id = g.id), '{}'::jsonb),
                                     'modifiers', (
                                       select coalesce(jsonb_agg(jsonb_build_object(
                                                'id', mo.id, 'name', mo.name,
                                                'translations', coalesce((select jsonb_object_agg(t.locale, t.name)
                                                                            from public.modifier_translations t where t.modifier_id = mo.id), '{}'::jsonb),
                                                'prices', coalesce((select jsonb_object_agg(p.channel, p.amount_minor) from public.prices p
                                                                     where p.branch_id = v_branch.id and p.modifier_id = mo.id and p.valid_to is null), '{}'::jsonb))
                                                order by mo.sort_order, mo.name), '[]'::jsonb)
                                         from public.modifiers mo where mo.group_id = g.id and mo.active))
                                     order by img.sort_order, g.sort_order, g.name), '[]'::jsonb)
                              from public.item_modifier_groups img join public.modifier_groups g on g.id = img.group_id and g.active
                             where img.item_id = mi.id))
                          order by mi.sort_order, mi.name), '[]'::jsonb)
                   from public.menu_items mi
                   join public.menu_item_branches mib on mib.item_id = mi.id and mib.branch_id = v_branch.id
                  where mi.category_id = c.id and mi.active
                    and exists (select 1 from public.item_variants v join public.prices p on p.variant_id = v.id
                                 where v.item_id = mi.id and v.active and p.branch_id = v_branch.id and p.valid_to is null)))
             order by c.sort_order, c.name)
        from public.menu_categories c
       where c.brand_id = v_branch.brand_id and c.active
         and exists (select 1 from public.menu_items mi join public.menu_item_branches mib on mib.item_id = mi.id and mib.branch_id = v_branch.id
                      where mi.category_id = c.id and mi.active)), '[]'::jsonb));
end $$;

-- QR code : établissement et table correspondant à un jeton.
create or replace function public.public_table(p_token text)
returns jsonb language sql stable security definer set search_path = '' as $$
  select jsonb_build_object('branch_id', t.branch_id, 'table_id', t.id, 'label', t.label)
    from public.dining_tables t join public.branches b on b.id = t.branch_id
   where t.qr_token = p_token and t.active and b.is_published and b.status = 'active'
$$;

create or replace function public.public_reviews(p_branch uuid, p_limit integer default 20)
returns table (rating smallint, comment text, author text, created_at timestamptz)
language sql stable security definer set search_path = '' as $$
  select r.rating, r.comment, coalesce(nullif(split_part(btrim(p.display_name), ' ', 1), ''), '—'), r.created_at
    from public.reviews r
    join public.branches b on b.id = r.branch_id and b.is_published
    left join public.profiles p on p.id = r.customer_user_id
   where r.branch_id = p_branch and r.status = 'published'
   order by r.created_at desc
   limit least(greatest(coalesce(p_limit, 20), 1), 100)
$$;

-- -----------------------------------------------------------------------------
-- Commandes des clients
-- -----------------------------------------------------------------------------

-- Passe une commande. p_items : [{"variant_id":…, "quantity":1, "modifier_ids":[…], "note":"…"}, …]
-- Sur place (QR) : p_table_token ; une table déjà occupée reçoit les articles
-- dans sa commande en cours. Les articles d'un client attendent toujours la
-- validation du restaurant avant de partir en cuisine.
create or replace function public.place_online_order(
  p_branch uuid, p_channel text, p_items jsonb, p_table_token text default null, p_scheduled_for timestamptz default null,
  p_delivery_address text default null, p_delivery_instructions text default null, p_contact_phone text default null,
  p_customer_name text default null, p_note text default null, p_client_id uuid default null)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare
  v_uid uuid := auth.uid();
  v_branch public.branches;
  v_table public.dining_tables;
  v_order public.orders;
  v_date date;
  v_item jsonb;
  v_lines_total bigint;
begin
  if v_uid is null then raise exception 'resto.not_authenticated' using errcode = '42501'; end if;
  if p_client_id is not null then
    select * into v_order from public.orders where id = p_client_id and customer_user_id = v_uid;
    if v_order.id is not null then return jsonb_build_object('order_id', v_order.id, 'number', v_order.number); end if;
  end if;
  select * into v_branch from public.branches where id = p_branch;
  if v_branch.id is null or not v_branch.is_published or v_branch.status <> 'active' or not v_branch.accepts_online_orders
     or not exists (select 1 from public.organizations o where o.id = v_branch.organization_id and o.status = 'active') then
    perform app_private.fail('resto.online_orders_closed');
  end if;
  if coalesce(p_channel, '') not in ('dine_in', 'takeaway', 'delivery') then perform app_private.fail('resto.invalid_order'); end if;
  if p_channel = 'delivery' and (not v_branch.accepts_delivery or length(btrim(coalesce(p_delivery_address, ''))) < 5
                                  or length(btrim(coalesce(p_contact_phone, ''))) < 6) then
    perform app_private.fail('resto.delivery_unavailable');
  end if;
  if p_channel = 'dine_in' then
    select * into v_table from public.dining_tables where qr_token = p_table_token and branch_id = p_branch and active;
    if v_table.id is null then perform app_private.fail('resto.invalid_table'); end if;
  end if;
  if jsonb_typeof(coalesce(p_items, 'null'::jsonb)) <> 'array' then perform app_private.fail('resto.invalid_order'); end if;
  if jsonb_array_length(p_items) not between 1 and 50 then perform app_private.fail('resto.invalid_order'); end if;
  if p_scheduled_for is not null and (p_scheduled_for < now() or p_scheduled_for > now() + interval '14 days') then
    perform app_private.fail('resto.invalid_order');
  end if;
  -- Anti-abus : au plus 5 commandes en attente par client et par établissement.
  if (select count(*) from public.orders where customer_user_id = v_uid and branch_id = p_branch
        and acceptance = 'pending' and status = 'open') >= 5 then
    perform app_private.fail('resto.rate_limited');
  end if;

  if p_channel = 'dine_in' then
    perform pg_advisory_xact_lock(hashtext('resto.table.' || v_table.id::text));
    select * into v_order from public.orders where table_id = v_table.id and status = 'open' for update;
  end if;
  if v_order.id is null then
    v_date := (now() at time zone v_branch.timezone)::date;
    insert into public.orders (id, organization_id, brand_id, branch_id, business_date, number, channel, source, table_id,
                               note, currency, prices_include_tax, tax_rate, opened_by, customer_user_id, acceptance,
                               scheduled_for, customer_name, contact_phone, delivery_address, delivery_instructions,
                               delivery_fee_minor)
    values (coalesce(p_client_id, gen_random_uuid()), v_branch.organization_id, v_branch.brand_id, p_branch, v_date,
            app_private.next_counter(p_branch, 'order:' || v_date::text), p_channel,
            case when p_channel = 'dine_in' then 'qr' else 'app' end, v_table.id, nullif(btrim(p_note), ''),
            v_branch.currency, v_branch.prices_include_tax, v_branch.tax_rate, null, v_uid, 'pending',
            p_scheduled_for, nullif(btrim(p_customer_name), ''), nullif(btrim(p_contact_phone), ''),
            nullif(btrim(p_delivery_address), ''), nullif(btrim(p_delivery_instructions), ''),
            case when p_channel = 'delivery' then v_branch.delivery_fee_minor else 0 end)
    returning * into v_order;
    perform app_private.log_order(v_order, 'opened', null, jsonb_build_object('channel', p_channel, 'source', 'customer'));
  else
    update public.orders set customer_user_id = coalesce(customer_user_id, v_uid), acceptance = 'pending'
     where id = v_order.id returning * into v_order;
  end if;

  for v_item in select * from jsonb_array_elements(p_items) loop
    perform app_private.insert_order_line(v_order, (v_item ->> 'variant_id')::uuid, coalesce((v_item ->> 'quantity')::int, 1),
      array(select jsonb_array_elements_text(coalesce(v_item -> 'modifier_ids', '[]'::jsonb))::uuid),
      v_item ->> 'note', null, 'customer');
  end loop;
  perform app_private.recompute_order(v_order.id);

  select coalesce(sum(line_total_minor), 0) into v_lines_total
    from public.order_items where order_id = v_order.id and prep_status <> 'cancelled';
  if p_channel <> 'dine_in' and v_lines_total < v_branch.min_order_minor then
    perform app_private.fail('resto.below_minimum');
  end if;
  return jsonb_build_object('order_id', v_order.id, 'number', v_order.number);
exception
  when invalid_text_representation then perform app_private.fail('resto.invalid_order');
end $$;

-- Le restaurant accepte : les articles en attente partent en cuisine.
create or replace function public.accept_online_order(p_order uuid)
returns void language plpgsql security definer set search_path = '' as $$
declare v_order public.orders;
begin
  v_order := app_private.lock_open_order(p_order, 'orders.write');
  if v_order.acceptance <> 'pending' then perform app_private.fail('resto.invalid_status'); end if;
  update public.orders set acceptance = 'accepted' where id = p_order;
  perform public.send_order(p_order);
end $$;

-- Refus : les articles du client non envoyés sont retirés ; une commande sans
-- autre article est annulée.
create or replace function public.reject_online_order(p_order uuid, p_reason text)
returns void language plpgsql security definer set search_path = '' as $$
declare v_order public.orders;
begin
  v_order := app_private.lock_open_order(p_order, 'orders.write');
  if v_order.acceptance <> 'pending' then perform app_private.fail('resto.invalid_status'); end if;
  if length(btrim(coalesce(p_reason, ''))) < 3 then perform app_private.fail('resto.reason_required'); end if;
  delete from public.order_items where order_id = p_order and prep_status = 'pending' and added_via = 'customer';
  update public.orders set acceptance = 'rejected', reject_reason = btrim(p_reason) where id = p_order;
  if not exists (select 1 from public.order_items where order_id = p_order and prep_status <> 'cancelled') then
    update public.orders set status = 'cancelled', cancelled_at = now(), cancelled_by = auth.uid(),
           cancel_reason = btrim(p_reason) where id = p_order;
    perform app_private.log_order(v_order, 'cancelled', null, jsonb_build_object('reason', btrim(p_reason)));
  else
    update public.orders set acceptance = 'accepted' where id = p_order;
  end if;
  perform app_private.recompute_order(p_order);
end $$;

-- Le client annule tant que le restaurant n'a pas accepté.
create or replace function public.customer_cancel_order(p_order uuid)
returns void language plpgsql security definer set search_path = '' as $$
declare v_order public.orders;
begin
  select * into v_order from public.orders where id = p_order for update;
  if v_order.id is null or v_order.customer_user_id is distinct from auth.uid() then
    raise exception 'resto.forbidden' using errcode = '42501';
  end if;
  if v_order.status <> 'open' or v_order.acceptance <> 'pending' or v_order.table_id is not null then
    perform app_private.fail('resto.too_late_to_cancel');
  end if;
  update public.order_items set prep_status = 'cancelled', cancelled_at = now(), cancelled_by = auth.uid(),
         cancel_reason = 'annulée par le client' where order_id = p_order and prep_status <> 'cancelled';
  perform app_private.recompute_order(p_order);
  update public.orders set status = 'cancelled', cancelled_at = now(), cancelled_by = auth.uid(),
         cancel_reason = 'annulée par le client' where id = p_order;
  perform app_private.log_order(v_order, 'cancelled', null, jsonb_build_object('by', 'customer'));
end $$;

-- Mes commandes (client), avec le nom du restaurant.
create or replace function public.my_customer_orders(p_limit integer default 50)
returns table (order_id uuid, number integer, branch_id uuid, branch_name text, brand_name text, channel text,
               status text, acceptance text, total_minor bigint, currency char(3), opened_at timestamptz,
               has_review boolean, reject_reason text)
language sql stable security definer set search_path = '' as $$
  select o.id, o.number, o.branch_id, b.name, br.name, o.channel, o.status, o.acceptance, o.total_minor, o.currency,
         o.opened_at, exists (select 1 from public.reviews r where r.order_id = o.id), o.reject_reason
    from public.orders o
    join public.branches b on b.id = o.branch_id
    join public.brands br on br.id = b.brand_id
   where o.customer_user_id = auth.uid()
   order by o.opened_at desc
   limit least(greatest(coalesce(p_limit, 50), 1), 200)
$$;

-- Avis vérifié : uniquement sur sa propre commande payée, une seule fois, sous 30 jours.
create or replace function public.submit_review(p_order uuid, p_rating smallint, p_comment text default null)
returns uuid language plpgsql security definer set search_path = '' as $$
declare
  v_order public.orders;
  v_id uuid;
begin
  select * into v_order from public.orders where id = p_order;
  if v_order.id is null or v_order.customer_user_id is distinct from auth.uid() then
    raise exception 'resto.forbidden' using errcode = '42501';
  end if;
  if v_order.status <> 'closed' or v_order.closed_at < now() - interval '30 days' then
    perform app_private.fail('resto.review_not_allowed');
  end if;
  if coalesce(p_rating, 0) not between 1 and 5 then perform app_private.fail('resto.invalid_review'); end if;
  if exists (select 1 from public.reviews where order_id = p_order) then perform app_private.fail('resto.review_not_allowed'); end if;
  insert into public.reviews (organization_id, branch_id, order_id, customer_user_id, rating, comment)
  values (v_order.organization_id, v_order.branch_id, p_order, auth.uid(), p_rating, nullif(btrim(p_comment), ''))
  returning id into v_id;
  return v_id;
end $$;

-- Modération par le restaurant (avis injurieux…) : masqué avec motif, jamais supprimé.
create or replace function public.hide_review(p_review uuid, p_reason text)
returns void language plpgsql security definer set search_path = '' as $$
declare v public.reviews;
begin
  select * into v from public.reviews where id = p_review for update;
  perform app_private.assert_branch_perm(v.branch_id, 'customers.manage');
  if length(btrim(coalesce(p_reason, ''))) < 3 then perform app_private.fail('resto.reason_required'); end if;
  update public.reviews set status = 'hidden', hidden_reason = btrim(p_reason) where id = p_review;
end $$;

revoke all on function public.public_search_branches(text, text, text, integer), public.public_branch_menu(uuid),
  public.public_table(text), public.public_reviews(uuid, integer),
  public.place_online_order(uuid, text, jsonb, text, timestamptz, text, text, text, text, text, uuid),
  public.accept_online_order(uuid), public.reject_online_order(uuid, text), public.customer_cancel_order(uuid),
  public.my_customer_orders(integer), public.submit_review(uuid, smallint, text), public.hide_review(uuid, text)
  from public;
grant execute on function public.public_search_branches(text, text, text, integer), public.public_branch_menu(uuid),
  public.public_table(text), public.public_reviews(uuid, integer) to anon, authenticated;
grant execute on function public.place_online_order(uuid, text, jsonb, text, timestamptz, text, text, text, text, text, uuid),
  public.accept_online_order(uuid), public.reject_online_order(uuid, text), public.customer_cancel_order(uuid),
  public.my_customer_orders(integer), public.submit_review(uuid, smallint, text), public.hide_review(uuid, text)
  to authenticated;

revoke all on all functions in schema app_private from public, anon, authenticated;
grant execute on function app_private.member_org_ids(), app_private.member_branch_ids(),
  app_private.org_ids_with(text), app_private.branch_ids_with(text),
  app_private.full_access_org_ids(), app_private.assigned_branch_ids(),
  app_private.org_ids_with_any_branch(text) to authenticated;
