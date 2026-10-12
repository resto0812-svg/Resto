-- =============================================================================
-- Resto — contrôles de la migration 001 (sécurité et règles métier).
-- À coller dans le SQL Editor APRÈS 001 et 002. Tout se passe dans une transaction
-- annulée à la fin : aucune donnée ne reste. Chaque contrôle réussi affiche
-- « OK n : … » ; au premier échec, le script s'arrête sur « ÉCHEC n : … ».
-- =============================================================================
begin;

-- Outils de contrôle (schéma temporaire, supprimé par le ROLLBACK final).
create schema zz_tests;
grant usage on schema zz_tests to anon, authenticated;

create function zz_tests.expect(p_ok boolean, p_label text) returns void
language plpgsql as $$
begin
  if p_ok is distinct from true then raise exception 'ÉCHEC %', p_label; end if;
  raise notice 'OK %', p_label;
end $$;

-- p_expected = message « resto.xxx » ou SQLSTATE (42501 droit, 23503 clé étrangère…)
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

create function zz_tests.rows(p_sql text) returns bigint language plpgsql as $$
declare n bigint;
begin
  execute p_sql;
  get diagnostics n = row_count;
  return n;
end $$;

-- Quatre comptes de test : propriétaire A, propriétaire B, futur serveur C, intrus D.
insert into auth.users (id, email, aud, role, raw_user_meta_data, email_confirmed_at) values
  ('00000000-0000-0000-0000-00000000a001', 'owner.a@resto.test', 'authenticated', 'authenticated', '{"display_name":"Owner A","locale":"fr"}', now()),
  ('00000000-0000-0000-0000-00000000b001', 'owner.b@resto.test', 'authenticated', 'authenticated', '{"display_name":"Owner B","locale":"en"}', now()),
  ('00000000-0000-0000-0000-00000000c001', 'waiter.c@resto.test', 'authenticated', 'authenticated', '{"display_name":"Waiter C"}', now()),
  ('00000000-0000-0000-0000-00000000d001', 'intrus.d@resto.test', 'authenticated', 'authenticated', '{}', now());

select zz_tests.expect((select count(*) from public.profiles where id::text like '00000000-0000-0000-0000-00000000%001') = 4,
  '1 : profils créés automatiquement à l''inscription');
select zz_tests.expect((select locale from public.profiles where id = '00000000-0000-0000-0000-00000000b001') = 'en',
  '2 : langue du profil reprise de l''inscription');

-- Matrice des permissions = docs/SECURITY.md §3
select zz_tests.expect((select count(*) from public.role_permissions) = 81, '3 : 81 couples rôle/permission');
select zz_tests.expect(
  (select count(*) from public.role_permissions where role_code = 'manager') = 17
  and not exists (select 1 from public.role_permissions where role_code = 'manager' and permission_code = 'members.manage')
  and not exists (select 1 from public.role_permissions where role_code = 'waiter' and permission_code = 'cash.close')
  and not exists (select 1 from public.role_permissions where role_code = 'kitchen' and permission_code = 'orders.write')
  and exists (select 1 from public.role_permissions where role_code = 'accountant' and permission_code = 'audit.read'),
  '4 : contrôles ponctuels de la matrice');

-- ------------------------------------------------------------- propriétaire A
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000a001","role":"authenticated"}';

select set_config('t.a', public.create_organization('Chez Léa', 'CM', 'XAF', 'fr', 'Africa/Douala', 'Douala', null, 'Akwa')::text, true);
select set_config('t.org_a', current_setting('t.a')::jsonb ->> 'organization_id', true);
select set_config('t.brand_a', current_setting('t.a')::jsonb ->> 'brand_id', true);
select set_config('t.br_a1', current_setting('t.a')::jsonb ->> 'branch_id', true);

select zz_tests.expect(
  (select role_code from public.memberships where organization_id = current_setting('t.org_a')::uuid) = 'owner'
  and (select slug from public.brands where id = current_setting('t.brand_a')::uuid) = 'chez-lea'
  and (select currency from public.branches where id = current_setting('t.br_a1')::uuid) = 'XAF',
  '5 : organisation + propriétaire + marque + établissement créés ensemble');

