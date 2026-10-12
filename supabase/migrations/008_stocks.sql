-- =============================================================================
-- Resto — 008_stocks
-- Ingrédients, unités et conversions, emplacements, mouvements de stock
-- (jamais modifiés ni supprimés), coût moyen pondéré par établissement,
-- fiches techniques versionnées (plats, options, préparations maison),
-- consommation théorique à la clôture des commandes, production des
-- préparations, transferts, inventaires et écarts, état des stocks.
-- À coller APRÈS 007, puis supabase/tests/008_stocks_tests.sql.
--
-- Quantités : numeric(18,4) dans l'unité de stock de l'ingrédient.
-- Coûts : unités mineures de la monnaie de l'établissement par unité de stock
-- (numeric, pour garder la précision des petits coûts unitaires).
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Unités (conversion automatique dans une même dimension)
-- -----------------------------------------------------------------------------
create table public.ref_units (
  code text primary key check (code ~ '^[a-z_]+$'),
  dimension text not null check (dimension in ('mass', 'volume', 'count')),
  factor numeric(18, 6) not null check (factor > 0),
  sort_order smallint not null
);
insert into public.ref_units (code, dimension, factor, sort_order) values
  ('g', 'mass', 1, 1), ('kg', 'mass', 1000, 2), ('ml', 'volume', 1, 3), ('cl', 'volume', 10, 4),
  ('l', 'volume', 1000, 5), ('unit', 'count', 1, 6), ('dozen', 'count', 12, 7)
on conflict (code) do nothing;
alter table public.ref_units enable row level security;
revoke all on public.ref_units from anon, authenticated;
grant select on public.ref_units to anon, authenticated;
create policy ref_units_read on public.ref_units for select to anon, authenticated using (true);

-- Conversion ; null si les unités ne sont pas de même nature.
create or replace function app_private.convert_qty(p_qty numeric, p_from text, p_to text)
returns numeric language sql stable security definer set search_path = '' as $$
  select p_qty * f.factor / t.factor
    from public.ref_units f, public.ref_units t
   where f.code = p_from and t.code = p_to and f.dimension = t.dimension
$$;

