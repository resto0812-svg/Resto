-- =============================================================================
-- Resto — 030_social_plats
-- Les plats de la carte vivent comme des publications (façon Facebook) :
--   * vues dédoublonnées (une fois par jour et par visiteur) ;
--   * J'aime (un par client) ;
--   * avis libres des clients connectés (commentaires), modérables par le
--     restaurant (menus.manage) ; les avis notés vérifiés (020) restent à part ;
--   * compteurs publics par plat (vues, J'aime, avis, favoris) pour la carte
--     côté client, et dans les indicateurs du module Menus.
-- À coller APRÈS 029, puis supabase/tests/030_social_plats_tests.sql.
-- =============================================================================

create table if not exists public.item_social (
  item_id uuid primary key references public.menu_items (id) on delete cascade,
  views integer not null default 0,
  likes integer not null default 0,
  comments integer not null default 0
);
create table if not exists public.item_views (
  item_id uuid not null references public.menu_items (id) on delete cascade,
  viewer_key text not null check (length(viewer_key) between 8 and 64),
  day date not null default current_date,
  primary key (item_id, viewer_key, day)
);
create table if not exists public.item_likes (
  item_id uuid not null references public.menu_items (id) on delete cascade,
  user_id uuid not null references auth.users (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (item_id, user_id)
);
create table if not exists public.item_comments (
  id uuid primary key default gen_random_uuid(),
  item_id uuid not null references public.menu_items (id) on delete cascade,
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
create index if not exists item_comments_item_idx on public.item_comments (item_id, created_at desc);

-- Lecture et écriture par les fonctions ci-dessous uniquement ; le client voit
-- ses J'aime, le restaurant lit les avis de ses plats.
alter table public.item_social enable row level security;
alter table public.item_views enable row level security;
alter table public.item_likes enable row level security;
alter table public.item_comments enable row level security;
grant select on public.item_likes, public.item_comments to authenticated;
drop policy if exists item_likes_own on public.item_likes;
drop policy if exists item_comments_read on public.item_comments;
create policy item_likes_own on public.item_likes for select to authenticated using (user_id = (select auth.uid()));
create policy item_comments_read on public.item_comments for select to authenticated
  using (user_id = (select auth.uid()) or organization_id in (select app_private.member_org_ids()));

-- Plat visible du public : actif, proposé dans un établissement publié d'une marque active.
create or replace function app_private.item_is_public(p_item uuid)
returns boolean language sql stable security definer set search_path = '' as $$
  select exists (select 1 from public.menu_items mi
                   join public.brands br on br.id = mi.brand_id and br.status = 'active'
                   join public.menu_item_branches mib on mib.item_id = mi.id
                   join public.branches b on b.id = mib.branch_id and b.is_published and b.status = 'active'
                  where mi.id = p_item and mi.active);
$$;

-- Recalcul des compteurs d'un plat.
create or replace function app_private.bump_item(p_item uuid)
returns void language plpgsql security definer set search_path = '' as $$
begin
  insert into public.item_social (item_id, views, likes, comments)
  values (p_item,
          (select count(*) from public.item_views v where v.item_id = p_item),
          (select count(*) from public.item_likes l where l.item_id = p_item),
          (select count(*) from public.item_comments c where c.item_id = p_item and c.status = 'published'))
  on conflict (item_id) do update
     set views = excluded.views, likes = excluded.likes, comments = excluded.comments;
end $$;

-- Vues des plats affichés (100 au plus par appel) : comptées une fois par jour
-- et par visiteur (compte, sinon identifiant anonyme de l'appareil).
create or replace function public.record_item_views(p_items uuid[], p_viewer text default null)
returns void language plpgsql security definer set search_path = '' as $$
declare
  v_key text := coalesce(auth.uid()::text, nullif(btrim(p_viewer), ''));
  v_item uuid;
  v_new integer;
begin
  if v_key is null or length(v_key) not between 8 and 64 or p_items is null then return; end if;
  foreach v_item in array p_items[1:100] loop
    if app_private.item_is_public(v_item) then
      insert into public.item_views (item_id, viewer_key) values (v_item, v_key) on conflict do nothing;
      get diagnostics v_new = row_count;
      if v_new > 0 then perform app_private.bump_item(v_item); end if;
    end if;
  end loop;
end $$;

create or replace function public.toggle_item_like(p_item uuid)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare v_liked boolean;
begin
  if auth.uid() is null then raise exception 'resto.not_authenticated' using errcode = '42501'; end if;
  if not app_private.item_is_public(p_item) then perform app_private.fail('resto.not_found'); end if;
  delete from public.item_likes where item_id = p_item and user_id = auth.uid();
  v_liked := not found;
  if v_liked then insert into public.item_likes (item_id, user_id) values (p_item, auth.uid()); end if;
  perform app_private.bump_item(p_item);
  return jsonb_build_object('liked', v_liked, 'likes', (select likes from public.item_social where item_id = p_item));
end $$;

-- Avis libre d'un client connecté (10 par heure au plus).
create or replace function public.add_item_comment(p_item uuid, p_body text)
returns uuid language plpgsql security definer set search_path = '' as $$
declare v_id uuid;
begin
  if auth.uid() is null then raise exception 'resto.not_authenticated' using errcode = '42501'; end if;
  if not app_private.item_is_public(p_item) then perform app_private.fail('resto.not_found'); end if;
  if length(btrim(coalesce(p_body, ''))) not between 1 and 500 then perform app_private.fail('resto.invalid_comment'); end if;
  if (select count(*) from public.item_comments where user_id = auth.uid() and created_at > now() - interval '1 hour') >= 10 then
    perform app_private.fail('resto.rate_limited');
  end if;
  insert into public.item_comments (item_id, organization_id, user_id, author_name, body)
  select p_item, mi.organization_id, auth.uid(), app_private.display_author(auth.uid()), btrim(p_body)
    from public.menu_items mi where mi.id = p_item
  returning id into v_id;
  perform app_private.bump_item(p_item);
  return v_id;
end $$;

-- Avis publiés d'un plat, les plus récents d'abord.
create or replace function public.public_item_comments(p_item uuid, p_limit integer default 50)
returns jsonb language sql stable security definer set search_path = '' as $$
  select coalesce(jsonb_agg(jsonb_build_object('id', m.id, 'author', m.author_name, 'body', m.body, 'created_at', m.created_at,
                                               'mine', m.user_id = auth.uid()) order by m.created_at desc), '[]'::jsonb)
    from (select * from public.item_comments
           where item_id = p_item and status = 'published' and app_private.item_is_public(p_item)
           order by created_at desc limit least(greatest(coalesce(p_limit, 50), 1), 100)) m;
$$;

-- Modération par le restaurant (menus.manage) : masquer avec un motif, ou republier.
create or replace function public.moderate_item_comment(p_comment uuid, p_hidden boolean, p_reason text default null)
returns void language plpgsql security definer set search_path = '' as $$
declare v public.item_comments;
begin
  select * into v from public.item_comments where id = p_comment;
  if v.id is null or not exists (select 1 from app_private.org_ids_with('menus.manage') x where x = v.organization_id) then
    raise exception 'resto.forbidden' using errcode = '42501';
  end if;
  if p_hidden then
    if length(btrim(coalesce(p_reason, ''))) < 3 then perform app_private.fail('resto.reason_required'); end if;
    update public.item_comments set status = 'hidden', hidden_reason = btrim(p_reason), hidden_by = auth.uid(), hidden_at = now()
     where id = p_comment;
  else
    update public.item_comments set status = 'published', hidden_reason = null, hidden_by = null, hidden_at = null
     where id = p_comment;
  end if;
  perform app_private.bump_item(v.item_id);
end $$;

-- Compteurs publics des plats d'un établissement publié, et réactions du client connecté.
create or replace function public.public_item_social(p_branch uuid)
returns jsonb language sql stable security definer set search_path = '' as $$
  select coalesce(jsonb_object_agg(mib.item_id, jsonb_build_object(
           'views', coalesce(s.views, 0), 'likes', coalesce(s.likes, 0), 'comments', coalesce(s.comments, 0),
           'favorites', (select count(*) from public.customer_item_favorites f where f.item_id = mib.item_id),
           'liked', exists (select 1 from public.item_likes l where l.item_id = mib.item_id and l.user_id = auth.uid()),
           'favorite', exists (select 1 from public.customer_item_favorites f where f.item_id = mib.item_id and f.user_id = auth.uid()))),
         '{}'::jsonb)
    from public.menu_item_branches mib
    join public.branches b on b.id = mib.branch_id and b.is_published and b.status = 'active'
    join public.menu_items mi on mi.id = mib.item_id and mi.active
    left join public.item_social s on s.item_id = mib.item_id
   where mib.branch_id = p_branch;
$$;

-- Indicateurs du module Menus : + vues, J'aime et avis libres.
create or replace function public.menu_item_stats(p_branch uuid)
returns jsonb language plpgsql stable security definer set search_path = '' as $$
begin
  if not exists (select 1 from app_private.member_branch_ids() x where x = p_branch) then
    raise exception 'resto.forbidden' using errcode = '42501';
  end if;
  return coalesce((
    select jsonb_object_agg(mib.item_id, jsonb_build_object(
             'rating', (select round(avg(r.rating), 1) from public.item_reviews r
                         where r.item_id = mib.item_id and r.branch_id = p_branch and r.status = 'published'),
             'reviews', (select count(*) from public.item_reviews r
                          where r.item_id = mib.item_id and r.branch_id = p_branch and r.status = 'published'),
             'favorites', (select count(*) from public.customer_item_favorites f where f.item_id = mib.item_id),
             'views', coalesce((select s.views from public.item_social s where s.item_id = mib.item_id), 0),
             'likes', coalesce((select s.likes from public.item_social s where s.item_id = mib.item_id), 0),
             'comments', coalesce((select s.comments from public.item_social s where s.item_id = mib.item_id), 0),
             'sold_30d', (select coalesce(sum(oi.quantity), 0) from public.order_items oi
                            join public.orders o on o.id = oi.order_id
                           where oi.item_id = mib.item_id and o.branch_id = p_branch and o.status = 'closed'
                             and oi.prep_status <> 'cancelled' and o.closed_at > now() - interval '30 days')))
      from public.menu_item_branches mib where mib.branch_id = p_branch), '{}'::jsonb);
end $$;

revoke all on function public.record_item_views(uuid[], text), public.toggle_item_like(uuid), public.add_item_comment(uuid, text),
  public.public_item_comments(uuid, integer), public.moderate_item_comment(uuid, boolean, text),
  public.public_item_social(uuid), public.menu_item_stats(uuid) from public, anon;
grant execute on function public.toggle_item_like(uuid), public.add_item_comment(uuid, text),
  public.moderate_item_comment(uuid, boolean, text), public.menu_item_stats(uuid) to authenticated;
grant execute on function public.record_item_views(uuid[], text), public.public_item_comments(uuid, integer),
  public.public_item_social(uuid) to anon, authenticated;

revoke all on all functions in schema app_private from public, anon, authenticated;
grant execute on function app_private.member_org_ids(), app_private.member_branch_ids(),
  app_private.org_ids_with(text), app_private.branch_ids_with(text),
  app_private.full_access_org_ids(), app_private.assigned_branch_ids(),
  app_private.org_ids_with_any_branch(text) to authenticated;
