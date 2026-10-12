-- =============================================================================
-- Resto — 020_accueil_avis
-- Lot 1 — Accueil personnalisé :
--   * position du client (domicile, adresses géolocalisées), avec son accord ;
--   * promotions publiques ; plats populaires (note pondérée × commandes
--     réelles), nouveautés ; commandes en cours, « recommander », suggestions.
-- Lot 2 — Avis vérifiés par plat :
--   * seul un client qui a reçu le plat peut le noter (commande annulée ou
--     plat annulé : non) ; photos, votes « utile », signalements ; le
--     restaurant masque un avis avec un motif (traçable), sans le modifier.
-- À coller APRÈS 019, puis supabase/tests/020_accueil_avis_tests.sql.
-- =============================================================================

-- Libellé de la permission « Publicité » (018 l'avait enregistré avec des accents abîmés).
update public.permissions set description = 'Publicité : campagnes, médiathèque, statistiques' where code = 'marketing.manage';

-- -----------------------------------------------------------------------------
-- 1. Position du client
-- -----------------------------------------------------------------------------
alter table public.customer_profiles
  add column if not exists home_latitude numeric(9, 6) check (home_latitude between -90 and 90),
  add column if not exists home_longitude numeric(9, 6) check (home_longitude between -180 and 180),
  add column if not exists home_label text check (length(home_label) <= 120),
  add column if not exists share_allergies boolean not null default true;
grant insert (home_latitude, home_longitude, home_label, share_allergies),
  update (home_latitude, home_longitude, home_label, share_allergies) on public.customer_profiles to authenticated;

alter table public.customer_addresses
  add column if not exists latitude numeric(9, 6) check (latitude between -90 and 90),
  add column if not exists longitude numeric(9, 6) check (longitude between -180 and 180);
grant insert (latitude, longitude), update (latitude, longitude) on public.customer_addresses to authenticated;

-- -----------------------------------------------------------------------------
-- 2. Promotions visibles des clients
-- -----------------------------------------------------------------------------
alter table public.promotions add column if not exists is_public boolean not null default false;
grant insert (is_public), update (is_public) on public.promotions to authenticated;

-- -----------------------------------------------------------------------------
-- 3. Avis vérifiés par plat
-- -----------------------------------------------------------------------------
create table if not exists public.item_reviews (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null,
  branch_id uuid not null,
  item_id uuid not null,
  order_id uuid not null,
  order_item_id uuid not null unique,
  user_id uuid not null references auth.users (id) on delete cascade,
  author_name text not null check (length(author_name) between 1 and 60),
  rating smallint not null check (rating between 1 and 5),
  comment text check (length(comment) <= 1000),
  photo_paths text[] not null default '{}' check (cardinality(photo_paths) <= 4),
  status text not null default 'published' check (status in ('published', 'hidden')),
  helpful_count integer not null default 0,
  reports_count integer not null default 0,
  hidden_reason text check (length(hidden_reason) <= 300),
  hidden_by uuid references auth.users (id) on delete set null,
  hidden_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  foreign key (organization_id, item_id) references public.menu_items (organization_id, id) on delete cascade,
  foreign key (organization_id, order_id) references public.orders (organization_id, id) on delete cascade,
  check ((status = 'hidden') = (hidden_at is not null))
);
create index if not exists item_reviews_item_idx on public.item_reviews (item_id, status, created_at desc);

create table if not exists public.item_review_votes (
  review_id uuid not null references public.item_reviews (id) on delete cascade,
  user_id uuid not null references auth.users (id) on delete cascade,
  primary key (review_id, user_id)
);
create table if not exists public.item_review_reports (
  review_id uuid not null references public.item_reviews (id) on delete cascade,
  user_id uuid not null references auth.users (id) on delete cascade,
  reason text not null check (length(btrim(reason)) between 3 and 300),
  created_at timestamptz not null default now(),
  primary key (review_id, user_id)
);

alter table public.item_reviews enable row level security;
alter table public.item_review_votes enable row level security;
alter table public.item_review_reports enable row level security;
-- Lecture : l'auteur, et les membres du restaurant concerné ; écriture par les fonctions seulement.
grant select on public.item_reviews to authenticated;
drop policy if exists item_reviews_read on public.item_reviews;
create policy item_reviews_read on public.item_reviews for select to authenticated
  using (user_id = (select auth.uid()) or organization_id in (select app_private.member_org_ids()));
grant select on public.item_review_reports to authenticated;
drop policy if exists item_review_reports_read on public.item_review_reports;
create policy item_review_reports_read on public.item_review_reports for select to authenticated
  using (user_id = (select auth.uid())
         or exists (select 1 from public.item_reviews r where r.id = review_id
                     and r.organization_id in (select app_private.member_org_ids())));

-- Photos des avis : bucket public, chaque client écrit dans son dossier {utilisateur}/.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('review-photos', 'review-photos', true, 5242880, array['image/jpeg', 'image/png', 'image/webp'])
on conflict (id) do update set public = true, file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;
drop policy if exists resto_review_photos_insert on storage.objects;
drop policy if exists resto_review_photos_delete on storage.objects;
create policy resto_review_photos_insert on storage.objects for insert to authenticated
  with check (bucket_id = 'review-photos' and (storage.foldername(name))[1] = (select auth.uid())::text);
create policy resto_review_photos_delete on storage.objects for delete to authenticated
  using (bucket_id = 'review-photos' and (storage.foldername(name))[1] = (select auth.uid())::text);

-- Nom affiché : prénom et initiale (jamais l'e-mail).
create or replace function app_private.display_author(p_user uuid)
returns text language sql stable security definer set search_path = '' as $$
  select coalesce(
    (select case when position(' ' in btrim(cp.full_name)) > 0
                 then split_part(btrim(cp.full_name), ' ', 1) || ' '
                      || left(split_part(btrim(cp.full_name), ' ', 2), 1) || '.'
                 else left(btrim(cp.full_name), 60) end
       from public.customer_profiles cp where cp.user_id = p_user and length(btrim(coalesce(cp.full_name, ''))) > 0),
    (select left(nullif(btrim(p.display_name), ''), 60) from public.profiles p where p.id = p_user),
    'Client');
$$;

-- Avis sur un plat reçu (une fois par ligne de commande ; modifiable par son auteur).
create or replace function public.submit_item_review(
  p_order_item uuid, p_rating integer, p_comment text default null, p_photos text[] default '{}')
returns uuid language plpgsql security definer set search_path = '' as $$
declare
  v_uid uuid := auth.uid();
  v_line public.order_items;
  v_order public.orders;
  v_id uuid;
  v_path text;
begin
  if v_uid is null then raise exception 'resto.not_authenticated' using errcode = '42501'; end if;
  select * into v_line from public.order_items where id = p_order_item;
  select * into v_order from public.orders where id = v_line.order_id;
  if v_line.id is null or v_order.customer_user_id is distinct from v_uid then
    raise exception 'resto.forbidden' using errcode = '42501';
  end if;
  if v_order.status = 'cancelled' or v_line.prep_status = 'cancelled'
     or not (v_order.status = 'closed' or v_line.prep_status = 'served') then
    perform app_private.fail('resto.review_not_allowed');
  end if;
  if coalesce(p_rating, 0) not between 1 and 5 then perform app_private.fail('resto.invalid_rating'); end if;
  if cardinality(coalesce(p_photos, '{}')) > 4 then perform app_private.fail('resto.invalid_media'); end if;
  foreach v_path in array coalesce(p_photos, '{}') loop
    if v_path not like v_uid::text || '/%' or length(v_path) > 300 then perform app_private.fail('resto.invalid_media'); end if;
  end loop;
  insert into public.item_reviews (organization_id, branch_id, item_id, order_id, order_item_id, user_id, author_name,
                                   rating, comment, photo_paths)
  values (v_order.organization_id, v_order.branch_id, v_line.item_id, v_order.id, v_line.id, v_uid,
          app_private.display_author(v_uid), p_rating, nullif(btrim(p_comment), ''), coalesce(p_photos, '{}'))
  on conflict (order_item_id) do update
     set rating = excluded.rating, comment = excluded.comment, photo_paths = excluded.photo_paths, updated_at = now()
  returning id into v_id;
  return v_id;
end $$;

-- « Utile » : un vote par client, compteur recalculé.
create or replace function public.vote_item_review(p_review uuid, p_helpful boolean)
returns integer language plpgsql security definer set search_path = '' as $$
declare v_count integer;
begin
  if auth.uid() is null then raise exception 'resto.not_authenticated' using errcode = '42501'; end if;
  if not exists (select 1 from public.item_reviews where id = p_review and status = 'published') then
    perform app_private.fail('resto.not_found');
  end if;
  if p_helpful then
    insert into public.item_review_votes (review_id, user_id) values (p_review, auth.uid()) on conflict do nothing;
  else
    delete from public.item_review_votes where review_id = p_review and user_id = auth.uid();
  end if;
  select count(*) into v_count from public.item_review_votes where review_id = p_review;
  update public.item_reviews set helpful_count = v_count where id = p_review;
  return v_count;
end $$;

-- Signalement d'un avis abusif (un par client).
create or replace function public.report_item_review(p_review uuid, p_reason text)
returns void language plpgsql security definer set search_path = '' as $$
begin
  if auth.uid() is null then raise exception 'resto.not_authenticated' using errcode = '42501'; end if;
  if length(btrim(coalesce(p_reason, ''))) < 3 then perform app_private.fail('resto.reason_required'); end if;
  if not exists (select 1 from public.item_reviews where id = p_review) then perform app_private.fail('resto.not_found'); end if;
  insert into public.item_review_reports (review_id, user_id, reason) values (p_review, auth.uid(), btrim(p_reason))
  on conflict do nothing;
  update public.item_reviews set reports_count = (select count(*) from public.item_review_reports where review_id = p_review)
   where id = p_review;
end $$;

-- Modération par le restaurant (customers.manage) : masquer avec un motif, ou republier.
create or replace function public.moderate_item_review(p_review uuid, p_hidden boolean, p_reason text default null)
returns void language plpgsql security definer set search_path = '' as $$
declare v public.item_reviews;
begin
  select * into v from public.item_reviews where id = p_review;
  if v.id is null then raise exception 'resto.forbidden' using errcode = '42501'; end if;
  perform app_private.assert_branch_perm(v.branch_id, 'customers.manage');
  if p_hidden then
    if length(btrim(coalesce(p_reason, ''))) < 3 then perform app_private.fail('resto.reason_required'); end if;
    update public.item_reviews set status = 'hidden', hidden_reason = btrim(p_reason), hidden_by = auth.uid(), hidden_at = now()
     where id = p_review;
  else
    update public.item_reviews set status = 'published', hidden_reason = null, hidden_by = null, hidden_at = null
     where id = p_review;
  end if;
end $$;

-- Avis publiés d'un plat : récents, utiles ou meilleures notes.
create or replace function public.public_item_reviews(p_item uuid, p_sort text default 'recent', p_limit integer default 20,
                                                      p_offset integer default 0)
returns jsonb language sql stable security definer set search_path = '' as $$
  select coalesce(jsonb_agg(x), '[]'::jsonb) from (
    select jsonb_build_object(
      'id', r.id, 'rating', r.rating, 'comment', r.comment, 'photos', to_jsonb(r.photo_paths), 'author', r.author_name,
      'helpful', r.helpful_count, 'created_at', r.created_at, 'verified', true,
      'voted', exists (select 1 from public.item_review_votes v where v.review_id = r.id and v.user_id = auth.uid()),
      'mine', r.user_id = auth.uid()) as x
      from public.item_reviews r
     where r.item_id = p_item and r.status = 'published'
     order by case when p_sort = 'helpful' then r.helpful_count end desc nulls last,
              case when p_sort = 'best' then r.rating end desc nulls last,
              case when p_sort = 'worst' then r.rating end asc nulls last,
              r.created_at desc
     limit least(greatest(coalesce(p_limit, 20), 1), 50) offset greatest(coalesce(p_offset, 0), 0)
  ) s;
$$;

-- Note de chaque plat d'un établissement : moyenne, nombre d'avis, % de clients satisfaits (4 ou 5).
create or replace function public.public_item_ratings(p_branch uuid)
returns jsonb language sql stable security definer set search_path = '' as $$
  select coalesce(jsonb_object_agg(s.item_id, jsonb_build_object('average', s.average, 'count', s.n, 'satisfied', s.satisfied)),
                  '{}'::jsonb)
    from (select r.item_id, round(avg(r.rating), 1) as average, count(*) as n,
                 round(100.0 * count(*) filter (where r.rating >= 4) / count(*)) as satisfied
            from public.item_reviews r
           where r.branch_id = p_branch and r.status = 'published'
           group by r.item_id) s;
$$;

-- Score de popularité : note pondérée (moyenne bayésienne, 10 avis fictifs à 4,2)
-- × logarithme des commandes réelles des 30 derniers jours. Une seule note de 5
-- ne dépasse pas des centaines d'excellentes évaluations.
create or replace function app_private.item_popularity(p_item uuid, p_branch uuid)
returns numeric language sql stable security definer set search_path = '' as $$
  select ((10 * 4.2 + coalesce(sum(r.rating), 0)) / (10 + count(r.id)))
         * ln(2 + (select coalesce(sum(oi.quantity), 0) from public.order_items oi
                     join public.orders o on o.id = oi.order_id
                    where oi.item_id = p_item and o.branch_id = p_branch and o.status = 'closed'
                      and oi.prep_status <> 'cancelled' and o.closed_at > now() - interval '30 days'))
    from public.item_reviews r
   where r.item_id = p_item and r.branch_id = p_branch and r.status = 'published';
$$;

-- -----------------------------------------------------------------------------
-- 4. Accueil public : populaires, nouveautés, promotions
-- -----------------------------------------------------------------------------
create or replace function public.public_home(p_city text default null, p_limit integer default 12)
returns jsonb language sql stable security definer set search_path = '' as $$
  with live as (
    select b.id, b.brand_id, b.organization_id, b.currency, b.latitude, b.longitude, br.name as brand_name, br.logo_path
      from public.branches b
      join public.brands br on br.id = b.brand_id and br.status = 'active'
      join public.organizations o on o.id = b.organization_id and o.status = 'active'
     where b.is_published and b.status = 'active' and not b.vacation_mode
       and (p_city is null or btrim(p_city) = '' or lower(b.city) = lower(btrim(p_city)))
  ), offers as (
    select mi.id as item_id, mi.name, mi.description, mi.image_path, mi.created_at, l.id as branch_id, l.brand_name,
           l.currency, l.latitude, l.longitude,
           (select min(p.amount_minor) from public.prices p join public.item_variants v on v.id = p.variant_id and v.active
             where v.item_id = mi.id and p.branch_id = l.id and p.channel = 'default' and p.valid_to is null) as price_minor,
           (select round(avg(r.rating), 1) from public.item_reviews r where r.item_id = mi.id and r.branch_id = l.id and r.status = 'published') as rating,
           (select count(*) from public.item_reviews r where r.item_id = mi.id and r.branch_id = l.id and r.status = 'published') as reviews
      from live l
      join public.menu_item_branches mib on mib.branch_id = l.id and mib.available
      join public.menu_items mi on mi.id = mib.item_id and mi.active
  )
  select jsonb_build_object(
    'popular', coalesce((select jsonb_agg(to_jsonb(p) - 'created_at' order by p.score desc) from (
        select o.*, app_private.item_popularity(o.item_id, o.branch_id) as score
          from offers o where o.price_minor is not null
         order by app_private.item_popularity(o.item_id, o.branch_id) desc, o.image_path is null
         limit least(greatest(coalesce(p_limit, 12), 1), 40)) p), '[]'::jsonb),
    'new_items', coalesce((select jsonb_agg(to_jsonb(n) order by n.created_at desc) from (
        select o.* from offers o where o.price_minor is not null and o.created_at > now() - interval '30 days'
         order by o.created_at desc limit least(greatest(coalesce(p_limit, 12), 1), 40)) n), '[]'::jsonb),
    'promos', coalesce((select jsonb_agg(jsonb_build_object(
        'id', pr.id, 'name', pr.name, 'kind', pr.kind, 'percent', pr.percent, 'amount_minor', pr.amount_minor,
        'code', pr.code, 'min_order_minor', pr.min_order_minor, 'ends_at', pr.ends_at,
        'branch_id', coalesce(pr.branch_id, (select l2.id from live l2 where l2.organization_id = pr.organization_id limit 1)),
        'brand_name', (select l3.brand_name from live l3 where l3.organization_id = pr.organization_id
                         and (pr.branch_id is null or l3.id = pr.branch_id) limit 1),
        'logo_path', (select l3.logo_path from live l3 where l3.organization_id = pr.organization_id
                        and (pr.branch_id is null or l3.id = pr.branch_id) limit 1),
        'currency', (select l3.currency from live l3 where l3.organization_id = pr.organization_id
                       and (pr.branch_id is null or l3.id = pr.branch_id) limit 1)))
        from public.promotions pr
       where pr.is_public and pr.active
         and (pr.starts_at is null or pr.starts_at <= now()) and (pr.ends_at is null or pr.ends_at > now())
         and (pr.max_uses is null or pr.uses_count < pr.max_uses)
         and exists (select 1 from live l where l.organization_id = pr.organization_id and (pr.branch_id is null or l.id = pr.branch_id))),
      '[]'::jsonb));
$$;

-- -----------------------------------------------------------------------------
-- 5. Accueil du client connecté : commandes en cours, recommander, suggestions
-- -----------------------------------------------------------------------------
create or replace function public.my_home()
returns jsonb language plpgsql stable security definer set search_path = '' as $$
declare v_uid uuid := auth.uid();
begin
  if v_uid is null then return jsonb_build_object('active', '[]'::jsonb, 'reorder', '[]'::jsonb, 'suggested', '[]'::jsonb); end if;
  return jsonb_build_object(
    'active', coalesce((select jsonb_agg(jsonb_build_object(
        'order_id', o.id, 'number', o.number, 'branch_id', o.branch_id, 'brand_name', br.name, 'channel', o.channel,
        'acceptance', o.acceptance, 'total_minor', o.total_minor, 'currency', o.currency, 'opened_at', o.opened_at,
        'ready', not exists (select 1 from public.order_items oi where oi.order_id = o.id
                              and oi.prep_status not in ('ready', 'served', 'cancelled')))
        order by o.opened_at desc)
        from public.orders o join public.brands br on br.id = o.brand_id
       where o.customer_user_id = v_uid and o.status = 'open' and o.acceptance <> 'rejected'), '[]'::jsonb),
    'reorder', coalesce((select jsonb_agg(x order by x ->> 'closed_at' desc) from (
        select jsonb_build_object(
          'order_id', o.id, 'branch_id', o.branch_id, 'brand_name', br.name, 'logo_path', br.logo_path, 'closed_at', o.closed_at,
          'total_minor', o.total_minor, 'currency', o.currency,
          'lines', (select coalesce(jsonb_agg(jsonb_build_object(
                      'item_id', oi.item_id, 'variant_id', oi.variant_id, 'name', oi.item_name, 'quantity', oi.quantity,
                      'modifier_ids', coalesce((select jsonb_agg(m.modifier_id) from public.order_item_modifiers m
                                                 where m.order_item_id = oi.id and m.modifier_id is not null), '[]'::jsonb))), '[]'::jsonb)
                      from public.order_items oi where oi.order_id = o.id and oi.prep_status <> 'cancelled')) as x
          from public.orders o join public.brands br on br.id = o.brand_id
         where o.customer_user_id = v_uid and o.status = 'closed'
         order by o.closed_at desc limit 6) s), '[]'::jsonb),
    'suggested', coalesce((select jsonb_agg(to_jsonb(g) order by g.score desc) from (
        select mi.id as item_id, mi.name, mi.image_path, b.id as branch_id, br.name as brand_name, b.currency,
               (select min(p.amount_minor) from public.prices p join public.item_variants v on v.id = p.variant_id and v.active
                 where v.item_id = mi.id and p.branch_id = b.id and p.channel = 'default' and p.valid_to is null) as price_minor,
               app_private.item_popularity(mi.id, b.id) as score
          from public.branches b
          join public.brands br on br.id = b.brand_id and br.status = 'active'
          join public.menu_item_branches mib on mib.branch_id = b.id and mib.available
          join public.menu_items mi on mi.id = mib.item_id and mi.active
         where b.is_published and b.status = 'active' and not b.vacation_mode
           -- restaurants déjà fréquentés, ou familles de plats déjà commandées
           and (b.id in (select o.branch_id from public.orders o where o.customer_user_id = v_uid and o.status = 'closed')
                or mi.kind in (select mi2.kind from public.order_items oi2 join public.orders o2 on o2.id = oi2.order_id
                                 join public.menu_items mi2 on mi2.id = oi2.item_id where o2.customer_user_id = v_uid))
           -- pas encore goûtés
           and not exists (select 1 from public.order_items oi3 join public.orders o3 on o3.id = oi3.order_id
                            where o3.customer_user_id = v_uid and oi3.item_id = mi.id)
         order by app_private.item_popularity(mi.id, b.id) desc limit 12) g
       where g.price_minor is not null), '[]'::jsonb));
end $$;

revoke all on function public.submit_item_review(uuid, integer, text, text[]), public.vote_item_review(uuid, boolean),
  public.report_item_review(uuid, text), public.moderate_item_review(uuid, boolean, text),
  public.public_item_reviews(uuid, text, integer, integer), public.public_item_ratings(uuid),
  public.public_home(text, integer), public.my_home() from public, anon;
grant execute on function public.submit_item_review(uuid, integer, text, text[]), public.vote_item_review(uuid, boolean),
  public.report_item_review(uuid, text), public.moderate_item_review(uuid, boolean, text), public.my_home() to authenticated;
grant execute on function public.public_item_reviews(uuid, text, integer, integer), public.public_item_ratings(uuid),
  public.public_home(text, integer) to anon, authenticated;

revoke all on all functions in schema app_private from public, anon, authenticated;
grant execute on function app_private.member_org_ids(), app_private.member_branch_ids(),
  app_private.org_ids_with(text), app_private.branch_ids_with(text),
  app_private.full_access_org_ids(), app_private.assigned_branch_ids(),
  app_private.org_ids_with_any_branch(text) to authenticated;
