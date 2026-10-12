-- =============================================================================
-- Resto — contrôles de la migration 004 (menus et prix).
-- À coller APRÈS 004. Transaction annulée à la fin : aucune donnée ne reste.
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

create function zz_tests.rows(p_sql text) returns bigint language plpgsql as $$
declare n bigint;
begin
  execute p_sql;
  get diagnostics n = row_count;
  return n;
end $$;

-- A = propriétaire, M = responsable limité à l'établissement A1, W = serveur, B = autre organisation
insert into auth.users (id, email, aud, role, raw_user_meta_data, email_confirmed_at) values
  ('00000000-0000-0000-0000-00000000a004', 'owner.a4@resto.test', 'authenticated', 'authenticated', '{}', now()),
  ('00000000-0000-0000-0000-00000000c004', 'manager.m4@resto.test', 'authenticated', 'authenticated', '{}', now()),
  ('00000000-0000-0000-0000-00000000d004', 'waiter.w4@resto.test', 'authenticated', 'authenticated', '{}', now()),
  ('00000000-0000-0000-0000-00000000b004', 'owner.b4@resto.test', 'authenticated', 'authenticated', '{}', now());

set local role authenticated;
-- ------------------------------------------------------------- propriétaire A
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000a004","role":"authenticated"}';
select set_config('t.a', public.create_organization('Menu A', 'CM', 'XAF', 'fr', 'Africa/Douala', 'Douala', null, 'A1')::text, true);
select set_config('t.org', current_setting('t.a')::jsonb ->> 'organization_id', true);
select set_config('t.brand', current_setting('t.a')::jsonb ->> 'brand_id', true);
select set_config('t.a1', current_setting('t.a')::jsonb ->> 'branch_id', true);
with ins as (
  insert into public.branches (organization_id, brand_id, name, slug, country_code, city, timezone, currency, default_locale)
  values (current_setting('t.org')::uuid, current_setting('t.brand')::uuid, 'A2', 'a2', 'CM', 'Douala', 'Africa/Douala', 'XAF', 'fr')
  returning id)
select set_config('t.a2', (select id::text from ins), true);

with ins as (
  insert into public.menu_categories (organization_id, brand_id, name)
  values (current_setting('t.org')::uuid, current_setting('t.brand')::uuid, 'Plats') returning id)
select set_config('t.cat', (select id::text from ins), true);
select set_config('t.item', public.create_menu_item(current_setting('t.cat')::uuid, 'Ndolé', 'Aux crevettes')::text, true);
select set_config('t.v1', (select id::text from public.item_variants where item_id = current_setting('t.item')::uuid), true);
select zz_tests.expect((select count(*) from public.item_variants where item_id = current_setting('t.item')::uuid and name = '') = 1,
  '1 : un article est créé avec sa variante unique');

with ins as (
  insert into public.item_variants (organization_id, brand_id, item_id, name)
  values (current_setting('t.org')::uuid, current_setting('t.brand')::uuid, current_setting('t.item')::uuid, 'Grande') returning id)
select set_config('t.v2', (select id::text from ins), true);
with ins as (
  insert into public.modifier_groups (organization_id, brand_id, name, min_select, max_select)
  values (current_setting('t.org')::uuid, current_setting('t.brand')::uuid, 'Accompagnement', 1, 1) returning id)
select set_config('t.grp', (select id::text from ins), true);
with ins as (
  insert into public.modifiers (organization_id, brand_id, group_id, name)
  values (current_setting('t.org')::uuid, current_setting('t.brand')::uuid, current_setting('t.grp')::uuid, 'Miondo') returning id)
select set_config('t.mod', (select id::text from ins), true);
insert into public.item_modifier_groups (organization_id, brand_id, item_id, group_id)
values (current_setting('t.org')::uuid, current_setting('t.brand')::uuid, current_setting('t.item')::uuid, current_setting('t.grp')::uuid);
insert into public.item_allergens (organization_id, item_id, allergen_code)
values (current_setting('t.org')::uuid, current_setting('t.item')::uuid, 'crustaceans');
insert into public.menu_item_translations (organization_id, item_id, locale, name, description)
values (current_setting('t.org')::uuid, current_setting('t.item')::uuid, 'en', 'Ndole', 'With shrimps');
insert into public.menu_item_branches (organization_id, brand_id, item_id, branch_id)
values (current_setting('t.org')::uuid, current_setting('t.brand')::uuid, current_setting('t.item')::uuid, current_setting('t.a1')::uuid),
       (current_setting('t.org')::uuid, current_setting('t.brand')::uuid, current_setting('t.item')::uuid, current_setting('t.a2')::uuid);
