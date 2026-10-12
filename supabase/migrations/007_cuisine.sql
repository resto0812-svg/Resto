-- =============================================================================
-- Resto — 007_cuisine
-- Écrans de préparation (KDS) : postes (Cuisine, Bar…), répartition des
-- articles par type au moment de l'envoi, suivi par ligne
-- (envoyé → en préparation → prêt → servi), mises à jour en direct.
-- À coller APRÈS 006, puis supabase/tests/007_cuisine_tests.sql.
-- =============================================================================

create table public.prep_stations (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations (id) on delete restrict,
  branch_id uuid not null,
  name text not null check (length(btrim(name)) between 1 and 60),
  -- Types d'articles préparés ici : food, drink, other
  kinds text[] not null check (cardinality(kinds) between 1 and 3 and kinds <@ array['food', 'drink', 'other']),
  sort_order integer not null default 0,
  active boolean not null default true,
  created_at timestamptz not null default now(),
  unique (organization_id, id),
  unique (branch_id, name),
  foreign key (organization_id, branch_id) references public.branches (organization_id, id) on delete restrict
);

-- Postes par défaut : « Cuisine » (plats et autres) et « Bar » (boissons).
insert into public.prep_stations (organization_id, branch_id, name, kinds, sort_order)
select b.organization_id, b.id, s.name, s.kinds, s.sort_order
  from public.branches b
 cross join (values ('Cuisine', array['food', 'other'], 0), ('Bar', array['drink'], 1)) s (name, kinds, sort_order)
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
  return null;
end $$;

alter table public.order_items add column if not exists station_id uuid;
alter table public.order_items add column if not exists ready_at timestamptz;
alter table public.order_items add column if not exists served_at timestamptz;
alter table public.order_items
  add constraint order_items_station_fk foreign key (organization_id, station_id)
  references public.prep_stations (organization_id, id) on delete restrict;
create index order_items_kitchen_idx on public.order_items (branch_id, prep_status, sent_at)
  where prep_status in ('sent', 'preparing', 'ready');

create trigger prep_stations_audit after insert or update or delete on public.prep_stations
  for each row execute function app_private.audit_row();
alter table public.prep_stations enable row level security;
revoke all on public.prep_stations from anon, authenticated;
grant select, insert (id, organization_id, branch_id, name, kinds, sort_order, active),
  update (name, kinds, sort_order, active) on public.prep_stations to authenticated;
create policy prep_stations_read on public.prep_stations for select to authenticated
  using (branch_id in (select app_private.member_branch_ids()));
create policy prep_stations_insert on public.prep_stations for insert to authenticated
  with check (branch_id in (select app_private.branch_ids_with('branches.manage')));
create policy prep_stations_update on public.prep_stations for update to authenticated
  using (branch_id in (select app_private.branch_ids_with('branches.manage')))
  with check (branch_id in (select app_private.branch_ids_with('branches.manage')));

-- Mises à jour en direct des écrans (Realtime respecte la RLS).
do $$
begin
  if exists (select 1 from pg_publication where pubname = 'supabase_realtime') then
    if not exists (select 1 from pg_publication_tables
                    where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'order_items') then
      execute 'alter publication supabase_realtime add table public.order_items';
    end if;
    if not exists (select 1 from pg_publication_tables
                    where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'orders') then
      execute 'alter publication supabase_realtime add table public.orders';
    end if;
  end if;
end $$;

-- Envoi en cuisine : chaque ligne part vers le premier poste actif qui prépare
-- ce type d'article (aucun poste : visible sur tous les écrans).
create or replace function public.send_order(p_order uuid)
returns integer language plpgsql security definer set search_path = '' as $$
declare
  v_order public.orders;
  v_count integer;
begin
  v_order := app_private.lock_open_order(p_order, 'orders.write');
  update public.order_items i
     set prep_status = 'sent', sent_at = now(),
         station_id = (select s.id from public.prep_stations s
                         join public.menu_items mi on mi.id = i.item_id
                        where s.branch_id = i.branch_id and s.active and mi.kind = any (s.kinds)
                        order by s.sort_order, s.name limit 1)
   where i.order_id = p_order and i.prep_status = 'pending';
  get diagnostics v_count = row_count;
  if v_count > 0 then
    update public.orders set version = version + 1 where id = p_order;
    perform app_private.log_order(v_order, 'sent', null, jsonb_build_object('lines', v_count));
  end if;
  return v_count;
end $$;

-- Avancement de la préparation. Cuisine (kitchen.operate) : en préparation,
-- prêt ; service (orders.write ou kitchen.operate) : servi. Possible aussi sur
-- une commande déjà payée (à emporter payé d'avance), jamais sur une annulée.
create or replace function public.set_prep_status(p_items uuid[], p_status text)
returns integer language plpgsql security definer set search_path = '' as $$
declare
  r record;
  v_count integer := 0;
  v_perm_ok boolean;
begin
  if coalesce(p_status, '') not in ('preparing', 'ready', 'served') then
    perform app_private.fail('resto.invalid_status');
  end if;
  for r in
    select i.id, i.prep_status, i.branch_id, o.id as order_id, o.status as order_status
      from public.order_items i join public.orders o on o.id = i.order_id
     where i.id = any (coalesce(p_items, '{}'))
     order by i.id
       for update of i
  loop
    v_perm_ok := exists (select 1 from app_private.branch_ids_with('kitchen.operate') x where x = r.branch_id)
      or (p_status = 'served' and exists (select 1 from app_private.branch_ids_with('orders.write') x where x = r.branch_id));
    if not v_perm_ok then raise exception 'resto.forbidden' using errcode = '42501'; end if;
    if r.order_status = 'cancelled'
       or not ((r.prep_status = 'sent' and p_status in ('preparing', 'ready'))
            or (r.prep_status = 'preparing' and p_status in ('ready'))
            or (r.prep_status = 'ready' and p_status in ('served', 'preparing'))) then
      perform app_private.fail('resto.invalid_status');
    end if;
    update public.order_items
       set prep_status = p_status,
           ready_at = case when p_status = 'ready' then now() when p_status = 'preparing' then null else ready_at end,
           served_at = case when p_status = 'served' then now() else served_at end
     where id = r.id;
    insert into public.order_events (organization_id, branch_id, order_id, order_item_id, event, detail, actor_id)
    select o.organization_id, o.branch_id, o.id, r.id, 'prep_status', jsonb_build_object('status', p_status), auth.uid()
      from public.orders o where o.id = r.order_id;
    v_count := v_count + 1;
  end loop;
  if v_count = 0 then perform app_private.fail('resto.invalid_status'); end if;
  return v_count;
end $$;

revoke all on function public.set_prep_status(uuid[], text) from public, anon;
grant execute on function public.set_prep_status(uuid[], text) to authenticated;

revoke all on all functions in schema app_private from public, anon, authenticated;
grant execute on function app_private.member_org_ids(), app_private.member_branch_ids(),
  app_private.org_ids_with(text), app_private.branch_ids_with(text),
  app_private.full_access_org_ids(), app_private.assigned_branch_ids() to authenticated;
