-- =============================================================================
-- Resto — contrôles de la migration 013 (service : commandes, salle, cuisine).
-- À coller APRÈS 013. Transaction annulée à la fin : aucune donnée ne reste.
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

-- A = propriétaire, W = serveur, K = cuisine, C = client, B = autre organisation
insert into auth.users (id, email, aud, role, raw_user_meta_data, email_confirmed_at) values
  ('00000000-0000-0000-0000-00000000a013', 'owner.a13@resto.test', 'authenticated', 'authenticated', '{}', now()),
  ('00000000-0000-0000-0000-00000000d013', 'waiter.w13@resto.test', 'authenticated', 'authenticated', '{}', now()),
  ('00000000-0000-0000-0000-00000000e013', 'kitchen.k13@resto.test', 'authenticated', 'authenticated', '{}', now()),
  ('00000000-0000-0000-0000-00000000c013', 'client.c13@resto.test', 'authenticated', 'authenticated', '{}', now()),
  ('00000000-0000-0000-0000-00000000b013', 'owner.b13@resto.test', 'authenticated', 'authenticated', '{}', now());

set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000a013","role":"authenticated"}';
select set_config('t.a', public.create_organization('Service A', 'CM', 'XAF', 'fr', 'Africa/Douala', 'Douala', null, 'A1')::text, true);
select set_config('t.org', current_setting('t.a')::jsonb ->> 'organization_id', true);
select set_config('t.brand', current_setting('t.a')::jsonb ->> 'brand_id', true);
select set_config('t.a1', current_setting('t.a')::jsonb ->> 'branch_id', true);
update public.branches set is_published = true, accepts_online_orders = true, accepts_delivery = true,
       delivery_fee_minor = 700, target_prep_minutes = 20
 where id = current_setting('t.a1')::uuid;

with ins as (insert into public.menu_categories (organization_id, brand_id, name)
  values (current_setting('t.org')::uuid, current_setting('t.brand')::uuid, 'Carte') returning id)
select set_config('t.cat', (select id::text from ins), true);
select set_config('t.plat', public.create_menu_item(current_setting('t.cat')::uuid, 'Ndolé', null, 'food')::text, true);
select set_config('t.dessert', public.create_menu_item(current_setting('t.cat')::uuid, 'Beignets', null, 'food')::text, true);
select set_config('t.vplat', (select id::text from public.item_variants where item_id = current_setting('t.plat')::uuid), true);
select set_config('t.vdessert', (select id::text from public.item_variants where item_id = current_setting('t.dessert')::uuid), true);
insert into public.menu_item_branches (organization_id, brand_id, item_id, branch_id)
select current_setting('t.org')::uuid, current_setting('t.brand')::uuid, i, current_setting('t.a1')::uuid
  from unnest(array[current_setting('t.plat')::uuid, current_setting('t.dessert')::uuid]) i;
select public.set_price(current_setting('t.a1')::uuid, current_setting('t.vplat')::uuid, null, 'default', 4000);
select public.set_price(current_setting('t.a1')::uuid, current_setting('t.vdessert')::uuid, null, 'default', 1000);

with ins as (insert into public.service_areas (organization_id, branch_id, name)
  values (current_setting('t.org')::uuid, current_setting('t.a1')::uuid, 'Salle') returning id)
select set_config('t.area', (select id::text from ins), true);
with ins as (insert into public.dining_tables (organization_id, branch_id, service_area_id, label, seats, shape, pos_x, pos_y)
  values (current_setting('t.org')::uuid, current_setting('t.a1')::uuid, current_setting('t.area')::uuid, 'Table 1', 4, 'round', 2, 3)
  returning id)
select set_config('t.t1', (select id::text from ins), true);
with ins as (insert into public.dining_tables (organization_id, branch_id, service_area_id, label, seats)
  values (current_setting('t.org')::uuid, current_setting('t.a1')::uuid, current_setting('t.area')::uuid, 'VIP 1', 6) returning id)
select set_config('t.vip', (select id::text from ins), true);
with ins as (insert into public.dining_tables (organization_id, branch_id, service_area_id, label, seats)
  values (current_setting('t.org')::uuid, current_setting('t.a1')::uuid, current_setting('t.area')::uuid, 'Table 2', 2) returning id)
select set_config('t.t2', (select id::text from ins), true);
select zz_tests.expect((select shape = 'round' and pos_x = 2 and pos_y = 3 from public.dining_tables where id = current_setting('t.t1')::uuid),
  '1 : une table a une forme et une position sur le plan de salle');

reset role;
insert into public.memberships (organization_id, user_id, role_code, all_branches) values
  (current_setting('t.org')::uuid, '00000000-0000-0000-0000-00000000d013', 'waiter', false),
  (current_setting('t.org')::uuid, '00000000-0000-0000-0000-00000000e013', 'kitchen', false);
insert into public.membership_branches (organization_id, membership_id, branch_id)
select m.organization_id, m.id, current_setting('t.a1')::uuid from public.memberships m
 where m.user_id in ('00000000-0000-0000-0000-00000000d013', '00000000-0000-0000-0000-00000000e013');
