-- =============================================================================
-- Resto — contrôles de la migration 009 (achats, fournisseurs, dépenses).
-- À coller APRÈS 009. Transaction annulée à la fin : aucune donnée ne reste.
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

-- A = propriétaire, C = comptable (A1), W = serveur (A1), B = autre organisation
insert into auth.users (id, email, aud, role, raw_user_meta_data, email_confirmed_at) values
  ('00000000-0000-0000-0000-00000000a010', 'owner.a10@resto.test', 'authenticated', 'authenticated', '{}', now()),
  ('00000000-0000-0000-0000-00000000c010', 'accountant.c10@resto.test', 'authenticated', 'authenticated', '{}', now()),
  ('00000000-0000-0000-0000-00000000d010', 'waiter.w10@resto.test', 'authenticated', 'authenticated', '{}', now()),
  ('00000000-0000-0000-0000-00000000b010', 'owner.b10@resto.test', 'authenticated', 'authenticated', '{}', now());

set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000a010","role":"authenticated"}';
select set_config('t.a', public.create_organization('Achats A', 'CM', 'XAF', 'fr', 'Africa/Douala', 'Douala', null, 'A1')::text, true);
select set_config('t.org', current_setting('t.a')::jsonb ->> 'organization_id', true);
select set_config('t.a1', current_setting('t.a')::jsonb ->> 'branch_id', true);
select set_config('t.loc', (select id::text from public.stock_locations where branch_id = current_setting('t.a1')::uuid), true);
select zz_tests.expect((select count(*) from public.expense_categories where organization_id = current_setting('t.org')::uuid) = 12,
  '1 : catégories de dépenses par défaut créées avec l''organisation');
select zz_tests.expect(zz_tests.rows(format($q$update public.expense_categories set name = 'X' where organization_id = %L and code = 'rent'$q$,
  current_setting('t.org'))) = 0, '2 : une catégorie par défaut ne se renomme pas');

with ins as (insert into public.ingredients (organization_id, name, kind, unit_code)
  values (current_setting('t.org')::uuid, 'Poulet', 'raw', 'kg') returning id)
select set_config('t.poulet', (select id::text from ins), true);
with ins as (insert into public.suppliers (organization_id, name, phone) values (current_setting('t.org')::uuid, 'Ferme Bello', '+237 600000000') returning id)
select set_config('t.sup', (select id::text from ins), true);

-- Bon de commande
select set_config('t.po', public.save_purchase_order(null, current_setting('t.a1')::uuid, current_setting('t.sup')::uuid,
  current_date + 2, 'livraison matin', jsonb_build_array(jsonb_build_object('ingredient_id', current_setting('t.poulet'),
  'quantity', 10, 'unit', 'kg', 'unit_price', 2500)))::text, true);
select zz_tests.expect((select total_minor from public.purchase_orders where id = current_setting('t.po')::uuid) = 25000
  and (select number from public.purchase_orders where id = current_setting('t.po')::uuid) = 1,
  '3 : bon de commande n° 1 : 10 kg à 2 500 = 25 000');
select public.save_purchase_order(current_setting('t.po')::uuid, current_setting('t.a1')::uuid, current_setting('t.sup')::uuid,
  current_date + 2, null, jsonb_build_array(jsonb_build_object('ingredient_id', current_setting('t.poulet'),
  'quantity', 8, 'unit', 'kg', 'unit_price', 2500)));
select public.set_purchase_order_status(current_setting('t.po')::uuid, 'sent');
select zz_tests.expect_error(format($q$select public.save_purchase_order(%L, %L, %L, null, null, %L::jsonb)$q$,
  current_setting('t.po'), current_setting('t.a1'), current_setting('t.sup'),
  jsonb_build_array(jsonb_build_object('ingredient_id', current_setting('t.poulet'), 'quantity', 1, 'unit', 'kg'))::text),
  'resto.purchase_not_draft', '4 : un bon envoyé ne se modifie plus');
select zz_tests.expect_error(format($q$select public.save_purchase_order(null, %L, %L, null, null, '[]'::jsonb)$q$,
  current_setting('t.a1'), current_setting('t.sup')), 'resto.invalid_purchase', '5 : bon de commande sans ligne refusé');

-- Réceptions
select set_config('t.pol', (select id::text from public.purchase_order_lines where po_id = current_setting('t.po')::uuid), true);
select set_config('t.r1', public.record_goods_receipt(current_setting('t.a1')::uuid, current_setting('t.loc')::uuid,
  current_setting('t.sup')::uuid, current_setting('t.po')::uuid, 'BL-1', jsonb_build_array(jsonb_build_object(
  'po_line_id', current_setting('t.pol'), 'ingredient_id', current_setting('t.poulet'), 'quantity', 5, 'unit', 'kg',
  'unit_price', 2500)))::text, true);