-- -----------------------------------------------------------------------------
-- Ingrédients (catalogue de l'organisation) et emplacements (par établissement)
-- -----------------------------------------------------------------------------
create table public.ingredients (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations (id) on delete restrict,
  name text not null check (length(btrim(name)) between 1 and 120),
  kind text not null default 'raw' check (kind in ('raw', 'beverage', 'packaging', 'semi_finished', 'consumable')),
  unit_code text not null references public.ref_units (code),
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (organization_id, id),
  unique (organization_id, name)
);
create trigger ingredients_touch before update on public.ingredients
  for each row execute function app_private.touch_updated_at();

-- L'unité de stock ne change plus dès qu'il existe des mouvements.
create or replace function app_private.lock_ingredient_unit()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  if new.unit_code is distinct from old.unit_code
     and exists (select 1 from public.stock_movements m where m.ingredient_id = new.id) then
    perform app_private.fail('resto.unit_locked');
  end if;
  return new;
end $$;

create table public.stock_locations (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations (id) on delete restrict,
  branch_id uuid not null,
  name text not null check (length(btrim(name)) between 1 and 60),
  sort_order integer not null default 0,
  active boolean not null default true,
  created_at timestamptz not null default now(),
  unique (organization_id, id),
  unique (organization_id, branch_id, id),
  unique (branch_id, name),
  foreign key (organization_id, branch_id) references public.branches (organization_id, id) on delete restrict
);
insert into public.stock_locations (organization_id, branch_id, name)
select b.organization_id, b.id, 'Réserve' from public.branches b
on conflict (branch_id, name) do nothing;

create or replace function app_private.on_branch_created()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  insert into public.cash_registers (organization_id, branch_id, name)
  values (new.organization_id, new.id, 'Caisse 1') on conflict (branch_id, name) do nothing;
  insert into public.prep_stations (organization_id, branch_id, name, kinds, sort_order)
  values (new.organization_id, new.id, 'Cuisine', array['food', 'other'], 0),
         (new.organization_id, new.id, 'Bar', array['drink'], 1)
  on conflict (branch_id, name) do nothing;
  insert into public.stock_locations (organization_id, branch_id, name)
  values (new.organization_id, new.id, 'Réserve') on conflict (branch_id, name) do nothing;
  return null;
end $$;

-- Par établissement : seuil d'alerte et coût moyen pondéré.
create table public.ingredient_stock (
  organization_id uuid not null,
  branch_id uuid not null,
  ingredient_id uuid not null,
  min_quantity numeric(18, 4) not null default 0 check (min_quantity >= 0),
  avg_unit_cost numeric(20, 6) not null default 0 check (avg_unit_cost >= 0),
  updated_at timestamptz not null default now(),
  primary key (branch_id, ingredient_id),
  foreign key (organization_id, branch_id) references public.branches (organization_id, id) on delete restrict,
  foreign key (organization_id, ingredient_id) references public.ingredients (organization_id, id) on delete restrict
);

-- -----------------------------------------------------------------------------
-- Mouvements de stock (journal ; jamais modifiés ni supprimés)
-- -----------------------------------------------------------------------------
create table public.stock_movements (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null,
  branch_id uuid not null,
  location_id uuid not null,
  ingredient_id uuid not null,
  kind text not null check (kind in ('opening', 'receipt', 'sale', 'production_in', 'production_out', 'waste',
    'staff_meal', 'return', 'transfer_in', 'transfer_out', 'adjustment', 'inventory')),
  quantity numeric(18, 4) not null check (quantity <> 0),
  unit_cost numeric(20, 6) not null default 0 check (unit_cost >= 0),
  currency char(3) not null references public.ref_currencies (code),
  reason text check (length(reason) <= 300),
  batch text check (length(batch) <= 60),
  expires_on date,
  order_item_id uuid,
  receipt_id uuid,
  inventory_id uuid,
  transfer_id uuid,
  production_id uuid,
  created_by uuid references auth.users (id) on delete set null,
  created_at timestamptz not null default now(),
  unique (organization_id, id),
  check (case
    when kind in ('opening', 'receipt', 'production_in', 'transfer_in') then quantity > 0
    when kind in ('sale', 'production_out', 'waste', 'staff_meal', 'return', 'transfer_out') then quantity < 0
    else true end),
  foreign key (organization_id, branch_id, location_id) references public.stock_locations (organization_id, branch_id, id) on delete restrict,
  foreign key (organization_id, ingredient_id) references public.ingredients (organization_id, id) on delete restrict
);
create index stock_movements_branch_ing_idx on public.stock_movements (branch_id, ingredient_id);
create index stock_movements_location_ing_idx on public.stock_movements (location_id, ingredient_id);
create index stock_movements_branch_date_idx on public.stock_movements (branch_id, created_at desc);
-- Une vente ne consomme qu'une fois un ingrédient pour une ligne de commande.
create unique index stock_movements_sale_once on public.stock_movements (order_item_id, ingredient_id) where kind = 'sale';

create trigger stock_movements_immutable before update or delete on public.stock_movements
  for each row execute function app_private.audit_immutable();
create trigger ingredients_lock_unit before update of unit_code on public.ingredients
  for each row execute function app_private.lock_ingredient_unit();

-- -----------------------------------------------------------------------------
-- Fiches techniques versionnées (plat = variante, option, préparation maison)
-- -----------------------------------------------------------------------------
create table public.recipe_versions (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations (id) on delete restrict,
  variant_id uuid,
  modifier_id uuid,
  ingredient_id uuid,
  -- Quantité obtenue (1 portion pour un plat ; pour une préparation maison,
  -- dans l'unité de stock de la préparation)
  yield_quantity numeric(18, 4) not null default 1 check (yield_quantity > 0),
  notes text check (length(notes) <= 1000),
  valid_from timestamptz not null default now(),
  valid_to timestamptz,
  created_by uuid references auth.users (id) on delete set null,
  created_at timestamptz not null default now(),
  unique (organization_id, id),
  check (num_nonnulls(variant_id, modifier_id, ingredient_id) = 1),
  check (valid_to is null or valid_to >= valid_from),
  foreign key (organization_id, variant_id) references public.item_variants (organization_id, id) on delete restrict,
  foreign key (organization_id, modifier_id) references public.modifiers (organization_id, id) on delete restrict,
  foreign key (organization_id, ingredient_id) references public.ingredients (organization_id, id) on delete restrict
);
create unique index recipe_versions_one_current on public.recipe_versions ((coalesce(variant_id, modifier_id, ingredient_id)))
  where valid_to is null;

create table public.recipe_lines (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null,
  version_id uuid not null,
  ingredient_id uuid not null,
  quantity numeric(18, 4) not null check (quantity > 0),
  unit_code text not null references public.ref_units (code),
  waste_percent numeric(5, 2) not null default 0 check (waste_percent >= 0 and waste_percent < 100),
  sort_order integer not null default 0,
  foreign key (organization_id, version_id) references public.recipe_versions (organization_id, id) on delete cascade,
  foreign key (organization_id, ingredient_id) references public.ingredients (organization_id, id) on delete restrict
);
create index recipe_lines_version_idx on public.recipe_lines (version_id);

-- -----------------------------------------------------------------------------
-- Inventaires
-- -----------------------------------------------------------------------------
create table public.inventory_counts (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null,
  branch_id uuid not null,
  location_id uuid not null,
  status text not null default 'draft' check (status in ('draft', 'validated', 'cancelled')),
  note text check (length(note) <= 500),
  started_by uuid references auth.users (id) on delete set null,
  started_at timestamptz not null default now(),
  validated_by uuid references auth.users (id) on delete set null,
  validated_at timestamptz,
  unique (organization_id, id),
  foreign key (organization_id, branch_id, location_id) references public.stock_locations (organization_id, branch_id, id) on delete restrict
);
create table public.inventory_count_lines (
  organization_id uuid not null,
  count_id uuid not null,
  ingredient_id uuid not null,
  counted_quantity numeric(18, 4) not null check (counted_quantity >= 0),
  theoretical_quantity numeric(18, 4),
  difference numeric(18, 4),
  primary key (count_id, ingredient_id),
  foreign key (organization_id, count_id) references public.inventory_counts (organization_id, id) on delete cascade,
  foreign key (organization_id, ingredient_id) references public.ingredients (organization_id, id) on delete restrict
);

-- -----------------------------------------------------------------------------
-- Audit, droits, RLS
-- -----------------------------------------------------------------------------
do $$
declare t text;
begin
  foreach t in array array['ingredients', 'stock_locations', 'ingredient_stock', 'stock_movements', 'recipe_versions',
    'recipe_lines', 'inventory_counts', 'inventory_count_lines'] loop
    -- Les mouvements sont eux-mêmes un journal immuable (auteur, date) : pas de double audit.
    if t <> 'stock_movements' then
      execute format('create trigger %I after insert or update or delete on public.%I
        for each row execute function app_private.audit_row()', t || '_audit', t);
    end if;
    execute format('alter table public.%I enable row level security', t);
    execute format('revoke all on public.%I from anon, authenticated', t);
    execute format('grant select on public.%I to authenticated', t);
  end loop;
  foreach t in array array['ingredient_stock', 'stock_movements', 'inventory_counts'] loop
    execute format('create policy %I on public.%I for select to authenticated
      using (branch_id in (select app_private.branch_ids_with(''stock.read'')))', t || '_read', t);
  end loop;
end $$;

-- Ingrédients et fiches techniques : visibles des membres ; ingrédients
-- gérés avec stock.write sur toute l'organisation.
grant insert (id, organization_id, name, kind, unit_code, active), update (name, kind, unit_code, active)
  on public.ingredients to authenticated;
create policy ingredients_read on public.ingredients for select to authenticated
  using (organization_id in (select app_private.member_org_ids()));
create policy ingredients_insert on public.ingredients for insert to authenticated
  with check (organization_id in (select app_private.org_ids_with('stock.write')));
create policy ingredients_update on public.ingredients for update to authenticated
  using (organization_id in (select app_private.org_ids_with('stock.write')))
  with check (organization_id in (select app_private.org_ids_with('stock.write')));

create policy recipe_versions_read on public.recipe_versions for select to authenticated
  using (organization_id in (select app_private.member_org_ids()));
create policy recipe_lines_read on public.recipe_lines for select to authenticated
  using (organization_id in (select app_private.member_org_ids()));
create policy inventory_count_lines_read on public.inventory_count_lines for select to authenticated
  using (count_id in (select id from public.inventory_counts));

grant insert (id, organization_id, branch_id, name, sort_order, active), update (name, sort_order, active)
  on public.stock_locations to authenticated;
create policy stock_locations_read on public.stock_locations for select to authenticated
  using (branch_id in (select app_private.member_branch_ids()));
create policy stock_locations_insert on public.stock_locations for insert to authenticated
  with check (branch_id in (select app_private.branch_ids_with('stock.adjust')));
create policy stock_locations_update on public.stock_locations for update to authenticated
  using (branch_id in (select app_private.branch_ids_with('stock.adjust')))
  with check (branch_id in (select app_private.branch_ids_with('stock.adjust')));

-- -----------------------------------------------------------------------------
-- Fonctions internes
-- -----------------------------------------------------------------------------

-- Quantité en stock d'un ingrédient (un emplacement, ou tout l'établissement).
create or replace function app_private.stock_qty(p_branch uuid, p_ingredient uuid, p_location uuid default null)
returns numeric language sql stable security definer set search_path = '' as $$
  select coalesce(sum(quantity), 0) from public.stock_movements
   where branch_id = p_branch and ingredient_id = p_ingredient and (p_location is null or location_id = p_location)
$$;

create or replace function app_private.avg_cost(p_branch uuid, p_ingredient uuid)
returns numeric language sql stable security definer set search_path = '' as $$
  select coalesce((select avg_unit_cost from public.ingredient_stock
                    where branch_id = p_branch and ingredient_id = p_ingredient), 0)
$$;

-- Entrée valorisée : nouveau coût moyen pondéré (le stock négatif compte pour 0).
create or replace function app_private.apply_entry_cost(p_branch uuid, p_ingredient uuid, p_qty numeric, p_cost numeric)
returns void language plpgsql volatile security definer set search_path = '' as $$
declare
  v_org uuid;
  v_qty numeric := greatest(app_private.stock_qty(p_branch, p_ingredient), 0);
  v_avg numeric := app_private.avg_cost(p_branch, p_ingredient);
begin
  select organization_id into v_org from public.branches where id = p_branch;
  insert into public.ingredient_stock (organization_id, branch_id, ingredient_id, avg_unit_cost)
  values (v_org, p_branch, p_ingredient, case when v_qty + p_qty > 0 then (v_qty * v_avg + p_qty * p_cost) / (v_qty + p_qty) else p_cost end)
  on conflict (branch_id, ingredient_id) do update
    set avg_unit_cost = excluded.avg_unit_cost, updated_at = now();
end $$;

create or replace function app_private.default_location(p_branch uuid)
returns uuid language sql stable security definer set search_path = '' as $$
  select id from public.stock_locations where branch_id = p_branch and active order by sort_order, created_at, id limit 1
$$;

-- Fiche technique en vigueur à une date pour une cible (variante, option ou préparation).
create or replace function app_private.recipe_at(p_target uuid, p_at timestamptz)
returns uuid language sql stable security definer set search_path = '' as $$
  select id from public.recipe_versions
   where coalesce(variant_id, modifier_id, ingredient_id) = p_target
     and valid_from <= p_at and (valid_to is null or valid_to > p_at)
   order by valid_from desc limit 1
$$;

-- Consommation théorique d'une commande clôturée : pour chaque ligne non
-- annulée, fiche du plat + fiches des options, en vigueur à l'envoi en cuisine.
create or replace function app_private.consume_order(p_order uuid)
returns void language plpgsql volatile security definer set search_path = '' as $$
declare
  v_order public.orders;
  v_location uuid;
begin
  select * into v_order from public.orders where id = p_order;
  v_location := app_private.default_location(v_order.branch_id);
  if v_location is null then return; end if;
  insert into public.stock_movements (organization_id, branch_id, location_id, ingredient_id, kind, quantity, unit_cost,
                                      currency, order_item_id, reason)
  select v_order.organization_id, v_order.branch_id, v_location, x.ingredient_id, 'sale', -sum(x.qty),
         app_private.avg_cost(v_order.branch_id, x.ingredient_id), v_order.currency, x.order_item_id,
         'commande ' || v_order.number
    from (
      select oi.id as order_item_id, rl.ingredient_id,
             app_private.convert_qty(rl.quantity, rl.unit_code, ing.unit_code)
               * (1 + rl.waste_percent / 100) / rv.yield_quantity * oi.quantity as qty
        from public.order_items oi
        join public.recipe_versions rv on rv.id = app_private.recipe_at(oi.variant_id, coalesce(oi.sent_at, oi.added_at))
        join public.recipe_lines rl on rl.version_id = rv.id
        join public.ingredients ing on ing.id = rl.ingredient_id
       where oi.order_id = p_order and oi.prep_status <> 'cancelled'
      union all
      select oi.id, rl.ingredient_id,
             app_private.convert_qty(rl.quantity, rl.unit_code, ing.unit_code)
               * (1 + rl.waste_percent / 100) / rv.yield_quantity * oi.quantity
        from public.order_items oi
        join public.order_item_modifiers om on om.order_item_id = oi.id
        join public.recipe_versions rv on rv.id = app_private.recipe_at(om.modifier_id, coalesce(oi.sent_at, oi.added_at))
        join public.recipe_lines rl on rl.version_id = rv.id
        join public.ingredients ing on ing.id = rl.ingredient_id
       where oi.order_id = p_order and oi.prep_status <> 'cancelled'
    ) x
   where x.qty is not null and x.qty > 0
   group by x.order_item_id, x.ingredient_id
  on conflict (order_item_id, ingredient_id) where kind = 'sale' do nothing;
end $$;

create or replace function app_private.on_order_closed()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  if new.status = 'closed' and old.status is distinct from 'closed' then
    perform app_private.consume_order(new.id);
  end if;
  return null;
end $$;
create trigger orders_consume_on_close after update of status on public.orders
  for each row execute function app_private.on_order_closed();

-- -----------------------------------------------------------------------------
-- RPC
-- -----------------------------------------------------------------------------

-- Mouvement manuel. p_quantity est une quantité positive dans p_unit, sauf
-- pour un ajustement (signé). Entrée et stock initial : p_unit_cost = coût
-- par unité saisie (unités mineures). Ajustement et stock initial : stock.adjust.
create or replace function public.record_stock_movement(
  p_branch uuid, p_location uuid, p_ingredient uuid, p_kind text, p_quantity numeric, p_unit text,
  p_unit_cost numeric default 0, p_reason text default null, p_batch text default null, p_expires_on date default null,
  p_client_id uuid default null)
returns uuid language plpgsql security definer set search_path = '' as $$
declare
  v_branch public.branches;
  v_ing public.ingredients;
  v_qty numeric;
  v_cost numeric;
  v_id uuid;
begin
  if coalesce(p_kind, '') not in ('opening', 'receipt', 'waste', 'staff_meal', 'return', 'adjustment') then
    perform app_private.fail('resto.invalid_movement');
  end if;
  perform app_private.assert_branch_perm(p_branch,
    case when p_kind in ('adjustment', 'opening') then 'stock.adjust' else 'stock.write' end);
  if p_client_id is not null and exists (select 1 from public.stock_movements where id = p_client_id) then
    return p_client_id;
  end if;
  select * into v_branch from public.branches where id = p_branch;
  select * into v_ing from public.ingredients where id = p_ingredient and organization_id = v_branch.organization_id;
  if v_ing.id is null or not exists (select 1 from public.stock_locations where id = p_location and branch_id = p_branch) then
    perform app_private.fail('resto.invalid_movement');
  end if;
  v_qty := app_private.convert_qty(p_quantity, p_unit, v_ing.unit_code);
  if v_qty is null or v_qty = 0 or (p_kind <> 'adjustment' and v_qty < 0) then
    perform app_private.fail('resto.invalid_quantity');
  end if;
  if p_kind in ('waste', 'staff_meal', 'return', 'adjustment') and length(btrim(coalesce(p_reason, ''))) < 3 then
    perform app_private.fail('resto.reason_required');
  end if;
  if coalesce(p_unit_cost, 0) < 0 then perform app_private.fail('resto.invalid_amount'); end if;
  -- Coût ramené à l'unité de stock.
  v_cost := case when p_kind in ('receipt', 'opening') then coalesce(p_unit_cost, 0) * p_quantity / v_qty
                 else app_private.avg_cost(p_branch, p_ingredient) end;
  if p_kind in ('receipt', 'opening') then
    perform app_private.apply_entry_cost(p_branch, p_ingredient, v_qty, v_cost);
  end if;
  insert into public.stock_movements (id, organization_id, branch_id, location_id, ingredient_id, kind, quantity,
                                      unit_cost, currency, reason, batch, expires_on, created_by)
  values (coalesce(p_client_id, gen_random_uuid()), v_branch.organization_id, p_branch, p_location, p_ingredient, p_kind,
          case when p_kind in ('opening', 'receipt') or (p_kind = 'adjustment' and v_qty > 0) then v_qty else -abs(v_qty) end,
          v_cost, v_branch.currency, nullif(btrim(p_reason), ''), nullif(btrim(p_batch), ''), p_expires_on, auth.uid())
  returning id into v_id;
  return v_id;
end $$;

-- Transfert entre emplacements (même établissement ou autre établissement de
-- l'organisation), valorisé au coût moyen de départ.
create or replace function public.transfer_stock(
  p_from_location uuid, p_to_location uuid, p_ingredient uuid, p_quantity numeric, p_unit text,
  p_reason text default null, p_client_id uuid default null)
returns uuid language plpgsql security definer set search_path = '' as $$
declare
  v_from public.stock_locations;
  v_to public.stock_locations;
  v_ing public.ingredients;
  v_qty numeric;
  v_cost numeric;
  v_transfer uuid := coalesce(p_client_id, gen_random_uuid());
  v_currency char(3);
begin
  select * into v_from from public.stock_locations where id = p_from_location;
  select * into v_to from public.stock_locations where id = p_to_location;
  perform app_private.assert_branch_perm(v_from.branch_id, 'stock.write');
  if exists (select 1 from public.stock_movements where transfer_id = v_transfer) then return v_transfer; end if;
  if v_to.id is null or v_to.organization_id <> v_from.organization_id or v_to.id = v_from.id then
    perform app_private.fail('resto.invalid_movement');
  end if;
  select * into v_ing from public.ingredients where id = p_ingredient and organization_id = v_from.organization_id;
  v_qty := app_private.convert_qty(p_quantity, p_unit, v_ing.unit_code);
  if v_ing.id is null or v_qty is null or v_qty <= 0 then perform app_private.fail('resto.invalid_quantity'); end if;
  if (select currency from public.branches where id = v_to.branch_id)
     <> (select currency from public.branches where id = v_from.branch_id) then
    perform app_private.fail('resto.invalid_movement');
  end if;
  select currency into v_currency from public.branches where id = v_from.branch_id;
  v_cost := app_private.avg_cost(v_from.branch_id, p_ingredient);
  if v_to.branch_id <> v_from.branch_id then
    perform app_private.apply_entry_cost(v_to.branch_id, p_ingredient, v_qty, v_cost);
  end if;
  insert into public.stock_movements (organization_id, branch_id, location_id, ingredient_id, kind, quantity, unit_cost,
                                      currency, reason, transfer_id, created_by)
  values (v_from.organization_id, v_from.branch_id, v_from.id, p_ingredient, 'transfer_out', -v_qty, v_cost, v_currency,
          nullif(btrim(p_reason), ''), v_transfer, auth.uid()),
         (v_to.organization_id, v_to.branch_id, v_to.id, p_ingredient, 'transfer_in', v_qty, v_cost, v_currency,
          nullif(btrim(p_reason), ''), v_transfer, auth.uid());
  return v_transfer;
end $$;

-- Production d'une préparation maison (sauce, pâte…) selon sa fiche :
-- consomme les ingrédients, ajoute la préparation au coût de revient.
create or replace function public.record_production(
  p_branch uuid, p_location uuid, p_ingredient uuid, p_quantity numeric, p_client_id uuid default null)
returns uuid language plpgsql security definer set search_path = '' as $$
declare
  v_branch public.branches;
  v_ing public.ingredients;
  v_recipe public.recipe_versions;
  v_prod uuid := coalesce(p_client_id, gen_random_uuid());
  v_total_cost numeric;
begin
  perform app_private.assert_branch_perm(p_branch, 'stock.write');
  if exists (select 1 from public.stock_movements where production_id = v_prod) then return v_prod; end if;
  select * into v_branch from public.branches where id = p_branch;
  select * into v_ing from public.ingredients where id = p_ingredient and organization_id = v_branch.organization_id;
  select * into v_recipe from public.recipe_versions where id = app_private.recipe_at(p_ingredient, now());
  if v_ing.id is null or v_ing.kind <> 'semi_finished' or v_recipe.id is null then
    perform app_private.fail('resto.no_recipe');
  end if;
  if coalesce(p_quantity, 0) <= 0
     or not exists (select 1 from public.stock_locations where id = p_location and branch_id = p_branch) then
    perform app_private.fail('resto.invalid_quantity');
  end if;
  with c as (
    select rl.ingredient_id,
           app_private.convert_qty(rl.quantity, rl.unit_code, i.unit_code) * (1 + rl.waste_percent / 100)
             / v_recipe.yield_quantity * p_quantity as qty
      from public.recipe_lines rl join public.ingredients i on i.id = rl.ingredient_id
     where rl.version_id = v_recipe.id),
  ins as (
    insert into public.stock_movements (organization_id, branch_id, location_id, ingredient_id, kind, quantity, unit_cost,
                                        currency, production_id, reason, created_by)
    select v_branch.organization_id, p_branch, p_location, c.ingredient_id, 'production_out', -c.qty,
           app_private.avg_cost(p_branch, c.ingredient_id), v_branch.currency, v_prod, v_ing.name, auth.uid()
      from c where c.qty > 0
    returning -quantity * unit_cost as cost)
  select coalesce(sum(cost), 0) into v_total_cost from ins;
  perform app_private.apply_entry_cost(p_branch, p_ingredient, p_quantity, v_total_cost / p_quantity);
  insert into public.stock_movements (organization_id, branch_id, location_id, ingredient_id, kind, quantity, unit_cost,
                                      currency, production_id, created_by)
  values (v_branch.organization_id, p_branch, p_location, p_ingredient, 'production_in', p_quantity,
          v_total_cost / p_quantity, v_branch.currency, v_prod, auth.uid());
  return v_prod;
end $$;

-- Enregistre une nouvelle version de fiche technique (l'ancienne est
-- conservée). p_lines : [{"ingredient_id":…, "quantity":120, "unit":"g", "waste_percent":5}, …]
-- Liste vide = plus de fiche. Catalogue : menus.manage sur toute l'organisation.
create or replace function public.save_recipe(
  p_variant uuid, p_modifier uuid, p_ingredient uuid, p_yield numeric, p_lines jsonb, p_notes text default null)
returns uuid language plpgsql security definer set search_path = '' as $$
declare
  v_org uuid;
  v_target uuid := coalesce(p_variant, p_modifier, p_ingredient);
  v_id uuid;
  v_now timestamptz := now();
  v_bad boolean;
begin
  if num_nonnulls(p_variant, p_modifier, p_ingredient) <> 1 then perform app_private.fail('resto.invalid_recipe'); end if;
  if p_variant is not null then select organization_id into v_org from public.item_variants where id = p_variant;
  elsif p_modifier is not null then select organization_id into v_org from public.modifiers where id = p_modifier;
  else select organization_id into v_org from public.ingredients where id = p_ingredient and kind = 'semi_finished';
  end if;
  if v_org is null or not app_private.has_org_perm(v_org, 'menus.manage') then
    raise exception 'resto.forbidden' using errcode = '42501';
  end if;
  if coalesce(p_yield, 0) <= 0 or jsonb_typeof(coalesce(p_lines, '[]'::jsonb)) <> 'array' then
    perform app_private.fail('resto.invalid_recipe');
  end if;
  -- Chaque ligne : ingrédient de l'organisation, quantité positive, unité compatible, pas la préparation elle-même.
  select exists (
    select 1 from jsonb_array_elements(coalesce(p_lines, '[]'::jsonb)) l
      left join public.ingredients i on i.id = (l ->> 'ingredient_id')::uuid and i.organization_id = v_org
     where i.id is null or i.id = p_ingredient
        or coalesce((l ->> 'quantity')::numeric, 0) <= 0
        or app_private.convert_qty(1, l ->> 'unit', i.unit_code) is null
        or coalesce((l ->> 'waste_percent')::numeric, 0) not between 0 and 99.99)
    into v_bad;
  if v_bad then perform app_private.fail('resto.invalid_recipe'); end if;

  perform pg_advisory_xact_lock(hashtext('resto.recipe.' || v_target::text));
  update public.recipe_versions set valid_to = v_now
   where coalesce(variant_id, modifier_id, ingredient_id) = v_target and valid_to is null;
  if jsonb_array_length(coalesce(p_lines, '[]'::jsonb)) = 0 then return null; end if;
  insert into public.recipe_versions (organization_id, variant_id, modifier_id, ingredient_id, yield_quantity, notes,
                                      valid_from, created_by)
  values (v_org, p_variant, p_modifier, p_ingredient, p_yield, nullif(btrim(p_notes), ''), v_now, auth.uid())
  returning id into v_id;
  insert into public.recipe_lines (organization_id, version_id, ingredient_id, quantity, unit_code, waste_percent, sort_order)
  select v_org, v_id, (l ->> 'ingredient_id')::uuid, (l ->> 'quantity')::numeric, l ->> 'unit',
         coalesce((l ->> 'waste_percent')::numeric, 0), (row_number() over ())::int
    from jsonb_array_elements(p_lines) l;
  return v_id;
exception
  when invalid_text_representation or numeric_value_out_of_range then
    perform app_private.fail('resto.invalid_recipe');
end $$;

-- Seuil d'alerte d'un ingrédient dans un établissement.
create or replace function public.set_stock_threshold(p_branch uuid, p_ingredient uuid, p_min numeric)
returns void language plpgsql security definer set search_path = '' as $$
declare v_org uuid;
begin
  perform app_private.assert_branch_perm(p_branch, 'stock.write');
  select organization_id into v_org from public.ingredients where id = p_ingredient;
  if coalesce(p_min, -1) < 0 or v_org is distinct from (select organization_id from public.branches where id = p_branch) then
    perform app_private.fail('resto.invalid_quantity');
  end if;
  insert into public.ingredient_stock (organization_id, branch_id, ingredient_id, min_quantity)
  values (v_org, p_branch, p_ingredient, p_min)
  on conflict (branch_id, ingredient_id) do update set min_quantity = excluded.min_quantity, updated_at = now();
end $$;

-- Inventaire : brouillon, saisie des quantités comptées, validation
-- (stock.adjust) qui enregistre les écarts comme mouvements « inventory ».
create or replace function public.start_inventory(p_location uuid, p_client_id uuid default null)
returns uuid language plpgsql security definer set search_path = '' as $$
declare
  v_loc public.stock_locations;
  v_id uuid;
begin
  select * into v_loc from public.stock_locations where id = p_location;
  perform app_private.assert_branch_perm(v_loc.branch_id, 'stock.write');
  if p_client_id is not null and exists (select 1 from public.inventory_counts where id = p_client_id) then
    return p_client_id;
  end if;
  insert into public.inventory_counts (id, organization_id, branch_id, location_id, started_by)
  values (coalesce(p_client_id, gen_random_uuid()), v_loc.organization_id, v_loc.branch_id, v_loc.id, auth.uid())
  returning id into v_id;
  return v_id;
end $$;

create or replace function public.save_inventory_line(p_count uuid, p_ingredient uuid, p_counted numeric, p_unit text)
returns void language plpgsql security definer set search_path = '' as $$
declare
  v_count public.inventory_counts;
  v_ing public.ingredients;
  v_qty numeric;
begin
  select * into v_count from public.inventory_counts where id = p_count for update;
  perform app_private.assert_branch_perm(v_count.branch_id, 'stock.write');
  if v_count.status <> 'draft' then perform app_private.fail('resto.inventory_closed'); end if;
  select * into v_ing from public.ingredients where id = p_ingredient and organization_id = v_count.organization_id;
  v_qty := app_private.convert_qty(p_counted, p_unit, v_ing.unit_code);
  if v_ing.id is null or v_qty is null or v_qty < 0 then perform app_private.fail('resto.invalid_quantity'); end if;
  insert into public.inventory_count_lines (organization_id, count_id, ingredient_id, counted_quantity)
  values (v_count.organization_id, p_count, p_ingredient, v_qty)
  on conflict (count_id, ingredient_id) do update set counted_quantity = excluded.counted_quantity;
end $$;

create or replace function public.validate_inventory(p_count uuid, p_note text default null)
returns integer language plpgsql security definer set search_path = '' as $$
declare
  v_count public.inventory_counts;
  v_currency char(3);
  v_n integer;
begin
  select * into v_count from public.inventory_counts where id = p_count for update;
  perform app_private.assert_branch_perm(v_count.branch_id, 'stock.adjust');
  if v_count.status <> 'draft' then perform app_private.fail('resto.inventory_closed'); end if;
  select currency into v_currency from public.branches where id = v_count.branch_id;
  update public.inventory_count_lines l
     set theoretical_quantity = app_private.stock_qty(v_count.branch_id, l.ingredient_id, v_count.location_id),
         difference = l.counted_quantity - app_private.stock_qty(v_count.branch_id, l.ingredient_id, v_count.location_id)
   where l.count_id = p_count;
  insert into public.stock_movements (organization_id, branch_id, location_id, ingredient_id, kind, quantity, unit_cost,
                                      currency, inventory_id, reason, created_by)
  select v_count.organization_id, v_count.branch_id, v_count.location_id, l.ingredient_id, 'inventory', l.difference,
         app_private.avg_cost(v_count.branch_id, l.ingredient_id), v_currency, p_count, 'inventaire', auth.uid()
    from public.inventory_count_lines l
   where l.count_id = p_count and l.difference <> 0;
  get diagnostics v_n = row_count;
  update public.inventory_counts set status = 'validated', validated_by = auth.uid(), validated_at = now(),
         note = nullif(btrim(p_note), '') where id = p_count;
  return v_n;
end $$;

-- État des stocks d'un établissement : quantité, seuil, coût moyen, valeur.
create or replace function public.stock_overview(p_branch uuid)
returns table (ingredient_id uuid, name text, kind text, unit_code text, quantity numeric, min_quantity numeric,
               avg_unit_cost numeric, value_minor numeric, below_min boolean)
language plpgsql stable security definer set search_path = '' as $$
begin
  perform app_private.assert_branch_perm(p_branch, 'stock.read');
  return query
  select i.id, i.name, i.kind, i.unit_code,
         coalesce(m.qty, 0), coalesce(s.min_quantity, 0), coalesce(s.avg_unit_cost, 0),
         round(greatest(coalesce(m.qty, 0), 0) * coalesce(s.avg_unit_cost, 0)),
         coalesce(m.qty, 0) <= coalesce(s.min_quantity, 0) and coalesce(s.min_quantity, 0) > 0
    from public.ingredients i
    left join (select sm.ingredient_id, sum(sm.quantity) as qty from public.stock_movements sm
                where sm.branch_id = p_branch group by sm.ingredient_id) m on m.ingredient_id = i.id
    left join public.ingredient_stock s on s.ingredient_id = i.id and s.branch_id = p_branch
   where i.organization_id = (select organization_id from public.branches where id = p_branch)
     and (i.active or coalesce(m.qty, 0) <> 0)
   order by (coalesce(m.qty, 0) <= coalesce(s.min_quantity, 0) and coalesce(s.min_quantity, 0) > 0) desc, i.name;
end $$;

-- Coût de revient théorique des plats d'un établissement (fiche en vigueur ×
-- coût moyen) et marge sur le prix de base.
create or replace function public.recipe_costs(p_branch uuid)
returns table (variant_id uuid, item_name text, variant_name text, cost_minor numeric, price_minor bigint, has_recipe boolean)
language plpgsql stable security definer set search_path = '' as $$
begin
  perform app_private.assert_branch_perm(p_branch, 'finance.read');
  return query
  select v.id, mi.name, v.name,
         (select round(sum(app_private.convert_qty(rl.quantity, rl.unit_code, ing.unit_code) * (1 + rl.waste_percent / 100)
                       / rv.yield_quantity * app_private.avg_cost(p_branch, rl.ingredient_id)))
            from public.recipe_versions rv
            join public.recipe_lines rl on rl.version_id = rv.id
            join public.ingredients ing on ing.id = rl.ingredient_id
           where rv.variant_id = v.id and rv.valid_to is null),
         (select p.amount_minor from public.prices p
           where p.branch_id = p_branch and p.variant_id = v.id and p.channel = 'default' and p.valid_to is null),
         exists (select 1 from public.recipe_versions rv where rv.variant_id = v.id and rv.valid_to is null)
    from public.item_variants v
    join public.menu_items mi on mi.id = v.item_id
    join public.menu_item_branches mib on mib.item_id = mi.id and mib.branch_id = p_branch
   where v.active and mi.active
   order by mi.name, v.sort_order, v.name;
end $$;

revoke all on function public.record_stock_movement(uuid, uuid, uuid, text, numeric, text, numeric, text, text, date, uuid),
  public.transfer_stock(uuid, uuid, uuid, numeric, text, text, uuid), public.record_production(uuid, uuid, uuid, numeric, uuid),
  public.save_recipe(uuid, uuid, uuid, numeric, jsonb, text), public.set_stock_threshold(uuid, uuid, numeric),
  public.start_inventory(uuid, uuid), public.save_inventory_line(uuid, uuid, numeric, text),
  public.validate_inventory(uuid, text), public.stock_overview(uuid), public.recipe_costs(uuid) from public, anon;
grant execute on function public.record_stock_movement(uuid, uuid, uuid, text, numeric, text, numeric, text, text, date, uuid),
  public.transfer_stock(uuid, uuid, uuid, numeric, text, text, uuid), public.record_production(uuid, uuid, uuid, numeric, uuid),
  public.save_recipe(uuid, uuid, uuid, numeric, jsonb, text), public.set_stock_threshold(uuid, uuid, numeric),
  public.start_inventory(uuid, uuid), public.save_inventory_line(uuid, uuid, numeric, text),
  public.validate_inventory(uuid, text), public.stock_overview(uuid), public.recipe_costs(uuid) to authenticated;

revoke all on all functions in schema app_private from public, anon, authenticated;
grant execute on function app_private.member_org_ids(), app_private.member_branch_ids(),
  app_private.org_ids_with(text), app_private.branch_ids_with(text),
  app_private.full_access_org_ids(), app_private.assigned_branch_ids() to authenticated;
