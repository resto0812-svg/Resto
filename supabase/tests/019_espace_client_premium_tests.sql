-- =============================================================================
-- Resto — contrôles de la migration 019 (espace client : profil, vitrine,
-- catalogue, villes, carte enrichie).
-- À coller APRÈS 019. Transaction annulée à la fin : aucune donnée ne reste.
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

-- A = restaurateur, C = client, D = autre client
insert into auth.users (id, email, aud, role, raw_user_meta_data, email_confirmed_at) values
  ('00000000-0000-0000-0000-00000000a019', 'owner.a19@resto.test', 'authenticated', 'authenticated', '{}', now()),
  ('00000000-0000-0000-0000-00000000c019', 'client.c19@resto.test', 'authenticated', 'authenticated', '{}', now()),
  ('00000000-0000-0000-0000-00000000d019', 'client.d19@resto.test', 'authenticated', 'authenticated', '{}', now());

set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000a019","role":"authenticated"}';
select set_config('t.a', public.create_organization('Vitrine 19', 'CM', 'XAF', 'fr', 'Africa/Douala', 'Zzville', null, 'Akwa')::text, true);
select set_config('t.org', current_setting('t.a')::jsonb ->> 'organization_id', true);
select set_config('t.brand', current_setting('t.a')::jsonb ->> 'brand_id', true);
select set_config('t.a1', current_setting('t.a')::jsonb ->> 'branch_id', true);
with ins as (insert into public.menu_categories (organization_id, brand_id, name)
  values (current_setting('t.org')::uuid, current_setting('t.brand')::uuid, 'Plats') returning id)
select set_config('t.cat', (select id::text from ins), true);
select set_config('t.item', public.create_menu_item(current_setting('t.cat')::uuid, 'Ndolé royal', 'Aux crevettes', 'food')::text, true);
select set_config('t.var', (select id::text from public.item_variants where item_id = current_setting('t.item')::uuid), true);
insert into public.menu_item_branches (organization_id, brand_id, item_id, branch_id)
values (current_setting('t.org')::uuid, current_setting('t.brand')::uuid, current_setting('t.item')::uuid, current_setting('t.a1')::uuid);
select public.set_price(current_setting('t.a1')::uuid, current_setting('t.var')::uuid, null, 'default', 4500);
update public.menu_items set image_path = current_setting('t.org') || '/' || current_setting('t.item') || '/p1.jpg',
       gallery_paths = array[current_setting('t.org') || '/' || current_setting('t.item') || '/p2.jpg'], prep_minutes = 20
 where id = current_setting('t.item')::uuid;
update public.brands set slogan = 'Le vrai goût' where id = current_setting('t.brand')::uuid;
update public.branches set is_published = true, latitude = 4.05, longitude = 9.7 where id = current_setting('t.a1')::uuid;

-- ------------------------------------------------------------- vitrine publique (sans compte)
set local role anon;
select set_config('t.cards', public.public_branch_cards(null, 'Zzville')::text, true);
select zz_tests.expect(jsonb_array_length(current_setting('t.cards')::jsonb) = 1
  and (current_setting('t.cards')::jsonb -> 0 ->> 'slogan') = 'Le vrai goût'
  and (current_setting('t.cards')::jsonb -> 0 ->> 'cover_path') like '%/p1.jpg'
  and (current_setting('t.cards')::jsonb -> 0 ->> 'prep_minutes') is not null,
  '1 : carte du restaurant publiée (slogan, photo de couverture, préparation)');
select zz_tests.expect(exists (select 1 from jsonb_array_elements(public.public_cities()) c where c ->> 'city' = 'Zzville'),
  '2 : ville desservie listée');
select zz_tests.expect((public.public_catalog('Zzville') -> 0 ->> 'price_minor')::int = 4500,
  '3 : catalogue global : plat, photo et prix');
select set_config('t.menu', public.public_branch_menu(current_setting('t.a1')::uuid)::text, true);
select zz_tests.expect((current_setting('t.menu')::jsonb -> 'brand' ->> 'slogan') = 'Le vrai goût'
  and jsonb_array_length(current_setting('t.menu')::jsonb -> 'categories' -> 0 -> 'items' -> 0 -> 'gallery_paths') = 1
  and (current_setting('t.menu')::jsonb -> 'categories' -> 0 -> 'items' -> 0 ->> 'prep_minutes')::int = 20,
  '4 : carte enrichie (slogan, galerie, préparation)');

set local role authenticated;
update public.branches set vacation_mode = true, accepts_online_orders = true where id = current_setting('t.a1')::uuid;
set local role anon;
select zz_tests.expect((public.public_branch_menu(current_setting('t.a1')::uuid) -> 'branch' ->> 'accepts_online_orders')::boolean = false
  and (public.public_branch_menu(current_setting('t.a1')::uuid) -> 'branch' ->> 'open_now')::boolean = false,
  '5 : mode vacances : affiché fermé, commandes en ligne suspendues');

-- ------------------------------------------------------------- profil client
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000c019","role":"authenticated"}';
select zz_tests.expect_error(format($q$select public.place_online_order(%L, 'takeaway', %L::jsonb)$q$,
  current_setting('t.a1'), jsonb_build_array(jsonb_build_object('variant_id', current_setting('t.var'), 'quantity', 1))::text),
  'resto.online_orders_closed', '9 : pas de commande en ligne pendant les vacances');
insert into public.customer_profiles (full_name, phone, allergies, preferred_payment, prefs)
values ('Michel B.', '+237 600 00 00 00', '{peanuts}', 'mobile_wallet', '{"promotions": true}');
select zz_tests.expect((select full_name = 'Michel B.' and allergies = '{peanuts}' from public.customer_profiles),
  '6 : le client enregistre son profil et ses allergies');
select zz_tests.expect_error($q$update public.customer_profiles set allergies = '{plutonium}'$q$,
  'resto.invalid_allergen', '7 : allergie inconnue refusée');
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000d019","role":"authenticated"}';
select zz_tests.expect((select count(*) from public.customer_profiles) = 0, '8 : le profil d''un client reste privé');

reset role;
rollback;
select 'TOUS LES CONTRÔLES 019 SONT PASSÉS (9)' as resultat;
