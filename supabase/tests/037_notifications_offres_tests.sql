-- =============================================================================
-- Resto — contrôles de la migration 037 (notifications d'offres : offres
-- programmées, envoi unique, destinataires élargis, nombre de destinataires).
-- À coller APRÈS 037. Transaction annulée à la fin.
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
  ('00000000-0000-0000-0000-00000000a037', 'owner.a37@resto.test', 'authenticated', 'authenticated', '{}', now()),
  ('00000000-0000-0000-0000-00000000c137', 'suit.c137@resto.test', 'authenticated', 'authenticated', '{}', now()),
  ('00000000-0000-0000-0000-00000000c237', 'proche.c237@resto.test', 'authenticated', 'authenticated', '{}', now()),
  ('00000000-0000-0000-0000-00000000c337', 'loin.c337@resto.test', 'authenticated', 'authenticated', '{}', now());

set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000a037","role":"authenticated"}';
select set_config('t.a', public.create_organization('Offres 37', 'CM', 'XAF', 'fr', 'Africa/Douala', 'Offreville')::text, true);
select set_config('t.org', current_setting('t.a')::jsonb ->> 'organization_id', true);
select set_config('t.brand', current_setting('t.a')::jsonb ->> 'brand_id', true);
select set_config('t.b', current_setting('t.a')::jsonb ->> 'branch_id', true);

reset role;
update public.branches set is_published = true, latitude = 3.866000, longitude = 11.516000
 where id = current_setting('t.b')::uuid;
-- C1 suit le restaurant ; C2 habite à environ 2 km ; C3 habite à Paris ;
-- le propriétaire suit aussi son restaurant (il ne doit rien recevoir).
insert into public.customer_favorites (user_id, branch_id) values
  ('00000000-0000-0000-0000-00000000c137', current_setting('t.b')::uuid),
  ('00000000-0000-0000-0000-00000000a037', current_setting('t.b')::uuid);
insert into public.customer_profiles (user_id, home_latitude, home_longitude) values
  ('00000000-0000-0000-0000-00000000c237', 3.880000, 11.520000),
  ('00000000-0000-0000-0000-00000000c337', 48.856600, 2.352200)
on conflict (user_id) do update set home_latitude = excluded.home_latitude, home_longitude = excluded.home_longitude;

-- ------------------------------------------------------------- nombre de destinataires
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000a037","role":"authenticated"}';
select zz_tests.expect(public.promotion_audience_count(current_setting('t.brand')::uuid) = 2,
  '1 : deux destinataires (qui suit + client proche), ni le client lointain ni l''équipe');

set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000c137","role":"authenticated"}';
select zz_tests.expect_error(format('select public.promotion_audience_count(%L::uuid)', current_setting('t.brand')),
  '42501', '2 : un client ne peut pas connaître l''audience d''un restaurant');

-- ------------------------------------------------------------- offre immédiate, envoyée une seule fois
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000a037","role":"authenticated"}';
with ins as (insert into public.ad_campaigns (organization_id, brand_id, format, title, body, status)
  values (current_setting('t.org')::uuid, current_setting('t.brand')::uuid, 'push', 'Happy hour', '-20 % ce soir', 'active')
  returning id)
select set_config('t.p1', (select id::text from ins), true);

reset role;
select zz_tests.expect((select count(*) from public.customer_notifications
                         where kind = 'promotion' and data ->> 'campaign_id' = current_setting('t.p1')) = 2,
  '3 : l''offre immédiate part aux deux destinataires');
select zz_tests.expect(not exists (select 1 from public.customer_notifications
                         where data ->> 'campaign_id' = current_setting('t.p1')
                           and user_id in ('00000000-0000-0000-0000-00000000a037', '00000000-0000-0000-0000-00000000c337')),
  '4 : ni le propriétaire ni le client lointain ne la reçoivent');

set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000a037","role":"authenticated"}';
update public.ad_campaigns set status = 'paused' where id = current_setting('t.p1')::uuid;
update public.ad_campaigns set status = 'active' where id = current_setting('t.p1')::uuid;
reset role;
select zz_tests.expect((select count(*) from public.customer_notifications
                         where data ->> 'campaign_id' = current_setting('t.p1')) = 2,
  '5 : mise en pause puis réactivée, l''offre ne repart pas');

-- ------------------------------------------------------------- offre programmée
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000a037","role":"authenticated"}';
with ins as (insert into public.ad_campaigns (organization_id, brand_id, format, title, status, starts_at)
  values (current_setting('t.org')::uuid, current_setting('t.brand')::uuid, 'push', 'Brunch dimanche', 'active', now() + interval '2 hours')
  returning id)
select set_config('t.p2', (select id::text from ins), true);
reset role;
select zz_tests.expect(not exists (select 1 from public.customer_notifications
                         where data ->> 'campaign_id' = current_setting('t.p2')),
  '6 : l''offre programmée ne part pas avant sa date');
select zz_tests.expect(app_private.send_due_promotions() = 0, '7 : la tâche planifiée n''envoie rien avant la date');

-- La date arrive (simulée sans déclencher l'envoi immédiat) : la tâche planifiée l'envoie.
alter table public.ad_campaigns disable trigger ad_campaigns_promotion_push;
update public.ad_campaigns set starts_at = now() - interval '1 minute' where id = current_setting('t.p2')::uuid;
alter table public.ad_campaigns enable trigger ad_campaigns_promotion_push;
select zz_tests.expect(app_private.send_due_promotions() = 2, '8 : à sa date, la tâche planifiée envoie l''offre');
select zz_tests.expect(app_private.send_due_promotions() = 0, '9 : la tâche suivante ne la renvoie pas');
select zz_tests.expect(exists (select 1 from cron.job where jobname = 'resto-offres-programmees'),
  '10 : la tâche planifiée est enregistrée');

rollback;
select 'TOUS LES CONTRÔLES 037 SONT PASSÉS (10)' as resultat;
