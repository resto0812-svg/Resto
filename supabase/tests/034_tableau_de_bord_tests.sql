-- =============================================================================
-- Resto — contrôles de la migration 034 (indicateurs détaillés du tableau
-- de bord).
-- À coller APRÈS 034. Transaction annulée à la fin.
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

insert into auth.users (id, email, aud, role, raw_user_meta_data, email_confirmed_at) values
  ('00000000-0000-0000-0000-00000000a034', 'owner.a34@resto.test', 'authenticated', 'authenticated', '{}', now()),
  ('00000000-0000-0000-0000-00000000c034', 'client.c34@resto.test', 'authenticated', 'authenticated', '{}', now());

set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000a034","role":"authenticated"}';
select set_config('t.a', public.create_organization('Bord 34', 'CM', 'XAF', 'fr', 'Africa/Douala', 'Bordville')::text, true);
select set_config('t.org', current_setting('t.a')::jsonb ->> 'organization_id', true);
select set_config('t.br', current_setting('t.a')::jsonb ->> 'brand_id', true);
select set_config('t.b', current_setting('t.a')::jsonb ->> 'branch_id', true);
with ins as (insert into public.menu_categories (organization_id, brand_id, name)
  values (current_setting('t.org')::uuid, current_setting('t.br')::uuid, 'Plats traditionnels') returning id)
select set_config('t.cat', (select id::text from ins), true);
select set_config('t.it', public.create_menu_item(current_setting('t.cat')::uuid, 'Ndolé royal', null, 'food')::text, true);
select set_config('t.v', (select id::text from public.item_variants where item_id = current_setting('t.it')::uuid), true);
insert into public.menu_item_branches (organization_id, brand_id, item_id, branch_id)
values (current_setting('t.org')::uuid, current_setting('t.br')::uuid, current_setting('t.it')::uuid, current_setting('t.b')::uuid);
select public.set_price(current_setting('t.b')::uuid, current_setting('t.v')::uuid, null, 'default', 4500);
update public.branches set is_published = true, accepts_online_orders = true,
       cover_path = current_setting('t.org') || '/jardin.jpg' where id = current_setting('t.b')::uuid;
select set_config('t.reg', (select id::text from public.cash_registers where branch_id = current_setting('t.b')::uuid), true);
select set_config('t.cash', (select id::text from public.payment_methods where organization_id = current_setting('t.org')::uuid and ref_code = 'cash'), true);


-- ------------------------------------------------------------- une vente encaissée et une commande annulée
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000c034","role":"authenticated"}';
select set_config('t.o', public.place_online_order(current_setting('t.b')::uuid, 'takeaway',
  jsonb_build_array(jsonb_build_object('variant_id', current_setting('t.v'), 'quantity', 2))) ->> 'order_id', true);
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000a034","role":"authenticated"}';
select public.accept_online_order(current_setting('t.o')::uuid, 15);
select set_config('t.s', public.open_cash_session(current_setting('t.reg')::uuid, 0)::text, true);
select public.take_payment(current_setting('t.o')::uuid, current_setting('t.s')::uuid, current_setting('t.cash')::uuid, 9000);
select set_config('t.o2', public.open_order(current_setting('t.b')::uuid, 'takeaway')::text, true);
select public.cancel_order(current_setting('t.o2')::uuid, 'Client parti');

select set_config('t.i', public.branch_insights(current_setting('t.b')::uuid, current_date - 1, current_date + 1)::text, true);
select zz_tests.expect(jsonb_array_length(current_setting('t.i')::jsonb -> 'orders_by_day') = 1
  and (current_setting('t.i')::jsonb -> 'orders_by_day' -> 0 ->> 'total')::int = 9000,
  '1 : commandes et chiffre d''affaires par jour');
select zz_tests.expect((select sum((x ->> 'total')::int) from jsonb_array_elements(current_setting('t.i')::jsonb -> 'payments_by_method') x) = 9000,
  '2 : encaissements par moyen de paiement');
select zz_tests.expect((current_setting('t.i')::jsonb -> 'items' -> 0 ->> 'quantity')::int = 2,
  '3 : plats vendus (quantités)');
select zz_tests.expect((current_setting('t.i')::jsonb -> 'cancellations' ->> 'orders')::int = 1
  and current_setting('t.i')::jsonb -> 'cancellations' -> 'reasons' -> 0 ->> 'reason' = 'Client parti',
  '4 : annulations et leurs motifs');
select zz_tests.expect_error(format($q$select public.branch_insights(%L, current_date, current_date - 10)$q$, current_setting('t.b')),
  'resto.invalid_period', '5 : période invalide refusée');

-- ------------------------------------------------------------- un client ne voit pas les chiffres du restaurant
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000c034","role":"authenticated"}';
select zz_tests.expect_error(format($q$select public.branch_insights(%L, current_date, current_date)$q$, current_setting('t.b')),
  '42501', '6 : réservé à l''équipe ayant accès aux finances');

reset role;
rollback;
select 'TOUS LES CONTRÔLES 034 SONT PASSÉS (6)' as resultat;
