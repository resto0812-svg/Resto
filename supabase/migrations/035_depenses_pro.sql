-- =============================================================================
-- Resto — 035_depenses_pro
-- Dépenses : modèles récurrents (loyer, abonnements, salaires…) générés chaque
-- mois en un geste, et budget mensuel par catégorie (alerte de dépassement
-- calculée par l'application).
-- Lecture : équipe ayant « expenses.manage » ou « finance.read » ;
-- écriture : « expenses.manage ».
-- À coller APRÈS 034, puis supabase/tests/035_depenses_pro_tests.sql.
-- =============================================================================

create table if not exists public.expense_templates (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null,
  branch_id uuid not null,
  category_id uuid not null,
  supplier_id uuid,
  description text not null check (length(btrim(description)) between 1 and 300),
  amount_minor bigint not null check (amount_minor > 0),
  tax_minor bigint not null default 0 check (tax_minor >= 0 and tax_minor <= amount_minor),
  method text not null default 'transfer' check (method in ('cash', 'card', 'mobile_money', 'transfer', 'other')),
  day_of_month smallint not null default 1 check (day_of_month between 1 and 28),
  active boolean not null default true,
  last_month date,
  created_at timestamptz not null default now(),
  foreign key (organization_id, branch_id) references public.branches (organization_id, id) on delete cascade,
  foreign key (organization_id, category_id) references public.expense_categories (organization_id, id) on delete restrict,
  foreign key (organization_id, supplier_id) references public.suppliers (organization_id, id) on delete restrict
);
create index if not exists expense_templates_branch_idx on public.expense_templates (branch_id);

create table if not exists public.expense_budgets (
  organization_id uuid not null,
  branch_id uuid not null,
  category_id uuid not null,
  monthly_minor bigint not null check (monthly_minor >= 0),
  primary key (branch_id, category_id),
  foreign key (organization_id, branch_id) references public.branches (organization_id, id) on delete cascade,
  foreign key (organization_id, category_id) references public.expense_categories (organization_id, id) on delete cascade
);

alter table public.expense_templates enable row level security;
alter table public.expense_budgets enable row level security;
grant select, delete on public.expense_templates, public.expense_budgets to authenticated;
grant insert (organization_id, branch_id, category_id, supplier_id, description, amount_minor, tax_minor, method, day_of_month, active),
  update (category_id, supplier_id, description, amount_minor, tax_minor, method, day_of_month, active)
  on public.expense_templates to authenticated;
grant insert (organization_id, branch_id, category_id, monthly_minor), update (monthly_minor)
  on public.expense_budgets to authenticated;

drop policy if exists expense_templates_read on public.expense_templates;
drop policy if exists expense_templates_write on public.expense_templates;
drop policy if exists expense_budgets_read on public.expense_budgets;
drop policy if exists expense_budgets_write on public.expense_budgets;
create policy expense_templates_read on public.expense_templates for select to authenticated
  using (branch_id in (select app_private.branch_ids_with('expenses.manage'))
      or branch_id in (select app_private.branch_ids_with('finance.read')));
create policy expense_templates_write on public.expense_templates for all to authenticated
  using (branch_id in (select app_private.branch_ids_with('expenses.manage')))
  with check (branch_id in (select app_private.branch_ids_with('expenses.manage')));
create policy expense_budgets_read on public.expense_budgets for select to authenticated
  using (branch_id in (select app_private.branch_ids_with('expenses.manage'))
      or branch_id in (select app_private.branch_ids_with('finance.read')));
create policy expense_budgets_write on public.expense_budgets for all to authenticated
  using (branch_id in (select app_private.branch_ids_with('expenses.manage')))
  with check (branch_id in (select app_private.branch_ids_with('expenses.manage')));

-- Génère, pour le mois donné (le mois en cours par défaut), les dépenses des
-- modèles actifs pas encore générés ce mois-là ; renvoie leur nombre.
create or replace function public.generate_recurring_expenses(p_branch uuid, p_month date default null)
returns integer language plpgsql security definer set search_path = '' as $$
declare
  v_month date := date_trunc('month', coalesce(p_month, current_date))::date;
  v_last_day integer;
  v_count integer := 0;
  r public.expense_templates;
begin
  perform app_private.assert_branch_perm(p_branch, 'expenses.manage');
  if v_month > date_trunc('month', current_date)::date then perform app_private.fail('resto.invalid_period'); end if;
  v_last_day := extract(day from (v_month + interval '1 month' - interval '1 day'))::integer;
  for r in select * from public.expense_templates
            where branch_id = p_branch and active and (last_month is null or last_month < v_month)
            order by day_of_month, description for update loop
    perform public.record_expense(p_branch, r.category_id, r.description,
                                  v_month + (least(r.day_of_month, v_last_day) - 1), r.amount_minor, r.tax_minor,
                                  r.method, r.supplier_id);
    update public.expense_templates set last_month = v_month where id = r.id;
    v_count := v_count + 1;
  end loop;
  return v_count;
end $$;

revoke all on function public.generate_recurring_expenses(uuid, date) from public, anon;
grant execute on function public.generate_recurring_expenses(uuid, date) to authenticated;

revoke all on all functions in schema app_private from public, anon, authenticated;
grant execute on function app_private.member_org_ids(), app_private.member_branch_ids(),
  app_private.org_ids_with(text), app_private.branch_ids_with(text),
  app_private.full_access_org_ids(), app_private.assigned_branch_ids(),
  app_private.org_ids_with_any_branch(text) to authenticated;