-- « insert … returning » = ce que fait l'application (régression corrigée par 002).
with ins as (
  insert into public.branches (organization_id, brand_id, name, slug, country_code, city, timezone, currency, default_locale)
  values (current_setting('t.org_a')::uuid, current_setting('t.brand_a')::uuid, 'Bonapriso', 'bonapriso',
          'CM', 'Douala', 'Africa/Douala', 'XAF', 'fr')
  returning id)
select set_config('t.br_a2', (select id::text from ins), true);

with ins as (
  insert into public.service_areas (organization_id, branch_id, name)
  values (current_setting('t.org_a')::uuid, current_setting('t.br_a1')::uuid, 'Terrasse') returning id)
select set_config('t.area_a1', (select id::text from ins), true);
insert into public.dining_tables (organization_id, branch_id, service_area_id, label, seats)
values (current_setting('t.org_a')::uuid, current_setting('t.br_a1')::uuid, current_setting('t.area_a1')::uuid, 'T1', 4);
select zz_tests.expect((select count(*) from public.dining_tables) = 1, '6 : propriétaire crée établissement, zone et table');

select zz_tests.expect_error(format(
  $q$insert into public.dining_tables (organization_id, branch_id, service_area_id, label)
     values (%L, %L, %L, 'T9')$q$, current_setting('t.org_a'), current_setting('t.br_a2'), current_setting('t.area_a1')),
  '23503', '7 : une table ne peut pas être rattachée à la zone d''un autre établissement');

select zz_tests.expect_error(
  $q$select public.create_organization('Mars', 'CM', 'XAF', 'fr', 'Mars/Olympus', 'Douala')$q$,
  'resto.invalid_timezone', '8 : fuseau horaire IANA invalide refusé');

select zz_tests.expect_error(format(
  $q$update public.branches set timezone = 'UTC+25' where id = %L$q$, current_setting('t.br_a1')),
  'resto.invalid_timezone', '9 : fuseau invalide refusé aussi en modification');

-- ------------------------------------------------------------- propriétaire B
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000b001","role":"authenticated"}';
select set_config('t.b', public.create_organization('Chez Léa', 'FR', 'EUR', 'en', 'Europe/Paris', 'Lyon')::text, true);
select set_config('t.org_b', current_setting('t.b')::jsonb ->> 'organization_id', true);

select zz_tests.expect((select slug from public.brands where organization_id = current_setting('t.org_b')::uuid) like 'chez-lea-%',
  '10 : nom de marque identique → identifiant public unique');
select zz_tests.expect((select count(*) from public.organizations) = 1, '11 : B ne voit que son organisation');
select zz_tests.expect((select count(*) from public.branches where organization_id = current_setting('t.org_a')::uuid) = 0
  and (select count(*) from public.brands where organization_id = current_setting('t.org_a')::uuid) = 0
  and (select count(*) from public.dining_tables) = 0
  and (select count(*) from public.memberships where organization_id = current_setting('t.org_a')::uuid) = 0,
  '12 : B ne voit aucune donnée de A');

select zz_tests.expect_error(format(
  $q$insert into public.brands (organization_id, name, slug) values (%L, 'Pirate', 'pirate')$q$, current_setting('t.org_a')),
  '42501', '13 : B ne crée pas de marque dans A');
select zz_tests.expect_error(format(
  $q$insert into public.branches (organization_id, brand_id, name, slug, country_code, city, timezone, currency, default_locale)
     values (%L, %L, 'X', 'x', 'FR', 'Lyon', 'Europe/Paris', 'EUR', 'en')$q$,
  current_setting('t.org_b'), current_setting('t.brand_a')),
  '23503', '14 : B ne rattache pas un établissement à une marque de A');
select zz_tests.expect(zz_tests.rows(format($q$update public.branches set name = 'Pirate' where id = %L$q$,
  current_setting('t.br_a1'))) = 0, '15 : B ne modifie pas un établissement de A');
select zz_tests.expect(zz_tests.rows(format($q$update public.organizations set name = 'Pirate' where id = %L$q$,
  current_setting('t.org_a'))) = 0, '16 : B ne modifie pas l''organisation A');
