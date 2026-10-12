-- =============================================================================
-- Resto — contrôles de la migration 015 (caisse professionnelle).
-- À coller APRÈS 015. Transaction annulée à la fin : aucune donnée ne reste.
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

-- A = propriétaire (Cameroun), K = caissier, B = autre organisation (États-Unis, anglais)
insert into auth.users (id, email, aud, role, raw_user_meta_data, email_confirmed_at) values
  ('00000000-0000-0000-0000-00000000a015', 'owner.a15@resto.test', 'authenticated', 'authenticated', '{}', now()),
  ('00000000-0000-0000-0000-00000000c015', 'cashier.k15@resto.test', 'authenticated', 'authenticated', '{}', now()),
  ('00000000-0000-0000-0000-00000000b015', 'owner.b15@resto.test', 'authenticated', 'authenticated', '{}', now());

set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000a015","role":"authenticated"}';
select set_config('t.a', public.create_organization('Caisse A', 'CM', 'XAF', 'fr', 'Africa/Douala', 'Douala', null, 'A1')::text, true);
select set_config('t.org', current_setting('t.a')::jsonb ->> 'organization_id', true);
select set_config('t.brand', current_setting('t.a')::jsonb ->> 'brand_id', true);
select set_config('t.a1', current_setting('t.a')::jsonb ->> 'branch_id', true);
select zz_tests.expect((select count(*) from public.payment_methods
    where organization_id = current_setting('t.org')::uuid and ref_code in ('cash', 'card', 'mtn_momo', 'orange_money')) = 4
  and not exists (select 1 from public.payment_methods where organization_id = current_setting('t.org')::uuid and ref_code = 'pix')
  and (select name from public.payment_methods where organization_id = current_setting('t.org')::uuid and ref_code = 'cash') = 'Espèces',
  '1 : modes du pays proposés d''office (Cameroun), noms dans la langue de l''organisation');
select set_config('t.cash', (select id::text from public.payment_methods where organization_id = current_setting('t.org')::uuid and ref_code = 'cash'), true);
select set_config('t.card', (select id::text from public.payment_methods where organization_id = current_setting('t.org')::uuid and ref_code = 'card'), true);
select set_config('t.momo', (select id::text from public.payment_methods where organization_id = current_setting('t.org')::uuid and ref_code = 'mtn_momo'), true);

with ins as (insert into public.payment_methods (organization_id, name, kind, requires_reference, fee_percent)
  values (current_setting('t.org')::uuid, 'Bon maison', 'voucher', true, 0) returning id)
select set_config('t.bon', (select id::text from ins), true);
select zz_tests.expect((select kind = 'voucher' and requires_reference from public.payment_methods where id = current_setting('t.bon')::uuid),
  '2 : l''organisation crée ses propres modes (nom libre, référence obligatoire)');

with ins as (insert into public.menu_categories (organization_id, brand_id, name)
  values (current_setting('t.org')::uuid, current_setting('t.brand')::uuid, 'Carte') returning id)
select set_config('t.cat', (select id::text from ins), true);
select set_config('t.item', public.create_menu_item(current_setting('t.cat')::uuid, 'Poulet DG', null, 'food')::text, true);
select set_config('t.var', (select id::text from public.item_variants where item_id = current_setting('t.item')::uuid), true);
insert into public.menu_item_branches (organization_id, brand_id, item_id, branch_id)
values (current_setting('t.org')::uuid, current_setting('t.brand')::uuid, current_setting('t.item')::uuid, current_setting('t.a1')::uuid);
select public.set_price(current_setting('t.a1')::uuid, current_setting('t.var')::uuid, null, 'default', 4000);
select set_config('t.reg', (select id::text from public.cash_registers where branch_id = current_setting('t.a1')::uuid), true);

reset role;
insert into public.memberships (organization_id, user_id, role_code, all_branches) values
  (current_setting('t.org')::uuid, '00000000-0000-0000-0000-00000000c015', 'cashier', false);
insert into public.membership_branches (organization_id, membership_id, branch_id)
select m.organization_id, m.id, current_setting('t.a1')::uuid from public.memberships m
 where m.user_id = '00000000-0000-0000-0000-00000000c015';
set local role anon;
select zz_tests.expect((select count(*) from public.ref_currency_denominations where currency = 'XAF') >= 8
  and (select count(*) from public.ref_payment_methods where code = 'pix' and 'BR' = any (countries)) = 1,
  '3 : catalogue des modes et coupures des monnaies lisibles par tous');
set local role authenticated;

