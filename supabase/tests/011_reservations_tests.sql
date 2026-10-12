-- =============================================================================
-- Resto — contrôles de la migration 011 (réservations).
-- À coller APRÈS 011. Transaction annulée à la fin : aucune donnée ne reste.
-- La dernière ligne « resultat » n'apparaît que si tout est passé.
-- =============================================================================
begin;

create schema zz_tests;
grant usage on schema zz_tests to anon, authenticated;

create function zz_tests.expect(p_ok boolean, p_label text) returns void language plpgsql as $$
begin
  if p_ok is distinct from true then raise exception 'ÉCHEC %', p_label; end if;
  raise notice 'OK %', p_label;
end $$;

create function zz_tests.expect_error(p_sql text, p_expected text, p_label text) returns void
language plpgsql as $$
begin
  begin
    execute p_sql;
  exception when others then
    if sqlerrm = p_expected or sqlstate = p_expected then
      raise notice 'OK %', p_label;
      return;
    end if;
    raise exception 'ÉCHEC % : erreur inattendue [%] %', p_label, sqlstate, sqlerrm;
  end;
  raise exception 'ÉCHEC % : aucune erreur', p_label;
end $$;

-- A = propriétaire, C = client, D = autre client, B = autre organisation
insert into auth.users (id, email, aud, role, raw_user_meta_data, email_confirmed_at) values
  ('00000000-0000-0000-0000-00000000a012', 'owner.a12@resto.test', 'authenticated', 'authenticated', '{}', now()),
  ('00000000-0000-0000-0000-00000000c012', 'client.c12@resto.test', 'authenticated', 'authenticated', '{}', now()),
  ('00000000-0000-0000-0000-00000000d012', 'client.d12@resto.test', 'authenticated', 'authenticated', '{}', now()),
  ('00000000-0000-0000-0000-00000000b012', 'owner.b12@resto.test', 'authenticated', 'authenticated', '{}', now());

set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000a012","role":"authenticated"}';
select set_config('t.a', public.create_organization('Résa A', 'CM', 'XAF', 'fr', 'Africa/Douala', 'Douala')::text, true);
select set_config('t.org', current_setting('t.a')::jsonb ->> 'organization_id', true);
select set_config('t.a1', current_setting('t.a')::jsonb ->> 'branch_id', true);
update public.branches set is_published = true, accepts_reservations = true, reservation_minutes = 120
 where id = current_setting('t.a1')::uuid;
with ins as (insert into public.service_areas (organization_id, branch_id, name)
  values (current_setting('t.org')::uuid, current_setting('t.a1')::uuid, 'Terrasse') returning id)
select set_config('t.area', (select id::text from ins), true);
with ins as (insert into public.dining_tables (organization_id, branch_id, service_area_id, label, seats)
  values (current_setting('t.org')::uuid, current_setting('t.a1')::uuid, current_setting('t.area')::uuid, 'T1', 4) returning id)
select set_config('t.t1', (select id::text from ins), true);
with ins as (insert into public.dining_tables (organization_id, branch_id, service_area_id, label, seats)
  values (current_setting('t.org')::uuid, current_setting('t.a1')::uuid, current_setting('t.area')::uuid, 'T2', 2) returning id)
select set_config('t.t2', (select id::text from ins), true);
select set_config('t.when', (date_trunc('hour', now()) + interval '1 day')::text, true);

-- ------------------------------------------------------------- client C
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000c012","role":"authenticated"}';
select set_config('t.r1', public.request_reservation(current_setting('t.a1')::uuid, current_setting('t.when')::timestamptz,
  4::smallint, 'Famille Ngo', '+237 677000000', 'anniversaire')::text, true);
select zz_tests.expect((select status from public.reservations where id = current_setting('t.r1')::uuid) = 'requested'
  and (select ends_at - starts_at from public.reservations where id = current_setting('t.r1')::uuid) = interval '120 minutes',
  '1 : demande de réservation enregistrée (durée de l''établissement)');
select zz_tests.expect_error(format($q$select public.request_reservation(%L, %L::timestamptz, 40::smallint, 'X', '+237 600000000')$q$,
  current_setting('t.a1'), current_setting('t.when')), 'resto.invalid_party_size', '2 : groupe trop grand refusé');
select zz_tests.expect_error(format($q$select public.request_reservation(%L, now() - interval '1 hour', 2::smallint, 'X', '+237 600000000')$q$,
  current_setting('t.a1')), 'resto.invalid_reservation_time', '3 : réservation dans le passé refusée');
select zz_tests.expect((select brand_name from public.my_reservations()) is not null, '4 : « Mes réservations » avec le restaurant');

