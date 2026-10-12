-- =============================================================================
-- Resto — 009_achats_depenses
-- Fournisseurs, bons de commande, réceptions (entrées en stock valorisées),
-- factures fournisseurs, paiements et dettes, dépenses par catégorie,
-- justificatifs (stockage privé), rapport financier par période.
-- À coller APRÈS 008, puis supabase/tests/009_achats_depenses_tests.sql.
--
-- Montants en unités mineures ; prix d'achat unitaires en numeric (unités
-- mineures par unité saisie) pour garder la précision.
-- Rien n'est supprimé : annulation avec motif, paiements annulés conservés.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Fournisseurs (catalogue de l'organisation)
-- -----------------------------------------------------------------------------
create table public.suppliers (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations (id) on delete restrict,
  name text not null check (length(btrim(name)) between 1 and 120),
  contact_name text check (length(contact_name) <= 120),
  phone text check (length(phone) <= 40),
  email text check (length(email) <= 254),
  tax_id text check (length(tax_id) <= 60),
  address text check (length(address) <= 300),
  payment_terms_days smallint not null default 0 check (payment_terms_days between 0 and 365),
  notes text check (length(notes) <= 1000),
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (organization_id, id),
  unique (organization_id, name)
);
create trigger suppliers_touch before update on public.suppliers
  for each row execute function app_private.touch_updated_at();

-- Organisations où j'ai une permission sur au moins un établissement.
create or replace function app_private.org_ids_with_any_branch(p_perm text)
returns setof uuid language sql stable security definer set search_path = '' as $$
  select distinct b.organization_id from public.branches b
   where b.id in (select app_private.branch_ids_with(p_perm))
$$;