-- ------------------------------------------------------------- caissier K
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000c015","role":"authenticated"}';
select zz_tests.expect_error(format($q$insert into public.payment_methods (organization_id, name, kind)
  values (%L, 'Pirate', 'other')$q$, current_setting('t.org')), '42501', '4 : un caissier ne crée pas de mode de paiement');
select zz_tests.expect_error(format($q$select public.open_cash_session(%L, 15000, null, '{"10000":1}'::jsonb)$q$, current_setting('t.reg')),
  'resto.invalid_amount', '5 : fond de caisse : le détail des coupures doit correspondre au montant');
select set_config('t.s1', public.open_cash_session(current_setting('t.reg')::uuid, 15000, null, '{"10000":1,"5000":1}'::jsonb)::text, true);
select zz_tests.expect((select opening_detail ->> '5000' from public.cash_sessions where id = current_setting('t.s1')::uuid) = '1',
  '6 : fond compté billet par billet, détail conservé');

select set_config('t.o1', public.create_order(current_setting('t.a1')::uuid, 'takeaway')::text, true);
select public.add_order_item(current_setting('t.o1')::uuid, current_setting('t.var')::uuid, 1);
select public.send_order(current_setting('t.o1')::uuid);
select set_config('t.c1', gen_random_uuid()::text, true);
select set_config('t.p1', public.take_payment(current_setting('t.o1')::uuid, current_setting('t.s1')::uuid,
  current_setting('t.cash')::uuid, 4000, 500, 5000, null, current_setting('t.c1')::uuid)::text, true);
select zz_tests.expect((current_setting('t.p1')::jsonb ->> 'change')::bigint = 500
  and (current_setting('t.p1')::jsonb ->> 'closed')::boolean
  and (current_setting('t.p1')::jsonb ->> 'receipt_number')::bigint = 1
  and (select total_minor = 4000 and paid_minor = 4000 from public.orders where id = current_setting('t.o1')::uuid),
  '7 : espèces 5 000 pour 4 000 + 500 de pourboire : 500 rendus, ticket n° 1, pourboire hors chiffre d''affaires');
select zz_tests.expect(public.take_payment(current_setting('t.o1')::uuid, current_setting('t.s1')::uuid,
  current_setting('t.cash')::uuid, 4000, 500, 5000, null, current_setting('t.c1')::uuid) ->> 'payment_id'
  = current_setting('t.p1')::jsonb ->> 'payment_id', '8 : paiement rejoué : aucun doublon');
select zz_tests.expect((public.cash_session_summary(current_setting('t.s1')::uuid) ->> 'expected_cash')::bigint = 19500,
  '9 : espèces attendues = fond + encaissement + pourboire en espèces');

select set_config('t.o2', public.create_order(current_setting('t.a1')::uuid, 'takeaway')::text, true);
select public.add_order_item(current_setting('t.o2')::uuid, current_setting('t.var')::uuid, 1);
select public.send_order(current_setting('t.o2')::uuid);
select zz_tests.expect_error(format($q$select public.take_payment(%L, %L, %L, 4000)$q$, current_setting('t.o2'),
  current_setting('t.s1'), current_setting('t.momo')), 'resto.reference_required', '10 : Mobile Money sans n° de transaction refusé');
select zz_tests.expect_error(format($q$select public.take_payment(%L, %L, %L, 4000, 0, 5000)$q$, current_setting('t.o2'),
  current_setting('t.s1'), current_setting('t.card')), 'resto.invalid_payment', '11 : somme remise seulement pour les espèces');

-- ------------------------------------------------------------- autre organisation B (États-Unis, anglais)
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000b015","role":"authenticated"}';
select set_config('t.b', public.create_organization('Diner B', 'US', 'USD', 'en', 'America/New_York', 'New York')::text, true);
select set_config('t.borg', current_setting('t.b')::jsonb ->> 'organization_id', true);
select zz_tests.expect((select name from public.payment_methods where organization_id = current_setting('t.borg')::uuid and ref_code = 'cash') = 'Cash'
  and not exists (select 1 from public.payment_methods where organization_id = current_setting('t.borg')::uuid and ref_code = 'mtn_momo'),
  '12 : aux États-Unis : modes en anglais, pas de Mobile Money africain');
select set_config('t.bcash', (select id::text from public.payment_methods where organization_id = current_setting('t.borg')::uuid and ref_code = 'cash'), true);
select zz_tests.expect((select count(*) from public.staff_directory(current_setting('t.org')::uuid)) = 0,
  '13 : B ne voit pas l''équipe de A');
select zz_tests.expect_error(format($q$select public.cash_report(%L, current_date, current_date)$q$, current_setting('t.a1')),
  '42501', '14 : B ne lit pas le rapport de caisse de A');

