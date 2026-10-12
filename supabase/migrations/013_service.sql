-- =============================================================================
-- Resto — 013_service
-- Refonte du service (Commandes + Cuisine + Salle) :
--   • plan de salle : forme et position de chaque table ;
--   • commande complète dès sa création (type, client, téléphone, adresse,
--     heure souhaitée, origine : serveur ou téléphone) ;
--   • articles « à suivre » (dessert…) lancés plus tard en cuisine ;
--   • heure promise au client, temps de préparation visé par établissement ;
--   • suivi « prête » / « servie » de la commande (heures notées, y compris
--     pour une vente à emporter payée d'avance) ;
--   • changement de table ;
--   • installation d'une réservation à sa table (commande ouverte avec le nom
--     du client), réservation terminée et table libérée à la fin du repas.
-- À coller APRÈS 012, puis supabase/tests/013_service_tests.sql.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Réglages de service par établissement
-- -----------------------------------------------------------------------------
alter table public.branches
  add column if not exists target_prep_minutes smallint not null default 15 check (target_prep_minutes between 1 and 240),
  add column if not exists pay_first_takeaway boolean not null default true;
grant insert (target_prep_minutes, pay_first_takeaway), update (target_prep_minutes, pay_first_takeaway)
  on public.branches to authenticated;

-- -----------------------------------------------------------------------------
-- Plan de salle : forme et position (grille de 60 × 60 cases par zone)
-- -----------------------------------------------------------------------------
alter table public.dining_tables
  add column if not exists shape text not null default 'square' check (shape in ('square', 'round', 'rect')),
  add column if not exists pos_x smallint check (pos_x between 0 and 59),
  add column if not exists pos_y smallint check (pos_y between 0 and 59);
grant insert (shape, pos_x, pos_y), update (shape, pos_x, pos_y) on public.dining_tables to authenticated;

-- -----------------------------------------------------------------------------
-- Commandes : heure promise, prête, servie ; réservation d'origine
-- -----------------------------------------------------------------------------
alter table public.orders
  add column if not exists promised_at timestamptz,
  add column if not exists ready_at timestamptz,
  add column if not exists served_at timestamptz,
  add column if not exists reservation_id uuid;
do $$
begin
  if not exists (select 1 from pg_constraint where conname = 'orders_reservation_fk') then
    alter table public.orders add constraint orders_reservation_fk
      foreign key (organization_id, reservation_id) references public.reservations (organization_id, id) on delete restrict;
  end if;
end $$;
create index if not exists orders_reservation_idx on public.orders (reservation_id) where reservation_id is not null;
create index if not exists orders_to_serve_idx on public.orders (branch_id, closed_at) where status = 'closed' and served_at is null;

-- Commandes déjà terminées : considérées servies (historique).
update public.orders set ready_at = coalesce(ready_at, closed_at, cancelled_at, updated_at),
                         served_at = coalesce(served_at, closed_at, cancelled_at, updated_at)
 where status <> 'open' and served_at is null;

-- Article « à suivre » : reste en attente à l'envoi, part avec « Lancer la suite ».
alter table public.order_items add column if not exists held boolean not null default false;

alter table public.order_events drop constraint if exists order_events_event_check;
alter table public.order_events add constraint order_events_event_check check (event in ('opened', 'item_added',
  'item_updated', 'item_removed', 'sent', 'item_cancelled', 'cancelled', 'closed', 'prep_status', 'payment',
  'payment_voided', 'refund', 'details_updated', 'table_moved', 'accepted', 'fired', 'held', 'promised', 'seated'));

-- -----------------------------------------------------------------------------
-- Heures « prête » et « servie » tenues à jour à chaque changement de ligne
-- -----------------------------------------------------------------------------
create or replace function app_private.refresh_service_times(p_order uuid)
returns void language plpgsql volatile security definer set search_path = '' as $$
declare
  v_active integer;
  v_done integer;
  v_served integer;
  v_ready timestamptz;
  v_served_at timestamptz;
  v public.orders;
begin
  select * into v from public.orders where id = p_order;
  if v.id is null then return; end if;
  select count(*) filter (where prep_status <> 'cancelled'),
         count(*) filter (where prep_status in ('ready', 'served')),
         count(*) filter (where prep_status = 'served')
    into v_active, v_done, v_served
    from public.order_items where order_id = p_order;
  v_ready := case when v_active > 0 and v_done = v_active then coalesce(v.ready_at, now()) end;
  v_served_at := case when v_active > 0 and v_served = v_active then coalesce(v.served_at, now()) end;
  if v_ready is distinct from v.ready_at or v_served_at is distinct from v.served_at then
    update public.orders set ready_at = v_ready, served_at = v_served_at where id = p_order;
  end if;
