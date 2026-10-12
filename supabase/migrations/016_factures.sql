-- =============================================================================
-- Resto — 016_factures
-- Factures clients : numérotation continue par établissement (préfixe
-- réglable), coordonnées du client (nom, société, n° fiscal, adresse,
-- e-mail), contenu figé au moment de l'émission (articles, réductions, frais,
-- taxes, paiements). Une facture émise n'est jamais modifiée : elle est
-- annulée avec un motif (le numéro reste utilisé) puis réémise.
-- Une seule facture valable par commande.
-- À coller APRÈS 015, puis supabase/tests/016_factures_tests.sql.
-- =============================================================================

alter table public.branches
  add column if not exists invoice_prefix text not null default 'FA-' check (length(invoice_prefix) <= 20),
  add column if not exists invoice_footer text check (length(invoice_footer) <= 600);
grant insert (invoice_prefix, invoice_footer), update (invoice_prefix, invoice_footer) on public.branches to authenticated;

create table if not exists public.customer_invoices (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null,
  branch_id uuid not null,
  order_id uuid not null,
  number bigint not null,
  label text not null check (length(label) <= 40),       -- préfixe + numéro, tel qu'imprimé
  issued_at timestamptz not null default now(),
  issued_by uuid references auth.users (id) on delete set null,
  customer_name text not null check (length(btrim(customer_name)) between 1 and 160),
  customer_company text check (length(customer_company) <= 160),
  customer_tax_id text check (length(customer_tax_id) <= 60),
  customer_address text check (length(customer_address) <= 500),
  customer_email text check (customer_email is null or customer_email ~ '^[^@\s]+@[^@\s]+\.[^@\s]+$'),
  currency char(3) not null references public.ref_currencies (code),
  prices_include_tax boolean not null,
  tax_rate numeric(6, 3) not null,
  subtotal_minor bigint not null,
  tax_minor bigint not null,
  total_minor bigint not null,
  paid_minor bigint not null,
  discount_minor bigint not null default 0,
  delivery_fee_minor bigint not null default 0,
  lines jsonb not null,
  adjustments jsonb not null default '[]',
  payments jsonb not null default '[]',
  status text not null default 'issued' check (status in ('issued', 'cancelled')),
  cancelled_at timestamptz,
  cancelled_by uuid references auth.users (id) on delete set null,
  cancel_reason text check (length(cancel_reason) <= 500),
  unique (organization_id, id),
  unique (branch_id, number),
  check ((status = 'cancelled') = (cancelled_at is not null)),
  foreign key (organization_id, order_id) references public.orders (organization_id, id) on delete restrict,
  foreign key (organization_id, branch_id) references public.branches (organization_id, id) on delete restrict
);
create unique index if not exists customer_invoices_one_per_order on public.customer_invoices (order_id) where status = 'issued';
create index if not exists customer_invoices_branch_idx on public.customer_invoices (branch_id, issued_at desc);

alter table public.customer_invoices enable row level security;
revoke all on public.customer_invoices from anon, authenticated;
grant select on public.customer_invoices to authenticated;
create policy customer_invoices_read on public.customer_invoices for select to authenticated
  using (branch_id in (select app_private.branch_ids_with('cash.operate'))
      or branch_id in (select app_private.branch_ids_with('finance.read')));
create trigger customer_invoices_audit after insert or update or delete on public.customer_invoices
  for each row execute function app_private.audit_row();

-- Contenu figé : seule l'annulation est permise ensuite.
create or replace function app_private.customer_invoice_immutable()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  if tg_op = 'DELETE' then raise exception 'resto.forbidden' using errcode = '42501'; end if;
  if old.status = 'cancelled'
     or (new.status, new.cancelled_at, new.cancelled_by, new.cancel_reason) is not distinct from
        (old.status, old.cancelled_at, old.cancelled_by, old.cancel_reason)
     or (to_jsonb(new) - array['status', 'cancelled_at', 'cancelled_by', 'cancel_reason'])
        is distinct from (to_jsonb(old) - array['status', 'cancelled_at', 'cancelled_by', 'cancel_reason']) then
    raise exception 'resto.forbidden' using errcode = '42501';
  end if;
  return new;
end $$;
drop trigger if exists customer_invoices_immutable on public.customer_invoices;
create trigger customer_invoices_immutable before update or delete on public.customer_invoices
  for each row execute function app_private.customer_invoice_immutable();

-- Émission (cash.operate ou orders.write). Rejouable ; une commande déjà
-- facturée renvoie sa facture valable.
create or replace function public.issue_invoice(
  p_order uuid, p_customer_name text, p_company text default null, p_tax_id text default null,
  p_address text default null, p_email text default null)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare
  v_order public.orders;
  v_branch public.branches;
  v_existing public.customer_invoices;
  v_number bigint;
  v_inv public.customer_invoices;