select zz_tests.expect(true, '2 : variantes, suppléments, allergènes, traductions et établissements enregistrés');

select zz_tests.expect_error(format($q$insert into public.item_allergens (organization_id, item_id, allergen_code) values (%L, %L, 'plutonium')$q$,
  current_setting('t.org'), current_setting('t.item')), '23503', '3 : allergène inconnu refusé');
select zz_tests.expect_error(format($q$insert into public.modifier_groups (organization_id, brand_id, name, min_select, max_select) values (%L, %L, 'X', 3, 2)$q$,
  current_setting('t.org'), current_setting('t.brand')), '23514', '4 : minimum de choix supérieur au maximum refusé');

-- Prix : création, changement (historique), sans changement, canal, retrait
select public.set_price(current_setting('t.a1')::uuid, current_setting('t.v1')::uuid, null, 'default', 2500);
select public.set_price(current_setting('t.a1')::uuid, current_setting('t.v1')::uuid, null, 'default', 3000);
select public.set_price(current_setting('t.a1')::uuid, current_setting('t.v1')::uuid, null, 'default', 3000);
select zz_tests.expect(
  (select count(*) from public.prices where variant_id = current_setting('t.v1')::uuid and channel = 'default') = 2
  and (select amount_minor from public.prices where variant_id = current_setting('t.v1')::uuid and channel = 'default' and valid_to is null) = 3000
  and (select currency from public.prices where variant_id = current_setting('t.v1')::uuid and valid_to is null) = 'XAF',
  '5 : prix modifié = ancien clôturé, nouveau créé ; même prix = aucune ligne de plus ; monnaie de l''établissement');
select public.set_price(current_setting('t.a1')::uuid, current_setting('t.v1')::uuid, null, 'delivery', 3500);
select public.set_price(current_setting('t.a1')::uuid, current_setting('t.v1')::uuid, null, 'delivery', null);
select zz_tests.expect(not exists (select 1 from public.prices where variant_id = current_setting('t.v1')::uuid
    and channel = 'delivery' and valid_to is null)
  and exists (select 1 from public.prices where variant_id = current_setting('t.v1')::uuid and channel = 'delivery'),
  '6 : prix de canal retiré : clôturé mais conservé dans l''historique');
select public.set_price(current_setting('t.a1')::uuid, null, current_setting('t.mod')::uuid, 'default', 500);
select zz_tests.expect((select count(*) from public.prices where modifier_id = current_setting('t.mod')::uuid and valid_to is null) = 1,
  '7 : prix d''un supplément');

select zz_tests.expect_error(format($q$select public.set_price(%L, %L, %L, 'default', 100)$q$,
  current_setting('t.a1'), current_setting('t.v1'), current_setting('t.mod')), 'resto.invalid_price', '8 : variante ET supplément refusés');
select zz_tests.expect_error(format($q$select public.set_price(%L, %L, null, 'default', -1)$q$,
  current_setting('t.a1'), current_setting('t.v1')), 'resto.invalid_price', '9 : prix négatif refusé');
select zz_tests.expect_error(format($q$select public.set_price(%L, %L, null, 'pigeon', 100)$q$,
  current_setting('t.a1'), current_setting('t.v1')), 'resto.invalid_price', '10 : canal inconnu refusé');
select zz_tests.expect_error(format($q$update public.prices set amount_minor = 1 where variant_id = %L$q$,
  current_setting('t.v1')), '42501', '11 : un prix ne se modifie jamais directement');
select zz_tests.expect_error(format($q$delete from public.prices where variant_id = %L$q$,
  current_setting('t.v1')), '42501', '12 : un prix ne se supprime jamais');
select zz_tests.expect_error(format($q$update public.branches set currency = 'EUR' where id = %L$q$,
  current_setting('t.a1')), 'resto.currency_locked', '13 : monnaie figée dès qu''il existe des prix');

-- Cohérence de marque : un supplément d'une autre marque ne peut pas être lié
with ins as (
  insert into public.brands (organization_id, name, slug) values (current_setting('t.org')::uuid, 'Autre marque', 'zz-autre-marque-004')
  returning id)
select set_config('t.brand2', (select id::text from ins), true);
with ins as (
  insert into public.modifier_groups (organization_id, brand_id, name)
  values (current_setting('t.org')::uuid, current_setting('t.brand2')::uuid, 'Sauce') returning id)
select set_config('t.grp2', (select id::text from ins), true);
select zz_tests.expect_error(format($q$insert into public.item_modifier_groups (organization_id, brand_id, item_id, group_id) values (%L, %L, %L, %L)$q$,
  current_setting('t.org'), current_setting('t.brand'), current_setting('t.item'), current_setting('t.grp2')),
  '23503', '14 : groupe de suppléments d''une autre marque refusé');

