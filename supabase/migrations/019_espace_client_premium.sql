-- =============================================================================
-- Resto — 019_espace_client_premium
-- Espace client (« marketplace ») :
-- 1. Profil client : nom, téléphone, date d'anniversaire, allergies,
--    préférences (notifications, langue, mode de paiement préféré — jamais de
--    numéro de carte ni de compte).
-- 2. Vitrine publique enrichie : logo, slogan, photo de couverture, position,
--    temps de préparation, mode vacances ; carte avec galerie, vidéo, temps de
--    préparation et jours de vente.
-- 3. Catalogue global (plats des restaurants publiés) et villes desservies.
-- À coller APRÈS 018, puis supabase/tests/019_espace_client_premium_tests.sql.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. Profil client
-- -----------------------------------------------------------------------------
create table if not exists public.customer_profiles (
  user_id uuid primary key default auth.uid() references auth.users (id) on delete cascade,
  full_name text check (length(full_name) <= 120),
  phone text check (length(phone) <= 32),
  birthday date check (birthday is null or birthday between date '1900-01-01' and current_date),
  allergies text[] not null default '{}' check (cardinality(allergies) <= 20),
  spice_level smallint check (spice_level between 0 and 3),
  preferred_payment text check (preferred_payment in ('cash', 'card', 'mobile_wallet', 'transfer', 'other')),
  prefs jsonb not null default '{}'::jsonb check (jsonb_typeof(prefs) = 'object' and length(prefs::text) <= 2000),
  updated_at timestamptz not null default now()
);
alter table public.customer_profiles enable row level security;
grant select, insert (user_id, full_name, phone, birthday, allergies, spice_level, preferred_payment, prefs),
  update (user_id, full_name, phone, birthday, allergies, spice_level, preferred_payment, prefs)
  on public.customer_profiles to authenticated;
drop policy if exists customer_profiles_own on public.customer_profiles;
create policy customer_profiles_own on public.customer_profiles for all to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));

-- Les allergies sont choisies parmi les allergènes de référence.
create or replace function app_private.check_customer_profile()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  if exists (select 1 from unnest(new.allergies) a where not exists (select 1 from public.ref_allergens r where r.code = a)) then
    perform app_private.fail('resto.invalid_allergen');
  end if;
  new.updated_at := now();
  return new;
end $$;
drop trigger if exists customer_profiles_check on public.customer_profiles;
create trigger customer_profiles_check before insert or update on public.customer_profiles
  for each row execute function app_private.check_customer_profile();

-- -----------------------------------------------------------------------------
-- 2. Vitrine publique
-- -----------------------------------------------------------------------------

-- Établissements publiés, avec ce qu'il faut pour une carte de restaurant.
create or replace function public.public_branch_cards(
  p_query text default null, p_city text default null, p_limit integer default 60)
returns jsonb language sql stable security definer set search_path = '' as $$
  select coalesce(jsonb_agg(x order by (x ->> 'open_now')::boolean desc, x ->> 'brand_name'), '[]'::jsonb) from (
    select jsonb_build_object(
      'branch_id', b.id, 'branch_name', b.name, 'brand_name', br.name, 'slogan', br.slogan,
      'logo_path', br.logo_path, 'city', b.city, 'address_line1', b.address_line1,
      'cuisines', br.cuisines, 'price_level', br.price_level, 'currency', b.currency,
      'latitude', b.latitude, 'longitude', b.longitude, 'prep_minutes', b.target_prep_minutes,
      'accepts_online_orders', b.accepts_online_orders, 'accepts_delivery', b.accepts_delivery,
      'delivery_fee_minor', b.delivery_fee_minor, 'vacation_mode', b.vacation_mode,
      'open_now', app_private.is_open_now(b.id) and not b.vacation_mode,
      'rating', (select round(avg(r.rating), 1) from public.reviews r where r.branch_id = b.id and r.status = 'published'),
      'reviews_count', (select count(*) from public.reviews r where r.branch_id = b.id and r.status = 'published'),
      'cover_path', (select mi.image_path from public.menu_items mi
                       join public.menu_item_branches mib on mib.item_id = mi.id and mib.branch_id = b.id
                      where mi.active and mi.image_path is not null
                      order by mi.sort_order limit 1)) as x
      from public.branches b
      join public.brands br on br.id = b.brand_id and br.status = 'active'
      join public.organizations o on o.id = b.organization_id and o.status = 'active'
     where b.is_published and b.status = 'active'
       and (p_city is null or btrim(p_city) = '' or lower(b.city) = lower(btrim(p_city)))
       and (p_query is null or btrim(p_query) = ''
            or lower(br.name || ' ' || b.name || ' ' || b.city || ' ' || array_to_string(br.cuisines, ' '))
               like '%' || lower(btrim(p_query)) || '%'
            or exists (select 1 from public.menu_items mi join public.menu_item_branches mib on mib.item_id = mi.id
                        where mib.branch_id = b.id and mi.active and lower(mi.name) like '%' || lower(btrim(p_query)) || '%'))
     limit least(greatest(coalesce(p_limit, 60), 1), 100)
  ) s;
$$;

