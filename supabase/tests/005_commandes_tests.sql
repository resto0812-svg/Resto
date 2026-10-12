-- =============================================================================
-- Resto — contrôles de la migration 005 (prise de commande).
-- À coller APRÈS 005. Transaction annulée à la fin : aucune donnée ne reste.
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

-- A = propriétaire, W = serveur (A1), K = cuisine (A1), B = autre organisation
insert into auth.users (id, email, aud, role, raw_user_meta_data, email_confirmed_at) values
  ('00000000-0000-0000-0000-00000000a006', 'owner.a6@resto.test', 'authenticated', 'authenticated', '{}', now()),
  ('00000000-0000-0000-0000-00000000c006', 'waiter.w6@resto.test', 'authenticated', 'authenticated', '{}', now()),
  ('00000000-0000-0000-0000-00000000d006', 'kitchen.k6@resto.test', 'authenticated', 'authenticated', '{}', now()),
  ('00000000-0000-0000-0000-00000000b006', 'owner.b6@resto.test', 'authenticated', 'authenticated', '{}', now());

set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000a006","role":"authenticated"}';

-- ------------------------------------------------------------- mise en place du menu
select set_config('t.a', public.create_organization('Cmd A', 'CM', 'XAF', 'fr', 'Africa/Douala', 'Douala', null, 'A1')::text, true);
select set_config('t.org', current_setting('t.a')::jsonb ->> 'organization_id', true);
select set_config('t.brand', current_setting('t.a')::jsonb ->> 'brand_id', true);
select set_config('t.a1', current_setting('t.a')::jsonb ->> 'branch_id', true);
update public.branches set tax_rate = 19.25, prices_include_tax = true where id = current_setting('t.a1')::uuid;

with ins as (insert into public.service_areas (organization_id, branch_id, name)
  values (current_setting('t.org')::uuid, current_setting('t.a1')::uuid, 'Salle') returning id)
select set_config('t.area', (select id::text from ins), true);
with ins as (insert into public.dining_tables (organization_id, branch_id, service_area_id, label, seats)
  values (current_setting('t.org')::uuid, current_setting('t.a1')::uuid, current_setting('t.area')::uuid, 'T1', 4) returning id)
select set_config('t.t1', (select id::text from ins), true);

with ins as (insert into public.menu_categories (organization_id, brand_id, name)
  values (current_setting('t.org')::uuid, current_setting('t.brand')::uuid, 'Plats') returning id)
select set_config('t.cat', (select id::text from ins), true);
select set_config('t.poulet', public.create_menu_item(current_setting('t.cat')::uuid, 'Poulet DG')::text, true);
select set_config('t.vpoulet', (select id::text from public.item_variants where item_id = current_setting('t.poulet')::uuid), true);
select set_config('t.ndole', public.create_menu_item(current_setting('t.cat')::uuid, 'Ndolé')::text, true);
select set_config('t.vpetite', (select id::text from public.item_variants where item_id = current_setting('t.ndole')::uuid), true);
update public.item_variants set name = 'Petite' where id = current_setting('t.vpetite')::uuid;
with ins as (insert into public.item_variants (organization_id, brand_id, item_id, name)
  values (current_setting('t.org')::uuid, current_setting('t.brand')::uuid, current_setting('t.ndole')::uuid, 'Grande') returning id)
select set_config('t.vgrande', (select id::text from ins), true);
select set_config('t.sansprix', public.create_menu_item(current_setting('t.cat')::uuid, 'Sans prix')::text, true);
select set_config('t.vsansprix', (select id::text from public.item_variants where item_id = current_setting('t.sansprix')::uuid), true);

with ins as (insert into public.modifier_groups (organization_id, brand_id, name, min_select, max_select)
  values (current_setting('t.org')::uuid, current_setting('t.brand')::uuid, 'Accompagnement', 1, 1) returning id)
select set_config('t.gacc', (select id::text from ins), true);
with ins as (insert into public.modifier_groups (organization_id, brand_id, name, min_select, max_select)
  values (current_setting('t.org')::uuid, current_setting('t.brand')::uuid, 'Sauce', 0, null) returning id)
select set_config('t.gsauce', (select id::text from ins), true);
with ins as (insert into public.modifiers (organization_id, brand_id, group_id, name)
  values (current_setting('t.org')::uuid, current_setting('t.brand')::uuid, current_setting('t.gacc')::uuid, 'Miondo') returning id)
