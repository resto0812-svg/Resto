-- =============================================================================
-- Resto — contrôles de la migration 018 (profil, préférences, médias et stock
-- des articles, duplication, publicité, tableau de bord).
-- À coller APRÈS 018. Transaction annulée à la fin : aucune donnée ne reste.
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

-- A = propriétaire, K = caissier, B = autre organisation
insert into auth.users (id, email, aud, role, raw_user_meta_data, email_confirmed_at) values
  ('00000000-0000-0000-0000-00000000a018', 'owner.a18@resto.test', 'authenticated', 'authenticated', '{}', now()),
  ('00000000-0000-0000-0000-00000000c018', 'cashier.k18@resto.test', 'authenticated', 'authenticated', '{}', now()),
  ('00000000-0000-0000-0000-00000000b018', 'owner.b18@resto.test', 'authenticated', 'authenticated', '{}', now());

set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000a018","role":"authenticated"}';
select set_config('t.a', public.create_organization('Vitrine A', 'CM', 'XAF', 'fr', 'Africa/Douala', 'Douala', null, 'A1')::text, true);
select set_config('t.org', current_setting('t.a')::jsonb ->> 'organization_id', true);
select set_config('t.brand', current_setting('t.a')::jsonb ->> 'brand_id', true);
select set_config('t.a1', current_setting('t.a')::jsonb ->> 'branch_id', true);
with ins as (insert into public.menu_categories (organization_id, brand_id, name)
  values (current_setting('t.org')::uuid, current_setting('t.brand')::uuid, 'Carte') returning id)
select set_config('t.cat', (select id::text from ins), true);
select set_config('t.item', public.create_menu_item(current_setting('t.cat')::uuid, 'Ndolé', null, 'food')::text, true);
select set_config('t.var', (select id::text from public.item_variants where item_id = current_setting('t.item')::uuid), true);
insert into public.menu_item_branches (organization_id, brand_id, item_id, branch_id)
values (current_setting('t.org')::uuid, current_setting('t.brand')::uuid, current_setting('t.item')::uuid, current_setting('t.a1')::uuid);
select public.set_price(current_setting('t.a1')::uuid, current_setting('t.var')::uuid, null, 'default', 4000);
select set_config('t.reg', (select id::text from public.cash_registers where branch_id = current_setting('t.a1')::uuid), true);
select set_config('t.cash', (select id::text from public.payment_methods where organization_id = current_setting('t.org')::uuid and ref_code = 'cash'), true);

-- ------------------------------------------------------------- profil, préférences
update public.branches set registration_number = 'RC/DLA/2026/B/1', whatsapp = '+237 600 00 00 00',
       latitude = 4.0511, longitude = 9.7679, delivery_zone = 'Akwa, Bonanjo', vacation_mode = true
 where id = current_setting('t.a1')::uuid;
update public.brands set slogan = 'Cuisine raffinée' where id = current_setting('t.brand')::uuid;
select zz_tests.expect((select registration_number = 'RC/DLA/2026/B/1' and vacation_mode and latitude = 4.0511
                          from public.branches where id = current_setting('t.a1')::uuid)
  and (select slogan from public.brands where id = current_setting('t.brand')::uuid) = 'Cuisine raffinée',
  '1 : profil de l''établissement enregistré (immatriculation, GPS, zone, vacances, slogan)');
select zz_tests.expect_error(format($q$update public.branches set latitude = 120 where id = %L$q$, current_setting('t.a1')),
  '23514', '2 : latitude impossible refusée');
update public.branches set vacation_mode = false where id = current_setting('t.a1')::uuid;
insert into public.member_preferences (organization_id, prefs)
values (current_setting('t.org')::uuid, '{"sound_new_order": true}');

-- ------------------------------------------------------------- familles, médias
select set_config('t.menu', public.create_menu_item(current_setting('t.cat')::uuid, 'Formule midi', null, 'menu')::text, true);
select zz_tests.expect((select kind from public.menu_items where id = current_setting('t.menu')::uuid) = 'menu',
  '3 : famille « formule » acceptée');
