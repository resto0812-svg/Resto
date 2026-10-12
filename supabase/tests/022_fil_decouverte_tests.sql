-- =============================================================================
-- Resto — contrôles de la migration 022 (fil de découverte, interactions,
-- vues dédoublonnées, commentaires modérés). À coller APRÈS 022.
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

insert into auth.users (id, email, aud, role, raw_user_meta_data, email_confirmed_at) values
  ('00000000-0000-0000-0000-00000000a022', 'owner.a22@resto.test', 'authenticated', 'authenticated', '{}', now()),
  ('00000000-0000-0000-0000-00000000b022', 'owner.b22@resto.test', 'authenticated', 'authenticated', '{}', now()),
  ('00000000-0000-0000-0000-00000000c022', 'client.c22@resto.test', 'authenticated', 'authenticated', '{}', now());

set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000a022","role":"authenticated"}';
select set_config('t.a', public.create_organization('Fil 22', 'CM', 'XAF', 'fr', 'Africa/Douala', 'Wwville', null, 'A')::text, true);
select set_config('t.org', current_setting('t.a')::jsonb ->> 'organization_id', true);
select set_config('t.brand', current_setting('t.a')::jsonb ->> 'brand_id', true);
select set_config('t.a1', current_setting('t.a')::jsonb ->> 'branch_id', true);
update public.branches set is_published = true where id = current_setting('t.a1')::uuid;
with ins as (
  insert into public.ad_campaigns (organization_id, brand_id, format, title, media, status, daily_budget_minor, currency)
  values (current_setting('t.org')::uuid, current_setting('t.brand')::uuid, 'video', 'Croissant beurre',
          jsonb_build_array(jsonb_build_object('kind', 'video', 'path', current_setting('t.org') || '/v.mp4')), 'active', 5000, 'XAF')
  returning id)
select set_config('t.ad', (select id::text from ins), true);
with ins as (
  insert into public.ad_campaigns (organization_id, brand_id, format, title, status)
  values (current_setting('t.org')::uuid, current_setting('t.brand')::uuid, 'classified', '-20 % ce midi', 'active')
  returning id)
select set_config('t.cl', (select id::text from ins), true);

-- ------------------------------------------------------------- visiteurs anonymes (sans identité)
set local role anon;
set local request.jwt.claims = '{"role":"anon"}';
select zz_tests.expect(jsonb_array_length(public.public_feed('Wwville')) = 2
  and (public.public_feed('Wwville') -> 0 ->> 'sponsored')::boolean
  and (public.public_feed('Wwville') -> 0 ->> 'id') = current_setting('t.ad'),
  '1 : fil public, contenu sponsorisé signalé et placé en tête');
select public.record_ad_view(current_setting('t.ad')::uuid, 'appareil-anonyme-1');
select public.record_ad_view(current_setting('t.ad')::uuid, 'appareil-anonyme-1');
select public.record_ad_view(current_setting('t.ad')::uuid, 'appareil-anonyme-2');
select public.record_ad_view(current_setting('t.ad')::uuid, 'court');
select public.record_ad_share(current_setting('t.ad')::uuid);
select zz_tests.expect_error(format($q$select public.toggle_ad_like(%L)$q$, current_setting('t.ad')), '42501',
  '2 : il faut un compte pour aimer');

-- ------------------------------------------------------------- client C
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000c022","role":"authenticated"}';
select public.record_ad_view(current_setting('t.ad')::uuid);
select zz_tests.expect((public.toggle_ad_like(current_setting('t.ad')::uuid) ->> 'liked')::boolean, '3 : J''aime');
select zz_tests.expect((public.toggle_ad_save(current_setting('t.ad')::uuid) ->> 'saves')::int = 1, '4 : enregistré');
select set_config('t.cm', public.add_ad_comment(current_setting('t.ad')::uuid, 'Il a l''air délicieux !')::text, true);
select zz_tests.expect_error(format($q$select public.add_ad_comment(%L, '   ')$q$, current_setting('t.ad')),
  'resto.invalid_comment', '5 : commentaire vide refusé');
select zz_tests.expect((public.public_feed('Wwville') -> 0 ->> 'liked')::boolean and (public.public_feed('Wwville') -> 0 ->> 'saved')::boolean,
  '6 : le fil indique ce que le client a aimé et enregistré');
select zz_tests.expect_error(format($q$update public.ad_campaigns set likes = 999 where id = %L$q$, current_setting('t.ad')),
  '42501', '7 : un client ne modifie pas une campagne');
select zz_tests.expect(not public.attribute_ad_order(gen_random_uuid(), current_setting('t.ad')::uuid),
  '7b : une commande qui n''est pas la sienne n''est pas rattachée');

-- ------------------------------------------------------------- restaurant A
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000a022","role":"authenticated"}';
select zz_tests.expect((select views = 3 and reach = 3 and likes = 1 and saves = 1 and comments = 1 and shares = 1
                          from public.ad_campaigns where id = current_setting('t.ad')::uuid),
  '8 : vues dédoublonnées (3), portée, J''aime, enregistrements, commentaires, partages');
select zz_tests.expect_error(format($q$update public.ad_campaigns set likes = 999 where id = %L$q$, current_setting('t.ad')),
  '42501', '9 : le restaurant ne gonfle pas ses statistiques');
select zz_tests.expect_error(format($q$select public.moderate_ad_comment(%L, true)$q$, current_setting('t.cm')),
  'resto.reason_required', '10 : masquer un commentaire exige un motif');
select public.moderate_ad_comment(current_setting('t.cm')::uuid, true, 'Hors sujet');
select zz_tests.expect((select comments from public.ad_campaigns where id = current_setting('t.ad')::uuid) = 0
  and jsonb_array_length(public.public_ad_comments(current_setting('t.ad')::uuid)) = 0,
  '11 : commentaire masqué : retiré du fil et des compteurs');

-- ------------------------------------------------------------- autre restaurant B
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000b022","role":"authenticated"}';
select public.create_organization('Autre 22', 'CM', 'XAF', 'fr', 'Africa/Douala', 'Yaoundé');
select zz_tests.expect((select count(*) from public.ad_comments) = 0, '12 : B ne lit pas les commentaires de A');
select zz_tests.expect_error(format($q$select public.moderate_ad_comment(%L, false)$q$, current_setting('t.cm')),
  '42501', '13 : B ne modère pas les commentaires de A');

reset role;
rollback;
select 'TOUS LES CONTRÔLES 022 SONT PASSÉS (14)' as resultat;