select set_config('t.miondo', (select id::text from ins), true);
with ins as (insert into public.modifiers (organization_id, brand_id, group_id, name)
  values (current_setting('t.org')::uuid, current_setting('t.brand')::uuid, current_setting('t.gacc')::uuid, 'Frites') returning id)
select set_config('t.frites', (select id::text from ins), true);
with ins as (insert into public.modifiers (organization_id, brand_id, group_id, name)
  values (current_setting('t.org')::uuid, current_setting('t.brand')::uuid, current_setting('t.gsauce')::uuid, 'Piment') returning id)
select set_config('t.piment', (select id::text from ins), true);
insert into public.item_modifier_groups (organization_id, brand_id, item_id, group_id)
values (current_setting('t.org')::uuid, current_setting('t.brand')::uuid, current_setting('t.ndole')::uuid, current_setting('t.gacc')::uuid);

insert into public.menu_item_branches (organization_id, brand_id, item_id, branch_id)
select current_setting('t.org')::uuid, current_setting('t.brand')::uuid, i, current_setting('t.a1')::uuid
  from unnest(array[current_setting('t.poulet')::uuid, current_setting('t.ndole')::uuid, current_setting('t.sansprix')::uuid]) i;
select public.set_price(current_setting('t.a1')::uuid, current_setting('t.vpoulet')::uuid, null, 'default', 5000);
select public.set_price(current_setting('t.a1')::uuid, current_setting('t.vpetite')::uuid, null, 'default', 2500);
select public.set_price(current_setting('t.a1')::uuid, current_setting('t.vgrande')::uuid, null, 'default', 3500);
select public.set_price(current_setting('t.a1')::uuid, current_setting('t.vgrande')::uuid, null, 'takeaway', 3000);
select public.set_price(current_setting('t.a1')::uuid, null, current_setting('t.frites')::uuid, 'default', 500);

reset role;
insert into public.memberships (organization_id, user_id, role_code, all_branches) values
  (current_setting('t.org')::uuid, '00000000-0000-0000-0000-00000000c006', 'waiter', false),
  (current_setting('t.org')::uuid, '00000000-0000-0000-0000-00000000d006', 'kitchen', false);
insert into public.membership_branches (organization_id, membership_id, branch_id)
select m.organization_id, m.id, current_setting('t.a1')::uuid from public.memberships m
 where m.user_id in ('00000000-0000-0000-0000-00000000c006', '00000000-0000-0000-0000-00000000d006');
set local role authenticated;

-- ------------------------------------------------------------- serveur W
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000c006","role":"authenticated"}';
select set_config('t.o1', public.open_order(current_setting('t.a1')::uuid, 'dine_in', current_setting('t.t1')::uuid, 2::smallint)::text, true);
select zz_tests.expect(public.open_order(current_setting('t.a1')::uuid, 'dine_in', current_setting('t.t1')::uuid) = current_setting('t.o1')::uuid,
  '1 : une table occupée rouvre sa commande en cours (jamais deux commandes ouvertes)');
select set_config('t.o2', public.open_order(current_setting('t.a1')::uuid, 'takeaway')::text, true);
select zz_tests.expect((select number from public.orders where id = current_setting('t.o1')::uuid) = 1
  and (select number from public.orders where id = current_setting('t.o2')::uuid) = 2
  and (select tax_rate from public.orders where id = current_setting('t.o1')::uuid) = 19.25,
  '2 : numéros du jour 1, 2… ; taxe de l''établissement figée sur la commande');
select zz_tests.expect_error(format($q$select public.open_order(%L, 'takeaway', %L)$q$, current_setting('t.a1'), current_setting('t.t1')),
  'resto.invalid_order', '3 : une vente à emporter n''a pas de table');

select public.add_order_item(current_setting('t.o1')::uuid, current_setting('t.vpoulet')::uuid, 2);
select zz_tests.expect((select subtotal_minor from public.orders where id = current_setting('t.o1')::uuid) = 10000
  and (select tax_minor from public.orders where id = current_setting('t.o1')::uuid) = 1614
  and (select total_minor from public.orders where id = current_setting('t.o1')::uuid) = 10000,
  '4 : prix choisi par le serveur ; taxe comprise extraite (10 000 dont 1 614 de taxe)');