set local role authenticated;

-- ------------------------------------------------------------- serveur W
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000d013","role":"authenticated"}';
with u as (update public.dining_tables set pos_x = 9 where id = current_setting('t.t1')::uuid returning 1)
select zz_tests.expect(count(*) = 0, '2 : un serveur ne modifie pas le plan de salle') from u;

select set_config('t.c1', gen_random_uuid()::text, true);
select public.create_order(current_setting('t.a1')::uuid, 'takeaway', null, null, 'phone', 'Paul', '+237 699000000',
  null, null, now() + interval '2 hours', 'sans piment', current_setting('t.c1')::uuid);
select zz_tests.expect((select source = 'phone' and customer_name = 'Paul' and contact_phone = '+237 699000000'
    and scheduled_for is not null and note = 'sans piment' and delivery_fee_minor = 0
    from public.orders where id = current_setting('t.c1')::uuid),
  '3 : commande par téléphone, à emporter, avec nom, téléphone, heure souhaitée et note');
select public.create_order(current_setting('t.a1')::uuid, 'takeaway', null, null, 'phone', 'Autre', null,
  null, null, null, null, current_setting('t.c1')::uuid);
select zz_tests.expect((select customer_name from public.orders where id = current_setting('t.c1')::uuid) = 'Paul'
  and (select count(*) from public.orders where branch_id = current_setting('t.a1')::uuid) = 1,
  '4 : appel rejoué : aucune deuxième commande, rien n''est écrasé');
select zz_tests.expect_error(format($q$select public.create_order(%L, 'delivery', null, null, 'phone', 'Awa')$q$, current_setting('t.a1')),
  'resto.address_required', '5 : livraison sans adresse refusée');
select zz_tests.expect_error(format($q$select public.create_order(%L, 'takeaway', null, null, 'app')$q$, current_setting('t.a1')),
  'resto.invalid_order', '6 : l''équipe ne se fait pas passer pour l''application client');

select set_config('t.liv', public.create_order(current_setting('t.a1')::uuid, 'delivery', null, null, 'phone', 'Awa',
  '+237 677000000', 'Bonamoussadi, carrefour Kotto', 'immeuble jaune')::text, true);
select public.add_order_item(current_setting('t.liv')::uuid, current_setting('t.vplat')::uuid, 1);
select zz_tests.expect((select delivery_fee_minor = 700 and total_minor = 4700 from public.orders where id = current_setting('t.liv')::uuid),
  '7 : livraison : frais de l''établissement ajoutés au total');
select public.update_order_details(current_setting('t.liv')::uuid, null, 'Awa N.', '+237 677000000',
  'Bonamoussadi, carrefour Kotto', 'immeuble jaune, 2e étage', null, null, 500);
select zz_tests.expect((select customer_name = 'Awa N.' and delivery_fee_minor = 500 and total_minor = 4500
    from public.orders where id = current_setting('t.liv')::uuid)
  and exists (select 1 from public.order_events where order_id = current_setting('t.liv')::uuid and event = 'details_updated'),
  '8 : informations et frais de livraison modifiés, total recalculé, modification historisée');

-- Table 1 : plat envoyé, dessert « à suivre »
select set_config('t.o', public.create_order(current_setting('t.a1')::uuid, 'dine_in', current_setting('t.t1')::uuid, 3::smallint)::text, true);
select set_config('t.lplat', public.add_order_item(current_setting('t.o')::uuid, current_setting('t.vplat')::uuid, 3)::text, true);
select set_config('t.ldessert', public.add_order_item(current_setting('t.o')::uuid, current_setting('t.vdessert')::uuid, 3)::text, true);
select public.set_item_held(current_setting('t.ldessert')::uuid, true);
select zz_tests.expect(public.send_order(current_setting('t.o')::uuid) = 1, '9 : à l''envoi, l''article « à suivre » reste en attente');
select zz_tests.expect((select prep_status = 'pending' and held from public.order_items where id = current_setting('t.ldessert')::uuid),
  '10 : le dessert attend « Lancer la suite »');
select zz_tests.expect_error(format($q$select public.set_item_held(%L, true)$q$, current_setting('t.lplat')),
  'resto.item_already_sent', '11 : un article déjà parti ne se met pas en attente');

select public.move_order_table(current_setting('t.o')::uuid, current_setting('t.vip')::uuid);
select zz_tests.expect((select table_id from public.orders where id = current_setting('t.o')::uuid) = current_setting('t.vip')::uuid,
  '12 : la commande change de table (vers une table libre)');
select public.create_order(current_setting('t.a1')::uuid, 'dine_in', current_setting('t.t2')::uuid);
select zz_tests.expect_error(format($q$select public.move_order_table(%L, %L)$q$, current_setting('t.o'), current_setting('t.t2')),
  'resto.table_busy', '13 : vers une table occupée : refusé');
