-- =============================================================================
-- Resto — 023_fidelisation
-- Lot 5 — Fidélisation du client :
--   1. notifications dans l'application (commande acceptée, prête, refusée ;
--      réservation confirmée ou refusée ; cadeau d'anniversaire ; commande groupée) ;
--   2. plats favoris et listes personnelles (« À tester », « Déjeuners du bureau »…) ;
--   3. portefeuille de coupons (promotions publiques enregistrées par le client) ;
--   4. points offerts pour l'anniversaire (programme de fidélité de chaque restaurant) ;
--   5. commande groupée : un lien à partager, chacun ajoute ses plats, l'organisateur valide.
-- Chaque client ne voit que ses propres données ; un restaurant ne voit rien de tout cela
-- en dehors des commandes qui lui sont adressées.
-- À coller APRÈS 022, puis supabase/tests/023_fidelisation_tests.sql.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. Notifications du client
-- -----------------------------------------------------------------------------
create table if not exists public.customer_notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  kind text not null check (kind in ('order_accepted', 'order_ready', 'order_rejected', 'reservation_confirmed',
                                     'reservation_declined', 'birthday_reward', 'group_joined', 'group_placed')),
  data jsonb not null default '{}'::jsonb check (jsonb_typeof(data) = 'object' and length(data::text) <= 2000),
  read_at timestamptz,
  created_at timestamptz not null default now()
);
create index if not exists customer_notifications_user_idx on public.customer_notifications (user_id, created_at desc);
alter table public.customer_notifications enable row level security;
grant select on public.customer_notifications to authenticated;
drop policy if exists customer_notifications_own on public.customer_notifications;
create policy customer_notifications_own on public.customer_notifications for select to authenticated
  using (user_id = (select auth.uid()));

-- Suivi en direct dans l'application (si la publication temps réel existe).
do $$
begin
  if exists (select 1 from pg_publication where pubname = 'supabase_realtime')
     and not exists (select 1 from pg_publication_tables
                      where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'customer_notifications') then
    execute 'alter publication supabase_realtime add table public.customer_notifications';
  end if;
end $$;

-- Le texte est composé par l'application dans la langue du client à partir de « kind » et « data ».
create or replace function app_private.notify_customer(p_user uuid, p_kind text, p_data jsonb)
returns void language plpgsql security definer set search_path = '' as $$
begin
  if p_user is null then return; end if;
  insert into public.customer_notifications (user_id, kind, data) values (p_user, p_kind, coalesce(p_data, '{}'::jsonb));
  -- On garde les 200 plus récentes.
  delete from public.customer_notifications
   where user_id = p_user
     and id not in (select id from public.customer_notifications where user_id = p_user order by created_at desc limit 200);
end $$;

create or replace function app_private.order_notifications()
returns trigger language plpgsql security definer set search_path = '' as $$
declare v_data jsonb;
begin
  if new.customer_user_id is null then return null; end if;
  v_data := jsonb_build_object('order_id', new.id, 'number', new.number,
                               'brand_name', (select br.name from public.brands br where br.id = new.brand_id));
  if old.acceptance = 'pending' and new.acceptance = 'accepted' then
    perform app_private.notify_customer(new.customer_user_id, 'order_accepted', v_data);
  elsif old.acceptance is distinct from 'rejected' and new.acceptance = 'rejected' then
    perform app_private.notify_customer(new.customer_user_id, 'order_rejected', v_data || jsonb_build_object('reason', new.reject_reason));
  end if;
  if old.ready_at is null and new.ready_at is not null and new.channel <> 'dine_in' and new.status = 'open' then
    perform app_private.notify_customer(new.customer_user_id, 'order_ready', v_data || jsonb_build_object('channel', new.channel));
  end if;
  return null;
end $$;
drop trigger if exists orders_customer_notifications on public.orders;
create trigger orders_customer_notifications after update of acceptance, ready_at on public.orders
  for each row execute function app_private.order_notifications();

create or replace function app_private.reservation_notifications()
returns trigger language plpgsql security definer set search_path = '' as $$
declare v_data jsonb;
begin
  if new.customer_user_id is null or new.status is not distinct from old.status then return null; end if;
  v_data := jsonb_build_object('reservation_id', new.id, 'starts_at', new.starts_at, 'party_size', new.party_size,
                               'brand_name', (select br.name from public.branches b join public.brands br on br.id = b.brand_id
                                               where b.id = new.branch_id));
  if new.status = 'confirmed' and old.status = 'requested' then
    perform app_private.notify_customer(new.customer_user_id, 'reservation_confirmed', v_data);
  elsif new.status = 'declined' then
    perform app_private.notify_customer(new.customer_user_id, 'reservation_declined', v_data || jsonb_build_object('reason', new.reason));
  end if;
  return null;
