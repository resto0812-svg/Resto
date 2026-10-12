-- =============================================================================
-- Resto — contrôles de la migration 025 (Stock pro : fiche article, tableau de
-- bord, lots proches de la date limite, commande suggérée). À coller APRÈS 025.
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
  ('00000000-0000-0000-0000-00000000a025', 'owner.a25@resto.test', 'authenticated', 'authenticated', '{}', now()),
  ('00000000-0000-0000-0000-00000000b025', 'owner.b25@resto.test', 'authenticated', 'authenticated', '{}', now());

set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000a025","role":"authenticated"}';
select set_config('t.a', public.create_organization('Stock 25', 'CM', 'XAF', 'fr', 'Africa/Douala', 'Douala')::text, true);
select set_config('t.org', current_setting('t.a')::jsonb ->> 'organization_id', true);
select set_config('t.b', current_setting('t.a')::jsonb ->> 'branch_id', true);
select set_config('t.loc', (select id::text from public.stock_locations where branch_id = current_setting('t.b')::uuid limit 1), true);
with ins as (insert into public.suppliers (organization_id, name) values (current_setting('t.org')::uuid, 'Marché central') returning id)
select set_config('t.sup', (select id::text from ins), true);

-- ------------------------------------------------------------- 1. fiche article
with ins as (
  insert into public.ingredients (organization_id, name, kind, unit_code, storage, purchase_unit_label, purchase_unit_qty,
                                  preferred_supplier_id, shelf_life_days, barcode)
  values (current_setting('t.org')::uuid, 'Tomate', 'raw', 'kg', 'chilled', 'Sac de 5 kg', 5,
          current_setting('t.sup')::uuid, 7, '3560070000000')
  returning id)
select set_config('t.ing', (select id::text from ins), true);
select zz_tests.expect((select storage = 'chilled' and purchase_unit_qty = 5 and preferred_supplier_id = current_setting('t.sup')::uuid
                          from public.ingredients where id = current_setting('t.ing')::uuid),
  '1 : fiche article complète (conservation, unité d''achat, fournisseur habituel)');
select zz_tests.expect_error(format($q$update public.ingredients set image_path = 'autre-org/photo.jpg' where id = %L$q$,
    current_setting('t.ing')), 'resto.invalid_image', '2 : photo hors du dossier de l''organisation refusée');
update public.branches set target_food_cost_percent = 28 where id = current_setting('t.b')::uuid;
select zz_tests.expect_error(format($q$update public.branches set target_food_cost_percent = 0 where id = %L$q$, current_setting('t.b')),
  '23514', '3 : objectif de coût matière entre 1 et 95 %');

-- ------------------------------------------------------------- 2. deux lots (dates de réception distinctes)
reset role;
insert into public.ingredient_stock (organization_id, branch_id, ingredient_id, min_quantity, avg_unit_cost)
values (current_setting('t.org')::uuid, current_setting('t.b')::uuid, current_setting('t.ing')::uuid, 20, 500);
insert into public.stock_movements (organization_id, branch_id, location_id, ingredient_id, kind, quantity, unit_cost, currency,
                                    batch, expires_on, created_at)
values (current_setting('t.org')::uuid, current_setting('t.b')::uuid, current_setting('t.loc')::uuid, current_setting('t.ing')::uuid,
        'receipt', 10, 500, 'XAF', 'L1', current_date + 2, now() - interval '2 days'),
       (current_setting('t.org')::uuid, current_setting('t.b')::uuid, current_setting('t.loc')::uuid, current_setting('t.ing')::uuid,
        'receipt', 5, 500, 'XAF', 'L2', current_date + 30, now() - interval '1 day');
set local role authenticated;
select public.record_stock_movement(current_setting('t.b')::uuid, current_setting('t.loc')::uuid, current_setting('t.ing')::uuid,
  'waste', 2, 'kg', 0, 'Abîmées');
select public.record_stock_movement(current_setting('t.b')::uuid, current_setting('t.loc')::uuid, current_setting('t.ing')::uuid,
  'staff_meal', 1, 'kg', 0, 'Repas de l''équipe');

-- Stock 12 kg : le lot L2 (5 kg, le plus récent) est entier, il reste 7 kg du lot L1.
select zz_tests.expect((select count(*) = 1 and min(batch) = 'L1' and min(remaining) = 7 and min(value_minor) = 3500
                          from public.stock_expiring(current_setting('t.b')::uuid, 3)),
  '4 : lot proche de sa date limite, quantité restante en « premier entré, premier sorti »');
select zz_tests.expect((select count(*) from public.stock_expiring(current_setting('t.b')::uuid, 60)) = 2,
  '5 : sur 60 jours, les deux lots apparaissent');

-- ------------------------------------------------------------- 3. tableau de bord
select set_config('t.d', public.stock_dashboard(current_setting('t.b')::uuid, current_date - 7, current_date)::text, true);
select zz_tests.expect((current_setting('t.d')::jsonb ->> 'value_minor')::numeric = 6000
  and (current_setting('t.d')::jsonb ->> 'below_min')::int = 1
  and (current_setting('t.d')::jsonb ->> 'expiring')::int = 1,
  '6 : valeur du stock (12 kg × 500), alerte de seuil, lot à surveiller');
select zz_tests.expect((current_setting('t.d')::jsonb ->> 'waste_minor')::numeric = 1000
  and (current_setting('t.d')::jsonb ->> 'consumption_minor')::numeric = 500
  and (current_setting('t.d')::jsonb ->> 'receipts_minor')::numeric = 7500,
  '7 : pertes, consommation et réceptions de la période valorisées');
select zz_tests.expect(current_setting('t.d')::jsonb -> 'waste_reasons' -> 0 ->> 'reason' = 'Abîmées'
  and jsonb_array_length(current_setting('t.d')::jsonb -> 'by_day') >= 2,
  '8 : pertes par motif et évolution par jour');
select zz_tests.expect_error(format($q$select public.stock_dashboard(%L, current_date, current_date - 1)$q$, current_setting('t.b')),
  'resto.invalid_period', '9 : période invalide refusée');

-- ------------------------------------------------------------- 4. commande suggérée
-- Seuil 20 + 7 jours × (3 kg / 28 j) − 12 kg = 8,75 kg → 2 sacs de 5 kg.
select zz_tests.expect((select suggested = 10 and supplier_name = 'Marché central' and last_unit_cost = 500
                          from public.reorder_suggestions(current_setting('t.b')::uuid, 7)
                         where ingredient_id = current_setting('t.ing')::uuid),
  '10 : quantité suggérée arrondie à l''unité d''achat, fournisseur habituel, dernier prix');

-- ------------------------------------------------------------- 5. autre restaurant
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000b025","role":"authenticated"}';
select public.create_organization('Autre 25', 'CM', 'XAF', 'fr', 'Africa/Douala', 'Yaoundé');
select zz_tests.expect_error(format($q$select public.stock_dashboard(%L, current_date - 7, current_date)$q$, current_setting('t.b')),
  '42501', '11 : B ne voit pas le tableau de bord du stock de A');
select zz_tests.expect_error(format($q$select * from public.reorder_suggestions(%L)$q$, current_setting('t.b')),
  '42501', '12 : ni ses suggestions de commande');

reset role;
rollback;
select 'TOUS LES CONTRÔLES 025 SONT PASSÉS (12)' as resultat;