select zz_tests.expect((select status from public.purchase_orders where id = current_setting('t.po')::uuid) = 'partially_received'
  and (select received_quantity from public.purchase_order_lines where id = current_setting('t.pol')::uuid) = 5
  and (select quantity from public.stock_movements where receipt_id = current_setting('t.r1')::uuid) = 5,
  '6 : réception partielle : 5 kg entrés en stock, bon partiellement reçu');
select set_config('t.r2', public.record_goods_receipt(current_setting('t.a1')::uuid, current_setting('t.loc')::uuid,
  current_setting('t.sup')::uuid, current_setting('t.po')::uuid, 'BL-2', jsonb_build_array(jsonb_build_object(
  'po_line_id', current_setting('t.pol'), 'ingredient_id', current_setting('t.poulet'), 'quantity', 3000, 'unit', 'g',
  'unit_price', 2.6)))::text, true);
select zz_tests.expect((select status from public.purchase_orders where id = current_setting('t.po')::uuid) = 'received'
  and (select avg_unit_cost from public.ingredient_stock where ingredient_id = current_setting('t.poulet')::uuid) = 2537.5,
  '7 : réception du reste (3 000 g à 2,6 / g) : bon reçu ; coût moyen 2 537,5 / kg');
select zz_tests.expect_error(format($q$select public.set_purchase_order_status(%L, 'cancelled')$q$, current_setting('t.po')),
  'resto.invalid_status', '8 : un bon reçu ne s''annule pas');

-- Factures et paiements
select set_config('t.inv', public.record_supplier_invoice(current_setting('t.a1')::uuid, current_setting('t.sup')::uuid, 'F-001',
  current_date, null, 20300, 0, array[current_setting('t.r1')::uuid, current_setting('t.r2')::uuid])::text, true);
select zz_tests.expect((select total_minor from public.supplier_invoices where id = current_setting('t.inv')::uuid) = 20300
  and (select count(*) from public.supplier_invoice_receipts where invoice_id = current_setting('t.inv')::uuid) = 2,
  '9 : facture 20 300 liée aux deux réceptions');
select zz_tests.expect_error(format($q$select public.record_supplier_invoice(%L, %L, ' F-001 ', current_date, null, 1, 0)$q$,
  current_setting('t.a1'), current_setting('t.sup')), 'resto.duplicate_invoice', '10 : une même facture ne se saisit pas deux fois');
select set_config('t.pay1', public.record_supplier_payment(current_setting('t.inv')::uuid, 10000, 'transfer', current_date, 'VIR-1')::text, true);
select zz_tests.expect_error(format($q$select public.record_supplier_payment(%L, 20000, 'transfer', current_date)$q$,
  current_setting('t.inv')), 'resto.overpayment', '11 : jamais plus que le reste dû');
select set_config('t.reg', (select id::text from public.cash_registers where branch_id = current_setting('t.a1')::uuid), true);
select set_config('t.sess', public.open_cash_session(current_setting('t.reg')::uuid, 50000)::text, true);
select public.record_supplier_payment(current_setting('t.inv')::uuid, 10300, 'cash', current_date, null, current_setting('t.sess')::uuid);
select zz_tests.expect((select status from public.supplier_invoices where id = current_setting('t.inv')::uuid) = 'paid'
  and (public.cash_session_summary(current_setting('t.sess')::uuid) ->> 'expected_cash')::bigint = 39700,
  '12 : solde payé en espèces de la caisse : facture payée, sortie de caisse automatique');
select zz_tests.expect_error(format($q$select public.cancel_supplier_invoice(%L, 'erreur')$q$, current_setting('t.inv')),
  'resto.invoice_has_payments', '13 : une facture payée ne s''annule pas');
select public.void_supplier_payment(current_setting('t.pay1')::uuid, 'virement rejeté');
select zz_tests.expect((select status from public.supplier_invoices where id = current_setting('t.inv')::uuid) = 'open'
  and (select paid_minor from public.supplier_invoices where id = current_setting('t.inv')::uuid) = 10300,
  '14 : paiement annulé (conservé) : la facture redevient ouverte, reste 10 000');

-- Dépenses
select set_config('t.cat', (select id::text from public.expense_categories
  where organization_id = current_setting('t.org')::uuid and code = 'electricity'), true);
