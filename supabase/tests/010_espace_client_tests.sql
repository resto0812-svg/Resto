-- =============================================================================
-- Resto — contrôles de la migration 010 (espace client).
-- À coller APRÈS 010. Transaction annulée à la fin : aucune donnée ne reste.
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
  ('00000000-0000-0000-0000-00000000a011', 'owner.a11@resto.test', 'authenticated', 'authenticated', '{}', now()),
  ('00000000-0000-0000-0000-00000000c011', 'client.c11@resto.test', 'authenticated', 'authenticated', '{"display_name":"Aïcha Mbarga"}', now()),
  ('00000000-0000-0000-0000-00000000d011', 'client.d11@resto.test', 'authenticated', 'authenticated', '{}', now()),
  ('00000000-0000-0000-0000-00000000b011', 'owner.b11@resto.test', 'authenticated', 'authenticated', '{}', now());

set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000a011","role":"authenticated"}';
select set_config('t.a', public.create_organization('Le Bon Goût', 'CM', 'XAF', 'fr', 'Africa/Douala', 'Douala', null, 'Akwa')::text, true);
select set_config('t.org', current_setting('t.a')::jsonb ->> 'organization_id', true);
select set_config('t.brand', current_setting('t.a')::jsonb ->> 'brand_id', true);
select set_config('t.a1', current_setting('t.a')::jsonb ->> 'branch_id', true);
update public.brands set cuisines = array['camerounaise', 'grillades'], description = 'Cuisine maison' where id = current_setting('t.brand')::uuid;
update public.branches set is_published = true, accepts_online_orders = true, accepts_delivery = true, delivery_fee_minor = 500
 where id = current_setting('t.a1')::uuid;
with ins as (insert into public.branches (organization_id, brand_id, name, slug, country_code, city, timezone, currency, default_locale)
  values (current_setting('t.org')::uuid, current_setting('t.brand')::uuid, 'Caché', 'cache', 'CM', 'Douala', 'Africa/Douala', 'XAF', 'fr')
  returning id)
select set_config('t.hidden', (select id::text from ins), true);

with ins as (insert into public.menu_categories (organization_id, brand_id, name)
  values (current_setting('t.org')::uuid, current_setting('t.brand')::uuid, 'Plats') returning id)
select set_config('t.cat', (select id::text from ins), true);
select set_config('t.item', public.create_menu_item(current_setting('t.cat')::uuid, 'Poulet DG')::text, true);
select set_config('t.var', (select id::text from public.item_variants where item_id = current_setting('t.item')::uuid), true);
insert into public.menu_item_branches (organization_id, brand_id, item_id, branch_id)
values (current_setting('t.org')::uuid, current_setting('t.brand')::uuid, current_setting('t.item')::uuid, current_setting('t.a1')::uuid);
select public.set_price(current_setting('t.a1')::uuid, current_setting('t.var')::uuid, null, 'default', 5000);
with ins as (insert into public.service_areas (organization_id, branch_id, name)
  values (current_setting('t.org')::uuid, current_setting('t.a1')::uuid, 'Salle') returning id)
select set_config('t.area', (select id::text from ins), true);
insert into public.dining_tables (organization_id, branch_id, service_area_id, label)
values (current_setting('t.org')::uuid, current_setting('t.a1')::uuid, current_setting('t.area')::uuid, 'T1');
select set_config('t.token', (select qr_token from public.dining_tables where branch_id = current_setting('t.a1')::uuid), true);
select zz_tests.expect(length(current_setting('t.token')) = 32, '1 : chaque table a un jeton de QR code aléatoire');
select zz_tests.expect_error(format($q$update public.menu_items set image_path = %L where id = %L$q$,
  gen_random_uuid()::text || '/' || current_setting('t.item') || '/x.jpg', current_setting('t.item')),
  'resto.invalid_image', '2 : photo hors du dossier de l''organisation refusée');

-- ------------------------------------------------------------- visiteur sans compte
set local role anon;
select zz_tests.expect((select count(*) from public.public_search_branches('grillades')) = 1
  and (select count(*) from public.public_search_branches('poulet')) = 1
  and not exists (select 1 from public.public_search_branches(null) where branch_id = current_setting('t.hidden')::uuid),
  '3 : recherche publique (cuisine, plat) ; un établissement non publié n''apparaît pas');