-- Villes où des restaurants sont publiés (sélecteur de ville).
create or replace function public.public_cities()
returns jsonb language sql stable security definer set search_path = '' as $$
  select coalesce(jsonb_agg(jsonb_build_object('city', c.city, 'count', c.n) order by c.n desc, c.city), '[]'::jsonb)
    from (select b.city, count(*) as n
            from public.branches b
            join public.organizations o on o.id = b.organization_id and o.status = 'active'
           where b.is_published and b.status = 'active'
           group by b.city) c;
$$;

-- Catalogue global : plats en vente dans les restaurants publiés (photo, prix).
create or replace function public.public_catalog(p_city text default null, p_query text default null, p_limit integer default 40)
returns jsonb language sql stable security definer set search_path = '' as $$
  select coalesce(jsonb_agg(x), '[]'::jsonb) from (
    select jsonb_build_object(
      'item_id', mi.id, 'name', mi.name, 'description', mi.description, 'kind', mi.kind,
      'image_path', mi.image_path, 'branch_id', b.id, 'brand_name', br.name, 'currency', b.currency,
      'price_minor', (select min(p.amount_minor) from public.prices p
                        join public.item_variants v on v.id = p.variant_id and v.active
                       where v.item_id = mi.id and p.branch_id = b.id and p.channel = 'default' and p.valid_to is null),
      'sold_out', not mib.available) as x
      from public.menu_items mi
      join public.menu_item_branches mib on mib.item_id = mi.id
      join public.branches b on b.id = mib.branch_id and b.is_published and b.status = 'active'
      join public.brands br on br.id = b.brand_id and br.status = 'active'
      join public.organizations o on o.id = b.organization_id and o.status = 'active'
     where mi.active
       and (p_city is null or btrim(p_city) = '' or lower(b.city) = lower(btrim(p_city)))
       and (p_query is null or btrim(p_query) = '' or lower(mi.name || ' ' || coalesce(mi.description, '')) like '%' || lower(btrim(p_query)) || '%')
       and exists (select 1 from public.prices p join public.item_variants v on v.id = p.variant_id and v.active
                    where v.item_id = mi.id and p.branch_id = b.id and p.valid_to is null)
     order by (mi.image_path is null), mib.available desc, mi.sort_order, mi.name
     limit least(greatest(coalesce(p_limit, 40), 1), 100)
  ) s;
$$;

-- Carte publique d'un établissement (même règles d'accès qu'en 010), enrichie.
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
      'address_line1', v_branch.address_line1, 'phone', v_branch.phone, 'whatsapp', v_branch.whatsapp,
      'currency', v_branch.currency, 'timezone', v_branch.timezone, 'default_locale', v_branch.default_locale,
      'latitude', v_branch.latitude, 'longitude', v_branch.longitude,
      'accepts_online_orders', v_branch.accepts_online_orders and not v_branch.vacation_mode,
      'accepts_delivery', v_branch.accepts_delivery, 'delivery_zone', v_branch.delivery_zone,
      'delivery_fee_minor', v_branch.delivery_fee_minor, 'min_order_minor', v_branch.min_order_minor,
      'prices_include_tax', v_branch.prices_include_tax, 'tax_rate', v_branch.tax_rate,
      'prep_minutes', v_branch.target_prep_minutes,
      'vacation_mode', v_branch.vacation_mode, 'vacation_message', v_branch.vacation_message,
      'open_now', app_private.is_open_now(v_branch.id) and not v_branch.vacation_mode,
      'languages', coalesce((select jsonb_agg(locale) from public.branch_languages where branch_id = v_branch.id), '[]'::jsonb)),
    'brand', (select jsonb_build_object('name', br.name, 'slug', br.slug, 'slogan', br.slogan, 'logo_path', br.logo_path,
                'description', br.description, 'cuisines', br.cuisines, 'price_level', br.price_level)
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
                          'image_path', mi.image_path, 'gallery_paths', to_jsonb(mi.gallery_paths), 'video_path', mi.video_path,
                          'prep_minutes', mi.prep_minutes, 'available_days', to_jsonb(mi.available_days),
                          'sold_out', not mib.available,
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

-- Mode vacances : aucune nouvelle commande de client (QR ou application).
create or replace function app_private.block_orders_on_vacation()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  if new.customer_user_id is not null and new.source in ('qr', 'app', 'web')
     and exists (select 1 from public.branches b where b.id = new.branch_id and b.vacation_mode) then
    perform app_private.fail('resto.online_orders_closed');
  end if;
  return new;
end $$;
drop trigger if exists orders_vacation on public.orders;
create trigger orders_vacation before insert on public.orders
  for each row execute function app_private.block_orders_on_vacation();

-- Logos lisibles par tous (bucket public) : rien à ajouter. Les photos et
-- vidéos des articles le sont aussi (buckets publics « menu-images », « menu-videos »).

revoke all on function public.public_branch_cards(text, text, integer), public.public_cities(),
  public.public_catalog(text, text, integer), public.public_branch_menu(uuid) from public;
grant execute on function public.public_branch_cards(text, text, integer), public.public_cities(),
  public.public_catalog(text, text, integer), public.public_branch_menu(uuid) to anon, authenticated;

revoke all on all functions in schema app_private from public, anon, authenticated;
grant execute on function app_private.member_org_ids(), app_private.member_branch_ids(),
  app_private.org_ids_with(text), app_private.branch_ids_with(text),
  app_private.full_access_org_ids(), app_private.assigned_branch_ids(),
  app_private.org_ids_with_any_branch(text) to authenticated;
