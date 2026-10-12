-- =============================================================================
-- Resto — 031_notifications_push
-- Notifications du client ET du restaurant, dans l'application et en push
-- (téléphone et navigateur, via Firebase Cloud Messaging) :
--   1. une seule boîte de notifications par utilisateur (customer_notifications,
--      023) : nouveaux types pour le restaurant (nouvelle commande en ligne,
--      commande prête à servir, nouvelle réservation, nouvel avis) et pour le
--      client (offre d'un restaurant suivi) ;
--   2. appareils de chaque utilisateur (jeton Firebase, plateforme, langue) ;
--   3. envoi : chaque nouvelle notification appelle la fonction serveur
--      « send-push » (Edge Function) si l'utilisateur a un appareil et n'a pas
--      coupé ce type de notification ; la fonction compose le texte dans la
--      langue de l'appareil et n'envoie qu'une fois (pushed_at).
-- Le restaurant ne voit jamais les appareils des clients ; personne ne voit
-- les appareils des autres.
-- À coller APRÈS 030, puis supabase/tests/031_notifications_push_tests.sql.
-- =============================================================================

create extension if not exists pg_net;

-- -----------------------------------------------------------------------------
-- 1. Types de notifications
-- -----------------------------------------------------------------------------
alter table public.customer_notifications drop constraint if exists customer_notifications_kind_check;
alter table public.customer_notifications add constraint customer_notifications_kind_check
  check (kind in ('order_accepted', 'order_ready', 'order_rejected', 'reservation_confirmed', 'reservation_declined',
                  'birthday_reward', 'group_joined', 'group_placed', 'promotion',
                  'staff_new_order', 'staff_order_ready', 'staff_new_reservation', 'staff_new_review'));
alter table public.customer_notifications add column if not exists pushed_at timestamptz;

-- -----------------------------------------------------------------------------
-- 2. Appareils
-- -----------------------------------------------------------------------------
create table if not exists public.push_devices (
  token text primary key check (length(token) between 20 and 4096),
  user_id uuid not null references auth.users (id) on delete cascade,
  platform text not null check (platform in ('android', 'ios', 'web')),
  locale text not null default 'fr' check (length(locale) between 2 and 10),
  updated_at timestamptz not null default now()
);
create index if not exists push_devices_user_idx on public.push_devices (user_id);
alter table public.push_devices enable row level security;
grant select on public.push_devices to authenticated;
drop policy if exists push_devices_own on public.push_devices;
create policy push_devices_own on public.push_devices for select to authenticated using (user_id = (select auth.uid()));

-- Enregistre l'appareil de l'utilisateur connecté (un appareil passe au dernier
-- compte connecté) ; 10 appareils au plus par utilisateur.
create or replace function public.register_push_device(p_token text, p_platform text, p_locale text default 'fr')
returns void language plpgsql security definer set search_path = '' as $$
begin
  if auth.uid() is null then raise exception 'resto.not_authenticated' using errcode = '42501'; end if;
  if length(coalesce(p_token, '')) not between 20 and 4096 or p_platform not in ('android', 'ios', 'web') then
    perform app_private.fail('resto.invalid_device');
  end if;
  insert into public.push_devices (token, user_id, platform, locale)
  values (p_token, auth.uid(), p_platform, coalesce(nullif(left(btrim(p_locale), 10), ''), 'fr'))
  on conflict (token) do update
     set user_id = excluded.user_id, platform = excluded.platform, locale = excluded.locale, updated_at = now();
  delete from public.push_devices
   where user_id = auth.uid()
     and token not in (select token from public.push_devices where user_id = auth.uid() order by updated_at desc limit 10);
end $$;

-- À la déconnexion : l'appareil ne reçoit plus les notifications de ce compte.
create or replace function public.unregister_push_device(p_token text)
returns void language plpgsql security definer set search_path = '' as $$
begin
  delete from public.push_devices where token = p_token and user_id = auth.uid();
end $$;

-- -----------------------------------------------------------------------------
-- 3. Destinataires côté restaurant
-- -----------------------------------------------------------------------------
-- Membres actifs ayant une permission sur un établissement.
create or replace function app_private.branch_members_with(p_branch uuid, p_perm text)
returns setof uuid language sql stable security definer set search_path = '' as $$
  select distinct m.user_id
    from public.memberships m
    join public.organizations o on o.id = m.organization_id and o.status = 'active'
    join public.role_permissions rp on rp.role_code = m.role_code and rp.permission_code = p_perm
    join public.branches b on b.id = p_branch and b.organization_id = m.organization_id
   where m.status = 'active'
     and (m.all_branches or exists (
       select 1 from public.membership_branches mb where mb.membership_id = m.id and mb.branch_id = p_branch))
$$;

-- Notification à l'équipe d'un établissement (sauf l'auteur de l'action).
create or replace function app_private.notify_branch_staff(p_branch uuid, p_perm text, p_kind text, p_data jsonb)
returns void language plpgsql security definer set search_path = '' as $$
begin
  if p_branch is null then return; end if;
  insert into public.customer_notifications (user_id, kind, data)
  select u.user_id, p_kind,
         coalesce(p_data, '{}'::jsonb) || jsonb_build_object('organization_id', b.organization_id, 'branch_id', b.id, 'branch_name', b.name)
    from app_private.branch_members_with(p_branch, p_perm) as u(user_id)
    join public.branches b on b.id = p_branch
   where u.user_id is distinct from auth.uid();
end $$;

-- Nouvelle commande d'un client (en ligne, QR de table, téléphone…).
create or replace function app_private.staff_new_order_notification()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  if new.source = 'staff' then return null; end if;
  perform app_private.notify_branch_staff(new.branch_id, 'orders.write', 'staff_new_order',
    jsonb_build_object('order_id', new.id, 'number', new.number, 'channel', new.channel, 'source', new.source,
                       'customer_name', new.customer_name));
  return null;
end $$;
drop trigger if exists orders_staff_new_order on public.orders;
create trigger orders_staff_new_order after insert on public.orders
  for each row execute function app_private.staff_new_order_notification();

-- Commande prête (cuisine) : l'équipe de salle est prévenue.
create or replace function app_private.staff_order_ready_notification()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  if old.ready_at is null and new.ready_at is not null and new.status = 'open' then
    perform app_private.notify_branch_staff(new.branch_id, 'orders.write', 'staff_order_ready',
      jsonb_build_object('order_id', new.id, 'number', new.number, 'channel', new.channel, 'table_id', new.table_id));
  end if;
  return null;
end $$;
drop trigger if exists orders_staff_order_ready on public.orders;
create trigger orders_staff_order_ready after update of ready_at on public.orders
  for each row execute function app_private.staff_order_ready_notification();

-- Nouvelle demande de réservation d'un client.
create or replace function app_private.staff_new_reservation_notification()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  if new.source <> 'customer' then return null; end if;
  perform app_private.notify_branch_staff(new.branch_id, 'reservations.manage', 'staff_new_reservation',
    jsonb_build_object('reservation_id', new.id, 'starts_at', new.starts_at, 'party_size', new.party_size,
                       'customer_name', new.customer_name));
  return null;
end $$;
drop trigger if exists reservations_staff_new on public.reservations;
create trigger reservations_staff_new after insert on public.reservations
  for each row execute function app_private.staff_new_reservation_notification();

-- Nouvel avis (noté après commande, ou libre) sur un plat.
create or replace function app_private.staff_new_review_notification()
returns trigger language plpgsql security definer set search_path = '' as $$
declare
  v_branch uuid;
  v_rating integer;
begin
  if tg_table_name = 'item_reviews' then
    v_branch := new.branch_id;
    v_rating := new.rating;
  else
    select mib.branch_id into v_branch from public.menu_item_branches mib where mib.item_id = new.item_id
     order by mib.updated_at limit 1;
  end if;
  perform app_private.notify_branch_staff(v_branch, 'menus.manage', 'staff_new_review',
    jsonb_build_object('item_id', new.item_id, 'rating', v_rating, 'author', new.author_name,
                       'item_name', (select mi.name from public.menu_items mi where mi.id = new.item_id)));
  return null;
end $$;
drop trigger if exists item_reviews_staff_new on public.item_reviews;
create trigger item_reviews_staff_new after insert on public.item_reviews
  for each row execute function app_private.staff_new_review_notification();
drop trigger if exists item_comments_staff_new on public.item_comments;
create trigger item_comments_staff_new after insert on public.item_comments
  for each row execute function app_private.staff_new_review_notification();

-- -----------------------------------------------------------------------------
-- 4. Offre d'un restaurant (publicité au format « notification »)
-- -----------------------------------------------------------------------------
-- Destinataires : clients qui suivent un établissement de la marque ou y ont
-- commandé ces 90 derniers jours (5 000 au plus), à l'activation de la campagne.
create or replace function app_private.promotion_notifications()
returns trigger language plpgsql security definer set search_path = '' as $$
declare v_branch uuid;
begin
  if new.format <> 'push' or new.status <> 'active' or new.starts_at > now()
     or (tg_op = 'UPDATE' and old.status = 'active') then
    return null;
  end if;
  select b.id into v_branch from public.branches b
   where b.brand_id = new.brand_id and b.is_published and b.status = 'active'
     and (cardinality(new.branch_ids) = 0 or b.id = any (new.branch_ids))
   order by b.created_at limit 1;
  if v_branch is null then return null; end if;
  insert into public.customer_notifications (user_id, kind, data)
  select r.user_id, 'promotion',
         jsonb_build_object('campaign_id', new.id, 'title', left(new.title, 120), 'body', left(coalesce(new.body, ''), 300),
                            'branch_id', v_branch, 'brand_name', (select br.name from public.brands br where br.id = new.brand_id))
    from (select f.user_id from public.customer_favorites f
            join public.branches b on b.id = f.branch_id and b.brand_id = new.brand_id
          union
          select o.customer_user_id from public.orders o
           where o.brand_id = new.brand_id and o.customer_user_id is not null and o.opened_at > now() - interval '90 days'
          limit 5000) r
   where r.user_id is not null
     and not exists (select 1 from public.memberships m where m.user_id = r.user_id and m.organization_id = new.organization_id);
  return null;
end $$;
drop trigger if exists ad_campaigns_promotion_push on public.ad_campaigns;
create trigger ad_campaigns_promotion_push after insert or update of status on public.ad_campaigns
  for each row execute function app_private.promotion_notifications();

-- -----------------------------------------------------------------------------
-- 5. Envoi en push
-- -----------------------------------------------------------------------------
-- Adresse de la fonction « send-push » du projet (pas un secret).
create table if not exists app_private.push_settings (
  id boolean primary key default true check (id),
  function_url text not null check (function_url ~ '^https://')
);
insert into app_private.push_settings (function_url)
values ('https://xpthqtcjqkpticezglbv.supabase.co/functions/v1/send-push')
on conflict (id) do nothing;

-- Préférence de l'utilisateur pour ce type (coupée = pas de push ; la
-- notification reste visible dans l'application).
create or replace function app_private.push_allowed(p_user uuid, p_kind text, p_data jsonb)
returns boolean language plpgsql stable security definer set search_path = '' as $$
declare
  v_key text;
  v_on boolean;
begin
  if p_kind like 'staff_%' then
    v_key := case p_kind when 'staff_new_order' then 'push_new_order' when 'staff_order_ready' then 'push_order_ready'
                         when 'staff_new_reservation' then 'push_reservations' else 'push_reviews' end;
    select (mp.prefs ->> v_key)::boolean into v_on from public.member_preferences mp
     where mp.user_id = p_user and mp.organization_id = (p_data ->> 'organization_id')::uuid;
  else
    v_key := case when p_kind like 'reservation_%' then 'reservation_reminders'
                  when p_kind in ('promotion', 'birthday_reward') then 'promotions' else 'order_updates' end;
    select (cp.prefs ->> v_key)::boolean into v_on from public.customer_profiles cp where cp.user_id = p_user;
  end if;
  return coalesce(v_on, true);
end $$;

create or replace function app_private.dispatch_push()
returns trigger language plpgsql security definer set search_path = '' as $$
declare v_url text;
begin
  if not exists (select 1 from public.push_devices d where d.user_id = new.user_id)
     or not app_private.push_allowed(new.user_id, new.kind, new.data) then
    return null;
  end if;
  select function_url into v_url from app_private.push_settings;
  if v_url is null then return null; end if;
  -- Un échec d'envoi ne bloque jamais l'action qui a créé la notification.
  begin
    perform net.http_post(url := v_url, body := jsonb_build_object('id', new.id),
                          headers := '{"Content-Type": "application/json"}'::jsonb);
  exception when others then
    null;
  end;
  return null;
end $$;
drop trigger if exists customer_notifications_push on public.customer_notifications;
create trigger customer_notifications_push after insert on public.customer_notifications
  for each row execute function app_private.dispatch_push();

revoke all on function public.register_push_device(text, text, text), public.unregister_push_device(text) from public, anon;
grant execute on function public.register_push_device(text, text, text), public.unregister_push_device(text) to authenticated;

revoke all on all functions in schema app_private from public, anon, authenticated;
grant execute on function app_private.member_org_ids(), app_private.member_branch_ids(),
  app_private.org_ids_with(text), app_private.branch_ids_with(text),
  app_private.full_access_org_ids(), app_private.assigned_branch_ids(),
  app_private.org_ids_with_any_branch(text) to authenticated;