select zz_tests.expect((public.public_branch_menu(current_setting('t.a1')::uuid) -> 'categories' -> 0 -> 'items' -> 0
    -> 'variants' -> 0 -> 'prices' ->> 'default')::bigint = 5000, '4 : carte publique avec prix, sans compte');
select zz_tests.expect_error(format($q$select public.public_branch_menu(%L)$q$, current_setting('t.hidden')),
  'resto.not_found', '5 : carte d''un établissement non publié : introuvable');
select zz_tests.expect((public.public_table(current_setting('t.token')) ->> 'label') = 'T1', '6 : le QR code mène à la bonne table');
select zz_tests.expect_error(format($q$select public.place_online_order(%L, 'takeaway', '[]'::jsonb)$q$, current_setting('t.a1')),
  '42501', '7 : commander exige un compte');
select zz_tests.expect_error($q$select count(*) from public.orders$q$, '42501', '8 : un visiteur ne lit aucune commande');

-- ------------------------------------------------------------- client C
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000c011","role":"authenticated"}';
select set_config('t.o1', public.place_online_order(current_setting('t.a1')::uuid, 'takeaway',
  jsonb_build_array(jsonb_build_object('variant_id', current_setting('t.var'), 'quantity', 2)))::text, true);
select set_config('t.o1id', current_setting('t.o1')::jsonb ->> 'order_id', true);
select zz_tests.expect((select acceptance from public.orders where id = current_setting('t.o1id')::uuid) = 'pending'
  and (select total_minor from public.orders where id = current_setting('t.o1id')::uuid) = 10000
  and (select count(*) from public.order_items where order_id = current_setting('t.o1id')::uuid
         and added_via = 'customer' and prep_status = 'pending') = 1,
  '9 : commande à emporter en attente d''acceptation, prix fixé par le serveur, visible par le client');
select zz_tests.expect((select brand_name from public.my_customer_orders()) = 'Le Bon Goût', '10 : « Mes commandes » avec le restaurant');
select set_config('t.o2', public.place_online_order(current_setting('t.a1')::uuid, 'delivery',
  jsonb_build_array(jsonb_build_object('variant_id', current_setting('t.var'), 'quantity', 1)), null, null,
  'Rue de la Joie, Akwa', 'portail bleu', '+237 690000000', 'Aïcha')::text, true);
select zz_tests.expect((select total_minor from public.orders where id = (current_setting('t.o2')::jsonb ->> 'order_id')::uuid) = 5500,
  '11 : livraison : frais de 500 ajoutés au total');
select zz_tests.expect_error(format($q$select public.place_online_order(%L, 'delivery', %L::jsonb)$q$, current_setting('t.a1'),
  jsonb_build_array(jsonb_build_object('variant_id', current_setting('t.var')))::text),
  'resto.delivery_unavailable', '12 : livraison sans adresse ni téléphone refusée');
select set_config('t.q1', public.place_online_order(current_setting('t.a1')::uuid, 'dine_in',
  jsonb_build_array(jsonb_build_object('variant_id', current_setting('t.var'))), current_setting('t.token'))::text, true);
select set_config('t.q2', public.place_online_order(current_setting('t.a1')::uuid, 'dine_in',
  jsonb_build_array(jsonb_build_object('variant_id', current_setting('t.var'))), current_setting('t.token'))::text, true);
select zz_tests.expect((current_setting('t.q1')::jsonb ->> 'order_id') = (current_setting('t.q2')::jsonb ->> 'order_id')
  and (select count(*) from public.order_items where order_id = (current_setting('t.q1')::jsonb ->> 'order_id')::uuid) = 2,
  '13 : QR à table : les articles rejoignent la commande en cours de la table');
select zz_tests.expect_error(format($q$select public.place_online_order(%L, 'dine_in', %L::jsonb, 'jeton-faux')$q$, current_setting('t.a1'),
  jsonb_build_array(jsonb_build_object('variant_id', current_setting('t.var')))::text), 'resto.invalid_table', '14 : faux QR code refusé');
select set_config('t.o3', public.place_online_order(current_setting('t.a1')::uuid, 'takeaway',
  jsonb_build_array(jsonb_build_object('variant_id', current_setting('t.var'))))::text, true);
