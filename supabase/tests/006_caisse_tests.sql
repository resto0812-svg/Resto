-- =============================================================================
-- Resto — contrôles de la migration 006 (caisse).
-- À coller APRÈS 006. Transaction annulée à la fin : aucune donnée ne reste.
-- La dernière ligne « resultat » n'apparaît que si tout est passé.
-- Rappel : une requête ne voit pas ses propres modifications ; chaque
-- vérification suit l'action dans une requête séparée.
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

-- A = propriétaire, C = caissier (A1), W = serveur (A1), B = autre organisation
insert into auth.users (id, email, aud, role, raw_user_meta_data, email_confirmed_at) values
  ('00000000-0000-0000-0000-00000000a007', 'owner.a7@resto.test', 'authenticated', 'authenticated', '{}', now()),
  ('00000000-0000-0000-0000-00000000c007', 'cashier.c7@resto.test', 'authenticated', 'authenticated', '{}', now()),
  ('00000000-0000-0000-0000-00000000d007', 'waiter.w7@resto.test', 'authenticated', 'authenticated', '{}', now()),
  ('00000000-0000-0000-0000-00000000b007', 'owner.b7@resto.test', 'authenticated', 'authenticated', '{}', now());

set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000a007","role":"authenticated"}';
select set_config('t.a', public.create_organization('Caisse A', 'CM', 'XAF', 'fr', 'Africa/Douala', 'Douala', null, 'A1')::text, true);
select set_config('t.org', current_setting('t.a')::jsonb ->> 'organization_id', true);
select set_config('t.brand', current_setting('t.a')::jsonb ->> 'brand_id', true);
select set_config('t.a1', current_setting('t.a')::jsonb ->> 'branch_id', true);
with ins as (insert into public.menu_categories (organization_id, brand_id, name)
  values (current_setting('t.org')::uuid, current_setting('t.brand')::uuid, 'Plats') returning id)
select set_config('t.cat', (select id::text from ins), true);
select set_config('t.item', public.create_menu_item(current_setting('t.cat')::uuid, 'Poulet DG')::text, true);
select set_config('t.var', (select id::text from public.item_variants where item_id = current_setting('t.item')::uuid), true);
insert into public.menu_item_branches (organization_id, brand_id, item_id, branch_id)
values (current_setting('t.org')::uuid, current_setting('t.brand')::uuid, current_setting('t.item')::uuid, current_setting('t.a1')::uuid);
select public.set_price(current_setting('t.a1')::uuid, current_setting('t.var')::uuid, null, 'default', 5000);

select set_config('t.reg', (select id::text from public.cash_registers where branch_id = current_setting('t.a1')::uuid), true);
select zz_tests.expect(current_setting('t.reg') <> '', '1 : une « Caisse 1 » est créée avec l''établissement');

reset role;
insert into public.memberships (organization_id, user_id, role_code, all_branches) values
  (current_setting('t.org')::uuid, '00000000-0000-0000-0000-00000000c007', 'cashier', false),
  (current_setting('t.org')::uuid, '00000000-0000-0000-0000-00000000d007', 'waiter', false);
insert into public.membership_branches (organization_id, membership_id, branch_id)
select m.organization_id, m.id, current_setting('t.a1')::uuid from public.memberships m
 where m.user_id in ('00000000-0000-0000-0000-00000000c007', '00000000-0000-0000-0000-00000000d007');
set local role authenticated;

-- ------------------------------------------------------------- serveur W
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000d007","role":"authenticated"}';
select zz_tests.expect_error(format($q$select public.open_cash_session(%L, 0)$q$, current_setting('t.reg')),
  '42501', '2 : un serveur n''ouvre pas la caisse');

-- ------------------------------------------------------------- caissier C
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000c007","role":"authenticated"}';
select set_config('t.s1', public.open_cash_session(current_setting('t.reg')::uuid, 20000)::text, true);
select zz_tests.expect_error(format($q$select public.open_cash_session(%L, 0)$q$, current_setting('t.reg')),
  'resto.session_already_open', '3 : une seule session ouverte par caisse');

select set_config('t.o1', public.open_order(current_setting('t.a1')::uuid, 'takeaway')::text, true);
select public.add_order_item(current_setting('t.o1')::uuid, current_setting('t.var')::uuid, 2);
select public.send_order(current_setting('t.o1')::uuid);

select set_config('t.p1', public.record_payment(current_setting('t.o1')::uuid, current_setting('t.s1')::uuid,
  'card', 4000, null, 'TPE 123')::text, true);
select zz_tests.expect((current_setting('t.p1')::jsonb ->> 'due')::bigint = 6000
  and (current_setting('t.p1')::jsonb ->> 'closed')::boolean = false,
  '4 : paiement partiel par carte, reste dû 6 000');
