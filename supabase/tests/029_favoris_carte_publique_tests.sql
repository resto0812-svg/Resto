-- =============================================================================
-- Resto — contrôles de la migration 029 (favoris des plats sur la
-- carte publique).
-- À coller APRÈS 029. Transaction annulée à la fin.
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
  ('00000000-0000-0000-0000-00000000a029', 'owner.a29@resto.test', 'authenticated', 'authenticated', '{}', now()),
  ('00000000-0000-0000-0000-00000000c029', 'client.c29@resto.test', 'authenticated', 'authenticated', '{}', now());

set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000a029","role":"authenticated"}';
select set_config('t.a', public.create_organization('Favoris 29', 'CM', 'XAF', 'fr', 'Africa/Douala', 'Favville')::text, true);
select set_config('t.org', current_setting('t.a')::jsonb ->> 'organization_id', true);
select set_config('t.br', current_setting('t.a')::jsonb ->> 'brand_id', true);
select set_config('t.b', current_setting('t.a')::jsonb ->> 'branch_id', true);
with ins as (insert into public.menu_categories (organization_id, brand_id, name)
  values (current_setting('t.org')::uuid, current_setting('t.br')::uuid, 'Plats') returning id)
select set_config('t.cat', (select id::text from ins), true);
select set_config('t.it', public.create_menu_item(current_setting('t.cat')::uuid, 'Poulet DG', null, 'food')::text, true);
select set_config('t.v', (select id::text from public.item_variants where item_id = current_setting('t.it')::uuid), true);
insert into public.menu_item_branches (organization_id, brand_id, item_id, branch_id)
values (current_setting('t.org')::uuid, current_setting('t.br')::uuid, current_setting('t.it')::uuid, current_setting('t.b')::uuid);
select public.set_price(current_setting('t.b')::uuid, current_setting('t.v')::uuid, null, 'default', 5000);
update public.branches set is_published = true where id = current_setting('t.b')::uuid;

-- ------------------------------------------------------------- un client met le plat en favori
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000c029","role":"authenticated"}';
insert into public.customer_item_favorites (item_id) values (current_setting('t.it')::uuid);

-- ------------------------------------------------------------- un visiteur voit le nombre de favoris
set local role anon;
set local request.jwt.claims = '{"role":"anon"}';
select set_config('t.m', public.public_branch_menu(current_setting('t.b')::uuid)::text, true);
select zz_tests.expect((current_setting('t.m')::jsonb -> 'categories' -> 0 -> 'items' -> 0 ->> 'favorites')::int = 1,
  '1 : nombre de favoris du plat visible sur la carte publique');
select zz_tests.expect((current_setting('t.m')::jsonb -> 'categories' -> 0 -> 'items' -> 0) ? 'sold_30d'
  and (current_setting('t.m')::jsonb -> 'categories' -> 0 -> 'items' -> 0) ? 'reviews_count',
  '2 : les autres indicateurs sont toujours là');

reset role;
rollback;
select 'TOUS LES CONTRÔLES 029 SONT PASSÉS (2)' as resultat;