end $$;
drop trigger if exists reservations_customer_notifications on public.reservations;
create trigger reservations_customer_notifications after update of status on public.reservations
  for each row execute function app_private.reservation_notifications();

-- Marquer comme lues (toutes, ou celles indiquées).
create or replace function public.mark_notifications_read(p_ids uuid[] default null)
returns void language plpgsql security definer set search_path = '' as $$
begin
  if auth.uid() is null then raise exception 'resto.not_authenticated' using errcode = '42501'; end if;
  update public.customer_notifications set read_at = now()
   where user_id = auth.uid() and read_at is null and (p_ids is null or id = any (p_ids));
end $$;

-- -----------------------------------------------------------------------------
-- 2. Plats favoris et listes personnelles
-- -----------------------------------------------------------------------------
create table if not exists public.customer_item_favorites (
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  item_id uuid not null references public.menu_items (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_id, item_id)
);
create table if not exists public.customer_lists (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  name text not null check (length(btrim(name)) between 1 and 60),
  created_at timestamptz not null default now(),
  unique (user_id, id)
);
create table if not exists public.customer_list_items (
  list_id uuid not null,
  user_id uuid not null default auth.uid(),
  item_id uuid not null references public.menu_items (id) on delete cascade,
  added_at timestamptz not null default now(),
  primary key (list_id, item_id),
  foreign key (user_id, list_id) references public.customer_lists (user_id, id) on delete cascade
);
alter table public.customer_item_favorites enable row level security;
alter table public.customer_lists enable row level security;
alter table public.customer_list_items enable row level security;
grant select, insert (item_id), delete on public.customer_item_favorites to authenticated;
grant select, insert (id, name), update (name), delete on public.customer_lists to authenticated;
grant select, insert (list_id, item_id), delete on public.customer_list_items to authenticated;
drop policy if exists customer_item_favorites_own on public.customer_item_favorites;
drop policy if exists customer_lists_own on public.customer_lists;
drop policy if exists customer_list_items_own on public.customer_list_items;
create policy customer_item_favorites_own on public.customer_item_favorites for all to authenticated
  using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));
create policy customer_lists_own on public.customer_lists for all to authenticated
  using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));
create policy customer_list_items_own on public.customer_list_items for all to authenticated
  using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));

-- Limites : 500 favoris, 20 listes, 200 plats par liste.
create or replace function app_private.limit_customer_saves()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  if tg_table_name = 'customer_item_favorites'
     and (select count(*) from public.customer_item_favorites where user_id = new.user_id) >= 500 then
    perform app_private.fail('resto.limit_reached');
  elsif tg_table_name = 'customer_lists'
     and (select count(*) from public.customer_lists where user_id = new.user_id) >= 20 then
    perform app_private.fail('resto.limit_reached');
  elsif tg_table_name = 'customer_list_items'
     and (select count(*) from public.customer_list_items where list_id = new.list_id) >= 200 then
    perform app_private.fail('resto.limit_reached');
  end if;
  return new;
end $$;
drop trigger if exists customer_item_favorites_limit on public.customer_item_favorites;
drop trigger if exists customer_lists_limit on public.customer_lists;
drop trigger if exists customer_list_items_limit on public.customer_list_items;
create trigger customer_item_favorites_limit before insert on public.customer_item_favorites
  for each row execute function app_private.limit_customer_saves();
create trigger customer_lists_limit before insert on public.customer_lists
  for each row execute function app_private.limit_customer_saves();
create trigger customer_list_items_limit before insert on public.customer_list_items
  for each row execute function app_private.limit_customer_saves();

