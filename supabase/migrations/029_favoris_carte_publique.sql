-- =============================================================================
-- Resto — 029 : nombre de favoris de chaque plat sur la carte publique, pour
-- que la carte produit côté client montre les mêmes indicateurs que le module
-- Menus (étoiles, avis, favoris, ventes des 30 derniers jours).
-- À coller APRÈS 028, puis supabase/tests/029_favoris_carte_publique_tests.sql.
-- =============================================================================

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
                            'favorites', (select count(*) from public.customer_item_favorites f where f.item_id = mi.id),
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

revoke all on function public.public_branch_menu(uuid) from public;
grant execute on function public.public_branch_menu(uuid) to anon, authenticated;

revoke all on all functions in schema app_private from public, anon, authenticated;
grant execute on function app_private.member_org_ids(), app_private.member_branch_ids(),
  app_private.org_ids_with(text), app_private.branch_ids_with(text),
  app_private.full_access_org_ids(), app_private.assigned_branch_ids(),
  app_private.org_ids_with_any_branch(text) to authenticated;
