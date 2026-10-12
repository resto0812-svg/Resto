-- =============================================================================
-- Resto — 012_fidelite_promotions
-- Réductions sur commande (promotion, code promo, fidélité, remise manuelle),
-- programme de fidélité par organisation (points gagnés à chaque commande
-- payée d'un client connu, récompense échangeable), historique des points.
-- À coller APRÈS 011, puis supabase/tests/012_fidelite_promotions_tests.sql.
--
-- Une réduction en pourcentage est recalculée quand la commande change ; elle
-- ne peut jamais rendre le total négatif. Aucune réduction ne s'applique à
-- une commande déjà payée au-delà du nouveau total.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Promotions
-- -----------------------------------------------------------------------------
create table public.promotions (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations (id) on delete restrict,
  branch_id uuid,                                   -- null = tous les établissements
  name text not null check (length(btrim(name)) between 1 and 120),
  kind text not null check (kind in ('percent', 'amount')),
  percent numeric(5, 2) check (percent > 0 and percent <= 100),
  amount_minor bigint check (amount_minor > 0),
  code text check (code ~ '^[A-Z0-9_-]{3,30}$'),     -- null = appliquée par l'équipe, sans code
  starts_at timestamptz,
  ends_at timestamptz,
  min_order_minor bigint not null default 0 check (min_order_minor >= 0),
  max_uses integer check (max_uses > 0),
  uses_count integer not null default 0 check (uses_count >= 0),
  per_customer_limit integer check (per_customer_limit > 0),
  active boolean not null default true,
  created_at timestamptz not null default now(),
  unique (organization_id, id),
  unique (organization_id, code),
  check ((kind = 'percent' and percent is not null and amount_minor is null)
      or (kind = 'amount' and amount_minor is not null and percent is null)),
  check (ends_at is null or starts_at is null or ends_at > starts_at),
  foreign key (organization_id, branch_id) references public.branches (organization_id, id) on delete restrict
);

-- -----------------------------------------------------------------------------
-- Programme de fidélité (un par organisation), comptes et mouvements de points
-- -----------------------------------------------------------------------------
create table public.loyalty_programs (
  organization_id uuid primary key references public.organizations (id) on delete restrict,
  active boolean not null default false,
  amount_per_point_minor bigint not null default 1000 check (amount_per_point_minor > 0),
  reward_points integer not null default 100 check (reward_points > 0),
  reward_minor bigint not null default 1000 check (reward_minor > 0),
  updated_at timestamptz not null default now()
);
create table public.loyalty_accounts (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations (id) on delete restrict,
  user_id uuid not null references auth.users (id) on delete cascade,
  points integer not null default 0 check (points >= 0),
  created_at timestamptz not null default now(),
  unique (organization_id, user_id),
  unique (organization_id, id)
);
create table public.loyalty_transactions (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null,
  account_id uuid not null,
  order_id uuid,
  kind text not null check (kind in ('earn', 'redeem', 'adjust')),
  points integer not null check (points <> 0),
  reason text check (length(reason) <= 300),
  created_by uuid,
  created_at timestamptz not null default now(),
  foreign key (organization_id, account_id) references public.loyalty_accounts (organization_id, id) on delete cascade,
  foreign key (organization_id, order_id) references public.orders (organization_id, id) on delete restrict
);
create unique index loyalty_earn_once on public.loyalty_transactions (order_id) where kind = 'earn';
create unique index loyalty_redeem_once on public.loyalty_transactions (order_id) where kind = 'redeem';
-- Jamais modifiés ; supprimés seulement avec le compte du client (droit à l'effacement).
create trigger loyalty_transactions_immutable before update on public.loyalty_transactions
  for each row execute function app_private.audit_immutable();

-- -----------------------------------------------------------------------------
-- Réductions appliquées à une commande
-- -----------------------------------------------------------------------------
create table public.order_adjustments (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null,
  branch_id uuid not null,
  order_id uuid not null,
  kind text not null check (kind in ('promotion', 'loyalty', 'manual')),
  label text not null check (length(btrim(label)) between 1 and 120),
  percent numeric(5, 2) check (percent > 0 and percent <= 100),
  amount_minor bigint check (amount_minor > 0),
  promotion_id uuid,
  -- Montant effectivement déduit, recalculé avec la commande.
  applied_minor bigint not null default 0 check (applied_minor >= 0),
  reason text check (length(reason) <= 300),
  created_by uuid references auth.users (id) on delete set null,
  created_at timestamptz not null default now(),
  check (num_nonnulls(percent, amount_minor) = 1),
  foreign key (organization_id, order_id) references public.orders (organization_id, id) on delete restrict,
  foreign key (organization_id, promotion_id) references public.promotions (organization_id, id) on delete restrict
);
create index order_adjustments_order_idx on public.order_adjustments (order_id);
create unique index order_adjustments_promo_once on public.order_adjustments (order_id, promotion_id) where promotion_id is not null;
alter table public.orders add column if not exists discount_minor bigint not null default 0 check (discount_minor >= 0);

do $$
declare t text;
begin
  foreach t in array array['promotions', 'loyalty_programs', 'loyalty_accounts', 'loyalty_transactions', 'order_adjustments'] loop
    execute format('create trigger %I after insert or update or delete on public.%I
      for each row execute function app_private.audit_row()', t || '_audit', t);
    execute format('alter table public.%I enable row level security', t);
    execute format('revoke all on public.%I from anon, authenticated', t);
    execute format('grant select on public.%I to authenticated', t);
  end loop;
end $$;

-- Promotions et programme : gérés avec customers.manage (sur toute l'organisation).
grant insert (id, organization_id, branch_id, name, kind, percent, amount_minor, code, starts_at, ends_at, min_order_minor,
              max_uses, per_customer_limit, active),
  update (name, percent, amount_minor, starts_at, ends_at, min_order_minor, max_uses, per_customer_limit, active)
  on public.promotions to authenticated;
create policy promotions_read on public.promotions for select to authenticated
  using (organization_id in (select app_private.member_org_ids()));
create policy promotions_insert on public.promotions for insert to authenticated
  with check (organization_id in (select app_private.org_ids_with('customers.manage')));
create policy promotions_update on public.promotions for update to authenticated
  using (organization_id in (select app_private.org_ids_with('customers.manage')))
  with check (organization_id in (select app_private.org_ids_with('customers.manage')));

grant insert (organization_id, active, amount_per_point_minor, reward_points, reward_minor),
  update (active, amount_per_point_minor, reward_points, reward_minor) on public.loyalty_programs to authenticated;
create policy loyalty_programs_read on public.loyalty_programs for select to authenticated
  using (organization_id in (select app_private.member_org_ids()));
create policy loyalty_programs_write on public.loyalty_programs for all to authenticated
  using (organization_id in (select app_private.org_ids_with('customers.manage')))
  with check (organization_id in (select app_private.org_ids_with('customers.manage')));

create policy loyalty_accounts_read on public.loyalty_accounts for select to authenticated
  using (user_id = (select auth.uid()) or organization_id in (select app_private.org_ids_with_any_branch('orders.read')));
create policy loyalty_transactions_read on public.loyalty_transactions for select to authenticated
  using (account_id in (select id from public.loyalty_accounts));
create policy order_adjustments_read on public.order_adjustments for select to authenticated
  using (branch_id in (select app_private.branch_ids_with('orders.read'))
      or order_id in (select id from public.orders where customer_user_id = (select auth.uid())));

-- -----------------------------------------------------------------------------
-- Totaux : lignes + frais de livraison − réductions (jamais négatif)
-- -----------------------------------------------------------------------------
create or replace function app_private.recompute_order(p_order uuid)
returns void language plpgsql volatile security definer set search_path = '' as $$
declare
  v public.orders;
  v_lines bigint;
  v_left bigint;
  v_discount bigint := 0;
  v_sub bigint;
  v_tax bigint;
  a record;
  v_cut bigint;
begin
  select * into v from public.orders where id = p_order;
  select coalesce(sum(line_total_minor), 0) into v_lines
    from public.order_items where order_id = p_order and prep_status <> 'cancelled';
  v_left := v_lines;
  for a in select * from public.order_adjustments where order_id = p_order order by created_at, id loop
    v_cut := least(v_left, coalesce(a.amount_minor, round(v_lines * a.percent / 100)::bigint));
    update public.order_adjustments set applied_minor = v_cut where id = a.id;
    v_left := v_left - v_cut;
    v_discount := v_discount + v_cut;
  end loop;
  v_sub := v_lines - v_discount + v.delivery_fee_minor;
  if v.prices_include_tax then
    v_tax := v_sub - round(v_sub / (1 + v.tax_rate / 100));
    update public.orders set subtotal_minor = v_sub, tax_minor = v_tax, total_minor = v_sub, discount_minor = v_discount,
           version = version + 1 where id = p_order;
  else
    v_tax := round(v_sub * v.tax_rate / 100);
    update public.orders set subtotal_minor = v_sub, tax_minor = v_tax, total_minor = v_sub + v_tax, discount_minor = v_discount,
           version = version + 1 where id = p_order;
  end if;
end $$;

-- Après une réduction : refus si la commande est déjà payée au-delà du total.
create or replace function app_private.assert_not_overpaid(p_order uuid)
returns void language plpgsql stable security definer set search_path = '' as $$
begin
  if (select paid_minor > total_minor from public.orders where id = p_order) then
    perform app_private.fail('resto.order_has_payments');
  end if;
end $$;

-- Promotion applicable à une commande (dates, établissement, minimum, limites).
create or replace function app_private.check_promotion(p_promo public.promotions, p_order public.orders)
returns void language plpgsql stable security definer set search_path = '' as $$
declare v_lines bigint;
begin
  select coalesce(sum(line_total_minor), 0) into v_lines
    from public.order_items where order_id = p_order.id and prep_status <> 'cancelled';
  if p_promo.id is null or not p_promo.active or p_promo.organization_id <> p_order.organization_id
     or (p_promo.branch_id is not null and p_promo.branch_id <> p_order.branch_id)
     or (p_promo.starts_at is not null and now() < p_promo.starts_at)
     or (p_promo.ends_at is not null and now() >= p_promo.ends_at)
     or (p_promo.max_uses is not null and p_promo.uses_count >= p_promo.max_uses) then
    perform app_private.fail('resto.promotion_unavailable');
  end if;
  if v_lines < p_promo.min_order_minor then perform app_private.fail('resto.below_minimum'); end if;
  if p_promo.per_customer_limit is not null and p_order.customer_user_id is not null
     and (select count(*) from public.order_adjustments oa join public.orders o on o.id = oa.order_id
           where oa.promotion_id = p_promo.id and o.customer_user_id = p_order.customer_user_id
             and o.status <> 'cancelled') >= p_promo.per_customer_limit then
    perform app_private.fail('resto.promotion_limit');
  end if;
end $$;

create or replace function app_private.add_promotion(p_promo public.promotions, p_order public.orders)
returns void language plpgsql volatile security definer set search_path = '' as $$
begin
  perform app_private.check_promotion(p_promo, p_order);
  if exists (select 1 from public.order_adjustments where order_id = p_order.id and promotion_id = p_promo.id) then
    perform app_private.fail('resto.promotion_already_applied');
  end if;
  insert into public.order_adjustments (organization_id, branch_id, order_id, kind, label, percent, amount_minor,
                                        promotion_id, created_by)
  values (p_order.organization_id, p_order.branch_id, p_order.id, 'promotion', p_promo.name, p_promo.percent,
          p_promo.amount_minor, p_promo.id, auth.uid());
  update public.promotions set uses_count = uses_count + 1 where id = p_promo.id;
  perform app_private.recompute_order(p_order.id);
  perform app_private.assert_not_overpaid(p_order.id);
end $$;

-- Points gagnés à la clôture d'une commande d'un client connu.
create or replace function app_private.earn_points(p_order uuid)
returns void language plpgsql volatile security definer set search_path = '' as $$
declare
  v_order public.orders;
  v_prog public.loyalty_programs;
  v_points integer;
  v_account uuid;
begin
  select * into v_order from public.orders where id = p_order;
  if v_order.customer_user_id is null then return; end if;
  select * into v_prog from public.loyalty_programs where organization_id = v_order.organization_id and active;
  if v_prog.organization_id is null then return; end if;
  v_points := floor(v_order.total_minor / v_prog.amount_per_point_minor)::int;
  if v_points <= 0 then return; end if;
  insert into public.loyalty_accounts (organization_id, user_id) values (v_order.organization_id, v_order.customer_user_id)
  on conflict (organization_id, user_id) do nothing;
  select id into v_account from public.loyalty_accounts
   where organization_id = v_order.organization_id and user_id = v_order.customer_user_id;
  insert into public.loyalty_transactions (organization_id, account_id, order_id, kind, points)
  values (v_order.organization_id, v_account, p_order, 'earn', v_points)
  on conflict (order_id) where kind = 'earn' do nothing;
  if found then
    update public.loyalty_accounts set points = points + v_points where id = v_account;
  end if;
end $$;

-- À la clôture : consommation théorique des stocks (008) + points de fidélité.
create or replace function app_private.on_order_closed()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  if new.status = 'closed' and old.status is distinct from 'closed' then
    perform app_private.consume_order(new.id);
    perform app_private.earn_points(new.id);
  end if;
  return null;
end $$;

-- -----------------------------------------------------------------------------
-- RPC
-- -----------------------------------------------------------------------------

-- Par l'équipe : promotion choisie (sans code) ou code saisi.
create or replace function public.apply_promotion(p_order uuid, p_promotion uuid default null, p_code text default null)
returns void language plpgsql security definer set search_path = '' as $$
declare
  v_order public.orders;
  v_promo public.promotions;
begin
  v_order := app_private.lock_open_order(p_order, 'orders.write');
  if p_promotion is not null then
    select * into v_promo from public.promotions where id = p_promotion for update;
  else
    select * into v_promo from public.promotions
     where organization_id = v_order.organization_id and code = upper(btrim(coalesce(p_code, ''))) for update;
  end if;
  perform app_private.add_promotion(v_promo, v_order);
end $$;

-- Par le client, sur sa commande en attente : code promo.
create or replace function public.customer_apply_code(p_order uuid, p_code text)
returns void language plpgsql security definer set search_path = '' as $$
declare
  v_order public.orders;
  v_promo public.promotions;
begin
  select * into v_order from public.orders where id = p_order for update;
  if v_order.id is null or v_order.customer_user_id is distinct from auth.uid() then
    raise exception 'resto.forbidden' using errcode = '42501';
  end if;
  if v_order.status <> 'open' or v_order.acceptance <> 'pending' then perform app_private.fail('resto.too_late_to_cancel'); end if;
  select * into v_promo from public.promotions
   where organization_id = v_order.organization_id and code = upper(btrim(coalesce(p_code, ''))) for update;
  if v_promo.id is null then perform app_private.fail('resto.promotion_unavailable'); end if;
  perform app_private.add_promotion(v_promo, v_order);
end $$;

-- Remise manuelle (geste commercial) : orders.void et motif obligatoires.
create or replace function public.apply_manual_discount(p_order uuid, p_percent numeric, p_amount bigint, p_reason text)
returns void language plpgsql security definer set search_path = '' as $$
declare v_order public.orders;
begin
  v_order := app_private.lock_open_order(p_order, 'orders.void');
  if num_nonnulls(p_percent, p_amount) <> 1 or coalesce(p_percent, 1) <= 0 or coalesce(p_percent, 1) > 100
     or coalesce(p_amount, 1) <= 0 then
    perform app_private.fail('resto.invalid_amount');
  end if;
  if length(btrim(coalesce(p_reason, ''))) < 3 then perform app_private.fail('resto.reason_required'); end if;
  insert into public.order_adjustments (organization_id, branch_id, order_id, kind, label, percent, amount_minor, reason, created_by)
  values (v_order.organization_id, v_order.branch_id, p_order, 'manual', left(btrim(p_reason), 120), p_percent, p_amount,
          btrim(p_reason), auth.uid());
  perform app_private.recompute_order(p_order);
  perform app_private.assert_not_overpaid(p_order);
end $$;

-- Retrait d'une réduction (avant paiement complet) ; points rendus si fidélité.
create or replace function public.remove_adjustment(p_adjustment uuid)
returns void language plpgsql security definer set search_path = '' as $$
declare
  v_adj public.order_adjustments;
  v_order public.orders;
  v_tx public.loyalty_transactions;
begin
  select * into v_adj from public.order_adjustments where id = p_adjustment;
  v_order := app_private.lock_open_order(v_adj.order_id, 'orders.void');
  delete from public.order_adjustments where id = p_adjustment;
  if v_adj.promotion_id is not null then
    update public.promotions set uses_count = greatest(uses_count - 1, 0) where id = v_adj.promotion_id;
  end if;
  if v_adj.kind = 'loyalty' then
    select * into v_tx from public.loyalty_transactions where order_id = v_order.id and kind = 'redeem';
    if v_tx.id is not null then
      insert into public.loyalty_transactions (organization_id, account_id, order_id, kind, points, reason, created_by)
      values (v_tx.organization_id, v_tx.account_id, null, 'adjust', -v_tx.points, 'réduction retirée', auth.uid());
      update public.loyalty_accounts set points = points - v_tx.points where id = v_tx.account_id;
    end if;
  end if;
  perform app_private.recompute_order(v_order.id);
end $$;

-- Échange de la récompense de fidélité sur la commande d'un client connu.
create or replace function public.redeem_loyalty(p_order uuid)
returns void language plpgsql security definer set search_path = '' as $$
declare
  v_order public.orders;
  v_prog public.loyalty_programs;
  v_acc public.loyalty_accounts;
begin
  v_order := app_private.lock_open_order(p_order, 'orders.write');
  select * into v_prog from public.loyalty_programs where organization_id = v_order.organization_id and active;
  select * into v_acc from public.loyalty_accounts
   where organization_id = v_order.organization_id and user_id = v_order.customer_user_id for update;
  if v_prog.organization_id is null or v_acc.id is null or v_acc.points < v_prog.reward_points then
    perform app_private.fail('resto.not_enough_points');
  end if;
  if exists (select 1 from public.loyalty_transactions where order_id = p_order and kind = 'redeem') then
    perform app_private.fail('resto.promotion_already_applied');
  end if;
  insert into public.loyalty_transactions (organization_id, account_id, order_id, kind, points, created_by)
  values (v_order.organization_id, v_acc.id, p_order, 'redeem', -v_prog.reward_points, auth.uid());
  update public.loyalty_accounts set points = points - v_prog.reward_points where id = v_acc.id;
  insert into public.order_adjustments (organization_id, branch_id, order_id, kind, label, amount_minor, created_by)
  values (v_order.organization_id, v_order.branch_id, p_order, 'loyalty', 'fidélité', v_prog.reward_minor, auth.uid());
  perform app_private.recompute_order(p_order);
  perform app_private.assert_not_overpaid(p_order);
end $$;

-- Mes points de fidélité (client), par restaurant.
create or replace function public.my_loyalty()
returns table (organization_id uuid, organization_name text, points integer, reward_points integer, reward_minor bigint,
               amount_per_point_minor bigint, currency char(3))
language sql stable security definer set search_path = '' as $$
  select a.organization_id, o.name, a.points, p.reward_points, p.reward_minor, p.amount_per_point_minor, o.default_currency
    from public.loyalty_accounts a
    join public.organizations o on o.id = a.organization_id
    left join public.loyalty_programs p on p.organization_id = a.organization_id and p.active
   where a.user_id = auth.uid()
   order by o.name
$$;

revoke all on function public.apply_promotion(uuid, uuid, text), public.customer_apply_code(uuid, text),
  public.apply_manual_discount(uuid, numeric, bigint, text), public.remove_adjustment(uuid),
  public.redeem_loyalty(uuid), public.my_loyalty() from public, anon;
grant execute on function public.apply_promotion(uuid, uuid, text), public.customer_apply_code(uuid, text),
  public.apply_manual_discount(uuid, numeric, bigint, text), public.remove_adjustment(uuid),
  public.redeem_loyalty(uuid), public.my_loyalty() to authenticated;

revoke all on all functions in schema app_private from public, anon, authenticated;
grant execute on function app_private.member_org_ids(), app_private.member_branch_ids(),
  app_private.org_ids_with(text), app_private.branch_ids_with(text),
  app_private.full_access_org_ids(), app_private.assigned_branch_ids(),
  app_private.org_ids_with_any_branch(text) to authenticated;