begin
  select * into v_order from public.orders where id = p_order for update;
  if v_order.id is null then raise exception 'resto.forbidden' using errcode = '42501'; end if;
  if not (exists (select 1 from app_private.branch_ids_with('cash.operate') x where x = v_order.branch_id)
       or exists (select 1 from app_private.branch_ids_with('orders.write') x where x = v_order.branch_id)) then
    raise exception 'resto.forbidden' using errcode = '42501';
  end if;
  select * into v_existing from public.customer_invoices where order_id = p_order and status = 'issued';
  if v_existing.id is not null then
    return jsonb_build_object('invoice_id', v_existing.id, 'number', v_existing.number, 'label', v_existing.label, 'existing', true);
  end if;
  if v_order.status = 'cancelled'
     or not exists (select 1 from public.order_items where order_id = p_order and prep_status <> 'cancelled') then
    perform app_private.fail('resto.invalid_order');
  end if;
  if length(btrim(coalesce(p_customer_name, ''))) = 0 then perform app_private.fail('resto.customer_name_required'); end if;
  if p_email is not null and btrim(p_email) <> '' and btrim(p_email) !~ '^[^@\s]+@[^@\s]+\.[^@\s]+$' then
    perform app_private.fail('resto.invalid_email');
  end if;
  select * into v_branch from public.branches where id = v_order.branch_id;
  v_number := app_private.next_counter(v_order.branch_id, 'invoice');
  insert into public.customer_invoices (
    organization_id, branch_id, order_id, number, label, issued_by, customer_name, customer_company, customer_tax_id,
    customer_address, customer_email, currency, prices_include_tax, tax_rate, subtotal_minor, tax_minor, total_minor,
    paid_minor, discount_minor, delivery_fee_minor, lines, adjustments, payments)
  values (
    v_order.organization_id, v_order.branch_id, p_order, v_number, v_branch.invoice_prefix || v_number, auth.uid(),
    btrim(p_customer_name), nullif(btrim(p_company), ''), nullif(btrim(p_tax_id), ''), nullif(btrim(p_address), ''),
    nullif(btrim(p_email), ''), v_order.currency, v_order.prices_include_tax, v_order.tax_rate, v_order.subtotal_minor,
    v_order.tax_minor, v_order.total_minor, v_order.paid_minor, v_order.discount_minor, v_order.delivery_fee_minor,
    coalesce((select jsonb_agg(jsonb_build_object(
                'name', i.item_name, 'variant', i.variant_name, 'quantity', i.quantity, 'unit', i.unit_price_minor,
                'total', i.line_total_minor,
                'options', coalesce((select jsonb_agg(m.modifier_name order by m.modifier_name)
                                       from public.order_item_modifiers m where m.order_item_id = i.id), '[]'::jsonb))
                order by i.added_at)
                from public.order_items i where i.order_id = p_order and i.prep_status <> 'cancelled'), '[]'::jsonb),
    coalesce((select jsonb_agg(jsonb_build_object('label', a.label, 'amount', a.applied_minor) order by a.created_at)
                from public.order_adjustments a where a.order_id = p_order and a.applied_minor > 0), '[]'::jsonb),
    coalesce((select jsonb_agg(jsonb_build_object('method', coalesce(pm.name, p.method), 'amount', p.amount_minor,
                                                  'reference', p.reference, 'at', p.created_at) order by p.created_at)
                from public.payments p left join public.payment_methods pm on pm.id = p.payment_method_id
               where p.order_id = p_order and p.status = 'confirmed'), '[]'::jsonb))
  returning * into v_inv;
  return jsonb_build_object('invoice_id', v_inv.id, 'number', v_inv.number, 'label', v_inv.label, 'existing', false);
end $$;

-- Annulation (cash.close) avec motif : la facture reste numérotée, la commande peut être refacturée.
create or replace function public.cancel_invoice(p_invoice uuid, p_reason text)
returns void language plpgsql security definer set search_path = '' as $$
declare v public.customer_invoices;
begin
  select * into v from public.customer_invoices where id = p_invoice for update;
  if v.id is null then raise exception 'resto.forbidden' using errcode = '42501'; end if;
  perform app_private.assert_branch_perm(v.branch_id, 'cash.close');
  if v.status <> 'issued' then perform app_private.fail('resto.invalid_status'); end if;
  if length(btrim(coalesce(p_reason, ''))) < 3 then perform app_private.fail('resto.reason_required'); end if;
  update public.customer_invoices set status = 'cancelled', cancelled_at = now(), cancelled_by = auth.uid(),
         cancel_reason = btrim(p_reason)
   where id = p_invoice;
end $$;

revoke all on function public.issue_invoice(uuid, text, text, text, text, text), public.cancel_invoice(uuid, text) from public, anon;
grant execute on function public.issue_invoice(uuid, text, text, text, text, text), public.cancel_invoice(uuid, text) to authenticated;

revoke all on all functions in schema app_private from public, anon, authenticated;
grant execute on function app_private.member_org_ids(), app_private.member_branch_ids(),
  app_private.org_ids_with(text), app_private.branch_ids_with(text),
  app_private.full_access_org_ids(), app_private.assigned_branch_ids(),
  app_private.org_ids_with_any_branch(text) to authenticated;
