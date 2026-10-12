-- =============================================================================
-- Resto — 033_tables_client
-- Le client voit les tables d'un restaurant publié et réserve en choisissant
-- sa table :
--   1. état de chaque table à un moment donné (maintenant ou plus tard) :
--      libre, occupée (avec l'heure estimée de libération) ou réservée (avec
--      le créneau) ; aucune donnée personnelle (ni nom, ni commande) ;
--   2. demande de réservation avec les tables choisies : elles sont bloquées
--      dès la demande (personne d'autre ne peut les prendre sur ce créneau) ;
--      le restaurant confirme (il peut changer de table), refuse ou annule,
--      ce qui les libère (fonctions de 011).
-- À coller APRÈS 032, puis supabase/tests/033_tables_client_tests.sql.
-- =============================================================================

alter table public.reservations
  add column if not exists requested_table_ids uuid[] not null default '{}'
    check (cardinality(requested_table_ids) <= 6);

-- -----------------------------------------------------------------------------
-- 1. État des tables pour le public
-- -----------------------------------------------------------------------------
-- Occupée : une commande sur place est ouverte sur la table ; libération
-- estimée = ouverture de la commande + durée d'un repas (réglage de
-- l'établissement), au plus tôt dans 5 minutes. Réservée : une réservation
-- confirmée ou demandée chevauche le créneau [p_at, p_at + durée d'un repas).
create or replace function public.public_table_status(p_branch uuid, p_at timestamptz default null)
returns jsonb language plpgsql stable security definer set search_path = '' as $$
declare
  v_branch public.branches;
  v_at timestamptz := coalesce(p_at, now());
  v_end timestamptz;
  v_live boolean;
begin
  select * into v_branch from public.branches where id = p_branch and is_published and status = 'active';
  if v_branch.id is null then perform app_private.fail('resto.not_found'); end if;
  if v_at < now() - interval '5 minutes' or v_at > now() + interval '90 days' then
    perform app_private.fail('resto.invalid_reservation_time');
  end if;
  v_end := v_at + make_interval(mins => v_branch.reservation_minutes);
  -- Les commandes en cours ne comptent que pour les prochaines heures.
  v_live := v_at < now() + make_interval(mins => v_branch.reservation_minutes * 2);
  return jsonb_build_object(
    'at', v_at,
    'reservation_minutes', v_branch.reservation_minutes,
    'accepts_reservations', v_branch.accepts_reservations,
    'max_party_size', v_branch.max_party_size,
    'areas', coalesce((
      select jsonb_agg(jsonb_build_object('id', a.id, 'name', a.name, 'tables', a.tables) order by a.sort_order, a.name)
        from (
          select sa.id, sa.name, sa.sort_order,
                 jsonb_agg(jsonb_build_object(
                   'id', t.id, 'label', t.label, 'seats', t.seats, 'shape', t.shape, 'pos_x', t.pos_x, 'pos_y', t.pos_y,
                   'status', case when r.reserved_from is not null then 'reserved'
                                  when o.free_at is not null and o.free_at > v_at then 'occupied'
                                  else 'free' end,
                   'reserved_from', r.reserved_from, 'reserved_until', r.reserved_until,
                   'free_at', case when r.reserved_from is null and o.free_at > v_at then o.free_at end,
                   'next_reserved_at', (select min(lower(rt.period)) from public.reservation_tables rt
                                         where rt.table_id = t.id and rt.active and lower(rt.period) >= v_end)
                 ) order by t.label) as tables
            from public.service_areas sa
            join public.dining_tables t on t.service_area_id = sa.id and t.active
            left join lateral (
              select min(lower(rt.period)) as reserved_from, max(upper(rt.period)) as reserved_until
                from public.reservation_tables rt
               where rt.table_id = t.id and rt.active and rt.period && tstzrange(v_at, v_end, '[)')
            ) r on true
            left join lateral (
              select case when min(od.opened_at) is null then null
                          else greatest(min(od.opened_at) + make_interval(mins => v_branch.reservation_minutes), now() + interval '5 minutes') end as free_at
                from public.orders od
               where v_live and od.table_id = t.id and od.status = 'open'
            ) o on true
           where sa.branch_id = p_branch and sa.active
           group by sa.id, sa.name, sa.sort_order
        ) a), '[]'::jsonb));
end $$;

-- -----------------------------------------------------------------------------
-- 2. Réservation avec les tables choisies
-- -----------------------------------------------------------------------------
-- Mêmes contrôles que request_reservation (011) ; les tables doivent être
-- actives, de l'établissement, assez grandes pour le groupe et libres sur le
-- créneau, sinon rien n'est créé.
create or replace function public.request_reservation_tables(
  p_branch uuid, p_starts_at timestamptz, p_party_size smallint, p_name text, p_phone text, p_tables uuid[],
  p_note text default null, p_client_id uuid default null)
returns uuid language plpgsql security definer set search_path = '' as $$
declare
  v_id uuid;
  v_res public.reservations;
begin
  if coalesce(cardinality(p_tables), 0) not between 1 and 6 then perform app_private.fail('resto.tables_required'); end if;
  v_id := public.request_reservation(p_branch, p_starts_at, p_party_size, p_name, p_phone, p_note, p_client_id);
  select * into v_res from public.reservations where id = v_id;
  if v_res.status <> 'requested' then return v_id; end if;
  perform app_private.assign_tables(v_res, p_tables);
  update public.reservations
     set requested_table_ids = (select array_agg(distinct x) from unnest(p_tables) x)
   where id = v_id;
  return v_id;
end $$;

revoke all on function public.public_table_status(uuid, timestamptz) from public;
grant execute on function public.public_table_status(uuid, timestamptz) to anon, authenticated;
revoke all on function public.request_reservation_tables(uuid, timestamptz, smallint, text, text, uuid[], text, uuid) from public, anon;
grant execute on function public.request_reservation_tables(uuid, timestamptz, smallint, text, text, uuid[], text, uuid) to authenticated;

revoke all on all functions in schema app_private from public, anon, authenticated;
grant execute on function app_private.member_org_ids(), app_private.member_branch_ids(),
  app_private.org_ids_with(text), app_private.branch_ids_with(text),
  app_private.full_access_org_ids(), app_private.assigned_branch_ids(),
  app_private.org_ids_with_any_branch(text) to authenticated;
