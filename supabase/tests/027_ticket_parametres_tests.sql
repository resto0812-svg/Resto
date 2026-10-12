-- =============================================================================
-- Resto — contrôles de la migration 027 (textes du ticket de caisse
-- réglables par établissement).
-- À coller APRÈS 027. Transaction annulée à la fin.
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
  ('00000000-0000-0000-0000-00000000a027', 'owner.a27@resto.test', 'authenticated', 'authenticated', '{}', now()),
  ('00000000-0000-0000-0000-00000000b027', 'autre.b27@resto.test', 'authenticated', 'authenticated', '{}', now());

set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000a027","role":"authenticated"}';
select set_config('t.a', public.create_organization('Gourmet 27', 'CM', 'XAF', 'fr', 'Africa/Douala', 'Gourmetville')::text, true);
select set_config('t.b', current_setting('t.a')::jsonb ->> 'branch_id', true);

update public.branches
   set receipt_title = 'Le Petit Gourmet', receipt_subtitle = 'Restaurant & Saveurs',
       receipt_slogan = 'Une cuisine authentique, des saveurs du monde', website = 'www.lepetitgourmet.fr',
       receipt_qr_title = 'Votre fidélité vous récompense !',
       receipt_qr_caption = 'Scannez ce QR code pour accéder à votre espace fidélité.',
       receipt_farewell = 'À très bientôt chez Le Petit Gourmet'
 where id = current_setting('t.b')::uuid;
select zz_tests.expect((select receipt_title = 'Le Petit Gourmet' and website = 'www.lepetitgourmet.fr'
                          and receipt_farewell like 'À très bientôt%' from public.branches where id = current_setting('t.b')::uuid),
  '1 : le responsable règle les textes du ticket');

select zz_tests.expect_error(format($q$update public.branches set website = 'www.mon site.fr' where id = %L$q$, current_setting('t.b')),
  '23514', '2 : site web avec espace refusé');
select zz_tests.expect_error(format($q$update public.branches set receipt_slogan = repeat('x', 161) where id = %L$q$, current_setting('t.b')),
  '23514', '3 : slogan trop long refusé');

set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000b027","role":"authenticated"}';
update public.branches set receipt_title = 'Piraté' where id = current_setting('t.b')::uuid;
reset role;
select zz_tests.expect((select receipt_title = 'Le Petit Gourmet' from public.branches where id = current_setting('t.b')::uuid),
  '4 : un autre utilisateur ne modifie pas le ticket');

rollback;
select 'TOUS LES CONTRÔLES 027 SONT PASSÉS (4)' as resultat;
