-- =============================================================================
-- Resto — 004_menus
-- Catalogue d'une marque (catégories, articles, variantes, suppléments,
-- allergènes, traductions) et, par établissement : articles proposés,
-- disponibilité, prix par canal avec historique.
-- À coller dans le SQL Editor APRÈS 003, puis supabase/tests/004_menus_tests.sql.
--
-- Droits :
--   - catalogue de la marque : permission menus.manage sur TOUTE l'organisation ;
--   - prix et disponibilité d'un établissement : menus.manage sur cet établissement ;
--   - lecture : membres (catalogue), membres de l'établissement (prix).
-- Rien n'est supprimé : articles, variantes, suppléments sont désactivés ;
-- un prix modifié est clôturé (valid_to) et remplacé (historique conservé).
-- =============================================================================

-- Les prix rattachent établissement et marque : clé composite nécessaire.
alter table public.branches add constraint branches_org_brand_id_key unique (organization_id, brand_id, id);

-- -----------------------------------------------------------------------------
-- Allergènes (déclarés par le restaurant ; liste des 14 allergènes majeurs)
-- -----------------------------------------------------------------------------
create table public.ref_allergens (
  code text primary key check (code ~ '^[a-z_]+$'),
  sort_order smallint not null
);
insert into public.ref_allergens (code, sort_order) values
  ('gluten', 1), ('crustaceans', 2), ('eggs', 3), ('fish', 4), ('peanuts', 5), ('soybeans', 6),
  ('milk', 7), ('nuts', 8), ('celery', 9), ('mustard', 10), ('sesame', 11), ('sulphites', 12),
  ('lupin', 13), ('molluscs', 14)
on conflict (code) do nothing;

-- -----------------------------------------------------------------------------
-- Catalogue de la marque
-- -----------------------------------------------------------------------------
create table public.menu_categories (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations (id) on delete restrict,
  brand_id uuid not null,
  name text not null check (length(btrim(name)) between 1 and 120),
  description text check (length(description) <= 1000),
  sort_order integer not null default 0,
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (organization_id, id),
  unique (organization_id, brand_id, id),
  foreign key (organization_id, brand_id) references public.brands (organization_id, id) on delete restrict
);
create index menu_categories_brand_idx on public.menu_categories (organization_id, brand_id);

create table public.menu_items (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations (id) on delete restrict,
  brand_id uuid not null,
  category_id uuid not null,
  name text not null check (length(btrim(name)) between 1 and 120),
  description text check (length(description) <= 2000),
  kind text not null default 'food' check (kind in ('food', 'drink', 'other')),
  sort_order integer not null default 0,
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (organization_id, id),
  unique (organization_id, brand_id, id),
  foreign key (organization_id, brand_id, category_id)
    references public.menu_categories (organization_id, brand_id, id) on delete restrict
);
create index menu_items_category_idx on public.menu_items (organization_id, category_id);

-- Chaque article a au moins une variante (nom vide = variante unique).
create table public.item_variants (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null,
  brand_id uuid not null,
  item_id uuid not null,
  name text not null default '' check (length(name) <= 80),
  sort_order integer not null default 0,
  active boolean not null default true,
  created_at timestamptz not null default now(),
  unique (organization_id, id),
  unique (organization_id, brand_id, id),
  unique (item_id, name),
  foreign key (organization_id, brand_id, item_id)
    references public.menu_items (organization_id, brand_id, id) on delete restrict
);

create table public.modifier_groups (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations (id) on delete restrict,
  brand_id uuid not null,
  name text not null check (length(btrim(name)) between 1 and 80),
  min_select smallint not null default 0 check (min_select between 0 and 50),
  max_select smallint check (max_select is null or (max_select between 1 and 50 and max_select >= min_select)),
  sort_order integer not null default 0,
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (organization_id, id),
  unique (organization_id, brand_id, id),
  foreign key (organization_id, brand_id) references public.brands (organization_id, id) on delete restrict
);

create table public.modifiers (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null,
  brand_id uuid not null,
  group_id uuid not null,
  name text not null check (length(btrim(name)) between 1 and 80),
  sort_order integer not null default 0,
  active boolean not null default true,
  created_at timestamptz not null default now(),
  unique (organization_id, id),
  unique (organization_id, brand_id, id),
  unique (group_id, name),
  foreign key (organization_id, brand_id, group_id)
    references public.modifier_groups (organization_id, brand_id, id) on delete restrict
);

-- Groupes de suppléments proposés sur un article (même marque obligatoire).
create table public.item_modifier_groups (
  organization_id uuid not null,
  brand_id uuid not null,
  item_id uuid not null,
  group_id uuid not null,
  sort_order integer not null default 0,
  primary key (item_id, group_id),
  foreign key (organization_id, brand_id, item_id) references public.menu_items (organization_id, brand_id, id) on delete cascade,
  foreign key (organization_id, brand_id, group_id) references public.modifier_groups (organization_id, brand_id, id) on delete cascade
);