select public.customer_cancel_order((current_setting('t.o3')::jsonb ->> 'order_id')::uuid);
select zz_tests.expect((select status from public.orders where id = (current_setting('t.o3')::jsonb ->> 'order_id')::uuid) = 'cancelled',
  '15 : le client annule tant que le restaurant n''a pas accepté');

-- ------------------------------------------------------------- client D
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000d011","role":"authenticated"}';
select zz_tests.expect((select count(*) from public.orders) = 0 and (select count(*) from public.my_customer_orders()) = 0,
  '16 : un client ne voit pas les commandes des autres');
select zz_tests.expect_error(format($q$select public.customer_cancel_order(%L)$q$, current_setting('t.o1id')),
  '42501', '17 : ni ne les annule');

-- ------------------------------------------------------------- restaurant A : acceptation / refus
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000a011","role":"authenticated"}';
select public.accept_online_order(current_setting('t.o1id')::uuid);
select zz_tests.expect((select acceptance from public.orders where id = current_setting('t.o1id')::uuid) = 'accepted'
  and not exists (select 1 from public.order_items where order_id = current_setting('t.o1id')::uuid and prep_status = 'pending'),
  '18 : acceptée par le restaurant : les articles partent en cuisine');
select public.reject_online_order((current_setting('t.o2')::jsonb ->> 'order_id')::uuid, 'livreur indisponible');
select zz_tests.expect((select status from public.orders where id = (current_setting('t.o2')::jsonb ->> 'order_id')::uuid) = 'cancelled'
  and (select reject_reason from public.orders where id = (current_setting('t.o2')::jsonb ->> 'order_id')::uuid) = 'livreur indisponible',
  '19 : refusée avec motif : la commande est annulée');
select set_config('t.reg', (select id::text from public.cash_registers where branch_id = current_setting('t.a1')::uuid), true);
select set_config('t.sess', public.open_cash_session(current_setting('t.reg')::uuid, 0)::text, true);
select public.record_payment(current_setting('t.o1id')::uuid, current_setting('t.sess')::uuid, 'cash', 10000);

-- ------------------------------------------------------------- client C : avis
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000c011","role":"authenticated"}';
select zz_tests.expect_error(format($q$select public.customer_cancel_order(%L)$q$, current_setting('t.o1id')),
  'resto.too_late_to_cancel', '20 : trop tard pour annuler une commande acceptée');
select public.submit_review(current_setting('t.o1id')::uuid, 5::smallint, 'Excellent poulet DG');
select zz_tests.expect_error(format($q$select public.submit_review(%L, 4::smallint)$q$, current_setting('t.o1id')),
  'resto.review_not_allowed', '21 : un seul avis par commande');
select zz_tests.expect_error(format($q$select public.submit_review(%L, 4::smallint)$q$, current_setting('t.q1')::jsonb ->> 'order_id'),
  'resto.review_not_allowed', '22 : pas d''avis sur une commande non payée');

set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000d011","role":"authenticated"}';
select zz_tests.expect_error(format($q$select public.submit_review(%L, 1::smallint)$q$, current_setting('t.o1id')),
  '42501', '23 : un avis seulement sur sa propre commande');

set local role anon;
select zz_tests.expect((select author from public.public_reviews(current_setting('t.a1')::uuid)) = 'Aïcha'
  and (select rating from public.public_search_branches('grillades')) = 5,
  '24 : avis public (prénom seul) et note moyenne dans la recherche');

-- ------------------------------------------------------------- autre organisation B
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000b011","role":"authenticated"}';
select public.create_organization('Autre', 'CM', 'XAF', 'fr', 'Africa/Douala', 'Yaoundé');
select zz_tests.expect_error(format($q$select public.accept_online_order(%L)$q$, current_setting('t.q1')::jsonb ->> 'order_id'),
  '42501', '25 : B n''accepte pas les commandes de A');

set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000a011","role":"authenticated"}';
update public.branches set accepts_online_orders = false where id = current_setting('t.a1')::uuid;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000c011","role":"authenticated"}';
select zz_tests.expect_error(format($q$select public.place_online_order(%L, 'takeaway', %L::jsonb)$q$, current_setting('t.a1'),
  jsonb_build_array(jsonb_build_object('variant_id', current_setting('t.var')))::text),
  'resto.online_orders_closed', '26 : commandes en ligne désactivées : refusées');

reset role;
rollback;
select 'TOUS LES CONTRÔLES 010 SONT PASSÉS (26)' as resultat;