select set_config('t.lndole', public.add_order_item(current_setting('t.o1')::uuid, current_setting('t.vgrande')::uuid, 1,
  array[current_setting('t.frites')::uuid])::text, true);
select zz_tests.expect((select unit_price_minor from public.order_items where id = current_setting('t.lndole')::uuid) = 4000
  and (select count(*) from public.order_item_modifiers where order_item_id = current_setting('t.lndole')::uuid and modifier_name = 'Frites') = 1,
  '5 : taille + option payante = 3 500 + 500, option enregistrée avec son nom');
select set_config('t.lto', public.add_order_item(current_setting('t.o2')::uuid, current_setting('t.vgrande')::uuid, 1,
  array[current_setting('t.miondo')::uuid])::text, true);
select zz_tests.expect((select unit_price_minor from public.order_items where id = current_setting('t.lto')::uuid) = 3000,
  '6 : à emporter, le prix propre au canal s''applique');

select zz_tests.expect_error(format($q$select public.add_order_item(%L, %L, 1)$q$, current_setting('t.o1'), current_setting('t.vgrande')),
  'resto.options_invalid', '7 : accompagnement obligatoire manquant refusé');
select zz_tests.expect_error(format($q$select public.add_order_item(%L, %L, 1, array[%L, %L]::uuid[])$q$, current_setting('t.o1'),
  current_setting('t.vgrande'), current_setting('t.miondo'), current_setting('t.frites')),
  'resto.options_invalid', '8 : deux accompagnements alors qu''un seul est permis : refusé');
select zz_tests.expect_error(format($q$select public.add_order_item(%L, %L, 1, array[%L, %L]::uuid[])$q$, current_setting('t.o1'),
  current_setting('t.vgrande'), current_setting('t.miondo'), current_setting('t.piment')),
  'resto.options_invalid', '9 : option d''un groupe non proposé sur cet article : refusée');
select zz_tests.expect_error(format($q$select public.add_order_item(%L, %L, 1)$q$, current_setting('t.o1'), current_setting('t.vsansprix')),
  'resto.no_price', '10 : article sans prix refusé');
select zz_tests.expect_error(format($q$select public.add_order_item(%L, %L, 0)$q$, current_setting('t.o1'), current_setting('t.vpoulet')),
  'resto.invalid_quantity', '11 : quantité nulle refusée');

select set_config('t.cid', gen_random_uuid()::text, true);
select public.add_order_item(current_setting('t.o1')::uuid, current_setting('t.vpetite')::uuid, 1,
  array[current_setting('t.miondo')::uuid], 'bien pimenté', current_setting('t.cid')::uuid);
select public.add_order_item(current_setting('t.o1')::uuid, current_setting('t.vpetite')::uuid, 1,
  array[current_setting('t.miondo')::uuid], 'bien pimenté', current_setting('t.cid')::uuid);
select zz_tests.expect((select count(*) from public.order_items where id = current_setting('t.cid')::uuid) = 1,
  '12 : un ajout rejoué (réseau) ne crée pas de doublon');

select public.update_order_item(current_setting('t.cid')::uuid, 3, 'bien pimenté');
select zz_tests.expect((select line_total_minor from public.order_items where id = current_setting('t.cid')::uuid) = 7500,
  '13 : ligne non envoyée : quantité modifiable');
-- Envoi et vérification en deux requêtes : une requête ne voit pas ses propres modifications.
select set_config('t.sent', public.send_order(current_setting('t.o1')::uuid)::text, true);
select zz_tests.expect(current_setting('t.sent')::int = 3
  and not exists (select 1 from public.order_items where order_id = current_setting('t.o1')::uuid and prep_status = 'pending'),
  '14 : envoi en cuisine de toutes les lignes en attente');
select zz_tests.expect_error(format($q$select public.update_order_item(%L, 1)$q$, current_setting('t.cid')),
  'resto.item_already_sent', '15 : ligne envoyée : plus modifiable');
select zz_tests.expect_error(format($q$select public.remove_order_item(%L)$q$, current_setting('t.cid')),
  'resto.item_already_sent', '16 : ligne envoyée : jamais effacée');
select zz_tests.expect_error(format($q$select public.cancel_order_item(%L, 'erreur de saisie')$q$, current_setting('t.cid')),
  '42501', '17 : un serveur n''annule pas une ligne envoyée');