select zz_tests.expect_error(format($q$select public.record_payment(%L, %L, 'mobile_money', 7000)$q$,
  current_setting('t.o1'), current_setting('t.s1')), 'resto.overpayment', '5 : on n''encaisse jamais plus que le reste dû');
select zz_tests.expect_error(format($q$select public.record_payment(%L, %L, 'card', 1000, 2000)$q$,
  current_setting('t.o1'), current_setting('t.s1')), 'resto.invalid_payment', '6 : « somme remise » réservée aux espèces');
select set_config('t.p2', public.record_payment(current_setting('t.o1')::uuid, current_setting('t.s1')::uuid,
  'cash', 6000, 10000)::text, true);
select zz_tests.expect((current_setting('t.p2')::jsonb ->> 'change')::bigint = 4000
  and (current_setting('t.p2')::jsonb ->> 'closed')::boolean
  and (select status from public.orders where id = current_setting('t.o1')::uuid) = 'closed',
  '7 : espèces 10 000 remis pour 6 000 : 4 000 rendus ; commande payée = clôturée');
select zz_tests.expect_error(format($q$select public.record_payment(%L, %L, 'cash', 1000)$q$,
  current_setting('t.o1'), current_setting('t.s1')), 'resto.order_not_open', '8 : plus d''encaissement sur une commande clôturée');
select zz_tests.expect((public.cash_session_summary(current_setting('t.s1')::uuid) ->> 'expected_cash')::bigint = 26000
  and (public.cash_session_summary(current_setting('t.s1')::uuid) -> 'by_method' ->> 'card')::bigint = 4000,
  '9 : espèces attendues = fond 20 000 + 6 000 ; la carte n''est pas comptée en espèces');

-- Commande non entièrement envoyée : payée mais pas clôturée
select set_config('t.o3', public.open_order(current_setting('t.a1')::uuid, 'takeaway')::text, true);
select public.add_order_item(current_setting('t.o3')::uuid, current_setting('t.var')::uuid, 1);
select set_config('t.p3', public.record_payment(current_setting('t.o3')::uuid, current_setting('t.s1')::uuid, 'mobile_money', 5000, null, 'MOMO-77')::text, true);
select zz_tests.expect((current_setting('t.p3')::jsonb ->> 'closed')::boolean = false,
  '10 : payée mais un article attend l''envoi : la commande reste ouverte');
select public.send_order(current_setting('t.o3')::uuid);
select public.close_order(current_setting('t.o3')::uuid);
select zz_tests.expect((select status from public.orders where id = current_setting('t.o3')::uuid) = 'closed',
  '11 : après l''envoi, clôture de la commande payée');

-- Commande avec paiement : annulation impossible ; annulation du paiement par un responsable
select set_config('t.o2', public.open_order(current_setting('t.a1')::uuid, 'takeaway')::text, true);
select public.add_order_item(current_setting('t.o2')::uuid, current_setting('t.var')::uuid, 1);
select public.send_order(current_setting('t.o2')::uuid);
select set_config('t.p4', (public.record_payment(current_setting('t.o2')::uuid, current_setting('t.s1')::uuid, 'cash', 1000) ->> 'payment_id'), true);
select zz_tests.expect_error(format($q$select public.void_payment(%L, 'erreur de saisie')$q$, current_setting('t.p4')),
  '42501', '12 : un caissier n''annule pas un paiement');
select zz_tests.expect_error($q$update public.payments set amount_minor = 1$q$, '42501', '13 : un paiement ne se modifie jamais directement');

set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000a007","role":"authenticated"}';
select zz_tests.expect_error(format($q$select public.cancel_order(%L, 'client parti')$q$, current_setting('t.o2')),
  'resto.order_has_payments', '14 : une commande avec paiement ne s''annule pas');
select zz_tests.expect_error(format($q$select public.void_payment(%L, '')$q$, current_setting('t.p4')),
  'resto.reason_required', '15 : annulation de paiement sans motif refusée');
select public.void_payment(current_setting('t.p4')::uuid, 'erreur de saisie');
select zz_tests.expect((select paid_minor from public.orders where id = current_setting('t.o2')::uuid) = 0
  and (select status from public.payments where id = current_setting('t.p4')::uuid) = 'voided',
  '16 : paiement annulé conservé, plus compté');
select public.cancel_order(current_setting('t.o2')::uuid, 'client parti');
select zz_tests.expect((select status from public.orders where id = current_setting('t.o2')::uuid) = 'cancelled',
  '17 : sans paiement, la commande peut être annulée');

-- Remboursement partiel d'une commande clôturée
select public.refund_payment((current_setting('t.p1')::jsonb ->> 'payment_id')::uuid, current_setting('t.s1')::uuid, 1500, 'plat froid');
select zz_tests.expect((select paid_minor from public.orders where id = current_setting('t.o1')::uuid) = 8500
  and (select count(*) from public.refunds where order_id = current_setting('t.o1')::uuid) = 1,
  '18 : remboursement partiel par le même moyen, tracé avec son motif');
