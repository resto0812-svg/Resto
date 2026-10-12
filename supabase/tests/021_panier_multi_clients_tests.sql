-- =============================================================================
-- Resto — contrôles de la migration 021 (panier multi-restaurants, fiche client
-- par restaurant). À coller APRÈS 021. Transaction annulée à la fin.
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

-- A et B = deux restaurants, C = client
insert into auth.users (id, email, aud, role, raw_user_meta_data, email_confirmed_at) values
  ('00000000-0000-0000-0000-00000000a021', 'owner.a21@resto.test', 'authenticated', 'authenticated', '{}', now()),
  ('00000000-0000-0000-0000-00000000b021', 'owner.b21@resto.test', 'authenticated', 'authenticated', '{}', now()),
  ('00000000-0000-0000-0000-00000000c021', 'client.c21@resto.test', 'authenticated', 'authenticated', '{}', now());

set local role authenticated;
-- Restaurant A
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000a021","role":"authenticated"}';
select set_config('t.a', public.create_organization('Burger 21', 'CM', 'XAF', 'fr', 'Africa/Douala', 'Xxville', null, 'A')::text, true);
select set_config('t.orgA', current_setting('t.a')::jsonb ->> 'organization_id', true);
select set_config('t.brA', current_setting('t.a')::jsonb ->> 'brand_id', true);
select set_config('t.bA', current_setting('t.a')::jsonb ->> 'branch_id', true);
with ins as (insert into public.menu_categories (organization_id, brand_id, name)
  values (current_setting('t.orgA')::uuid, current_setting('t.brA')::uuid, 'Burgers') returning id)
select set_config('t.catA', (select id::text from ins), true);
select set_config('t.itA', public.create_menu_item(current_setting('t.catA')::uuid, 'Burger', null, 'food')::text, true);
select set_config('t.vA', (select id::text from public.item_variants where item_id = current_setting('t.itA')::uuid), true);
insert into public.menu_item_branches (organization_id, brand_id, item_id, branch_id)
values (current_setting('t.orgA')::uuid, current_setting('t.brA')::uuid, current_setting('t.itA')::uuid, current_setting('t.bA')::uuid);
select public.set_price(current_setting('t.bA')::uuid, current_setting('t.vA')::uuid, null, 'default', 3000);
update public.branches set is_published = true, accepts_online_orders = true where id = current_setting('t.bA')::uuid;
select set_config('t.regA', (select id::text from public.cash_registers where branch_id = current_setting('t.bA')::uuid), true);
select set_config('t.cashA', (select id::text from public.payment_methods where organization_id = current_setting('t.orgA')::uuid and ref_code = 'cash'), true);

-- Restaurant B
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000b021","role":"authenticated"}';
select set_config('t.b', public.create_organization('Pizza 21', 'CM', 'XAF', 'fr', 'Africa/Douala', 'Xxville', null, 'B')::text, true);
select set_config('t.orgB', current_setting('t.b')::jsonb ->> 'organization_id', true);
select set_config('t.brB', current_setting('t.b')::jsonb ->> 'brand_id', true);
select set_config('t.bB', current_setting('t.b')::jsonb ->> 'branch_id', true);
with ins as (insert into public.menu_categories (organization_id, brand_id, name)
  values (current_setting('t.orgB')::uuid, current_setting('t.brB')::uuid, 'Pizzas') returning id)
select set_config('t.catB', (select id::text from ins), true);
select set_config('t.itB', public.create_menu_item(current_setting('t.catB')::uuid, 'Pizza', null, 'food')::text, true);
select set_config('t.vB', (select id::text from public.item_variants where item_id = current_setting('t.itB')::uuid), true);
insert into public.menu_item_branches (organization_id, brand_id, item_id, branch_id)
values (current_setting('t.orgB')::uuid, current_setting('t.brB')::uuid, current_setting('t.itB')::uuid, current_setting('t.bB')::uuid);
select public.set_price(current_setting('t.bB')::uuid, current_setting('t.vB')::uuid, null, 'default', 5000);
update public.branches set is_published = true, accepts_online_orders = false where id = current_setting('t.bB')::uuid;

-- ------------------------------------------------------------- client C
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000c021","role":"authenticated"}';
insert into public.customer_profiles (full_name, phone, allergies) values ('Awa Ndiaye', '+237 600 11 22 33', '{peanuts}');
select set_config('t.parts', jsonb_build_array(
  jsonb_build_object('branch_id', current_setting('t.bA'), 'channel', 'takeaway', 'client_id', gen_random_uuid(),
                     'items', jsonb_build_array(jsonb_build_object('variant_id', current_setting('t.vA'), 'quantity', 2))),
  jsonb_build_object('branch_id', current_setting('t.bB'), 'channel', 'takeaway', 'client_id', gen_random_uuid(),
                     'items', jsonb_build_array(jsonb_build_object('variant_id', current_setting('t.vB'), 'quantity', 1))))::text, true);
