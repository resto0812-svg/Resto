-- =============================================================================
-- Resto — contrôles de la migration 008 (stocks et fiches techniques).
-- À coller APRÈS 008. Transaction annulée à la fin : aucune donnée ne reste.
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

-- A = propriétaire, S = magasinier (A1), W = serveur (A1), B = autre organisation
insert into auth.users (id, email, aud, role, raw_user_meta_data, email_confirmed_at) values
  ('00000000-0000-0000-0000-00000000a009', 'owner.a9@resto.test', 'authenticated', 'authenticated', '{}', now()),
  ('00000000-0000-0000-0000-00000000c009', 'stock.s9@resto.test', 'authenticated', 'authenticated', '{}', now()),
  ('00000000-0000-0000-0000-00000000d009', 'waiter.w9@resto.test', 'authenticated', 'authenticated', '{}', now()),
  ('00000000-0000-0000-0000-00000000b009', 'owner.b9@resto.test', 'authenticated', 'authenticated', '{}', now());

set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000a009","role":"authenticated"}';
select set_config('t.a', public.create_organization('Stock A', 'CM', 'XAF', 'fr', 'Africa/Douala', 'Douala', null, 'A1')::text, true);
select set_config('t.org', current_setting('t.a')::jsonb ->> 'organization_id', true);
select set_config('t.brand', current_setting('t.a')::jsonb ->> 'brand_id', true);
select set_config('t.a1', current_setting('t.a')::jsonb ->> 'branch_id', true);
select set_config('t.res', (select id::text from public.stock_locations where branch_id = current_setting('t.a1')::uuid), true);
select zz_tests.expect(current_setting('t.res') <> '', '1 : emplacement « Réserve » créé avec l''établissement');

with ins as (insert into public.ingredients (organization_id, name, kind, unit_code)
  values (current_setting('t.org')::uuid, 'Poulet', 'raw', 'kg') returning id)
select set_config('t.poulet', (select id::text from ins), true);
with ins as (insert into public.ingredients (organization_id, name, kind, unit_code)
  values (current_setting('t.org')::uuid, 'Huile', 'raw', 'l') returning id)
select set_config('t.huile', (select id::text from ins), true);
with ins as (insert into public.ingredients (organization_id, name, kind, unit_code)
  values (current_setting('t.org')::uuid, 'Sauce DG', 'semi_finished', 'kg') returning id)
select set_config('t.sauce', (select id::text from ins), true);

-- Entrées valorisées et coût moyen pondéré
select public.record_stock_movement(current_setting('t.a1')::uuid, current_setting('t.res')::uuid,
  current_setting('t.poulet')::uuid, 'receipt', 10, 'kg', 3000);
select public.record_stock_movement(current_setting('t.a1')::uuid, current_setting('t.res')::uuid,
  current_setting('t.poulet')::uuid, 'receipt', 5000, 'g', 3.6);
select public.record_stock_movement(current_setting('t.a1')::uuid, current_setting('t.res')::uuid,
  current_setting('t.huile')::uuid, 'receipt', 2, 'l', 1500);
select zz_tests.expect((select avg_unit_cost from public.ingredient_stock where ingredient_id = current_setting('t.poulet')::uuid) = 3200,
  '2 : 10 kg à 3 000 + 5 000 g à 3,6 / g : 15 kg, coût moyen 3 200 / kg (conversion g → kg)');

select zz_tests.expect_error(format($q$select public.record_stock_movement(%L, %L, %L, 'waste', 0.5, 'kg')$q$,
  current_setting('t.a1'), current_setting('t.res'), current_setting('t.poulet')), 'resto.reason_required',
  '3 : une perte exige un motif');
select zz_tests.expect_error(format($q$select public.record_stock_movement(%L, %L, %L, 'receipt', 1, 'l', 100)$q$,
  current_setting('t.a1'), current_setting('t.res'), current_setting('t.poulet')), 'resto.invalid_quantity',
  '4 : unité incompatible (litres pour un ingrédient en kg) refusée');
select public.record_stock_movement(current_setting('t.a1')::uuid, current_setting('t.res')::uuid,
  current_setting('t.poulet')::uuid, 'waste', 0.5, 'kg', 0, 'avarié');
select zz_tests.expect((select quantity from public.stock_overview(current_setting('t.a1')::uuid)
    where ingredient_id = current_setting('t.poulet')::uuid) = 14.5
  and (select value_minor from public.stock_overview(current_setting('t.a1')::uuid)
    where ingredient_id = current_setting('t.poulet')::uuid) = 46400,
  '5 : état du stock : 14,5 kg valorisés 46 400');
select zz_tests.expect_error(format($q$update public.ingredients set unit_code = 'g' where id = %L$q$, current_setting('t.poulet')),
  'resto.unit_locked', '6 : l''unité d''un ingrédient déjà mouvementé est figée');

