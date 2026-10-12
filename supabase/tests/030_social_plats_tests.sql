-- =============================================================================
-- Resto — contrôles de la migration 030 (vues, J'aime et avis des plats
-- façon Facebook).
-- À coller APRÈS 030. Transaction annulée à la fin.
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
  ('00000000-0000-0000-0000-00000000a030', 'owner.a30@resto.test', 'authenticated', 'authenticated', '{}', now()),
  ('00000000-0000-0000-0000-00000000c030', 'client.c30@resto.test', 'authenticated', 'authenticated', '{}', now());

set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000a030","role":"authenticated"}';
select set_config('t.a', public.create_organization('Social 30', 'CM', 'XAF', 'fr', 'Africa/Douala', 'Socialville')::text, true);
select set_config('t.org', current_setting('t.a')::jsonb ->> 'organization_id', true);
select set_config('t.br', current_setting('t.a')::jsonb ->> 'brand_id', true);
select set_config('t.b', current_setting('t.a')::jsonb ->> 'branch_id', true);
with ins as (insert into public.menu_categories (organization_id, brand_id, name)
  values (current_setting('t.org')::uuid, current_setting('t.br')::uuid, 'Grillades') returning id)
select set_config('t.cat', (select id::text from ins), true);
select set_config('t.it', public.create_menu_item(current_setting('t.cat')::uuid, 'Poisson braisé', null, 'food')::text, true);
select set_config('t.v', (select id::text from public.item_variants where item_id = current_setting('t.it')::uuid), true);
insert into public.menu_item_branches (organization_id, brand_id, item_id, branch_id)
values (current_setting('t.org')::uuid, current_setting('t.br')::uuid, current_setting('t.it')::uuid, current_setting('t.b')::uuid);
select public.set_price(current_setting('t.b')::uuid, current_setting('t.v')::uuid, null, 'default', 6000);
update public.branches set is_published = true where id = current_setting('t.b')::uuid;

-- ------------------------------------------------------------- visiteurs anonymes
set local role anon;
set local request.jwt.claims = '{"role":"anon"}';
select public.record_item_views(array[current_setting('t.it')::uuid], 'appareil-anonyme-1');
select public.record_item_views(array[current_setting('t.it')::uuid], 'appareil-anonyme-1');
select public.record_item_views(array[current_setting('t.it')::uuid], 'appareil-anonyme-2');
select public.record_item_views(array[current_setting('t.it')::uuid], 'court');
select zz_tests.expect((public.public_item_social(current_setting('t.b')::uuid) -> current_setting('t.it') ->> 'views')::int = 2,
  '1 : vues dédoublonnées (une par visiteur et par jour)');
select zz_tests.expect_error(format($q$select public.toggle_item_like(%L)$q$, current_setting('t.it')), '42501',
  '2 : il faut un compte pour aimer un plat');

-- ------------------------------------------------------------- client connecté
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000c030","role":"authenticated"}';
select zz_tests.expect((public.toggle_item_like(current_setting('t.it')::uuid) ->> 'likes')::int = 1, '3 : J''aime sur un plat');
select set_config('t.cm', public.add_item_comment(current_setting('t.it')::uuid, 'Délicieux, bien épicé !')::text, true);
select zz_tests.expect_error(format($q$select public.add_item_comment(%L, '   ')$q$, current_setting('t.it')),
  'resto.invalid_comment', '4 : avis vide refusé');
insert into public.customer_item_favorites (item_id) values (current_setting('t.it')::uuid);
select set_config('t.s', (public.public_item_social(current_setting('t.b')::uuid) -> current_setting('t.it'))::text, true);
select zz_tests.expect((current_setting('t.s')::jsonb ->> 'liked')::boolean and (current_setting('t.s')::jsonb ->> 'favorite')::boolean
  and (current_setting('t.s')::jsonb ->> 'comments')::int = 1 and (current_setting('t.s')::jsonb ->> 'favorites')::int = 1,
  '5 : le client voit ses réactions et les compteurs (avis, cœurs)');
select zz_tests.expect(jsonb_array_length(public.public_item_comments(current_setting('t.it')::uuid)) = 1
  and (public.public_item_comments(current_setting('t.it')::uuid) -> 0 ->> 'mine')::boolean,
  '6 : avis publié visible');
select zz_tests.expect_error(format($q$select public.moderate_item_comment(%L, true, 'Hors sujet')$q$, current_setting('t.cm')),
  '42501', '7 : un client ne modère pas les avis');

-- ------------------------------------------------------------- le restaurant
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000a030","role":"authenticated"}';
select zz_tests.expect((public.menu_item_stats(current_setting('t.b')::uuid) -> current_setting('t.it') ->> 'views')::int = 2
  and (public.menu_item_stats(current_setting('t.b')::uuid) -> current_setting('t.it') ->> 'likes')::int = 1,
  '8 : vues et J''aime dans les indicateurs du module Menus');
select public.moderate_item_comment(current_setting('t.cm')::uuid, true, 'Hors sujet');
select zz_tests.expect((public.public_item_social(current_setting('t.b')::uuid) -> current_setting('t.it') ->> 'comments')::int = 0,
  '9 : avis masqué par le restaurant, compteur à jour');

reset role;
rollback;
select 'TOUS LES CONTRÔLES 030 SONT PASSÉS (9)' as resultat;
