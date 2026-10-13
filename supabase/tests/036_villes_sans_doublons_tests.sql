-- =============================================================================
-- Resto — contrôles de la migration 036 (une ville = une seule entrée).
-- À coller APRÈS 036. Transaction annulée à la fin.
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
  ('00000000-0000-0000-0000-00000000a036', 'owner.a36@resto.test', 'authenticated', 'authenticated', '{}', now()),
  ('00000000-0000-0000-0000-00000000b036', 'owner.b36@resto.test', 'authenticated', 'authenticated', '{}', now()),
  ('00000000-0000-0000-0000-00000000c036', 'owner.c36@resto.test', 'authenticated', 'authenticated', '{}', now());

set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000a036","role":"authenticated"}';
select set_config('t.a', (public.create_organization('Villes A36', 'CM', 'XAF', 'fr', 'Africa/Douala', 'Zzvilletest') ->> 'branch_id'), true);
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000b036","role":"authenticated"}';
select set_config('t.b', (public.create_organization('Villes B36', 'CM', 'XAF', 'fr', 'Africa/Douala', 'ZZVILLETEST') ->> 'branch_id'), true);
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000c036","role":"authenticated"}';
select set_config('t.c', (public.create_organization('Villes C36', 'CM', 'XAF', 'fr', 'Africa/Douala', 'Zzautreville') ->> 'branch_id'), true);
-- Ville ressaisie avec des espaces autour.
update public.branches set city = '  Zzautreville  ' where id = current_setting('t.c')::uuid;

reset role;
update public.branches set is_published = true
 where id in (current_setting('t.a')::uuid, current_setting('t.b')::uuid, current_setting('t.c')::uuid);
select zz_tests.expect((select city from public.branches where id = current_setting('t.c')::uuid) = 'Zzautreville',
  '1 : la ville est enregistrée sans espaces autour');
set local role anon;

select zz_tests.expect((select count(*) from jsonb_array_elements(public.public_cities()) x
                         where lower(x ->> 'city') = 'zzvilletest') = 1,
  '2 : « Zzvilletest » et « ZZVILLETEST » ne forment qu''une seule ville');
select zz_tests.expect((select x ->> 'city' from jsonb_array_elements(public.public_cities()) x
                         where lower(x ->> 'city') = 'zzvilletest') = 'Zzvilletest',
  '3 : le nom affiché n''est pas tout en majuscules');
select zz_tests.expect((select (x ->> 'count')::integer from jsonb_array_elements(public.public_cities()) x
                         where lower(x ->> 'city') = 'zzvilletest') = 2,
  '4 : la ville compte ses deux restaurants');
select zz_tests.expect(jsonb_array_length(public.public_branch_cards(null, 'Zzvilletest')) = 2,
  '5 : la ville choisie montre les deux restaurants');
select zz_tests.expect(jsonb_array_length(public.public_branch_cards(null, 'Zzautreville')) = 1,
  '6 : la ville ressaisie avec des espaces reste trouvable');

reset role;
rollback;
select 'TOUS LES CONTRÔLES 036 SONT PASSÉS (6)' as resultat;