-- -----------------------------------------------------------------------------
-- Bons de commande et réceptions
-- -----------------------------------------------------------------------------
create table public.purchase_orders (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null,
  branch_id uuid not null,
  supplier_id uuid not null,
  number integer not null check (number > 0),
  status text not null default 'draft' check (status in ('draft', 'sent', 'partially_received', 'received', 'cancelled')),
  expected_on date,
  currency char(3) not null references public.ref_currencies (code),
  total_minor bigint not null default 0 check (total_minor >= 0),
  note text check (length(note) <= 500),
  created_by uuid references auth.users (id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  cancel_reason text check (length(cancel_reason) <= 500),
  unique (organization_id, id),
  unique (branch_id, number),
  foreign key (organization_id, branch_id) references public.branches (organization_id, id) on delete restrict,
  foreign key (organization_id, supplier_id) references public.suppliers (organization_id, id) on delete restrict
);
create trigger purchase_orders_touch before update on public.purchase_orders
  for each row execute function app_private.touch_updated_at();

create table public.purchase_order_lines (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null,
  po_id uuid not null,
  ingredient_id uuid not null,
  quantity numeric(18, 4) not null check (quantity > 0),
  unit_code text not null references public.ref_units (code),
  unit_price numeric(20, 4) not null default 0 check (unit_price >= 0),
  received_quantity numeric(18, 4) not null default 0 check (received_quantity >= 0),
  sort_order integer not null default 0,
  unique (organization_id, id),
  foreign key (organization_id, po_id) references public.purchase_orders (organization_id, id) on delete cascade,
  foreign key (organization_id, ingredient_id) references public.ingredients (organization_id, id) on delete restrict
);

create table public.goods_receipts (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null,
  branch_id uuid not null,
  location_id uuid not null,
  supplier_id uuid not null,
  po_id uuid,
  reference text check (length(reference) <= 80),
  note text check (length(note) <= 500),
  total_minor bigint not null default 0,
  received_at timestamptz not null default now(),
  created_by uuid references auth.users (id) on delete set null,
  unique (organization_id, id),
  foreign key (organization_id, branch_id, location_id) references public.stock_locations (organization_id, branch_id, id) on delete restrict,
  foreign key (organization_id, supplier_id) references public.suppliers (organization_id, id) on delete restrict,
  foreign key (organization_id, po_id) references public.purchase_orders (organization_id, id) on delete restrict
);
create table public.goods_receipt_lines (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null,
  receipt_id uuid not null,
  po_line_id uuid,
  ingredient_id uuid not null,
  quantity numeric(18, 4) not null check (quantity > 0),
  unit_code text not null references public.ref_units (code),
  unit_price numeric(20, 4) not null default 0 check (unit_price >= 0),
  foreign key (organization_id, receipt_id) references public.goods_receipts (organization_id, id) on delete restrict,
  foreign key (organization_id, po_line_id) references public.purchase_order_lines (organization_id, id) on delete restrict,
  foreign key (organization_id, ingredient_id) references public.ingredients (organization_id, id) on delete restrict
);
alter table public.stock_movements add constraint stock_movements_receipt_fk
  foreign key (organization_id, receipt_id) references public.goods_receipts (organization_id, id) on delete restrict;

-- -----------------------------------------------------------------------------
-- Factures fournisseurs, paiements
-- -----------------------------------------------------------------------------
create table public.supplier_invoices (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null,
  branch_id uuid not null,
  supplier_id uuid not null,
  number text not null check (length(btrim(number)) between 1 and 60),
  invoice_date date not null,
  due_date date,
  currency char(3) not null references public.ref_currencies (code),
  subtotal_minor bigint not null check (subtotal_minor >= 0),
  tax_minor bigint not null default 0 check (tax_minor >= 0),
  total_minor bigint generated always as (subtotal_minor + tax_minor) stored,
  paid_minor bigint not null default 0 check (paid_minor >= 0),
  status text not null default 'open' check (status in ('open', 'paid', 'cancelled')),
  attachment_path text check (length(attachment_path) <= 300),
  note text check (length(note) <= 500),
  created_by uuid references auth.users (id) on delete set null,
  created_at timestamptz not null default now(),
  cancelled_at timestamptz,
  cancel_reason text check (length(cancel_reason) <= 500),
  unique (organization_id, id),
  -- Une même facture fournisseur n'est saisie qu'une fois.
  unique (supplier_id, number),
  check (due_date is null or due_date >= invoice_date),
  foreign key (organization_id, branch_id) references public.branches (organization_id, id) on delete restrict,
  foreign key (organization_id, supplier_id) references public.suppliers (organization_id, id) on delete restrict
);
create index supplier_invoices_branch_idx on public.supplier_invoices (branch_id, invoice_date desc);

create table public.supplier_invoice_receipts (
  organization_id uuid not null,
  invoice_id uuid not null,
  receipt_id uuid not null,
  primary key (invoice_id, receipt_id),
  foreign key (organization_id, invoice_id) references public.supplier_invoices (organization_id, id) on delete cascade,
  foreign key (organization_id, receipt_id) references public.goods_receipts (organization_id, id) on delete restrict
);

create table public.supplier_payments (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null,
  branch_id uuid not null,
  invoice_id uuid not null,
  amount_minor bigint not null check (amount_minor > 0),
  method text not null check (method in ('cash', 'card', 'mobile_money', 'transfer', 'other')),
  paid_on date not null,
  reference text check (length(reference) <= 120),
  cash_movement_id uuid,
  status text not null default 'confirmed' check (status in ('confirmed', 'voided')),
  created_by uuid references auth.users (id) on delete set null,
  created_at timestamptz not null default now(),
  voided_at timestamptz,
  void_reason text check (length(void_reason) <= 500),
  unique (organization_id, id),
  check ((status = 'voided') = (voided_at is not null)),
  foreign key (organization_id, invoice_id) references public.supplier_invoices (organization_id, id) on delete restrict
);

-- -----------------------------------------------------------------------------
-- Dépenses
-- -----------------------------------------------------------------------------
create table public.expense_categories (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations (id) on delete restrict,
  -- Catégories par défaut : code traduit par l'application ; sinon, nom saisi.
  code text check (code ~ '^[a-z_]+$'),
  name text not null check (length(btrim(name)) between 1 and 80),
  active boolean not null default true,
  unique (organization_id, id),
  unique (organization_id, name)
);

create or replace function app_private.seed_expense_categories(p_org uuid)
returns void language sql volatile security definer set search_path = '' as $$
  insert into public.expense_categories (organization_id, code, name)
  select p_org, c, c from unnest(array['rent', 'electricity', 'water', 'gas', 'salaries', 'transport', 'maintenance',
    'marketing', 'supplies', 'taxes', 'bank_fees', 'other']) c
  on conflict (organization_id, name) do nothing
$$;
select app_private.seed_expense_categories(id) from public.organizations;

create or replace function app_private.on_organization_created()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  perform app_private.seed_expense_categories(new.id);
  return null;
end $$;
create trigger organizations_seed_categories after insert on public.organizations
  for each row execute function app_private.on_organization_created();

create table public.expenses (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null,
  branch_id uuid not null,
  category_id uuid not null,
  supplier_id uuid,
  description text not null check (length(btrim(description)) between 1 and 300),
  expense_date date not null,
  currency char(3) not null references public.ref_currencies (code),
  amount_minor bigint not null check (amount_minor > 0),
  tax_minor bigint not null default 0 check (tax_minor >= 0 and tax_minor <= amount_minor),
  method text not null check (method in ('cash', 'card', 'mobile_money', 'transfer', 'other')),
  cash_movement_id uuid,
  attachment_path text check (length(attachment_path) <= 300),
  status text not null default 'recorded' check (status in ('recorded', 'cancelled')),
  created_by uuid references auth.users (id) on delete set null,
  created_at timestamptz not null default now(),
  cancelled_at timestamptz,
  cancel_reason text check (length(cancel_reason) <= 500),
  unique (organization_id, id),
  check ((status = 'cancelled') = (cancelled_at is not null)),
  foreign key (organization_id, branch_id) references public.branches (organization_id, id) on delete restrict,
  foreign key (organization_id, category_id) references public.expense_categories (organization_id, id) on delete restrict,
  foreign key (organization_id, supplier_id) references public.suppliers (organization_id, id) on delete restrict
);
create index expenses_branch_date_idx on public.expenses (branch_id, expense_date desc);

-- -----------------------------------------------------------------------------
-- Justificatifs : stockage privé {organisation}/{établissement}/{fichier}
-- -----------------------------------------------------------------------------
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('documents', 'documents', false, 5242880, array['application/pdf', 'image/jpeg', 'image/png', 'image/webp'])
on conflict (id) do update set public = false, file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists resto_documents_read on storage.objects;
drop policy if exists resto_documents_insert on storage.objects;
create policy resto_documents_read on storage.objects for select to authenticated
  using (bucket_id = 'documents' and (
    (storage.foldername(name))[2] in (select x::text from app_private.branch_ids_with('finance.read') x)
    or (storage.foldername(name))[2] in (select x::text from app_private.branch_ids_with('expenses.manage') x)
    or (storage.foldername(name))[2] in (select x::text from app_private.branch_ids_with('purchases.manage') x)));
create policy resto_documents_insert on storage.objects for insert to authenticated
  with check (bucket_id = 'documents' and (
    (storage.foldername(name))[2] in (select x::text from app_private.branch_ids_with('expenses.manage') x)
    or (storage.foldername(name))[2] in (select x::text from app_private.branch_ids_with('purchases.manage') x)));

-- -----------------------------------------------------------------------------
-- Audit, droits, RLS
-- -----------------------------------------------------------------------------
do $$
declare t text;
begin
  foreach t in array array['suppliers', 'purchase_orders', 'purchase_order_lines', 'goods_receipts', 'goods_receipt_lines',
    'supplier_invoices', 'supplier_invoice_receipts', 'supplier_payments', 'expense_categories', 'expenses'] loop
    execute format('create trigger %I after insert or update or delete on public.%I
      for each row execute function app_private.audit_row()', t || '_audit', t);
    execute format('alter table public.%I enable row level security', t);
    execute format('revoke all on public.%I from anon, authenticated', t);
    execute format('grant select on public.%I to authenticated', t);
  end loop;
  foreach t in array array['purchase_orders', 'goods_receipts', 'supplier_invoices', 'supplier_payments'] loop
    execute format('create policy %I on public.%I for select to authenticated
      using (branch_id in (select app_private.branch_ids_with(''purchases.manage''))
          or branch_id in (select app_private.branch_ids_with(''finance.read'')))', t || '_read', t);
  end loop;
end $$;

create policy purchase_order_lines_read on public.purchase_order_lines for select to authenticated
  using (po_id in (select id from public.purchase_orders));
create policy goods_receipt_lines_read on public.goods_receipt_lines for select to authenticated
  using (receipt_id in (select id from public.goods_receipts));
create policy supplier_invoice_receipts_read on public.supplier_invoice_receipts for select to authenticated
  using (invoice_id in (select id from public.supplier_invoices));
create policy expenses_read on public.expenses for select to authenticated
  using (branch_id in (select app_private.branch_ids_with('expenses.manage'))
      or branch_id in (select app_private.branch_ids_with('finance.read')));

grant insert (id, organization_id, name, contact_name, phone, email, tax_id, address, payment_terms_days, notes, active),
  update (name, contact_name, phone, email, tax_id, address, payment_terms_days, notes, active) on public.suppliers to authenticated;
create policy suppliers_read on public.suppliers for select to authenticated
  using (organization_id in (select app_private.member_org_ids()));
create policy suppliers_insert on public.suppliers for insert to authenticated
  with check (organization_id in (select app_private.org_ids_with_any_branch('purchases.manage')));
create policy suppliers_update on public.suppliers for update to authenticated
  using (organization_id in (select app_private.org_ids_with_any_branch('purchases.manage')))
  with check (organization_id in (select app_private.org_ids_with_any_branch('purchases.manage')));

grant insert (id, organization_id, name, active), update (name, active) on public.expense_categories to authenticated;
create policy expense_categories_read on public.expense_categories for select to authenticated
  using (organization_id in (select app_private.member_org_ids()));
create policy expense_categories_insert on public.expense_categories for insert to authenticated
  with check (organization_id in (select app_private.org_ids_with_any_branch('expenses.manage')));
create policy expense_categories_update on public.expense_categories for update to authenticated
  using (organization_id in (select app_private.org_ids_with_any_branch('expenses.manage')) and code is null)
  with check (organization_id in (select app_private.org_ids_with_any_branch('expenses.manage')));

-- -----------------------------------------------------------------------------
-- Fonctions internes
-- -----------------------------------------------------------------------------

-- Sortie d'espèces de la caisse (paiement fournisseur ou dépense payés en caisse).
create or replace function app_private.cash_out(p_session uuid, p_branch uuid, p_amount bigint, p_reason text)
returns uuid language plpgsql volatile security definer set search_path = '' as $$
declare
  v_session public.cash_sessions;
  v_id uuid;
begin
  perform app_private.assert_branch_perm(p_branch, 'cash.operate');
  v_session := app_private.lock_open_session(p_session, p_branch);
  if p_amount > app_private.expected_cash(p_session) then perform app_private.fail('resto.not_enough_cash'); end if;
  insert into public.cash_movements (organization_id, branch_id, session_id, kind, amount_minor, reason, created_by)
  values (v_session.organization_id, p_branch, p_session, 'out', p_amount, left(p_reason, 300), auth.uid())
  returning id into v_id;
  return v_id;
end $$;

create or replace function app_private.validate_attachment(p_path text, p_org uuid, p_branch uuid)
returns void language plpgsql stable security definer set search_path = '' as $$
begin
  if p_path is not null and p_path not like p_org::text || '/' || p_branch::text || '/%' then
    perform app_private.fail('resto.invalid_attachment');
  end if;
end $$;

-- -----------------------------------------------------------------------------
-- RPC : achats
-- -----------------------------------------------------------------------------

-- Crée ou modifie un bon de commande en brouillon.
-- p_lines : [{"ingredient_id":…, "quantity":10, "unit":"kg", "unit_price":2500}, …]
create or replace function public.save_purchase_order(
  p_id uuid, p_branch uuid, p_supplier uuid, p_expected_on date, p_note text, p_lines jsonb)
returns uuid language plpgsql security definer set search_path = '' as $$
declare
  v_branch public.branches;
  v_po public.purchase_orders;
  v_bad boolean;
begin
  perform app_private.assert_branch_perm(p_branch, 'purchases.manage');
  select * into v_branch from public.branches where id = p_branch;
  if not exists (select 1 from public.suppliers where id = p_supplier and organization_id = v_branch.organization_id) then
    perform app_private.fail('resto.invalid_purchase');
  end if;
  if jsonb_typeof(coalesce(p_lines, 'null'::jsonb)) <> 'array' then perform app_private.fail('resto.invalid_purchase'); end if;
  if jsonb_array_length(p_lines) = 0 then perform app_private.fail('resto.invalid_purchase'); end if;
  select exists (
    select 1 from jsonb_array_elements(p_lines) l
      left join public.ingredients i on i.id = (l ->> 'ingredient_id')::uuid and i.organization_id = v_branch.organization_id
     where i.id is null or coalesce((l ->> 'quantity')::numeric, 0) <= 0 or coalesce((l ->> 'unit_price')::numeric, 0) < 0
        or app_private.convert_qty(1, l ->> 'unit', i.unit_code) is null)
    into v_bad;
  if v_bad then perform app_private.fail('resto.invalid_purchase'); end if;

  if p_id is null then
    insert into public.purchase_orders (organization_id, branch_id, supplier_id, number, expected_on, currency, note, created_by)
    values (v_branch.organization_id, p_branch, p_supplier, app_private.next_counter(p_branch, 'purchase_order'),
            p_expected_on, v_branch.currency, nullif(btrim(p_note), ''), auth.uid())
    returning * into v_po;
  else
    select * into v_po from public.purchase_orders where id = p_id and branch_id = p_branch for update;
    if v_po.id is null or v_po.status <> 'draft' then perform app_private.fail('resto.purchase_not_draft'); end if;
    update public.purchase_orders set supplier_id = p_supplier, expected_on = p_expected_on, note = nullif(btrim(p_note), '')
     where id = p_id;
    delete from public.purchase_order_lines where po_id = p_id;
  end if;
  insert into public.purchase_order_lines (organization_id, po_id, ingredient_id, quantity, unit_code, unit_price, sort_order)
  select v_branch.organization_id, v_po.id, (l ->> 'ingredient_id')::uuid, (l ->> 'quantity')::numeric, l ->> 'unit',
         coalesce((l ->> 'unit_price')::numeric, 0), (row_number() over ())::int
    from jsonb_array_elements(p_lines) l;
  update public.purchase_orders
     set total_minor = (select coalesce(round(sum(quantity * unit_price)), 0) from public.purchase_order_lines where po_id = v_po.id)
   where id = v_po.id;
  return v_po.id;
exception
  when invalid_text_representation or numeric_value_out_of_range then
    perform app_private.fail('resto.invalid_purchase');
end $$;

-- Brouillon → envoyé ; annulation possible tant que rien n'est reçu.
create or replace function public.set_purchase_order_status(p_id uuid, p_status text, p_reason text default null)
returns void language plpgsql security definer set search_path = '' as $$
declare v_po public.purchase_orders;
begin
  select * into v_po from public.purchase_orders where id = p_id for update;
  perform app_private.assert_branch_perm(v_po.branch_id, 'purchases.manage');
  if p_status = 'sent' and v_po.status = 'draft' then
    update public.purchase_orders set status = 'sent' where id = p_id;
  elsif p_status = 'cancelled' and v_po.status in ('draft', 'sent') then
    update public.purchase_orders set status = 'cancelled', cancel_reason = nullif(btrim(p_reason), '') where id = p_id;
  else
    perform app_private.fail('resto.invalid_status');
  end if;
end $$;

-- Réception de marchandises : entrées en stock valorisées (coût moyen),
-- avancement du bon de commande. p_lines : [{"po_line_id":…?, "ingredient_id":…,
-- "quantity":5, "unit":"kg", "unit_price":2500}, …]
create or replace function public.record_goods_receipt(
  p_branch uuid, p_location uuid, p_supplier uuid, p_po uuid, p_reference text, p_lines jsonb,
  p_note text default null, p_client_id uuid default null)
returns uuid language plpgsql security definer set search_path = '' as $$
declare
  v_branch public.branches;
  v_po public.purchase_orders;
  v_receipt uuid := coalesce(p_client_id, gen_random_uuid());
  v_bad boolean;
  r record;
  v_qty numeric;
  v_cost numeric;
begin
  perform app_private.assert_branch_perm(p_branch, 'purchases.manage');
  if exists (select 1 from public.goods_receipts where id = v_receipt) then return v_receipt; end if;
  select * into v_branch from public.branches where id = p_branch;
  if not exists (select 1 from public.suppliers where id = p_supplier and organization_id = v_branch.organization_id)
     or not exists (select 1 from public.stock_locations where id = p_location and branch_id = p_branch)
     or jsonb_typeof(coalesce(p_lines, 'null'::jsonb)) <> 'array' then
    perform app_private.fail('resto.invalid_purchase');
  end if;
  if jsonb_array_length(p_lines) = 0 then perform app_private.fail('resto.invalid_purchase'); end if;
  if p_po is not null then
    select * into v_po from public.purchase_orders where id = p_po for update;
    if v_po.id is null or v_po.branch_id <> p_branch or v_po.supplier_id <> p_supplier
       or v_po.status not in ('draft', 'sent', 'partially_received') then
      perform app_private.fail('resto.invalid_purchase');
    end if;
  end if;
  select exists (
    select 1 from jsonb_array_elements(p_lines) l
      left join public.ingredients i on i.id = (l ->> 'ingredient_id')::uuid and i.organization_id = v_branch.organization_id
      left join public.purchase_order_lines pl on pl.id = (l ->> 'po_line_id')::uuid
     where i.id is null or coalesce((l ->> 'quantity')::numeric, 0) <= 0 or coalesce((l ->> 'unit_price')::numeric, 0) < 0
        or app_private.convert_qty(1, l ->> 'unit', i.unit_code) is null
        or ((l ->> 'po_line_id') is not null and (pl.id is null or pl.po_id is distinct from p_po or pl.ingredient_id <> i.id)))
    into v_bad;
  if v_bad then perform app_private.fail('resto.invalid_purchase'); end if;

  insert into public.goods_receipts (id, organization_id, branch_id, location_id, supplier_id, po_id, reference, note, created_by)
  values (v_receipt, v_branch.organization_id, p_branch, p_location, p_supplier, p_po, nullif(btrim(p_reference), ''),
          nullif(btrim(p_note), ''), auth.uid());

  for r in
    select (l ->> 'po_line_id')::uuid as po_line_id, (l ->> 'ingredient_id')::uuid as ingredient_id,
           (l ->> 'quantity')::numeric as quantity, l ->> 'unit' as unit, coalesce((l ->> 'unit_price')::numeric, 0) as unit_price,
           i.unit_code as stock_unit
      from jsonb_array_elements(p_lines) l join public.ingredients i on i.id = (l ->> 'ingredient_id')::uuid
  loop
    insert into public.goods_receipt_lines (organization_id, receipt_id, po_line_id, ingredient_id, quantity, unit_code, unit_price)
    values (v_branch.organization_id, v_receipt, r.po_line_id, r.ingredient_id, r.quantity, r.unit, r.unit_price);
    v_qty := app_private.convert_qty(r.quantity, r.unit, r.stock_unit);
    v_cost := r.unit_price * r.quantity / v_qty;
    perform app_private.apply_entry_cost(p_branch, r.ingredient_id, v_qty, v_cost);
    insert into public.stock_movements (organization_id, branch_id, location_id, ingredient_id, kind, quantity, unit_cost,
                                        currency, receipt_id, reason, created_by)
    values (v_branch.organization_id, p_branch, p_location, r.ingredient_id, 'receipt', v_qty, v_cost, v_branch.currency,
            v_receipt, nullif(btrim(p_reference), ''), auth.uid());
    if r.po_line_id is not null then
      update public.purchase_order_lines
         set received_quantity = received_quantity + app_private.convert_qty(r.quantity, r.unit, unit_code)
       where id = r.po_line_id;
    end if;
  end loop;

  update public.goods_receipts
     set total_minor = (select coalesce(round(sum(quantity * unit_price)), 0) from public.goods_receipt_lines where receipt_id = v_receipt)
   where id = v_receipt;
  if p_po is not null then
    update public.purchase_orders
       set status = case when not exists (select 1 from public.purchase_order_lines
                                           where po_id = p_po and received_quantity < quantity)
                         then 'received' else 'partially_received' end
     where id = p_po;
  end if;
  return v_receipt;
exception
  when invalid_text_representation or numeric_value_out_of_range then
    perform app_private.fail('resto.invalid_purchase');
end $$;

-- Facture fournisseur (une seule fois par numéro et fournisseur), liée aux réceptions.
create or replace function public.record_supplier_invoice(
  p_branch uuid, p_supplier uuid, p_number text, p_invoice_date date, p_due_date date,
  p_subtotal bigint, p_tax bigint, p_receipts uuid[] default '{}', p_attachment text default null,
  p_note text default null, p_client_id uuid default null)
returns uuid language plpgsql security definer set search_path = '' as $$
declare
  v_branch public.branches;
  v_supplier public.suppliers;
  v_id uuid;
begin
  perform app_private.assert_branch_perm(p_branch, 'purchases.manage');
  if p_client_id is not null and exists (select 1 from public.supplier_invoices where id = p_client_id) then
    return p_client_id;
  end if;
  select * into v_branch from public.branches where id = p_branch;
  select * into v_supplier from public.suppliers where id = p_supplier and organization_id = v_branch.organization_id;
  if v_supplier.id is null or length(btrim(coalesce(p_number, ''))) = 0 or p_invoice_date is null
     or coalesce(p_subtotal, -1) < 0 or coalesce(p_tax, 0) < 0 then
    perform app_private.fail('resto.invalid_purchase');
  end if;
  if exists (select 1 from public.supplier_invoices where supplier_id = p_supplier and number = btrim(p_number)) then
    perform app_private.fail('resto.duplicate_invoice');
  end if;
  perform app_private.validate_attachment(p_attachment, v_branch.organization_id, p_branch);
  if exists (select 1 from unnest(coalesce(p_receipts, '{}')) x (id)
              where not exists (select 1 from public.goods_receipts g where g.id = x.id and g.branch_id = p_branch
                                   and g.supplier_id = p_supplier)) then
    perform app_private.fail('resto.invalid_purchase');
  end if;
  insert into public.supplier_invoices (id, organization_id, branch_id, supplier_id, number, invoice_date, due_date, currency,
                                        subtotal_minor, tax_minor, attachment_path, note, created_by)
  values (coalesce(p_client_id, gen_random_uuid()), v_branch.organization_id, p_branch, p_supplier, btrim(p_number),
          p_invoice_date, coalesce(p_due_date, p_invoice_date + v_supplier.payment_terms_days), v_branch.currency,
          p_subtotal, coalesce(p_tax, 0), p_attachment, nullif(btrim(p_note), ''), auth.uid())
  returning id into v_id;
  insert into public.supplier_invoice_receipts (organization_id, invoice_id, receipt_id)
  select v_branch.organization_id, v_id, x from unnest(coalesce(p_receipts, '{}')) x group by x;
  return v_id;
end $$;

-- Paiement d'une facture (jamais plus que le reste dû). Espèces de la caisse :
-- p_cash_session renseignée → sortie de caisse automatique.
create or replace function public.record_supplier_payment(
  p_invoice uuid, p_amount bigint, p_method text, p_paid_on date, p_reference text default null,
  p_cash_session uuid default null, p_client_id uuid default null)
returns uuid language plpgsql security definer set search_path = '' as $$
declare
  v_inv public.supplier_invoices;
  v_cash uuid;
  v_id uuid;
begin
  select * into v_inv from public.supplier_invoices where id = p_invoice for update;
  perform app_private.assert_branch_perm(v_inv.branch_id, 'purchases.manage');
  if p_client_id is not null and exists (select 1 from public.supplier_payments where id = p_client_id) then
    return p_client_id;
  end if;
  if v_inv.status <> 'open' then perform app_private.fail('resto.invoice_not_open'); end if;
  if coalesce(p_method, '') not in ('cash', 'card', 'mobile_money', 'transfer', 'other') or p_paid_on is null then
    perform app_private.fail('resto.invalid_payment');
  end if;
  if coalesce(p_amount, 0) <= 0 or p_amount > v_inv.total_minor - v_inv.paid_minor then
    perform app_private.fail('resto.overpayment');
  end if;
  if p_cash_session is not null then
    if p_method <> 'cash' then perform app_private.fail('resto.invalid_payment'); end if;
    v_cash := app_private.cash_out(p_cash_session, v_inv.branch_id, p_amount, 'facture ' || v_inv.number);
  end if;
  insert into public.supplier_payments (id, organization_id, branch_id, invoice_id, amount_minor, method, paid_on, reference,
                                        cash_movement_id, created_by)
  values (coalesce(p_client_id, gen_random_uuid()), v_inv.organization_id, v_inv.branch_id, p_invoice, p_amount, p_method,
          p_paid_on, nullif(btrim(p_reference), ''), v_cash, auth.uid())
  returning id into v_id;
  update public.supplier_invoices set paid_minor = paid_minor + p_amount,
         status = case when paid_minor + p_amount >= total_minor then 'paid' else 'open' end
   where id = p_invoice;
  return v_id;
end $$;

create or replace function public.void_supplier_payment(p_payment uuid, p_reason text)
returns void language plpgsql security definer set search_path = '' as $$
declare v_pay public.supplier_payments;
begin
  select * into v_pay from public.supplier_payments where id = p_payment for update;
  perform app_private.assert_branch_perm(v_pay.branch_id, 'purchases.manage');
  if v_pay.status <> 'confirmed' then perform app_private.fail('resto.invalid_payment'); end if;
  if length(btrim(coalesce(p_reason, ''))) < 3 then perform app_private.fail('resto.reason_required'); end if;
  update public.supplier_payments set status = 'voided', voided_at = now(), void_reason = btrim(p_reason) where id = p_payment;
  update public.supplier_invoices set paid_minor = paid_minor - v_pay.amount_minor, status = 'open'
   where id = v_pay.invoice_id and status <> 'cancelled';
end $$;

create or replace function public.cancel_supplier_invoice(p_invoice uuid, p_reason text)
returns void language plpgsql security definer set search_path = '' as $$
declare v_inv public.supplier_invoices;
begin
  select * into v_inv from public.supplier_invoices where id = p_invoice for update;
  perform app_private.assert_branch_perm(v_inv.branch_id, 'purchases.manage');
  if v_inv.status = 'cancelled' then perform app_private.fail('resto.invoice_not_open'); end if;
  if v_inv.paid_minor > 0 then perform app_private.fail('resto.invoice_has_payments'); end if;
  if length(btrim(coalesce(p_reason, ''))) < 3 then perform app_private.fail('resto.reason_required'); end if;
  update public.supplier_invoices set status = 'cancelled', cancelled_at = now(), cancel_reason = btrim(p_reason)
   where id = p_invoice;
end $$;

-- -----------------------------------------------------------------------------
-- RPC : dépenses
-- -----------------------------------------------------------------------------
create or replace function public.record_expense(
  p_branch uuid, p_category uuid, p_description text, p_expense_date date, p_amount bigint, p_tax bigint,
  p_method text, p_supplier uuid default null, p_cash_session uuid default null, p_attachment text default null,
  p_client_id uuid default null)
returns uuid language plpgsql security definer set search_path = '' as $$
declare
  v_branch public.branches;
  v_cash uuid;
  v_id uuid;
begin
  perform app_private.assert_branch_perm(p_branch, 'expenses.manage');
  if p_client_id is not null and exists (select 1 from public.expenses where id = p_client_id) then return p_client_id; end if;
  select * into v_branch from public.branches where id = p_branch;
  if not exists (select 1 from public.expense_categories where id = p_category and organization_id = v_branch.organization_id and active)
     or (p_supplier is not null and not exists (select 1 from public.suppliers where id = p_supplier
                                                  and organization_id = v_branch.organization_id))
     or length(btrim(coalesce(p_description, ''))) = 0 or p_expense_date is null
     or coalesce(p_amount, 0) <= 0 or coalesce(p_tax, 0) < 0 or coalesce(p_tax, 0) > p_amount
     or coalesce(p_method, '') not in ('cash', 'card', 'mobile_money', 'transfer', 'other') then
    perform app_private.fail('resto.invalid_expense');
  end if;
  perform app_private.validate_attachment(p_attachment, v_branch.organization_id, p_branch);
  if p_cash_session is not null then
    if p_method <> 'cash' then perform app_private.fail('resto.invalid_payment'); end if;
    v_cash := app_private.cash_out(p_cash_session, p_branch, p_amount, btrim(p_description));
  end if;
  insert into public.expenses (id, organization_id, branch_id, category_id, supplier_id, description, expense_date, currency,
                               amount_minor, tax_minor, method, cash_movement_id, attachment_path, created_by)
  values (coalesce(p_client_id, gen_random_uuid()), v_branch.organization_id, p_branch, p_category, p_supplier,
          btrim(p_description), p_expense_date, v_branch.currency, p_amount, coalesce(p_tax, 0), p_method, v_cash,
          p_attachment, auth.uid())
  returning id into v_id;
  return v_id;
end $$;

-- Annulation tracée. Payée en espèces d'une caisse encore ouverte : l'argent
-- est remis en caisse automatiquement.
create or replace function public.cancel_expense(p_expense uuid, p_reason text)
returns void language plpgsql security definer set search_path = '' as $$
declare
  v_exp public.expenses;
  v_mov public.cash_movements;
begin
  select * into v_exp from public.expenses where id = p_expense for update;
  perform app_private.assert_branch_perm(v_exp.branch_id, 'expenses.manage');
  if v_exp.status <> 'recorded' then perform app_private.fail('resto.invalid_expense'); end if;
  if length(btrim(coalesce(p_reason, ''))) < 3 then perform app_private.fail('resto.reason_required'); end if;
  if v_exp.cash_movement_id is not null then
    select * into v_mov from public.cash_movements where id = v_exp.cash_movement_id;
    if exists (select 1 from public.cash_sessions where id = v_mov.session_id and status = 'open') then
      insert into public.cash_movements (organization_id, branch_id, session_id, kind, amount_minor, reason, created_by)
      values (v_mov.organization_id, v_mov.branch_id, v_mov.session_id, 'in', v_mov.amount_minor,
              left('annulation : ' || v_exp.description, 300), auth.uid());
    end if;
  end if;
  update public.expenses set status = 'cancelled', cancelled_at = now(), cancel_reason = btrim(p_reason) where id = p_expense;
end $$;

-- -----------------------------------------------------------------------------
-- Rapport financier d'une période (journées locales de l'établissement)
--   sales_ttc / sales_tax / sales_ht : commandes clôturées
--   collected : encaissements nets (paiements − remboursements)
--   cogs : coût théorique des ventes (consommations valorisées au coût moyen)
--   losses : pertes, repas du personnel et écarts d'inventaire valorisés
--   purchases : factures fournisseurs (HT) ; expenses : dépenses (HT)
--   gross_margin = sales_ht − cogs ; estimated_result = gross_margin − losses − expenses_ht
--   supplier_debt : reste dû sur les factures ouvertes (à la date du jour)
-- -----------------------------------------------------------------------------
create or replace function public.finance_summary(p_branch uuid, p_from date, p_to date)
returns jsonb language plpgsql stable security definer set search_path = '' as $$
declare
  v_tz text;
  v_sales_ttc bigint;
  v_sales_tax bigint;
  v_cogs numeric;
  v_losses numeric;
  v_exp_ht bigint;
begin
  perform app_private.assert_branch_perm(p_branch, 'finance.read');
  if p_from is null or p_to is null or p_to < p_from then perform app_private.fail('resto.invalid_period'); end if;
  select timezone into v_tz from public.branches where id = p_branch;
  select coalesce(sum(total_minor), 0), coalesce(sum(tax_minor), 0) into v_sales_ttc, v_sales_tax
    from public.orders where branch_id = p_branch and status = 'closed' and business_date between p_from and p_to;
  select coalesce(sum(-quantity * unit_cost), 0) into v_cogs
    from public.stock_movements
   where branch_id = p_branch and kind = 'sale' and (created_at at time zone v_tz)::date between p_from and p_to;
  select coalesce(sum(-quantity * unit_cost), 0) into v_losses
    from public.stock_movements
   where branch_id = p_branch and kind in ('waste', 'staff_meal', 'inventory', 'adjustment')
     and (created_at at time zone v_tz)::date between p_from and p_to;
  select coalesce(sum(amount_minor - tax_minor), 0) into v_exp_ht
    from public.expenses where branch_id = p_branch and status = 'recorded' and expense_date between p_from and p_to;
  return jsonb_build_object(
    'sales_ttc', v_sales_ttc,
    'sales_tax', v_sales_tax,
    'sales_ht', v_sales_ttc - v_sales_tax,
    'orders_closed', (select count(*) from public.orders where branch_id = p_branch and status = 'closed'
                        and business_date between p_from and p_to),
    'collected', coalesce((select sum(amount_minor) from public.payments where branch_id = p_branch and status = 'confirmed'
                             and (created_at at time zone v_tz)::date between p_from and p_to), 0)
               - coalesce((select sum(amount_minor) from public.refunds where branch_id = p_branch
                             and (created_at at time zone v_tz)::date between p_from and p_to), 0),
    'cogs', round(v_cogs),
    'losses', round(v_losses),
    'purchases', coalesce((select sum(subtotal_minor) from public.supplier_invoices where branch_id = p_branch
                             and status <> 'cancelled' and invoice_date between p_from and p_to), 0),
    'expenses_ht', v_exp_ht,
    'expenses_by_category', coalesce((
      select jsonb_agg(jsonb_build_object('code', c.code, 'name', c.name, 'total', x.total) order by x.total desc)
        from (select category_id, sum(amount_minor - tax_minor) as total from public.expenses
               where branch_id = p_branch and status = 'recorded' and expense_date between p_from and p_to
               group by category_id) x
        join public.expense_categories c on c.id = x.category_id), '[]'::jsonb),
    'gross_margin', (v_sales_ttc - v_sales_tax) - round(v_cogs),
    'estimated_result', (v_sales_ttc - v_sales_tax) - round(v_cogs) - round(v_losses) - v_exp_ht,
    'supplier_debt', coalesce((select sum(total_minor - paid_minor) from public.supplier_invoices
                                where branch_id = p_branch and status = 'open'), 0));
end $$;

revoke all on function public.save_purchase_order(uuid, uuid, uuid, date, text, jsonb),
  public.set_purchase_order_status(uuid, text, text),
  public.record_goods_receipt(uuid, uuid, uuid, uuid, text, jsonb, text, uuid),
  public.record_supplier_invoice(uuid, uuid, text, date, date, bigint, bigint, uuid[], text, text, uuid),
  public.record_supplier_payment(uuid, bigint, text, date, text, uuid, uuid), public.void_supplier_payment(uuid, text),
  public.cancel_supplier_invoice(uuid, text),
  public.record_expense(uuid, uuid, text, date, bigint, bigint, text, uuid, uuid, text, uuid),
  public.cancel_expense(uuid, text), public.finance_summary(uuid, date, date) from public, anon;
grant execute on function public.save_purchase_order(uuid, uuid, uuid, date, text, jsonb),
  public.set_purchase_order_status(uuid, text, text),
  public.record_goods_receipt(uuid, uuid, uuid, uuid, text, jsonb, text, uuid),
  public.record_supplier_invoice(uuid, uuid, text, date, date, bigint, bigint, uuid[], text, text, uuid),
  public.record_supplier_payment(uuid, bigint, text, date, text, uuid, uuid), public.void_supplier_payment(uuid, text),
  public.cancel_supplier_invoice(uuid, text),
  public.record_expense(uuid, uuid, text, date, bigint, bigint, text, uuid, uuid, text, uuid),
  public.cancel_expense(uuid, text), public.finance_summary(uuid, date, date) to authenticated;

revoke all on all functions in schema app_private from public, anon, authenticated;
grant execute on function app_private.member_org_ids(), app_private.member_branch_ids(),
  app_private.org_ids_with(text), app_private.branch_ids_with(text),
  app_private.full_access_org_ids(), app_private.assigned_branch_ids(),
  app_private.org_ids_with_any_branch(text) to authenticated;