-- Fiche publique d'un plat : premier établissement publié qui le propose (ou indisponible).
create or replace function app_private.item_card(p_item uuid)
returns jsonb language sql stable security definer set search_path = '' as $$
  select coalesce(
    (select jsonb_build_object(
        'item_id', mi.id, 'name', mi.name, 'image_path', mi.image_path, 'branch_id', b.id, 'brand_name', br.name,
        'currency', b.currency, 'available', true,
        'price_minor', (select min(p.amount_minor) from public.prices p
                          join public.item_variants v on v.id = p.variant_id and v.active
                         where v.item_id = mi.id and p.branch_id = b.id and p.channel = 'default' and p.valid_to is null),
        'rating', (select round(avg(r.rating), 1) from public.item_reviews r
                    where r.item_id = mi.id and r.branch_id = b.id and r.status = 'published'))
       from public.menu_items mi
       join public.menu_item_branches mib on mib.item_id = mi.id and mib.available
       join public.branches b on b.id = mib.branch_id and b.is_published and b.status = 'active'
       join public.brands br on br.id = b.brand_id and br.status = 'active'
      where mi.id = p_item and mi.active
      order by b.created_at
      limit 1),
    (select jsonb_build_object('item_id', mi.id, 'name', mi.name, 'image_path', mi.image_path, 'available', false)
       from public.menu_items mi where mi.id = p_item));
$$;

-- Mes plats enregistrés : favoris et listes.
create or replace function public.my_saved_items()
returns jsonb language sql stable security definer set search_path = '' as $$
  select jsonb_build_object(
    'favorites', coalesce((select jsonb_agg(app_private.item_card(f.item_id) order by f.created_at desc)
                             from public.customer_item_favorites f where f.user_id = auth.uid()), '[]'::jsonb),
    'lists', coalesce((select jsonb_agg(jsonb_build_object(
                 'id', l.id, 'name', l.name,
                 'items', coalesce((select jsonb_agg(app_private.item_card(li.item_id) order by li.added_at desc)
                                      from public.customer_list_items li where li.list_id = l.id), '[]'::jsonb))
               order by l.created_at)
             from public.customer_lists l where l.user_id = auth.uid()), '[]'::jsonb));
$$;

-- -----------------------------------------------------------------------------
-- 3. Portefeuille de coupons
-- -----------------------------------------------------------------------------
create table if not exists public.customer_coupons (
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  promotion_id uuid not null references public.promotions (id) on delete cascade,
  saved_at timestamptz not null default now(),
  primary key (user_id, promotion_id)
);
alter table public.customer_coupons enable row level security;
grant select, delete on public.customer_coupons to authenticated;
drop policy if exists customer_coupons_own on public.customer_coupons;
create policy customer_coupons_own on public.customer_coupons for all to authenticated
  using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));

-- Enregistrer un coupon : seulement une promotion publique, avec code, en cours.
create or replace function public.save_coupon(p_promotion uuid)
returns void language plpgsql security definer set search_path = '' as $$
begin
  if auth.uid() is null then raise exception 'resto.not_authenticated' using errcode = '42501'; end if;
  if not exists (select 1 from public.promotions pr
                  where pr.id = p_promotion and pr.is_public and pr.active and pr.code is not null
                    and (pr.ends_at is null or pr.ends_at > now())
                    and (pr.max_uses is null or pr.uses_count < pr.max_uses)) then
    perform app_private.fail('resto.promotion_unavailable');
  end if;
  if (select count(*) from public.customer_coupons where user_id = auth.uid()) >= 100 then
    perform app_private.fail('resto.limit_reached');
  end if;
  insert into public.customer_coupons (user_id, promotion_id) values (auth.uid(), p_promotion) on conflict do nothing;
end $$;

