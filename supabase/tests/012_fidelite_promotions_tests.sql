-- =============================================================================
-- Resto — contrôles de la migration 012 (fidélité, promotions, remises).
-- À coller APRÈS 012. Transaction annulée à la fin : aucune donnée ne reste.
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

create function zz_tests.total(p_order text) returns bigint language sql as $$
  select total_minor from public.orders where id = p_order::uuid
$$;

-- A = propriétaire, W = serveur (A1), C = client, D = autre client, B = autre organisation
insert into auth.users (id, email, aud, role, raw_user_meta_data, email_confirmed_at) values
  ('00000000-0000-0000-0000-00000000a013', 'owner.a13@resto.test', 'authenticated', 'authenticated', '{}', now()),
  ('00000000-0000-0000-0000-00000000e013', 'waiter.w13@resto.test', 'authenticated', 'authenticated', '{}', now()),
  ('00000000-0000-0000-0000-00000000c013', 'client.c13@resto.test', 'authenticated', 'authenticated', '{}', now()),
  ('00000000-0000-0000-0000-00000000d013', 'client.d13@resto.test', 'authenticated', 'authenticated', '{}', now()),
  ('00000000-0000-0000-0000-00000000b013', 'owner.b13@resto.test', 'authenticated', 'authenticated', '{}', now());

set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000a013","role":"authenticated"}';
select set_config('t.a', public.create_organization('Promo A', 'CM', 'XAF', 'fr', 'Africa/Douala', 'Douala')::text, true);
select set_config('t.org', current_setting('t.a')::jsonb ->> 'organization_id', true);
select set_config('t.brand', current_setting('t.a')::jsonb ->> 'brand_id', true);
select set_config('t.a1', current_setting('t.a')::jsonb ->> 'branch_id', true);
update public.branches set is_published = true, accepts_online_orders = true where id = current_setting('t.a1')::uuid;
with ins as (insert into public.menu_categories (organization_id, brand_id, name)
  values (current_setting('t.org')::uuid, current_setting('t.brand')::uuid, 'Plats') returning id)
select set_config('t.cat', (select id::text from ins), true);
select set_config('t.item', public.create_menu_item(current_setting('t.cat')::uuid, 'Poulet DG')::text, true);
select set_config('t.var', (select id::text from public.item_variants where item_id = current_setting('t.item')::uuid), true);
insert into public.menu_item_branches (organization_id, brand_id, item_id, branch_id)
values (current_setting('t.org')::uuid, current_setting('t.brand')::uuid, current_setting('t.item')::uuid, current_setting('t.a1')::uuid);
select public.set_price(current_setting('t.a1')::uuid, current_setting('t.var')::uuid, null, 'default', 5000);
select set_config('t.reg', (select id::text from public.cash_registers where branch_id = current_setting('t.a1')::uuid), true);
select set_config('t.sess', public.open_cash_session(current_setting('t.reg')::uuid, 0)::text, true);

insert into public.promotions (organization_id, name, kind, percent, code)
values (current_setting('t.org')::uuid, 'Bienvenue', 'percent', 10, 'BIENVENUE');
with ins as (insert into public.promotions (organization_id, name, kind, amount_minor)
  values (current_setting('t.org')::uuid, 'Offre maison', 'amount', 3000) returning id)
select set_config('t.pamount', (select id::text from ins), true);
insert into public.promotions (organization_id, name, kind, percent, code, ends_at)
values (current_setting('t.org')::uuid, 'Expirée', 'percent', 50, 'VIEILLE', now() - interval '1 day');
insert into public.promotions (organization_id, name, kind, percent, code, max_uses)
values (current_setting('t.org')::uuid, 'Unique', 'percent', 5, 'UNEFOIS', 1);

-- Promotion en pourcentage, recalculée quand la commande change
select set_config('t.o1', public.open_order(current_setting('t.a1')::uuid, 'takeaway')::text, true);
select public.add_order_item(current_setting('t.o1')::uuid, current_setting('t.var')::uuid, 2);
select public.apply_promotion(current_setting('t.o1')::uuid, null, ' bienvenue ');
select zz_tests.expect(zz_tests.total(current_setting('t.o1')) = 9000
  and (select discount_minor from public.orders where id = current_setting('t.o1')::uuid) = 1000,
  '1 : code BIENVENUE (−10 %) : 10 000 → 9 000');
select zz_tests.expect_error(format($q$select public.apply_promotion(%L, null, 'BIENVENUE')$q$, current_setting('t.o1')),
  'resto.promotion_already_applied', '2 : une même promotion ne s''applique qu''une fois');
select public.add_order_item(current_setting('t.o1')::uuid, current_setting('t.var')::uuid, 1);
select zz_tests.expect(zz_tests.total(current_setting('t.o1')) = 13500, '3 : article ajouté : la réduction suit (15 000 − 10 % = 13 500)');

-- Montant fixe plafonné, promotions expirée et épuisée
select set_config('t.o2', public.open_order(current_setting('t.a1')::uuid, 'takeaway')::text, true);
select public.add_order_item(current_setting('t.o2')::uuid, current_setting('t.var')::uuid, 1);
select public.apply_promotion(current_setting('t.o2')::uuid, current_setting('t.pamount')::uuid);
select zz_tests.expect(zz_tests.total(current_setting('t.o2')) = 2000, '4 : offre de 3 000 sur 5 000 : reste 2 000');
select zz_tests.expect_error(format($q$select public.apply_promotion(%L, null, 'VIEILLE')$q$, current_setting('t.o2')),
  'resto.promotion_unavailable', '5 : promotion expirée refusée');
