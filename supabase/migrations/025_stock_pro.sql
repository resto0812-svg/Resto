-- =============================================================================
-- Resto — 025_stock_pro
-- Module Stock professionnel :
--   1. fiche article complète (photo, code-barres, conservation, unité
--      d'achat et contenance, fournisseur habituel, durée de conservation) ;
--   2. objectif de coût matière par établissement (alerte de marge) ;
--   3. tableau de bord du stock (valeur, alertes, consommation, pertes,
--      réceptions, écarts d'inventaire, par jour, top consommations) ;
--   4. lots qui arrivent à leur date limite (méthode « premier entré,
--      premier sorti ») ;
--   5. commande suggérée (seuil + consommation moyenne des 28 derniers jours).
-- Les bons de commande se créent avec save_purchase_order (009).
-- À coller APRÈS 024, puis supabase/tests/025_stock_pro_tests.sql.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. Fiche article
-- -----------------------------------------------------------------------------
alter table public.ingredients
  add column if not exists image_path text check (image_path is null or length(image_path) <= 300),
  add column if not exists barcode text check (length(barcode) <= 60),
  add column if not exists storage text not null default 'ambient' check (storage in ('ambient', 'chilled', 'frozen')),
  add column if not exists purchase_unit_label text check (length(purchase_unit_label) <= 40),
  add column if not exists purchase_unit_qty numeric(18, 4) check (purchase_unit_qty is null or purchase_unit_qty > 0),
  add column if not exists preferred_supplier_id uuid,
  add column if not exists shelf_life_days smallint check (shelf_life_days is null or shelf_life_days between 1 and 3650);
alter table public.ingredients drop constraint if exists ingredients_preferred_supplier_fk;
alter table public.ingredients add constraint ingredients_preferred_supplier_fk
  foreign key (organization_id, preferred_supplier_id) references public.suppliers (organization_id, id) on delete restrict;
grant insert (image_path, barcode, storage, purchase_unit_label, purchase_unit_qty, preferred_supplier_id, shelf_life_days),
  update (image_path, barcode, storage, purchase_unit_label, purchase_unit_qty, preferred_supplier_id, shelf_life_days)
  on public.ingredients to authenticated;

-- La photo est rangée dans le dossier de l'organisation.
create or replace function app_private.check_ingredient_image()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  if new.image_path is not null and new.image_path not like new.organization_id::text || '/%' then
    perform app_private.fail('resto.invalid_image');
  end if;
  return new;
end $$;
drop trigger if exists ingredients_check_image on public.ingredients;
create trigger ingredients_check_image before insert or update of image_path on public.ingredients
  for each row execute function app_private.check_ingredient_image();

-- Photos des articles de stock : bucket public (aucune donnée personnelle),
-- écriture par les membres ayant stock.write, dans le dossier de leur organisation.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('stock-images', 'stock-images', true, 2097152, array['image/jpeg', 'image/png', 'image/webp'])
on conflict (id) do update set public = true, file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;
drop policy if exists resto_stock_images_insert on storage.objects;
drop policy if exists resto_stock_images_update on storage.objects;
drop policy if exists resto_stock_images_delete on storage.objects;
create policy resto_stock_images_insert on storage.objects for insert to authenticated
  with check (bucket_id = 'stock-images'
    and (storage.foldername(name))[1] in (select x::text from app_private.org_ids_with('stock.write') x));
create policy resto_stock_images_update on storage.objects for update to authenticated
  using (bucket_id = 'stock-images'
    and (storage.foldername(name))[1] in (select x::text from app_private.org_ids_with('stock.write') x))
  with check (bucket_id = 'stock-images'
    and (storage.foldername(name))[1] in (select x::text from app_private.org_ids_with('stock.write') x));
create policy resto_stock_images_delete on storage.objects for delete to authenticated
  using (bucket_id = 'stock-images'
    and (storage.foldername(name))[1] in (select x::text from app_private.org_ids_with('stock.write') x));

-- -----------------------------------------------------------------------------
-- 2. Objectif de coût matière (part du prix de vente)
-- -----------------------------------------------------------------------------
alter table public.branches
  add column if not exists target_food_cost_percent numeric(5, 2) not null default 30
    check (target_food_cost_percent between 1 and 95);
grant update (target_food_cost_percent) on public.branches to authenticated;

-- -----------------------------------------------------------------------------
-- 3. Tableau de bord du stock (période en jours locaux de l'établissement)
-- -----------------------------------------------------------------------------
create or replace function public.stock_dashboard(p_branch uuid, p_from date, p_to date)
returns jsonb language plpgsql stable security definer set search_path = '' as $$
declare
  v_branch public.branches;
  v_from timestamptz;
  v_to timestamptz;
begin
  perform app_private.assert_branch_perm(p_branch, 'stock.read');
  select * into v_branch from public.branches where id = p_branch;
  if p_from is null or p_to is null or p_to < p_from or p_to - p_from > 400 then perform app_private.fail('resto.invalid_period'); end if;
  v_from := p_from::timestamp at time zone v_branch.timezone;
  v_to := (p_to + 1)::timestamp at time zone v_branch.timezone;
  return (
    with levels as (
      select i.id, coalesce(sum(m.quantity), 0) as qty, coalesce(s.min_quantity, 0) as min_qty, coalesce(s.avg_unit_cost, 0) as cost
        from public.ingredients i
        left join public.stock_movements m on m.ingredient_id = i.id and m.branch_id = p_branch
        left join public.ingredient_stock s on s.ingredient_id = i.id and s.branch_id = p_branch
       where i.organization_id = v_branch.organization_id and i.active
       group by i.id, s.min_quantity, s.avg_unit_cost
    ), period as (
      select m.*, (m.created_at at time zone v_branch.timezone)::date as day
        from public.stock_movements m
       where m.branch_id = p_branch and m.created_at >= v_from and m.created_at < v_to
    )
    select jsonb_build_object(
      'value_minor', (select coalesce(round(sum(greatest(qty, 0) * cost)), 0) from levels),
      'items', (select count(*) from levels),
      'below_min', (select count(*) from levels where min_qty > 0 and qty <= min_qty and qty > 0),
      'out_of_stock', (select count(*) from levels where qty <= 0 and (min_qty > 0 or cost > 0)),
      'expiring', (select count(*) from public.stock_expiring(p_branch, 3)),
      'consumption_minor', (select coalesce(round(sum(-quantity * unit_cost)), 0) from period where kind in ('sale', 'staff_meal')),
      'waste_minor', (select coalesce(round(sum(-quantity * unit_cost)), 0) from period where kind = 'waste'),
      'receipts_minor', (select coalesce(round(sum(quantity * unit_cost)), 0) from period where kind = 'receipt'),
      'inventory_variance_minor', (select coalesce(round(sum(quantity * unit_cost)), 0) from period where kind = 'inventory'),
      'by_day', coalesce((select jsonb_agg(jsonb_build_object('day', d.day, 'consumption', d.c, 'waste', d.w, 'receipts', d.r) order by d.day)
                            from (select day,
                                         round(sum(-quantity * unit_cost) filter (where kind in ('sale', 'staff_meal'))) as c,
                                         round(sum(-quantity * unit_cost) filter (where kind = 'waste')) as w,
                                         round(sum(quantity * unit_cost) filter (where kind = 'receipt')) as r
                                    from period group by day) d), '[]'::jsonb),
      'top_consumed', coalesce((select jsonb_agg(jsonb_build_object('ingredient_id', t.ingredient_id, 'name', i.name,
                                                                      'unit_code', i.unit_code, 'quantity', t.q, 'value', t.v)
                                                   order by t.v desc)
                                  from (select ingredient_id, sum(-quantity) as q, round(sum(-quantity * unit_cost)) as v
                                          from period where kind in ('sale', 'staff_meal')
                                         group by ingredient_id order by 3 desc limit 8) t
                                  join public.ingredients i on i.id = t.ingredient_id), '[]'::jsonb),
      'waste_reasons', coalesce((select jsonb_agg(jsonb_build_object('reason', w.reason, 'value', w.v) order by w.v desc)
                                   from (select coalesce(nullif(btrim(reason), ''), '—') as reason, round(sum(-quantity * unit_cost)) as v
                                           from period where kind = 'waste' group by 1 order by 2 desc limit 8) w), '[]'::jsonb)
    ));
end $$;

-- -----------------------------------------------------------------------------
-- 4. Lots proches de leur date limite (FIFO : les réceptions les plus récentes
--    forment le stock restant)
-- -----------------------------------------------------------------------------
create or replace function public.stock_expiring(p_branch uuid, p_days integer default 7)
returns table (ingredient_id uuid, name text, unit_code text, batch text, expires_on date, remaining numeric,
               value_minor numeric, received_at timestamptz)
language plpgsql stable security definer set search_path = '' as $$
begin
  perform app_private.assert_branch_perm(p_branch, 'stock.read');
  return query
  with stock as (
    select m.ingredient_id, sum(m.quantity) as qty from public.stock_movements m
     where m.branch_id = p_branch group by m.ingredient_id having sum(m.quantity) > 0
  ), lots as (
    select m.ingredient_id, m.batch, m.expires_on, m.quantity, m.unit_cost, m.created_at,
           sum(m.quantity) over (partition by m.ingredient_id order by m.created_at desc, m.id) as running
      from public.stock_movements m
     where m.branch_id = p_branch and m.kind in ('receipt', 'opening', 'production_in', 'transfer_in')
  )
  select l.ingredient_id, i.name, i.unit_code, l.batch, l.expires_on,
         least(l.quantity, s.qty - (l.running - l.quantity)) as remaining,
         round(least(l.quantity, s.qty - (l.running - l.quantity)) * l.unit_cost),
         l.created_at
    from lots l
    join stock s on s.ingredient_id = l.ingredient_id
    join public.ingredients i on i.id = l.ingredient_id
   where l.expires_on is not null
     and l.expires_on <= current_date + greatest(coalesce(p_days, 7), 0)
     and s.qty - (l.running - l.quantity) > 0
   order by l.expires_on, i.name;
end $$;

-- -----------------------------------------------------------------------------
-- 5. Commande suggérée : de quoi tenir p_cover_days jours au-dessus du seuil,
--    arrondi à l'unité d'achat (carton, sac…)
-- -----------------------------------------------------------------------------
create or replace function public.reorder_suggestions(p_branch uuid, p_cover_days integer default 7)
returns table (ingredient_id uuid, name text, unit_code text, quantity numeric, min_quantity numeric,
               daily_use numeric, days_left numeric, suggested numeric, purchase_unit_label text,
               purchase_unit_qty numeric, supplier_id uuid, supplier_name text, last_unit_cost numeric)
language plpgsql stable security definer set search_path = '' as $$
declare v_org uuid;
begin
  perform app_private.assert_branch_perm(p_branch, 'stock.read');
  select organization_id into v_org from public.branches where id = p_branch;
  return query
  with base as (
    select i.id, i.name, i.unit_code, i.purchase_unit_label, i.purchase_unit_qty, i.preferred_supplier_id,
           (select coalesce(sum(m.quantity), 0) from public.stock_movements m
             where m.branch_id = p_branch and m.ingredient_id = i.id) as qty,
           coalesce(s.min_quantity, 0) as min_qty,
           (select coalesce(sum(-m.quantity), 0) / 28 from public.stock_movements m
             where m.branch_id = p_branch and m.ingredient_id = i.id
               and m.kind in ('sale', 'staff_meal', 'production_out', 'waste')
               and m.created_at > now() - interval '28 days') as daily,
           (select m.unit_cost from public.stock_movements m
             where m.branch_id = p_branch and m.ingredient_id = i.id and m.kind = 'receipt'
             order by m.created_at desc limit 1) as last_cost,
           coalesce(s.avg_unit_cost, 0) as avg_cost
      from public.ingredients i
      left join public.ingredient_stock s on s.ingredient_id = i.id and s.branch_id = p_branch
     where i.organization_id = v_org and i.active
  ), need as (
    select b.*, greatest(b.min_qty + b.daily * greatest(coalesce(p_cover_days, 7), 1) - b.qty, 0) as raw_need from base b
  )
  select n.id, n.name, n.unit_code, n.qty, n.min_qty, round(n.daily, 4),
         case when n.daily > 0 then round(greatest(n.qty, 0) / n.daily, 1) end,
         case when n.purchase_unit_qty is not null then ceil(n.raw_need / n.purchase_unit_qty) * n.purchase_unit_qty
              else round(n.raw_need, 2) end,
         n.purchase_unit_label, n.purchase_unit_qty, n.preferred_supplier_id, sup.name,
         coalesce(n.last_cost, n.avg_cost)
    from need n
    left join public.suppliers sup on sup.id = n.preferred_supplier_id
   where n.raw_need > 0 and (n.min_qty > 0 or n.daily > 0)
   order by case when n.daily > 0 then greatest(n.qty, 0) / n.daily end nulls last, n.name;
end $$;

revoke all on function public.stock_dashboard(uuid, date, date), public.stock_expiring(uuid, integer),
  public.reorder_suggestions(uuid, integer) from public, anon;
grant execute on function public.stock_dashboard(uuid, date, date), public.stock_expiring(uuid, integer),
  public.reorder_suggestions(uuid, integer) to authenticated;

revoke all on all functions in schema app_private from public, anon, authenticated;
grant execute on function app_private.member_org_ids(), app_private.member_branch_ids(),
  app_private.org_ids_with(text), app_private.branch_ids_with(text),
  app_private.full_access_org_ids(), app_private.assigned_branch_ids(),
  app_private.org_ids_with_any_branch(text) to authenticated;
