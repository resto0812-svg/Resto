-- =============================================================================
-- Resto — 028 : compteurs publics des publicités (vues, j'aime, commentaires,
-- enregistrements) dans le fil « Découvrir » et le carrousel de l'accueil
-- client, pour mettre en avant les plats qui plaisent.
-- À coller APRÈS 027, puis supabase/tests/028_stats_publiques_pubs_tests.sql.
-- =============================================================================

-- Fil de découverte : + nombre de vues.
create or replace function public.public_feed(p_city text default null, p_limit integer default 20, p_offset integer default 0)
returns jsonb language sql stable security definer set search_path = '' as $$
  select coalesce(jsonb_agg(x), '[]'::jsonb) from (
    select jsonb_build_object(
      'id', c.id, 'format', c.format, 'title', c.title, 'body', c.body, 'cta_label', c.cta_label, 'cta_url', c.cta_url,
      'media', c.media, 'sponsored', coalesce(c.daily_budget_minor, 0) > 0,
      'views', c.views, 'likes', c.likes, 'comments', c.comments, 'saves', c.saves, 'shares', c.shares,
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

-- Publicités de l'accueil et de la page restaurant : + compteurs.
create or replace function public.public_ads(p_branch uuid default null, p_limit integer default 20)
returns jsonb language sql stable security definer set search_path = '' as $$
  select coalesce(jsonb_agg(x order by x ->> 'starts_at' desc), '[]'::jsonb) from (
    select jsonb_build_object(
      'id', c.id, 'format', c.format, 'title', c.title, 'body', c.body, 'cta_label', c.cta_label,
      'cta_url', c.cta_url, 'media', c.media, 'item_ids', c.item_ids, 'starts_at', c.starts_at, 'ends_at', c.ends_at,
      'views', c.views, 'likes', c.likes, 'comments', c.comments, 'saves', c.saves,
      'brand_name', br.name, 'logo_path', br.logo_path,
      'branch_id', (select b.id from public.branches b
                     where b.brand_id = c.brand_id and b.is_published and b.status = 'active'
                       and (cardinality(c.branch_ids) = 0 or b.id = any (c.branch_ids))
                       and (p_branch is null or b.id = p_branch)
                     order by b.created_at limit 1)) as x
      from public.ad_campaigns c
      join public.brands br on br.id = c.brand_id and br.status = 'active'
     where c.status = 'active' and c.format <> 'push'
       and c.starts_at <= now() and (c.ends_at is null or c.ends_at > now())
       and exists (select 1 from public.branches b
                    where b.brand_id = c.brand_id and b.is_published and b.status = 'active'
                      and (cardinality(c.branch_ids) = 0 or b.id = any (c.branch_ids))
                      and (p_branch is null or b.id = p_branch))
     limit least(greatest(coalesce(p_limit, 20), 1), 50)
  ) s;
$$;

revoke all on function public.public_feed(text, integer, integer), public.public_ads(uuid, integer) from public;
grant execute on function public.public_feed(text, integer, integer), public.public_ads(uuid, integer) to anon, authenticated;

revoke all on all functions in schema app_private from public, anon, authenticated;
grant execute on function app_private.member_org_ids(), app_private.member_branch_ids(),
  app_private.org_ids_with(text), app_private.branch_ids_with(text),
  app_private.full_access_org_ids(), app_private.assigned_branch_ids(),
  app_private.org_ids_with_any_branch(text) to authenticated;
