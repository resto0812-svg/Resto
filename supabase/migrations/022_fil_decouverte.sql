-- =============================================================================
-- Resto — 022_fil_decouverte
-- Lot 4 — Fil de découverte et réseau publicitaire :
--   * fil façon Reels / Stories (vidéos, carrousels, stories, plats mis en
--     avant, annonces), contenus sponsorisés signalés comme tels ;
--   * J'aime, enregistrements, commentaires (modérables par le restaurant),
--     partages ;
--   * vues dédoublonnées (un visiteur compte une fois par jour et par
--     contenu) et portée (visiteurs uniques) ;
--   * petites annonces flottantes (format « petite annonce »).
-- Chaque restaurant ne voit que les statistiques et commentaires de ses contenus.
-- À coller APRÈS 021, puis supabase/tests/022_fil_decouverte_tests.sql.
-- =============================================================================

alter table public.ad_campaigns
  add column if not exists likes integer not null default 0,
  add column if not exists saves integer not null default 0,
  add column if not exists comments integer not null default 0,
  add column if not exists shares integer not null default 0,
  add column if not exists reach integer not null default 0;
-- Ces compteurs ne figurent pas dans les colonnes modifiables accordées en 018 :
-- seuls les fonctions ci-dessous les tiennent à jour.

create table if not exists public.ad_views (
  campaign_id uuid not null references public.ad_campaigns (id) on delete cascade,
  viewer_key text not null check (length(viewer_key) between 8 and 64),
  day date not null default current_date,
  primary key (campaign_id, viewer_key, day)
);
create table if not exists public.ad_likes (
  campaign_id uuid not null references public.ad_campaigns (id) on delete cascade,
  user_id uuid not null references auth.users (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (campaign_id, user_id)
);
create table if not exists public.ad_saves (
  campaign_id uuid not null references public.ad_campaigns (id) on delete cascade,
  user_id uuid not null references auth.users (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (campaign_id, user_id)
);
create table if not exists public.ad_comments (
  id uuid primary key default gen_random_uuid(),
  campaign_id uuid not null references public.ad_campaigns (id) on delete cascade,
  organization_id uuid not null references public.organizations (id) on delete cascade,
  user_id uuid not null references auth.users (id) on delete cascade,
  author_name text not null check (length(author_name) between 1 and 60),
  body text not null check (length(btrim(body)) between 1 and 500),
  status text not null default 'published' check (status in ('published', 'hidden')),
  hidden_reason text check (length(hidden_reason) <= 300),
  hidden_by uuid references auth.users (id) on delete set null,
  hidden_at timestamptz,
  created_at timestamptz not null default now(),
  check ((status = 'hidden') = (hidden_at is not null))
);
create index if not exists ad_comments_campaign_idx on public.ad_comments (campaign_id, created_at desc);

alter table public.ad_views enable row level security;
alter table public.ad_likes enable row level security;
alter table public.ad_saves enable row level security;
alter table public.ad_comments enable row level security;
-- Le client voit ses propres J'aime et enregistrements ; le restaurant lit les commentaires de ses contenus.
grant select on public.ad_likes, public.ad_saves, public.ad_comments to authenticated;
drop policy if exists ad_likes_own on public.ad_likes;
drop policy if exists ad_saves_own on public.ad_saves;
drop policy if exists ad_comments_read on public.ad_comments;
create policy ad_likes_own on public.ad_likes for select to authenticated using (user_id = (select auth.uid()));
create policy ad_saves_own on public.ad_saves for select to authenticated using (user_id = (select auth.uid()));
create policy ad_comments_read on public.ad_comments for select to authenticated
  using (user_id = (select auth.uid()) or organization_id in (select app_private.member_org_ids()));

-- Mise à jour des compteurs par le serveur uniquement (voir le contrôle de 018).
create or replace function app_private.bump_ad(p_campaign uuid)
returns void language plpgsql security definer set search_path = '' as $$
begin
  perform set_config('resto.ad_stats', 'on', true);
  update public.ad_campaigns c
     set likes = (select count(*) from public.ad_likes l where l.campaign_id = c.id),
         saves = (select count(*) from public.ad_saves s where s.campaign_id = c.id),
         comments = (select count(*) from public.ad_comments m where m.campaign_id = c.id and m.status = 'published'),
         reach = (select count(distinct v.viewer_key) from public.ad_views v where v.campaign_id = c.id)
   where c.id = p_campaign;
  perform set_config('resto.ad_stats', 'off', true);
end $$;

create or replace function app_private.ad_is_live(p_campaign uuid)
returns boolean language sql stable security definer set search_path = '' as $$
  select exists (select 1 from public.ad_campaigns c
                  where c.id = p_campaign and c.status = 'active' and c.starts_at <= now()
                    and (c.ends_at is null or c.ends_at > now()));
$$;

-- Le contrôle de 018 protège vues, clics, commandes et chiffre d'affaires ; il
-- protège désormais aussi J'aime, enregistrements, commentaires, partages, portée.
create or replace function app_private.guard_ad_social()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  if current_setting('resto.ad_stats', true) is distinct from 'on'
     and (new.likes, new.saves, new.comments, new.shares, new.reach)
         is distinct from (old.likes, old.saves, old.comments, old.shares, old.reach) then
    raise exception 'resto.forbidden' using errcode = '42501';
  end if;
  return new;
end $$;
drop trigger if exists ad_campaigns_guard_social on public.ad_campaigns;
create trigger ad_campaigns_guard_social before update on public.ad_campaigns
  for each row execute function app_private.guard_ad_social();

-- Vue : comptée une fois par jour et par visiteur (compte, sinon identifiant anonyme de l'appareil).
create or replace function public.record_ad_view(p_campaign uuid, p_viewer text default null)
returns void language plpgsql security definer set search_path = '' as $$
declare
  v_key text := coalesce(auth.uid()::text, nullif(btrim(p_viewer), ''));
  v_new integer;
begin
  if v_key is null or length(v_key) not between 8 and 64 or not app_private.ad_is_live(p_campaign) then return; end if;
  insert into public.ad_views (campaign_id, viewer_key) values (p_campaign, v_key) on conflict do nothing;
  get diagnostics v_new = row_count;
  if v_new > 0 then
    perform set_config('resto.ad_stats', 'on', true);
    update public.ad_campaigns set views = views + 1 where id = p_campaign;
    perform set_config('resto.ad_stats', 'off', true);
    perform app_private.bump_ad(p_campaign);
  end if;
end $$;

create or replace function public.toggle_ad_like(p_campaign uuid)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare v_liked boolean;
begin
  if auth.uid() is null then raise exception 'resto.not_authenticated' using errcode = '42501'; end if;
  if not app_private.ad_is_live(p_campaign) then perform app_private.fail('resto.not_found'); end if;
  delete from public.ad_likes where campaign_id = p_campaign and user_id = auth.uid();
  v_liked := not found;
  if v_liked then insert into public.ad_likes (campaign_id, user_id) values (p_campaign, auth.uid()); end if;
  perform app_private.bump_ad(p_campaign);
  return jsonb_build_object('liked', v_liked, 'likes', (select likes from public.ad_campaigns where id = p_campaign));
end $$;

create or replace function public.toggle_ad_save(p_campaign uuid)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare v_saved boolean;
begin
  if auth.uid() is null then raise exception 'resto.not_authenticated' using errcode = '42501'; end if;
  if not app_private.ad_is_live(p_campaign) then perform app_private.fail('resto.not_found'); end if;
  delete from public.ad_saves where campaign_id = p_campaign and user_id = auth.uid();
  v_saved := not found;
  if v_saved then insert into public.ad_saves (campaign_id, user_id) values (p_campaign, auth.uid()); end if;
  perform app_private.bump_ad(p_campaign);
  return jsonb_build_object('saved', v_saved, 'saves', (select saves from public.ad_campaigns where id = p_campaign));
end $$;

-- Commentaire (10 par heure au plus et par client).
create or replace function public.add_ad_comment(p_campaign uuid, p_body text)
returns uuid language plpgsql security definer set search_path = '' as $$
declare
  v_org uuid;
  v_id uuid;
begin
  if auth.uid() is null then raise exception 'resto.not_authenticated' using errcode = '42501'; end if;
  if not app_private.ad_is_live(p_campaign) then perform app_private.fail('resto.not_found'); end if;
  if length(btrim(coalesce(p_body, ''))) not between 1 and 500 then perform app_private.fail('resto.invalid_comment'); end if;
  if (select count(*) from public.ad_comments where user_id = auth.uid() and created_at > now() - interval '1 hour') >= 10 then
    perform app_private.fail('resto.rate_limited');
  end if;
  select organization_id into v_org from public.ad_campaigns where id = p_campaign;
  insert into public.ad_comments (campaign_id, organization_id, user_id, author_name, body)
  values (p_campaign, v_org, auth.uid(), app_private.display_author(auth.uid()), btrim(p_body))
  returning id into v_id;
  perform app_private.bump_ad(p_campaign);
  return v_id;
end $$;

-- Modération par le restaurant (marketing.manage) : masquer avec un motif, ou republier.
create or replace function public.moderate_ad_comment(p_comment uuid, p_hidden boolean, p_reason text default null)
returns void language plpgsql security definer set search_path = '' as $$
declare v public.ad_comments;
begin
  select * into v from public.ad_comments where id = p_comment;
  if v.id is null or not exists (select 1 from app_private.org_ids_with('marketing.manage') x where x = v.organization_id) then
    raise exception 'resto.forbidden' using errcode = '42501';
  end if;
  if p_hidden then
    if length(btrim(coalesce(p_reason, ''))) < 3 then perform app_private.fail('resto.reason_required'); end if;
    update public.ad_comments set status = 'hidden', hidden_reason = btrim(p_reason), hidden_by = auth.uid(), hidden_at = now()
     where id = p_comment;
  else
    update public.ad_comments set status = 'published', hidden_reason = null, hidden_by = null, hidden_at = null where id = p_comment;
  end if;
  perform app_private.bump_ad(v.campaign_id);
end $$;

create or replace function public.record_ad_share(p_campaign uuid)
returns void language plpgsql security definer set search_path = '' as $$
begin
  if not app_private.ad_is_live(p_campaign) then return; end if;
  perform set_config('resto.ad_stats', 'on', true);
  update public.ad_campaigns set shares = shares + 1 where id = p_campaign;
  perform set_config('resto.ad_stats', 'off', true);
end $$;

-- Commande passée depuis un contenu du fil : rattachée à la campagne (comptée à
-- la clôture, voir 018). Seulement par le client lui-même, dans les 30 minutes,
-- pour une campagne en cours du même restaurant, et une seule fois.
create or replace function public.attribute_ad_order(p_order uuid, p_campaign uuid)
returns boolean language plpgsql security definer set search_path = '' as $$
declare v_count integer;
begin
  if auth.uid() is null then raise exception 'resto.not_authenticated' using errcode = '42501'; end if;
  if not app_private.ad_is_live(p_campaign) then return false; end if;
  update public.orders o set ad_campaign_id = p_campaign
   where o.id = p_order and o.customer_user_id = auth.uid() and o.ad_campaign_id is null
     and o.opened_at > now() - interval '30 minutes' and o.status <> 'cancelled'
     and o.organization_id = (select c.organization_id from public.ad_campaigns c where c.id = p_campaign);
  get diagnostics v_count = row_count;
  return v_count > 0;
end $$;

-- Fil de découverte : contenus en cours des restaurants publiés (sponsorisés signalés).
create or replace function public.public_feed(p_city text default null, p_limit integer default 20, p_offset integer default 0)
returns jsonb language sql stable security definer set search_path = '' as $$
  select coalesce(jsonb_agg(x), '[]'::jsonb) from (
    select jsonb_build_object(
      'id', c.id, 'format', c.format, 'title', c.title, 'body', c.body, 'cta_label', c.cta_label, 'cta_url', c.cta_url,
      'media', c.media, 'sponsored', coalesce(c.daily_budget_minor, 0) > 0,
      'likes', c.likes, 'comments', c.comments, 'saves', c.saves, 'shares', c.shares,
      'liked', exists (select 1 from public.ad_likes l where l.campaign_id = c.id and l.user_id = auth.uid()),
      'saved', exists (select 1 from public.ad_saves s where s.campaign_id = c.id and s.user_id = auth.uid()),
      'brand_name', br.name, 'logo_path', br.logo_path, 'branch_id', b.id, 'accepts_reservations', b.accepts_reservations,
      'items', (select coalesce(jsonb_agg(jsonb_build_object('item_id', mi.id, 'name', mi.name, 'image_path', mi.image_path)), '[]'::jsonb)
                  from public.menu_items mi where mi.id = any (c.item_ids) and mi.active)) as x
      from public.ad_campaigns c
      join public.brands br on br.id = c.brand_id and br.status = 'active'
      join lateral (select b2.* from public.branches b2
                     where b2.brand_id = c.brand_id and b2.is_published and b2.status = 'active'
                       and (cardinality(c.branch_ids) = 0 or b2.id = any (c.branch_ids))
                       and (p_city is null or btrim(p_city) = '' or lower(b2.city) = lower(btrim(p_city)))
                     order by b2.created_at limit 1) b on true
     where c.status = 'active' and c.format in ('video', 'carousel', 'story', 'sponsored_menu', 'classified')
       and c.starts_at <= now() and (c.ends_at is null or c.ends_at > now())
     order by (coalesce(c.daily_budget_minor, 0) > 0) desc, c.starts_at desc
     limit least(greatest(coalesce(p_limit, 20), 1), 50) offset greatest(coalesce(p_offset, 0), 0)
  ) s;
$$;

-- Commentaires publiés d'un contenu.
create or replace function public.public_ad_comments(p_campaign uuid, p_limit integer default 50)
returns jsonb language sql stable security definer set search_path = '' as $$
  select coalesce(jsonb_agg(jsonb_build_object('id', m.id, 'author', m.author_name, 'body', m.body, 'created_at', m.created_at,
                                               'mine', m.user_id = auth.uid()) order by m.created_at desc), '[]'::jsonb)
    from (select * from public.ad_comments where campaign_id = p_campaign and status = 'published'
           order by created_at desc limit least(greatest(coalesce(p_limit, 50), 1), 100)) m;
$$;

revoke all on function public.record_ad_view(uuid, text), public.toggle_ad_like(uuid), public.toggle_ad_save(uuid),
  public.add_ad_comment(uuid, text), public.moderate_ad_comment(uuid, boolean, text), public.record_ad_share(uuid),
  public.public_feed(text, integer, integer), public.public_ad_comments(uuid, integer),
  public.attribute_ad_order(uuid, uuid) from public, anon;
grant execute on function public.toggle_ad_like(uuid), public.toggle_ad_save(uuid), public.add_ad_comment(uuid, text),
  public.moderate_ad_comment(uuid, boolean, text), public.attribute_ad_order(uuid, uuid) to authenticated;
grant execute on function public.record_ad_view(uuid, text), public.record_ad_share(uuid), public.public_feed(text, integer, integer),
  public.public_ad_comments(uuid, integer) to anon, authenticated;

revoke all on all functions in schema app_private from public, anon, authenticated;
grant execute on function app_private.member_org_ids(), app_private.member_branch_ids(),
  app_private.org_ids_with(text), app_private.branch_ids_with(text),
  app_private.full_access_org_ids(), app_private.assigned_branch_ids(),
  app_private.org_ids_with_any_branch(text) to authenticated;