-- ------------------------------------------------------------- restaurant A
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000a012","role":"authenticated"}';
select zz_tests.expect_error(format($q$select public.confirm_reservation(%L, array[%L]::uuid[])$q$,
  current_setting('t.r1'), current_setting('t.t2')), 'resto.not_enough_seats', '5 : table trop petite pour le groupe refusée');
select public.confirm_reservation(current_setting('t.r1')::uuid, array[current_setting('t.t1')::uuid]);
select zz_tests.expect((select status from public.reservations where id = current_setting('t.r1')::uuid) = 'confirmed',
  '6 : réservation confirmée avec la table T1');
select zz_tests.expect_error(format($q$select public.staff_create_reservation(%L, %L::timestamptz + interval '30 minutes', 60::smallint, 2::smallint, 'Client tél.', null, array[%L]::uuid[])$q$,
  current_setting('t.a1'), current_setting('t.when'), current_setting('t.t1')), 'resto.table_unavailable',
  '7 : jamais deux réservations sur la même table au même moment');
select zz_tests.expect(not exists (select 1 from public.available_tables(current_setting('t.a1')::uuid,
    current_setting('t.when')::timestamptz, current_setting('t.when')::timestamptz + interval '1 hour') where table_id = current_setting('t.t1')::uuid)
  and exists (select 1 from public.available_tables(current_setting('t.a1')::uuid,
    current_setting('t.when')::timestamptz, current_setting('t.when')::timestamptz + interval '1 hour') where table_id = current_setting('t.t2')::uuid),
  '8 : tables libres sur le créneau : T2 oui, T1 non');
select public.staff_create_reservation(current_setting('t.a1')::uuid, current_setting('t.when')::timestamptz + interval '120 minutes',
  60::smallint, 2::smallint, 'Juste après', null, array[current_setting('t.t1')::uuid]);
select zz_tests.expect(true, '9 : une réservation qui commence à la fin de la précédente est acceptée');
select zz_tests.expect_error(format($q$select public.set_reservation_status(%L, 'completed')$q$, current_setting('t.r1')),
  'resto.invalid_status', '10 : une réservation confirmée ne se termine pas sans arrivée');

-- ------------------------------------------------------------- client D
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000d012","role":"authenticated"}';
select zz_tests.expect((select count(*) from public.reservations) = 0, '11 : un client ne voit pas les réservations des autres');
select zz_tests.expect_error(format($q$select public.customer_cancel_reservation(%L)$q$, current_setting('t.r1')),
  '42501', '12 : ni ne les annule');

-- ------------------------------------------------------------- client C annule
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000c012","role":"authenticated"}';
select public.customer_cancel_reservation(current_setting('t.r1')::uuid);

set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000a012","role":"authenticated"}';
select set_config('t.r3', public.staff_create_reservation(current_setting('t.a1')::uuid, current_setting('t.when')::timestamptz,
  90::smallint, 3::smallint, 'Remplaçant', '+237 650000000', array[current_setting('t.t1')::uuid])::text, true);
select zz_tests.expect((select status from public.reservations where id = current_setting('t.r3')::uuid) = 'confirmed',
  '13 : réservation annulée par le client : la table est libérée');
select public.set_reservation_status(current_setting('t.r3')::uuid, 'seated');
select public.set_reservation_status(current_setting('t.r3')::uuid, 'completed');
select zz_tests.expect((select status from public.reservations where id = current_setting('t.r3')::uuid) = 'completed',
  '14 : arrivée puis départ enregistrés');
select zz_tests.expect_error(format($q$select public.set_reservation_status(%L, 'cancelled')$q$, current_setting('t.r3')),
  'resto.invalid_status', '15 : une réservation terminée ne s''annule plus');

-- ------------------------------------------------------------- autre organisation B
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000b012","role":"authenticated"}';
select public.create_organization('Résa B', 'CM', 'XAF', 'fr', 'Africa/Douala', 'Yaoundé');
select zz_tests.expect_error(format($q$select * from public.available_tables(%L, now(), now() + interval '1 hour')$q$, current_setting('t.a1')),
  '42501', '16 : B ne consulte pas les tables de A');
select zz_tests.expect_error(format($q$select public.set_reservation_status(%L, 'seated')$q$, current_setting('t.r3')),
  '42501', '17 : B ne touche pas aux réservations de A');

set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000a012","role":"authenticated"}';
update public.branches set accepts_reservations = false where id = current_setting('t.a1')::uuid;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000c012","role":"authenticated"}';
select zz_tests.expect_error(format($q$select public.request_reservation(%L, %L::timestamptz, 2::smallint, 'X', '+237 600000000')$q$,
  current_setting('t.a1'), current_setting('t.when')), 'resto.reservations_closed', '18 : réservations fermées : demande refusée');

reset role;
rollback;
select 'TOUS LES CONTRÔLES 011 SONT PASSÉS (18)' as resultat;