end $$;

create or replace function app_private.on_order_item_changed()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  perform app_private.refresh_service_times(coalesce(new.order_id, old.order_id));
  return null;
end $$;
drop trigger if exists order_items_service_times on public.order_items;
create trigger order_items_service_times after insert or delete or update of prep_status on public.order_items
  for each row execute function app_private.on_order_item_changed();

-- -----------------------------------------------------------------------------
-- Envoi en cuisine (remplace 007) : les articles « à suivre » attendent.
-- -----------------------------------------------------------------------------
create or replace function public.send_order(p_order uuid)
returns integer language plpgsql security definer set search_path = '' as $$
declare
  v_order public.orders;
  v_count integer;
begin
  v_order := app_private.lock_open_order(p_order, 'orders.write');
  update public.order_items i
     set prep_status = 'sent', sent_at = now(), held = false,
         station_id = (select s.id from public.prep_stations s
                         join public.menu_items mi on mi.id = i.item_id
                        where s.branch_id = i.branch_id and s.active and mi.kind = any (s.kinds)
                        order by s.sort_order, s.name limit 1)
   where i.order_id = p_order and i.prep_status = 'pending' and not i.held;
  get diagnostics v_count = row_count;
  if v_count > 0 then
    update public.orders set version = version + 1 where id = p_order;
    perform app_private.log_order(v_order, 'sent', null, jsonb_build_object('lines', v_count));
  end if;
  return v_count;
end $$;

-- Met un article en attente (« à suivre ») ou le libère, tant qu'il n'est pas parti.
create or replace function public.set_item_held(p_item uuid, p_held boolean)
returns void language plpgsql security definer set search_path = '' as $$
declare
  v_item public.order_items;
  v_order public.orders;
begin
  select * into v_item from public.order_items where id = p_item;
  if v_item.id is null then raise exception 'resto.forbidden' using errcode = '42501'; end if;
  v_order := app_private.lock_open_order(v_item.order_id, 'orders.write');
  select * into v_item from public.order_items where id = p_item for update;
  if v_item.prep_status <> 'pending' then perform app_private.fail('resto.item_already_sent'); end if;
  update public.order_items set held = coalesce(p_held, false) where id = p_item;
  perform app_private.log_order(v_order, 'held', p_item, jsonb_build_object('held', coalesce(p_held, false)));
end $$;

-- « Lancer la suite » : envoie en cuisine les articles mis en attente.
create or replace function public.fire_held(p_order uuid)
returns integer language plpgsql security definer set search_path = '' as $$
declare
  v_order public.orders;
  v_count integer;
begin
  v_order := app_private.lock_open_order(p_order, 'orders.write');
  update public.order_items set held = false where order_id = p_order and prep_status = 'pending' and held;
  get diagnostics v_count = row_count;
  if v_count = 0 then perform app_private.fail('resto.invalid_status'); end if;
  perform app_private.log_order(v_order, 'fired', null, jsonb_build_object('lines', v_count));
  return public.send_order(p_order);
end $$;

-- -----------------------------------------------------------------------------
-- Création d'une commande complète (serveur, comptoir, téléphone)
-- -----------------------------------------------------------------------------
create or replace function public.create_order(
  p_branch uuid, p_channel text, p_table uuid default null, p_guests smallint default null,
  p_source text default 'staff', p_customer_name text default null, p_contact_phone text default null,
  p_delivery_address text default null, p_delivery_instructions text default null,
  p_scheduled_for timestamptz default null, p_note text default null, p_client_id uuid default null)
returns uuid language plpgsql security definer set search_path = '' as $$
declare
  v_id uuid;
  v_order public.orders;
  v_fee bigint;
begin
  perform app_private.assert_branch_perm(p_branch, 'orders.write');
  if coalesce(p_source, '') not in ('staff', 'phone') then perform app_private.fail('resto.invalid_order'); end if;
  if p_channel = 'delivery' and length(btrim(coalesce(p_delivery_address, ''))) < 3 then
    perform app_private.fail('resto.address_required');
  end if;
  if p_scheduled_for is not null and (p_scheduled_for < now() - interval '1 hour' or p_scheduled_for > now() + interval '30 days') then
    perform app_private.fail('resto.invalid_order');
  end if;
  v_id := public.open_order(p_branch, p_channel, p_table, p_guests, p_note, p_client_id);
  select * into v_order from public.orders where id = v_id for update;
  -- Commande déjà existante (appel rejoué ou table déjà occupée) : inchangée.
  -- now() est l'heure de début de la transaction : égale seulement si créée ici.
  if v_order.opened_at <> now() then return v_id; end if;
  select delivery_fee_minor into v_fee from public.branches where id = p_branch;
  update public.orders
     set source = p_source,
         customer_name = nullif(btrim(p_customer_name), ''),
         contact_phone = nullif(btrim(p_contact_phone), ''),
         delivery_address = nullif(btrim(p_delivery_address), ''),
         delivery_instructions = nullif(btrim(p_delivery_instructions), ''),
         scheduled_for = p_scheduled_for,
         delivery_fee_minor = case when p_channel = 'delivery' then v_fee else 0 end
   where id = v_id;
  perform app_private.recompute_order(v_id);
  return v_id;