select public.record_expense(current_setting('t.a1')::uuid, current_setting('t.cat')::uuid, 'Facture ENEO octobre',
  current_date, 15000, 2000, 'transfer');
select set_config('t.exp2', public.record_expense(current_setting('t.a1')::uuid, current_setting('t.cat')::uuid, 'Bougies',
  current_date, 5000, 0, 'cash', null, current_setting('t.sess')::uuid)::text, true);
select zz_tests.expect((public.cash_session_summary(current_setting('t.sess')::uuid) ->> 'expected_cash')::bigint = 34700,
  '15 : dépense payée en caisse : sortie d''espèces automatique');
select public.cancel_expense(current_setting('t.exp2')::uuid, 'saisie en double');
select zz_tests.expect((public.cash_session_summary(current_setting('t.sess')::uuid) ->> 'expected_cash')::bigint = 39700
  and (select status from public.expenses where id = current_setting('t.exp2')::uuid) = 'cancelled',
  '16 : dépense annulée (conservée) : l''argent revient en caisse');
select zz_tests.expect_error(format($q$select public.record_expense(%L, %L, 'X', current_date, 100, 200, 'cash')$q$,
  current_setting('t.a1'), current_setting('t.cat')), 'resto.invalid_expense', '17 : taxe supérieure au montant refusée');
select zz_tests.expect_error(format($q$select public.record_expense(%L, %L, 'X', current_date, 100, 0, 'cash', null, null, 'autre/dossier/x.pdf')$q$,
  current_setting('t.a1'), current_setting('t.cat')), 'resto.invalid_attachment', '18 : justificatif hors du dossier de l''établissement refusé');

select set_config('t.fin', public.finance_summary(current_setting('t.a1')::uuid, current_date - 1, current_date + 1)::text, true);
select zz_tests.expect((current_setting('t.fin')::jsonb ->> 'purchases')::bigint = 20300
  and (current_setting('t.fin')::jsonb ->> 'expenses_ht')::bigint = 13000
  and (current_setting('t.fin')::jsonb ->> 'supplier_debt')::bigint = 10000
  and (current_setting('t.fin')::jsonb ->> 'estimated_result')::numeric = -13000,
  '19 : rapport : achats 20 300, dépenses HT 13 000 (annulée exclue), dette fournisseur 10 000, résultat −13 000');

reset role;
insert into public.memberships (organization_id, user_id, role_code, all_branches) values
  (current_setting('t.org')::uuid, '00000000-0000-0000-0000-00000000c010', 'accountant', false),
  (current_setting('t.org')::uuid, '00000000-0000-0000-0000-00000000d010', 'waiter', false);
insert into public.membership_branches (organization_id, membership_id, branch_id)
select m.organization_id, m.id, current_setting('t.a1')::uuid from public.memberships m
 where m.user_id in ('00000000-0000-0000-0000-00000000c010', '00000000-0000-0000-0000-00000000d010');
set local role authenticated;

-- ------------------------------------------------------------- comptable C
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000c010","role":"authenticated"}';
select public.record_expense(current_setting('t.a1')::uuid, current_setting('t.cat')::uuid, 'Eau', current_date, 3000, 0, 'mobile_money');
select zz_tests.expect((select count(*) from public.expenses) = 3 and (select count(*) from public.supplier_invoices) = 1,
  '20 : le comptable saisit les dépenses et consulte les factures');

-- ------------------------------------------------------------- serveur W
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000d010","role":"authenticated"}';
select zz_tests.expect_error(format($q$select public.record_expense(%L, %L, 'X', current_date, 100, 0, 'cash')$q$,
  current_setting('t.a1'), current_setting('t.cat')), '42501', '21 : un serveur ne saisit pas de dépense');
select zz_tests.expect((select count(*) from public.expenses) = 0 and (select count(*) from public.supplier_invoices) = 0,
  '22 : ni ne consulte dépenses et factures');

-- ------------------------------------------------------------- autre organisation B
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000b010","role":"authenticated"}';
select public.create_organization('Achats B', 'CM', 'XAF', 'fr', 'Africa/Douala', 'Yaoundé');
select zz_tests.expect((select count(*) from public.suppliers) = 0 and (select count(*) from public.purchase_orders) = 0,
  '23 : B ne voit ni les fournisseurs ni les achats de A');
select zz_tests.expect_error(format($q$select public.record_supplier_payment(%L, 1, 'cash', current_date)$q$, current_setting('t.inv')),
  '42501', '24 : B ne paie pas une facture de A');

reset role;
rollback;
select 'TOUS LES CONTRÔLES 009 SONT PASSÉS (24)' as resultat;
