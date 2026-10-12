-- =============================================================================
-- Resto — contrôles de la migration 026 (page restaurant côté client : photo
-- d'ambiance, étiquettes libres des plats, ventes, best-seller).
-- À coller APRÈS 026. Transaction annulée à la fin.
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
  ('00000000-0000-0000-0000-00000000a026', 'owner.a26@resto.test', 'authenticated', 'authenticated', '{}', now()),
  ('00000000-0000-0000-0000-00000000c026', 'client.c26@resto.test', 'authenticated', 'authenticated', '{}', now());

set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000a026","role":"authenticated"}';
select set_config('t.a', public.create_organization('Jardin 26', 'CM', 'XAF', 'fr', 'Africa/Douala', 'Jardinville')::text, true);
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

update public.menu_items set tags = array['  Piment   doux ', 'Halal', 'halal', ''] where id = current_setting('t.it')::uuid;
select zz_tests.expect((select tags = '{Piment doux,Halal}' from public.menu_items where id = current_setting('t.it')::uuid),
  '1 : étiquettes libres nettoyées (espaces, doublons, vides)');
select zz_tests.expect_error(format($q$update public.menu_items set tags = array[repeat('x', 31)] where id = %L$q$, current_setting('t.it')),
  'resto.invalid_tag', '2 : étiquette de plus de 30 caractères refusée');
select zz_tests.expect_error(format($q$update public.menu_items set tags = array['a','b','c','d','e','f','g','h','i','j','k'] where id = %L$q$, current_setting('t.it')),
  '23514', '3 : 10 étiquettes au plus par plat');
select zz_tests.expect_error(format($q$update public.branches set cover_path = 'autre/photo.jpg' where id = %L$q$, current_setting('t.b')),
  'resto.invalid_image', '4 : photo d''ambiance hors du dossier de l''organisation refusée');

-- ------------------------------------------------------------- un client commande, le restaurant encaisse
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000c026","role":"authenticated"}';
select set_config('t.o', public.place_online_order(current_setting('t.b')::uuid, 'takeaway',
  jsonb_build_array(jsonb_build_object('variant_id', current_setting('t.v'), 'quantity', 2))) ->> 'order_id', true);
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000a026","role":"authenticated"}';
select public.accept_online_order(current_setting('t.o')::uuid, 15);
select set_config('t.s', public.open_cash_session(current_setting('t.reg')::uuid, 0)::text, true);
select public.take_payment(current_setting('t.o')::uuid, current_setting('t.s')::uuid, current_setting('t.cash')::uuid, 9000);

select zz_tests.expect((public.menu_item_stats(current_setting('t.b')::uuid) -> current_setting('t.it') ->> 'sold_30d')::int = 2,
  '9 : indicateurs du plat pour l''équipe (ventes, avis, favoris)');

-- ------------------------------------------------------------- carte publique (visiteur)
set local role anon;
set local request.jwt.claims = '{"role":"anon"}';
select set_config('t.m', public.public_branch_menu(current_setting('t.b')::uuid)::text, true);
select zz_tests.expect((current_setting('t.m')::jsonb -> 'branch' ->> 'cover_path') = current_setting('t.org') || '/jardin.jpg',
  '5 : photo d''ambiance sur la page du restaurant');
select zz_tests.expect((current_setting('t.m')::jsonb -> 'categories' -> 0 -> 'items' -> 0 -> 'tags') = '["Piment doux", "Halal"]'::jsonb,
  '6 : étiquettes visibles par le client pour filtrer la carte');
select zz_tests.expect((current_setting('t.m')::jsonb -> 'categories' -> 0 -> 'items' -> 0 ->> 'sold_30d')::int = 2
  and (current_setting('t.m')::jsonb -> 'categories' -> 0 -> 'items' -> 0 ->> 'best_seller')::boolean,
  '7 : ventes des 30 derniers jours et badge best-seller');
select zz_tests.expect((select x ->> 'cover_path' from jsonb_array_elements(public.public_branch_cards(null, 'Jardinville')) x
                         where x ->> 'branch_id' = current_setting('t.b')) = current_setting('t.org') || '/jardin.jpg',
  '8 : la vitrine montre la photo d''ambiance');
select zz_tests.expect_error(format($q$select public.menu_item_stats(%L)$q$, current_setting('t.b')),
  '42501', '10 : un visiteur ne voit pas les indicateurs de l''équipe');

reset role;
rollback;
select 'TOUS LES CONTRÔLES 026 SONT PASSÉS (10)' as resultat;