select zz_tests.expect_error(format($q$select public.move_order_table(%L, %L)$q$, current_setting('t.c1'), current_setting('t.t1')),
  'resto.invalid_order', '14 : une vente à emporter n''a pas de table');

-- ------------------------------------------------------------- cuisine K
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000e013","role":"authenticated"}';
select public.set_prep_status(array[current_setting('t.lplat')::uuid], 'ready');
select zz_tests.expect((select ready_at is null from public.orders where id = current_setting('t.o')::uuid),
  '15 : pas « prête » tant que le dessert attend');

-- ------------------------------------------------------------- serveur W : la suite
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000d013","role":"authenticated"}';
select zz_tests.expect(public.fire_held(current_setting('t.o')::uuid) = 1, '16 : « Lancer la suite » envoie le dessert');
select zz_tests.expect_error(format($q$select public.fire_held(%L)$q$, current_setting('t.o')),
  'resto.invalid_status', '17 : plus rien en attente : refusé');
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000e013","role":"authenticated"}';
select public.set_prep_status(array[current_setting('t.ldessert')::uuid], 'ready');
select zz_tests.expect((select ready_at is not null and served_at is null from public.orders where id = current_setting('t.o')::uuid),
  '18 : tout est prêt : la commande est « prête » (heure notée)');
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000d013","role":"authenticated"}';
select public.set_prep_status(array[current_setting('t.lplat')::uuid, current_setting('t.ldessert')::uuid], 'served');
select zz_tests.expect((select served_at is not null from public.orders where id = current_setting('t.o')::uuid),
  '19 : tout est servi : la commande est « servie » (heure notée)');

-- ------------------------------------------------------------- client C : commande en ligne
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000c013","role":"authenticated"}';
select set_config('t.web', public.place_online_order(current_setting('t.a1')::uuid, 'takeaway',
  jsonb_build_array(jsonb_build_object('variant_id', current_setting('t.vplat'))))::jsonb ->> 'order_id', true);
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000d013","role":"authenticated"}';
select public.accept_online_order(current_setting('t.web')::uuid, 25);
select zz_tests.expect((select acceptance = 'accepted' and promised_at = now() + interval '25 minutes'
    from public.orders where id = current_setting('t.web')::uuid)
  and not exists (select 1 from public.order_items where order_id = current_setting('t.web')::uuid and prep_status = 'pending'),
  '20 : acceptée avec un délai de 25 min : heure promise au client, envoi en cuisine');
select public.set_promised_time(current_setting('t.web')::uuid, 40);
select zz_tests.expect((select promised_at from public.orders where id = current_setting('t.web')::uuid) = now() + interval '40 minutes',
  '21 : le délai annoncé peut être modifié');

-- ------------------------------------------------------------- réservation installée
select set_config('t.res', public.staff_create_reservation(current_setting('t.a1')::uuid, now() - interval '5 minutes', 90::smallint,
  4::smallint, 'Famille Ekwalla', '+237 650000000', array[current_setting('t.t1')::uuid], 'anniversaire')::text, true);
select set_config('t.ro', public.seat_reservation(current_setting('t.res')::uuid)::text, true);
select zz_tests.expect((select table_id = current_setting('t.t1')::uuid and guests = 4 and customer_name = 'Famille Ekwalla'
    and reservation_id = current_setting('t.res')::uuid from public.orders where id = current_setting('t.ro')::uuid)
  and (select status from public.reservations where id = current_setting('t.res')::uuid) = 'seated',
  '22 : clients arrivés : commande ouverte sur leur table, avec le nom et le nombre de personnes');
select zz_tests.expect(public.seat_reservation(current_setting('t.res')::uuid) = current_setting('t.ro')::uuid,
  '23 : installer deux fois ne crée pas de deuxième commande');
select public.cancel_order(current_setting('t.ro')::uuid, null);
select zz_tests.expect((select status from public.reservations where id = current_setting('t.res')::uuid) = 'completed'
  and exists (select 1 from public.available_tables(current_setting('t.a1')::uuid, now(), now() + interval '1 hour')
               where table_id = current_setting('t.t1')::uuid),
  '24 : fin du repas : réservation terminée et table de nouveau libre');

-- ------------------------------------------------------------- autre organisation B
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000b013","role":"authenticated"}';
select public.create_organization('Service B', 'CM', 'XAF', 'fr', 'Africa/Douala', 'Yaoundé');
select zz_tests.expect_error(format($q$select public.create_order(%L, 'takeaway')$q$, current_setting('t.a1')),
  '42501', '25 : B ne crée pas de commande chez A');
select zz_tests.expect_error(format($q$select public.move_order_table(%L, %L)$q$, current_setting('t.o'), current_setting('t.t1')),
  '42501', '26 : B ne déplace pas les commandes de A');
select zz_tests.expect_error(format($q$select public.seat_reservation(%L)$q$, current_setting('t.res')),
  '42501', '27 : B n''installe pas les réservations de A');

reset role;
rollback;
select 'TOUS LES CONTRÔLES 013 SONT PASSÉS (27)' as resultat;