select set_config('t.ck1', gen_random_uuid()::text, true);
select zz_tests.expect_error(format($q$select public.place_checkout(%L, %L::jsonb)$q$, current_setting('t.ck1'), current_setting('t.parts')),
  'resto.online_orders_closed', '1 : un restaurant fermé aux commandes en ligne fait échouer tout le panier');
select zz_tests.expect((select count(*) from public.orders where customer_user_id = '00000000-0000-0000-0000-00000000c021') = 0,
  '2 : tout ou rien : aucune commande créée');

reset role;
update public.branches set accepts_online_orders = true where id = current_setting('t.bB')::uuid;
set local role authenticated;
select set_config('t.ck', gen_random_uuid()::text, true);
select set_config('t.res', public.place_checkout(current_setting('t.ck')::uuid, current_setting('t.parts')::jsonb, '+237 600 11 22 33', 'Awa')::text, true);
select zz_tests.expect(jsonb_array_length(current_setting('t.res')::jsonb) = 2
  and (select count(distinct organization_id) = 2 and count(*) = 2 from public.orders where checkout_id = current_setting('t.ck')::uuid),
  '3 : une commande indépendante par restaurant, reliées au même passage en caisse');
select zz_tests.expect(jsonb_array_length(public.place_checkout(current_setting('t.ck')::uuid, current_setting('t.parts')::jsonb)) = 2
  and (select count(*) from public.orders where customer_user_id = '00000000-0000-0000-0000-00000000c021') = 2,
  '4 : validation rejouée : pas de doublon');
select zz_tests.expect(jsonb_array_length(public.my_checkout(current_setting('t.ck')::uuid)) = 2, '5 : le client suit ses deux commandes');

-- ------------------------------------------------------------- restaurant A
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000a021","role":"authenticated"}';
select zz_tests.expect((select count(*) from public.orders where checkout_id = current_setting('t.ck')::uuid) = 1,
  '6 : le restaurant A ne voit que sa propre commande');
select zz_tests.expect((select display_name = 'Awa' and allergies = '{peanuts}' and phone is not null
                          from public.restaurant_customers where user_id = '00000000-0000-0000-0000-00000000c021'),
  '7 : fiche client créée chez A (nom, téléphone, allergies partagées)');
select set_config('t.oA', (select id::text from public.orders where checkout_id = current_setting('t.ck')::uuid), true);
select public.accept_online_order(current_setting('t.oA')::uuid, 10);
select set_config('t.sA', public.open_cash_session(current_setting('t.regA')::uuid, 0)::text, true);
select public.take_payment(current_setting('t.oA')::uuid, current_setting('t.sA')::uuid, current_setting('t.cashA')::uuid, 6000);
select zz_tests.expect((select orders_count = 1 and total_spent_minor = 6000 from public.restaurant_customers
                          where user_id = '00000000-0000-0000-0000-00000000c021'),
  '8 : commandes et dépenses du client chez A seulement');
update public.restaurant_customers set notes = 'Aime la sauce piquante' where user_id = '00000000-0000-0000-0000-00000000c021';

-- ------------------------------------------------------------- restaurant B
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000b021","role":"authenticated"}';
select zz_tests.expect((select orders_count = 0 and notes is null from public.restaurant_customers
                          where user_id = '00000000-0000-0000-0000-00000000c021')
  and (select count(*) from public.restaurant_customers) = 1,
  '9 : B ne voit ni les dépenses ni les notes de A sur ce client');

-- ------------------------------------------------------------- allergies non partagées
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000c021","role":"authenticated"}';
update public.customer_profiles set share_allergies = false;
select public.place_online_order(current_setting('t.bB')::uuid, 'takeaway',
  jsonb_build_array(jsonb_build_object('variant_id', current_setting('t.vB'), 'quantity', 1)));
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000b021","role":"authenticated"}';
select zz_tests.expect((select allergies = '{}' from public.restaurant_customers where user_id = '00000000-0000-0000-0000-00000000c021'),
  '10 : allergies retirées de la fiche quand le client ne les partage plus');

reset role;
rollback;
select 'TOUS LES CONTRÔLES 021 SONT PASSÉS (10)' as resultat;
