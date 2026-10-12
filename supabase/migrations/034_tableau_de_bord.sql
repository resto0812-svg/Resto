-- =============================================================================
-- Resto — 034_tableau_de_bord
-- Indicateurs détaillés du tableau de bord d'un établissement sur une période
-- (droit « finance.read ») :
--   * commandes par jour, couverts, panier par couvert ;
--   * encaissements par moyen de paiement ;
--   * annulations (commandes et articles envoyés) et leurs motifs ;
--   * tous les plats vendus (quantités, chiffre d'affaires) pour l'ingénierie
--     de menu et les plats qui se vendent peu ;
--   * équipe : commandes, ventes et pourboires par membre ;
--   * temps de préparation, de service et d'occupation des tables ;
--   * affluence par jour de la semaine et par heure.
-- À coller APRÈS 033, puis supabase/tests/034_tableau_de_bord_tests.sql.
-- =============================================================================

create or replace function public.branch_insights(p_branch uuid, p_from date, p_to date)
returns jsonb language plpgsql stable security definer set search_path = '' as $$
declare v_tz text;
begin
  perform app_private.assert_branch_perm(p_branch, 'finance.read');
  if p_from is null or p_to is null or p_to < p_from or p_to - p_from > 400 then
    perform app_private.fail('resto.invalid_period');
  end if;
  select timezone into v_tz from public.branches where id = p_branch;
  return jsonb_build_object(
    'orders_by_day', coalesce((
      select jsonb_agg(jsonb_build_object('day', d.day, 'count', d.n, 'total', d.total) order by d.day)
        from (select o.business_date as day, count(*) as n, sum(o.total_minor) as total
                from public.orders o
               where o.branch_id = p_branch and o.status = 'closed' and o.business_date between p_from and p_to
               group by o.business_date) d), '[]'::jsonb),
    'covers', (select coalesce(sum(o.guests), 0) from public.orders o
                where o.branch_id = p_branch and o.status = 'closed' and o.channel = 'dine_in'
                  and o.business_date between p_from and p_to),
    'dine_in_sales', (select coalesce(sum(o.total_minor), 0) from public.orders o
                       where o.branch_id = p_branch and o.status = 'closed' and o.channel = 'dine_in' and o.guests is not null
                         and o.business_date between p_from and p_to),
    'payments_by_method', coalesce((
      select jsonb_agg(jsonb_build_object('name', m.name, 'kind', m.kind, 'total', m.total, 'count', m.n, 'tips', m.tips)
                       order by m.total desc)
        from (select coalesce(pm.name, p.method) as name, p.method as kind, sum(p.amount_minor) as total, count(*) as n,
                     sum(p.tip_minor) as tips
                from public.payments p
                join public.orders o on o.id = p.order_id
                left join public.payment_methods pm on pm.id = p.payment_method_id
               where p.branch_id = p_branch and p.status = 'confirmed' and o.business_date between p_from and p_to
               group by coalesce(pm.name, p.method), p.method) m), '[]'::jsonb),
    'cancellations', jsonb_build_object(
      'orders', (select count(*) from public.orders o
                  where o.branch_id = p_branch and o.status = 'cancelled' and o.business_date between p_from and p_to),
      'orders_amount', (select coalesce(sum(o.total_minor), 0) from public.orders o
                         where o.branch_id = p_branch and o.status = 'cancelled' and o.business_date between p_from and p_to),
      'items', (select count(*) from public.order_items oi join public.orders o on o.id = oi.order_id
                 where o.branch_id = p_branch and oi.prep_status = 'cancelled' and oi.sent_at is not null
                   and o.business_date between p_from and p_to),
      'items_amount', (select coalesce(sum(oi.line_total_minor), 0) from public.order_items oi join public.orders o on o.id = oi.order_id
                        where o.branch_id = p_branch and oi.prep_status = 'cancelled' and oi.sent_at is not null
                          and o.business_date between p_from and p_to),
      'reasons', coalesce((
        select jsonb_agg(jsonb_build_object('reason', r.reason, 'count', r.n) order by r.n desc)
          from (select left(btrim(x.reason), 80) as reason, count(*) as n
                  from (select o.cancel_reason as reason from public.orders o
                         where o.branch_id = p_branch and o.status = 'cancelled' and o.business_date between p_from and p_to
                        union all
                        select oi.cancel_reason from public.order_items oi join public.orders o on o.id = oi.order_id
                         where o.branch_id = p_branch and oi.prep_status = 'cancelled' and oi.sent_at is not null
                           and o.business_date between p_from and p_to) x
                 where length(btrim(coalesce(x.reason, ''))) > 0
                 group by left(btrim(x.reason), 80)
                 order by count(*) desc limit 6) r), '[]'::jsonb)),
    'items', coalesce((
      select jsonb_agg(jsonb_build_object('item_id', i.item_id, 'name', i.name, 'quantity', i.qty, 'total', i.total)
                       order by i.qty desc)
        from (select oi.item_id, max(oi.item_name) as name, sum(oi.quantity) as qty, sum(oi.line_total_minor) as total
                from public.order_items oi join public.orders o on o.id = oi.order_id
               where o.branch_id = p_branch and o.status = 'closed' and oi.prep_status <> 'cancelled'
                 and o.business_date between p_from and p_to
               group by oi.item_id
               order by sum(oi.quantity) desc limit 300) i), '[]'::jsonb),
    'staff', coalesce((
      select jsonb_agg(jsonb_build_object('name', s.name, 'orders', s.n, 'sales', s.sales, 'tips', s.tips) order by s.sales desc)
        from (select coalesce(nullif(btrim(pr.display_name), ''), '—') as name, count(*) as n, sum(o.total_minor) as sales,
                     coalesce((select sum(p.tip_minor) from public.payments p
                                join public.orders o2 on o2.id = p.order_id
                               where p.branch_id = p_branch and p.status = 'confirmed' and p.created_by = o.opened_by
                                 and o2.business_date between p_from and p_to), 0) as tips
                from public.orders o
                left join public.profiles pr on pr.id = o.opened_by
               where o.branch_id = p_branch and o.status = 'closed' and o.opened_by is not null
                 and o.business_date between p_from and p_to
               group by o.opened_by, pr.display_name
               order by sum(o.total_minor) desc limit 20) s), '[]'::jsonb),
    'service', jsonb_build_object(
      'prep_minutes', (select round(avg(extract(epoch from (oi.ready_at - oi.sent_at)) / 60)::numeric, 1)
                         from public.order_items oi join public.orders o on o.id = oi.order_id
                        where o.branch_id = p_branch and oi.ready_at is not null and oi.sent_at is not null
                          and oi.ready_at > oi.sent_at and o.business_date between p_from and p_to),
      'serve_minutes', (select round(avg(extract(epoch from (oi.served_at - oi.ready_at)) / 60)::numeric, 1)
                          from public.order_items oi join public.orders o on o.id = oi.order_id
                         where o.branch_id = p_branch and oi.served_at is not null and oi.ready_at is not null
                           and oi.served_at > oi.ready_at and o.business_date between p_from and p_to),
      'table_minutes', (select round(avg(extract(epoch from (o.closed_at - o.opened_at)) / 60)::numeric, 0)
                          from public.orders o
                         where o.branch_id = p_branch and o.status = 'closed' and o.channel = 'dine_in'
                           and o.closed_at is not null and o.business_date between p_from and p_to)),
    'heatmap', coalesce((
      select jsonb_agg(jsonb_build_object('dow', h.dow, 'hour', h.hour, 'count', h.n))
        from (select extract(isodow from o.opened_at at time zone v_tz)::int as dow,
                     extract(hour from o.opened_at at time zone v_tz)::int as hour, count(*) as n
                from public.orders o
               where o.branch_id = p_branch and o.status = 'closed' and o.business_date between p_from and p_to
               group by 1, 2) h), '[]'::jsonb)
  );
end $$;

revoke all on function public.branch_insights(uuid, date, date) from public, anon;
grant execute on function public.branch_insights(uuid, date, date) to authenticated;

revoke all on all functions in schema app_private from public, anon, authenticated;
grant execute on function app_private.member_org_ids(), app_private.member_branch_ids(),
  app_private.org_ids_with(text), app_private.branch_ids_with(text),
  app_private.full_access_org_ids(), app_private.assigned_branch_ids(),
  app_private.org_ids_with_any_branch(text) to authenticated;