-- Mes coupons, avec leur état (utilisable, utilisé, expiré).
create or replace function public.my_coupons()
returns jsonb language sql stable security definer set search_path = '' as $$
  select coalesce(jsonb_agg(x order by (x ->> 'usable')::boolean desc, x ->> 'ends_at' nulls last), '[]'::jsonb) from (
    select jsonb_build_object(
      'id', pr.id, 'name', pr.name, 'kind', pr.kind, 'percent', pr.percent, 'amount_minor', pr.amount_minor, 'code', pr.code,
      'min_order_minor', pr.min_order_minor, 'starts_at', pr.starts_at, 'ends_at', pr.ends_at,
      'usable', pr.active and (pr.starts_at is null or pr.starts_at <= now()) and (pr.ends_at is null or pr.ends_at > now())
                and (pr.max_uses is null or pr.uses_count < pr.max_uses)
                and (pr.per_customer_limit is null or (select count(*) from public.order_adjustments a
                                                         join public.orders o on o.id = a.order_id
                                                        where a.promotion_id = pr.id and o.customer_user_id = auth.uid()
                                                          and o.status <> 'cancelled') < pr.per_customer_limit),
      'used', (select count(*) from public.order_adjustments a join public.orders o on o.id = a.order_id
                where a.promotion_id = pr.id and o.customer_user_id = auth.uid() and o.status <> 'cancelled'),
      'branch_id', coalesce(pr.branch_id, (select b.id from public.branches b
                                            where b.organization_id = pr.organization_id and b.is_published and b.status = 'active'
                                            order by b.created_at limit 1)),
      'brand_name', (select br.name from public.branches b join public.brands br on br.id = b.brand_id
                      where b.organization_id = pr.organization_id and (pr.branch_id is null or b.id = pr.branch_id)
                      order by b.created_at limit 1),
      'logo_path', (select br.logo_path from public.branches b join public.brands br on br.id = b.brand_id
                     where b.organization_id = pr.organization_id and (pr.branch_id is null or b.id = pr.branch_id)
                     order by b.created_at limit 1),
      'currency', (select b.currency from public.branches b
                    where b.organization_id = pr.organization_id and (pr.branch_id is null or b.id = pr.branch_id)
                    order by b.created_at limit 1)) as x
      from public.customer_coupons cc
      join public.promotions pr on pr.id = cc.promotion_id
     where cc.user_id = auth.uid()
  ) s;
$$;

-- -----------------------------------------------------------------------------
-- 4. Anniversaire : points offerts par chaque restaurant où le client a déjà commandé
-- -----------------------------------------------------------------------------
alter table public.loyalty_programs
  add column if not exists birthday_points integer not null default 0 check (birthday_points between 0 and 1000000);
grant insert (birthday_points), update (birthday_points) on public.loyalty_programs to authenticated;

alter table public.loyalty_transactions drop constraint if exists loyalty_transactions_kind_check;
alter table public.loyalty_transactions
  add constraint loyalty_transactions_kind_check check (kind in ('earn', 'redeem', 'adjust', 'birthday'));
-- Une fois par an et par compte (motif « birthday:AAAA »).
create unique index if not exists loyalty_birthday_once on public.loyalty_transactions (account_id, reason) where kind = 'birthday';

-- Date de saisie de l'anniversaire : une date modifiée ne donne droit au cadeau qu'après 30 jours.
alter table public.customer_profiles add column if not exists birthday_set_at timestamptz;
create or replace function app_private.track_birthday()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  if tg_op = 'INSERT' then
    new.birthday_set_at := case when new.birthday is not null then now() end;
  elsif new.birthday is distinct from old.birthday then
    new.birthday_set_at := case when new.birthday is not null then now() end;
  else
    new.birthday_set_at := old.birthday_set_at;
  end if;
  return new;
end $$;
drop trigger if exists customer_profiles_birthday on public.customer_profiles;
create trigger customer_profiles_birthday before insert or update on public.customer_profiles
  for each row execute function app_private.track_birthday();

-- Appelée à l'ouverture de l'application : crédite les points d'anniversaire dus
-- (du 3 jours avant au 7 jours après la date), une seule fois par an et par restaurant.
create or replace function public.claim_birthday_rewards()
returns jsonb language plpgsql security definer set search_path = '' as $$
declare
  v_uid uuid := auth.uid();
  v_profile public.customer_profiles;
  v_day date;
  v_year integer := extract(year from current_date)::int;
  v_prog record;
  v_account uuid;
  v_new integer;
  v_out jsonb := '[]'::jsonb;