select public.apply_promotion(current_setting('t.o2')::uuid, null, 'UNEFOIS');
select zz_tests.expect_error(format($q$select public.apply_promotion(%L, null, 'UNEFOIS')$q$, current_setting('t.o1')),
  'resto.promotion_unavailable', '6 : promotion à usage limité épuisée');
select zz_tests.expect(zz_tests.total(current_setting('t.o2')) >= 0, '7 : un total ne devient jamais négatif');

-- Remise manuelle et commande déjà payée
select public.apply_manual_discount(current_setting('t.o1')::uuid, null, 500, 'attente trop longue');
select zz_tests.expect(zz_tests.total(current_setting('t.o1')) = 13000, '8 : geste commercial de 500 avec motif');
select set_config('t.o3', public.open_order(current_setting('t.a1')::uuid, 'takeaway')::text, true);
select public.add_order_item(current_setting('t.o3')::uuid, current_setting('t.var')::uuid, 2);
select public.record_payment(current_setting('t.o3')::uuid, current_setting('t.sess')::uuid, 'cash', 9000);
select zz_tests.expect_error(format($q$select public.apply_manual_discount(%L, null, 2000, 'trop tard')$q$, current_setting('t.o3')),
  'resto.order_has_payments', '9 : pas de réduction qui rendrait la commande trop payée');

reset role;
insert into public.memberships (organization_id, user_id, role_code, all_branches)
values (current_setting('t.org')::uuid, '00000000-0000-0000-0000-00000000e013', 'waiter', true);
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000e013","role":"authenticated"}';
select zz_tests.expect_error(format($q$select public.apply_manual_discount(%L, 10, null, 'copain')$q$, current_setting('t.o2')),
  '42501', '10 : un serveur ne fait pas de remise manuelle');
select zz_tests.expect_error($q$insert into public.promotions (organization_id, name, kind, percent) select organization_id, 'X', 'percent', 90 from public.orders limit 1$q$,
  '42501', '11 : un serveur ne crée pas de promotion');

-- Fidélité
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000a013","role":"authenticated"}';
insert into public.loyalty_programs (organization_id, active, amount_per_point_minor, reward_points, reward_minor)
values (current_setting('t.org')::uuid, true, 1000, 10, 1000);

set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000c013","role":"authenticated"}';
select set_config('t.c1', public.place_online_order(current_setting('t.a1')::uuid, 'takeaway',
  jsonb_build_array(jsonb_build_object('variant_id', current_setting('t.var'), 'quantity', 2))) ->> 'order_id', true);
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000a013","role":"authenticated"}';
select public.accept_online_order(current_setting('t.c1')::uuid);
select public.record_payment(current_setting('t.c1')::uuid, current_setting('t.sess')::uuid, 'cash', 10000);

set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000c013","role":"authenticated"}';
select zz_tests.expect((select points from public.my_loyalty()) = 10, '12 : commande payée de 10 000 : 10 points gagnés');
select set_config('t.c2', public.place_online_order(current_setting('t.a1')::uuid, 'takeaway',
  jsonb_build_array(jsonb_build_object('variant_id', current_setting('t.var'), 'quantity', 1))) ->> 'order_id', true);
select public.customer_apply_code(current_setting('t.c2')::uuid, 'BIENVENUE');
select zz_tests.expect(zz_tests.total(current_setting('t.c2')) = 4500, '13 : le client applique un code sur sa commande en attente');

set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000d013","role":"authenticated"}';
select zz_tests.expect_error(format($q$select public.customer_apply_code(%L, 'BIENVENUE')$q$, current_setting('t.c2')),
  '42501', '14 : pas de code sur la commande d''un autre client');
select zz_tests.expect((select count(*) from public.my_loyalty()) = 0, '15 : chacun ne voit que ses propres points');

set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000a013","role":"authenticated"}';
select public.accept_online_order(current_setting('t.c2')::uuid);
select public.redeem_loyalty(current_setting('t.c2')::uuid);
select zz_tests.expect(zz_tests.total(current_setting('t.c2')) = 3500
  and (select points from public.loyalty_accounts where user_id = '00000000-0000-0000-0000-00000000c013') = 0,
  '16 : récompense échangée (10 points = 1 000) : 4 500 → 3 500, points à 0');
select zz_tests.expect_error(format($q$select public.redeem_loyalty(%L)$q$, current_setting('t.c2')),
  'resto.not_enough_points', '17 : pas de récompense sans points suffisants');
select public.remove_adjustment((select id from public.order_adjustments where order_id = current_setting('t.c2')::uuid and kind = 'loyalty'));
select zz_tests.expect((select points from public.loyalty_accounts where user_id = '00000000-0000-0000-0000-00000000c013') = 10
  and zz_tests.total(current_setting('t.c2')) = 4500, '18 : récompense retirée : points rendus, total rétabli');
select zz_tests.expect_error($q$update public.loyalty_transactions set points = 999$q$, '42501', '19 : l''historique des points ne se modifie pas');

-- ------------------------------------------------------------- autre organisation B
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000b013","role":"authenticated"}';
select public.create_organization('Promo B', 'CM', 'XAF', 'fr', 'Africa/Douala', 'Yaoundé');
select zz_tests.expect((select count(*) from public.promotions) = 0 and (select count(*) from public.loyalty_accounts) = 0,
  '20 : B ne voit ni les promotions ni les clients fidèles de A');
select zz_tests.expect_error(format($q$select public.apply_promotion(%L, %L)$q$, current_setting('t.o2'), current_setting('t.pamount')),
  '42501', '21 : B n''applique rien sur les commandes de A');

reset role;
rollback;
select 'TOUS LES CONTRÔLES 012 SONT PASSÉS (21)' as resultat;
