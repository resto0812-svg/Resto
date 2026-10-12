-- =============================================================================
-- Resto — 018_vitrine_publicite
-- 1. Profil complet de l'établissement (slogan, n° d'immatriculation,
--    WhatsApp, position GPS, zone de livraison, mode vacances).
-- 2. Préférences de chaque membre (notifications, sons).
-- 3. Articles : galerie de photos (5 au plus avec la photo principale),
--    vidéo, temps de préparation, jours de vente, familles « dessert » et
--    « formule » ; stock du jour par établissement (décompté à la commande,
--    rupture automatique à zéro) ; duplication d'un article.
-- 4. Publicité : campagnes (vidéo, carrousel, story 24 h, menu sponsorisé,
--    notification, petite annonce), médiathèque, ciblage, budget prévu,
--    statistiques (vues, clics, commandes, chiffre d'affaires).
-- 5. Tableau de bord d'un établissement (accueil et rapports).
-- À coller APRÈS 017, puis supabase/tests/018_vitrine_publicite_tests.sql.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. Profil de l'établissement
-- -----------------------------------------------------------------------------
alter table public.brands
  add column if not exists slogan text check (length(slogan) <= 160);
grant update (slogan) on public.brands to authenticated;

alter table public.branches
  add column if not exists registration_number text check (length(registration_number) <= 60),
  add column if not exists whatsapp text check (length(whatsapp) <= 30),
  add column if not exists latitude numeric(9, 6) check (latitude between -90 and 90),
  add column if not exists longitude numeric(9, 6) check (longitude between -180 and 180),
  add column if not exists delivery_zone text check (length(delivery_zone) <= 300),
  add column if not exists vacation_mode boolean not null default false,
  add column if not exists vacation_message text check (length(vacation_message) <= 200);
grant insert (registration_number, whatsapp, latitude, longitude, delivery_zone, vacation_mode, vacation_message),
  update (registration_number, whatsapp, latitude, longitude, delivery_zone, vacation_mode, vacation_message)
  on public.branches to authenticated;

-- -----------------------------------------------------------------------------
-- 2. Préférences d'un membre (par organisation)
-- -----------------------------------------------------------------------------
create table if not exists public.member_preferences (
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  organization_id uuid not null references public.organizations (id) on delete cascade,
  prefs jsonb not null default '{}'::jsonb check (jsonb_typeof(prefs) = 'object' and length(prefs::text) <= 4000),
  updated_at timestamptz not null default now(),
  primary key (user_id, organization_id)
);
alter table public.member_preferences enable row level security;
-- L'enregistrement se fait par « upsert » : toutes les colonnes envoyées doivent être modifiables (la RLS borne).
grant select, insert (user_id, organization_id, prefs), update (user_id, organization_id, prefs)
  on public.member_preferences to authenticated;
drop policy if exists member_preferences_own on public.member_preferences;
create policy member_preferences_own on public.member_preferences for all to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()) and organization_id in (select app_private.member_org_ids()));

-- -----------------------------------------------------------------------------
-- 3. Articles : médias, préparation, jours, familles, stock
-- -----------------------------------------------------------------------------
alter table public.menu_items drop constraint if exists menu_items_kind_check;
alter table public.menu_items add constraint menu_items_kind_check
  check (kind in ('food', 'drink', 'dessert', 'menu', 'other'));

-- Postes de préparation : mêmes familles ; desserts et formules partent en cuisine par défaut.
alter table public.prep_stations drop constraint if exists prep_stations_kinds_check;
alter table public.prep_stations add constraint prep_stations_kinds_check
  check (cardinality(kinds) between 1 and 5 and kinds <@ array['food', 'drink', 'dessert', 'menu', 'other']);
update public.prep_stations
   set kinds = kinds || array(select k from unnest(array['dessert', 'menu']) k where not (k = any (kinds)))
 where 'food' = any (kinds);

