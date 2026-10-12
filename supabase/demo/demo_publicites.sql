-- =============================================================================
-- Resto — données de DÉMONSTRATION (environnement de développement seulement)
-- Crée, pour chaque marque qui a un établissement publié :
--   * une petite annonce (annonce flottante de l'accueil + fil « Découvrir ») ;
--   * des plats mis en avant (stories de l'accueil + fil « Découvrir »), avec
--     jusqu'à 4 plats qui ont une photo.
-- Diffusion active 7 jours, signalée « Sponsorisé ». Sans effet si elles existent déjà.
-- Les vidéos et carrousels se créent dans l'application : Publicité › Créer.
-- À coller dans l'éditeur SQL de Supabase (pas une migration).
-- =============================================================================
with live as (
  select distinct on (b.brand_id) b.organization_id, b.brand_id, b.id as branch_id, b.currency, br.name as brand_name
    from public.branches b
    join public.brands br on br.id = b.brand_id and br.status = 'active'
   where b.is_published and b.status = 'active'
   order by b.brand_id, b.created_at
)
insert into public.ad_campaigns (organization_id, brand_id, format, title, body, cta_label, status, daily_budget_minor,
                                 currency, starts_at, ends_at)
select l.organization_id, l.brand_id, 'classified', 'Offre du jour : -15 % sur toute la carte',
       'Ce midi et ce soir chez ' || l.brand_name || '. Présentez-vous de la part de Resto !', 'Commander',
       'active', 1000, l.currency, now(), now() + interval '7 days'
  from live l
 where not exists (select 1 from public.ad_campaigns c where c.brand_id = l.brand_id and c.title = 'Offre du jour : -15 % sur toute la carte');

with live as (
  select distinct on (b.brand_id) b.organization_id, b.brand_id, b.id as branch_id, b.currency, br.name as brand_name
    from public.branches b
    join public.brands br on br.id = b.brand_id and br.status = 'active'
   where b.is_published and b.status = 'active'
   order by b.brand_id, b.created_at
), dishes as (
  select l.brand_id, array_agg(mi.id order by mi.created_at desc) filter (where mi.image_path is not null) as ids
    from live l
    join public.menu_items mi on mi.brand_id = l.brand_id and mi.active
   group by l.brand_id
)
insert into public.ad_campaigns (organization_id, brand_id, format, title, body, cta_label, item_ids, status, daily_budget_minor,
                                 currency, starts_at, ends_at)
select l.organization_id, l.brand_id, 'sponsored_menu', 'Nos plats signature',
       'Les préférés de nos clients, à découvrir chez ' || l.brand_name || '.', 'Voir la carte',
       d.ids[1:4], 'active', 2000, l.currency, now(), now() + interval '7 days'
  from live l
  join dishes d on d.brand_id = l.brand_id and cardinality(d.ids) > 0
 where not exists (select 1 from public.ad_campaigns c where c.brand_id = l.brand_id and c.title = 'Nos plats signature');

select br.name as marque, c.format, c.title, c.status, c.ends_at
  from public.ad_campaigns c join public.brands br on br.id = c.brand_id
 where c.title in ('Offre du jour : -15 % sur toute la carte', 'Nos plats signature')
 order by br.name, c.format;