begin
  if v_uid is null then return v_out; end if;
  select * into v_profile from public.customer_profiles where user_id = v_uid;
  if v_profile.birthday is null or (v_profile.birthday_set_at is not null and v_profile.birthday_set_at > now() - interval '30 days') then
    return v_out;
  end if;
  -- 29 février : le 1er mars les années non bissextiles.
  v_day := make_date(v_year, extract(month from v_profile.birthday)::int, 1) + (extract(day from v_profile.birthday)::int - 1);
  if current_date not between v_day - 3 and v_day + 7 then return v_out; end if;
  for v_prog in
    select p.organization_id, p.birthday_points, o.name as organization_name
      from public.loyalty_programs p
      join public.organizations o on o.id = p.organization_id and o.status = 'active'
     where p.active and p.birthday_points > 0
       and exists (select 1 from public.restaurant_customers rc where rc.organization_id = p.organization_id and rc.user_id = v_uid)
  loop
    insert into public.loyalty_accounts (organization_id, user_id) values (v_prog.organization_id, v_uid)
    on conflict (organization_id, user_id) do nothing;
    select id into v_account from public.loyalty_accounts where organization_id = v_prog.organization_id and user_id = v_uid;
    insert into public.loyalty_transactions (organization_id, account_id, kind, points, reason)
    values (v_prog.organization_id, v_account, 'birthday', v_prog.birthday_points, 'birthday:' || v_year)
    on conflict (account_id, reason) where kind = 'birthday' do nothing;
    get diagnostics v_new = row_count;
    if v_new > 0 then
      update public.loyalty_accounts set points = points + v_prog.birthday_points where id = v_account;
      perform app_private.notify_customer(v_uid, 'birthday_reward',
        jsonb_build_object('organization_name', v_prog.organization_name, 'points', v_prog.birthday_points));
      v_out := v_out || jsonb_build_object('organization_name', v_prog.organization_name, 'points', v_prog.birthday_points);
    end if;
  end loop;
  return v_out;
end $$;

-- -----------------------------------------------------------------------------
-- 5. Commande groupée
-- -----------------------------------------------------------------------------
create table if not exists public.group_orders (
  id uuid primary key default gen_random_uuid(),
  token text not null unique default replace(gen_random_uuid()::text, '-', ''),
  organization_id uuid not null,
  branch_id uuid not null,
  host_user_id uuid not null references auth.users (id) on delete cascade,
  host_name text not null check (length(btrim(host_name)) between 1 and 60),
  status text not null default 'open' check (status in ('open', 'placed', 'cancelled')),
  order_id uuid references public.orders (id) on delete set null,
  expires_at timestamptz not null default now() + interval '6 hours',
  created_at timestamptz not null default now(),
  foreign key (organization_id, branch_id) references public.branches (organization_id, id) on delete cascade
);
create table if not exists public.group_order_lines (
  id uuid primary key default gen_random_uuid(),
  group_id uuid not null references public.group_orders (id) on delete cascade,
  user_id uuid not null references auth.users (id) on delete cascade,
  participant_name text not null check (length(btrim(participant_name)) between 1 and 60),
  variant_id uuid not null references public.item_variants (id) on delete cascade,
  quantity smallint not null check (quantity between 1 and 50),
  modifier_ids uuid[] not null default '{}' check (cardinality(modifier_ids) <= 30),
  note text check (length(note) <= 200),
  created_at timestamptz not null default now()
);
create index if not exists group_order_lines_group_idx on public.group_order_lines (group_id, created_at);
-- Accès uniquement par les fonctions ci-dessous (lien secret).
alter table public.group_orders enable row level security;
alter table public.group_order_lines enable row level security;
revoke all on public.group_orders, public.group_order_lines from anon, authenticated;

create or replace function app_private.open_group(p_token text)
returns public.group_orders language plpgsql security definer set search_path = '' as $$
declare v public.group_orders;
begin
  select * into v from public.group_orders where token = p_token for update;
  if v.id is null then perform app_private.fail('resto.not_found'); end if;
  if v.status <> 'open' or v.expires_at < now() then perform app_private.fail('resto.group_closed'); end if;
  return v;
end $$;

create or replace function public.create_group_order(p_branch uuid, p_name text)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare
  v_branch public.branches;
  v public.group_orders;
begin
  if auth.uid() is null then raise exception 'resto.not_authenticated' using errcode = '42501'; end if;
  select * into v_branch from public.branches where id = p_branch;
  if v_branch.id is null or not v_branch.is_published or v_branch.status <> 'active' or not v_branch.accepts_online_orders then
    perform app_private.fail('resto.online_orders_closed');
  end if;
  if (select count(*) from public.group_orders where host_user_id = auth.uid() and status = 'open' and expires_at > now()) >= 3 then
    perform app_private.fail('resto.rate_limited');
  end if;
  insert into public.group_orders (organization_id, branch_id, host_user_id, host_name)
  values (v_branch.organization_id, p_branch, auth.uid(),
          coalesce(nullif(left(btrim(p_name), 60), ''), app_private.display_author(auth.uid())))
  returning * into v;
  return jsonb_build_object('id', v.id, 'token', v.token);
end $$;

