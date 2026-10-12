-- =============================================================================
-- Resto — contrôles de la migration 023 (favoris et listes, coupons, commande
-- groupée, notifications, anniversaire). À coller APRÈS 023.
-- Transaction annulée à la fin. La dernière ligne « resultat » n'apparaît que si tout est passé.
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

-- A = restaurant, C = organisateur, D = convive
insert into auth.users (id, email, aud, role, raw_user_meta_data, email_confirmed_at) values
  ('00000000-0000-0000-0000-00000000a023', 'owner.a23@resto.test', 'authenticated', 'authenticated', '{}', now()),
  ('00000000-0000-0000-0000-00000000c023', 'client.c23@resto.test', 'authenticated', 'authenticated', '{}', now()),
  ('00000000-0000-0000-0000-00000000d023', 'client.d23@resto.test', 'authenticated', 'authenticated', '{}', now());

set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000a023","role":"authenticated"}';
select set_config('t.a', public.create_organization('Fidèle 23', 'CM', 'XAF', 'fr', 'Africa/Douala', 'Zzville', null, 'A')::text, true);
select set_config('t.org', current_setting('t.a')::jsonb ->> 'organization_id', true);
select set_config('t.br', current_setting('t.a')::jsonb ->> 'brand_id', true);
select set_config('t.b', current_setting('t.a')::jsonb ->> 'branch_id', true);
with ins as (insert into public.menu_categories (organization_id, brand_id, name)
  values (current_setting('t.org')::uuid, current_setting('t.br')::uuid, 'Plats') returning id)
select set_config('t.cat', (select id::text from ins), true);
select set_config('t.it', public.create_menu_item(current_setting('t.cat')::uuid, 'Ndolé', null, 'food')::text, true);
select set_config('t.v', (select id::text from public.item_variants where item_id = current_setting('t.it')::uuid), true);
insert into public.menu_item_branches (organization_id, brand_id, item_id, branch_id)
values (current_setting('t.org')::uuid, current_setting('t.br')::uuid, current_setting('t.it')::uuid, current_setting('t.b')::uuid);
select public.set_price(current_setting('t.b')::uuid, current_setting('t.v')::uuid, null, 'default', 3000);
update public.branches set is_published = true, accepts_online_orders = true where id = current_setting('t.b')::uuid;
insert into public.loyalty_programs (organization_id, active, birthday_points) values (current_setting('t.org')::uuid, true, 50);
with ins as (insert into public.promotions (organization_id, name, kind, percent, code, is_public)
  values (current_setting('t.org')::uuid, 'Bienvenue', 'percent', 10, 'BIENVENUE', true) returning id)
select set_config('t.promo', (select id::text from ins), true);
with ins as (insert into public.promotions (organization_id, name, kind, percent, code)
  values (current_setting('t.org')::uuid, 'Interne', 'percent', 50, 'PERSONNEL') returning id)
select set_config('t.secret', (select id::text from ins), true);

-- ------------------------------------------------------------- client C : favoris, listes, coupons
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000c023","role":"authenticated"}';
insert into public.customer_profiles (full_name, birthday) values ('Awa Ndiaye', (current_date - interval '36 years')::date);
insert into public.customer_item_favorites (item_id) values (current_setting('t.it')::uuid);
select zz_tests.expect((public.my_saved_items() -> 'favorites' -> 0 ->> 'available')::boolean
  and (public.my_saved_items() -> 'favorites' -> 0 ->> 'price_minor')::int = 3000,
  '1 : plat favori avec son prix et sa disponibilité');
with ins as (insert into public.customer_lists (name) values ('À tester') returning id)
select set_config('t.list', (select id::text from ins), true);
insert into public.customer_list_items (list_id, item_id) values (current_setting('t.list')::uuid, current_setting('t.it')::uuid);
select zz_tests.expect(jsonb_array_length(public.my_saved_items() -> 'lists' -> 0 -> 'items') = 1, '2 : liste personnelle');
select public.save_coupon(current_setting('t.promo')::uuid);
select zz_tests.expect((public.my_coupons() -> 0 ->> 'code') = 'BIENVENUE' and (public.my_coupons() -> 0 ->> 'usable')::boolean,
  '3 : coupon public enregistré et utilisable');
select zz_tests.expect_error(format($q$select public.save_coupon(%L)$q$, current_setting('t.secret')),
  'resto.promotion_unavailable', '4 : une promotion non publique ne peut pas être enregistrée');

-- ------------------------------------------------------------- commande groupée
select set_config('t.g', public.create_group_order(current_setting('t.b')::uuid, 'Awa')::text, true);
select set_config('t.tok', current_setting('t.g')::jsonb ->> 'token', true);
select public.add_group_lines(current_setting('t.tok'), jsonb_build_array(jsonb_build_object('variant_id', current_setting('t.v'), 'quantity', 1)));

