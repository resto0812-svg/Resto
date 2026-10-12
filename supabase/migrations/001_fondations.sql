-- =============================================================================
-- Resto — 001_fondations
-- Référentiels, profils, organisations, rôles et permissions, adhésions,
-- invitations, marques, établissements, horaires, salle, journal d'audit.
--
-- À coller dans le SQL Editor d'un projet Supabase DÉDIÉ à Resto.
-- Ensuite : supabase/seed/ref_iso.sql (référentiels complets), puis
-- supabase/tests/001_fondations_tests.sql (contrôles, annulés à la fin).
--
-- Erreurs métier : exception SQLSTATE P0001 dont le message est un code
-- stable « resto.xxx » traduit par l'application. Refus de droit : 42501.
-- =============================================================================

create schema if not exists app_private;
revoke all on schema app_private from public;
grant usage on schema app_private to authenticated;

-- Rien n'est accessible par défaut : chaque table / fonction future devra
-- accorder explicitement ses droits (les migrations s'exécutent en postgres).
alter default privileges in schema public revoke all on tables from anon, authenticated;
alter default privileges in schema public revoke all on sequences from anon, authenticated;
alter default privileges in schema public revoke execute on functions from public, anon, authenticated;

-- -----------------------------------------------------------------------------
-- Outils communs
-- -----------------------------------------------------------------------------
create or replace function app_private.touch_updated_at()
returns trigger language plpgsql set search_path = '' as $$
begin
  new.updated_at := now();
  return new;
end $$;

create or replace function app_private.is_valid_timezone(p text)
returns boolean language sql stable set search_path = '' as $$
  select exists (select 1 from pg_catalog.pg_timezone_names where name = p)
$$;

-- « Chez Léa — Akwa » → « chez-lea-akwa » ; vide si aucun caractère latin.
create or replace function app_private.slugify(p text)
returns text language sql immutable set search_path = '' as $$
  select left(trim(both '-' from regexp_replace(
    lower(translate(coalesce(p, ''),
      'àâäáãåçéèêëíìîïñóòôöõúùûüýÿÀÂÄÁÃÅÇÉÈÊËÍÌÎÏÑÓÒÔÖÕÚÙÛÜÝŸ',
      'aaaaaaceeeeiiiinooooouuuuyyAAAAAACEEEEIIIINOOOOOUUUUYY')),
    '[^a-z0-9]+', '-', 'g')), 50)
$$;

create or replace function app_private.fail(p_code text)
returns void language plpgsql set search_path = '' as $$
begin
  raise exception '%', p_code using errcode = 'P0001';
end $$;

-- -----------------------------------------------------------------------------
-- Référentiels internationaux (complétés par supabase/seed/ref_iso.sql)
-- -----------------------------------------------------------------------------
create table public.ref_currencies (
  code char(3) primary key check (code ~ '^[A-Z]{3}$'),
  numeric_code char(3) check (numeric_code ~ '^[0-9]{3}$'),
  minor_unit smallint not null check (minor_unit between 0 and 4),
  name text not null,
  active boolean not null default true
);

create table public.ref_countries (
  code char(2) primary key check (code ~ '^[A-Z]{2}$'),
  alpha3 char(3) not null unique check (alpha3 ~ '^[A-Z]{3}$'),
  numeric_code char(3) check (numeric_code ~ '^[0-9]{3}$'),
  name text not null,
  active boolean not null default true
);

create table public.ref_languages (
  code text primary key check (code ~ '^[a-z]{2,3}(-[A-Za-z0-9]{2,8})*$'),
  native_name text not null,
  rtl boolean not null default false,
  ui_enabled boolean not null default true
);

insert into public.ref_languages (code, native_name, rtl) values
  ('fr', 'Français', false), ('en', 'English', false), ('de', 'Deutsch', false),
  ('es', 'Español', false), ('pt', 'Português', false), ('ar', 'العربية', true),
  ('zh-Hans', '简体中文', false), ('zh-Hant', '繁體中文', false)
on conflict (code) do nothing;

-- Amorçage minimal (le seed ISO complet remplace ces lignes).
insert into public.ref_currencies (code, numeric_code, minor_unit, name) values
  ('XAF', '950', 0, 'CFA Franc BEAC'), ('XOF', '952', 0, 'CFA Franc BCEAO'),
  ('EUR', '978', 2, 'Euro'), ('USD', '840', 2, 'US Dollar'),
  ('GBP', '826', 2, 'Pound Sterling'), ('JPY', '392', 0, 'Yen'),
  ('CNY', '156', 2, 'Yuan Renminbi'), ('KWD', '414', 3, 'Kuwaiti Dinar'),
  ('MAD', '504', 2, 'Moroccan Dirham'), ('NGN', '566', 2, 'Naira')
on conflict (code) do nothing;

insert into public.ref_countries (code, alpha3, numeric_code, name) values
  ('CM', 'CMR', '120', 'Cameroon'), ('SN', 'SEN', '686', 'Senegal'),
  ('CI', 'CIV', '384', 'Côte d''Ivoire'), ('NG', 'NGA', '566', 'Nigeria'),
  ('MA', 'MAR', '504', 'Morocco'), ('FR', 'FRA', '250', 'France'),
  ('DE', 'DEU', '276', 'Germany'), ('ES', 'ESP', '724', 'Spain'),
  ('PT', 'PRT', '620', 'Portugal'), ('GB', 'GBR', '826', 'United Kingdom'),
  ('US', 'USA', '840', 'United States'), ('JP', 'JPN', '392', 'Japan'),
  ('CN', 'CHN', '156', 'China'), ('KW', 'KWT', '414', 'Kuwait')
on conflict (code) do nothing;

-- -----------------------------------------------------------------------------
-- Profils (données personnelles minimales) et personnel de la plateforme
-- -----------------------------------------------------------------------------
create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  display_name text not null default '' check (length(display_name) <= 120),
  locale text references public.ref_languages (code),
  country_code char(2) references public.ref_countries (code),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create trigger profiles_touch before update on public.profiles
  for each row execute function app_private.touch_updated_at();

create or replace function app_private.on_auth_user_created()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  insert into public.profiles (id, display_name, locale)
  values (
    new.id,
    left(btrim(coalesce(new.raw_user_meta_data ->> 'display_name', '')), 120),
    (select l.code from public.ref_languages l
      where l.code = new.raw_user_meta_data ->> 'locale' and l.ui_enabled))
  on conflict (id) do nothing;
  return new;
end $$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users
  for each row execute function app_private.on_auth_user_created();

-- Géré uniquement en SQL par le super-administrateur. Ne donne AUCUN accès
-- aux données privées des restaurants.
create table public.platform_staff (
  user_id uuid primary key references auth.users (id) on delete cascade,
  role text not null check (role in ('support', 'finance', 'moderation', 'superadmin')),
  active boolean not null default true,
  created_at timestamptz not null default now()
);

-- -----------------------------------------------------------------------------
-- Organisations
-- -----------------------------------------------------------------------------
create table public.organizations (
  id uuid primary key default gen_random_uuid(),
  name text not null check (length(btrim(name)) between 2 and 120),
  legal_name text check (length(legal_name) <= 200),
  country_code char(2) not null references public.ref_countries (code),
  default_currency char(3) not null references public.ref_currencies (code),
  default_locale text not null references public.ref_languages (code),
  -- suspended = lecture seule ; closed = plus aucun accès membre
  status text not null default 'active' check (status in ('active', 'suspended', 'closed')),
  created_by uuid references auth.users (id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index organizations_created_by_idx on public.organizations (created_by, created_at);
create trigger organizations_touch before update on public.organizations
  for each row execute function app_private.touch_updated_at();

-- -----------------------------------------------------------------------------
-- Rôles et permissions (catalogue système ; matrice = docs/SECURITY.md §3)
-- -----------------------------------------------------------------------------
create table public.permissions (
  code text primary key check (code ~ '^[a-z_]+\.[a-z_]+$'),
  scope text not null check (scope in ('organization', 'branch')),
  description text not null
);

create table public.roles (
  code text primary key check (code ~ '^[a-z_]+$'),
  rank smallint not null unique,
  description text not null
);

create table public.role_permissions (
  role_code text not null references public.roles (code) on delete cascade,
  permission_code text not null references public.permissions (code) on delete cascade,
  primary key (role_code, permission_code)
);

insert into public.permissions (code, scope, description) values
  ('org.manage', 'organization', 'Paramètres de l''organisation et marques'),
  ('members.manage', 'organization', 'Employés, rôles et invitations'),
  ('billing.manage', 'organization', 'Abonnement et facturation de la plateforme'),
  ('audit.read', 'organization', 'Journal d''audit'),
  ('branches.manage', 'branch', 'Établissement, salle et horaires'),
  ('menus.manage', 'branch', 'Menus, articles et prix'),
  ('orders.read', 'branch', 'Consulter les commandes'),
  ('orders.write', 'branch', 'Créer et modifier les commandes avant validation'),
  ('orders.void', 'branch', 'Annuler une commande validée'),
  ('kitchen.operate', 'branch', 'Statuts de préparation'),
  ('reservations.manage', 'branch', 'Réservations'),
  ('cash.operate', 'branch', 'Ouvrir une caisse et encaisser'),
  ('cash.close', 'branch', 'Valider une clôture de caisse et ses écarts'),
  ('payments.refund', 'branch', 'Rembourser'),
  ('stock.read', 'branch', 'Consulter les stocks'),
  ('stock.write', 'branch', 'Réceptions, pertes, transferts'),
  ('stock.adjust', 'branch', 'Valider inventaires et ajustements'),
  ('purchases.manage', 'branch', 'Fournisseurs et achats'),
  ('expenses.manage', 'branch', 'Dépenses'),
  ('finance.read', 'branch', 'Rapports financiers'),
  ('customers.manage', 'branch', 'Fidélité et promotions')
on conflict (code) do nothing;

insert into public.roles (code, rank, description) values
  ('owner', 100, 'Propriétaire'), ('admin', 90, 'Administrateur'),
  ('manager', 70, 'Responsable d''établissement'), ('accountant', 50, 'Comptable'),
  ('cashier', 40, 'Caissier'), ('stock_keeper', 45, 'Magasinier'),
  ('waiter', 30, 'Serveur'), ('kitchen', 20, 'Cuisine / bar'), ('viewer', 10, 'Lecteur')
on conflict (code) do nothing;

insert into public.role_permissions (role_code, permission_code)
select r, p from (values
  ('manager', 'branches.manage'), ('manager', 'menus.manage'), ('manager', 'orders.read'),
  ('manager', 'orders.write'), ('manager', 'orders.void'), ('manager', 'kitchen.operate'),
  ('manager', 'reservations.manage'), ('manager', 'cash.operate'), ('manager', 'cash.close'),
  ('manager', 'payments.refund'), ('manager', 'stock.read'), ('manager', 'stock.write'),
  ('manager', 'stock.adjust'), ('manager', 'purchases.manage'), ('manager', 'expenses.manage'),
  ('manager', 'finance.read'), ('manager', 'customers.manage'),
  ('cashier', 'orders.read'), ('cashier', 'orders.write'), ('cashier', 'reservations.manage'),
  ('cashier', 'cash.operate'),
  ('waiter', 'orders.read'), ('waiter', 'orders.write'), ('waiter', 'reservations.manage'),
  ('kitchen', 'orders.read'), ('kitchen', 'kitchen.operate'), ('kitchen', 'stock.read'),
  ('stock_keeper', 'stock.read'), ('stock_keeper', 'stock.write'), ('stock_keeper', 'purchases.manage'),
  ('accountant', 'audit.read'), ('accountant', 'orders.read'), ('accountant', 'stock.read'),
  ('accountant', 'purchases.manage'), ('accountant', 'expenses.manage'), ('accountant', 'finance.read'),
  ('viewer', 'orders.read'), ('viewer', 'stock.read'), ('viewer', 'finance.read')
) v (r, p)
union all
select r.code, p.code from public.roles r cross join public.permissions p
where r.code in ('owner', 'admin')
on conflict do nothing;

-- -----------------------------------------------------------------------------
-- Marques et établissements
-- -----------------------------------------------------------------------------
create table public.brands (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations (id) on delete restrict,
  name text not null check (length(btrim(name)) between 1 and 120),
  slug text not null unique check (slug ~ '^[a-z0-9]+(-[a-z0-9]+)*$' and length(slug) <= 60),
  status text not null default 'active' check (status in ('active', 'archived')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (organization_id, id)
);
create index brands_org_idx on public.brands (organization_id);
create trigger brands_touch before update on public.brands
  for each row execute function app_private.touch_updated_at();

create table public.branches (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations (id) on delete restrict,
  brand_id uuid not null,
  name text not null check (length(btrim(name)) between 1 and 120),
  slug text not null check (slug ~ '^[a-z0-9]+(-[a-z0-9]+)*$' and length(slug) <= 60),
  country_code char(2) not null references public.ref_countries (code),
  address_line1 text check (length(address_line1) <= 200),
  address_line2 text check (length(address_line2) <= 200),
  city text not null check (length(btrim(city)) between 1 and 120),
  region text check (length(region) <= 120),
  postal_code text check (length(postal_code) <= 20),
  latitude numeric(9, 6) check (latitude between -90 and 90),
  longitude numeric(9, 6) check (longitude between -180 and 180),
  phone text check (length(phone) <= 32),
  email text check (length(email) <= 254),
  timezone text not null,
  currency char(3) not null references public.ref_currencies (code),
  default_locale text not null references public.ref_languages (code),
  status text not null default 'active' check (status in ('active', 'archived')),
  is_published boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (organization_id, id),
  unique (brand_id, slug),
  foreign key (organization_id, brand_id) references public.brands (organization_id, id) on delete restrict
);
create index branches_org_idx on public.branches (organization_id);
create trigger branches_touch before update on public.branches
  for each row execute function app_private.touch_updated_at();

create or replace function app_private.check_branch()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  if not app_private.is_valid_timezone(new.timezone) then
    perform app_private.fail('resto.invalid_timezone');
  end if;
  return new;
end $$;
create trigger branches_check before insert or update of timezone on public.branches
  for each row execute function app_private.check_branch();

create table public.branch_languages (
  organization_id uuid not null,
  branch_id uuid not null,
  locale text not null references public.ref_languages (code),
  primary key (branch_id, locale),
  foreign key (organization_id, branch_id) references public.branches (organization_id, id) on delete cascade
);

-- weekday ISO : 1 = lundi … 7 = dimanche ; heures locales de l'établissement.
-- closes_at < opens_at = fermeture après minuit ; 00:00 → 24:00 = ouvert 24 h.
create table public.branch_opening_hours (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null,
  branch_id uuid not null,
  weekday smallint not null check (weekday between 1 and 7),
  opens_at time not null,
  closes_at time not null check (closes_at <> opens_at),
  unique (branch_id, weekday, opens_at),
  foreign key (organization_id, branch_id) references public.branches (organization_id, id) on delete cascade
);

create table public.service_areas (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null,
  branch_id uuid not null,
  name text not null check (length(btrim(name)) between 1 and 80),
  sort_order integer not null default 0,
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (organization_id, id),
  unique (organization_id, branch_id, id),
  unique (branch_id, name),
  foreign key (organization_id, branch_id) references public.branches (organization_id, id) on delete restrict
);
create trigger service_areas_touch before update on public.service_areas
  for each row execute function app_private.touch_updated_at();

-- L'occupation d'une table n'est pas stockée ici : elle sera dérivée des
-- commandes et réservations (Phase 2/4), jamais d'un statut combiné.
create table public.dining_tables (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null,
  branch_id uuid not null,
  service_area_id uuid not null,
  label text not null check (length(btrim(label)) between 1 and 30),
  seats smallint not null default 2 check (seats between 1 and 100),
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (organization_id, id),
  unique (branch_id, label),
  foreign key (organization_id, branch_id, service_area_id)
    references public.service_areas (organization_id, branch_id, id) on delete restrict
);
create index dining_tables_branch_idx on public.dining_tables (organization_id, branch_id);
create trigger dining_tables_touch before update on public.dining_tables
  for each row execute function app_private.touch_updated_at();

-- -----------------------------------------------------------------------------
-- Adhésions et invitations
-- -----------------------------------------------------------------------------
create table public.memberships (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations (id) on delete restrict,
  user_id uuid not null references auth.users (id) on delete cascade,
  role_code text not null references public.roles (code),
  all_branches boolean not null default true,
  status text not null default 'active' check (status in ('active', 'revoked')),
  invited_by uuid references auth.users (id) on delete set null,
  revoked_at timestamptz,
  revoked_by uuid references auth.users (id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (organization_id, user_id),
  unique (organization_id, id),
  check (role_code not in ('owner', 'admin') or all_branches)
);
create index memberships_user_idx on public.memberships (user_id) where status = 'active';
create trigger memberships_touch before update on public.memberships
  for each row execute function app_private.touch_updated_at();

create table public.membership_branches (
  organization_id uuid not null,
  membership_id uuid not null,
  branch_id uuid not null,
  primary key (membership_id, branch_id),
  foreign key (organization_id, membership_id) references public.memberships (organization_id, id) on delete cascade,
  foreign key (organization_id, branch_id) references public.branches (organization_id, id) on delete cascade
);
create index membership_branches_branch_idx on public.membership_branches (branch_id);

create table public.invitations (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations (id) on delete restrict,
  email text not null check (email = lower(btrim(email)) and email ~ '^[^@\s]+@[^@\s]+\.[^@\s]+$'),
  role_code text not null references public.roles (code),
  all_branches boolean not null default true,
  -- SHA-256 du jeton ; le jeton lui-même n'est jamais stocké.
  token_hash bytea not null unique,
  status text not null default 'pending' check (status in ('pending', 'accepted', 'revoked')),
  expires_at timestamptz not null,
  invited_by uuid references auth.users (id) on delete set null,
  accepted_by uuid references auth.users (id) on delete set null,
  accepted_at timestamptz,
  created_at timestamptz not null default now(),
  unique (organization_id, id),
  check (role_code not in ('owner', 'admin') or all_branches)
);
create index invitations_org_idx on public.invitations (organization_id, status);

create table public.invitation_branches (
  organization_id uuid not null,
  invitation_id uuid not null,
  branch_id uuid not null,
  primary key (invitation_id, branch_id),
  foreign key (organization_id, invitation_id) references public.invitations (organization_id, id) on delete cascade,
  foreign key (organization_id, branch_id) references public.branches (organization_id, id) on delete cascade
);

-- -----------------------------------------------------------------------------
-- Journal d'audit : alimenté par déclencheurs, jamais modifiable.
-- -----------------------------------------------------------------------------
create table public.audit_log (
  id bigint generated always as identity primary key,
  organization_id uuid references public.organizations (id) on delete restrict,
  actor_id uuid,
  action text not null,
  entity text not null,
  entity_id uuid,
  details jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);
create index audit_log_org_idx on public.audit_log (organization_id, created_at desc);

create or replace function app_private.audit_immutable()
returns trigger language plpgsql set search_path = '' as $$
begin
  raise exception 'resto.audit_immutable' using errcode = '42501';
end $$;
create trigger audit_log_no_update before update or delete on public.audit_log
  for each row execute function app_private.audit_immutable();
create trigger audit_log_no_truncate before truncate on public.audit_log
  for each statement execute function app_private.audit_immutable();

-- Écrit une ligne d'audit par insertion / modification / suppression.
-- En modification, seules les colonnes changées sont conservées.
create or replace function app_private.audit_row()
returns trigger language plpgsql security definer set search_path = '' as $$
declare
  v_old jsonb;
  v_new jsonb;
  v_row jsonb;
begin
  if tg_op <> 'INSERT' then v_old := to_jsonb(old); end if;
  if tg_op <> 'DELETE' then v_new := to_jsonb(new); end if;
  v_row := coalesce(v_new, v_old);
  if tg_op = 'UPDATE' then
    select coalesce(jsonb_object_agg(n.key, n.value), '{}'::jsonb) into v_new
      from jsonb_each(to_jsonb(new)) n
     where n.value is distinct from (v_old -> n.key) and n.key <> 'updated_at';
    if v_new = '{}'::jsonb then return null; end if;
    select jsonb_object_agg(k.key, v_old -> k.key) into v_old from jsonb_object_keys(v_new) k (key);
  end if;
  insert into public.audit_log (organization_id, actor_id, action, entity, entity_id, details)
  values (
    coalesce((v_row ->> 'organization_id')::uuid,
             case when tg_table_name = 'organizations' then (v_row ->> 'id')::uuid end),
    auth.uid(), lower(tg_op), tg_table_name, (v_row ->> 'id')::uuid,
    jsonb_strip_nulls(jsonb_build_object('old', v_old - 'token_hash', 'new', v_new - 'token_hash')));
  return null;
end $$;

do $$
declare t text;
begin
  foreach t in array array['organizations', 'memberships', 'membership_branches', 'invitations',
    'brands', 'branches', 'branch_languages', 'branch_opening_hours', 'service_areas', 'dining_tables']
  loop
    execute format('create trigger %I after insert or update or delete on public.%I
      for each row execute function app_private.audit_row()', t || '_audit', t);
  end loop;
end $$;

-- -----------------------------------------------------------------------------
-- Fonctions de droits (security definer, évaluées une fois par requête dans
-- les politiques grâce à « in (select …) »).
-- -----------------------------------------------------------------------------

-- Organisations dont je suis membre actif (lecture ; organisation suspendue incluse).
create or replace function app_private.member_org_ids()
returns setof uuid language sql stable security definer set search_path = '' as $$
  select m.organization_id
    from public.memberships m
    join public.organizations o on o.id = m.organization_id and o.status <> 'closed'
   where m.user_id = auth.uid() and m.status = 'active'
$$;

-- Établissements visibles : tous si all_branches, sinon ceux attribués.
create or replace function app_private.member_branch_ids()
returns setof uuid language sql stable security definer set search_path = '' as $$
  select b.id
    from public.memberships m
    join public.organizations o on o.id = m.organization_id and o.status <> 'closed'
    join public.branches b on b.organization_id = m.organization_id
   where m.user_id = auth.uid() and m.status = 'active'
     and (m.all_branches or exists (
       select 1 from public.membership_branches mb where mb.membership_id = m.id and mb.branch_id = b.id))
$$;

-- Organisations où j'ai la permission sur TOUTE l'organisation (écriture :
-- organisation active uniquement).
create or replace function app_private.org_ids_with(p_perm text)
returns setof uuid language sql stable security definer set search_path = '' as $$
  select m.organization_id
    from public.memberships m
    join public.organizations o on o.id = m.organization_id and o.status = 'active'
    join public.role_permissions rp on rp.role_code = m.role_code and rp.permission_code = p_perm
   where m.user_id = auth.uid() and m.status = 'active' and m.all_branches
$$;

-- Établissements où j'ai la permission (portée « branch » uniquement).
create or replace function app_private.branch_ids_with(p_perm text)
returns setof uuid language sql stable security definer set search_path = '' as $$
  select b.id
    from public.memberships m
    join public.organizations o on o.id = m.organization_id and o.status = 'active'
    join public.role_permissions rp on rp.role_code = m.role_code and rp.permission_code = p_perm
    join public.permissions p on p.code = rp.permission_code and p.scope = 'branch'
    join public.branches b on b.organization_id = m.organization_id
   where m.user_id = auth.uid() and m.status = 'active'
     and (m.all_branches or exists (
       select 1 from public.membership_branches mb where mb.membership_id = m.id and mb.branch_id = b.id))
$$;

create or replace function app_private.has_org_perm(p_org uuid, p_perm text)
returns boolean language sql stable security definer set search_path = '' as $$
  select exists (select 1 from app_private.org_ids_with(p_perm) x where x = p_org)
$$;

create or replace function app_private.my_role_in(p_org uuid)
returns text language sql stable security definer set search_path = '' as $$
  select m.role_code from public.memberships m
   where m.organization_id = p_org and m.user_id = auth.uid() and m.status = 'active'
$$;

-- -----------------------------------------------------------------------------
-- Droits d'accès aux tables + RLS
-- -----------------------------------------------------------------------------
do $$
declare t text;
begin
  foreach t in array array['ref_currencies', 'ref_countries', 'ref_languages', 'profiles',
    'platform_staff', 'organizations', 'permissions', 'roles', 'role_permissions', 'brands',
    'branches', 'branch_languages', 'branch_opening_hours', 'service_areas', 'dining_tables',
    'memberships', 'membership_branches', 'invitations', 'invitation_branches', 'audit_log']
  loop
    execute format('alter table public.%I enable row level security', t);
    execute format('revoke all on public.%I from anon, authenticated', t);
  end loop;
end $$;

-- Référentiels : lecture publique.
grant select on public.ref_currencies, public.ref_countries, public.ref_languages to anon, authenticated;
create policy ref_currencies_read on public.ref_currencies for select to anon, authenticated using (true);
create policy ref_countries_read on public.ref_countries for select to anon, authenticated using (true);
create policy ref_languages_read on public.ref_languages for select to anon, authenticated using (true);

grant select on public.permissions, public.roles, public.role_permissions to authenticated;
create policy permissions_read on public.permissions for select to authenticated using (true);
create policy roles_read on public.roles for select to authenticated using (true);
create policy role_permissions_read on public.role_permissions for select to authenticated using (true);

-- Profil : chacun le sien.
grant select, update (display_name, locale, country_code) on public.profiles to authenticated;
create policy profiles_own_read on public.profiles for select to authenticated
  using (id = (select auth.uid()));
create policy profiles_own_update on public.profiles for update to authenticated
  using (id = (select auth.uid())) with check (id = (select auth.uid()));

grant select on public.platform_staff to authenticated;
create policy platform_staff_own on public.platform_staff for select to authenticated
  using (user_id = (select auth.uid()));

-- Organisations : création par RPC ; modification des paramètres par org.manage.
grant select, update (name, legal_name, country_code, default_currency, default_locale)
  on public.organizations to authenticated;
create policy organizations_read on public.organizations for select to authenticated
  using (id in (select app_private.member_org_ids()));
create policy organizations_update on public.organizations for update to authenticated
  using (id in (select app_private.org_ids_with('org.manage')))
  with check (id in (select app_private.org_ids_with('org.manage')));

-- Marques
grant select, insert (id, organization_id, name, slug, status), update (name, slug, status)
  on public.brands to authenticated;
create policy brands_read on public.brands for select to authenticated
  using (organization_id in (select app_private.member_org_ids()));
create policy brands_insert on public.brands for insert to authenticated
  with check (organization_id in (select app_private.org_ids_with('org.manage')));
create policy brands_update on public.brands for update to authenticated
  using (organization_id in (select app_private.org_ids_with('org.manage')))
  with check (organization_id in (select app_private.org_ids_with('org.manage')));

-- Établissements : création par org.manage, modification par branches.manage.
grant select,
  insert (id, organization_id, brand_id, name, slug, country_code, address_line1, address_line2,
    city, region, postal_code, latitude, longitude, phone, email, timezone, currency,
    default_locale, status, is_published),
  update (name, slug, country_code, address_line1, address_line2, city, region, postal_code,
    latitude, longitude, phone, email, timezone, currency, default_locale, status, is_published)
  on public.branches to authenticated;
create policy branches_read on public.branches for select to authenticated
  using (id in (select app_private.member_branch_ids()));
create policy branches_insert on public.branches for insert to authenticated
  with check (organization_id in (select app_private.org_ids_with('org.manage')));
create policy branches_update on public.branches for update to authenticated
  using (id in (select app_private.branch_ids_with('branches.manage')))
  with check (id in (select app_private.branch_ids_with('branches.manage')));

-- Langues, horaires, zones et tables d'un établissement.
grant select, insert, delete on public.branch_languages to authenticated;
create policy branch_languages_read on public.branch_languages for select to authenticated
  using (branch_id in (select app_private.member_branch_ids()));
create policy branch_languages_insert on public.branch_languages for insert to authenticated
  with check (branch_id in (select app_private.branch_ids_with('branches.manage')));
create policy branch_languages_delete on public.branch_languages for delete to authenticated
  using (branch_id in (select app_private.branch_ids_with('branches.manage')));

grant select, insert (id, organization_id, branch_id, weekday, opens_at, closes_at),
  update (weekday, opens_at, closes_at), delete on public.branch_opening_hours to authenticated;
create policy opening_hours_read on public.branch_opening_hours for select to authenticated
  using (branch_id in (select app_private.member_branch_ids()));
create policy opening_hours_write on public.branch_opening_hours for all to authenticated
  using (branch_id in (select app_private.branch_ids_with('branches.manage')))
  with check (branch_id in (select app_private.branch_ids_with('branches.manage')));

grant select, insert (id, organization_id, branch_id, name, sort_order, active),
  update (name, sort_order, active) on public.service_areas to authenticated;
create policy service_areas_read on public.service_areas for select to authenticated
  using (branch_id in (select app_private.member_branch_ids()));
create policy service_areas_insert on public.service_areas for insert to authenticated
  with check (branch_id in (select app_private.branch_ids_with('branches.manage')));
create policy service_areas_update on public.service_areas for update to authenticated
  using (branch_id in (select app_private.branch_ids_with('branches.manage')))
  with check (branch_id in (select app_private.branch_ids_with('branches.manage')));

grant select, insert (id, organization_id, branch_id, service_area_id, label, seats, active),
  update (service_area_id, label, seats, active) on public.dining_tables to authenticated;
create policy dining_tables_read on public.dining_tables for select to authenticated
  using (branch_id in (select app_private.member_branch_ids()));
create policy dining_tables_insert on public.dining_tables for insert to authenticated
  with check (branch_id in (select app_private.branch_ids_with('branches.manage')));
create policy dining_tables_update on public.dining_tables for update to authenticated
  using (branch_id in (select app_private.branch_ids_with('branches.manage')))
  with check (branch_id in (select app_private.branch_ids_with('branches.manage')));

-- Adhésions et invitations : lecture seule, écritures par RPC.
grant select on public.memberships, public.membership_branches, public.invitations,
  public.invitation_branches to authenticated;
create policy memberships_read on public.memberships for select to authenticated
  using (user_id = (select auth.uid())
    or organization_id in (select app_private.org_ids_with('members.manage')));
create policy membership_branches_read on public.membership_branches for select to authenticated
  using (membership_id in (select m.id from public.memberships m where m.user_id = (select auth.uid()))
    or organization_id in (select app_private.org_ids_with('members.manage')));
create policy invitations_read on public.invitations for select to authenticated
  using (organization_id in (select app_private.org_ids_with('members.manage')));
create policy invitation_branches_read on public.invitation_branches for select to authenticated
  using (organization_id in (select app_private.org_ids_with('members.manage')));

grant select on public.audit_log to authenticated;
create policy audit_log_read on public.audit_log for select to authenticated
  using (organization_id in (select app_private.org_ids_with('audit.read')));

-- -----------------------------------------------------------------------------
-- RPC : organisations
-- -----------------------------------------------------------------------------
create or replace function app_private.unique_brand_slug(p_name text)
returns text language plpgsql volatile set search_path = '' as $$
declare
  v_base text := coalesce(nullif(app_private.slugify(p_name), ''), 'resto');
  v_slug text := v_base;
begin
  while exists (select 1 from public.brands where slug = v_slug) loop
    v_slug := left(v_base, 43) || '-' || substr(md5(gen_random_uuid()::text), 1, 6);
  end loop;
  return v_slug;
end $$;

-- Crée organisation + adhésion propriétaire + marque + premier établissement,
-- en une seule transaction. Limite : 3 créations par compte et par 24 h.
create or replace function public.create_organization(
  p_name text, p_country text, p_currency text, p_locale text, p_timezone text,
  p_city text, p_brand_name text default null, p_branch_name text default null)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare
  v_uid uuid := auth.uid();
  v_org uuid;
  v_brand uuid;
  v_branch uuid;
begin
  if v_uid is null then raise exception 'resto.not_authenticated' using errcode = '42501'; end if;
  perform pg_advisory_xact_lock(hashtext('resto.create_org.' || v_uid::text));
  if (select count(*) from public.organizations
       where created_by = v_uid and created_at > now() - interval '24 hours') >= 3 then
    perform app_private.fail('resto.rate_limited');
  end if;
  if not app_private.is_valid_timezone(p_timezone) then
    perform app_private.fail('resto.invalid_timezone');
  end if;

  insert into public.organizations (name, country_code, default_currency, default_locale, created_by)
  values (btrim(p_name), upper(p_country), upper(p_currency), p_locale, v_uid)
  returning id into v_org;

  insert into public.memberships (organization_id, user_id, role_code, all_branches)
  values (v_org, v_uid, 'owner', true);

  insert into public.brands (organization_id, name, slug)
  values (v_org, coalesce(nullif(btrim(p_brand_name), ''), btrim(p_name)),
          app_private.unique_brand_slug(coalesce(nullif(btrim(p_brand_name), ''), p_name)))
  returning id into v_brand;

  insert into public.branches (organization_id, brand_id, name, slug, country_code, city,
                               timezone, currency, default_locale)
  values (v_org, v_brand, coalesce(nullif(btrim(p_branch_name), ''), btrim(p_city)),
          coalesce(nullif(app_private.slugify(coalesce(nullif(btrim(p_branch_name), ''), p_city)), ''), 'principal'),
          upper(p_country), btrim(p_city), p_timezone, upper(p_currency), p_locale)
  returning id into v_branch;

  insert into public.branch_languages (organization_id, branch_id, locale) values (v_org, v_branch, p_locale);

  return jsonb_build_object('organization_id', v_org, 'brand_id', v_brand, 'branch_id', v_branch);
end $$;

-- Mes adhésions actives, avec permissions et établissements (pour adapter
-- l'interface ; la sécurité reste assurée par la RLS et les RPC).
create or replace function public.my_memberships()
returns jsonb language sql stable security definer set search_path = '' as $$
  select coalesce(jsonb_agg(jsonb_build_object(
    'membership_id', m.id, 'organization_id', o.id, 'organization_name', o.name,
    'organization_status', o.status, 'role', m.role_code, 'all_branches', m.all_branches,
    'branch_ids', coalesce((select jsonb_agg(mb.branch_id) from public.membership_branches mb
                             where mb.membership_id = m.id), '[]'::jsonb),
    'permissions', coalesce((select jsonb_agg(rp.permission_code order by rp.permission_code)
                              from public.role_permissions rp where rp.role_code = m.role_code), '[]'::jsonb)
  ) order by o.name), '[]'::jsonb)
  from public.memberships m
  join public.organizations o on o.id = m.organization_id and o.status <> 'closed'
  where m.user_id = auth.uid() and m.status = 'active'
$$;

-- -----------------------------------------------------------------------------
-- RPC : employés
-- -----------------------------------------------------------------------------

-- Vérifie que l'acteur peut attribuer / modifier ce rôle ; renvoie son rôle.
create or replace function app_private.assert_can_assign(p_org uuid, p_role text)
returns text language plpgsql stable security definer set search_path = '' as $$
declare v_actor text;
begin
  if not app_private.has_org_perm(p_org, 'members.manage') then
    raise exception 'resto.forbidden' using errcode = '42501';
  end if;
  if not exists (select 1 from public.roles where code = p_role) then
    perform app_private.fail('resto.invalid_role');
  end if;
  v_actor := app_private.my_role_in(p_org);
  if p_role = 'owner' and v_actor <> 'owner' then
    raise exception 'resto.owner_only' using errcode = '42501';
  end if;
  return v_actor;
end $$;

create or replace function app_private.assert_branches_in_org(p_org uuid, p_branch_ids uuid[])
returns void language plpgsql stable security definer set search_path = '' as $$
begin
  if exists (select 1 from unnest(coalesce(p_branch_ids, '{}')) x (id)
              where not exists (select 1 from public.branches b where b.id = x.id and b.organization_id = p_org)) then
    perform app_private.fail('resto.invalid_branch');
  end if;
end $$;

-- Invite par e-mail ; renvoie le jeton (affiché / envoyé une seule fois).
create or replace function public.invite_member(
  p_org uuid, p_email text, p_role text, p_all_branches boolean, p_branch_ids uuid[] default '{}')
returns text language plpgsql security definer set search_path = '' as $$
declare
  v_email text := lower(btrim(p_email));
  v_token text := replace(gen_random_uuid()::text, '-', '') || replace(gen_random_uuid()::text, '-', '');
  v_inv uuid;
  v_all boolean := coalesce(p_all_branches, false) or coalesce(p_role in ('owner', 'admin'), false);
begin
  perform app_private.assert_can_assign(p_org, p_role);
  if v_email !~ '^[^@\s]+@[^@\s]+\.[^@\s]+$' then perform app_private.fail('resto.invalid_email'); end if;
  if not v_all and coalesce(cardinality(p_branch_ids), 0) = 0 then
    perform app_private.fail('resto.branches_required');
  end if;
  perform app_private.assert_branches_in_org(p_org, p_branch_ids);
  if (select count(*) from public.invitations
       where organization_id = p_org and created_at > now() - interval '24 hours') >= 50 then
    perform app_private.fail('resto.rate_limited');
  end if;
  if exists (select 1 from public.memberships m join auth.users u on u.id = m.user_id
              where m.organization_id = p_org and m.status = 'active' and lower(u.email) = v_email) then
    perform app_private.fail('resto.already_member');
  end if;

  update public.invitations set status = 'revoked'
   where organization_id = p_org and email = v_email and status = 'pending';

  insert into public.invitations (organization_id, email, role_code, all_branches, token_hash,
                                  expires_at, invited_by)
  values (p_org, v_email, p_role, v_all, sha256(convert_to(v_token, 'UTF8')),
          now() + interval '7 days', auth.uid())
  returning id into v_inv;

  if not v_all then
    insert into public.invitation_branches (organization_id, invitation_id, branch_id)
    select p_org, v_inv, x from unnest(p_branch_ids) x group by x;
  end if;
  return v_token;
end $$;

create or replace function public.accept_invitation(p_token text)
returns uuid language plpgsql security definer set search_path = '' as $$
declare
  v_uid uuid := auth.uid();
  v_inv public.invitations;
  v_email text;
  v_membership uuid;
begin
  if v_uid is null then raise exception 'resto.not_authenticated' using errcode = '42501'; end if;
  select * into v_inv from public.invitations
   where token_hash = sha256(convert_to(coalesce(p_token, ''), 'UTF8')) for update;
  if v_inv.id is null or v_inv.status <> 'pending' or v_inv.expires_at < now() then
    perform app_private.fail('resto.invitation_invalid');
  end if;
  select lower(u.email) into v_email from auth.users u
   where u.id = v_uid and u.email_confirmed_at is not null;
  if v_email is distinct from v_inv.email then
    perform app_private.fail('resto.invitation_wrong_account');
  end if;

  insert into public.memberships (organization_id, user_id, role_code, all_branches, invited_by)
  values (v_inv.organization_id, v_uid, v_inv.role_code, v_inv.all_branches, v_inv.invited_by)
  on conflict (organization_id, user_id) do update
    set role_code = excluded.role_code, all_branches = excluded.all_branches,
        status = 'active', revoked_at = null, revoked_by = null, invited_by = excluded.invited_by
    where public.memberships.status = 'revoked'
  returning id into v_membership;
  -- Déjà membre actif : une invitation ne remplace jamais un rôle existant.
  if v_membership is null then perform app_private.fail('resto.already_member'); end if;

  delete from public.membership_branches where membership_id = v_membership;
  insert into public.membership_branches (organization_id, membership_id, branch_id)
  select v_inv.organization_id, v_membership, ib.branch_id
    from public.invitation_branches ib where ib.invitation_id = v_inv.id;

  update public.invitations set status = 'accepted', accepted_by = v_uid, accepted_at = now()
   where id = v_inv.id;
  return v_inv.organization_id;
end $$;

create or replace function public.revoke_invitation(p_invitation uuid)
returns void language plpgsql security definer set search_path = '' as $$
declare v_org uuid;
begin
  select organization_id into v_org from public.invitations where id = p_invitation;
  if v_org is null or not app_private.has_org_perm(v_org, 'members.manage') then
    raise exception 'resto.forbidden' using errcode = '42501';
  end if;
  update public.invitations set status = 'revoked' where id = p_invitation and status = 'pending';
end $$;

create or replace function app_private.assert_not_last_owner(p_org uuid, p_membership uuid)
returns void language plpgsql stable security definer set search_path = '' as $$
begin
  if not exists (select 1 from public.memberships
                  where organization_id = p_org and role_code = 'owner' and status = 'active'
                    and id <> p_membership) then
    perform app_private.fail('resto.last_owner');
  end if;
end $$;

create or replace function public.update_membership(
  p_membership uuid, p_role text, p_all_branches boolean, p_branch_ids uuid[] default '{}')
returns void language plpgsql security definer set search_path = '' as $$
declare
  v_m public.memberships;
  v_actor text;
  v_all boolean := coalesce(p_all_branches, false) or coalesce(p_role in ('owner', 'admin'), false);
begin
  select * into v_m from public.memberships where id = p_membership;
  if v_m.id is null then raise exception 'resto.forbidden' using errcode = '42501'; end if;
  -- Sérialise les changements d'équipe d'une même organisation.
  perform 1 from public.organizations where id = v_m.organization_id for update;
  v_actor := app_private.assert_can_assign(v_m.organization_id, p_role);
  if v_m.status <> 'active' then perform app_private.fail('resto.membership_revoked'); end if;
  if v_m.role_code = 'owner' and v_actor <> 'owner' then
    raise exception 'resto.owner_only' using errcode = '42501';
  end if;
  if v_m.role_code = 'owner' and p_role <> 'owner' then
    perform app_private.assert_not_last_owner(v_m.organization_id, v_m.id);
  end if;
  if not v_all and coalesce(cardinality(p_branch_ids), 0) = 0 then
    perform app_private.fail('resto.branches_required');
  end if;
  perform app_private.assert_branches_in_org(v_m.organization_id, p_branch_ids);

  update public.memberships set role_code = p_role, all_branches = v_all where id = v_m.id;
  delete from public.membership_branches where membership_id = v_m.id;
  if not v_all then
    insert into public.membership_branches (organization_id, membership_id, branch_id)
    select v_m.organization_id, v_m.id, x from unnest(p_branch_ids) x group by x;
  end if;
end $$;

-- Retire un membre (ou soi-même : quitter l'organisation).
create or replace function public.revoke_membership(p_membership uuid)
returns void language plpgsql security definer set search_path = '' as $$
declare
  v_m public.memberships;
  v_actor text;
begin
  select * into v_m from public.memberships where id = p_membership;
  if v_m.id is null then raise exception 'resto.forbidden' using errcode = '42501'; end if;
  perform 1 from public.organizations where id = v_m.organization_id for update;
  if v_m.user_id <> auth.uid() then
    if not app_private.has_org_perm(v_m.organization_id, 'members.manage') then
      raise exception 'resto.forbidden' using errcode = '42501';
    end if;
    v_actor := app_private.my_role_in(v_m.organization_id);
    if v_m.role_code = 'owner' and v_actor <> 'owner' then
      raise exception 'resto.owner_only' using errcode = '42501';
    end if;
  end if;
  if v_m.status <> 'active' then return; end if;
  if v_m.role_code = 'owner' then
    perform app_private.assert_not_last_owner(v_m.organization_id, v_m.id);
  end if;
  update public.memberships set status = 'revoked', revoked_at = now(), revoked_by = auth.uid()
   where id = v_m.id;
end $$;

-- Liste des membres avec leur e-mail (réservé à members.manage).
create or replace function public.org_members(p_org uuid)
returns table (membership_id uuid, user_id uuid, email text, display_name text, role_code text,
               all_branches boolean, status text, branch_ids uuid[], created_at timestamptz)
language plpgsql stable security definer set search_path = '' as $$
begin
  if not app_private.has_org_perm(p_org, 'members.manage') then
    raise exception 'resto.forbidden' using errcode = '42501';
  end if;
  return query
  select m.id, m.user_id, u.email::text, p.display_name, m.role_code, m.all_branches, m.status,
         coalesce(array(select mb.branch_id from public.membership_branches mb where mb.membership_id = m.id), '{}'),
         m.created_at
    from public.memberships m
    join auth.users u on u.id = m.user_id
    left join public.profiles p on p.id = m.user_id
   where m.organization_id = p_org
   order by m.status, p.display_name, u.email;
end $$;

revoke all on function public.create_organization(text, text, text, text, text, text, text, text),
  public.my_memberships(), public.invite_member(uuid, text, text, boolean, uuid[]),
  public.accept_invitation(text), public.revoke_invitation(uuid),
  public.update_membership(uuid, text, boolean, uuid[]), public.revoke_membership(uuid),
  public.org_members(uuid) from public, anon;
grant execute on function public.create_organization(text, text, text, text, text, text, text, text),
  public.my_memberships(), public.invite_member(uuid, text, text, boolean, uuid[]),
  public.accept_invitation(text), public.revoke_invitation(uuid),
  public.update_membership(uuid, text, boolean, uuid[]), public.revoke_membership(uuid),
  public.org_members(uuid) to authenticated;

-- -----------------------------------------------------------------------------
-- Fonctions internes : seules celles utilisées par les politiques RLS sont
-- exécutables par les utilisateurs connectés.
-- -----------------------------------------------------------------------------
revoke all on all functions in schema app_private from public, anon, authenticated;
grant execute on function app_private.member_org_ids(), app_private.member_branch_ids(),
  app_private.org_ids_with(text), app_private.branch_ids_with(text) to authenticated;