select zz_tests.expect_error(format($q$update public.menu_items set gallery_paths = array['00000000-0000-0000-0000-000000000000/x/y.jpg'] where id = %L$q$,
  current_setting('t.item')), 'resto.invalid_image', '4 : photo hors du dossier de l''article refusée');
update public.menu_items set gallery_paths = array[current_setting('t.org') || '/' || current_setting('t.item') || '/g1.jpg'],
       prep_minutes = 25, available_days = '{1,2,3,4,5}' where id = current_setting('t.item')::uuid;

-- ------------------------------------------------------------- stock du jour
update public.menu_item_branches set stock_qty = 3 where item_id = current_setting('t.item')::uuid;
select set_config('t.s', public.open_cash_session(current_setting('t.reg')::uuid, 0)::text, true);
select set_config('t.o1', public.create_order(current_setting('t.a1')::uuid, 'takeaway')::text, true);
select set_config('t.l1', public.add_order_item(current_setting('t.o1')::uuid, current_setting('t.var')::uuid, 2)::text, true);
select set_config('t.l2', public.add_order_item(current_setting('t.o1')::uuid, current_setting('t.var')::uuid, 1)::text, true);
select zz_tests.expect((select stock_qty = 0 and not available from public.menu_item_branches
                          where item_id = current_setting('t.item')::uuid),
  '5 : stock décompté à la commande, rupture automatique à zéro');
select zz_tests.expect_error(format($q$select public.add_order_item(%L, %L, 1)$q$, current_setting('t.o1'), current_setting('t.var')),
  'resto.item_unavailable', '6 : article en rupture refusé');
select public.remove_order_item(current_setting('t.l2')::uuid);
select zz_tests.expect((select stock_qty = 1 and available from public.menu_item_branches
                          where item_id = current_setting('t.item')::uuid),
  '7 : ligne retirée : stock rendu, article de nouveau disponible');
select public.send_order(current_setting('t.o1')::uuid);
select public.cancel_order_item(current_setting('t.l1')::uuid, 'client parti');
select zz_tests.expect((select stock_qty from public.menu_item_branches where item_id = current_setting('t.item')::uuid) = 3,
  '8 : ligne annulée après envoi : stock rendu');

-- ------------------------------------------------------------- duplication
select set_config('t.copy', public.duplicate_menu_item(current_setting('t.item')::uuid, ' (copie)')::text, true);
select zz_tests.expect((select name = 'Ndolé (copie)' and not active and prep_minutes = 25
                          from public.menu_items where id = current_setting('t.copy')::uuid)
  and (select p.amount_minor from public.prices p join public.item_variants v on v.id = p.variant_id
        where v.item_id = current_setting('t.copy')::uuid and p.valid_to is null) = 4000,
  '9 : article dupliqué (masqué) avec ses tailles et ses prix');

-- ------------------------------------------------------------- publicité
with ins as (
  insert into public.ad_campaigns (organization_id, brand_id, format, title, media, starts_at, status)
  values (current_setting('t.org')::uuid, current_setting('t.brand')::uuid, 'story', 'Eru du week-end',
          jsonb_build_array(jsonb_build_object('kind', 'image', 'path', current_setting('t.org') || '/story.jpg')),
          '2026-10-10 12:00+00', 'draft')
  returning id)
select set_config('t.story', (select id::text from ins), true);
select zz_tests.expect((select ends_at = starts_at + interval '24 hours' from public.ad_campaigns
                          where id = current_setting('t.story')::uuid),
  '10 : story limitée à 24 heures');
select zz_tests.expect_error(format($q$insert into public.ad_campaigns (organization_id, brand_id, format, title, status)
  values (%L, %L, 'video', 'Sans vidéo', 'active')$q$, current_setting('t.org'), current_setting('t.brand')),
  'resto.media_required', '11 : vidéo publiée sans vidéo refusée');
with ins as (
  insert into public.ad_campaigns (organization_id, brand_id, format, title, body, status, item_ids)
  values (current_setting('t.org')::uuid, current_setting('t.brand')::uuid, 'sponsored_menu', 'Ndolé à l''honneur',
          'Le vrai goût de chez nous', 'active', array[current_setting('t.item')::uuid])
  returning id)
