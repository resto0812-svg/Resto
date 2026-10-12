-- =============================================================================
-- Resto — contrôles de la migration 020 (accueil personnalisé, avis vérifiés).
-- À coller APRÈS 020. Transaction annulée à la fin : aucune donnée ne reste.
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

-- A = restaurateur, C = client, D = autre client, B = autre restaurateur
insert into auth.users (id, email, aud, role, raw_user_meta_data, email_confirmed_at) values
  ('00000000-0000-0000-0000-00000000a020', 'owner.a20@resto.test', 'authenticated', 'authenticated', '{}', now()),
  ('00000000-0000-0000-0000-00000000c020', 'client.c20@resto.test', 'authenticated', 'authenticated', '{}', now()),
  ('00000000-0000-0000-0000-00000000d020', 'client.d20@resto.test', 'authenticated', 'authenticated', '{}', now()),
  ('00000000-0000-0000-0000-00000000b020', 'owner.b20@resto.test', 'authenticated', 'authenticated', '{}', now());

set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000a020","role":"authenticated"}';
select set_config('t.a', public.create_organization('Avis 20', 'CM', 'XAF', 'fr', 'Africa/Douala', 'Yyville', null, 'Bonapriso')::text, true);
select set_config('t.org', current_setting('t.a')::jsonb ->> 'organization_id', true);
select set_config('t.brand', current_setting('t.a')::jsonb ->> 'brand_id', true);
select set_config('t.a1', current_setting('t.a')::jsonb ->> 'branch_id', true);
with ins as (insert into public.menu_categories (organization_id, brand_id, name)
  values (current_setting('t.org')::uuid, current_setting('t.brand')::uuid, 'Grillades') returning id)
select set_config('t.cat', (select id::text from ins), true);
select set_config('t.item', public.create_menu_item(current_setting('t.cat')::uuid, 'Poulet grillé spécial', null, 'food')::text, true);
select set_config('t.var', (select id::text from public.item_variants where item_id = current_setting('t.item')::uuid), true);
insert into public.menu_item_branches (organization_id, brand_id, item_id, branch_id)
values (current_setting('t.org')::uuid, current_setting('t.brand')::uuid, current_setting('t.item')::uuid, current_setting('t.a1')::uuid);
select public.set_price(current_setting('t.a1')::uuid, current_setting('t.var')::uuid, null, 'default', 4500);
update public.branches set is_published = true, accepts_online_orders = true where id = current_setting('t.a1')::uuid;
insert into public.promotions (organization_id, name, kind, percent, code, is_public)
values (current_setting('t.org')::uuid, '-20 % ce midi', 'percent', 20, 'MIDI20', true);
select set_config('t.reg', (select id::text from public.cash_registers where branch_id = current_setting('t.a1')::uuid), true);
select set_config('t.cash', (select id::text from public.payment_methods where organization_id = current_setting('t.org')::uuid and ref_code = 'cash'), true);

-- ------------------------------------------------------------- client C commande
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000c020","role":"authenticated"}';
insert into public.customer_profiles (full_name, home_latitude, home_longitude) values ('Michel Bounou', 4.04, 9.69);
select set_config('t.o', (public.place_online_order(current_setting('t.a1')::uuid, 'takeaway',
  jsonb_build_array(jsonb_build_object('variant_id', current_setting('t.var'), 'quantity', 1))) ->> 'order_id'), true);
select set_config('t.line', (select id::text from public.order_items where order_id = current_setting('t.o')::uuid), true);
select zz_tests.expect_error(format($q$select public.submit_item_review(%L, 5)$q$, current_setting('t.line')),
  'resto.review_not_allowed', '1 : pas d''avis avant d''avoir reçu le plat');
select zz_tests.expect((public.my_home() -> 'active' -> 0 ->> 'order_id') = current_setting('t.o'),
  '2 : la commande en cours apparaît sur l''accueil du client');

-- ------------------------------------------------------------- le restaurant sert et encaisse
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000a020","role":"authenticated"}';
select public.accept_online_order(current_setting('t.o')::uuid, 15);
select set_config('t.s', public.open_cash_session(current_setting('t.reg')::uuid, 0)::text, true);
select public.take_payment(current_setting('t.o')::uuid, current_setting('t.s')::uuid, current_setting('t.cash')::uuid, 4500);
select zz_tests.expect((select status from public.orders where id = current_setting('t.o')::uuid) = 'closed',
  '3 : commande servie et payée');

-- ------------------------------------------------------------- avis vérifié
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000c020","role":"authenticated"}';
select zz_tests.expect_error(format($q$select public.submit_item_review(%L, 9)$q$, current_setting('t.line')),
  'resto.invalid_rating', '4 : note hors de 1 à 5 refusée');