create table public.item_allergens (
  organization_id uuid not null,
  item_id uuid not null,
  allergen_code text not null references public.ref_allergens (code),
  primary key (item_id, allergen_code),
  foreign key (organization_id, item_id) references public.menu_items (organization_id, id) on delete cascade
);

-- -----------------------------------------------------------------------------
-- Traductions du contenu (saisies et validées par le restaurant)
-- -----------------------------------------------------------------------------
create table public.menu_category_translations (
  organization_id uuid not null,
  category_id uuid not null,
  locale text not null references public.ref_languages (code),
  name text not null check (length(btrim(name)) between 1 and 120),
  description text check (length(description) <= 1000),
  primary key (category_id, locale),
  foreign key (organization_id, category_id) references public.menu_categories (organization_id, id) on delete cascade
);

create table public.menu_item_translations (
  organization_id uuid not null,
  item_id uuid not null,
  locale text not null references public.ref_languages (code),
  name text not null check (length(btrim(name)) between 1 and 120),
  description text check (length(description) <= 2000),
  primary key (item_id, locale),
  foreign key (organization_id, item_id) references public.menu_items (organization_id, id) on delete cascade
);

create table public.item_variant_translations (
  organization_id uuid not null,
  variant_id uuid not null,
  locale text not null references public.ref_languages (code),
  name text not null check (length(btrim(name)) between 1 and 80),
  primary key (variant_id, locale),
  foreign key (organization_id, variant_id) references public.item_variants (organization_id, id) on delete cascade
);

create table public.modifier_group_translations (
  organization_id uuid not null,
  group_id uuid not null,
  locale text not null references public.ref_languages (code),
  name text not null check (length(btrim(name)) between 1 and 80),
  primary key (group_id, locale),
  foreign key (organization_id, group_id) references public.modifier_groups (organization_id, id) on delete cascade
);

create table public.modifier_translations (
  organization_id uuid not null,
  modifier_id uuid not null,
  locale text not null references public.ref_languages (code),
  name text not null check (length(btrim(name)) between 1 and 80),
  primary key (modifier_id, locale),
  foreign key (organization_id, modifier_id) references public.modifiers (organization_id, id) on delete cascade
);

-- -----------------------------------------------------------------------------
-- Par établissement : articles proposés, disponibilité, prix
-- -----------------------------------------------------------------------------
create table public.menu_item_branches (
  organization_id uuid not null,
  brand_id uuid not null,
  item_id uuid not null,
  branch_id uuid not null,
  available boolean not null default true,
  updated_at timestamptz not null default now(),
  primary key (item_id, branch_id),
  foreign key (organization_id, brand_id, item_id) references public.menu_items (organization_id, brand_id, id) on delete restrict,
  foreign key (organization_id, brand_id, branch_id) references public.branches (organization_id, brand_id, id) on delete restrict
);
create index menu_item_branches_branch_idx on public.menu_item_branches (branch_id);

-- Prix en unités mineures dans la monnaie de l'établissement. Une ligne par
-- période : modifier un prix clôture la ligne courante et en crée une nouvelle.
-- channel « default » s'applique quand aucun prix propre au canal n'existe.
create table public.prices (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null,
  brand_id uuid not null,
  branch_id uuid not null,
  variant_id uuid,
  modifier_id uuid,
  channel text not null default 'default' check (channel in ('default', 'dine_in', 'takeaway', 'delivery')),
  currency char(3) not null references public.ref_currencies (code),
  amount_minor bigint not null check (amount_minor between 0 and 9007199254740991),
  valid_from timestamptz not null default now(),
  valid_to timestamptz,
  created_by uuid,
  check (num_nonnulls(variant_id, modifier_id) = 1),
  check (valid_to is null or valid_to >= valid_from),
  foreign key (organization_id, brand_id, branch_id) references public.branches (organization_id, brand_id, id) on delete restrict,
  foreign key (organization_id, brand_id, variant_id) references public.item_variants (organization_id, brand_id, id) on delete restrict,
  foreign key (organization_id, brand_id, modifier_id) references public.modifiers (organization_id, brand_id, id) on delete restrict
);
create unique index prices_current_variant on public.prices (branch_id, variant_id, channel)
  where valid_to is null and variant_id is not null;
create unique index prices_current_modifier on public.prices (branch_id, modifier_id, channel)
  where valid_to is null and modifier_id is not null;
create index prices_org_branch_idx on public.prices (organization_id, branch_id) where valid_to is null;

