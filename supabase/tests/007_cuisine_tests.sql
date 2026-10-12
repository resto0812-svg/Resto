-- =============================================================================
-- Resto — contrôles de la migration 007 (cuisine / KDS).
-- À coller APRÈS 007. Transaction annulée à la fin : aucune donnée ne reste.
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

-- A = propriétaire, K = cuisine (A1), W = serveur (A1), B = autre organisation
insert into auth.users (id, email, aud, role, raw_user_meta_data, email_confirmed_at) values
  ('00000000-0000-0000-0000-00000000a008', 'owner.a8@resto.test', 'authenticated', 'authenticated', '{}', now()),
  ('00000000-0000-0000-0000-00000000c008', 'kitchen.k8@resto.test', 'authenticated', 'authenticated', '{}', now()),
  ('00000000-0000-0000-0000-00000000d008', 'waiter.w8@resto.test', 'authenticated', 'authenticated', '{}', now()),
  ('00000000-0000-0000-0000-00000000b008', 'owner.b8@resto.test', 'authenticated', 'authenticated', '{}', now());

set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000a008","role":"authenticated"}';
select set_config('t.a', public.create_organization('KDS A', 'CM', 'XAF', 'fr', 'Africa/Douala', 'Douala', null, 'A1')::text, true);
select set_config('t.org', current_setting('t.a')::jsonb ->> 'organization_id', true);
select set_config('t.brand', current_setting('t.a')::jsonb ->> 'brand_id', true);
select set_config('t.a1', current_setting('t.a')::jsonb ->> 'branch_id', true);
select zz_tests.expect((select count(*) from public.prep_stations where branch_id = current_setting('t.a1')::uuid) = 2,
  '1 : postes « Cuisine » et « Bar » créés avec l''établissement');

with ins as (insert into public.menu_categories (organization_id, brand_id, name)
  values (current_setting('t.org')::uuid, current_setting('t.brand')::uuid, 'Carte') returning id)
select set_config('t.cat', (select id::text from ins), true);
select set_config('t.plat', public.create_menu_item(current_setting('t.cat')::uuid, 'Poisson braisé', null, 'food')::text, true);
select set_config('t.boisson', public.create_menu_item(current_setting('t.cat')::uuid, 'Jus de bissap', null, 'drink')::text, true);
select set_config('t.vplat', (select id::text from public.item_variants where item_id = current_setting('t.plat')::uuid), true);
select set_config('t.vboisson', (select id::text from public.item_variants where item_id = current_setting('t.boisson')::uuid), true);
insert into public.menu_item_branches (organization_id, brand_id, item_id, branch_id)
select current_setting('t.org')::uuid, current_setting('t.brand')::uuid, i, current_setting('t.a1')::uuid
  from unnest(array[current_setting('t.plat')::uuid, current_setting('t.boisson')::uuid]) i;
select public.set_price(current_setting('t.a1')::uuid, current_setting('t.vplat')::uuid, null, 'default', 6000);
select public.set_price(current_setting('t.a1')::uuid, current_setting('t.vboisson')::uuid, null, 'default', 1000);

reset role;
insert into public.memberships (organization_id, user_id, role_code, all_branches) values
  (current_setting('t.org')::uuid, '00000000-0000-0000-0000-00000000c008', 'kitchen', false),
  (current_setting('t.org')::uuid, '00000000-0000-0000-0000-00000000d008', 'waiter', false);
insert into public.membership_branches (organization_id, membership_id, branch_id)
select m.organization_id, m.id, current_setting('t.a1')::uuid from public.memberships m
 where m.user_id in ('00000000-0000-0000-0000-00000000c008', '00000000-0000-0000-0000-00000000d008');
set local role authenticated;

-- ------------------------------------------------------------- serveur W : commande et envoi
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000d008","role":"authenticated"}';
select set_config('t.o', public.open_order(current_setting('t.a1')::uuid, 'takeaway')::text, true);
select set_config('t.lplat', public.add_order_item(current_setting('t.o')::uuid, current_setting('t.vplat')::uuid, 1)::text, true);
select set_config('t.lboisson', public.add_order_item(current_setting('t.o')::uuid, current_setting('t.vboisson')::uuid, 2)::text, true);
select public.send_order(current_setting('t.o')::uuid);
select zz_tests.expect(
  (select s.name from public.order_items i join public.prep_stations s on s.id = i.station_id
    where i.id = current_setting('t.lplat')::uuid) = 'Cuisine'
  and (select s.name from public.order_items i join public.prep_stations s on s.id = i.station_id
    where i.id = current_setting('t.lboisson')::uuid) = 'Bar',
  '2 : à l''envoi, le plat part en Cuisine et la boisson au Bar');
select zz_tests.expect_error(format($q$select public.set_prep_status(array[%L]::uuid[], 'preparing')$q$, current_setting('t.lplat')),
  '42501', '3 : un serveur ne passe pas un plat « en préparation »');

-- ------------------------------------------------------------- cuisine K
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000c008","role":"authenticated"}';
select zz_tests.expect_error(format($q$select public.set_prep_status(array[%L]::uuid[], 'served')$q$, current_setting('t.lplat')),
  'resto.invalid_status', '4 : on ne sert pas un plat qui n''est pas prêt');
select public.set_prep_status(array[current_setting('t.lplat')::uuid], 'preparing');
select public.set_prep_status(array[current_setting('t.lplat')::uuid, current_setting('t.lboisson')::uuid], 'ready');
select zz_tests.expect((select count(*) from public.order_items where order_id = current_setting('t.o')::uuid
    and prep_status = 'ready' and ready_at is not null) = 2,
  '5 : la cuisine passe les lignes en préparation puis prêtes (heure notée)');
select zz_tests.expect_error($q$select public.set_prep_status(array[]::uuid[], 'ready')$q$,
  'resto.invalid_status', '6 : aucune ligne : refusé');
select zz_tests.expect_error(format($q$select public.set_prep_status(array[%L]::uuid[], 'cooking')$q$, current_setting('t.lplat')),
  'resto.invalid_status', '7 : statut inconnu refusé');

-- ------------------------------------------------------------- serveur W : service
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000d008","role":"authenticated"}';
select public.set_prep_status(array[current_setting('t.lplat')::uuid], 'served');
select zz_tests.expect((select prep_status from public.order_items where id = current_setting('t.lplat')::uuid) = 'served'
  and (select count(*) from public.order_events where order_id = current_setting('t.o')::uuid and event = 'prep_status') >= 4,
  '8 : le serveur marque « servi » ; chaque étape est historisée');

-- ------------------------------------------------------------- autre organisation B
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000b008","role":"authenticated"}';
select public.create_organization('KDS B', 'CM', 'XAF', 'fr', 'Africa/Douala', 'Yaoundé');
select zz_tests.expect((select count(*) from public.prep_stations
    where branch_id = current_setting('t.a1')::uuid) = 0, '9 : B ne voit pas les postes de A');
select zz_tests.expect_error(format($q$select public.set_prep_status(array[%L]::uuid[], 'served')$q$, current_setting('t.lboisson')),
  '42501', '10 : B ne touche pas aux préparations de A');

reset role;
rollback;
select 'TOUS LES CONTRÔLES 007 SONT PASSÉS (10)' as resultat;