select zz_tests.expect_error(format($q$select public.submit_item_review(%L, 5, null, array['autre/photo.jpg'])$q$, current_setting('t.line')),
  'resto.invalid_media', '5 : photo hors du dossier du client refusée');
select set_config('t.r', public.submit_item_review(current_setting('t.line')::uuid, 5,
  'Bien assaisonné, portion généreuse, livraison rapide.', array['00000000-0000-0000-0000-00000000c020/p1.jpg'])::text, true);
select zz_tests.expect((select author_name = 'Michel B.' and rating = 5 from public.item_reviews where id = current_setting('t.r')::uuid),
  '6 : avis publié sous « Michel B. » (jamais l''e-mail)');
select public.submit_item_review(current_setting('t.line')::uuid, 4, 'Très bon');
select zz_tests.expect((select count(*) = 1 and min(rating) = 4 from public.item_reviews where order_item_id = current_setting('t.line')::uuid),
  '7 : un seul avis par plat commandé, modifiable par son auteur');
select zz_tests.expect((select reorder -> 0 -> 'lines' -> 0 ->> 'variant_id' from (select public.my_home() -> 'reorder' as reorder) x)
  = current_setting('t.var'), '8 : « recommander » propose la dernière commande');

-- ------------------------------------------------------------- autre client D
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000d020","role":"authenticated"}';
select zz_tests.expect_error(format($q$select public.submit_item_review(%L, 1)$q$, current_setting('t.line')),
  '42501', '9 : on ne note pas un plat qu''on n''a pas commandé');
select zz_tests.expect(public.vote_item_review(current_setting('t.r')::uuid, true) = 1, '10 : vote « utile »');
select public.report_item_review(current_setting('t.r')::uuid, 'Contenu hors sujet');
-- D ne lit pas l'avis lui-même (réservé à l'auteur et au restaurant) : contrôle du compteur hors RLS.
reset role;
select zz_tests.expect((select reports_count from public.item_reviews where id = current_setting('t.r')::uuid) = 1,
  '11 : signalement enregistré');
set local role authenticated;

-- ------------------------------------------------------------- public
set local role anon;
select zz_tests.expect((public.public_item_ratings(current_setting('t.a1')::uuid) -> current_setting('t.item') ->> 'count')::int = 1
  and (public.public_item_ratings(current_setting('t.a1')::uuid) -> current_setting('t.item') ->> 'satisfied')::int = 100,
  '12 : note du plat : 1 avis, 100 % de satisfaits');
select zz_tests.expect(jsonb_array_length(public.public_item_reviews(current_setting('t.item')::uuid, 'helpful')) = 1,
  '13 : avis visibles sans compte');
select set_config('t.home', public.public_home('Yyville')::text, true);
select zz_tests.expect((current_setting('t.home')::jsonb -> 'promos' -> 0 ->> 'code') = 'MIDI20'
  and (current_setting('t.home')::jsonb -> 'popular' -> 0 ->> 'item_id') = current_setting('t.item'),
  '14 : accueil public : promotion et plat populaire');

-- ------------------------------------------------------------- modération
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000b020","role":"authenticated"}';
select public.create_organization('Avis B', 'CM', 'XAF', 'fr', 'Africa/Douala', 'Yaoundé');
select zz_tests.expect_error(format($q$select public.moderate_item_review(%L, true, 'concurrent')$q$, current_setting('t.r')),
  '42501', '15 : un autre restaurant ne modère pas cet avis');
select zz_tests.expect((select count(*) from public.item_reviews) = 0, '16 : un autre restaurant ne lit pas ces avis');
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000a020","role":"authenticated"}';
select zz_tests.expect_error(format($q$select public.moderate_item_review(%L, true)$q$, current_setting('t.r')),
  'resto.reason_required', '17 : masquer un avis exige un motif');
select public.moderate_item_review(current_setting('t.r')::uuid, true, 'Propos injurieux');
select zz_tests.expect((select status = 'hidden' and hidden_by is not null and hidden_reason = 'Propos injurieux'
                          from public.item_reviews where id = current_setting('t.r')::uuid),
  '18 : avis masqué, avec motif et auteur de la décision');
set local role anon;
select zz_tests.expect(jsonb_array_length(public.public_item_reviews(current_setting('t.item')::uuid)) = 0,
  '19 : un avis masqué n''est plus public');

reset role;
select zz_tests.expect((select description from public.permissions where code = 'marketing.manage')
  = 'Publicité : campagnes, médiathèque, statistiques', '20 : libellé de la permission Publicité corrigé');
rollback;
select 'TOUS LES CONTRÔLES 020 SONT PASSÉS (20)' as resultat;