alter table public.menu_items
  add column if not exists gallery_paths text[] not null default '{}' check (cardinality(gallery_paths) <= 4),
  add column if not exists video_path text check (video_path is null or length(video_path) <= 300),
  add column if not exists prep_minutes smallint check (prep_minutes between 1 and 240),
  add column if not exists available_days smallint[] check (available_days is null
    or (cardinality(available_days) between 1 and 7 and available_days <@ array[1, 2, 3, 4, 5, 6, 7]::smallint[]));
grant update (gallery_paths, video_path, prep_minutes, available_days) on public.menu_items to authenticated;

-- Tous les médias d'un article sont rangés sous {organisation}/{article}/.
create or replace function app_private.check_item_media()
returns trigger language plpgsql security definer set search_path = '' as $$
declare
  v_prefix text := new.organization_id::text || '/' || new.id::text || '/';
  v_path text;
begin
  foreach v_path in array coalesce(new.gallery_paths, '{}') loop
    if v_path is null or length(v_path) > 300 or v_path not like v_prefix || '%' then
      perform app_private.fail('resto.invalid_image');
    end if;
  end loop;
  if new.video_path is not null and new.video_path not like v_prefix || '%' then
    perform app_private.fail('resto.invalid_image');
  end if;
  return new;
end $$;
drop trigger if exists menu_items_check_media on public.menu_items;
create trigger menu_items_check_media before insert or update of gallery_paths, video_path on public.menu_items
  for each row execute function app_private.check_item_media();

-- Photos jusqu'à 5 Mo ; vidéos (30 s environ) dans leur propre bucket.
update storage.buckets set file_size_limit = 5242880 where id = 'menu-images';
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('menu-videos', 'menu-videos', true, 31457280, array['video/mp4', 'video/webm', 'video/quicktime'])
on conflict (id) do update set public = true, file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;
drop policy if exists resto_menu_videos_insert on storage.objects;
drop policy if exists resto_menu_videos_update on storage.objects;
drop policy if exists resto_menu_videos_delete on storage.objects;
create policy resto_menu_videos_insert on storage.objects for insert to authenticated
  with check (bucket_id = 'menu-videos'
    and (storage.foldername(name))[1] in (select x::text from app_private.org_ids_with('menus.manage') x));
create policy resto_menu_videos_update on storage.objects for update to authenticated
  using (bucket_id = 'menu-videos'
    and (storage.foldername(name))[1] in (select x::text from app_private.org_ids_with('menus.manage') x))
  with check (bucket_id = 'menu-videos'
    and (storage.foldername(name))[1] in (select x::text from app_private.org_ids_with('menus.manage') x));
create policy resto_menu_videos_delete on storage.objects for delete to authenticated
  using (bucket_id = 'menu-videos'
    and (storage.foldername(name))[1] in (select x::text from app_private.org_ids_with('menus.manage') x));

-- Stock du jour par établissement (null = non suivi).
alter table public.menu_item_branches
  add column if not exists stock_qty integer check (stock_qty is null or stock_qty between 0 and 1000000),
  add column if not exists low_stock_threshold integer not null default 5 check (low_stock_threshold between 0 and 100000);
grant update (stock_qty, low_stock_threshold) on public.menu_item_branches to authenticated;

-- Décompte à l'ajout d'une ligne, remise en stock à l'annulation ; à zéro
-- l'article passe en rupture, et redevient disponible s'il est réapprovisionné.
create or replace function app_private.menu_stock_on_line()
returns trigger language plpgsql security definer set search_path = '' as $$
declare
  v_delta integer := 0;
  v_left integer;
  v_item uuid;
  v_branch uuid;
begin
  if tg_op = 'INSERT' then
    if new.prep_status <> 'cancelled' then v_delta := new.quantity; end if;
  elsif tg_op = 'DELETE' then
    if old.prep_status <> 'cancelled' then v_delta := -old.quantity; end if;
  elsif new.prep_status = 'cancelled' and old.prep_status <> 'cancelled' then
    v_delta := -old.quantity;
  elsif new.prep_status <> 'cancelled' and new.quantity <> old.quantity then
    v_delta := new.quantity - old.quantity;
  end if;
  if tg_op = 'DELETE' then
    v_item := old.item_id; v_branch := old.branch_id;
  else
    v_item := new.item_id; v_branch := new.branch_id;
  end if;

  if v_delta <> 0 then
    update public.menu_item_branches
       set stock_qty = stock_qty - v_delta,
           available = case when stock_qty - v_delta <= 0 then false
                            when stock_qty <= 0 and stock_qty - v_delta > 0 then true
                            else available end,
           updated_at = now()
     where item_id = v_item and branch_id = v_branch and stock_qty is not null
     returning stock_qty into v_left;
    if v_left is not null and v_left < 0 then
      perform app_private.fail('resto.out_of_stock');
    end if;
  end if;
  if tg_op = 'DELETE' then return old; end if;
  return new;