set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000d023","role":"authenticated"}';
select zz_tests.expect((select count(*) from public.customer_item_favorites) = 0 and (select count(*) from public.customer_coupons) = 0,
  '5 : D ne voit ni les favoris ni les coupons de C');
select public.add_group_lines(current_setting('t.tok'),
  jsonb_build_array(jsonb_build_object('variant_id', current_setting('t.v'), 'quantity', 2, 'note', 'sans piment')), 'Ben');
select zz_tests.expect(jsonb_array_length(public.group_order(current_setting('t.tok')) -> 'lines') = 2
  and not (public.group_order(current_setting('t.tok')) ->> 'is_host')::boolean
  and exists (select 1 from jsonb_array_elements(public.group_order(current_setting('t.tok')) -> 'lines') l
               where l ->> 'participant_name' = 'Ben' and (l ->> 'mine')::boolean),
  '6 : le convive voit la commande groupée et ses plats');
select zz_tests.expect_error(format($q$select public.place_group_order(%L, 'takeaway')$q$, current_setting('t.tok')),
  '42501', '7 : seul l''organisateur valide');
select zz_tests.expect_error(format($q$select public.remove_group_line(%L)$q$,
    (select l ->> 'id' from jsonb_array_elements(public.group_order(current_setting('t.tok')) -> 'lines') l
      where not (l ->> 'mine')::boolean)),
  '42501', '8 : un convive ne retire pas les plats des autres');

set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000c023","role":"authenticated"}';
select zz_tests.expect((select count(*) from public.customer_notifications where kind = 'group_joined') = 1,
  '9 : l''organisateur est prévenu de l''arrivée d''un convive');
select set_config('t.res', public.place_group_order(current_setting('t.tok'), 'takeaway', '+237 600 00 00 00', 'Awa')::text, true);
select set_config('t.o', current_setting('t.res')::jsonb ->> 'order_id', true);
select zz_tests.expect((public.group_order(current_setting('t.tok')) ->> 'status') = 'placed', '10 : commande groupée validée');
select zz_tests.expect_error(format($q$select public.add_group_lines(%L, %L::jsonb)$q$, current_setting('t.tok'),
    jsonb_build_array(jsonb_build_object('variant_id', current_setting('t.v'), 'quantity', 1))),
  'resto.group_closed', '11 : plus d''ajout après validation');

set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000d023","role":"authenticated"}';
select zz_tests.expect((select count(*) from public.customer_notifications where kind = 'group_placed') = 1,
  '12 : le convive est prévenu de la validation');

-- ------------------------------------------------------------- restaurant A
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000a023","role":"authenticated"}';
select zz_tests.expect((select count(*) = 2 and bool_or(note like 'Ben%sans piment') from public.order_items
                         where order_id = current_setting('t.o')::uuid),
  '13 : une seule commande au restaurant, chaque plat porte le prénom du convive');
select zz_tests.expect((select count(*) from public.customer_notifications) = 0, '14 : le restaurant ne lit pas les notifications des clients');
select public.accept_online_order(current_setting('t.o')::uuid, 15);

-- ------------------------------------------------------------- notifications et anniversaire de C
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000c023","role":"authenticated"}';
select zz_tests.expect((select count(*) from public.customer_notifications where kind = 'order_accepted') = 1,
  '15 : notification « commande acceptée »');
select zz_tests.expect(jsonb_array_length(public.claim_birthday_rewards()) = 0,
  '16 : anniversaire saisi il y a moins de 30 jours : pas de cadeau');
reset role;
alter table public.customer_profiles disable trigger customer_profiles_birthday;
update public.customer_profiles set birthday_set_at = now() - interval '60 days' where user_id = '00000000-0000-0000-0000-00000000c023';
alter table public.customer_profiles enable trigger customer_profiles_birthday;
set local role authenticated;
-- Créditer puis vérifier dans deux instructions distinctes (une instruction ne voit pas ses propres écritures).
select set_config('t.gift', public.claim_birthday_rewards()::text, true);
select zz_tests.expect((current_setting('t.gift')::jsonb -> 0 ->> 'points')::int = 50
  and (select points from public.loyalty_accounts where user_id = '00000000-0000-0000-0000-00000000c023') = 50,
  '17 : points d''anniversaire crédités chez le restaurant où le client a commandé');
select zz_tests.expect(jsonb_array_length(public.claim_birthday_rewards()) = 0
  and (select points from public.loyalty_accounts where user_id = '00000000-0000-0000-0000-00000000c023') = 50,
  '18 : une seule fois par an');
update public.customer_profiles set birthday = birthday - 1;
select zz_tests.expect((select birthday_set_at > now() - interval '1 minute' from public.customer_profiles),
  '19 : changer sa date d''anniversaire relance le délai de 30 jours');
select public.mark_notifications_read();
select zz_tests.expect((select count(*) from public.customer_notifications where read_at is null) = 0, '20 : notifications lues');

reset role;
rollback;
select 'TOUS LES CONTRÔLES 023 SONT PASSÉS (20)' as resultat;