-- Fiche technique, vente, consommation à la clôture
with ins as (insert into public.menu_categories (organization_id, brand_id, name)
  values (current_setting('t.org')::uuid, current_setting('t.brand')::uuid, 'Plats') returning id)
select set_config('t.cat', (select id::text from ins), true);
select set_config('t.item', public.create_menu_item(current_setting('t.cat')::uuid, 'Poulet DG')::text, true);
select set_config('t.var', (select id::text from public.item_variants where item_id = current_setting('t.item')::uuid), true);
insert into public.menu_item_branches (organization_id, brand_id, item_id, branch_id)
values (current_setting('t.org')::uuid, current_setting('t.brand')::uuid, current_setting('t.item')::uuid, current_setting('t.a1')::uuid);
select public.set_price(current_setting('t.a1')::uuid, current_setting('t.var')::uuid, null, 'default', 5000);
select public.save_recipe(current_setting('t.var')::uuid, null, null, 1, jsonb_build_array(
  jsonb_build_object('ingredient_id', current_setting('t.poulet'), 'quantity', 250, 'unit', 'g'),
  jsonb_build_object('ingredient_id', current_setting('t.huile'), 'quantity', 20, 'unit', 'ml')));
select zz_tests.expect((select cost_minor from public.recipe_costs(current_setting('t.a1')::uuid)
    where variant_id = current_setting('t.var')::uuid) = 830,
  '7 : coût de revient = 250 g × 3 200 / kg + 20 ml × 1 500 / l = 830');
select zz_tests.expect_error(format($q$select public.save_recipe(%L, null, null, 1, %L::jsonb)$q$, current_setting('t.var'),
  jsonb_build_array(jsonb_build_object('ingredient_id', current_setting('t.poulet'), 'quantity', 1, 'unit', 'l'))::text),
  'resto.invalid_recipe', '8 : fiche avec unité incompatible refusée');

select set_config('t.reg', (select id::text from public.cash_registers where branch_id = current_setting('t.a1')::uuid), true);
select set_config('t.sess', public.open_cash_session(current_setting('t.reg')::uuid, 0)::text, true);
select set_config('t.o', public.open_order(current_setting('t.a1')::uuid, 'takeaway')::text, true);
select set_config('t.line', public.add_order_item(current_setting('t.o')::uuid, current_setting('t.var')::uuid, 2)::text, true);
select public.send_order(current_setting('t.o')::uuid);
select public.record_payment(current_setting('t.o')::uuid, current_setting('t.sess')::uuid, 'cash', 10000);
select zz_tests.expect((select quantity from public.stock_movements where order_item_id = current_setting('t.line')::uuid
    and ingredient_id = current_setting('t.poulet')::uuid and kind = 'sale') = -0.5
  and (select quantity from public.stock_movements where order_item_id = current_setting('t.line')::uuid
    and ingredient_id = current_setting('t.huile')::uuid and kind = 'sale') = -0.04,
  '9 : commande payée et clôturée : 2 × (250 g + 20 ml) déduits du stock');

select public.save_recipe(current_setting('t.var')::uuid, null, null, 1, jsonb_build_array(
  jsonb_build_object('ingredient_id', current_setting('t.poulet'), 'quantity', 300, 'unit', 'g')));
select zz_tests.expect((select count(*) from public.recipe_versions where variant_id = current_setting('t.var')::uuid) = 2
  and (select count(*) from public.recipe_versions where variant_id = current_setting('t.var')::uuid and valid_to is null) = 1
  and (select count(*) from public.stock_movements where order_item_id = current_setting('t.line')::uuid) = 2,
  '10 : nouvelle version de fiche ; l''ancienne est conservée ; la vente passée n''est pas recalculée');

-- Préparation maison
select public.save_recipe(null, null, current_setting('t.sauce')::uuid, 1, jsonb_build_array(
  jsonb_build_object('ingredient_id', current_setting('t.huile'), 'quantity', 0.2, 'unit', 'l')));
select public.record_production(current_setting('t.a1')::uuid, current_setting('t.res')::uuid, current_setting('t.sauce')::uuid, 2);
select zz_tests.expect((select quantity from public.stock_overview(current_setting('t.a1')::uuid)
    where ingredient_id = current_setting('t.sauce')::uuid) = 2
  and (select avg_unit_cost from public.ingredient_stock where ingredient_id = current_setting('t.sauce')::uuid) = 300,
  '11 : 2 kg de sauce produits avec 0,4 l d''huile : coût 300 / kg');

-- Transfert et inventaire
with ins as (insert into public.stock_locations (organization_id, branch_id, name)
  values (current_setting('t.org')::uuid, current_setting('t.a1')::uuid, 'Cuisine') returning id)
