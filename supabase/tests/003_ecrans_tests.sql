-- =============================================================================
-- Resto — contrôles de la migration 003 (fonctions des premiers écrans).
-- À coller APRÈS 003. Transaction annulée à la fin : aucune donnée ne reste.
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

insert into auth.users (id, email, aud, role, raw_user_meta_data, email_confirmed_at) values
  ('00000000-0000-0000-0000-00000000a003', 'owner.a3@resto.test', 'authenticated', 'authenticated', '{"display_name":"Owner A3"}', now()),
  ('00000000-0000-0000-0000-00000000b003', 'owner.b3@resto.test', 'authenticated', 'authenticated', '{}', now());

-- ------------------------------------------------------------- visiteur
set local role anon;
select zz_tests.expect((select count(*) from public.list_timezones() z where z = 'Africa/Douala') = 1
  and not exists (select 1 from public.list_timezones() z where z like 'posix/%' or z like 'Etc/%'),
  '1 : fuseaux IANA lisibles sans compte, sans alias techniques');
select zz_tests.expect_error($q$select public.set_opening_hours(gen_random_uuid(), '[]')$q$, '42501',
  '2 : un visiteur ne modifie aucun horaire');

-- ------------------------------------------------------------- propriétaire A
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000a003","role":"authenticated"}';
select set_config('t.a', public.create_organization('Test 003', 'CM', 'XAF', 'fr', 'Africa/Douala', 'Douala')::text, true);
select set_config('t.org', current_setting('t.a')::jsonb ->> 'organization_id', true);
select set_config('t.br', current_setting('t.a')::jsonb ->> 'branch_id', true);

select public.set_opening_hours(current_setting('t.br')::uuid,
  '[{"weekday":1,"opens_at":"08:00","closes_at":"14:00"},{"weekday":1,"opens_at":"18:00","closes_at":"01:00"},
    {"weekday":6,"opens_at":"00:00","closes_at":"24:00"}]');
select zz_tests.expect((select count(*) from public.branch_opening_hours where branch_id = current_setting('t.br')::uuid) = 3,
  '3 : semaine enregistrée d''un bloc (après minuit et 24 h acceptés)');

select public.set_opening_hours(current_setting('t.br')::uuid, '[{"weekday":2,"opens_at":"09:00","closes_at":"17:00"}]');
select zz_tests.expect((select count(*) from public.branch_opening_hours where branch_id = current_setting('t.br')::uuid) = 1,
  '4 : un nouvel enregistrement remplace toute la semaine');

select zz_tests.expect_error(format($q$select public.set_opening_hours(%L, '[{"weekday":8,"opens_at":"09:00","closes_at":"17:00"}]')$q$,
  current_setting('t.br')), 'resto.invalid_hours', '5 : jour inexistant refusé');
select zz_tests.expect_error(format($q$select public.set_opening_hours(%L, '[{"weekday":1,"opens_at":"25:99","closes_at":"17:00"}]')$q$,
  current_setting('t.br')), 'resto.invalid_hours', '6 : heure invalide refusée');
select zz_tests.expect_error(format($q$select public.set_opening_hours(%L, '[{"weekday":1,"opens_at":"09:00","closes_at":"09:00"}]')$q$,
  current_setting('t.br')), 'resto.invalid_hours', '7 : plage vide refusée');
select zz_tests.expect((select count(*) from public.branch_opening_hours where branch_id = current_setting('t.br')::uuid) = 1,
  '8 : un refus ne touche pas aux horaires existants');

select zz_tests.expect((select count(*) from public.audit_entries(current_setting('t.org')::uuid)) > 0
  and (select actor_name from public.audit_entries(current_setting('t.org')::uuid) limit 1) = 'Owner A3',
  '9 : journal lisible avec le nom de l''auteur');

-- ------------------------------------------------------------- propriétaire B (autre organisation)
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000b003","role":"authenticated"}';
select zz_tests.expect_error(format($q$select public.set_opening_hours(%L, '[]')$q$, current_setting('t.br')),
  '42501', '10 : B ne modifie pas les horaires de A');
select zz_tests.expect_error(format($q$select * from public.audit_entries(%L)$q$, current_setting('t.org')),
  '42501', '11 : B ne lit pas le journal de A');

reset role;
rollback;
select 'TOUS LES CONTRÔLES 003 SONT PASSÉS (11)' as resultat;
