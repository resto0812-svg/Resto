-- =============================================================================
-- Resto — 011_reservations
-- Réservations de tables : demandes des clients, saisie par l'équipe,
-- confirmation avec attribution de tables, arrivée, absence, annulation.
-- Deux réservations actives ne peuvent jamais occuper la même table au même
-- moment : contrainte d'exclusion en base (et non un simple contrôle).
-- À coller APRÈS 010, puis supabase/tests/011_reservations_tests.sql.
-- =============================================================================

create extension if not exists btree_gist with schema extensions;

alter table public.branches
  add column if not exists accepts_reservations boolean not null default false,
  add column if not exists reservation_minutes smallint not null default 90 check (reservation_minutes between 15 and 480),
  add column if not exists max_party_size smallint not null default 12 check (max_party_size between 1 and 200);
grant insert (accepts_reservations, reservation_minutes, max_party_size),
  update (accepts_reservations, reservation_minutes, max_party_size) on public.branches to authenticated;

create table public.reservations (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null,
  branch_id uuid not null,
  customer_user_id uuid references auth.users (id) on delete set null,
  customer_name text not null check (length(btrim(customer_name)) between 1 and 120),
  contact_phone text check (length(contact_phone) <= 40),
  party_size smallint not null check (party_size between 1 and 200),
  starts_at timestamptz not null,
  ends_at timestamptz not null,
  status text not null default 'requested'
    check (status in ('requested', 'confirmed', 'seated', 'completed', 'cancelled', 'no_show', 'declined')),
  source text not null default 'customer' check (source in ('customer', 'staff')),
  note text check (length(note) <= 500),
  reason text check (length(reason) <= 500),
  created_by uuid references auth.users (id) on delete set null,
  decided_by uuid references auth.users (id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (organization_id, id),
  check (ends_at > starts_at),
  foreign key (organization_id, branch_id) references public.branches (organization_id, id) on delete restrict
);
create index reservations_branch_time_idx on public.reservations (branch_id, starts_at);
create index reservations_customer_idx on public.reservations (customer_user_id, starts_at desc) where customer_user_id is not null;
create trigger reservations_touch before update on public.reservations
  for each row execute function app_private.touch_updated_at();

-- Tables attribuées. « active » suit le statut (confirmée ou installée) :
-- la contrainte d'exclusion interdit tout chevauchement sur une même table.
create table public.reservation_tables (
  organization_id uuid not null,
  branch_id uuid not null,
  reservation_id uuid not null,
  table_id uuid not null,
  period tstzrange not null,
  active boolean not null default true,
  primary key (reservation_id, table_id),
  foreign key (organization_id, reservation_id) references public.reservations (organization_id, id) on delete cascade,
  foreign key (organization_id, branch_id, table_id) references public.dining_tables (organization_id, branch_id, id) on delete restrict,
  constraint reservation_tables_no_overlap exclude using gist (table_id with =, period with &&) where (active)
);

do $$
declare t text;
begin
  foreach t in array array['reservations', 'reservation_tables'] loop
    execute format('create trigger %I after insert or update or delete on public.%I
      for each row execute function app_private.audit_row()', t || '_audit', t);
    execute format('alter table public.%I enable row level security', t);
    execute format('revoke all on public.%I from anon, authenticated', t);
    execute format('grant select on public.%I to authenticated', t);
  end loop;
end $$;
create policy reservations_read on public.reservations for select to authenticated
  using (branch_id in (select app_private.branch_ids_with('reservations.manage'))
      or customer_user_id = (select auth.uid()));
create policy reservation_tables_read on public.reservation_tables for select to authenticated
  using (branch_id in (select app_private.branch_ids_with('reservations.manage')));

-- -----------------------------------------------------------------------------
-- Fonctions
-- -----------------------------------------------------------------------------

-- Attribue des tables (remplace les précédentes). Refus si une table est déjà
-- prise sur ce créneau ou si la capacité est insuffisante.
create or replace function app_private.assign_tables(p_res public.reservations, p_tables uuid[])
returns void language plpgsql volatile security definer set search_path = '' as $$
begin
  if coalesce(cardinality(p_tables), 0) = 0 then perform app_private.fail('resto.tables_required'); end if;
  if exists (select 1 from unnest(p_tables) x (id)
              where not exists (select 1 from public.dining_tables t where t.id = x.id and t.branch_id = p_res.branch_id and t.active)) then
    perform app_private.fail('resto.invalid_table');
  end if;
  if (select coalesce(sum(seats), 0) from public.dining_tables where id = any (p_tables)) < p_res.party_size then
    perform app_private.fail('resto.not_enough_seats');
  end if;
  delete from public.reservation_tables where reservation_id = p_res.id;
  begin
    insert into public.reservation_tables (organization_id, branch_id, reservation_id, table_id, period, active)
    select p_res.organization_id, p_res.branch_id, p_res.id, x, tstzrange(p_res.starts_at, p_res.ends_at, '[)'), true
      from unnest(p_tables) x group by x;
  exception when exclusion_violation then
    perform app_private.fail('resto.table_unavailable');
  end;
end $$;

-- Demande d'un client (compte obligatoire). Statut « demandée » jusqu'à la
-- réponse du restaurant.
create or replace function public.request_reservation(
  p_branch uuid, p_starts_at timestamptz, p_party_size smallint, p_name text, p_phone text, p_note text default null,
  p_client_id uuid default null)
returns uuid language plpgsql security definer set search_path = '' as $$
declare
  v_uid uuid := auth.uid();
  v_branch public.branches;
  v_id uuid;
begin
  if v_uid is null then raise exception 'resto.not_authenticated' using errcode = '42501'; end if;
  if p_client_id is not null and exists (select 1 from public.reservations where id = p_client_id and customer_user_id = v_uid) then
    return p_client_id;
  end if;
  select * into v_branch from public.branches where id = p_branch;
  if v_branch.id is null or not v_branch.is_published or v_branch.status <> 'active' or not v_branch.accepts_reservations then
    perform app_private.fail('resto.reservations_closed');
  end if;
  if coalesce(p_party_size, 0) not between 1 and v_branch.max_party_size then perform app_private.fail('resto.invalid_party_size'); end if;
  if p_starts_at is null or p_starts_at < now() + interval '15 minutes' or p_starts_at > now() + interval '90 days' then
    perform app_private.fail('resto.invalid_reservation_time');
  end if;
  if length(btrim(coalesce(p_name, ''))) = 0 or length(btrim(coalesce(p_phone, ''))) < 6 then
    perform app_private.fail('resto.invalid_reservation');
  end if;
  if (select count(*) from public.reservations where customer_user_id = v_uid and branch_id = p_branch
        and status = 'requested') >= 3 then
    perform app_private.fail('resto.rate_limited');
  end if;
  insert into public.reservations (id, organization_id, branch_id, customer_user_id, customer_name, contact_phone, party_size,
                                   starts_at, ends_at, source, note, created_by)
  values (coalesce(p_client_id, gen_random_uuid()), v_branch.organization_id, p_branch, v_uid, btrim(p_name), btrim(p_phone),
          p_party_size, p_starts_at, p_starts_at + make_interval(mins => v_branch.reservation_minutes), 'customer',
          nullif(btrim(p_note), ''), v_uid)
  returning id into v_id;
  return v_id;
end $$;

-- Réservation saisie par l'équipe (téléphone, sur place) : confirmée d'emblée.
create or replace function public.staff_create_reservation(
  p_branch uuid, p_starts_at timestamptz, p_minutes smallint, p_party_size smallint, p_name text, p_phone text,
  p_tables uuid[], p_note text default null, p_client_id uuid default null)
returns uuid language plpgsql security definer set search_path = '' as $$
declare
  v_branch public.branches;
  v_res public.reservations;
begin
  perform app_private.assert_branch_perm(p_branch, 'reservations.manage');
  if p_client_id is not null and exists (select 1 from public.reservations where id = p_client_id) then return p_client_id; end if;
  select * into v_branch from public.branches where id = p_branch;
  if coalesce(p_party_size, 0) not between 1 and 200 or p_starts_at is null
     or length(btrim(coalesce(p_name, ''))) = 0 then
    perform app_private.fail('resto.invalid_reservation');
  end if;
  insert into public.reservations (id, organization_id, branch_id, customer_name, contact_phone, party_size, starts_at, ends_at,
                                   status, source, note, created_by, decided_by)
  values (coalesce(p_client_id, gen_random_uuid()), v_branch.organization_id, p_branch, btrim(p_name), nullif(btrim(p_phone), ''),
          p_party_size, p_starts_at,
          p_starts_at + make_interval(mins => coalesce(p_minutes, v_branch.reservation_minutes)), 'confirmed', 'staff',
          nullif(btrim(p_note), ''), auth.uid(), auth.uid())
  returning * into v_res;
  perform app_private.assign_tables(v_res, p_tables);
  return v_res.id;
end $$;

-- Confirmation d'une demande avec attribution de tables.
create or replace function public.confirm_reservation(p_reservation uuid, p_tables uuid[])
returns void language plpgsql security definer set search_path = '' as $$
declare v_res public.reservations;
begin
  select * into v_res from public.reservations where id = p_reservation for update;
  perform app_private.assert_branch_perm(v_res.branch_id, 'reservations.manage');
  if v_res.status not in ('requested', 'confirmed') then perform app_private.fail('resto.invalid_status'); end if;
  perform app_private.assign_tables(v_res, p_tables);
  update public.reservations set status = 'confirmed', decided_by = auth.uid() where id = p_reservation;
end $$;

-- Changement d'état par l'équipe : declined (refus, motif), seated (arrivés),
-- completed (partis), no_show (absents), cancelled (motif).
create or replace function public.set_reservation_status(p_reservation uuid, p_status text, p_reason text default null)
returns void language plpgsql security definer set search_path = '' as $$
declare v_res public.reservations;
begin
  select * into v_res from public.reservations where id = p_reservation for update;
  perform app_private.assert_branch_perm(v_res.branch_id, 'reservations.manage');
  if not ((v_res.status = 'requested' and p_status in ('declined', 'cancelled'))
       or (v_res.status = 'confirmed' and p_status in ('seated', 'no_show', 'cancelled'))
       or (v_res.status = 'seated' and p_status = 'completed')) then
    perform app_private.fail('resto.invalid_status');
  end if;
  if p_status in ('declined', 'cancelled') and length(btrim(coalesce(p_reason, ''))) < 3 then
    perform app_private.fail('resto.reason_required');
  end if;
  update public.reservations set status = p_status, reason = coalesce(nullif(btrim(p_reason), ''), reason),
         decided_by = auth.uid() where id = p_reservation;
  update public.reservation_tables set active = p_status in ('seated', 'completed') where reservation_id = p_reservation;
end $$;

-- Le client annule sa réservation (demandée ou confirmée, avant l'heure).
create or replace function public.customer_cancel_reservation(p_reservation uuid)
returns void language plpgsql security definer set search_path = '' as $$
declare v_res public.reservations;
begin
  select * into v_res from public.reservations where id = p_reservation for update;
  if v_res.id is null or v_res.customer_user_id is distinct from auth.uid() then
    raise exception 'resto.forbidden' using errcode = '42501';
  end if;
  if v_res.status not in ('requested', 'confirmed') or v_res.starts_at <= now() then
    perform app_private.fail('resto.too_late_to_cancel');
  end if;
  update public.reservations set status = 'cancelled', reason = 'annulée par le client' where id = p_reservation;
  update public.reservation_tables set active = false where reservation_id = p_reservation;
end $$;

-- Tables libres d'un établissement sur un créneau.
create or replace function public.available_tables(p_branch uuid, p_starts_at timestamptz, p_ends_at timestamptz)
returns table (table_id uuid, label text, seats smallint, area_name text)
language plpgsql stable security definer set search_path = '' as $$
begin
  perform app_private.assert_branch_perm(p_branch, 'reservations.manage');
  return query
  select t.id, t.label, t.seats, a.name
    from public.dining_tables t join public.service_areas a on a.id = t.service_area_id and a.active
   where t.branch_id = p_branch and t.active
     and not exists (select 1 from public.reservation_tables rt
                      where rt.table_id = t.id and rt.active and rt.period && tstzrange(p_starts_at, p_ends_at, '[)'))
   order by a.sort_order, a.name, t.label;
end $$;

-- Mes réservations (client), avec le restaurant.
create or replace function public.my_reservations()
returns table (reservation_id uuid, branch_id uuid, branch_name text, brand_name text, starts_at timestamptz,
               party_size smallint, status text, reason text)
language sql stable security definer set search_path = '' as $$
  select r.id, r.branch_id, b.name, br.name, r.starts_at, r.party_size, r.status, r.reason
    from public.reservations r
    join public.branches b on b.id = r.branch_id
    join public.brands br on br.id = b.brand_id
   where r.customer_user_id = auth.uid()
   order by r.starts_at desc
   limit 100
$$;

revoke all on function public.request_reservation(uuid, timestamptz, smallint, text, text, text, uuid),
  public.staff_create_reservation(uuid, timestamptz, smallint, smallint, text, text, uuid[], text, uuid),
  public.confirm_reservation(uuid, uuid[]), public.set_reservation_status(uuid, text, text),
  public.customer_cancel_reservation(uuid), public.available_tables(uuid, timestamptz, timestamptz),
  public.my_reservations() from public, anon;
grant execute on function public.request_reservation(uuid, timestamptz, smallint, text, text, text, uuid),
  public.staff_create_reservation(uuid, timestamptz, smallint, smallint, text, text, uuid[], text, uuid),
  public.confirm_reservation(uuid, uuid[]), public.set_reservation_status(uuid, text, text),
  public.customer_cancel_reservation(uuid), public.available_tables(uuid, timestamptz, timestamptz),
  public.my_reservations() to authenticated;

-- La carte publique indique si l'établissement prend les réservations.
create or replace function public.public_reservation_settings(p_branch uuid)
returns jsonb language sql stable security definer set search_path = '' as $$
  select jsonb_build_object('accepts_reservations', b.accepts_reservations, 'reservation_minutes', b.reservation_minutes,
                            'max_party_size', b.max_party_size)
    from public.branches b where b.id = p_branch and b.is_published and b.status = 'active'
$$;
revoke all on function public.public_reservation_settings(uuid) from public;
grant execute on function public.public_reservation_settings(uuid) to anon, authenticated;

revoke all on all functions in schema app_private from public, anon, authenticated;
grant execute on function app_private.member_org_ids(), app_private.member_branch_ids(),
  app_private.org_ids_with(text), app_private.branch_ids_with(text),
  app_private.full_access_org_ids(), app_private.assigned_branch_ids(),
  app_private.org_ids_with_any_branch(text) to authenticated;