end $$;

-- Informations de la commande : couverts, client, adresse, heure, note, frais de livraison.
create or replace function public.update_order_details(
  p_order uuid, p_guests smallint default null, p_customer_name text default null, p_contact_phone text default null,
  p_delivery_address text default null, p_delivery_instructions text default null,
  p_scheduled_for timestamptz default null, p_note text default null, p_delivery_fee bigint default null)
returns void language plpgsql security definer set search_path = '' as $$
declare v_order public.orders;
begin
  v_order := app_private.lock_open_order(p_order, 'orders.write');
  if p_guests is not null and p_guests not between 1 and 200 then perform app_private.fail('resto.invalid_order'); end if;
  if v_order.channel = 'delivery' and length(btrim(coalesce(p_delivery_address, ''))) < 3 then
    perform app_private.fail('resto.address_required');
  end if;
  if p_delivery_fee is not null and (p_delivery_fee < 0 or v_order.channel <> 'delivery') then
    perform app_private.fail('resto.invalid_amount');
  end if;
  update public.orders
     set guests = p_guests,
         customer_name = nullif(btrim(p_customer_name), ''),
         contact_phone = nullif(btrim(p_contact_phone), ''),
         delivery_address = case when channel = 'delivery' then nullif(btrim(p_delivery_address), '') end,
         delivery_instructions = case when channel = 'delivery' then nullif(btrim(p_delivery_instructions), '') end,
         scheduled_for = p_scheduled_for,
         note = nullif(btrim(p_note), ''),
         delivery_fee_minor = coalesce(p_delivery_fee, delivery_fee_minor)
   where id = p_order;
  perform app_private.recompute_order(p_order);
  perform app_private.assert_not_overpaid(p_order);
  perform app_private.log_order(v_order, 'details_updated', null, '{}'::jsonb);
end $$;

-- Changement de table (sur place) vers une table libre.
create or replace function public.move_order_table(p_order uuid, p_table uuid)
returns void language plpgsql security definer set search_path = '' as $$
declare v_order public.orders;
begin
  v_order := app_private.lock_open_order(p_order, 'orders.write');
  if v_order.channel <> 'dine_in' then perform app_private.fail('resto.invalid_order'); end if;
  if not exists (select 1 from public.dining_tables where id = p_table and branch_id = v_order.branch_id and active) then
    perform app_private.fail('resto.invalid_table');
  end if;
  if p_table = v_order.table_id then return; end if;
  perform pg_advisory_xact_lock(hashtext('resto.table.' || p_table::text));
  if exists (select 1 from public.orders where table_id = p_table and status = 'open') then
    perform app_private.fail('resto.table_busy');
  end if;
  update public.orders set table_id = p_table, version = version + 1 where id = p_order;
  perform app_private.log_order(v_order, 'table_moved', null, jsonb_build_object('from', v_order.table_id, 'to', p_table));
end $$;

-- Heure promise au client (délai annoncé), modifiable par l'équipe.
create or replace function public.set_promised_time(p_order uuid, p_minutes integer)
returns void language plpgsql security definer set search_path = '' as $$
declare v_order public.orders;
begin
  v_order := app_private.lock_open_order(p_order, 'orders.write');
  if coalesce(p_minutes, 0) not between 1 and 600 then perform app_private.fail('resto.invalid_order'); end if;
  update public.orders set promised_at = now() + make_interval(mins => p_minutes), version = version + 1 where id = p_order;
  perform app_private.log_order(v_order, 'promised', null, jsonb_build_object('minutes', p_minutes));
end $$;

-- Acceptation d'une commande client (remplace 010) : délai annoncé au client.
drop function if exists public.accept_online_order(uuid);
create or replace function public.accept_online_order(p_order uuid, p_prep_minutes integer default null)
returns void language plpgsql security definer set search_path = '' as $$
declare
  v_order public.orders;
  v_target smallint;
