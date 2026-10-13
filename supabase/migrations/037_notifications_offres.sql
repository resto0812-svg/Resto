-- =============================================================================
-- Resto — 037 : notifications d'offres des restaurants (publicité au format
-- « Notification »).
--  1. Une offre programmée (date de début à venir) part à sa date : une tâche
--     planifiée vérifie toutes les 5 minutes. Avant, elle ne partait jamais.
--  2. Une offre n'est envoyée qu'une seule fois, même mise en pause puis
--     réactivée.
--  3. Destinataires élargis : clients qui suivent le restaurant, y ont commandé
--     dans l'année, ont mis un de ses plats en favori ou aimé un de ses plats
--     ou publicités, et clients dont l'adresse enregistrée est à moins de
--     30 km d'un établissement concerné. Un nouveau restaurant touche ainsi
--     les clients proches. L'équipe du restaurant n'est jamais destinataire.
--  4. Le restaurant voit à l'avance combien de clients recevront l'offre.
-- Le client garde la main : « Offres » coupé dans ses préférences = pas de
-- push (l'offre reste visible dans ses notifications).
-- =============================================================================

create extension if not exists pg_cron;

-- Offres déjà envoyées (une ligne par campagne).
create table if not exists app_private.promotion_pushes (
  campaign_id uuid primary key references public.ad_campaigns (id) on delete cascade,
  sent_at timestamptz not null default now(),
  recipients integer not null default 0
);

-- Les offres actives déjà parties au moment de leur activation ne repartent pas.
insert into app_private.promotion_pushes (campaign_id, sent_at)
select c.id, c.starts_at from public.ad_campaigns c
 where c.format = 'push' and c.status = 'active' and c.starts_at <= now()
on conflict (campaign_id) do nothing;

-- Destinataires d'une offre (5 000 au plus).
create or replace function app_private.promotion_recipients(p_org uuid, p_brand uuid, p_branch_ids uuid[])
returns table (user_id uuid) language sql stable security definer set search_path = '' as $$
  with targets as (
    select b.id, b.latitude, b.longitude from public.branches b
     where b.brand_id = p_brand and b.is_published and b.status = 'active'
       and (cardinality(coalesce(p_branch_ids, '{}')) = 0 or b.id = any (p_branch_ids))
  ), brand_items as (
    select distinct mib.item_id from public.menu_item_branches mib join targets t on t.id = mib.branch_id
  ), audience as (
    select f.user_id from public.customer_favorites f
      join public.branches b on b.id = f.branch_id and b.brand_id = p_brand
    union
    select o.customer_user_id from public.orders o
     where o.brand_id = p_brand and o.customer_user_id is not null and o.opened_at > now() - interval '365 days'
    union
    select fi.user_id from public.customer_item_favorites fi join brand_items i on i.item_id = fi.item_id
    union
    select l.user_id from public.item_likes l join brand_items i on i.item_id = l.item_id
    union
    select al.user_id from public.ad_likes al join public.ad_campaigns c on c.id = al.campaign_id and c.brand_id = p_brand
    union
    select s.user_id from public.ad_saves s join public.ad_campaigns c on c.id = s.campaign_id and c.brand_id = p_brand
    union
    select cp.user_id from public.customer_profiles cp
     where cp.home_latitude is not null and cp.home_longitude is not null
       and exists (select 1 from targets t
                    where t.latitude is not null and t.longitude is not null
                      and 2 * 6371 * asin(least(1, sqrt(
                            power(sin(radians(cp.home_latitude - t.latitude) / 2), 2)
                            + cos(radians(t.latitude)) * cos(radians(cp.home_latitude))
                              * power(sin(radians(cp.home_longitude - t.longitude) / 2), 2)))) <= 30)
  )
  select a.user_id from audience a
   where a.user_id is not null
     and not exists (select 1 from public.memberships m where m.user_id = a.user_id and m.organization_id = p_org)
   limit 5000;
$$;

-- Envoie une offre si elle est due et pas encore partie ; renvoie le nombre
-- de clients prévenus.
create or replace function app_private.send_promotion(p_campaign uuid)
returns integer language plpgsql security definer set search_path = '' as $$
declare
  c public.ad_campaigns;
  v_branch uuid;
  v_count integer;
begin
  select * into c from public.ad_campaigns where id = p_campaign;
  if c.id is null or c.format <> 'push' or c.status <> 'active' or c.starts_at > now()
     or (c.ends_at is not null and c.ends_at <= now()) then
    return 0;
  end if;
  select b.id into v_branch from public.branches b
   where b.brand_id = c.brand_id and b.is_published and b.status = 'active'
     and (cardinality(c.branch_ids) = 0 or b.id = any (c.branch_ids))
   order by b.created_at limit 1;
  -- Restaurant pas encore publié : l'offre partira dès qu'il le sera.
  if v_branch is null then return 0; end if;
  insert into app_private.promotion_pushes (campaign_id) values (c.id) on conflict (campaign_id) do nothing;
  if not found then return 0; end if;
  insert into public.customer_notifications (user_id, kind, data)
  select r.user_id, 'promotion',
         jsonb_build_object('campaign_id', c.id, 'title', left(c.title, 120), 'body', left(coalesce(c.body, ''), 300),
                            'branch_id', v_branch, 'brand_name', (select br.name from public.brands br where br.id = c.brand_id))
    from app_private.promotion_recipients(c.organization_id, c.brand_id, c.branch_ids) r;
  get diagnostics v_count = row_count;
  update app_private.promotion_pushes set recipients = v_count where campaign_id = c.id;
  return v_count;
end $$;

-- Activation ou changement de date : envoi immédiat si l'offre est due.
create or replace function app_private.promotion_notifications()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  if new.format = 'push' and new.status = 'active' then
    perform app_private.send_promotion(new.id);
  end if;
  return null;
end $$;
drop trigger if exists ad_campaigns_promotion_push on public.ad_campaigns;
create trigger ad_campaigns_promotion_push after insert or update of status, starts_at, ends_at on public.ad_campaigns
  for each row execute function app_private.promotion_notifications();

-- Offres programmées arrivées à leur date.
create or replace function app_private.send_due_promotions()
returns integer language plpgsql security definer set search_path = '' as $$
declare
  r record;
  v_total integer := 0;
begin
  for r in select c.id from public.ad_campaigns c
            where c.format = 'push' and c.status = 'active' and c.starts_at <= now()
              and (c.ends_at is null or c.ends_at > now())
              and not exists (select 1 from app_private.promotion_pushes p where p.campaign_id = c.id)
            order by c.starts_at
            limit 50 loop
    v_total := v_total + app_private.send_promotion(r.id);
  end loop;
  return v_total;
end $$;

select cron.unschedule(j.jobid) from cron.job j where j.jobname = 'resto-offres-programmees';
select cron.schedule('resto-offres-programmees', '*/5 * * * *', 'select app_private.send_due_promotions()');

-- Pour le restaurant : nombre de clients qui recevraient l'offre.
create or replace function public.promotion_audience_count(p_brand uuid, p_branch_ids uuid[] default '{}')
returns integer language plpgsql stable security definer set search_path = '' as $$
declare v_org uuid;
begin
  select br.organization_id into v_org from public.brands br where br.id = p_brand;
  if v_org is null or not exists (select 1 from app_private.org_ids_with('marketing.manage') x where x = v_org) then
    raise exception 'resto.forbidden' using errcode = '42501';
  end if;
  return (select count(*) from app_private.promotion_recipients(v_org, p_brand, coalesce(p_branch_ids, '{}')));
end $$;

revoke all on function public.promotion_audience_count(uuid, uuid[]) from public, anon;
grant execute on function public.promotion_audience_count(uuid, uuid[]) to authenticated;

revoke all on all functions in schema app_private from public, anon, authenticated;
grant execute on function app_private.member_org_ids(), app_private.member_branch_ids(),
  app_private.org_ids_with(text), app_private.branch_ids_with(text),
  app_private.full_access_org_ids(), app_private.assigned_branch_ids(),
  app_private.org_ids_with_any_branch(text) to authenticated;