select zz_tests.expect_error(format($q$select public.refund_payment(%L, %L, 3000, 'encore')$q$,
  current_setting('t.p1')::jsonb ->> 'payment_id', current_setting('t.s1')), 'resto.invalid_amount',
  '19 : jamais plus remboursé que payé');

-- ------------------------------------------------------------- caissier C : mouvements et comptage
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000c007","role":"authenticated"}';
select zz_tests.expect_error(format($q$select public.add_cash_movement(%L, 'out', 999999, 'trop')$q$, current_setting('t.s1')),
  'resto.not_enough_cash', '20 : on ne sort pas plus d''espèces qu''il n''y en a');
select public.add_cash_movement(current_setting('t.s1')::uuid, 'out', 2000, 'achat de gaz');
select zz_tests.expect((public.cash_session_summary(current_setting('t.s1')::uuid) ->> 'expected_cash')::bigint = 24000,
  '21 : sortie d''espèces déduite de l''attendu (26 000 − 2 000)');
select set_config('t.count', public.count_cash_session(current_setting('t.s1')::uuid, 23500)::text, true);
select zz_tests.expect((current_setting('t.count')::jsonb ->> 'difference')::bigint = -500
  and (select status from public.cash_sessions where id = current_setting('t.s1')::uuid) = 'counted',
  '22 : comptage 23 500 pour 24 000 attendus : écart −500 figé');
select set_config('t.o4', public.open_order(current_setting('t.a1')::uuid, 'takeaway')::text, true);
select public.add_order_item(current_setting('t.o4')::uuid, current_setting('t.var')::uuid, 1);
select zz_tests.expect_error(format($q$select public.record_payment(%L, %L, 'cash', 5000)$q$,
  current_setting('t.o4'), current_setting('t.s1')), 'resto.session_not_open', '23 : plus d''encaissement sur une session comptée');
select zz_tests.expect_error(format($q$select public.validate_cash_session(%L, 'ok')$q$, current_setting('t.s1')),
  '42501', '24 : un caissier ne valide pas sa propre clôture');
select zz_tests.expect_error(format($q$select public.daily_summary(%L, current_date)$q$, current_setting('t.a1')),
  '42501', '25 : le rapport du jour est réservé aux responsables');
select set_config('t.s2', public.open_cash_session(current_setting('t.reg')::uuid, 10000)::text, true);
select zz_tests.expect(current_setting('t.s2') <> current_setting('t.s1'), '26 : nouvelle session possible pendant la validation de la précédente');

-- ------------------------------------------------------------- propriétaire A : validation et rapport
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000a007","role":"authenticated"}';
select zz_tests.expect_error(format($q$select public.validate_cash_session(%L)$q$, current_setting('t.s1')),
  'resto.reason_required', '27 : un écart se valide avec un commentaire');
select public.validate_cash_session(current_setting('t.s1')::uuid, 'pièces manquantes');
select zz_tests.expect((select status from public.cash_sessions where id = current_setting('t.s1')::uuid) = 'closed',
  '28 : session validée et close');
select set_config('t.day', public.daily_summary(current_setting('t.a1')::uuid,
  (select business_date from public.orders where id = current_setting('t.o1')::uuid))::text, true);
select zz_tests.expect((current_setting('t.day')::jsonb ->> 'orders_closed')::int = 2
  and (current_setting('t.day')::jsonb ->> 'orders_cancelled')::int = 1
  and (current_setting('t.day')::jsonb ->> 'sales_total')::bigint = 15000
  and (current_setting('t.day')::jsonb -> 'payments_by_method' ->> 'cash')::bigint = 6000
  and (current_setting('t.day')::jsonb ->> 'refunds_total')::bigint = 1500,
  '29 : rapport du jour : 2 clôturées (15 000), 1 annulée, espèces 6 000 (paiement annulé exclu), remboursé 1 500');

-- ------------------------------------------------------------- autre organisation B
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000b007","role":"authenticated"}';
select public.create_organization('Caisse B', 'CM', 'XAF', 'fr', 'Africa/Douala', 'Yaoundé');
select zz_tests.expect((select count(*) from public.cash_sessions) = 0 and (select count(*) from public.payments) = 0
  and (select count(*) from public.refunds) = 0 and (select count(*) from public.cash_movements) = 0,
  '30 : B ne voit rien de la caisse de A');
select zz_tests.expect_error(format($q$select public.record_payment(%L, %L, 'cash', 5000)$q$,
  current_setting('t.o4'), current_setting('t.s2')), '42501', '31 : B n''encaisse rien chez A');
select zz_tests.expect_error(format($q$select public.cash_session_summary(%L)$q$, current_setting('t.s2')),
  '42501', '32 : B ne lit pas les sessions de A');

reset role;
rollback;
select 'TOUS LES CONTRÔLES 006 SONT PASSÉS (32)' as resultat;
