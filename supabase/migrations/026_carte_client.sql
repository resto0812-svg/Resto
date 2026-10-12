-- =============================================================================
-- Resto — 026_carte_client
-- Page restaurant côté client (maquette « DELICES ») :
--   1. photo d'ambiance de l'établissement (bandeau de la page) ;
--   2. étiquettes libres de chaque plat ou boisson, créées par le restaurant
--      (« Piment doux », « Halal », « Sans alcool », « Fait maison »…) : elles
--      deviennent les filtres de sa carte côté client ;
--   3. ventes des 30 derniers jours, « Best-seller » (3 plats les plus vendus),
--      note des avis vérifiés du plat.
-- À coller APRÈS 025, puis supabase/tests/026_carte_client_tests.sql.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. Photo d'ambiance (bucket « menu-images », dossier de l'organisation)
-- -----------------------------------------------------------------------------
alter table public.branches add column if not exists cover_path text check (cover_path is null or length(cover_path) <= 300);
grant insert (cover_path), update (cover_path) on public.branches to authenticated;

create or replace function app_private.check_branch_cover()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  if new.cover_path is not null and new.cover_path not like new.organization_id::text || '/%' then
    perform app_private.fail('resto.invalid_image');
  end if;
  return new;
end $$;
drop trigger if exists branches_check_cover on public.branches;
create trigger branches_check_cover before insert or update of cover_path on public.branches
  for each row execute function app_private.check_branch_cover();

-- -----------------------------------------------------------------------------
-- 2. Étiquettes des plats et boissons (libres, choisies par le restaurant)
-- -----------------------------------------------------------------------------
alter table public.menu_items
  add column if not exists tags text[] not null default '{}' check (cardinality(tags) <= 10);
grant insert (tags), update (tags) on public.menu_items to authenticated;

-- Étiquettes propres : 1 à 30 caractères, sans doublon (casse ignorée), espaces superflus retirés.
create or replace function app_private.clean_item_tags()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  new.tags := coalesce((select array_agg(x order by ord) from (
                 select distinct on (lower(btrim(t))) btrim(regexp_replace(t, '\s+', ' ', 'g')) as x, ord
                   from unnest(new.tags) with ordinality as u(t, ord)
                  where t is not null and btrim(t) <> ''
                  order by lower(btrim(t)), ord) s), '{}');
  if exists (select 1 from unnest(new.tags) t where length(t) > 30) then perform app_private.fail('resto.invalid_tag'); end if;
  return new;
end $$;
drop trigger if exists menu_items_clean_tags on public.menu_items;
create trigger menu_items_clean_tags before insert or update of tags on public.menu_items
  for each row execute function app_private.clean_item_tags();

-- -----------------------------------------------------------------------------
-- 3. Carte publique enrichie
-- -----------------------------------------------------------------------------
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
  return (
    with sales as (
      select oi.item_id, sum(oi.quantity)::int as sold
        from public.order_items oi
        join public.orders o on o.id = oi.order_id
       where o.branch_id = v_branch.id and o.status = 'closed' and oi.prep_status <> 'cancelled'
         and o.closed_at > now() - interval '30 days'
       group by oi.item_id
    ), best as (
      select item_id from sales order by sold desc limit 3
    )
    select jsonb_build_object(
      'branch', jsonb_build_object('id', v_branch.id, 'name', v_branch.name, 'city', v_branch.city,
        'address_line1', v_branch.address_line1, 'phone', v_branch.phone, 'whatsapp', v_branch.whatsapp,
        'currency', v_branch.currency, 'timezone', v_branch.timezone, 'default_locale', v_branch.default_locale,
        'latitude', v_branch.latitude, 'longitude', v_branch.longitude, 'cover_path', v_branch.cover_path,
        'accepts_online_orders', v_branch.accepts_online_orders and not v_branch.vacation_mode,
        'accepts_delivery', v_branch.accepts_delivery, 'delivery_zone', v_branch.delivery_zone,
        'delivery_fee_minor', v_branch.delivery_fee_minor, 'min_order_minor', v_branch.min_order_minor,
        'accepts_reservations', v_branch.accepts_reservations,
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
                            'tags', to_jsonb(mi.tags),
                            'sold_30d', coalesce((select s.sold from sales s where s.item_id = mi.id), 0),
                            'best_seller', exists (select 1 from best where best.item_id = mi.id),
                            'rating', (select round(avg(r.rating), 1) from public.item_reviews r
                                        where r.item_id = mi.id and r.branch_id = v_branch.id and r.status = 'published'),
                            'reviews_count', (select count(*) from public.item_reviews r
                                               where r.item_id = mi.id and r.branch_id = v_branch.id and r.status = 'published'),
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
                        where mi.category_id = c.id and mi.active)), '[]'::jsonb)));
end $$;

-- Cartes de la vitrine : la photo d'ambiance passe avant la photo d'un plat.
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
      'cover_path', coalesce(b.cover_path, (select mi.image_path from public.menu_items mi
                       join public.menu_item_branches mib on mib.item_id = mi.id and mib.branch_id = b.id
                      where mi.active and mi.image_path is not null
                      order by mi.sort_order limit 1))) as x
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

-- Indicateurs de chaque plat pour l'équipe (module Menus) : note et nombre
-- d'avis vérifiés, clients qui l'ont en favori, ventes des 30 derniers jours.
create or replace function public.menu_item_stats(p_branch uuid)
returns jsonb language plpgsql stable security definer set search_path = '' as $$
begin
  if not exists (select 1 from app_private.member_branch_ids() x where x = p_branch) then
    raise exception 'resto.forbidden' using errcode = '42501';
  end if;
  return coalesce((
    select jsonb_object_agg(mib.item_id, jsonb_build_object(
             'rating', (select round(avg(r.rating), 1) from public.item_reviews r
                         where r.item_id = mib.item_id and r.branch_id = p_branch and r.status = 'published'),
             'reviews', (select count(*) from public.item_reviews r
                          where r.item_id = mib.item_id and r.branch_id = p_branch and r.status = 'published'),
             'favorites', (select count(*) from public.customer_item_favorites f where f.item_id = mib.item_id),
             'sold_30d', (select coalesce(sum(oi.quantity), 0) from public.order_items oi
                            join public.orders o on o.id = oi.order_id
                           where oi.item_id = mib.item_id and o.branch_id = p_branch and o.status = 'closed'
                             and oi.prep_status <> 'cancelled' and o.closed_at > now() - interval '30 days')))
      from public.menu_item_branches mib where mib.branch_id = p_branch), '{}'::jsonb);
end $$;

revoke all on function public.public_branch_menu(uuid), public.public_branch_cards(text, text, integer) from public;
grant execute on function public.public_branch_menu(uuid), public.public_branch_cards(text, text, integer) to anon, authenticated;
revoke all on function public.menu_item_stats(uuid) from public, anon;
grant execute on function public.menu_item_stats(uuid) to authenticated;

revoke all on all functions in schema app_private from public, anon, authenticated;
grant execute on function app_private.member_org_ids(), app_private.member_branch_ids(),
  app_private.org_ids_with(text), app_private.branch_ids_with(text),
  app_private.full_access_org_ids(), app_private.assigned_branch_ids(),
  app_private.org_ids_with_any_branch(text) to authenticated;