select set_config('t.cuis', (select id::text from ins), true);
select public.transfer_stock(current_setting('t.res')::uuid, current_setting('t.cuis')::uuid, current_setting('t.poulet')::uuid, 1, 'kg');
select set_config('t.inv', public.start_inventory(current_setting('t.res')::uuid)::text, true);
select public.save_inventory_line(current_setting('t.inv')::uuid, current_setting('t.poulet')::uuid, 12, 'kg');
select public.validate_inventory(current_setting('t.inv')::uuid);
select zz_tests.expect((select theoretical_quantity from public.inventory_count_lines where count_id = current_setting('t.inv')::uuid) = 13
  and (select quantity from public.stock_movements where inventory_id = current_setting('t.inv')::uuid) = -1
  and (select quantity from public.stock_overview(current_setting('t.a1')::uuid)
    where ingredient_id = current_setting('t.poulet')::uuid) = 13,
  '12 : inventaire Réserve : théorique 13 kg, compté 12 kg, écart −1 enregistré (13 kg au total avec 1 kg en Cuisine)');
select zz_tests.expect_error(format($q$select public.save_inventory_line(%L, %L, 1, 'kg')$q$, current_setting('t.inv'),
  current_setting('t.poulet')), 'resto.inventory_closed', '13 : un inventaire validé ne se modifie plus');
select zz_tests.expect_error($q$update public.stock_movements set quantity = 1$q$, '42501',
  '14 : un mouvement de stock ne se modifie jamais');

reset role;
select zz_tests.expect_error($q$delete from public.stock_movements$q$, 'resto.audit_immutable',
  '15 : même l''administrateur SQL ne supprime pas un mouvement');
insert into public.memberships (organization_id, user_id, role_code, all_branches) values
  (current_setting('t.org')::uuid, '00000000-0000-0000-0000-00000000c009', 'stock_keeper', false),
  (current_setting('t.org')::uuid, '00000000-0000-0000-0000-00000000d009', 'waiter', false);
insert into public.membership_branches (organization_id, membership_id, branch_id)
select m.organization_id, m.id, current_setting('t.a1')::uuid from public.memberships m
 where m.user_id in ('00000000-0000-0000-0000-00000000c009', '00000000-0000-0000-0000-00000000d009');
set local role authenticated;

-- ------------------------------------------------------------- magasinier S
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000c009","role":"authenticated"}';
select public.record_stock_movement(current_setting('t.a1')::uuid, current_setting('t.res')::uuid,
  current_setting('t.huile')::uuid, 'waste', 100, 'ml', 0, 'bouteille cassée');
select zz_tests.expect(true, '16 : le magasinier enregistre une perte');
select zz_tests.expect_error(format($q$select public.record_stock_movement(%L, %L, %L, 'adjustment', -1, 'kg', 0, 'correction')$q$,
  current_setting('t.a1'), current_setting('t.res'), current_setting('t.poulet')), '42501', '17 : pas d''ajustement sans stock.adjust');
select set_config('t.inv2', public.start_inventory(current_setting('t.res')::uuid)::text, true);
select zz_tests.expect_error(format($q$select public.validate_inventory(%L)$q$, current_setting('t.inv2')),
  '42501', '18 : le magasinier compte, un responsable valide l''inventaire');
select zz_tests.expect_error(format($q$select public.save_recipe(%L, null, null, 1, '[]'::jsonb)$q$, current_setting('t.var')),
  '42501', '19 : les fiches techniques relèvent du menu');

-- ------------------------------------------------------------- serveur W
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000d009","role":"authenticated"}';
select zz_tests.expect_error(format($q$select * from public.stock_overview(%L)$q$, current_setting('t.a1')),
  '42501', '20 : un serveur ne consulte pas les stocks');
select zz_tests.expect((select count(*) from public.stock_movements) = 0, '21 : ni les mouvements');

-- ------------------------------------------------------------- autre organisation B
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000b009","role":"authenticated"}';
select public.create_organization('Stock B', 'CM', 'XAF', 'fr', 'Africa/Douala', 'Yaoundé');
select zz_tests.expect((select count(*) from public.ingredients) = 0 and (select count(*) from public.stock_movements) = 0
  and (select count(*) from public.recipe_versions) = 0, '22 : B ne voit rien des stocks de A');
select zz_tests.expect_error(format($q$select public.record_stock_movement(%L, %L, %L, 'receipt', 1, 'kg', 1)$q$,
  current_setting('t.a1'), current_setting('t.res'), current_setting('t.poulet')), '42501', '23 : B ne touche pas au stock de A');

reset role;
rollback;
select 'TOUS LES CONTRÔLES 008 SONT PASSÉS (23)' as resultat;