-- Détail d'une commande groupée (pour qui a le lien et un compte).
create or replace function public.group_order(p_token text)
returns jsonb language plpgsql stable security definer set search_path = '' as $$
declare v public.group_orders;
begin
  if auth.uid() is null then raise exception 'resto.not_authenticated' using errcode = '42501'; end if;
  select * into v from public.group_orders where token = p_token;
  if v.id is null then perform app_private.fail('resto.not_found'); end if;
  return jsonb_build_object(
    'id', v.id, 'token', v.token, 'branch_id', v.branch_id, 'host_name', v.host_name, 'is_host', v.host_user_id = auth.uid(),
    'status', case when v.status = 'open' and v.expires_at < now() then 'expired' else v.status end,
    'expires_at', v.expires_at,
    'order_id', case when v.host_user_id = auth.uid() then v.order_id end,
    'brand_name', (select br.name from public.branches b join public.brands br on br.id = b.brand_id where b.id = v.branch_id),
    'lines', coalesce((select jsonb_agg(jsonb_build_object(
        'id', l.id, 'participant_name', l.participant_name, 'variant_id', l.variant_id, 'item_id', iv.item_id,
        'quantity', l.quantity, 'modifier_ids', to_jsonb(l.modifier_ids), 'note', l.note, 'mine', l.user_id = auth.uid())
        order by l.created_at)
        from public.group_order_lines l join public.item_variants iv on iv.id = l.variant_id
       where l.group_id = v.id), '[]'::jsonb));
end $$;

-- Ajouter ses plats : [{variant_id, quantity, modifier_ids, note}].
create or replace function public.add_group_lines(p_token text, p_items jsonb, p_name text default null)
returns void language plpgsql security definer set search_path = '' as $$
declare
  v public.group_orders;
  v_item jsonb;
  v_name text;
  v_first boolean;
begin
  if auth.uid() is null then raise exception 'resto.not_authenticated' using errcode = '42501'; end if;
  v := app_private.open_group(p_token);
  if jsonb_typeof(coalesce(p_items, 'null'::jsonb)) <> 'array' or jsonb_array_length(p_items) not between 1 and 30 then
    perform app_private.fail('resto.invalid_order');
  end if;
  v_name := coalesce(nullif(left(btrim(p_name), 60), ''),
                     (select l.participant_name from public.group_order_lines l
                       where l.group_id = v.id and l.user_id = auth.uid() limit 1),
                     app_private.display_author(auth.uid()));
  v_first := not exists (select 1 from public.group_order_lines l where l.group_id = v.id and l.user_id = auth.uid());
  if (select count(*) from public.group_order_lines l where l.group_id = v.id) + jsonb_array_length(p_items) > 100
     or (select count(*) from public.group_order_lines l where l.group_id = v.id and l.user_id = auth.uid())
        + jsonb_array_length(p_items) > 30 then
    perform app_private.fail('resto.limit_reached');
  end if;
  for v_item in select * from jsonb_array_elements(p_items) loop
    -- La taille doit appartenir à un plat proposé par cet établissement.
    if not exists (select 1 from public.item_variants iv
                     join public.menu_item_branches mib on mib.item_id = iv.item_id and mib.branch_id = v.branch_id and mib.available
                    where iv.id = (v_item ->> 'variant_id')::uuid and iv.active) then
      perform app_private.fail('resto.invalid_order');
    end if;
    insert into public.group_order_lines (group_id, user_id, participant_name, variant_id, quantity, modifier_ids, note)
    values (v.id, auth.uid(), v_name, (v_item ->> 'variant_id')::uuid, coalesce((v_item ->> 'quantity')::int, 1),
            array(select jsonb_array_elements_text(coalesce(v_item -> 'modifier_ids', '[]'::jsonb))::uuid),
            nullif(left(btrim(v_item ->> 'note'), 200), ''));
  end loop;
  if v_first and auth.uid() <> v.host_user_id then
    perform app_private.notify_customer(v.host_user_id, 'group_joined',
      jsonb_build_object('token', v.token, 'participant_name', v_name,
                         'brand_name', (select br.name from public.branches b join public.brands br on br.id = b.brand_id
                                         where b.id = v.branch_id)));
  end if;
exception
  when invalid_text_representation then perform app_private.fail('resto.invalid_order');
end $$;

-- Retirer une ligne : la sienne, ou n'importe laquelle pour l'organisateur.
create or replace function public.remove_group_line(p_line uuid)
returns void language plpgsql security definer set search_path = '' as $$
declare
  v_line public.group_order_lines;
  v public.group_orders;
