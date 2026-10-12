-- =============================================================================
-- Resto — contrôles de la migration 033 (tables visibles par le client,
-- réservation en choisissant sa table).
-- À coller APRÈS 033. Transaction annulée à la fin.
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
grant execute on all functions in schema zz_tests to anon, authenticated;


insert into auth.users (id, email, aud, role, raw_user_meta_data, email_confirmed_at) values
  ('00000000-0000-0000-0000-00000000a032', 'owner.a32@resto.test', 'authenticated', 'authenticated', '{}', now()),
  ('00000000-0000-0000-0000-00000000c032', 'client.c32@resto.test', 'authenticated', 'authenticated', '{}', now()),
  ('00000000-0000-0000-0000-00000000d032', 'client.d32@resto.test', 'authenticated', 'authenticated', '{}', now());

set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000a032","role":"authenticated"}';
select set_config('t.a', public.create_organization('Tables 32', 'CM', 'XAF', 'fr', 'Africa/Douala', 'Tableville')::text, true);
select set_config('t.org', current_setting('t.a')::jsonb ->> 'organization_id', true);
select set_config('t.b', current_setting('t.a')::jsonb ->> 'branch_id', true);
update public.branches set is_published = true, accepts_reservations = true, reservation_minutes = 90
 where id = current_setting('t.b')::uuid;
with ins as (insert into public.service_areas (organization_id, branch_id, name)
  values (current_setting('t.org')::uuid, current_setting('t.b')::uuid, 'Salle principale') returning id)
select set_config('t.area', (select id::text from ins), true);
with ins as (insert into public.dining_tables (organization_id, branch_id, service_area_id, label, seats)
  values (current_setting('t.org')::uuid, current_setting('t.b')::uuid, current_setting('t.area')::uuid, 'T1', 4) returning id)
select set_config('t.t1', (select id::text from ins), true);
with ins as (insert into public.dining_tables (organization_id, branch_id, service_area_id, label, seats)
  values (current_setting('t.org')::uuid, current_setting('t.b')::uuid, current_setting('t.area')::uuid, 'T2', 2) returning id)
select set_config('t.t2', (select id::text from ins), true);
-- Des clients sont installés à la table T1 (commande sur place ouverte).
select public.open_order(current_setting('t.b')::uuid, 'dine_in', current_setting('t.t1')::uuid, 2::smallint);
select set_config('t.when', (date_trunc('hour', now()) + interval '1 day')::text, true);

-- ------------------------------------------------------------- visiteur : état des tables maintenant
set local role anon;
set local request.jwt.claims = '{"role":"anon"}';
select set_config('t.s', public.public_table_status(current_setting('t.b')::uuid)::text, true);
select zz_tests.expect((select x ->> 'status' from jsonb_array_elements(current_setting('t.s')::jsonb -> 'areas' -> 0 -> 'tables') x
                         where x ->> 'label' = 'T1') = 'occupied'
  and (select (x ->> 'free_at') is not null from jsonb_array_elements(current_setting('t.s')::jsonb -> 'areas' -> 0 -> 'tables') x
        where x ->> 'label' = 'T1'),
  '1 : table occupée avec l''heure estimée de libération');
select zz_tests.expect((select x ->> 'status' from jsonb_array_elements(current_setting('t.s')::jsonb -> 'areas' -> 0 -> 'tables') x
                         where x ->> 'label' = 'T2') = 'free',
  '2 : table libre');
select zz_tests.expect(current_setting('t.s') not like '%customer%' and current_setting('t.s') not like '%order%',
  '3 : aucune donnée personnelle ni commande exposée');
select zz_tests.expect((select x ->> 'status' from jsonb_array_elements(
    public.public_table_status(current_setting('t.b')::uuid, current_setting('t.when')::timestamptz) -> 'areas' -> 0 -> 'tables') x
   where x ->> 'label' = 'T1') = 'free',
  '4 : demain, la table occupée aujourd''hui est libre');
select zz_tests.expect_error(format($q$select public.request_reservation_tables(%L, %L::timestamptz, 2::smallint, 'X', '+237 600000000', array[%L]::uuid[])$q$,
  current_setting('t.b'), current_setting('t.when'), current_setting('t.t2')), '42501', '5 : il faut un compte pour réserver');

-- ------------------------------------------------------------- client C réserve la table T1 pour demain
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000c032","role":"authenticated"}';
select zz_tests.expect_error(format($q$select public.request_reservation_tables(%L, %L::timestamptz, 4::smallint, 'Famille Ndi', '+237 677000000', array[%L]::uuid[])$q$,
  current_setting('t.b'), current_setting('t.when'), current_setting('t.t2')), 'resto.not_enough_seats', '6 : table trop petite pour le groupe refusée');
select zz_tests.expect((select count(*) from public.reservations) = 0, '7 : rien n''est créé en cas de refus');
select set_config('t.r', public.request_reservation_tables(current_setting('t.b')::uuid, current_setting('t.when')::timestamptz,
  4::smallint, 'Famille Ndi', '+237 677000000', array[current_setting('t.t1')::uuid])::text, true);
select zz_tests.expect((select status = 'requested' and requested_table_ids = array[current_setting('t.t1')::uuid]
                          from public.reservations where id = current_setting('t.r')::uuid),
  '8 : demande enregistrée avec la table choisie');

-- ------------------------------------------------------------- client D voit la table réservée et ne peut pas la prendre
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000d032","role":"authenticated"}';
select zz_tests.expect((select x ->> 'status' from jsonb_array_elements(
    public.public_table_status(current_setting('t.b')::uuid, current_setting('t.when')::timestamptz + interval '30 minutes') -> 'areas' -> 0 -> 'tables') x
   where x ->> 'label' = 'T1') = 'reserved',
  '9 : la table choisie apparaît réservée sur le créneau');
select zz_tests.expect_error(format($q$select public.request_reservation_tables(%L, %L::timestamptz, 2::smallint, 'Paul', '+237 699000000', array[%L]::uuid[])$q$,
  current_setting('t.b'), current_setting('t.when'), current_setting('t.t1')), 'resto.table_unavailable', '10 : table déjà prise sur ce créneau');

-- ------------------------------------------------------------- le restaurant refuse : la table est libérée
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000a032","role":"authenticated"}';
select public.set_reservation_status(current_setting('t.r')::uuid, 'declined', 'Complet ce soir');
select zz_tests.expect((select x ->> 'status' from jsonb_array_elements(
    public.public_table_status(current_setting('t.b')::uuid, current_setting('t.when')::timestamptz) -> 'areas' -> 0 -> 'tables') x
   where x ->> 'label' = 'T1') = 'free',
  '11 : refus du restaurant, la table redevient libre');

reset role;
rollback;
select 'TOUS LES CONTRÔLES 033 SONT PASSÉS (11)' as resultat;
