-- =============================================================================
-- Resto — contrôles de la migration 031 (notifications du client et du
-- restaurant, appareils push).
-- À coller APRÈS 031. Transaction annulée à la fin.
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
  ('00000000-0000-0000-0000-00000000a031', 'owner.a31@resto.test', 'authenticated', 'authenticated', '{}', now()),
  ('00000000-0000-0000-0000-00000000c031', 'client.c31@resto.test', 'authenticated', 'authenticated', '{}', now());

set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000a031","role":"authenticated"}';
select set_config('t.a', public.create_organization('Notif 31', 'CM', 'XAF', 'fr', 'Africa/Douala', 'Notifville')::text, true);
select set_config('t.org', current_setting('t.a')::jsonb ->> 'organization_id', true);
select set_config('t.br', current_setting('t.a')::jsonb ->> 'brand_id', true);
select set_config('t.b', current_setting('t.a')::jsonb ->> 'branch_id', true);
with ins as (insert into public.menu_categories (organization_id, brand_id, name)
  values (current_setting('t.org')::uuid, current_setting('t.br')::uuid, 'Plats') returning id)
select set_config('t.cat', (select id::text from ins), true);
select set_config('t.it', public.create_menu_item(current_setting('t.cat')::uuid, 'Eru', null, 'food')::text, true);
select set_config('t.v', (select id::text from public.item_variants where item_id = current_setting('t.it')::uuid), true);
insert into public.menu_item_branches (organization_id, brand_id, item_id, branch_id)
values (current_setting('t.org')::uuid, current_setting('t.br')::uuid, current_setting('t.it')::uuid, current_setting('t.b')::uuid);
select public.set_price(current_setting('t.b')::uuid, current_setting('t.v')::uuid, null, 'default', 3500);
update public.branches set is_published = true, accepts_online_orders = true where id = current_setting('t.b')::uuid;

-- ------------------------------------------------------------- le client : appareil, commande, avis, suivi
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000c031","role":"authenticated"}';
select public.register_push_device('jeton-firebase-client-0123456789', 'android', 'fr');
select zz_tests.expect((select count(*) from public.push_devices) = 1, '1 : appareil du client enregistré');
select zz_tests.expect_error($q$select public.register_push_device('court', 'android', 'fr')$q$,
  'resto.invalid_device', '2 : jeton invalide refusé');
select public.place_online_order(current_setting('t.b')::uuid, 'takeaway',
  jsonb_build_array(jsonb_build_object('variant_id', current_setting('t.v'), 'quantity', 1)));
select public.add_item_comment(current_setting('t.it')::uuid, 'Très bon eru !');
insert into public.customer_favorites (branch_id) values (current_setting('t.b')::uuid);

-- ------------------------------------------------------------- le restaurant est prévenu
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000a031","role":"authenticated"}';
select zz_tests.expect((select count(*) from public.customer_notifications where kind = 'staff_new_order'
                         and data ->> 'branch_id' = current_setting('t.b')) = 1,
  '3 : nouvelle commande en ligne notifiée à l''équipe');
select zz_tests.expect((select count(*) from public.customer_notifications where kind = 'staff_new_review'
                         and data ->> 'item_name' = 'Eru') = 1,
  '4 : nouvel avis notifié à l''équipe');
select zz_tests.expect((select count(*) from public.push_devices) = 0, '5 : le restaurant ne voit pas les appareils des clients');
insert into public.ad_campaigns (organization_id, brand_id, format, title, body, status)
values (current_setting('t.org')::uuid, current_setting('t.br')::uuid, 'push', '-20 % ce soir', 'Sur tous les plats', 'active');
select zz_tests.expect((select count(*) from public.customer_notifications where kind = 'promotion') = 0,
  '6 : l''équipe ne reçoit pas ses propres offres');

-- ------------------------------------------------------------- le client reçoit l'offre
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000c031","role":"authenticated"}';
select zz_tests.expect((select count(*) from public.customer_notifications where kind = 'promotion'
                         and data ->> 'title' = '-20 % ce soir') = 1,
  '7 : offre envoyée aux clients qui suivent le restaurant');
insert into public.customer_profiles (user_id, prefs) values (auth.uid(), '{"promotions": false}'::jsonb)
on conflict (user_id) do update set prefs = excluded.prefs;
select public.unregister_push_device('jeton-firebase-client-0123456789');
select zz_tests.expect((select count(*) from public.push_devices) = 0, '8 : appareil retiré à la déconnexion');

reset role;
select zz_tests.expect(not app_private.push_allowed('00000000-0000-0000-0000-00000000c031', 'promotion', '{}')
  and app_private.push_allowed('00000000-0000-0000-0000-00000000c031', 'order_ready', '{}'),
  '9 : les offres coupées par le client ne partent pas en push, le suivi de commande oui');

rollback;
select 'TOUS LES CONTRÔLES 031 SONT PASSÉS (9)' as resultat;