select zz_tests.expect_error(format($q$select public.invite_member(%L, 'x@resto.test', 'waiter', true)$q$,
  current_setting('t.org_a')), '42501', '17 : B n''invite personne dans A');
select zz_tests.expect_error(format($q$select * from public.org_members(%L)$q$, current_setting('t.org_a')),
  '42501', '18 : B ne liste pas les membres de A');
select zz_tests.expect((select count(*) from public.audit_log where organization_id = current_setting('t.org_a')::uuid) = 0,
  '19 : B ne lit pas le journal d''audit de A');
select zz_tests.expect(jsonb_array_length(public.my_memberships()) = 1, '20 : my_memberships ne renvoie que B');
select zz_tests.expect_error($q$insert into public.audit_log (action, entity) values ('x', 'y')$q$,
  '42501', '21 : personne n''écrit directement dans le journal d''audit');

-- ------------------------------------------------------------- invitations
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000a001","role":"authenticated"}';
select set_config('t.tok', public.invite_member(current_setting('t.org_a')::uuid, ' Waiter.C@resto.test ', 'waiter',
  false, array[current_setting('t.br_a1')::uuid]), true);
select zz_tests.expect(length(current_setting('t.tok')) = 64
  and (select count(*) from public.invitations where status = 'pending' and email = 'waiter.c@resto.test') = 1,
  '22 : invitation créée, e-mail normalisé, jeton de 64 caractères');
select zz_tests.expect_error(format($q$select public.invite_member(%L, 'z@resto.test', 'waiter', false)$q$,
  current_setting('t.org_a')), 'resto.branches_required', '23 : rôle limité sans établissement refusé');
select zz_tests.expect_error(format($q$select public.invite_member(%L, 'z@resto.test', 'waiter', false, array[%L::uuid])$q$,
  current_setting('t.org_a'), current_setting('t.b')::jsonb ->> 'branch_id'),
  'resto.invalid_branch', '24 : établissement d''une autre organisation refusé');

set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000d001","role":"authenticated"}';
select zz_tests.expect_error(format($q$select public.accept_invitation(%L)$q$, current_setting('t.tok')),
  'resto.invitation_wrong_account', '25 : un autre compte ne peut pas utiliser l''invitation');
select zz_tests.expect_error($q$select public.accept_invitation('jeton-invente')$q$,
  'resto.invitation_invalid', '26 : jeton inconnu refusé');

set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000c001","role":"authenticated"}';
select zz_tests.expect(public.accept_invitation(current_setting('t.tok')) = current_setting('t.org_a')::uuid,
  '27 : le bon compte accepte l''invitation');
select zz_tests.expect_error(format($q$select public.accept_invitation(%L)$q$, current_setting('t.tok')),
  'resto.invitation_invalid', '28 : invitation à usage unique');

-- ------------------------------------------------------------- serveur C (A1 seulement)
select zz_tests.expect((select count(*) from public.branches) = 1
  and (select id from public.branches) = current_setting('t.br_a1')::uuid, '29 : C ne voit que son établissement');
select zz_tests.expect(zz_tests.rows(format($q$update public.branches set name = 'X' where id = %L$q$,
  current_setting('t.br_a1'))) = 0, '30 : un serveur ne modifie pas l''établissement');
select zz_tests.expect_error(format(
  $q$insert into public.dining_tables (organization_id, branch_id, service_area_id, label) values (%L, %L, %L, 'T2')$q$,
  current_setting('t.org_a'), current_setting('t.br_a1'), current_setting('t.area_a1')),
  '42501', '31 : un serveur ne crée pas de table');
select zz_tests.expect((select count(*) from public.audit_log) = 0
  and (select count(*) from public.memberships) = 1
  and (select count(*) from public.invitations) = 0, '32 : C ne voit ni audit, ni équipe, ni invitations');
select zz_tests.expect_error(format($q$select public.invite_member(%L, 'z@resto.test', 'waiter', true)$q$,
  current_setting('t.org_a')), '42501', '33 : un serveur n''invite personne');

-- ------------------------------------------------------------- règles du propriétaire
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000a001","role":"authenticated"}';
select set_config('t.m_a', (select id::text from public.memberships
  where user_id = '00000000-0000-0000-0000-00000000a001' and organization_id = current_setting('t.org_a')::uuid), true);