select set_config('t.ad', (select id::text from ins), true);
select zz_tests.expect_error(format($q$update public.ad_campaigns set views = 9999 where id = %L$q$, current_setting('t.ad')),
  '42501', '12 : statistiques non modifiables à la main');

-- Commande issue de la campagne, payée : comptée dans ses statistiques.
select set_config('t.o2', public.create_order(current_setting('t.a1')::uuid, 'takeaway')::text, true);
select public.add_order_item(current_setting('t.o2')::uuid, current_setting('t.var')::uuid, 1);
select public.send_order(current_setting('t.o2')::uuid);
reset role;
update public.orders set ad_campaign_id = current_setting('t.ad')::uuid where id = current_setting('t.o2')::uuid;
update public.branches set is_published = true where id = current_setting('t.a1')::uuid;
set local role authenticated;
select public.take_payment(current_setting('t.o2')::uuid, current_setting('t.s')::uuid, current_setting('t.cash')::uuid, 4000);
select zz_tests.expect((select orders = 1 and revenue_minor = 4000 from public.ad_campaigns where id = current_setting('t.ad')::uuid),
  '13 : commande issue d''une publicité comptée (commandes, chiffre d''affaires)');

-- ------------------------------------------------------------- tableau de bord
select set_config('t.d', public.branch_dashboard(current_setting('t.a1')::uuid, current_date - 30, current_date + 1)::text, true);
select zz_tests.expect((current_setting('t.d')::jsonb ->> 'sales')::bigint = 4000
  and (current_setting('t.d')::jsonb -> 'top_items' -> 0 ->> 'name') = 'Ndolé'
  and jsonb_array_length(current_setting('t.d')::jsonb -> 'recent') = 1,
  '14 : tableau de bord : ventes, meilleurs plats, dernières transactions');

-- ------------------------------------------------------------- public
set local role anon;
select public.record_ad_event(current_setting('t.ad')::uuid, 'view');
select zz_tests.expect(jsonb_array_length(public.public_ads()) >= 1, '15 : campagne en cours visible du public');
set local role authenticated;
select zz_tests.expect((select views from public.ad_campaigns where id = current_setting('t.ad')::uuid) = 1,
  '16 : vue enregistrée depuis l''espace client');

-- ------------------------------------------------------------- caissier K
reset role;
insert into public.memberships (organization_id, user_id, role_code, all_branches) values
  (current_setting('t.org')::uuid, '00000000-0000-0000-0000-00000000c018', 'cashier', false);
insert into public.membership_branches (organization_id, membership_id, branch_id)
select m.organization_id, m.id, current_setting('t.a1')::uuid from public.memberships m
 where m.user_id = '00000000-0000-0000-0000-00000000c018';
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000c018","role":"authenticated"}';
select zz_tests.expect((select count(*) from public.member_preferences) = 0,
  '17 : les préférences d''un membre restent privées');
select zz_tests.expect_error(format($q$select public.duplicate_menu_item(%L)$q$, current_setting('t.item')),
  '42501', '18 : un caissier ne duplique pas un article');
select zz_tests.expect_error(format($q$insert into public.ad_campaigns (organization_id, brand_id, format, title)
  values (%L, %L, 'classified', 'Pirate')$q$, current_setting('t.org'), current_setting('t.brand')),
  '42501', '19 : un caissier ne crée pas de publicité');
select zz_tests.expect((public.branch_dashboard(current_setting('t.a1')::uuid, current_date, current_date) -> 'sales') is null,
  '20 : sans droit financier, le tableau de bord ne montre pas le chiffre d''affaires');

-- ------------------------------------------------------------- autre organisation B
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000b018","role":"authenticated"}';
select public.create_organization('Vitrine B', 'CM', 'XAF', 'fr', 'Africa/Douala', 'Yaoundé');
select zz_tests.expect((select count(*) from public.ad_campaigns) = 0, '21 : B ne voit pas les campagnes de A');
select zz_tests.expect_error(format($q$select public.branch_dashboard(%L, current_date, current_date)$q$, current_setting('t.a1')),
  '42501', '22 : B ne lit pas le tableau de bord de A');

reset role;
rollback;
select 'TOUS LES CONTRÔLES 018 SONT PASSÉS (22)' as resultat;