-- ------------------------------------------------------------- caissier K
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000c015","role":"authenticated"}';
select zz_tests.expect_error(format($q$select public.take_payment(%L, %L, %L, 4000)$q$, current_setting('t.o2'),
  current_setting('t.s1'), current_setting('t.bcash')), 'resto.payment_method_unavailable', '15 : mode d''une autre organisation refusé');
select set_config('t.p2', public.take_payment(current_setting('t.o2')::uuid, current_setting('t.s1')::uuid,
  current_setting('t.momo')::uuid, 4000, 0, null, 'TX-889911')::text, true);
select zz_tests.expect((current_setting('t.p2')::jsonb ->> 'receipt_number')::bigint = 2
  and (select method = 'mobile_wallet' and reference = 'TX-889911' from public.payments
        where id = (current_setting('t.p2')::jsonb ->> 'payment_id')::uuid),
  '16 : Mobile Money avec n° de transaction ; ticket n° 2');
select zz_tests.expect((public.cash_session_summary(current_setting('t.s1')::uuid) ->> 'tips')::bigint = 500
  and (public.cash_session_summary(current_setting('t.s1')::uuid) ->> 'collected')::bigint = 8000
  and jsonb_array_length(public.cash_session_summary(current_setting('t.s1')::uuid) -> 'by_method') = 2,
  '17 : résumé de session : encaissé 8 000, pourboires 500 à part, détail par mode');
select zz_tests.expect_error(format($q$select public.count_cash_session(%L, 19500, null, '{"10000":2}'::jsonb)$q$, current_setting('t.s1')),
  'resto.invalid_amount', '18 : comptage : détail incohérent refusé');
select zz_tests.expect((public.count_cash_session(current_setting('t.s1')::uuid, 19500, null,
  '{"10000":1,"5000":1,"2000":2,"500":1}'::jsonb) ->> 'difference')::bigint = 0, '19 : comptage par coupures, aucun écart');
select zz_tests.expect_error(format($q$select public.validate_cash_session(%L)$q$, current_setting('t.s1')),
  '42501', '20 : un caissier ne valide pas la clôture');
select zz_tests.expect_error(format($q$select public.cash_report(%L, current_date, current_date)$q$, current_setting('t.a1')),
  '42501', '21 : un caissier ne lit pas le rapport de caisse');

-- ------------------------------------------------------------- propriétaire A
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000a015","role":"authenticated"}';
select public.validate_cash_session(current_setting('t.s1')::uuid);
select set_config('t.s2', public.open_cash_session(current_setting('t.reg')::uuid, 0)::text, true);
select public.count_cash_session(current_setting('t.s2')::uuid, 0);
select public.validate_cash_session(current_setting('t.s2')::uuid);
select zz_tests.expect((select z_number from public.cash_sessions where id = current_setting('t.s1')::uuid) = 1
  and (select z_number from public.cash_sessions where id = current_setting('t.s2')::uuid) = 2,
  '22 : Z de caisse numérotés à la validation (1, 2…)');
update public.payment_methods set active = false where id = current_setting('t.card')::uuid;
select set_config('t.s3', public.open_cash_session(current_setting('t.reg')::uuid, 0)::text, true);
select set_config('t.o3', public.create_order(current_setting('t.a1')::uuid, 'takeaway')::text, true);
select public.add_order_item(current_setting('t.o3')::uuid, current_setting('t.var')::uuid, 1);
select zz_tests.expect_error(format($q$select public.take_payment(%L, %L, %L, 4000)$q$, current_setting('t.o3'),
  current_setting('t.s3'), current_setting('t.card')), 'resto.payment_method_unavailable', '23 : mode désactivé refusé');
select zz_tests.expect((public.cash_report(current_setting('t.a1')::uuid, current_date - 1, current_date + 1) ->> 'tips')::bigint = 500
  and (public.cash_report(current_setting('t.a1')::uuid, current_date - 1, current_date + 1) ->> 'collected')::bigint = 8000
  and (public.cash_report(current_setting('t.a1')::uuid, current_date - 1, current_date + 1) ->> 'sales_total')::bigint = 8000
  and jsonb_array_length(public.cash_report(current_setting('t.a1')::uuid, current_date - 1, current_date + 1) -> 'sessions') = 3,
  '24 : rapport de caisse : ventes 8 000, encaissé 8 000, pourboires 500 à part, sessions listées');
select zz_tests.expect((select count(*) from public.staff_directory(current_setting('t.org')::uuid)) = 2,
  '25 : annuaire de l''équipe pour les noms (propriétaire et caissier)');

reset role;
rollback;
select 'TOUS LES CONTRÔLES 015 SONT PASSÉS (25)' as resultat;