-- Équipe (insérée directement par l'administrateur SQL) : responsable et serveur limités à A1
reset role;
insert into public.memberships (organization_id, user_id, role_code, all_branches) values
  (current_setting('t.org')::uuid, '00000000-0000-0000-0000-00000000c004', 'manager', false),
  (current_setting('t.org')::uuid, '00000000-0000-0000-0000-00000000d004', 'waiter', false);
insert into public.membership_branches (organization_id, membership_id, branch_id)
select m.organization_id, m.id, current_setting('t.a1')::uuid from public.memberships m
 where m.user_id in ('00000000-0000-0000-0000-00000000c004', '00000000-0000-0000-0000-00000000d004');
set local role authenticated;

-- ------------------------------------------------------------- responsable M (A1 seulement)
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000c004","role":"authenticated"}';
select zz_tests.expect((select count(*) from public.menu_items) = 1 and (select count(*) from public.menu_item_translations) = 1,
  '15 : un responsable lit le catalogue de la marque');
select zz_tests.expect((select count(*) from public.prices where branch_id = current_setting('t.a2')::uuid) = 0
  and (select count(*) from public.menu_item_branches) = 1, '16 : il ne voit que les prix et articles de son établissement');
select zz_tests.expect_error(format($q$insert into public.menu_categories (organization_id, brand_id, name) values (%L, %L, 'X')$q$,
  current_setting('t.org'), current_setting('t.brand')), '42501', '17 : le catalogue de la marque se gère sur toute l''organisation');
select zz_tests.expect_error(format($q$select public.create_menu_item(%L, 'X')$q$, current_setting('t.cat')),
  '42501', '18 : un responsable limité ne crée pas d''article');
select public.set_price(current_setting('t.a1')::uuid, current_setting('t.v2')::uuid, null, 'default', 4000);
select zz_tests.expect(zz_tests.rows(format($q$update public.menu_item_branches set available = false where item_id = %L and branch_id = %L$q$,
  current_setting('t.item'), current_setting('t.a1'))) = 1, '19 : il fixe les prix et la disponibilité de son établissement');
select zz_tests.expect_error(format($q$select public.set_price(%L, %L, null, 'default', 1)$q$,
  current_setting('t.a2'), current_setting('t.v1')), '42501', '20 : pas sur un autre établissement');

-- ------------------------------------------------------------- serveur W
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000d004","role":"authenticated"}';
select zz_tests.expect((select count(*) from public.prices where branch_id = current_setting('t.a1')::uuid and valid_to is null) >= 2,
  '21 : un serveur lit les prix de son établissement');
select zz_tests.expect_error(format($q$select public.set_price(%L, %L, null, 'default', 1)$q$,
  current_setting('t.a1'), current_setting('t.v1')), '42501', '22 : un serveur ne change pas les prix');
select zz_tests.expect(zz_tests.rows(format($q$update public.menu_item_branches set available = true where item_id = %L$q$,
  current_setting('t.item'))) = 0, '23 : un serveur ne change pas la disponibilité');

-- ------------------------------------------------------------- autre organisation B
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000b004","role":"authenticated"}';
select set_config('t.b', public.create_organization('Menu B', 'FR', 'EUR', 'fr', 'Europe/Paris', 'Paris')::text, true);
select zz_tests.expect((select count(*) from public.menu_categories) = 0 and (select count(*) from public.menu_items) = 0
  and (select count(*) from public.prices) = 0 and (select count(*) from public.modifiers) = 0,
  '24 : B ne voit rien du menu de A');
select zz_tests.expect_error(format($q$select public.set_price(%L, %L, null, 'default', 1)$q$,
  current_setting('t.a1'), current_setting('t.v1')), '42501', '25 : B ne fixe pas de prix chez A');
select zz_tests.expect_error(format($q$insert into public.menu_item_branches (organization_id, brand_id, item_id, branch_id) values (%L, %L, %L, %L)$q$,
  current_setting('t.b')::jsonb ->> 'organization_id', current_setting('t.b')::jsonb ->> 'brand_id',
  current_setting('t.item'), current_setting('t.b')::jsonb ->> 'branch_id'),
  '23503', '26 : B ne propose pas un article de A dans son établissement');
select zz_tests.expect_error(format($q$select public.create_menu_item(%L, 'Pirate')$q$, current_setting('t.cat')),
  '42501', '27 : B ne crée pas d''article dans le menu de A');

reset role;
rollback;
select 'TOUS LES CONTRÔLES 004 SONT PASSÉS (27)' as resultat;