-- La monnaie d'un établissement est figée dès qu'il a des prix (les montants
-- n'auraient plus de sens).
create or replace function app_private.lock_branch_currency()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  if new.currency is distinct from old.currency
     and exists (select 1 from public.prices p where p.branch_id = new.id) then
    perform app_private.fail('resto.currency_locked');
  end if;
  return new;
end $$;
create trigger branches_lock_currency before update of currency on public.branches
  for each row execute function app_private.lock_branch_currency();

-- -----------------------------------------------------------------------------
-- Horodatage, audit
-- -----------------------------------------------------------------------------
create trigger menu_categories_touch before update on public.menu_categories
  for each row execute function app_private.touch_updated_at();
create trigger menu_items_touch before update on public.menu_items
  for each row execute function app_private.touch_updated_at();
create trigger modifier_groups_touch before update on public.modifier_groups
  for each row execute function app_private.touch_updated_at();
create trigger menu_item_branches_touch before update on public.menu_item_branches
  for each row execute function app_private.touch_updated_at();

do $$
declare t text;
begin
  foreach t in array array['menu_categories', 'menu_items', 'item_variants', 'modifier_groups', 'modifiers',
    'item_modifier_groups', 'item_allergens', 'menu_category_translations', 'menu_item_translations',
    'item_variant_translations', 'modifier_group_translations', 'modifier_translations',
    'menu_item_branches', 'prices']
  loop
    execute format('create trigger %I after insert or update or delete on public.%I
      for each row execute function app_private.audit_row()', t || '_audit', t);
  end loop;
end $$;

-- -----------------------------------------------------------------------------
-- Droits et RLS
-- -----------------------------------------------------------------------------
do $$
declare t text;
begin
  foreach t in array array['ref_allergens', 'menu_categories', 'menu_items', 'item_variants', 'modifier_groups',
    'modifiers', 'item_modifier_groups', 'item_allergens', 'menu_category_translations', 'menu_item_translations',
    'item_variant_translations', 'modifier_group_translations', 'modifier_translations',
    'menu_item_branches', 'prices']
  loop
    execute format('alter table public.%I enable row level security', t);
    execute format('revoke all on public.%I from anon, authenticated', t);
  end loop;
end $$;

grant select on public.ref_allergens to anon, authenticated;
create policy ref_allergens_read on public.ref_allergens for select to anon, authenticated using (true);

-- Catalogue : lecture par les membres, écriture par menus.manage sur toute l'organisation.
do $$
declare t text;
begin
  foreach t in array array['menu_categories', 'menu_items', 'item_variants', 'modifier_groups', 'modifiers',
    'item_modifier_groups', 'item_allergens', 'menu_category_translations', 'menu_item_translations',
    'item_variant_translations', 'modifier_group_translations', 'modifier_translations']
  loop
    execute format('create policy %I on public.%I for select to authenticated
      using (organization_id in (select app_private.member_org_ids()))', t || '_read', t);
    execute format('create policy %I on public.%I for insert to authenticated
      with check (organization_id in (select app_private.org_ids_with(''menus.manage'')))', t || '_insert', t);
    execute format('create policy %I on public.%I for update to authenticated
      using (organization_id in (select app_private.org_ids_with(''menus.manage'')))
      with check (organization_id in (select app_private.org_ids_with(''menus.manage'')))', t || '_update', t);
    execute format('create policy %I on public.%I for delete to authenticated
      using (organization_id in (select app_private.org_ids_with(''menus.manage'')))', t || '_delete', t);
  end loop;
end $$;

-- Colonnes modifiables ; la suppression n'est accordée que pour les liens et traductions.
grant select, insert (id, organization_id, brand_id, name, description, sort_order, active),
  update (name, description, sort_order, active) on public.menu_categories to authenticated;
grant select, update (category_id, name, description, kind, sort_order, active) on public.menu_items to authenticated;
grant select, insert (id, organization_id, brand_id, item_id, name, sort_order, active),
  update (name, sort_order, active) on public.item_variants to authenticated;
grant select, insert (id, organization_id, brand_id, name, min_select, max_select, sort_order, active),
  update (name, min_select, max_select, sort_order, active) on public.modifier_groups to authenticated;
grant select, insert (id, organization_id, brand_id, group_id, name, sort_order, active),
  update (name, sort_order, active) on public.modifiers to authenticated;
grant select, insert, update (sort_order), delete on public.item_modifier_groups to authenticated;
grant select, insert, delete on public.item_allergens to authenticated;
-- Traductions : insertion ou mise à jour en une fois (upsert), sous contrôle RLS.
grant select, insert, update, delete on public.menu_category_translations to authenticated;
grant select, insert, update, delete on public.menu_item_translations to authenticated;
grant select, insert, update, delete on public.item_variant_translations to authenticated;
grant select, insert, update, delete on public.modifier_group_translations to authenticated;
grant select, insert, update, delete on public.modifier_translations to authenticated;

-- Par établissement : lecture par les membres de l'établissement,
-- disponibilité modifiable par menus.manage sur cet établissement.
grant select, insert (organization_id, brand_id, item_id, branch_id, available), update (available), delete
  on public.menu_item_branches to authenticated;
create policy menu_item_branches_read on public.menu_item_branches for select to authenticated
  using (branch_id in (select app_private.member_branch_ids()));
create policy menu_item_branches_write on public.menu_item_branches for all to authenticated
  using (branch_id in (select app_private.branch_ids_with('menus.manage')))
  with check (branch_id in (select app_private.branch_ids_with('menus.manage')));

-- Prix : lecture seule ; écriture uniquement par set_price (historique).
grant select on public.prices to authenticated;
create policy prices_read on public.prices for select to authenticated
  using (branch_id in (select app_private.member_branch_ids()));

-- -----------------------------------------------------------------------------
-- RPC
-- -----------------------------------------------------------------------------

-- Crée un article et sa variante unique, ensemble.
create or replace function public.create_menu_item(
  p_category uuid, p_name text, p_description text default null, p_kind text default 'food')
returns uuid language plpgsql security definer set search_path = '' as $$
declare
  v_cat public.menu_categories;
  v_item uuid;
begin
  select * into v_cat from public.menu_categories where id = p_category;
  if v_cat.id is null or not app_private.has_org_perm(v_cat.organization_id, 'menus.manage') then
    raise exception 'resto.forbidden' using errcode = '42501';
  end if;
  insert into public.menu_items (organization_id, brand_id, category_id, name, description, kind, sort_order)
  values (v_cat.organization_id, v_cat.brand_id, v_cat.id, btrim(p_name), nullif(btrim(p_description), ''),
          coalesce(p_kind, 'food'),
          coalesce((select max(sort_order) + 1 from public.menu_items where category_id = v_cat.id), 0))
  returning id into v_item;
  insert into public.item_variants (organization_id, brand_id, item_id, name)
  values (v_cat.organization_id, v_cat.brand_id, v_item, '');
  return v_item;
end $$;

-- Fixe (ou retire, p_amount null) le prix d'une variante OU d'un supplément
-- dans un établissement pour un canal. L'ancien prix est clôturé, jamais effacé.
create or replace function public.set_price(
  p_branch uuid, p_variant uuid, p_modifier uuid, p_channel text, p_amount bigint)
returns void language plpgsql security definer set search_path = '' as $$
declare
  v_branch public.branches;
  v_current public.prices;
  v_brand uuid;
  v_now timestamptz := now();
begin
  select * into v_branch from public.branches where id = p_branch;
  if v_branch.id is null or not exists (
    select 1 from app_private.branch_ids_with('menus.manage') x where x = p_branch) then
    raise exception 'resto.forbidden' using errcode = '42501';
  end if;
  if num_nonnulls(p_variant, p_modifier) <> 1
     or coalesce(p_channel, '') not in ('default', 'dine_in', 'takeaway', 'delivery')
     or p_amount < 0 or p_amount > 9007199254740991 then
    perform app_private.fail('resto.invalid_price');
  end if;
  if p_variant is not null then
    select brand_id into v_brand from public.item_variants where id = p_variant;
  else
    select brand_id into v_brand from public.modifiers where id = p_modifier;
  end if;
  if v_brand is distinct from v_branch.brand_id then perform app_private.fail('resto.invalid_price'); end if;

  -- Un seul changement à la fois pour un même prix.
  perform pg_advisory_xact_lock(hashtext('resto.price.' || p_branch::text || coalesce(p_variant, p_modifier)::text || p_channel));
  select * into v_current from public.prices
   where branch_id = p_branch and channel = p_channel and valid_to is null
     and variant_id is not distinct from p_variant and modifier_id is not distinct from p_modifier;

  if v_current.id is not null and v_current.amount_minor = p_amount then return; end if;
  if v_current.id is not null then
    update public.prices set valid_to = v_now where id = v_current.id;
  end if;
  if p_amount is not null then
    insert into public.prices (organization_id, brand_id, branch_id, variant_id, modifier_id, channel,
                               currency, amount_minor, valid_from, created_by)
    values (v_branch.organization_id, v_branch.brand_id, p_branch, p_variant, p_modifier, p_channel,
            v_branch.currency, p_amount, v_now, auth.uid());
  end if;
end $$;

revoke all on function public.create_menu_item(uuid, text, text, text),
  public.set_price(uuid, uuid, uuid, text, bigint) from public, anon;
grant execute on function public.create_menu_item(uuid, text, text, text),
  public.set_price(uuid, uuid, uuid, text, bigint) to authenticated;