begin
  select * into v_line from public.group_order_lines where id = p_line;
  if v_line.id is null then perform app_private.fail('resto.not_found'); end if;
  select * into v from public.group_orders where id = v_line.group_id;
  if auth.uid() is distinct from v_line.user_id and auth.uid() is distinct from v.host_user_id then
    raise exception 'resto.forbidden' using errcode = '42501';
  end if;
  perform app_private.open_group(v.token);
  delete from public.group_order_lines where id = p_line;
end $$;

create or replace function public.cancel_group_order(p_token text)
returns void language plpgsql security definer set search_path = '' as $$
declare v public.group_orders;
begin
  v := app_private.open_group(p_token);
  if auth.uid() is distinct from v.host_user_id then raise exception 'resto.forbidden' using errcode = '42501'; end if;
  update public.group_orders set status = 'cancelled' where id = v.id;
end $$;

-- L'organisateur valide : une seule commande au restaurant, chaque plat porte le prénom de son convive.
create or replace function public.place_group_order(
  p_token text, p_channel text, p_contact_phone text default null, p_customer_name text default null,
  p_delivery_address text default null, p_delivery_instructions text default null,
  p_scheduled_for timestamptz default null, p_note text default null)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare
  v public.group_orders;
  v_items jsonb;
  v_res jsonb;
  v_user uuid;
begin
  v := app_private.open_group(p_token);
  if auth.uid() is distinct from v.host_user_id then raise exception 'resto.forbidden' using errcode = '42501'; end if;
  if coalesce(p_channel, '') not in ('takeaway', 'delivery') then perform app_private.fail('resto.invalid_order'); end if;
  select jsonb_agg(jsonb_build_object(
           'variant_id', l.variant_id, 'quantity', l.quantity, 'modifier_ids', to_jsonb(l.modifier_ids),
           'note', left(l.participant_name || coalesce(' — ' || l.note, ''), 200)) order by l.participant_name, l.created_at)
    into v_items
    from public.group_order_lines l where l.group_id = v.id;
  if v_items is null then perform app_private.fail('resto.invalid_order'); end if;
  v_res := public.place_online_order(v.branch_id, p_channel, v_items, null, p_scheduled_for,
             case when p_channel = 'delivery' then p_delivery_address end,
             case when p_channel = 'delivery' then p_delivery_instructions end,
             p_contact_phone, p_customer_name, p_note, v.id);
  update public.group_orders set status = 'placed', order_id = (v_res ->> 'order_id')::uuid where id = v.id;
  for v_user in select distinct l.user_id from public.group_order_lines l where l.group_id = v.id and l.user_id <> v.host_user_id loop
    perform app_private.notify_customer(v_user, 'group_placed',
      jsonb_build_object('host_name', v.host_name, 'number', v_res -> 'number',
                         'brand_name', (select br.name from public.branches b join public.brands br on br.id = b.brand_id
                                         where b.id = v.branch_id)));
  end loop;
  return v_res;
end $$;

-- -----------------------------------------------------------------------------
-- Droits
-- -----------------------------------------------------------------------------
revoke all on function public.mark_notifications_read(uuid[]), public.my_saved_items(), public.save_coupon(uuid),
  public.my_coupons(), public.claim_birthday_rewards(), public.create_group_order(uuid, text), public.group_order(text),
  public.add_group_lines(text, jsonb, text), public.remove_group_line(uuid), public.cancel_group_order(text),
  public.place_group_order(text, text, text, text, text, text, timestamptz, text) from public, anon;
grant execute on function public.mark_notifications_read(uuid[]), public.my_saved_items(), public.save_coupon(uuid),
  public.my_coupons(), public.claim_birthday_rewards(), public.create_group_order(uuid, text), public.group_order(text),
  public.add_group_lines(text, jsonb, text), public.remove_group_line(uuid), public.cancel_group_order(text),
  public.place_group_order(text, text, text, text, text, text, timestamptz, text) to authenticated;

revoke all on all functions in schema app_private from public, anon, authenticated;
grant execute on function app_private.member_org_ids(), app_private.member_branch_ids(),
  app_private.org_ids_with(text), app_private.branch_ids_with(text),
  app_private.full_access_org_ids(), app_private.assigned_branch_ids(),
  app_private.org_ids_with_any_branch(text) to authenticated;
