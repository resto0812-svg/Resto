-- =============================================================================
-- Resto — 006_caisse
-- Caisses, sessions de caisse (fond initial, comptage, écart, validation),
-- paiements enregistrés (espèces, carte, Mobile Money, virement, autre),
-- rendu de monnaie, annulations et remboursements tracés, entrées / sorties
-- d'argent, clôture des commandes payées, rapport de session et du jour.
-- À coller APRÈS 005, puis supabase/tests/006_caisse_tests.sql.
--
-- Règles :
--   - un paiement électronique n'est jamais compté comme des espèces ;
--   - les paiements sont « enregistrés manuellement » (source = manual) : le
--     prélèvement automatique par un prestataire viendra avec les connecteurs ;
--   - on n'encaisse jamais plus que le reste dû (la monnaie rendue est notée) ;
--   - aucun paiement ni mouvement n'est supprimé : annulation ou
--     remboursement avec motif (permission payments.refund) ;
--   - une commande payée ne peut plus être annulée ;
--   - le comptage de fin de service fige l'attendu, le compté et l'écart ;
--     la validation (cash.close) clôt la session.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Caisses (une « Caisse 1 » est créée pour chaque établissement)
-- -----------------------------------------------------------------------------
create table public.cash_registers (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations (id) on delete restrict,
  branch_id uuid not null,
  name text not null check (length(btrim(name)) between 1 and 60),
  active boolean not null default true,
  created_at timestamptz not null default now(),
  unique (organization_id, id),
  unique (organization_id, branch_id, id),
  unique (branch_id, name),
  foreign key (organization_id, branch_id) references public.branches (organization_id, id) on delete restrict
);

insert into public.cash_registers (organization_id, branch_id, name)
select b.organization_id, b.id, 'Caisse 1' from public.branches b
on conflict (branch_id, name) do nothing;

create or replace function app_private.on_branch_created()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  insert into public.cash_registers (organization_id, branch_id, name)
  values (new.organization_id, new.id, 'Caisse 1') on conflict (branch_id, name) do nothing;
  return null;
end $$;
create trigger branches_default_register after insert on public.branches
  for each row execute function app_private.on_branch_created();

-- -----------------------------------------------------------------------------
-- Sessions de caisse
-- -----------------------------------------------------------------------------
create table public.cash_sessions (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null,
  branch_id uuid not null,
  register_id uuid not null,
  currency char(3) not null references public.ref_currencies (code),
  status text not null default 'open' check (status in ('open', 'counted', 'closed')),
  opening_float_minor bigint not null check (opening_float_minor between 0 and 9007199254740991),
  opened_by uuid references auth.users (id) on delete set null,
  opened_at timestamptz not null default now(),
  expected_cash_minor bigint,
  counted_cash_minor bigint check (counted_cash_minor between 0 and 9007199254740991),
  difference_minor bigint,
  count_note text check (length(count_note) <= 500),
  counted_by uuid references auth.users (id) on delete set null,
  counted_at timestamptz,
  validated_by uuid references auth.users (id) on delete set null,
  validated_at timestamptz,
  validation_note text check (length(validation_note) <= 500),
  unique (organization_id, id),
  check (status = 'open' or (counted_at is not null and counted_cash_minor is not null and expected_cash_minor is not null)),
  check (status <> 'closed' or validated_at is not null),
  foreign key (organization_id, branch_id, register_id)
    references public.cash_registers (organization_id, branch_id, id) on delete restrict
);
create unique index cash_sessions_one_open on public.cash_sessions (register_id) where status = 'open';
create index cash_sessions_branch_idx on public.cash_sessions (branch_id, opened_at desc);

-- -----------------------------------------------------------------------------
-- Paiements, remboursements, mouvements d'espèces
-- -----------------------------------------------------------------------------
alter table public.orders add column if not exists paid_minor bigint not null default 0 check (paid_minor >= 0);

