-- =============================================================================
-- Resto — 021_panier_multi_clients
-- Lot 3 — Panier multi-restaurants et fiche client par restaurant :
--   * une validation unique crée une commande indépendante par restaurant
--     (numéro, statut, frais, suivi propres), reliées par un même
--     « passage en caisse » ; tout ou rien (une transaction) et rejouable ;
--   * fiche client propre à chaque restaurant (nom, téléphone, allergies si
--     le client accepte de les partager, nombre de commandes, dépenses, notes
--     de l'équipe) : un restaurant ne voit jamais l'activité du client
--     chez un autre.
-- À coller APRÈS 020, puis supabase/tests/021_panier_multi_clients_tests.sql.
-- =============================================================================

alter table public.orders add column if not exists checkout_id uuid;
create index if not exists orders_checkout_idx on public.orders (checkout_id) where checkout_id is not null;

-- -----------------------------------------------------------------------------
-- 1. Passage en caisse multi-restaurants
-- -----------------------------------------------------------------------------
-- p_orders : [{ "branch_id", "channel", "items": [...], "table_token"?, "note"?, "client_id" }]
create or replace function public.place_checkout(
  p_checkout uuid, p_orders jsonb, p_contact_phone text default null, p_customer_name text default null,
  p_delivery_address text default null, p_delivery_instructions text default null, p_scheduled_for timestamptz default null)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare
  v_uid uuid := auth.uid();
  v_part jsonb;
  v_res jsonb;
  v_out jsonb := '[]'::jsonb;
  v_existing public.orders;
begin
  if v_uid is null then raise exception 'resto.not_authenticated' using errcode = '42501'; end if;
  if p_checkout is null or jsonb_typeof(coalesce(p_orders, 'null'::jsonb)) <> 'array'
     or jsonb_array_length(p_orders) not between 1 and 10 then
    perform app_private.fail('resto.invalid_order');
  end if;
  -- Rejoué : on renvoie les commandes déjà créées.
  if exists (select 1 from public.orders where checkout_id = p_checkout and customer_user_id = v_uid) then
    return (select jsonb_agg(jsonb_build_object('branch_id', o.branch_id, 'order_id', o.id, 'number', o.number) order by o.opened_at)
              from public.orders o where o.checkout_id = p_checkout and o.customer_user_id = v_uid);
  end if;
  if (select count(distinct x ->> 'branch_id') from jsonb_array_elements(p_orders) x) <> jsonb_array_length(p_orders) then
    perform app_private.fail('resto.invalid_order');
  end if;
  for v_part in select * from jsonb_array_elements(p_orders) loop
    v_res := public.place_online_order(
      (v_part ->> 'branch_id')::uuid, v_part ->> 'channel', v_part -> 'items', v_part ->> 'table_token', p_scheduled_for,
      case when v_part ->> 'channel' = 'delivery' then p_delivery_address end,
      case when v_part ->> 'channel' = 'delivery' then p_delivery_instructions end,
      p_contact_phone, p_customer_name, v_part ->> 'note', (v_part ->> 'client_id')::uuid);
    update public.orders set checkout_id = p_checkout
     where id = (v_res ->> 'order_id')::uuid and customer_user_id = v_uid
     returning * into v_existing;
    v_out := v_out || jsonb_build_array(jsonb_build_object(
      'branch_id', v_existing.branch_id, 'order_id', v_existing.id, 'number', v_existing.number));
  end loop;
  return v_out;
exception
  when invalid_text_representation then perform app_private.fail('resto.invalid_order');
end $$;

-- -----------------------------------------------------------------------------
-- 2. Fiche client propre à chaque restaurant (organisation)
-- -----------------------------------------------------------------------------
create table if not exists public.restaurant_customers (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations (id) on delete cascade,
  user_id uuid not null references auth.users (id) on delete cascade,
  display_name text check (length(display_name) <= 120),
  phone text check (length(phone) <= 32),
  allergies text[] not null default '{}',
  first_order_at timestamptz not null default now(),
  last_order_at timestamptz not null default now(),
  orders_count integer not null default 0,
  total_spent_minor bigint not null default 0,
  currency char(3),
  notes text check (length(notes) <= 1000),
  updated_at timestamptz not null default now(),
  unique (organization_id, user_id)
);
create index if not exists restaurant_customers_org_idx on public.restaurant_customers (organization_id, last_order_at desc);

alter table public.restaurant_customers enable row level security;
grant select, update (notes) on public.restaurant_customers to authenticated;
drop policy if exists restaurant_customers_read on public.restaurant_customers;
drop policy if exists restaurant_customers_notes on public.restaurant_customers;
create policy restaurant_customers_read on public.restaurant_customers for select to authenticated
  using (organization_id in (select app_private.org_ids_with_any_branch('orders.read')));
create policy restaurant_customers_notes on public.restaurant_customers for update to authenticated
  using (organization_id in (select app_private.org_ids_with_any_branch('customers.manage')))
  with check (organization_id in (select app_private.org_ids_with_any_branch('customers.manage')));

-- Création ou mise à jour à chaque commande d'un client ; totaux recalculés à la clôture.
create or replace function app_private.sync_restaurant_customer()
returns trigger language plpgsql security definer set search_path = '' as $$
declare
  v_profile public.customer_profiles;
begin
  if new.customer_user_id is null then return new; end if;
  select * into v_profile from public.customer_profiles where user_id = new.customer_user_id;
  insert into public.restaurant_customers as rc (organization_id, user_id, display_name, phone, allergies,
                                                 first_order_at, last_order_at, currency)
  values (new.organization_id, new.customer_user_id,
          coalesce(nullif(btrim(new.customer_name), ''), v_profile.full_name, app_private.display_author(new.customer_user_id)),
          coalesce(nullif(btrim(new.contact_phone), ''), v_profile.phone),
          case when coalesce(v_profile.share_allergies, true) then coalesce(v_profile.allergies, '{}') else '{}' end,
          new.opened_at, new.opened_at, new.currency)
  on conflict (organization_id, user_id) do update
     set display_name = coalesce(excluded.display_name, rc.display_name),
         phone = coalesce(excluded.phone, rc.phone),
         allergies = excluded.allergies,
         last_order_at = greatest(rc.last_order_at, excluded.last_order_at),
         orders_count = (select count(*) from public.orders o
                          where o.organization_id = new.organization_id and o.customer_user_id = new.customer_user_id
                            and o.status = 'closed'),
         total_spent_minor = (select coalesce(sum(o.total_minor), 0) from public.orders o
                               where o.organization_id = new.organization_id and o.customer_user_id = new.customer_user_id
                                 and o.status = 'closed'),
         updated_at = now();
  return new;
end $$;
drop trigger if exists orders_sync_customer on public.orders;
create trigger orders_sync_customer after insert or update of status, customer_user_id on public.orders
  for each row execute function app_private.sync_restaurant_customer();

-- Clients déjà venus : fiches créées à partir des commandes existantes.
insert into public.restaurant_customers (organization_id, user_id, display_name, phone, first_order_at, last_order_at,
                                         orders_count, total_spent_minor, currency)
select o.organization_id, o.customer_user_id,
       (array_agg(o.customer_name order by o.opened_at desc) filter (where o.customer_name is not null))[1],
       (array_agg(o.contact_phone order by o.opened_at desc) filter (where o.contact_phone is not null))[1],
       min(o.opened_at), max(o.opened_at),
       count(*) filter (where o.status = 'closed'),
       coalesce(sum(o.total_minor) filter (where o.status = 'closed'), 0),
       (array_agg(o.currency))[1]
  from public.orders o
 where o.customer_user_id is not null
 group by o.organization_id, o.customer_user_id
on conflict (organization_id, user_id) do nothing;

-- Suivi du client : toutes ses commandes d'un même passage en caisse.
create or replace function public.my_checkout(p_checkout uuid)
returns jsonb language sql stable security definer set search_path = '' as $$
  select coalesce(jsonb_agg(jsonb_build_object(
    'order_id', o.id, 'number', o.number, 'branch_id', o.branch_id, 'brand_name', br.name, 'channel', o.channel,
    'status', o.status, 'acceptance', o.acceptance, 'total_minor', o.total_minor, 'currency', o.currency)
    order by o.opened_at), '[]'::jsonb)
    from public.orders o join public.brands br on br.id = o.brand_id
   where o.checkout_id = p_checkout and o.customer_user_id = auth.uid();
$$;

revoke all on function public.place_checkout(uuid, jsonb, text, text, text, text, timestamptz), public.my_checkout(uuid)
  from public, anon;
grant execute on function public.place_checkout(uuid, jsonb, text, text, text, text, timestamptz), public.my_checkout(uuid)
  to authenticated;

revoke all on all functions in schema app_private from public, anon, authenticated;
grant execute on function app_private.member_org_ids(), app_private.member_branch_ids(),
  app_private.org_ids_with(text), app_private.branch_ids_with(text),
  app_private.full_access_org_ids(), app_private.assigned_branch_ids(),
  app_private.org_ids_with_any_branch(text) to authenticated;