begin
  v_order := app_private.lock_open_order(p_order, 'orders.write');
  if v_order.acceptance <> 'pending' then perform app_private.fail('resto.invalid_status'); end if;
  if p_prep_minutes is not null and p_prep_minutes not between 1 and 600 then perform app_private.fail('resto.invalid_order'); end if;
  select target_prep_minutes into v_target from public.branches where id = v_order.branch_id;
  update public.orders
     set acceptance = 'accepted',
         promised_at = case
           when scheduled_for is not null and scheduled_for > now() then scheduled_for
           else now() + make_interval(mins => coalesce(p_prep_minutes, v_target)) end
   where id = p_order;
  perform app_private.log_order(v_order, 'accepted', null, jsonb_build_object('minutes', p_prep_minutes));
  perform public.send_order(p_order);
end $$;

-- -----------------------------------------------------------------------------
-- Réservations ↔ commandes
-- -----------------------------------------------------------------------------

-- Les clients arrivent : réservation « installée », commande ouverte sur sa
-- table avec le nombre de personnes et le nom du client. Rejouable.
create or replace function public.seat_reservation(p_reservation uuid)
returns uuid language plpgsql security definer set search_path = '' as $$
declare
  v_res public.reservations;
  v_table uuid;
  v_id uuid;
begin
  select * into v_res from public.reservations where id = p_reservation for update;
  perform app_private.assert_branch_perm(v_res.branch_id, 'reservations.manage');
  perform app_private.assert_branch_perm(v_res.branch_id, 'orders.write');
  if v_res.status = 'seated' then
    select id into v_id from public.orders where reservation_id = p_reservation and status = 'open';
    if v_id is not null then return v_id; end if;
  elsif v_res.status <> 'confirmed' then
    perform app_private.fail('resto.invalid_status');
  end if;
  select rt.table_id into v_table
    from public.reservation_tables rt join public.dining_tables t on t.id = rt.table_id
   where rt.reservation_id = p_reservation
   order by t.label limit 1;
  if v_table is null then perform app_private.fail('resto.tables_required'); end if;
  perform pg_advisory_xact_lock(hashtext('resto.table.' || v_table::text));
  if exists (select 1 from public.orders where table_id = v_table and status = 'open') then
    perform app_private.fail('resto.table_busy');
  end if;
  update public.reservations set status = 'seated', decided_by = auth.uid() where id = p_reservation;
  update public.reservation_tables set active = true where reservation_id = p_reservation;
  v_id := public.open_order(v_res.branch_id, 'dine_in', v_table, v_res.party_size, v_res.note, null);
  update public.orders set reservation_id = p_reservation, customer_name = v_res.customer_name,
         contact_phone = v_res.contact_phone, customer_user_id = v_res.customer_user_id
   where id = v_id;
  perform app_private.log_order((select o from public.orders o where o.id = v_id), 'seated', null,
    jsonb_build_object('reservation_id', p_reservation));
  return v_id;
end $$;

-- Fin du repas (commande payée ou annulée) : réservation terminée et table
-- libérée pour la suite du créneau.
create or replace function app_private.on_order_finished()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  if new.reservation_id is not null and new.status in ('closed', 'cancelled') and old.status = 'open' then
    update public.reservations set status = 'completed' where id = new.reservation_id and status = 'seated';
    update public.reservation_tables
       set period = tstzrange(lower(period), greatest(now(), lower(period) + interval '1 minute'), '[)')
     where reservation_id = new.reservation_id and upper(period) > now();
  end if;
  return null;
end $$;
drop trigger if exists orders_finish_reservation on public.orders;
create trigger orders_finish_reservation after update of status on public.orders
  for each row execute function app_private.on_order_finished();

-- -----------------------------------------------------------------------------
-- Droits
-- -----------------------------------------------------------------------------
revoke all on function public.set_item_held(uuid, boolean), public.fire_held(uuid),
  public.create_order(uuid, text, uuid, smallint, text, text, text, text, text, timestamptz, text, uuid),
  public.update_order_details(uuid, smallint, text, text, text, text, timestamptz, text, bigint),
  public.move_order_table(uuid, uuid), public.set_promised_time(uuid, integer),
  public.accept_online_order(uuid, integer), public.seat_reservation(uuid) from public, anon;
grant execute on function public.set_item_held(uuid, boolean), public.fire_held(uuid),
  public.create_order(uuid, text, uuid, smallint, text, text, text, text, text, timestamptz, text, uuid),
  public.update_order_details(uuid, smallint, text, text, text, text, timestamptz, text, bigint),
  public.move_order_table(uuid, uuid), public.set_promised_time(uuid, integer),
  public.accept_online_order(uuid, integer), public.seat_reservation(uuid) to authenticated;

revoke all on all functions in schema app_private from public, anon, authenticated;
grant execute on function app_private.member_org_ids(), app_private.member_branch_ids(),
  app_private.org_ids_with(text), app_private.branch_ids_with(text),
  app_private.full_access_org_ids(), app_private.assigned_branch_ids(),
  app_private.org_ids_with_any_branch(text) to authenticated;
