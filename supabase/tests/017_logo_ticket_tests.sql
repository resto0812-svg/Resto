-- =============================================================================
-- Resto — contrôles de la migration 017 (logo du restaurant, QR code du ticket).
-- À coller APRÈS 017. Transaction annulée à la fin : aucune donnée ne reste.
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

-- A = propriétaire, K = caissier, B = autre organisation
insert into auth.users (id, email, aud, role, raw_user_meta_data, email_confirmed_at) values
  ('00000000-0000-0000-0000-00000000a017', 'owner.a17@resto.test', 'authenticated', 'authenticated', '{}', now()),
  ('00000000-0000-0000-0000-00000000c017', 'cashier.k17@resto.test', 'authenticated', 'authenticated', '{}', now()),
  ('00000000-0000-0000-0000-00000000b017', 'owner.b17@resto.test', 'authenticated', 'authenticated', '{}', now());

set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000a017","role":"authenticated"}';
select set_config('t.a', public.create_organization('Logo A', 'CM', 'XAF', 'fr', 'Africa/Douala', 'Douala', null, 'A1')::text, true);
select set_config('t.org', current_setting('t.a')::jsonb ->> 'organization_id', true);
select set_config('t.brand', current_setting('t.a')::jsonb ->> 'brand_id', true);
select set_config('t.a1', current_setting('t.a')::jsonb ->> 'branch_id', true);

select zz_tests.expect((select receipt_qr and receipt_qr_url is null from public.branches where id = current_setting('t.a1')::uuid),
  '1 : QR code affiché par défaut, vers la page du restaurant');
update public.brands set logo_path = current_setting('t.org') || '/' || current_setting('t.brand') || '/logo-1.png'
 where id = current_setting('t.brand')::uuid;
select zz_tests.expect((select logo_path like current_setting('t.org') || '/%' from public.brands where id = current_setting('t.brand')::uuid),
  '2 : le responsable enregistre le logo');
select zz_tests.expect_error(format($q$update public.brands set logo_path = '00000000-0000-0000-0000-000000000000/x.png' where id = %L$q$,
  current_setting('t.brand')), '23514', '3 : un logo hors du dossier de l''organisation est refusé');
update public.branches set receipt_qr_url = 'https://exemple.test/avis' where id = current_setting('t.a1')::uuid;
select zz_tests.expect((select receipt_qr_url from public.branches where id = current_setting('t.a1')::uuid) = 'https://exemple.test/avis',
  '4 : lien libre du QR code enregistré');
select zz_tests.expect_error(format($q$update public.branches set receipt_qr_url = 'javascript:alert(1)' where id = %L$q$,
  current_setting('t.a1')), '23514', '5 : lien du QR code autre que http(s) refusé');

reset role;
insert into public.memberships (organization_id, user_id, role_code, all_branches) values
  (current_setting('t.org')::uuid, '00000000-0000-0000-0000-00000000c017', 'cashier', false);
insert into public.membership_branches (organization_id, membership_id, branch_id)
select m.organization_id, m.id, current_setting('t.a1')::uuid from public.memberships m
 where m.user_id = '00000000-0000-0000-0000-00000000c017';
set local role authenticated;

-- ------------------------------------------------------------- caissier K
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000c017","role":"authenticated"}';
select zz_tests.expect((select logo_path from public.brands where id = current_setting('t.brand')::uuid) is not null,
  '6 : le caissier lit le logo (impression du ticket)');
update public.brands set logo_path = null where id = current_setting('t.brand')::uuid;

-- ------------------------------------------------------------- autre organisation B
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000b017","role":"authenticated"}';
update public.brands set logo_path = null where id = current_setting('t.brand')::uuid;

reset role;
select zz_tests.expect((select logo_path from public.brands where id = current_setting('t.brand')::uuid) is not null,
  '7 : ni le caissier ni une autre organisation ne retirent le logo');
select zz_tests.expect((select public and file_size_limit = 1048576 from storage.buckets where id = 'brand-logos')
  and (select count(*) from pg_policies where schemaname = 'storage' and tablename = 'objects'
         and policyname like 'resto_brand_logos_%') = 4,
  '8 : bucket des logos (1 Mo) et ses 4 règles d''accès');

rollback;
select 'TOUS LES CONTRÔLES 017 SONT PASSÉS (8)' as resultat;