create table public.payments (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null,
  branch_id uuid not null,
  order_id uuid not null,
  session_id uuid not null,
  method text not null check (method in ('cash', 'card', 'mobile_money', 'transfer', 'other')),
  source text not null default 'manual' check (source in ('manual', 'provider')),
  currency char(3) not null references public.ref_currencies (code),
  amount_minor bigint not null check (amount_minor between 1 and 9007199254740991),
  tendered_minor bigint check (tendered_minor is null or tendered_minor >= amount_minor),
  change_minor bigint generated always as (coalesce(tendered_minor, amount_minor) - amount_minor) stored,
  reference text check (length(reference) <= 120),
  status text not null default 'confirmed' check (status in ('confirmed', 'voided')),
  created_by uuid references auth.users (id) on delete set null,
  created_at timestamptz not null default now(),
  voided_by uuid references auth.users (id) on delete set null,
  voided_at timestamptz,
  void_reason text check (length(void_reason) <= 500),
  unique (organization_id, id),
  check ((status = 'voided') = (voided_at is not null)),
  check (method = 'cash' or tendered_minor is null),
  foreign key (organization_id, order_id) references public.orders (organization_id, id) on delete restrict,
  foreign key (organization_id, session_id) references public.cash_sessions (organization_id, id) on delete restrict
);
create index payments_order_idx on public.payments (order_id);
create index payments_session_idx on public.payments (session_id);
create index payments_branch_date_idx on public.payments (branch_id, created_at);

create table public.refunds (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null,
  branch_id uuid not null,
  order_id uuid not null,
  payment_id uuid not null,
  session_id uuid not null,
  method text not null check (method in ('cash', 'card', 'mobile_money', 'transfer', 'other')),
  currency char(3) not null references public.ref_currencies (code),
  amount_minor bigint not null check (amount_minor between 1 and 9007199254740991),
  reason text not null check (length(btrim(reason)) between 3 and 500),
  created_by uuid references auth.users (id) on delete set null,
  created_at timestamptz not null default now(),
  foreign key (organization_id, order_id) references public.orders (organization_id, id) on delete restrict,
  foreign key (organization_id, payment_id) references public.payments (organization_id, id) on delete restrict,
  foreign key (organization_id, session_id) references public.cash_sessions (organization_id, id) on delete restrict
);
create index refunds_session_idx on public.refunds (session_id);

create table public.cash_movements (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null,
  branch_id uuid not null,
  session_id uuid not null,
  kind text not null check (kind in ('in', 'out')),
  amount_minor bigint not null check (amount_minor between 1 and 9007199254740991),
  reason text not null check (length(btrim(reason)) between 3 and 300),
  created_by uuid references auth.users (id) on delete set null,
  created_at timestamptz not null default now(),
  foreign key (organization_id, session_id) references public.cash_sessions (organization_id, id) on delete restrict
);
create index cash_movements_session_idx on public.cash_movements (session_id);

-- Nouveaux évènements de commande
alter table public.order_events drop constraint if exists order_events_event_check;
alter table public.order_events add constraint order_events_event_check check (event in ('opened', 'item_added',
  'item_updated', 'item_removed', 'sent', 'item_cancelled', 'cancelled', 'closed', 'prep_status', 'payment',
  'payment_voided', 'refund'));