end $$;
drop trigger if exists order_items_menu_stock on public.order_items;
create trigger order_items_menu_stock before insert or delete or update of prep_status, quantity on public.order_items
  for each row execute function app_private.menu_stock_on_line();

-- Copie d'un article : tailles, options, allergènes, traductions, établissements
-- et prix courants ; la copie est masquée jusqu'à sa relecture.
create or replace function public.duplicate_menu_item(p_item uuid, p_suffix text default ' (2)')
returns uuid language plpgsql security definer set search_path = '' as $$
declare
  v public.menu_items;
  v_new uuid := gen_random_uuid();
  r record;
  v_variant uuid;
begin
  select * into v from public.menu_items where id = p_item;
  if v.id is null or not app_private.has_org_perm(v.organization_id, 'menus.manage') then
    raise exception 'resto.forbidden' using errcode = '42501';
  end if;
  insert into public.menu_items (id, organization_id, brand_id, category_id, name, description, kind, sort_order, active,
                                 prep_minutes, available_days)
  values (v_new, v.organization_id, v.brand_id, v.category_id, left(v.name || left(coalesce(p_suffix, ' (2)'), 30), 120),
          v.description, v.kind,
          v.sort_order + 1, false, v.prep_minutes, v.available_days);
  for r in select * from public.item_variants where item_id = p_item and active order by sort_order loop
    v_variant := gen_random_uuid();
    insert into public.item_variants (id, organization_id, brand_id, item_id, name, sort_order, active)
    values (v_variant, r.organization_id, r.brand_id, v_new, r.name, r.sort_order, true);
    insert into public.item_variant_translations (organization_id, variant_id, locale, name)
    select organization_id, v_variant, locale, name from public.item_variant_translations where variant_id = r.id;
    insert into public.prices (organization_id, brand_id, branch_id, variant_id, channel, currency, amount_minor, created_by)
    select organization_id, brand_id, branch_id, v_variant, channel, currency, amount_minor, auth.uid()
      from public.prices where variant_id = r.id and valid_to is null;
  end loop;
  insert into public.item_modifier_groups (organization_id, brand_id, item_id, group_id, sort_order)
  select organization_id, brand_id, v_new, group_id, sort_order from public.item_modifier_groups where item_id = p_item;
  insert into public.item_allergens (organization_id, item_id, allergen_code)
  select organization_id, v_new, allergen_code from public.item_allergens where item_id = p_item;
  insert into public.menu_item_translations (organization_id, item_id, locale, name, description)
  select organization_id, v_new, locale, name, description from public.menu_item_translations where item_id = p_item;
  insert into public.menu_item_branches (organization_id, brand_id, item_id, branch_id, available)
  select organization_id, brand_id, v_new, branch_id, true from public.menu_item_branches where item_id = p_item;
  return v_new;
end $$;

-- -----------------------------------------------------------------------------
-- 4. Publicité
-- -----------------------------------------------------------------------------
insert into public.permissions (code, scope, description) values
  ('marketing.manage', 'organization', 'Publicité : campagnes, médiathèque, statistiques')
on conflict (code) do nothing;
insert into public.role_permissions (role_code, permission_code) values
  ('owner', 'marketing.manage'), ('admin', 'marketing.manage'), ('manager', 'marketing.manage')
on conflict do nothing;

