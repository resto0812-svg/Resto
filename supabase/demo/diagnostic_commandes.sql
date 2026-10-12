-- =============================================================================
-- Resto — DIAGNOSTIC : pourquoi un client ne peut pas commander ?
-- À coller dans l'éditeur SQL de Supabase (lecture seule, ne modifie rien).
-- Une commande en ligne exige : établissement publié et actif, « Commandes en
-- ligne » activées, plats disponibles dans l'établissement, avec un prix.
-- =============================================================================
select b.name as etablissement,
       b.is_published as publie,
       b.status as statut,
       b.accepts_online_orders as commandes_en_ligne,
       b.accepts_delivery as livraison,
       b.min_order_minor as minimum_commande,
       (select count(*) from public.menu_item_branches mib where mib.branch_id = b.id and mib.available) as plats_disponibles,
       (select count(*) from public.menu_item_branches mib
         where mib.branch_id = b.id and mib.available
           and exists (select 1 from public.item_variants v join public.prices p on p.variant_id = v.id
                        where v.item_id = mib.item_id and v.active and p.branch_id = b.id and p.valid_to is null)) as plats_avec_prix,
       (select count(*) from public.orders o where o.branch_id = b.id and o.source in ('app', 'qr')) as commandes_clients_recues
  from public.branches b
 order by b.name;

-- Si « commandes_en_ligne » vaut false : dans l'interface Entreprise,
-- Paramètres › Commandes en ligne › activer « Accepter les commandes en ligne ».
-- Si « plats_avec_prix » vaut 0 : Menus › chaque plat › Prix de vente.
