-- =============================================================================
-- Resto — 005_commandes
-- Prise de commande : commandes (sur place, à emporter), lignes avec
-- instantané du nom et du prix, options choisies, historique des évènements.
-- Taxe par établissement (taux et « prix affichés taxes comprises »).
-- À coller APRÈS 004, puis supabase/tests/005_commandes_tests.sql.
--
-- Règles :
--   - toutes les écritures passent par des fonctions (prix et options
--     vérifiés par le serveur, jamais fournis par l'application) ;
--   - une ligne non envoyée en cuisine se modifie ou se retire librement ;
--   - une ligne envoyée ne s'efface jamais : elle s'annule avec un motif
--     (permission orders.void) ;
--   - le prix et le nom sont figés au moment de l'ajout ;
--   - statuts séparés : commande (open / closed / cancelled), préparation
--     par ligne (pending → sent → preparing → ready → served, ou cancelled) ;
--     le paiement viendra avec la caisse.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Taxe de l'établissement (0 tant qu'elle n'est pas configurée)
-- -----------------------------------------------------------------------------
alter table public.branches
  add column if not exists tax_rate numeric(6, 3) not null default 0 check (tax_rate >= 0 and tax_rate < 100),
  add column if not exists prices_include_tax boolean not null default true;
grant insert (tax_rate, prices_include_tax), update (tax_rate, prices_include_tax) on public.branches to authenticated;

alter table public.dining_tables add constraint dining_tables_org_branch_id_key unique (organization_id, branch_id, id);

-- Compteurs par établissement (numéro de commande du jour…), uniquement
-- utilisés par les fonctions du serveur.
create table public.branch_counters (
  branch_id uuid not null references public.branches (id) on delete cascade,
  counter text not null check (length(counter) <= 60),
  value bigint not null default 0,
  primary key (branch_id, counter)
);
alter table public.branch_counters enable row level security;
revoke all on public.branch_counters from anon, authenticated;

-- -----------------------------------------------------------------------------
-- Commandes
-- -----------------------------------------------------------------------------
create table public.orders (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations (id) on delete restrict,
  brand_id uuid not null,
  branch_id uuid not null,
  business_date date not null,
  number integer not null check (number > 0),
  channel text not null default 'dine_in' check (channel in ('dine_in', 'takeaway', 'delivery')),
  source text not null default 'staff' check (source in ('staff', 'qr', 'web', 'app', 'phone', 'partner')),
  table_id uuid,
  guests smallint check (guests between 1 and 200),
  note text check (length(note) <= 500),
  status text not null default 'open' check (status in ('open', 'closed', 'cancelled')),
  currency char(3) not null references public.ref_currencies (code),
  prices_include_tax boolean not null,
  tax_rate numeric(6, 3) not null,
  subtotal_minor bigint not null default 0 check (subtotal_minor >= 0),
  tax_minor bigint not null default 0 check (tax_minor >= 0),
  total_minor bigint not null default 0 check (total_minor >= 0),
  opened_by uuid references auth.users (id) on delete set null,
  opened_at timestamptz not null default now(),
  closed_at timestamptz,
  cancelled_at timestamptz,
  cancelled_by uuid references auth.users (id) on delete set null,
  cancel_reason text check (length(cancel_reason) <= 500),
  version integer not null default 1,
  updated_at timestamptz not null default now(),
  unique (organization_id, id),
  unique (branch_id, business_date, number),
  check ((status = 'cancelled') = (cancelled_at is not null)),
  check (channel = 'dine_in' or table_id is null),
  foreign key (organization_id, brand_id, branch_id) references public.branches (organization_id, brand_id, id) on delete restrict,
  foreign key (organization_id, branch_id, table_id) references public.dining_tables (organization_id, branch_id, id) on delete restrict
);
create index orders_branch_open_idx on public.orders (branch_id, status) where status = 'open';
create index orders_branch_date_idx on public.orders (branch_id, business_date desc);
-- Une seule commande ouverte par table.
create unique index orders_one_open_per_table on public.orders (table_id) where status = 'open' and table_id is not null;

create table public.order_items (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null,
  branch_id uuid not null,
  order_id uuid not null,
  item_id uuid not null,
  variant_id uuid not null,
  item_name text not null,
  variant_name text not null default '',
  quantity integer not null check (quantity between 1 and 999),
  unit_price_minor bigint not null check (unit_price_minor >= 0),
  line_total_minor bigint not null check (line_total_minor >= 0),
  note text check (length(note) <= 300),
  prep_status text not null default 'pending'
    check (prep_status in ('pending', 'sent', 'preparing', 'ready', 'served', 'cancelled')),
  added_by uuid references auth.users (id) on delete set null,
  added_at timestamptz not null default now(),
  sent_at timestamptz,
  cancelled_at timestamptz,
  cancelled_by uuid references auth.users (id) on delete set null,
  cancel_reason text check (length(cancel_reason) <= 500),
  unique (organization_id, id),
  check ((prep_status = 'cancelled') = (cancelled_at is not null)),
  foreign key (organization_id, order_id) references public.orders (organization_id, id) on delete restrict,
  foreign key (organization_id, item_id) references public.menu_items (organization_id, id) on delete restrict,
  foreign key (organization_id, variant_id) references public.item_variants (organization_id, id) on delete restrict
);
create index order_items_order_idx on public.order_items (order_id);
create index order_items_branch_status_idx on public.order_items (branch_id, prep_status);

create table public.order_item_modifiers (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null,
  branch_id uuid not null,
  order_item_id uuid not null,
  modifier_id uuid not null,
  group_name text not null,
  modifier_name text not null,
  price_minor bigint not null check (price_minor >= 0),
  foreign key (organization_id, order_item_id) references public.order_items (organization_id, id) on delete cascade,
  foreign key (organization_id, modifier_id) references public.modifiers (organization_id, id) on delete restrict
);
create index order_item_modifiers_item_idx on public.order_item_modifiers (order_item_id);

-- Historique de la commande (en plus du journal d'audit), lisible par l'équipe.
create table public.order_events (
  id bigint generated always as identity primary key,
  organization_id uuid not null,
  branch_id uuid not null,
  order_id uuid not null,
  order_item_id uuid,
  event text not null check (event in ('opened', 'item_added', 'item_updated', 'item_removed', 'sent',
    'item_cancelled', 'cancelled', 'closed', 'prep_status')),
  detail jsonb not null default '{}'::jsonb,
  actor_id uuid,
  created_at timestamptz not null default now(),
  foreign key (organization_id, order_id) references public.orders (organization_id, id) on delete restrict
);
create index order_events_order_idx on public.order_events (order_id, id);

create trigger orders_touch before update on public.orders
  for each row execute function app_private.touch_updated_at();
create trigger order_events_no_update before update or delete on public.order_events
  for each row execute function app_private.audit_immutable();

do $$
declare t text;
begin
  foreach t in array array['orders', 'order_items', 'order_item_modifiers'] loop
    execute format('create trigger %I after insert or update or delete on public.%I
      for each row execute function app_private.audit_row()', t || '_audit', t);
  end loop;
  foreach t in array array['orders', 'order_items', 'order_item_modifiers', 'order_events'] loop
    execute format('alter table public.%I enable row level security', t);
    execute format('revoke all on public.%I from anon, authenticated', t);
    execute format('grant select on public.%I to authenticated', t);
    execute format('create policy %I on public.%I for select to authenticated
      using (branch_id in (select app_private.branch_ids_with(''orders.read'')))', t || '_read', t);
  end loop;
end $$;

-- -----------------------------------------------------------------------------
-- Fonctions internes
-- -----------------------------------------------------------------------------
create or replace function app_private.assert_branch_perm(p_branch uuid, p_perm text)
returns void language plpgsql stable security definer set search_path = '' as $$
begin
  if p_branch is null or not exists (
    select 1 from app_private.branch_ids_with(p_perm) x where x = p_branch) then
    raise exception 'resto.forbidden' using errcode = '42501';
  end if;
end $$;

create or replace function app_private.next_counter(p_branch uuid, p_counter text)
returns bigint language sql volatile security definer set search_path = '' as $$
  insert into public.branch_counters (branch_id, counter, value) values (p_branch, p_counter, 1)
  on conflict (branch_id, counter) do update set value = public.branch_counters.value + 1
  returning value
$$;

create or replace function app_private.log_order(p_order public.orders, p_event text, p_item uuid, p_detail jsonb)
returns void language sql volatile security definer set search_path = '' as $$
  insert into public.order_events (organization_id, branch_id, order_id, order_item_id, event, detail, actor_id)
  values (p_order.organization_id, p_order.branch_id, p_order.id, p_item, p_event, coalesce(p_detail, '{}'::jsonb), auth.uid())
$$;

-- Totaux de la commande à partir des lignes non annulées.
-- Prix taxes comprises : la taxe est extraite du total ; sinon elle s'ajoute.
create or replace function app_private.recompute_order(p_order uuid)
returns void language plpgsql volatile security definer set search_path = '' as $$
declare
  v public.orders;
  v_sub bigint;
  v_tax bigint;
begin
  select * into v from public.orders where id = p_order;
  select coalesce(sum(line_total_minor), 0) into v_sub
    from public.order_items where order_id = p_order and prep_status <> 'cancelled';
  if v.prices_include_tax then
    v_tax := v_sub - round(v_sub / (1 + v.tax_rate / 100));
    update public.orders set subtotal_minor = v_sub, tax_minor = v_tax, total_minor = v_sub,
           version = version + 1 where id = p_order;
  else
    v_tax := round(v_sub * v.tax_rate / 100);
    update public.orders set subtotal_minor = v_sub, tax_minor = v_tax, total_minor = v_sub + v_tax,
           version = version + 1 where id = p_order;
  end if;
end $$;

-- Commande ouverte, verrouillée, avec contrôle du droit ; sinon erreur.
create or replace function app_private.lock_open_order(p_order uuid, p_perm text)
returns public.orders language plpgsql volatile security definer set search_path = '' as $$
declare v public.orders;
begin
  select * into v from public.orders where id = p_order for update;
  if v.id is null then raise exception 'resto.forbidden' using errcode = '42501'; end if;
  perform app_private.assert_branch_perm(v.branch_id, p_perm);
  if v.status <> 'open' then perform app_private.fail('resto.order_not_open'); end if;
  return v;
end $$;

-- -----------------------------------------------------------------------------
-- RPC
-- -----------------------------------------------------------------------------

-- Ouvre une commande. Sur une table déjà occupée : renvoie la commande en cours.
-- p_client_id (facultatif) rend l'appel rejouable sans doublon.
create or replace function public.open_order(
  p_branch uuid, p_channel text default 'dine_in', p_table uuid default null,
  p_guests smallint default null, p_note text default null, p_client_id uuid default null)
returns uuid language plpgsql security definer set search_path = '' as $$
declare
  v_branch public.branches;
  v_existing uuid;
  v_date date;
  v_order public.orders;
begin
  perform app_private.assert_branch_perm(p_branch, 'orders.write');
  if p_client_id is not null and exists (select 1 from public.orders where id = p_client_id and branch_id = p_branch) then
    return p_client_id;
  end if;
  select * into v_branch from public.branches where id = p_branch;
  if v_branch.status <> 'active' then perform app_private.fail('resto.branch_inactive'); end if;
  if coalesce(p_channel, '') not in ('dine_in', 'takeaway', 'delivery')
     or (p_channel <> 'dine_in' and p_table is not null) then
    perform app_private.fail('resto.invalid_order');
  end if;
  if p_table is not null then
    if not exists (select 1 from public.dining_tables
                    where id = p_table and branch_id = p_branch and active) then
      perform app_private.fail('resto.invalid_table');
    end if;
    -- Une seule commande ouverte par table : on attend un éventuel ouvreur concurrent.
    perform pg_advisory_xact_lock(hashtext('resto.table.' || p_table::text));
    select id into v_existing from public.orders where table_id = p_table and status = 'open';
    if v_existing is not null then return v_existing; end if;
  end if;

  v_date := (now() at time zone v_branch.timezone)::date;
  insert into public.orders (id, organization_id, brand_id, branch_id, business_date, number, channel, table_id,
                             guests, note, currency, prices_include_tax, tax_rate, opened_by)
  values (coalesce(p_client_id, gen_random_uuid()), v_branch.organization_id, v_branch.brand_id, p_branch, v_date,
          app_private.next_counter(p_branch, 'order:' || v_date::text), p_channel, p_table, p_guests,
          nullif(btrim(p_note), ''), v_branch.currency, v_branch.prices_include_tax, v_branch.tax_rate, auth.uid())
  returning * into v_order;
  perform app_private.log_order(v_order, 'opened', null, jsonb_build_object('table_id', p_table, 'channel', p_channel));
  return v_order.id;
end $$;

-- Ajoute un article. Le serveur choisit le prix (canal de la commande, sinon
-- prix de base) et vérifie disponibilité et règles des options.
create or replace function public.add_order_item(
  p_order uuid, p_variant uuid, p_quantity integer default 1, p_modifiers uuid[] default '{}',
  p_note text default null, p_client_id uuid default null)
returns uuid language plpgsql security definer set search_path = '' as $$
declare
  v_order public.orders;
  v_variant public.item_variants;
  v_item public.menu_items;
  v_available boolean;
  v_price bigint;
  v_mods uuid[] := array(select distinct m from unnest(coalesce(p_modifiers, '{}')) m);
  v_mod_total bigint := 0;
  v_line_id uuid;
  r record;
begin
  v_order := app_private.lock_open_order(p_order, 'orders.write');
  if p_client_id is not null and exists (select 1 from public.order_items where id = p_client_id and order_id = p_order) then
    return p_client_id;
  end if;
  if coalesce(p_quantity, 0) not between 1 and 999 then perform app_private.fail('resto.invalid_quantity'); end if;

  select * into v_variant from public.item_variants where id = p_variant and organization_id = v_order.organization_id;
  select * into v_item from public.menu_items where id = v_variant.item_id;
  select available into v_available from public.menu_item_branches where item_id = v_item.id and branch_id = v_order.branch_id;
  if v_variant.id is null or not v_variant.active or not v_item.active or v_item.brand_id <> v_order.brand_id
     or v_available is distinct from true then
    perform app_private.fail('resto.item_unavailable');
  end if;

  select amount_minor into v_price from public.prices
   where branch_id = v_order.branch_id and variant_id = p_variant and valid_to is null
     and channel in (v_order.channel, 'default')
   order by (channel = 'default') limit 1;
  if v_price is null then perform app_private.fail('resto.no_price'); end if;

  -- Options : chacune doit appartenir à un groupe actif proposé sur l'article ;
  -- chaque groupe respecte son minimum et son maximum.
  if exists (
    select 1 from unnest(v_mods) m
     where not exists (
       select 1 from public.modifiers mo
         join public.modifier_groups g on g.id = mo.group_id and g.active
         join public.item_modifier_groups img on img.group_id = g.id and img.item_id = v_item.id
        where mo.id = m and mo.active)) then
    perform app_private.fail('resto.options_invalid');
  end if;
  if exists (
    select 1 from public.item_modifier_groups img
      join public.modifier_groups g on g.id = img.group_id and g.active
     where img.item_id = v_item.id
       and ((select count(*) from public.modifiers mo where mo.group_id = g.id and mo.id = any (v_mods)) < g.min_select
         or (g.max_select is not null
             and (select count(*) from public.modifiers mo where mo.group_id = g.id and mo.id = any (v_mods)) > g.max_select))) then
    perform app_private.fail('resto.options_invalid');
  end if;

  select coalesce(sum(coalesce(
           (select p.amount_minor from public.prices p
             where p.branch_id = v_order.branch_id and p.modifier_id = mo.id and p.valid_to is null
               and p.channel in (v_order.channel, 'default')
             order by (p.channel = 'default') limit 1), 0)), 0)
    into v_mod_total
    from public.modifiers mo where mo.id = any (v_mods);

  insert into public.order_items (id, organization_id, branch_id, order_id, item_id, variant_id, item_name, variant_name,
                                  quantity, unit_price_minor, line_total_minor, note, added_by)
  values (coalesce(p_client_id, gen_random_uuid()), v_order.organization_id, v_order.branch_id, p_order, v_item.id,
          p_variant, v_item.name, v_variant.name, p_quantity, v_price + v_mod_total,
          (v_price + v_mod_total) * p_quantity, nullif(btrim(p_note), ''), auth.uid())
  returning id into v_line_id;

  for r in
    select mo.id, mo.name, g.name as group_name,
           coalesce((select p.amount_minor from public.prices p
                      where p.branch_id = v_order.branch_id and p.modifier_id = mo.id and p.valid_to is null
                        and p.channel in (v_order.channel, 'default')
                      order by (p.channel = 'default') limit 1), 0) as price
      from public.modifiers mo join public.modifier_groups g on g.id = mo.group_id
     where mo.id = any (v_mods)
     order by g.sort_order, g.name, mo.sort_order, mo.name
  loop
    insert into public.order_item_modifiers (organization_id, branch_id, order_item_id, modifier_id, group_name,
                                             modifier_name, price_minor)
    values (v_order.organization_id, v_order.branch_id, v_line_id, r.id, r.group_name, r.name, r.price);
  end loop;

  perform app_private.recompute_order(p_order);
  perform app_private.log_order(v_order, 'item_added', v_line_id,
    jsonb_build_object('name', v_item.name, 'variant', v_variant.name, 'quantity', p_quantity));
  return v_line_id;
end $$;

-- Ligne pas encore envoyée : quantité et remarque modifiables.
create or replace function public.update_order_item(p_item uuid, p_quantity integer, p_note text default null)
returns void language plpgsql security definer set search_path = '' as $$
declare
  v_line public.order_items;
  v_order public.orders;
begin
  select * into v_line from public.order_items where id = p_item;
  v_order := app_private.lock_open_order(v_line.order_id, 'orders.write');
  if v_line.prep_status <> 'pending' then perform app_private.fail('resto.item_already_sent'); end if;
  if coalesce(p_quantity, 0) not between 1 and 999 then perform app_private.fail('resto.invalid_quantity'); end if;
  update public.order_items set quantity = p_quantity, line_total_minor = unit_price_minor * p_quantity,
         note = nullif(btrim(p_note), '') where id = p_item;
  perform app_private.recompute_order(v_order.id);
  perform app_private.log_order(v_order, 'item_updated', p_item, jsonb_build_object('quantity', p_quantity));
end $$;

-- Ligne pas encore envoyée : peut être retirée (elle n'a jamais été validée).
create or replace function public.remove_order_item(p_item uuid)
returns void language plpgsql security definer set search_path = '' as $$
declare
  v_line public.order_items;
  v_order public.orders;
begin
  select * into v_line from public.order_items where id = p_item;
  v_order := app_private.lock_open_order(v_line.order_id, 'orders.write');
  if v_line.prep_status <> 'pending' then perform app_private.fail('resto.item_already_sent'); end if;
  delete from public.order_items where id = p_item;
  perform app_private.recompute_order(v_order.id);
  perform app_private.log_order(v_order, 'item_removed', p_item,
    jsonb_build_object('name', v_line.item_name, 'quantity', v_line.quantity));
end $$;

-- Envoie en cuisine toutes les lignes en attente ; renvoie leur nombre.
create or replace function public.send_order(p_order uuid)
returns integer language plpgsql security definer set search_path = '' as $$
declare
  v_order public.orders;
  v_count integer;
begin
  v_order := app_private.lock_open_order(p_order, 'orders.write');
  update public.order_items set prep_status = 'sent', sent_at = now()
   where order_id = p_order and prep_status = 'pending';
  get diagnostics v_count = row_count;
  if v_count > 0 then
    update public.orders set version = version + 1 where id = p_order;
    perform app_private.log_order(v_order, 'sent', null, jsonb_build_object('lines', v_count));
  end if;
  return v_count;
end $$;

-- Annule une ligne déjà envoyée : permission orders.void et motif obligatoires.
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
  perform app_private.log_order(v_order, 'item_cancelled', p_item,
    jsonb_build_object('name', v_line.item_name, 'reason', btrim(p_reason)));
end $$;

-- Annule toute la commande. Si des lignes sont déjà parties en cuisine :
-- permission orders.void et motif obligatoires.
create or replace function public.cancel_order(p_order uuid, p_reason text default null)
returns void language plpgsql security definer set search_path = '' as $$
declare
  v_order public.orders;
  v_sent boolean;
begin
  v_order := app_private.lock_open_order(p_order, 'orders.write');
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

revoke all on function public.open_order(uuid, text, uuid, smallint, text, uuid),
  public.add_order_item(uuid, uuid, integer, uuid[], text, uuid),
  public.update_order_item(uuid, integer, text), public.remove_order_item(uuid), public.send_order(uuid),
  public.cancel_order_item(uuid, text), public.cancel_order(uuid, text) from public, anon;
grant execute on function public.open_order(uuid, text, uuid, smallint, text, uuid),
  public.add_order_item(uuid, uuid, integer, uuid[], text, uuid),
  public.update_order_item(uuid, integer, text), public.remove_order_item(uuid), public.send_order(uuid),
  public.cancel_order_item(uuid, text), public.cancel_order(uuid, text) to authenticated;

revoke all on all functions in schema app_private from public, anon, authenticated;
grant execute on function app_private.member_org_ids(), app_private.member_branch_ids(),
  app_private.org_ids_with(text), app_private.branch_ids_with(text),
  app_private.full_access_org_ids(), app_private.assigned_branch_ids() to authenticated;
