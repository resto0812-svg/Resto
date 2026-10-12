-- =============================================================================
-- Resto — contrôles de la migration 028 (compteurs publics des publicités).
-- À coller APRÈS 028.
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
  ('00000000-0000-0000-0000-00000000a028', 'owner.a28@resto.test', 'authenticated', 'authenticated', '{}', now()),
  ('00000000-0000-0000-0000-00000000c028', 'client.c28@resto.test', 'authenticated', 'authenticated', '{}', now());

set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000a028","role":"authenticated"}';
select set_config('t.a', public.create_organization('Pub 28', 'CM', 'XAF', 'fr', 'Africa/Douala', 'Pubville', null, 'A')::text, true);
select set_config('t.org', current_setting('t.a')::jsonb ->> 'organization_id', true);
select set_config('t.brand', current_setting('t.a')::jsonb ->> 'brand_id', true);
select set_config('t.b', current_setting('t.a')::jsonb ->> 'branch_id', true);
update public.branches set is_published = true where id = current_setting('t.b')::uuid;
with ins as (
  insert into public.ad_campaigns (organization_id, brand_id, format, title, media, status)
  values (current_setting('t.org')::uuid, current_setting('t.brand')::uuid, 'video', 'Poulet DG',
          jsonb_build_array(jsonb_build_object('kind', 'video', 'path', current_setting('t.org') || '/v.mp4')), 'active')
  returning id)
select set_config('t.ad', (select id::text from ins), true);

-- ------------------------------------------------------------- un client regarde, aime, commente
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000c028","role":"authenticated"}';
select public.record_ad_view(current_setting('t.ad')::uuid);
select public.toggle_ad_like(current_setting('t.ad')::uuid);
select public.add_ad_comment(current_setting('t.ad')::uuid, 'Superbe !');

-- ------------------------------------------------------------- un visiteur voit les compteurs
set local role anon;
set local request.jwt.claims = '{"role":"anon"}';
select set_config('t.f', (public.public_feed('Pubville') -> 0)::text, true);
select zz_tests.expect((current_setting('t.f')::jsonb ->> 'views')::int = 1
  and (current_setting('t.f')::jsonb ->> 'likes')::int = 1,
  '1 : vues et j''aime visibles dans le fil');
select set_config('t.p', (public.public_ads(current_setting('t.b')::uuid) -> 0)::text, true);
select zz_tests.expect((current_setting('t.p')::jsonb ->> 'views')::int = 1
  and (current_setting('t.p')::jsonb ->> 'likes')::int = 1
  and (current_setting('t.p')::jsonb ->> 'comments')::int >= 0
  and current_setting('t.p')::jsonb ? 'saves',
  '2 : compteurs visibles sur les publicités de l''accueil');

reset role;
rollback;
select 'TOUS LES CONTRÔLES 028 SONT PASSÉS (2)' as resultat;