select set_config('t.m_c', (select id::text from public.memberships
  where user_id = '00000000-0000-0000-0000-00000000c001'), true);

select zz_tests.expect_error(format($q$select public.revoke_membership(%L)$q$, current_setting('t.m_a')),
  'resto.last_owner', '34 : le dernier propriétaire ne peut pas partir');
select zz_tests.expect_error(format($q$select public.update_membership(%L, 'admin', true)$q$, current_setting('t.m_a')),
  'resto.last_owner', '35 : le dernier propriétaire ne peut pas être rétrogradé');
select zz_tests.expect((select count(*) from public.org_members(current_setting('t.org_a')::uuid)
  where email = 'waiter.c@resto.test') = 1, '36 : le propriétaire voit l''e-mail de ses membres');

select public.update_membership(current_setting('t.m_c')::uuid, 'manager', false, array[current_setting('t.br_a1')::uuid]);

set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000c001","role":"authenticated"}';
select zz_tests.expect(zz_tests.rows(format($q$update public.branches set phone = '+237 600 00 00 00' where id = %L$q$,
  current_setting('t.br_a1'))) = 1
  and zz_tests.rows(format($q$update public.branches set phone = 'x' where id = %L$q$, current_setting('t.br_a2'))) = 0,
  '37 : responsable promu : modifie A1, pas A2');
select zz_tests.expect(zz_tests.rows(format($q$update public.organizations set name = 'X' where id = %L$q$,
  current_setting('t.org_a'))) = 0, '38 : un responsable ne change pas les paramètres de l''organisation');

set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000a001","role":"authenticated"}';
select public.revoke_membership(current_setting('t.m_c')::uuid);
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000c001","role":"authenticated"}';
select zz_tests.expect((select count(*) from public.branches) = 0 and jsonb_array_length(public.my_memberships()) = 0,
  '39 : membre retiré : plus aucun accès, immédiatement');

-- ------------------------------------------------------------- audit
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000a001","role":"authenticated"}';
select zz_tests.expect(exists (select 1 from public.audit_log where entity = 'memberships' and action = 'update'
    and actor_id = '00000000-0000-0000-0000-00000000a001' and details -> 'new' ->> 'status' = 'revoked')
  and not exists (select 1 from public.audit_log where details::text like '%token_hash%'),
  '40 : audit des changements, sans jeton d''invitation');
select zz_tests.expect_error($q$delete from public.audit_log$q$, '42501', '41 : un propriétaire ne supprime pas l''audit');

reset role;
select zz_tests.expect_error($q$update public.audit_log set action = 'x'$q$, 'resto.audit_immutable',
  '42 : même l''administrateur SQL ne modifie pas l''audit');

-- ------------------------------------------------------------- quotas et anonymes
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000a001","role":"authenticated"}';
select public.create_organization('Deux', 'CM', 'XAF', 'fr', 'Africa/Douala', 'Yaoundé');
select public.create_organization('Trois', 'CM', 'XAF', 'fr', 'Africa/Douala', 'Kribi');
select zz_tests.expect_error($q$select public.create_organization('Quatre', 'CM', 'XAF', 'fr', 'Africa/Douala', 'Limbe')$q$,
  'resto.rate_limited', '43 : au plus 3 organisations créées par 24 h');

set local role anon;
select zz_tests.expect_error($q$select count(*) from public.organizations$q$, '42501', '44 : un visiteur ne lit pas les organisations');
select zz_tests.expect_error($q$select public.create_organization('X', 'CM', 'XAF', 'fr', 'Africa/Douala', 'Douala')$q$,
  '42501', '45 : un visiteur ne crée pas d''organisation');
select zz_tests.expect((select count(*) from public.ref_languages) >= 8, '46 : référentiels lisibles sans compte');

reset role;
-- Les « OK n » sont des NOTICE, que le SQL Editor de Supabase n'affiche pas :
-- la ligne ci-dessous (après le ROLLBACK) n'apparaît que si tout est passé.
rollback;
select 'TOUS LES CONTRÔLES 001 SONT PASSÉS (46)' as resultat;