create table if not exists public.ad_campaigns (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations (id) on delete restrict,
  brand_id uuid not null,
  format text not null check (format in ('video', 'carousel', 'story', 'sponsored_menu', 'push', 'classified')),
  title text not null check (length(btrim(title)) between 1 and 120),
  body text check (length(body) <= 1000),
  cta_label text check (length(cta_label) <= 40),
  cta_url text check (cta_url is null or (length(cta_url) <= 300 and cta_url ~ '^https?://\S+$')),
  media jsonb not null default '[]'::jsonb check (jsonb_typeof(media) = 'array' and jsonb_array_length(media) <= 10),
  item_ids uuid[] not null default '{}' check (cardinality(item_ids) <= 20),
  branch_ids uuid[] not null default '{}' check (cardinality(branch_ids) <= 200),
  target_areas text[] not null default '{}' check (cardinality(target_areas) <= 30),
  moments text[] not null default '{}'
    check (moments <@ array['morning', 'noon', 'afternoon', 'evening', 'night']::text[]),
  daily_budget_minor bigint check (daily_budget_minor between 0 and 9007199254740991),
  currency char(3) references public.ref_currencies (code),
  starts_at timestamptz not null default now(),
  ends_at timestamptz,
  status text not null default 'draft' check (status in ('draft', 'active', 'paused', 'ended')),
  views integer not null default 0,
  clicks integer not null default 0,
  orders integer not null default 0,
  revenue_minor bigint not null default 0,
  created_by uuid default auth.uid() references auth.users (id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (organization_id, id),
  check (ends_at is null or ends_at > starts_at),
  foreign key (organization_id, brand_id) references public.brands (organization_id, id) on delete restrict
);
create index if not exists ad_campaigns_org_idx on public.ad_campaigns (organization_id, status, starts_at desc);
drop trigger if exists ad_campaigns_touch on public.ad_campaigns;
create trigger ad_campaigns_touch before update on public.ad_campaigns
  for each row execute function app_private.touch_updated_at();

-- Règles propres à chaque format ; médias rangés sous le dossier de l'organisation.
create or replace function app_private.check_ad_campaign()
returns trigger language plpgsql security definer set search_path = '' as $$
declare
  m jsonb;
begin
  if new.format = 'story' then
    new.ends_at := new.starts_at + interval '24 hours';
  end if;
  for m in select * from jsonb_array_elements(new.media) loop
    if jsonb_typeof(m) <> 'object' or coalesce(m ->> 'kind', '') not in ('image', 'video')
       or coalesce(m ->> 'path', '') not like new.organization_id::text || '/%'
       or length(m ->> 'path') > 300 then
      perform app_private.fail('resto.invalid_media');
    end if;
  end loop;
  if new.status = 'active' then
    if new.format = 'video' and not exists (
         select 1 from jsonb_array_elements(new.media) x where x ->> 'kind' = 'video') then
      perform app_private.fail('resto.media_required');
    end if;
    if new.format in ('carousel', 'story') and jsonb_array_length(new.media) = 0 then
      perform app_private.fail('resto.media_required');
    end if;
    if new.format = 'sponsored_menu' and cardinality(new.item_ids) = 0 then
      perform app_private.fail('resto.items_required');
    end if;
  end if;
  if exists (select 1 from unnest(new.item_ids) i
             where not exists (select 1 from public.menu_items mi
                                where mi.id = i and mi.organization_id = new.organization_id)) then
    raise exception 'resto.forbidden' using errcode = '42501';
  end if;
  if exists (select 1 from unnest(new.branch_ids) b
             where not exists (select 1 from public.branches br
                                where br.id = b and br.organization_id = new.organization_id)) then
    raise exception 'resto.forbidden' using errcode = '42501';
  end if;
  -- Les statistiques ne se modifient que par le serveur.
  if tg_op = 'UPDATE' and current_setting('resto.ad_stats', true) is distinct from 'on'
     and (new.views, new.clicks, new.orders, new.revenue_minor) is distinct from
         (old.views, old.clicks, old.orders, old.revenue_minor) then
    raise exception 'resto.forbidden' using errcode = '42501';
  end if;
  if tg_op = 'INSERT' and current_setting('resto.ad_stats', true) is distinct from 'on' then
    new.views := 0; new.clicks := 0; new.orders := 0; new.revenue_minor := 0;
  end if;
  return new;
end $$;
drop trigger if exists ad_campaigns_check on public.ad_campaigns;
create trigger ad_campaigns_check before insert or update on public.ad_campaigns
  for each row execute function app_private.check_ad_campaign();

alter table public.ad_campaigns enable row level security;
grant select, delete,
  insert (id, organization_id, brand_id, format, title, body, cta_label, cta_url, media, item_ids, branch_ids,
          target_areas, moments, daily_budget_minor, currency, starts_at, ends_at, status),
  update (format, title, body, cta_label, cta_url, media, item_ids, branch_ids, target_areas, moments,
          daily_budget_minor, currency, starts_at, ends_at, status)
  on public.ad_campaigns to authenticated;
drop policy if exists ad_campaigns_read on public.ad_campaigns;
drop policy if exists ad_campaigns_write on public.ad_campaigns;
create policy ad_campaigns_read on public.ad_campaigns for select to authenticated
  using (organization_id in (select app_private.member_org_ids()));
create policy ad_campaigns_write on public.ad_campaigns for all to authenticated
  using (organization_id in (select app_private.org_ids_with('marketing.manage')))
  with check (organization_id in (select app_private.org_ids_with('marketing.manage')));

-- Médiathèque publicitaire : photos et vidéos (50 Mo au plus).
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('marketing-media', 'marketing-media', true, 52428800,
        array['image/jpeg', 'image/png', 'image/webp', 'video/mp4', 'video/webm', 'video/quicktime'])
on conflict (id) do update set public = true, file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;
drop policy if exists resto_marketing_media_read on storage.objects;
drop policy if exists resto_marketing_media_insert on storage.objects;
drop policy if exists resto_marketing_media_update on storage.objects;
drop policy if exists resto_marketing_media_delete on storage.objects;
create policy resto_marketing_media_read on storage.objects for select to authenticated
  using (bucket_id = 'marketing-media'
    and (storage.foldername(name))[1] in (select x::text from app_private.member_org_ids() x));
create policy resto_marketing_media_insert on storage.objects for insert to authenticated
  with check (bucket_id = 'marketing-media'
    and (storage.foldername(name))[1] in (select x::text from app_private.org_ids_with('marketing.manage') x));
create policy resto_marketing_media_update on storage.objects for update to authenticated
  using (bucket_id = 'marketing-media'
    and (storage.foldername(name))[1] in (select x::text from app_private.org_ids_with('marketing.manage') x))
  with check (bucket_id = 'marketing-media'
    and (storage.foldername(name))[1] in (select x::text from app_private.org_ids_with('marketing.manage') x));
create policy resto_marketing_media_delete on storage.objects for delete to authenticated
  using (bucket_id = 'marketing-media'
    and (storage.foldername(name))[1] in (select x::text from app_private.org_ids_with('marketing.manage') x));

-- Commandes issues d'une publicité : comptées à la clôture.
alter table public.orders
  add column if not exists ad_campaign_id uuid references public.ad_campaigns (id) on delete set null;

create or replace function app_private.ad_order_closed()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  if new.ad_campaign_id is not null and new.status = 'closed' and old.status <> 'closed' then
    perform set_config('resto.ad_stats', 'on', true);
    update public.ad_campaigns
       set orders = orders + 1, revenue_minor = revenue_minor + new.total_minor
     where id = new.ad_campaign_id and organization_id = new.organization_id;
    perform set_config('resto.ad_stats', 'off', true);
  end if;
  return new;
end $$;
drop trigger if exists orders_ad_closed on public.orders;
create trigger orders_ad_closed after update of status on public.orders
  for each row execute function app_private.ad_order_closed();

-- Vues et clics enregistrés par l'espace client (campagne en cours uniquement).
create or replace function public.record_ad_event(p_campaign uuid, p_event text)
returns void language plpgsql security definer set search_path = '' as $$
begin
  if p_event not in ('view', 'click') then perform app_private.fail('resto.invalid_event'); end if;
  perform set_config('resto.ad_stats', 'on', true);
  update public.ad_campaigns
     set views = views + case when p_event = 'view' then 1 else 0 end,
         clicks = clicks + case when p_event = 'click' then 1 else 0 end
   where id = p_campaign and status = 'active' and starts_at <= now() and (ends_at is null or ends_at > now());
  perform set_config('resto.ad_stats', 'off', true);
end $$;

-- Campagnes visibles par le public (établissements publiés, campagnes en cours).
create or replace function public.public_ads(p_branch uuid default null, p_limit integer default 20)
returns jsonb language sql stable security definer set search_path = '' as $$
  select coalesce(jsonb_agg(x order by x ->> 'starts_at' desc), '[]'::jsonb) from (
    select jsonb_build_object(
      'id', c.id, 'format', c.format, 'title', c.title, 'body', c.body, 'cta_label', c.cta_label,
      'cta_url', c.cta_url, 'media', c.media, 'item_ids', c.item_ids, 'starts_at', c.starts_at, 'ends_at', c.ends_at,
      'brand_name', br.name, 'logo_path', br.logo_path,
      'branch_id', (select b.id from public.branches b
                     where b.brand_id = c.brand_id and b.is_published and b.status = 'active'
                       and (cardinality(c.branch_ids) = 0 or b.id = any (c.branch_ids))
                       and (p_branch is null or b.id = p_branch)
                     order by b.created_at limit 1)) as x
      from public.ad_campaigns c
      join public.brands br on br.id = c.brand_id and br.status = 'active'
     where c.status = 'active' and c.format <> 'push'
       and c.starts_at <= now() and (c.ends_at is null or c.ends_at > now())
       and exists (select 1 from public.branches b
                    where b.brand_id = c.brand_id and b.is_published and b.status = 'active'
                      and (cardinality(c.branch_ids) = 0 or b.id = any (c.branch_ids))
                      and (p_branch is null or b.id = p_branch))
     limit least(greatest(coalesce(p_limit, 20), 1), 50)
  ) s;
$$;

-- -----------------------------------------------------------------------------
-- 5. Tableau de bord d'un établissement
-- -----------------------------------------------------------------------------
create or replace function public.branch_dashboard(p_branch uuid, p_from date, p_to date)
returns jsonb language plpgsql stable security definer set search_path = '' as $$
declare
  v_branch public.branches;
  v_fin boolean;
  v_days integer;
  v_prev_from date;
  v_prev_to date;
  v_result jsonb;
begin
  select * into v_branch from public.branches where id = p_branch;
  if v_branch.id is null or not exists (select 1 from app_private.branch_ids_with('orders.read') x where x = p_branch) then
    raise exception 'resto.forbidden' using errcode = '42501';
  end if;
  if p_from is null or p_to is null or p_to < p_from or p_to - p_from > 366 then
    perform app_private.fail('resto.invalid_period');
  end if;
  v_fin := exists (select 1 from app_private.branch_ids_with('finance.read') x where x = p_branch);
  v_days := p_to - p_from + 1;
  v_prev_to := p_from - 1;
  v_prev_from := p_from - v_days;

  v_result := jsonb_build_object(
    'currency', v_branch.currency,
    'finance', v_fin,
    'open_orders', (select count(*) from public.orders o where o.branch_id = p_branch and o.status = 'open'),
    'pending_orders', (select count(*) from public.orders o
                        where o.branch_id = p_branch and o.status = 'open' and o.acceptance = 'pending'),
    'orders_count', (select count(*) from public.orders o
                      where o.branch_id = p_branch and o.status <> 'cancelled'
                        and o.business_date between p_from and p_to),
    'tables_total', (select count(*) from public.dining_tables t where t.branch_id = p_branch and t.active),
    'tables_busy', (select count(distinct o.table_id) from public.orders o
                     where o.branch_id = p_branch and o.status = 'open' and o.table_id is not null),
    'low_stock', (select coalesce(jsonb_agg(jsonb_build_object('item_id', mi.id, 'name', mi.name, 'stock', mib.stock_qty)
                                            order by mib.stock_qty), '[]'::jsonb)
                    from public.menu_item_branches mib
                    join public.menu_items mi on mi.id = mib.item_id and mi.active
                   where mib.branch_id = p_branch and mib.stock_qty is not null
                     and mib.stock_qty <= mib.low_stock_threshold)
  );
  if not v_fin then return v_result; end if;

  return v_result || jsonb_build_object(
    'sales', (select coalesce(sum(o.total_minor), 0) from public.orders o
               where o.branch_id = p_branch and o.status = 'closed' and o.business_date between p_from and p_to),
    'prev_sales', (select coalesce(sum(o.total_minor), 0) from public.orders o
                    where o.branch_id = p_branch and o.status = 'closed' and o.business_date between v_prev_from and v_prev_to),
    'orders_closed', (select count(*) from public.orders o
                       where o.branch_id = p_branch and o.status = 'closed' and o.business_date between p_from and p_to),
    'by_day', (select coalesce(jsonb_agg(jsonb_build_object('day', d.day, 'total', d.total) order by d.day), '[]'::jsonb)
                 from (select g::date as day,
                              (select coalesce(sum(o.total_minor), 0) from public.orders o
                                where o.branch_id = p_branch and o.status = 'closed' and o.business_date = g::date) as total
                         from generate_series(p_from, p_to, interval '1 day') g) d),
    'by_hour', (select coalesce(jsonb_agg(jsonb_build_object('hour', h.hour, 'total', h.total) order by h.hour), '[]'::jsonb)
                  from (select extract(hour from o.closed_at at time zone v_branch.timezone)::int as hour,
                               sum(o.total_minor) as total
                          from public.orders o
                         where o.branch_id = p_branch and o.status = 'closed' and o.business_date between p_from and p_to
                         group by 1) h),
    'top_items', (select coalesce(jsonb_agg(jsonb_build_object('name', t.item_name, 'quantity', t.qty, 'total', t.total)
                                            order by t.qty desc), '[]'::jsonb)
                    from (select oi.item_name, sum(oi.quantity) as qty, sum(oi.line_total_minor) as total
                            from public.order_items oi
                            join public.orders o on o.id = oi.order_id
                           where o.branch_id = p_branch and o.status = 'closed'
                             and o.business_date between p_from and p_to and oi.prep_status <> 'cancelled'
                           group by oi.item_name order by 2 desc limit 6) t),
    'by_channel', (select coalesce(jsonb_agg(jsonb_build_object('channel', c.channel, 'total', c.total, 'count', c.n)), '[]'::jsonb)
                     from (select o.channel, sum(o.total_minor) as total, count(*) as n
                             from public.orders o
                            where o.branch_id = p_branch and o.status = 'closed' and o.business_date between p_from and p_to
                            group by o.channel) c),
    'recent', (select coalesce(jsonb_agg(r.x order by r.at desc), '[]'::jsonb) from (
                 select p.created_at as at, jsonb_build_object(
                          'at', p.created_at, 'order_number', o.number, 'customer', o.customer_name,
                          'channel', o.channel, 'amount', p.amount_minor,
                          'method', coalesce(pm.name, p.method), 'order_status', o.status) as x
                   from public.payments p
                   join public.orders o on o.id = p.order_id
                   left join public.payment_methods pm on pm.id = p.payment_method_id
                  where p.branch_id = p_branch and p.status = 'confirmed'
                    and o.business_date between p_from and p_to
                  order by p.created_at desc limit 10) r)
  );
end $$;

revoke all on function public.duplicate_menu_item(uuid, text), public.branch_dashboard(uuid, date, date),
  public.record_ad_event(uuid, text), public.public_ads(uuid, integer) from public, anon;
grant execute on function public.duplicate_menu_item(uuid, text), public.branch_dashboard(uuid, date, date)
  to authenticated;
grant execute on function public.record_ad_event(uuid, text), public.public_ads(uuid, integer) to anon, authenticated;

revoke all on all functions in schema app_private from public, anon, authenticated;
grant execute on function app_private.member_org_ids(), app_private.member_branch_ids(),
  app_private.org_ids_with(text), app_private.branch_ids_with(text),
  app_private.full_access_org_ids(), app_private.assigned_branch_ids(),
  app_private.org_ids_with_any_branch(text) to authenticated;
