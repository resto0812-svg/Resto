-- =============================================================================
-- Resto — contrôles de la migration 035 (dépenses récurrentes et budgets
-- par catégorie).
-- À coller APRÈS 035. Transaction annulée à la fin.
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
  ('00000000-0000-0000-0000-00000000a035', 'owner.a35@resto.test', 'authenticated', 'authenticated', '{}', now()),
  ('00000000-0000-0000-0000-00000000c035', 'autre.c35@resto.test', 'authenticated', 'authenticated', '{}', now());

set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000a035","role":"authenticated"}';
select set_config('t.a', public.create_organization('Dépenses 35', 'CM', 'XAF', 'fr', 'Africa/Douala', 'Depville')::text, true);
select set_config('t.org', current_setting('t.a')::jsonb ->> 'organization_id', true);
select set_config('t.b', current_setting('t.a')::jsonb ->> 'branch_id', true);
select set_config('t.rent', (select id::text from public.expense_categories
                              where organization_id = current_setting('t.org')::uuid and code = 'rent'), true);

-- ------------------------------------------------------------- modèle récurrent et budget
insert into public.expense_templates (organization_id, branch_id, category_id, description, amount_minor, method, day_of_month)
values (current_setting('t.org')::uuid, current_setting('t.b')::uuid, current_setting('t.rent')::uuid, 'Loyer du local', 250000, 'transfer', 5);
insert into public.expense_budgets (organization_id, branch_id, category_id, monthly_minor)
values (current_setting('t.org')::uuid, current_setting('t.b')::uuid, current_setting('t.rent')::uuid, 300000);
select zz_tests.expect((select count(*) from public.expense_templates) = 1 and (select count(*) from public.expense_budgets) = 1,
  '1 : modèle récurrent et budget enregistrés');

select zz_tests.expect(public.generate_recurring_expenses(current_setting('t.b')::uuid) = 1, '2 : dépense du mois générée');
select zz_tests.expect((select count(*) from public.expenses
                         where description = 'Loyer du local' and date_trunc('month', expense_date) = date_trunc('month', current_date)
                           and extract(day from expense_date) = 5) = 1,
  '3 : dépense datée du jour prévu dans le mois');
select zz_tests.expect(public.generate_recurring_expenses(current_setting('t.b')::uuid) = 0, '4 : pas de doublon le même mois');
select zz_tests.expect_error(format($q$select public.generate_recurring_expenses(%L, (current_date + interval '2 months')::date)$q$,
  current_setting('t.b')), 'resto.invalid_period', '5 : mois futur refusé');

-- ------------------------------------------------------------- une personne extérieure
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000c035","role":"authenticated"}';
select zz_tests.expect((select count(*) from public.expense_templates) = 0 and (select count(*) from public.expense_budgets) = 0,
  '6 : modèles et budgets invisibles hors de l''établissement');
select zz_tests.expect_error(format($q$insert into public.expense_budgets (organization_id, branch_id, category_id, monthly_minor) values (%L, %L, %L, 1)$q$,
  current_setting('t.org'), current_setting('t.b'), current_setting('t.rent')), '42501', '7 : écriture refusée hors de l''établissement');
select zz_tests.expect_error(format($q$select public.generate_recurring_expenses(%L)$q$, current_setting('t.b')),
  '42501', '8 : génération refusée hors de l''établissement');

reset role;
rollback;
select 'TOUS LES CONTRÔLES 035 SONT PASSÉS (8)' as resultat;