select zz_tests.expect_error(format($q$select public.cancel_order(%L, 'client parti')$q$, current_setting('t.o1')),
  '42501', '18 : un serveur n''annule pas une commande déjà en cuisine');
select zz_tests.expect_error($q$update public.order_items set unit_price_minor = 1$q$, '42501',
  '19 : aucune ligne ne se modifie directement');

-- ------------------------------------------------------------- cuisine K
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000d006","role":"authenticated"}';
select zz_tests.expect((select count(*) from public.order_items where order_id = current_setting('t.o1')::uuid) = 3,
  '20 : la cuisine voit les commandes de son établissement');
select zz_tests.expect_error(format($q$select public.add_order_item(%L, %L, 1)$q$, current_setting('t.o1'), current_setting('t.vpoulet')),
  '42501', '21 : la cuisine ne prend pas de commande');

-- ------------------------------------------------------------- autre organisation B
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000b006","role":"authenticated"}';
select public.create_organization('Cmd B', 'CM', 'XAF', 'fr', 'Africa/Douala', 'Yaoundé');
select zz_tests.expect((select count(*) from public.orders) = 0 and (select count(*) from public.order_items) = 0
  and (select count(*) from public.order_events) = 0, '22 : B ne voit aucune commande de A');
select zz_tests.expect_error(format($q$select public.add_order_item(%L, %L, 1)$q$, current_setting('t.o1'), current_setting('t.vpoulet')),
  '42501', '23 : B n''ajoute rien à une commande de A');
select zz_tests.expect_error(format($q$select public.open_order(%L, 'takeaway')$q$, current_setting('t.a1')),
  '42501', '24 : B n''ouvre pas de commande chez A');

-- ------------------------------------------------------------- propriétaire A
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000a006","role":"authenticated"}';
select public.set_price(current_setting('t.a1')::uuid, current_setting('t.vpoulet')::uuid, null, 'default', 6000);
select zz_tests.expect((select unit_price_minor from public.order_items where order_id = current_setting('t.o1')::uuid
    and variant_id = current_setting('t.vpoulet')::uuid) = 5000,
  '25 : un changement de prix ne modifie jamais une commande déjà prise');
select zz_tests.expect_error(format($q$select public.cancel_order_item(%L, '')$q$, current_setting('t.cid')),
  'resto.reason_required', '26 : annulation sans motif refusée');
select public.cancel_order_item(current_setting('t.cid')::uuid, 'erreur de saisie');
select zz_tests.expect((select prep_status from public.order_items where id = current_setting('t.cid')::uuid) = 'cancelled'
  and (select subtotal_minor from public.orders where id = current_setting('t.o1')::uuid) = 14000,
  '27 : ligne annulée conservée, retirée du total (10 000 + 4 000)');
select public.cancel_order(current_setting('t.o1')::uuid, 'client parti');
select zz_tests.expect((select status from public.orders where id = current_setting('t.o1')::uuid) = 'cancelled'
  and public.open_order(current_setting('t.a1')::uuid, 'dine_in', current_setting('t.t1')::uuid) <> current_setting('t.o1')::uuid,
  '28 : commande annulée : la table est libérée');
select zz_tests.expect((select count(*) from public.order_events where order_id = current_setting('t.o1')::uuid) >= 8,
  '29 : chaque étape de la commande est historisée');
select zz_tests.expect_error(format($q$update public.order_events set event = 'opened' where order_id = %L$q$, current_setting('t.o1')),
  '42501', '30 : l''historique ne se modifie pas');

-- Taxe ajoutée au prix (prix affichés hors taxe)
update public.branches set tax_rate = 10, prices_include_tax = false where id = current_setting('t.a1')::uuid;
select set_config('t.o3', public.open_order(current_setting('t.a1')::uuid, 'takeaway')::text, true);
select public.add_order_item(current_setting('t.o3')::uuid, current_setting('t.vpoulet')::uuid, 1);
select zz_tests.expect((select total_minor from public.orders where id = current_setting('t.o3')::uuid) = 6600
  and (select tax_minor from public.orders where id = current_setting('t.o3')::uuid) = 600,
  '31 : prix hors taxe : 6 000 + 10 % = 6 600');

reset role;
rollback;
select 'TOUS LES CONTRÔLES 005 SONT PASSÉS (31)' as resultat;