do $$
declare t text;
begin
  foreach t in array array['cash_registers', 'cash_sessions', 'payments', 'refunds', 'cash_movements'] loop
    execute format('create trigger %I after insert or update or delete on public.%I
      for each row execute function app_private.audit_row()', t || '_audit', t);
    execute format('alter table public.%I enable row level security', t);
    execute format('revoke all on public.%I from anon, authenticated', t);
    execute format('grant select on public.%I to authenticated', t);
  end loop;
  foreach t in array array['cash_sessions', 'payments', 'refunds', 'cash_movements'] loop
    execute format('create policy %I on public.%I for select to authenticated
      using (branch_id in (select app_private.branch_ids_with(''cash.operate''))
          or branch_id in (select app_private.branch_ids_with(''finance.read'')))', t || '_read', t);
  end loop;
end $$;

-- Caisses : visibles par les membres de l'établissement, gérées par branches.manage.
grant insert (id, organization_id, branch_id, name, active), update (name, active) on public.cash_registers to authenticated;
create policy cash_registers_read on public.cash_registers for select to authenticated
  using (branch_id in (select app_private.member_branch_ids()));
create policy cash_registers_insert on public.cash_registers for insert to authenticated
  with check (branch_id in (select app_private.branch_ids_with('branches.manage')));
create policy cash_registers_update on public.cash_registers for update to authenticated
  using (branch_id in (select app_private.branch_ids_with('branches.manage')))
  with check (branch_id in (select app_private.branch_ids_with('branches.manage')));

-- -----------------------------------------------------------------------------
-- Fonctions internes
-- -----------------------------------------------------------------------------

-- Montant encaissé net (paiements confirmés − remboursements) ; mis à jour sur la commande.
create or replace function app_private.recompute_paid(p_order uuid)
returns bigint language plpgsql volatile security definer set search_path = '' as $$
declare v_paid bigint;
begin
  select coalesce((select sum(amount_minor) from public.payments where order_id = p_order and status = 'confirmed'), 0)
       - coalesce((select sum(amount_minor) from public.refunds where order_id = p_order), 0)
    into v_paid;
  update public.orders set paid_minor = v_paid, version = version + 1 where id = p_order;
  return v_paid;
end $$;

-- Session ouverte de l'établissement, verrouillée ; sinon erreur.
create or replace function app_private.lock_open_session(p_session uuid, p_branch uuid)
returns public.cash_sessions language plpgsql volatile security definer set search_path = '' as $$
declare v public.cash_sessions;
begin
  select * into v from public.cash_sessions where id = p_session for update;
  if v.id is null or v.branch_id is distinct from p_branch then perform app_private.fail('resto.no_open_session'); end if;
  if v.status <> 'open' then perform app_private.fail('resto.session_not_open'); end if;
  return v;
end $$;

-- Espèces attendues dans le tiroir.
create or replace function app_private.expected_cash(p_session uuid)
returns bigint language sql stable security definer set search_path = '' as $$
  select s.opening_float_minor
       + coalesce((select sum(amount_minor) from public.payments
                    where session_id = s.id and method = 'cash' and status = 'confirmed'), 0)
       - coalesce((select sum(amount_minor) from public.refunds where session_id = s.id and method = 'cash'), 0)
       + coalesce((select sum(amount_minor) from public.cash_movements where session_id = s.id and kind = 'in'), 0)
       - coalesce((select sum(amount_minor) from public.cash_movements where session_id = s.id and kind = 'out'), 0)
    from public.cash_sessions s where s.id = p_session
$$;

-- Clôture la commande si tout est payé et que rien n'attend d'être envoyé.
create or replace function app_private.try_close_order(p_order uuid)
returns boolean language plpgsql volatile security definer set search_path = '' as $$
declare v public.orders;
begin
  select * into v from public.orders where id = p_order;
  if v.status <> 'open' or v.paid_minor < v.total_minor
     or not exists (select 1 from public.order_items where order_id = p_order and prep_status <> 'cancelled')
     or exists (select 1 from public.order_items where order_id = p_order and prep_status = 'pending') then
    return false;
  end if;
  update public.orders set status = 'closed', closed_at = now(), version = version + 1 where id = p_order;
  perform app_private.log_order(v, 'closed', null, jsonb_build_object('total', v.total_minor));
  return true;
end $$;

-- -----------------------------------------------------------------------------
-- Commandes : annulation impossible une fois payée (remplace les versions de 005)
-- -----------------------------------------------------------------------------
create or replace function public.cancel_order_item(p_item uuid, p_reason text)
returns void language plpgsql security definer set search_path = '' as $$
declare
  v_line public.order_items;
  v_order public.orders;
begin
  select * into v_line from public.order_items where id = p_item;
  v_order := app_private.lock_open_order(v_line.order_id, 'orders.void');
  if v_line.prep_status in ('pending', 'cancelled') then perform app_private.fail('resto.invalid_order'); end if;
  if length(btrim(coalesce(p_reason, ''))) < 3 then perform app_private.fail('resto.reason_required'); end if;
  update public.order_items set prep_status = 'cancelled', cancelled_at = now(), cancelled_by = auth.uid(),
         cancel_reason = btrim(p_reason) where id = p_item;
  perform app_private.recompute_order(v_order.id);
  if (select paid_minor > total_minor from public.orders where id = v_order.id) then
    perform app_private.fail('resto.order_has_payments');
  end if;
  perform app_private.log_order(v_order, 'item_cancelled', p_item,
    jsonb_build_object('name', v_line.item_name, 'reason', btrim(p_reason)));
end $$;

create or replace function public.cancel_order(p_order uuid, p_reason text default null)
returns void language plpgsql security definer set search_path = '' as $$
declare
  v_order public.orders;
  v_sent boolean;
begin
  v_order := app_private.lock_open_order(p_order, 'orders.write');
  if v_order.paid_minor > 0 then perform app_private.fail('resto.order_has_payments'); end if;
  v_sent := exists (select 1 from public.order_items where order_id = p_order and prep_status not in ('pending', 'cancelled'));
  if v_sent then
    perform app_private.assert_branch_perm(v_order.branch_id, 'orders.void');
    if length(btrim(coalesce(p_reason, ''))) < 3 then perform app_private.fail('resto.reason_required'); end if;
  end if;
  delete from public.order_items where order_id = p_order and prep_status = 'pending';
  update public.order_items set prep_status = 'cancelled', cancelled_at = now(), cancelled_by = auth.uid(),
         cancel_reason = coalesce(nullif(btrim(p_reason), ''), 'commande annulée')
   where order_id = p_order and prep_status <> 'cancelled';
  perform app_private.recompute_order(p_order);
  update public.orders set status = 'cancelled', cancelled_at = now(), cancelled_by = auth.uid(),
         cancel_reason = nullif(btrim(p_reason), '') where id = p_order;
  perform app_private.log_order(v_order, 'cancelled', null, jsonb_build_object('reason', nullif(btrim(p_reason), '')));
end $$;

-- -----------------------------------------------------------------------------
-- RPC : caisse
-- -----------------------------------------------------------------------------
create or replace function public.open_cash_session(p_register uuid, p_float bigint, p_client_id uuid default null)
returns uuid language plpgsql security definer set search_path = '' as $$
declare
  v_reg public.cash_registers;
  v_id uuid;
begin
  select * into v_reg from public.cash_registers where id = p_register;
  perform app_private.assert_branch_perm(v_reg.branch_id, 'cash.operate');
  if p_client_id is not null and exists (select 1 from public.cash_sessions where id = p_client_id) then
    return p_client_id;
  end if;
  if not v_reg.active then perform app_private.fail('resto.register_inactive'); end if;
  if coalesce(p_float, -1) < 0 then perform app_private.fail('resto.invalid_amount'); end if;
  perform pg_advisory_xact_lock(hashtext('resto.register.' || p_register::text));
  if exists (select 1 from public.cash_sessions where register_id = p_register and status = 'open') then
    perform app_private.fail('resto.session_already_open');
  end if;
  insert into public.cash_sessions (id, organization_id, branch_id, register_id, currency, opening_float_minor, opened_by)
  select coalesce(p_client_id, gen_random_uuid()), v_reg.organization_id, v_reg.branch_id, v_reg.id, b.currency,
         p_float, auth.uid()
    from public.branches b where b.id = v_reg.branch_id
  returning id into v_id;
  return v_id;
end $$;

create or replace function public.add_cash_movement(
  p_session uuid, p_kind text, p_amount bigint, p_reason text, p_client_id uuid default null)
returns uuid language plpgsql security definer set search_path = '' as $$
declare
  v_branch uuid;
  v_session public.cash_sessions;
  v_id uuid;
begin
  select branch_id into v_branch from public.cash_sessions where id = p_session;
  perform app_private.assert_branch_perm(v_branch, 'cash.operate');
  if p_client_id is not null and exists (select 1 from public.cash_movements where id = p_client_id) then
    return p_client_id;
  end if;
  v_session := app_private.lock_open_session(p_session, v_branch);
  if coalesce(p_kind, '') not in ('in', 'out') or coalesce(p_amount, 0) <= 0 then
    perform app_private.fail('resto.invalid_amount');
  end if;
  if length(btrim(coalesce(p_reason, ''))) < 3 then perform app_private.fail('resto.reason_required'); end if;
  if p_kind = 'out' and p_amount > app_private.expected_cash(p_session) then
    perform app_private.fail('resto.not_enough_cash');
  end if;
  insert into public.cash_movements (id, organization_id, branch_id, session_id, kind, amount_minor, reason, created_by)
  values (coalesce(p_client_id, gen_random_uuid()), v_session.organization_id, v_branch, p_session, p_kind, p_amount,
          btrim(p_reason), auth.uid())
  returning id into v_id;
  return v_id;
end $$;

-- Encaisse tout ou partie du reste dû. Espèces : p_tendered = somme remise
-- (la monnaie rendue est calculée). Renvoie {payment_id, change, due, closed}.
create or replace function public.record_payment(
  p_order uuid, p_session uuid, p_method text, p_amount bigint, p_tendered bigint default null,
  p_reference text default null, p_client_id uuid default null)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare
  v_order public.orders;
  v_session public.cash_sessions;
  v_payment public.payments;
  v_due bigint;
  v_closed boolean;
begin
  if p_client_id is not null then
    select * into v_payment from public.payments where id = p_client_id;
    if v_payment.id is not null then
      perform app_private.assert_branch_perm(v_payment.branch_id, 'cash.operate');
      return jsonb_build_object('payment_id', v_payment.id, 'change', v_payment.change_minor,
        'due', (select total_minor - paid_minor from public.orders where id = v_payment.order_id),
        'closed', (select status = 'closed' from public.orders where id = v_payment.order_id));
    end if;
  end if;
  v_order := app_private.lock_open_order(p_order, 'cash.operate');
  v_session := app_private.lock_open_session(p_session, v_order.branch_id);
  if v_session.currency <> v_order.currency then perform app_private.fail('resto.invalid_amount'); end if;
  if coalesce(p_method, '') not in ('cash', 'card', 'mobile_money', 'transfer', 'other') then
    perform app_private.fail('resto.invalid_payment');
  end if;
  v_due := v_order.total_minor - v_order.paid_minor;
  if coalesce(p_amount, 0) <= 0 or p_amount > v_due then perform app_private.fail('resto.overpayment'); end if;
  if p_method <> 'cash' and p_tendered is not null then perform app_private.fail('resto.invalid_payment'); end if;
  if p_tendered is not null and p_tendered < p_amount then perform app_private.fail('resto.invalid_amount'); end if;

  insert into public.payments (id, organization_id, branch_id, order_id, session_id, method, currency, amount_minor,
                               tendered_minor, reference, created_by)
  values (coalesce(p_client_id, gen_random_uuid()), v_order.organization_id, v_order.branch_id, p_order, p_session,
          p_method, v_order.currency, p_amount, p_tendered, nullif(btrim(p_reference), ''), auth.uid())
  returning * into v_payment;
  perform app_private.recompute_paid(p_order);
  perform app_private.log_order(v_order, 'payment', null,
    jsonb_build_object('method', p_method, 'amount', p_amount, 'payment_id', v_payment.id));
  v_closed := app_private.try_close_order(p_order);
  return jsonb_build_object('payment_id', v_payment.id, 'change', v_payment.change_minor,
    'due', v_due - p_amount, 'closed', v_closed);
end $$;

-- Clôture manuelle (par exemple commande offerte, total 0) : tout doit être payé.
create or replace function public.close_order(p_order uuid)
returns void language plpgsql security definer set search_path = '' as $$
declare v_order public.orders;
begin
  v_order := app_private.lock_open_order(p_order, 'orders.write');
  if exists (select 1 from public.order_items where order_id = p_order and prep_status = 'pending') then
    perform app_private.fail('resto.pending_lines');
  end if;
  if v_order.paid_minor < v_order.total_minor then perform app_private.fail('resto.not_fully_paid'); end if;
  update public.orders set status = 'closed', closed_at = now(), version = version + 1 where id = p_order;
  perform app_private.log_order(v_order, 'closed', null, jsonb_build_object('total', v_order.total_minor));
end $$;

-- Paiement saisi par erreur : annulé (jamais supprimé) tant que la commande
-- et la session sont ouvertes. Permission payments.refund, motif obligatoire.
create or replace function public.void_payment(p_payment uuid, p_reason text)
returns void language plpgsql security definer set search_path = '' as $$
declare
  v_pay public.payments;
  v_order public.orders;
begin
  select * into v_pay from public.payments where id = p_payment;
  v_order := app_private.lock_open_order(v_pay.order_id, 'payments.refund');
  perform app_private.lock_open_session(v_pay.session_id, v_order.branch_id);
  if v_pay.status <> 'confirmed' then perform app_private.fail('resto.invalid_payment'); end if;
  if length(btrim(coalesce(p_reason, ''))) < 3 then perform app_private.fail('resto.reason_required'); end if;
  if exists (select 1 from public.refunds where payment_id = p_payment) then perform app_private.fail('resto.invalid_payment'); end if;
  update public.payments set status = 'voided', voided_at = now(), voided_by = auth.uid(), void_reason = btrim(p_reason)
   where id = p_payment;
  perform app_private.recompute_paid(v_order.id);
  perform app_private.log_order(v_order, 'payment_voided', null,
    jsonb_build_object('payment_id', p_payment, 'reason', btrim(p_reason)));
end $$;

-- Remboursement (commande ouverte ou déjà clôturée), par le même moyen que le
-- paiement, dans une session ouverte. Permission payments.refund.
create or replace function public.refund_payment(
  p_payment uuid, p_session uuid, p_amount bigint, p_reason text, p_client_id uuid default null)
returns uuid language plpgsql security definer set search_path = '' as $$
declare
  v_pay public.payments;
  v_order public.orders;
  v_refunded bigint;
  v_id uuid;
begin
  select * into v_pay from public.payments where id = p_payment;
  perform app_private.assert_branch_perm(v_pay.branch_id, 'payments.refund');
  if p_client_id is not null and exists (select 1 from public.refunds where id = p_client_id) then
    return p_client_id;
  end if;
  select * into v_order from public.orders where id = v_pay.order_id for update;
  perform app_private.lock_open_session(p_session, v_pay.branch_id);
  if v_pay.status <> 'confirmed' then perform app_private.fail('resto.invalid_payment'); end if;
  if length(btrim(coalesce(p_reason, ''))) < 3 then perform app_private.fail('resto.reason_required'); end if;
  select coalesce(sum(amount_minor), 0) into v_refunded from public.refunds where payment_id = p_payment;
  if coalesce(p_amount, 0) <= 0 or p_amount > v_pay.amount_minor - v_refunded then
    perform app_private.fail('resto.invalid_amount');
  end if;
  if v_pay.method = 'cash' and p_amount > app_private.expected_cash(p_session) then
    perform app_private.fail('resto.not_enough_cash');
  end if;
  insert into public.refunds (id, organization_id, branch_id, order_id, payment_id, session_id, method, currency,
                              amount_minor, reason, created_by)
  values (coalesce(p_client_id, gen_random_uuid()), v_pay.organization_id, v_pay.branch_id, v_pay.order_id, p_payment,
          p_session, v_pay.method, v_pay.currency, p_amount, btrim(p_reason), auth.uid())
  returning id into v_id;
  perform app_private.recompute_paid(v_order.id);
  perform app_private.log_order(v_order, 'refund', null,
    jsonb_build_object('payment_id', p_payment, 'amount', p_amount, 'reason', btrim(p_reason)));
  return v_id;
end $$;

-- Fin de service : saisie des espèces comptées ; attendu et écart figés.
create or replace function public.count_cash_session(p_session uuid, p_counted bigint, p_note text default null)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare
  v_branch uuid;
  v_expected bigint;
begin
  select branch_id into v_branch from public.cash_sessions where id = p_session;
  perform app_private.assert_branch_perm(v_branch, 'cash.operate');
  perform app_private.lock_open_session(p_session, v_branch);
  if coalesce(p_counted, -1) < 0 then perform app_private.fail('resto.invalid_amount'); end if;
  v_expected := app_private.expected_cash(p_session);
  update public.cash_sessions set status = 'counted', expected_cash_minor = v_expected, counted_cash_minor = p_counted,
         difference_minor = p_counted - v_expected, count_note = nullif(btrim(p_note), ''),
         counted_by = auth.uid(), counted_at = now()
   where id = p_session;
  return jsonb_build_object('expected', v_expected, 'counted', p_counted, 'difference', p_counted - v_expected);
end $$;

-- Validation par un responsable (cash.close) : la session est close.
-- Un écart non nul exige un commentaire.
create or replace function public.validate_cash_session(p_session uuid, p_note text default null)
returns void language plpgsql security definer set search_path = '' as $$
declare v public.cash_sessions;
begin
  select * into v from public.cash_sessions where id = p_session for update;
  perform app_private.assert_branch_perm(v.branch_id, 'cash.close');
  if v.status <> 'counted' then perform app_private.fail('resto.session_not_counted'); end if;
  if v.difference_minor <> 0 and length(btrim(coalesce(p_note, v.count_note, ''))) < 3 then
    perform app_private.fail('resto.reason_required');
  end if;
  update public.cash_sessions set status = 'closed', validated_by = auth.uid(), validated_at = now(),
         validation_note = nullif(btrim(p_note), '')
   where id = p_session;
end $$;

-- Résumé d'une session : espèces attendues et totaux par moyen de paiement.
create or replace function public.cash_session_summary(p_session uuid)
returns jsonb language plpgsql stable security definer set search_path = '' as $$
declare v public.cash_sessions;
begin
  select * into v from public.cash_sessions where id = p_session;
  if v.id is null or not (
       exists (select 1 from app_private.branch_ids_with('cash.operate') x where x = v.branch_id)
    or exists (select 1 from app_private.branch_ids_with('finance.read') x where x = v.branch_id)) then
    raise exception 'resto.forbidden' using errcode = '42501';
  end if;
  return jsonb_build_object(
    'opening_float', v.opening_float_minor,
    'expected_cash', app_private.expected_cash(p_session),
    'movements_in', coalesce((select sum(amount_minor) from public.cash_movements where session_id = p_session and kind = 'in'), 0),
    'movements_out', coalesce((select sum(amount_minor) from public.cash_movements where session_id = p_session and kind = 'out'), 0),
    'payments_count', (select count(*) from public.payments where session_id = p_session and status = 'confirmed'),
    'by_method', coalesce((
      select jsonb_object_agg(method, total) from (
        select p.method, sum(p.amount_minor)
             - coalesce((select sum(r.amount_minor) from public.refunds r where r.session_id = p_session and r.method = p.method), 0) as total
          from public.payments p where p.session_id = p_session and p.status = 'confirmed'
         group by p.method) m), '{}'::jsonb),
    'refunds', coalesce((select sum(amount_minor) from public.refunds where session_id = p_session), 0));
end $$;

-- Rapport du jour d'un établissement (journée locale de l'établissement).
-- Chiffre d'affaires = commandes clôturées ; encaissements = paiements nets.
create or replace function public.daily_summary(p_branch uuid, p_date date)
returns jsonb language plpgsql stable security definer set search_path = '' as $$
declare
  v_tz text;
begin
  if not (exists (select 1 from app_private.branch_ids_with('finance.read') x where x = p_branch)
       or exists (select 1 from app_private.branch_ids_with('cash.close') x where x = p_branch)) then
    raise exception 'resto.forbidden' using errcode = '42501';
  end if;
  select timezone into v_tz from public.branches where id = p_branch;
  return (
    with o as (select * from public.orders where branch_id = p_branch and business_date = p_date),
         p as (select * from public.payments
                where branch_id = p_branch and status = 'confirmed' and (created_at at time zone v_tz)::date = p_date),
         r as (select * from public.refunds where branch_id = p_branch and (created_at at time zone v_tz)::date = p_date)
    select jsonb_build_object(
      'orders_closed', (select count(*) from o where status = 'closed'),
      'orders_open', (select count(*) from o where status = 'open'),
      'orders_cancelled', (select count(*) from o where status = 'cancelled'),
      'sales_total', coalesce((select sum(total_minor) from o where status = 'closed'), 0),
      'sales_tax', coalesce((select sum(tax_minor) from o where status = 'closed'), 0),
      'average_ticket', coalesce((select round(avg(total_minor)) from o where status = 'closed'), 0),
      'lines_cancelled', (select count(*) from public.order_items i join o on o.id = i.order_id
                           where i.prep_status = 'cancelled' and i.sent_at is not null),
      'payments_by_method', coalesce((select jsonb_object_agg(method, total) from (
          select method, sum(amount_minor) as total from p group by method) x), '{}'::jsonb),
      'refunds_total', coalesce((select sum(amount_minor) from r), 0),
      'top_items', coalesce((select jsonb_agg(jsonb_build_object('name', name, 'quantity', qty, 'total', total)
                                              order by qty desc, name)
          from (select i.item_name as name, sum(i.quantity) as qty, sum(i.line_total_minor) as total
                  from public.order_items i join o on o.id = i.order_id
                 where o.status = 'closed' and i.prep_status <> 'cancelled'
                 group by i.item_name order by sum(i.quantity) desc limit 10) t), '[]'::jsonb)));
end $$;

revoke all on function public.open_cash_session(uuid, bigint, uuid),
  public.add_cash_movement(uuid, text, bigint, text, uuid),
  public.record_payment(uuid, uuid, text, bigint, bigint, text, uuid), public.close_order(uuid),
  public.void_payment(uuid, text), public.refund_payment(uuid, uuid, bigint, text, uuid),
  public.count_cash_session(uuid, bigint, text), public.validate_cash_session(uuid, text),
  public.cash_session_summary(uuid), public.daily_summary(uuid, date) from public, anon;
grant execute on function public.open_cash_session(uuid, bigint, uuid),
  public.add_cash_movement(uuid, text, bigint, text, uuid),
  public.record_payment(uuid, uuid, text, bigint, bigint, text, uuid), public.close_order(uuid),
  public.void_payment(uuid, text), public.refund_payment(uuid, uuid, bigint, text, uuid),
  public.count_cash_session(uuid, bigint, text), public.validate_cash_session(uuid, text),
  public.cash_session_summary(uuid), public.daily_summary(uuid, date) to authenticated;

revoke all on all functions in schema app_private from public, anon, authenticated;
grant execute on function app_private.member_org_ids(), app_private.member_branch_ids(),
  app_private.org_ids_with(text), app_private.branch_ids_with(text),
  app_private.full_access_org_ids(), app_private.assigned_branch_ids() to authenticated;
