-- =============================================================================
-- Resto — contrôles de la migration 016 (factures clients).
-- À coller APRÈS 016. Transaction annulée à la fin : aucune donnée ne reste.
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

-- A = propriétaire, K = caissier, B = autre organisation
insert into auth.users (id, email, aud, role, raw_user_meta_data, email_confirmed_at) values
  ('00000000-0000-0000-0000-00000000a016', 'owner.a16@resto.test', 'authenticated', 'authenticated', '{}', now()),
  ('00000000-0000-0000-0000-00000000c016', 'cashier.k16@resto.test', 'authenticated', 'authenticated', '{}', now()),
  ('00000000-0000-0000-0000-00000000b016', 'owner.b16@resto.test', 'authenticated', 'authenticated', '{}', now());

set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000a016","role":"authenticated"}';
select set_config('t.a', public.create_organization('Factures A', 'CM', 'XAF', 'fr', 'Africa/Douala', 'Douala', null, 'A1')::text, true);
select set_config('t.org', current_setting('t.a')::jsonb ->> 'organization_id', true);
select set_config('t.brand', current_setting('t.a')::jsonb ->> 'brand_id', true);
select set_config('t.a1', current_setting('t.a')::jsonb ->> 'branch_id', true);
update public.branches set invoice_prefix = 'FA-2026-', invoice_footer = 'Paiement à réception.' where id = current_setting('t.a1')::uuid;
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

reset role;
insert into public.memberships (organization_id, user_id, role_code, all_branches) values
  (current_setting('t.org')::uuid, '00000000-0000-0000-0000-00000000c016', 'cashier', false);
insert into public.membership_branches (organization_id, membership_id, branch_id)
select m.organization_id, m.id, current_setting('t.a1')::uuid from public.memberships m
 where m.user_id = '00000000-0000-0000-0000-00000000c016';
set local role authenticated;

-- ------------------------------------------------------------- caissier K
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000c016","role":"authenticated"}';
select set_config('t.s', public.open_cash_session(current_setting('t.reg')::uuid, 0)::text, true);
select set_config('t.o1', public.create_order(current_setting('t.a1')::uuid, 'takeaway')::text, true);
select public.add_order_item(current_setting('t.o1')::uuid, current_setting('t.var')::uuid, 2);
select public.send_order(current_setting('t.o1')::uuid);
select public.take_payment(current_setting('t.o1')::uuid, current_setting('t.s')::uuid, current_setting('t.cash')::uuid, 8000);
select zz_tests.expect_error(format($q$select public.issue_invoice(%L, '  ')$q$, current_setting('t.o1')),
  'resto.customer_name_required', '1 : facture sans nom de client refusée');
select zz_tests.expect_error(format($q$select public.issue_invoice(%L, 'Awa', null, null, null, 'pas-un-email')$q$, current_setting('t.o1')),
  'resto.invalid_email', '2 : e-mail invalide refusé');
select set_config('t.f1', public.issue_invoice(current_setting('t.o1')::uuid, 'Awa Ndiaye', 'Société Kotto SARL', 'M0123456789X',
  'Bonamoussadi, Douala', 'compta@kotto.test')::text, true);
select zz_tests.expect((current_setting('t.f1')::jsonb ->> 'label') = 'FA-2026-1'
  and (select total_minor = 8000 and paid_minor = 8000 and customer_company = 'Société Kotto SARL'
         and jsonb_array_length(lines) = 1 and (lines -> 0 ->> 'quantity')::int = 2
         and jsonb_array_length(payments) = 1
        from public.customer_invoices where id = (current_setting('t.f1')::jsonb ->> 'invoice_id')::uuid),
  '3 : facture n° FA-2026-1 : client, société, n° fiscal, articles et paiement figés');
select zz_tests.expect((public.issue_invoice(current_setting('t.o1')::uuid, 'Autre') ->> 'invoice_id')
  = current_setting('t.f1')::jsonb ->> 'invoice_id', '4 : une commande déjà facturée renvoie sa facture (pas de doublon)');
select zz_tests.expect_error(format($q$update public.customer_invoices set customer_name = 'Fraude' where id = %L$q$,
  current_setting('t.f1')::jsonb ->> 'invoice_id'), '42501', '5 : une facture ne se modifie pas');
select zz_tests.expect_error(format($q$select public.cancel_invoice(%L, 'erreur de nom')$q$,
  current_setting('t.f1')::jsonb ->> 'invoice_id'), '42501', '6 : un caissier n''annule pas une facture');

-- ------------------------------------------------------------- propriétaire A
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000a016","role":"authenticated"}';
select zz_tests.expect_error(format($q$select public.cancel_invoice(%L, 'x')$q$, current_setting('t.f1')::jsonb ->> 'invoice_id'),
  'resto.reason_required', '7 : annulation sans motif refusée');
select public.cancel_invoice((current_setting('t.f1')::jsonb ->> 'invoice_id')::uuid, 'erreur de raison sociale');
select set_config('t.f2', public.issue_invoice(current_setting('t.o1')::uuid, 'Awa Ndiaye', 'Kotto SARL')::text, true);
select zz_tests.expect((select status from public.customer_invoices where id = (current_setting('t.f1')::jsonb ->> 'invoice_id')::uuid) = 'cancelled'
  and (current_setting('t.f2')::jsonb ->> 'label') = 'FA-2026-2',
  '8 : facture annulée (numéro conservé), commande refacturée sous le n° suivant');
select zz_tests.expect_error(format($q$select public.cancel_invoice(%L, 'encore une fois')$q$,
  current_setting('t.f1')::jsonb ->> 'invoice_id'), 'resto.invalid_status', '9 : une facture annulée ne se réannule pas');

-- ------------------------------------------------------------- autre organisation B
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000b016","role":"authenticated"}';
select public.create_organization('Factures B', 'CM', 'XAF', 'fr', 'Africa/Douala', 'Yaoundé');
select zz_tests.expect((select count(*) from public.customer_invoices) = 0, '10 : B ne voit pas les factures de A');
select zz_tests.expect_error(format($q$select public.issue_invoice(%L, 'Pirate')$q$, current_setting('t.o1')),
  '42501', '11 : B ne facture pas les commandes de A');

reset role;
rollback;
select 'TOUS LES CONTRÔLES 016 SONT PASSÉS (11)' as resultat;
