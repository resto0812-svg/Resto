-- =============================================================================
-- Resto — 015_caisse_pro
-- Caisse professionnelle, utilisable dans tous les pays :
--   • catalogue mondial des modes de paiement (espèces, carte, portefeuilles
--     mobiles, paiements instantanés, titres-restaurant, chèques…) avec les
--     pays où ils sont courants ; chaque organisation choisit et nomme ses
--     propres modes (référence obligatoire, commission, établissements) ;
--     les modes courants du pays sont proposés à la création ;
--   • pourboires enregistrés à part (jamais dans le chiffre d'affaires),
--     attribués au serveur de la commande ;
--   • numéro de ticket légal (séquence par établissement, à la clôture) ;
--   • mentions du ticket par établissement (raison sociale, n° fiscal, pied) ;
--   • comptage par billets et pièces (coupures par monnaie) ;
--   • Z de caisse numéroté à la validation ;
--   • rapport de caisse par période (modes, heures, jours, serveurs, caisses,
--     pourboires, remboursements, annulations, sessions).
-- À coller APRÈS 014, puis supabase/tests/015_caisse_pro_tests.sql.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Catalogue mondial des modes de paiement (référentiel public)
-- -----------------------------------------------------------------------------
create table if not exists public.ref_payment_methods (
  code text primary key check (code ~ '^[a-z0-9_]{2,40}$'),
  kind text not null check (kind in ('cash', 'card', 'mobile_wallet', 'instant_transfer', 'bank_transfer', 'voucher',
                                     'cheque', 'customer_account', 'other')),
  name text not null check (length(btrim(name)) between 1 and 60),
  countries char(2)[] not null default '{}',   -- vide = partout
  default_on boolean not null default false,    -- activé d'office dans ces pays
  requires_reference boolean not null default false,
  sort_order smallint not null default 100
);
alter table public.ref_payment_methods enable row level security;
revoke all on public.ref_payment_methods from anon, authenticated;
grant select on public.ref_payment_methods to anon, authenticated;
drop policy if exists ref_payment_methods_read on public.ref_payment_methods;
create policy ref_payment_methods_read on public.ref_payment_methods for select to anon, authenticated using (true);

insert into public.ref_payment_methods (code, kind, name, countries, default_on, requires_reference, sort_order) values
  ('cash', 'cash', 'Espèces', '{}', true, false, 1),
  ('card', 'card', 'Carte bancaire', '{}', true, false, 2),
  ('contactless_wallet', 'card', 'Apple Pay / Google Pay', '{}', false, false, 3),
  ('bank_transfer', 'bank_transfer', 'Virement bancaire', '{}', false, true, 20),
  ('gift_card', 'voucher', 'Carte cadeau', '{}', false, true, 30),
  ('customer_account', 'customer_account', 'Compte client', '{}', false, false, 40),
  ('other', 'other', 'Autre', '{}', false, false, 99),
  ('meal_voucher', 'voucher', 'Titre-restaurant', '{FR,BE,LU,BR,IT,ES,PT,CZ,RO,AT,TR,MX}', true, false, 10),
  ('cheque', 'cheque', 'Chèque', '{FR,BE,US,CA,IE,MA,TN,DZ,SN,CI,CM}', false, true, 15),
  ('interac', 'card', 'Interac', '{CA}', true, false, 5),
  ('pix', 'instant_transfer', 'Pix', '{BR}', true, true, 4),
  ('upi', 'instant_transfer', 'UPI', '{IN}', true, true, 4),
  ('alipay', 'mobile_wallet', 'Alipay', '{CN,HK,MO}', true, true, 4),
  ('wechat_pay', 'mobile_wallet', 'WeChat Pay', '{CN,HK,MO}', true, true, 5),
  ('twint', 'mobile_wallet', 'TWINT', '{CH}', true, true, 4),
  ('bizum', 'instant_transfer', 'Bizum', '{ES}', true, true, 4),
  ('mbway', 'mobile_wallet', 'MB WAY', '{PT}', true, true, 4),
  ('ideal', 'instant_transfer', 'iDEAL', '{NL}', false, true, 6),
  ('swish', 'instant_transfer', 'Swish', '{SE}', true, true, 4),
  ('mobilepay', 'mobile_wallet', 'MobilePay', '{DK,FI}', true, true, 4),
  ('vipps', 'mobile_wallet', 'Vipps', '{NO}', true, true, 4),
  ('blik', 'instant_transfer', 'BLIK', '{PL}', true, true, 4),
  ('paynow', 'instant_transfer', 'PayNow', '{SG}', true, true, 4),
  ('promptpay', 'instant_transfer', 'PromptPay', '{TH}', true, true, 4),
  ('duitnow', 'instant_transfer', 'DuitNow', '{MY}', true, true, 4),
  ('qris', 'instant_transfer', 'QRIS', '{ID}', true, true, 4),
  ('gcash', 'mobile_wallet', 'GCash', '{PH}', true, true, 4),
  ('mpesa', 'mobile_wallet', 'M-Pesa', '{KE,TZ,MZ,LS,GH,EG}', true, true, 4),
  ('mtn_momo', 'mobile_wallet', 'MTN Mobile Money', '{CM,CI,GH,UG,RW,BJ,CG,ZM,GN,LR,SS,ZA}', true, true, 5),
  ('orange_money', 'mobile_wallet', 'Orange Money', '{CM,CI,SN,ML,BF,GN,MG,CD,NE,CF,SL,LR,BW,MA,TN,JO}', true, true, 6),
  ('wave', 'mobile_wallet', 'Wave', '{SN,CI,ML,BF,GM,UG}', true, true, 7),
  ('moov_money', 'mobile_wallet', 'Moov Money', '{BJ,TG,CI,BF,NE,ML,GA,TD,CF}', true, true, 8),
  ('airtel_money', 'mobile_wallet', 'Airtel Money', '{CD,UG,KE,TZ,RW,ZM,MW,NE,TD,CG,GA,MG,NG,SC}', true, true, 9),
  ('ecocash', 'mobile_wallet', 'EcoCash', '{ZW}', true, true, 4),
  ('venmo', 'mobile_wallet', 'Venmo', '{US}', false, true, 8),
  ('cash_app', 'mobile_wallet', 'Cash App', '{US,GB}', false, true, 9)
on conflict (code) do nothing;

-- Noms des modes génériques dans les langues de l'interface (les marques gardent leur nom).
alter table public.ref_payment_methods add column if not exists names jsonb not null default '{}';
update public.ref_payment_methods r set names = v.names
  from (values
    ('cash', '{"fr":"Espèces","en":"Cash","de":"Bargeld","es":"Efectivo","pt":"Numerário","ar":"نقدًا","zh-Hans":"现金","zh-Hant":"現金"}'::jsonb),
    ('card', '{"fr":"Carte bancaire","en":"Card","de":"Karte","es":"Tarjeta","pt":"Cartão","ar":"بطاقة بنكية","zh-Hans":"银行卡","zh-Hant":"銀行卡"}'),
    ('bank_transfer', '{"fr":"Virement bancaire","en":"Bank transfer","de":"Überweisung","es":"Transferencia","pt":"Transferência bancária","ar":"تحويل بنكي","zh-Hans":"银行转账","zh-Hant":"銀行轉帳"}'),
    ('gift_card', '{"fr":"Carte cadeau","en":"Gift card","de":"Geschenkkarte","es":"Tarjeta regalo","pt":"Cartão-presente","ar":"بطاقة هدية","zh-Hans":"礼品卡","zh-Hant":"禮品卡"}'),
    ('customer_account', '{"fr":"Compte client","en":"Customer account","de":"Kundenkonto","es":"Cuenta de cliente","pt":"Conta de cliente","ar":"حساب الزبون","zh-Hans":"客户账户","zh-Hant":"客戶帳戶"}'),
    ('other', '{"fr":"Autre","en":"Other","de":"Sonstiges","es":"Otro","pt":"Outro","ar":"أخرى","zh-Hans":"其他","zh-Hant":"其他"}'),
    ('meal_voucher', '{"fr":"Titre-restaurant","en":"Meal voucher","de":"Essensgutschein","es":"Vale de comida","pt":"Vale-refeição","ar":"قسيمة طعام","zh-Hans":"餐券","zh-Hant":"餐券"}'),
    ('cheque', '{"fr":"Chèque","en":"Cheque","de":"Scheck","es":"Cheque","pt":"Cheque","ar":"شيك","zh-Hans":"支票","zh-Hant":"支票"}'),
    ('contactless_wallet', '{"fr":"Apple Pay / Google Pay","en":"Apple Pay / Google Pay"}')
  ) as v (code, names)
 where r.code = v.code;

-- -----------------------------------------------------------------------------
-- Modes de paiement de chaque organisation
-- -----------------------------------------------------------------------------
create table if not exists public.payment_methods (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations (id) on delete restrict,
  ref_code text references public.ref_payment_methods (code) on delete set null,
  name text not null check (length(btrim(name)) between 1 and 60),
  kind text not null check (kind in ('cash', 'card', 'mobile_wallet', 'instant_transfer', 'bank_transfer', 'voucher',
                                     'cheque', 'customer_account', 'other')),
  requires_reference boolean not null default false,
  fee_percent numeric(5, 2) not null default 0 check (fee_percent between 0 and 100),
  branch_ids uuid[] not null default '{}',      -- vide = tous les établissements
  active boolean not null default true,
  sort_order smallint not null default 100,
  created_at timestamptz not null default now(),
  unique (organization_id, id),
  unique (organization_id, name)
);
create index if not exists payment_methods_org_idx on public.payment_methods (organization_id, sort_order);
alter table public.payment_methods enable row level security;
revoke all on public.payment_methods from anon, authenticated;
grant select, insert (id, organization_id, ref_code, name, kind, requires_reference, fee_percent, branch_ids, active, sort_order),
  update (name, requires_reference, fee_percent, branch_ids, active, sort_order) on public.payment_methods to authenticated;
create policy payment_methods_read on public.payment_methods for select to authenticated
  using (organization_id in (select app_private.member_org_ids()));
create policy payment_methods_insert on public.payment_methods for insert to authenticated
  with check (organization_id in (select app_private.org_ids_with('org.manage')));
create policy payment_methods_update on public.payment_methods for update to authenticated
  using (organization_id in (select app_private.org_ids_with('org.manage')))
  with check (organization_id in (select app_private.org_ids_with('org.manage')));
create trigger payment_methods_audit after insert or update or delete on public.payment_methods
  for each row execute function app_private.audit_row();

-- Modes courants du pays de l'organisation (activés d'office).
create or replace function app_private.seed_payment_methods(p_org uuid)
returns void language plpgsql volatile security definer set search_path = '' as $$
declare
  v_country char(2);
  v_locale text;
begin
  select country_code, default_locale into v_country, v_locale from public.organizations where id = p_org;
  insert into public.payment_methods (organization_id, ref_code, name, kind, requires_reference, sort_order)
  select p_org, r.code, coalesce(r.names ->> v_locale, r.name), r.kind, r.requires_reference, r.sort_order
    from public.ref_payment_methods r
   where r.default_on and (cardinality(r.countries) = 0 or v_country = any (r.countries))
  on conflict (organization_id, name) do nothing;
end $$;

create or replace function app_private.on_organization_created_payment_methods()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  perform app_private.seed_payment_methods(new.id);
  return null;
end $$;
drop trigger if exists organizations_payment_methods on public.organizations;
create trigger organizations_payment_methods after insert on public.organizations
  for each row execute function app_private.on_organization_created_payment_methods();

select app_private.seed_payment_methods(o.id) from public.organizations o;

-- -----------------------------------------------------------------------------
-- Paiements : mode choisi, pourboire, nouveaux types
-- -----------------------------------------------------------------------------
alter table public.payments
  add column if not exists payment_method_id uuid,
  add column if not exists tip_minor bigint not null default 0 check (tip_minor between 0 and 9007199254740991);
do $$
begin
  if not exists (select 1 from pg_constraint where conname = 'payments_method_fk') then
    alter table public.payments add constraint payments_method_fk
      foreign key (organization_id, payment_method_id) references public.payment_methods (organization_id, id) on delete restrict;
  end if;
end $$;
create index if not exists payments_method_idx on public.payments (payment_method_id);

alter table public.payments drop constraint if exists payments_method_check;
alter table public.payments add constraint payments_method_check check (method in ('cash', 'card', 'mobile_money', 'transfer',
  'other', 'mobile_wallet', 'instant_transfer', 'bank_transfer', 'voucher', 'cheque', 'customer_account'));
alter table public.refunds drop constraint if exists refunds_method_check;
alter table public.refunds add constraint refunds_method_check check (method in ('cash', 'card', 'mobile_money', 'transfer',
  'other', 'mobile_wallet', 'instant_transfer', 'bank_transfer', 'voucher', 'cheque', 'customer_account'));

-- Espèces remises : couvrent le montant et le pourboire ; monnaie rendue recalculée.
alter table public.payments drop constraint if exists payments_tendered_minor_check;
alter table public.payments drop column if exists change_minor;
alter table public.payments add column change_minor bigint
  generated always as (coalesce(tendered_minor, amount_minor + tip_minor) - amount_minor - tip_minor) stored;
alter table public.payments add constraint payments_tendered_minor_check
  check (tendered_minor is null or tendered_minor >= amount_minor + tip_minor);

-- Espèces attendues : les pourboires en espèces sont dans le tiroir.
create or replace function app_private.expected_cash(p_session uuid)
returns bigint language sql stable security definer set search_path = '' as $$
  select s.opening_float_minor
       + coalesce((select sum(amount_minor + tip_minor) from public.payments
                    where session_id = s.id and method = 'cash' and status = 'confirmed'), 0)
       - coalesce((select sum(amount_minor) from public.refunds where session_id = s.id and method = 'cash'), 0)
       + coalesce((select sum(amount_minor) from public.cash_movements where session_id = s.id and kind = 'in'), 0)
       - coalesce((select sum(amount_minor) from public.cash_movements where session_id = s.id and kind = 'out'), 0)
    from public.cash_sessions s where s.id = p_session
$$;

-- -----------------------------------------------------------------------------
-- Établissement : mentions du ticket, pourboires
-- -----------------------------------------------------------------------------
alter table public.branches
  add column if not exists legal_name text check (length(legal_name) <= 160),
  add column if not exists tax_identifier text check (length(tax_identifier) <= 60),
  add column if not exists receipt_footer text check (length(receipt_footer) <= 300),
  add column if not exists tips_enabled boolean not null default true,
  add column if not exists tip_presets smallint[] not null default '{5,10,15}' check (cardinality(tip_presets) <= 6);
grant insert (legal_name, tax_identifier, receipt_footer, tips_enabled, tip_presets),
  update (legal_name, tax_identifier, receipt_footer, tips_enabled, tip_presets) on public.branches to authenticated;

-- -----------------------------------------------------------------------------
-- Numéro de ticket légal : séquence par établissement, attribuée à la clôture
-- -----------------------------------------------------------------------------
alter table public.orders add column if not exists receipt_number bigint;
create unique index if not exists orders_receipt_number_idx on public.orders (branch_id, receipt_number) where receipt_number is not null;

create or replace function app_private.assign_receipt_number()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  if new.status = 'closed' and old.status is distinct from 'closed' and new.receipt_number is null then
    new.receipt_number := app_private.next_counter(new.branch_id, 'receipt');
  end if;
  return new;
end $$;
drop trigger if exists orders_receipt_number on public.orders;
create trigger orders_receipt_number before update of status on public.orders
  for each row execute function app_private.assign_receipt_number();

-- -----------------------------------------------------------------------------
-- Coupures (billets et pièces) par monnaie, pour le comptage
-- -----------------------------------------------------------------------------
create table if not exists public.ref_currency_denominations (
  currency char(3) not null references public.ref_currencies (code),
  value_minor bigint not null check (value_minor > 0),
  kind text not null check (kind in ('note', 'coin')),
  primary key (currency, value_minor)
);
alter table public.ref_currency_denominations enable row level security;
revoke all on public.ref_currency_denominations from anon, authenticated;
grant select on public.ref_currency_denominations to anon, authenticated;
drop policy if exists ref_currency_denominations_read on public.ref_currency_denominations;
create policy ref_currency_denominations_read on public.ref_currency_denominations for select to anon, authenticated using (true);

insert into public.ref_currency_denominations (currency, value_minor, kind)
select d.cur, round(d.major * power(10, c.minor_unit))::bigint, d.kind
  from (values
    ('XAF', 10000, 'note'), ('XAF', 5000, 'note'), ('XAF', 2000, 'note'), ('XAF', 1000, 'note'), ('XAF', 500, 'coin'),
    ('XAF', 100, 'coin'), ('XAF', 50, 'coin'), ('XAF', 25, 'coin'), ('XAF', 10, 'coin'), ('XAF', 5, 'coin'),
    ('XOF', 10000, 'note'), ('XOF', 5000, 'note'), ('XOF', 2000, 'note'), ('XOF', 1000, 'note'), ('XOF', 500, 'note'),
    ('XOF', 250, 'coin'), ('XOF', 200, 'coin'), ('XOF', 100, 'coin'), ('XOF', 50, 'coin'), ('XOF', 25, 'coin'),
    ('XOF', 10, 'coin'), ('XOF', 5, 'coin'),
    ('EUR', 500, 'note'), ('EUR', 200, 'note'), ('EUR', 100, 'note'), ('EUR', 50, 'note'), ('EUR', 20, 'note'),
    ('EUR', 10, 'note'), ('EUR', 5, 'note'), ('EUR', 2, 'coin'), ('EUR', 1, 'coin'), ('EUR', 0.5, 'coin'),
    ('EUR', 0.2, 'coin'), ('EUR', 0.1, 'coin'), ('EUR', 0.05, 'coin'), ('EUR', 0.02, 'coin'), ('EUR', 0.01, 'coin'),
    ('USD', 100, 'note'), ('USD', 50, 'note'), ('USD', 20, 'note'), ('USD', 10, 'note'), ('USD', 5, 'note'),
    ('USD', 2, 'note'), ('USD', 1, 'note'), ('USD', 0.25, 'coin'), ('USD', 0.1, 'coin'), ('USD', 0.05, 'coin'),
    ('USD', 0.01, 'coin'),
    ('GBP', 50, 'note'), ('GBP', 20, 'note'), ('GBP', 10, 'note'), ('GBP', 5, 'note'), ('GBP', 2, 'coin'),
    ('GBP', 1, 'coin'), ('GBP', 0.5, 'coin'), ('GBP', 0.2, 'coin'), ('GBP', 0.1, 'coin'), ('GBP', 0.05, 'coin'),
    ('GBP', 0.02, 'coin'), ('GBP', 0.01, 'coin'),
    ('CHF', 1000, 'note'), ('CHF', 200, 'note'), ('CHF', 100, 'note'), ('CHF', 50, 'note'), ('CHF', 20, 'note'),
    ('CHF', 10, 'note'), ('CHF', 5, 'coin'), ('CHF', 2, 'coin'), ('CHF', 1, 'coin'), ('CHF', 0.5, 'coin'),
    ('CHF', 0.2, 'coin'), ('CHF', 0.1, 'coin'), ('CHF', 0.05, 'coin'),
    ('CAD', 100, 'note'), ('CAD', 50, 'note'), ('CAD', 20, 'note'), ('CAD', 10, 'note'), ('CAD', 5, 'note'),
    ('CAD', 2, 'coin'), ('CAD', 1, 'coin'), ('CAD', 0.25, 'coin'), ('CAD', 0.1, 'coin'), ('CAD', 0.05, 'coin'),
    ('AUD', 100, 'note'), ('AUD', 50, 'note'), ('AUD', 20, 'note'), ('AUD', 10, 'note'), ('AUD', 5, 'note'),
    ('AUD', 2, 'coin'), ('AUD', 1, 'coin'), ('AUD', 0.5, 'coin'), ('AUD', 0.2, 'coin'), ('AUD', 0.1, 'coin'),
    ('AUD', 0.05, 'coin'),
    ('MAD', 200, 'note'), ('MAD', 100, 'note'), ('MAD', 50, 'note'), ('MAD', 20, 'note'), ('MAD', 10, 'coin'),
    ('MAD', 5, 'coin'), ('MAD', 2, 'coin'), ('MAD', 1, 'coin'), ('MAD', 0.5, 'coin'),
    ('DZD', 2000, 'note'), ('DZD', 1000, 'note'), ('DZD', 500, 'note'), ('DZD', 200, 'note'), ('DZD', 100, 'coin'),
    ('DZD', 50, 'coin'), ('DZD', 20, 'coin'), ('DZD', 10, 'coin'), ('DZD', 5, 'coin'),
    ('TND', 50, 'note'), ('TND', 20, 'note'), ('TND', 10, 'note'), ('TND', 5, 'coin'), ('TND', 2, 'coin'),
    ('TND', 1, 'coin'), ('TND', 0.5, 'coin'), ('TND', 0.2, 'coin'), ('TND', 0.1, 'coin'),
    ('EGP', 200, 'note'), ('EGP', 100, 'note'), ('EGP', 50, 'note'), ('EGP', 20, 'note'), ('EGP', 10, 'note'),
    ('EGP', 5, 'note'), ('EGP', 1, 'coin'), ('EGP', 0.5, 'coin'),
    ('NGN', 1000, 'note'), ('NGN', 500, 'note'), ('NGN', 200, 'note'), ('NGN', 100, 'note'), ('NGN', 50, 'note'),
    ('NGN', 20, 'note'), ('NGN', 10, 'note'), ('NGN', 5, 'note'),
    ('GHS', 200, 'note'), ('GHS', 100, 'note'), ('GHS', 50, 'note'), ('GHS', 20, 'note'), ('GHS', 10, 'note'),
    ('GHS', 5, 'note'), ('GHS', 2, 'coin'), ('GHS', 1, 'coin'), ('GHS', 0.5, 'coin'), ('GHS', 0.2, 'coin'),
    ('KES', 1000, 'note'), ('KES', 500, 'note'), ('KES', 200, 'note'), ('KES', 100, 'note'), ('KES', 50, 'note'),
    ('KES', 20, 'coin'), ('KES', 10, 'coin'), ('KES', 5, 'coin'), ('KES', 1, 'coin'),
    ('ZAR', 200, 'note'), ('ZAR', 100, 'note'), ('ZAR', 50, 'note'), ('ZAR', 20, 'note'), ('ZAR', 10, 'note'),
    ('ZAR', 5, 'coin'), ('ZAR', 2, 'coin'), ('ZAR', 1, 'coin'), ('ZAR', 0.5, 'coin'), ('ZAR', 0.2, 'coin'),
    ('ZAR', 0.1, 'coin'),
    ('CDF', 20000, 'note'), ('CDF', 10000, 'note'), ('CDF', 5000, 'note'), ('CDF', 1000, 'note'), ('CDF', 500, 'note'),
    ('CDF', 200, 'note'), ('CDF', 100, 'note'), ('CDF', 50, 'note'),
    ('RWF', 5000, 'note'), ('RWF', 2000, 'note'), ('RWF', 1000, 'note'), ('RWF', 500, 'note'), ('RWF', 100, 'coin'),
    ('RWF', 50, 'coin'), ('RWF', 20, 'coin'), ('RWF', 10, 'coin'),
    ('INR', 500, 'note'), ('INR', 200, 'note'), ('INR', 100, 'note'), ('INR', 50, 'note'), ('INR', 20, 'note'),
    ('INR', 10, 'note'), ('INR', 5, 'coin'), ('INR', 2, 'coin'), ('INR', 1, 'coin'),
    ('CNY', 100, 'note'), ('CNY', 50, 'note'), ('CNY', 20, 'note'), ('CNY', 10, 'note'), ('CNY', 5, 'note'),
    ('CNY', 1, 'coin'), ('CNY', 0.5, 'coin'), ('CNY', 0.1, 'coin'),
    ('JPY', 10000, 'note'), ('JPY', 5000, 'note'), ('JPY', 2000, 'note'), ('JPY', 1000, 'note'), ('JPY', 500, 'coin'),
    ('JPY', 100, 'coin'), ('JPY', 50, 'coin'), ('JPY', 10, 'coin'), ('JPY', 5, 'coin'), ('JPY', 1, 'coin'),
    ('BRL', 200, 'note'), ('BRL', 100, 'note'), ('BRL', 50, 'note'), ('BRL', 20, 'note'), ('BRL', 10, 'note'),
    ('BRL', 5, 'note'), ('BRL', 2, 'note'), ('BRL', 1, 'coin'), ('BRL', 0.5, 'coin'), ('BRL', 0.25, 'coin'),
    ('BRL', 0.1, 'coin'), ('BRL', 0.05, 'coin'),
    ('MXN', 1000, 'note'), ('MXN', 500, 'note'), ('MXN', 200, 'note'), ('MXN', 100, 'note'), ('MXN', 50, 'note'),
    ('MXN', 20, 'note'), ('MXN', 10, 'coin'), ('MXN', 5, 'coin'), ('MXN', 2, 'coin'), ('MXN', 1, 'coin'),
    ('MXN', 0.5, 'coin'),
    ('AED', 1000, 'note'), ('AED', 500, 'note'), ('AED', 200, 'note'), ('AED', 100, 'note'), ('AED', 50, 'note'),
    ('AED', 20, 'note'), ('AED', 10, 'note'), ('AED', 5, 'note'), ('AED', 1, 'coin'), ('AED', 0.5, 'coin'),
    ('AED', 0.25, 'coin')
  ) as d (cur, major, kind)
  join public.ref_currencies c on c.code = d.cur
on conflict do nothing;

-- -----------------------------------------------------------------------------
-- Sessions : détail des coupures, numéro de Z
-- -----------------------------------------------------------------------------
alter table public.cash_sessions
  add column if not exists opening_detail jsonb,
  add column if not exists count_detail jsonb,
  add column if not exists z_number integer;
create unique index if not exists cash_sessions_z_idx on public.cash_sessions (branch_id, z_number) where z_number is not null;

-- Détail {"valeur en unités mineures": nombre} : nombres entiers positifs,
-- total égal au montant annoncé.
create or replace function app_private.check_cash_detail(p_detail jsonb, p_total bigint)
returns void language plpgsql immutable security definer set search_path = '' as $$
declare
  r record;
  v_sum numeric := 0;
begin
  if p_detail is null then return; end if;
  if jsonb_typeof(p_detail) <> 'object' then perform app_private.fail('resto.invalid_amount'); end if;
  for r in select key, value from jsonb_each_text(p_detail) loop
    if r.key !~ '^[0-9]{1,15}$' or r.value !~ '^[0-9]{1,9}$' then perform app_private.fail('resto.invalid_amount'); end if;
    v_sum := v_sum + r.key::numeric * r.value::numeric;
  end loop;
  if v_sum <> p_total then perform app_private.fail('resto.invalid_amount'); end if;
end $$;

drop function if exists public.open_cash_session(uuid, bigint, uuid);
create or replace function public.open_cash_session(p_register uuid, p_float bigint, p_client_id uuid default null,
  p_detail jsonb default null)
returns uuid language plpgsql security definer set search_path = '' as $$
declare
  v_reg public.cash_registers;
  v_id uuid;
begin
  select * into v_reg from public.cash_registers where id = p_register;
  perform app_private.assert_branch_perm(v_reg.branch_id, 'cash.operate');
  if p_client_id is not null and exists (select 1 from public.cash_sessions where id = p_client_id) then
    return p_client_id;
  end if;
  if not v_reg.active then perform app_private.fail('resto.register_inactive'); end if;
  if coalesce(p_float, -1) < 0 then perform app_private.fail('resto.invalid_amount'); end if;
  perform app_private.check_cash_detail(p_detail, p_float);
  perform pg_advisory_xact_lock(hashtext('resto.register.' || p_register::text));
  if exists (select 1 from public.cash_sessions where register_id = p_register and status = 'open') then
    perform app_private.fail('resto.session_already_open');
  end if;
  insert into public.cash_sessions (id, organization_id, branch_id, register_id, currency, opening_float_minor, opened_by,
                                    opening_detail)
  select coalesce(p_client_id, gen_random_uuid()), v_reg.organization_id, v_reg.branch_id, v_reg.id, b.currency,
         p_float, auth.uid(), p_detail
    from public.branches b where b.id = v_reg.branch_id
  returning id into v_id;
  return v_id;
end $$;

drop function if exists public.count_cash_session(uuid, bigint, text);
create or replace function public.count_cash_session(p_session uuid, p_counted bigint, p_note text default null,
  p_detail jsonb default null)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare
  v_branch uuid;
  v_expected bigint;
begin
  select branch_id into v_branch from public.cash_sessions where id = p_session;
  perform app_private.assert_branch_perm(v_branch, 'cash.operate');
  perform app_private.lock_open_session(p_session, v_branch);
  if coalesce(p_counted, -1) < 0 then perform app_private.fail('resto.invalid_amount'); end if;
  perform app_private.check_cash_detail(p_detail, p_counted);
  v_expected := app_private.expected_cash(p_session);
  update public.cash_sessions set status = 'counted', expected_cash_minor = v_expected, counted_cash_minor = p_counted,
         difference_minor = p_counted - v_expected, count_note = nullif(btrim(p_note), ''), count_detail = p_detail,
         counted_by = auth.uid(), counted_at = now()
   where id = p_session;
  return jsonb_build_object('expected', v_expected, 'counted', p_counted, 'difference', p_counted - v_expected);
end $$;

-- Validation (cash.close) : session close et Z numéroté (séquence par établissement).
create or replace function public.validate_cash_session(p_session uuid, p_note text default null)
returns void language plpgsql security definer set search_path = '' as $$
declare v public.cash_sessions;
begin
  select * into v from public.cash_sessions where id = p_session for update;
  perform app_private.assert_branch_perm(v.branch_id, 'cash.close');
  if v.status <> 'counted' then perform app_private.fail('resto.session_not_counted'); end if;
  if v.difference_minor <> 0 and length(btrim(coalesce(p_note, v.count_note, ''))) < 3 then
    perform app_private.fail('resto.reason_required');
  end if;
  update public.cash_sessions set status = 'closed', validated_by = auth.uid(), validated_at = now(),
         validation_note = nullif(btrim(p_note), ''), z_number = app_private.next_counter(v.branch_id, 'z')::integer
   where id = p_session;
end $$;

-- -----------------------------------------------------------------------------
-- Encaissement avec le mode choisi et le pourboire
-- -----------------------------------------------------------------------------
create or replace function public.take_payment(
  p_order uuid, p_session uuid, p_payment_method uuid, p_amount bigint, p_tip bigint default 0,
  p_tendered bigint default null, p_reference text default null, p_client_id uuid default null)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare
  v_order public.orders;
  v_session public.cash_sessions;
  v_method public.payment_methods;
  v_payment public.payments;
  v_due bigint;
  v_closed boolean;
  v_tip bigint := coalesce(p_tip, 0);
begin
  if p_client_id is not null then
    select * into v_payment from public.payments where id = p_client_id;
    if v_payment.id is not null then
      perform app_private.assert_branch_perm(v_payment.branch_id, 'cash.operate');
      return jsonb_build_object('payment_id', v_payment.id, 'change', v_payment.change_minor,
        'due', (select total_minor - paid_minor from public.orders where id = v_payment.order_id),
        'closed', (select status = 'closed' from public.orders where id = v_payment.order_id),
        'receipt_number', (select receipt_number from public.orders where id = v_payment.order_id));
    end if;
  end if;
  v_order := app_private.lock_open_order(p_order, 'cash.operate');
  v_session := app_private.lock_open_session(p_session, v_order.branch_id);
  if v_session.currency <> v_order.currency then perform app_private.fail('resto.invalid_amount'); end if;
  select * into v_method from public.payment_methods where id = p_payment_method;
  if v_method.id is null or v_method.organization_id <> v_order.organization_id or not v_method.active
     or (cardinality(v_method.branch_ids) > 0 and not (v_order.branch_id = any (v_method.branch_ids))) then
    perform app_private.fail('resto.payment_method_unavailable');
  end if;
  if v_method.requires_reference and length(btrim(coalesce(p_reference, ''))) < 3 then
    perform app_private.fail('resto.reference_required');
  end if;
  v_due := v_order.total_minor - v_order.paid_minor;
  if coalesce(p_amount, 0) <= 0 or p_amount > v_due then perform app_private.fail('resto.overpayment'); end if;
  if v_tip < 0 then perform app_private.fail('resto.invalid_amount'); end if;
  if v_method.kind <> 'cash' and p_tendered is not null then perform app_private.fail('resto.invalid_payment'); end if;
  if p_tendered is not null and p_tendered < p_amount + v_tip then perform app_private.fail('resto.invalid_amount'); end if;

  insert into public.payments (id, organization_id, branch_id, order_id, session_id, method, payment_method_id, currency,
                               amount_minor, tip_minor, tendered_minor, reference, created_by)
  values (coalesce(p_client_id, gen_random_uuid()), v_order.organization_id, v_order.branch_id, p_order, p_session,
          v_method.kind, v_method.id, v_order.currency, p_amount, v_tip, p_tendered, nullif(btrim(p_reference), ''), auth.uid())
  returning * into v_payment;
  perform app_private.recompute_paid(p_order);
  perform app_private.log_order(v_order, 'payment', null,
    jsonb_build_object('method', v_method.name, 'amount', p_amount, 'tip', v_tip, 'payment_id', v_payment.id));
  v_closed := app_private.try_close_order(p_order);
  return jsonb_build_object('payment_id', v_payment.id, 'change', v_payment.change_minor, 'due', v_due - p_amount,
    'closed', v_closed, 'receipt_number', (select receipt_number from public.orders where id = p_order));
end $$;

-- -----------------------------------------------------------------------------
-- Annuaire de l'équipe (noms affichés dans la caisse et les rapports)
-- -----------------------------------------------------------------------------
create or replace function public.staff_directory(p_org uuid)
returns table (user_id uuid, display_name text)
language sql stable security definer set search_path = '' as $$
  select m.user_id, coalesce(nullif(btrim(p.display_name), ''), split_part(u.email, '@', 1))
    from public.memberships m
    join auth.users u on u.id = m.user_id
    left join public.profiles p on p.id = m.user_id
   where m.organization_id = p_org and m.status = 'active'
     and p_org in (select app_private.member_org_ids())
$$;

-- -----------------------------------------------------------------------------
-- Résumé de session (remplace 006) : par mode choisi, pourboires
-- -----------------------------------------------------------------------------
create or replace function public.cash_session_summary(p_session uuid)
returns jsonb language plpgsql stable security definer set search_path = '' as $$
declare v public.cash_sessions;
begin
  select * into v from public.cash_sessions where id = p_session;
  if v.id is null or not (
       exists (select 1 from app_private.branch_ids_with('cash.operate') x where x = v.branch_id)
    or exists (select 1 from app_private.branch_ids_with('finance.read') x where x = v.branch_id)) then
    raise exception 'resto.forbidden' using errcode = '42501';
  end if;
  return jsonb_build_object(
    'opening_float', v.opening_float_minor,
    'expected_cash', app_private.expected_cash(p_session),
    'movements_in', coalesce((select sum(amount_minor) from public.cash_movements where session_id = p_session and kind = 'in'), 0),
    'movements_out', coalesce((select sum(amount_minor) from public.cash_movements where session_id = p_session and kind = 'out'), 0),
    'payments_count', (select count(*) from public.payments where session_id = p_session and status = 'confirmed'),
    'collected', coalesce((select sum(amount_minor) from public.payments where session_id = p_session and status = 'confirmed'), 0)
               - coalesce((select sum(amount_minor) from public.refunds where session_id = p_session), 0),
    'tips', coalesce((select sum(tip_minor) from public.payments where session_id = p_session and status = 'confirmed'), 0),
    'cash_tips', coalesce((select sum(tip_minor) from public.payments
                            where session_id = p_session and status = 'confirmed' and method = 'cash'), 0),
    'voided_count', (select count(*) from public.payments where session_id = p_session and status = 'voided'),
    'by_method', coalesce((
      select jsonb_agg(jsonb_build_object('name', name, 'kind', kind, 'total', total, 'tips', tips, 'count', n) order by total desc)
        from (select coalesce(pm.name, p.method) as name, p.method as kind, sum(p.amount_minor) as total,
                     sum(p.tip_minor) as tips, count(*) as n
                from public.payments p left join public.payment_methods pm on pm.id = p.payment_method_id
               where p.session_id = p_session and p.status = 'confirmed'
               group by coalesce(pm.name, p.method), p.method) m), '[]'::jsonb),
    'refunds', coalesce((select sum(amount_minor) from public.refunds where session_id = p_session), 0));
end $$;

-- -----------------------------------------------------------------------------
-- Rapport de caisse par période (journées locales de l'établissement)
-- -----------------------------------------------------------------------------
create or replace function public.cash_report(p_branch uuid, p_from date, p_to date)
returns jsonb language plpgsql stable security definer set search_path = '' as $$
declare v_tz text;
begin
  if not (exists (select 1 from app_private.branch_ids_with('finance.read') x where x = p_branch)
       or exists (select 1 from app_private.branch_ids_with('cash.close') x where x = p_branch)) then
    raise exception 'resto.forbidden' using errcode = '42501';
  end if;
  if p_from is null or p_to is null or p_to < p_from or p_to - p_from > 366 then
    perform app_private.fail('resto.invalid_period');
  end if;
  select timezone into v_tz from public.branches where id = p_branch;
  return (
    with p as (
           select p.*, (p.created_at at time zone v_tz) as local_at, coalesce(pm.name, p.method) as method_name,
                  pm.fee_percent
             from public.payments p left join public.payment_methods pm on pm.id = p.payment_method_id
            where p.branch_id = p_branch and (p.created_at at time zone v_tz)::date between p_from and p_to),
         ok as (select * from p where status = 'confirmed'),
         r as (select * from public.refunds
                where branch_id = p_branch and (created_at at time zone v_tz)::date between p_from and p_to),
         o as (select * from public.orders where branch_id = p_branch and business_date between p_from and p_to)
    select jsonb_build_object(
      'sales_total', coalesce((select sum(total_minor) from o where status = 'closed'), 0),
      'sales_tax', coalesce((select sum(tax_minor) from o where status = 'closed'), 0),
      'discounts', coalesce((select sum(discount_minor) from o where status = 'closed'), 0),
      'orders_closed', (select count(*) from o where status = 'closed'),
      'orders_cancelled', (select count(*) from o where status = 'cancelled'),
      'average_ticket', coalesce((select round(avg(total_minor)) from o where status = 'closed'), 0),
      'collected', coalesce((select sum(amount_minor) from ok), 0) - coalesce((select sum(amount_minor) from r), 0),
      'tips', coalesce((select sum(tip_minor) from ok), 0),
      'refunds', coalesce((select sum(amount_minor) from r), 0),
      'refunds_count', (select count(*) from r),
      'voided', coalesce((select sum(amount_minor) from p where status = 'voided'), 0),
      'voided_count', (select count(*) from p where status = 'voided'),
      'payments_count', (select count(*) from ok),
      'fees', coalesce((select round(sum(amount_minor * coalesce(fee_percent, 0) / 100)) from ok), 0),
      'by_method', coalesce((select jsonb_agg(jsonb_build_object('name', method_name, 'kind', method, 'total', total,
                                              'tips', tips, 'count', n) order by total desc)
          from (select method_name, method, sum(amount_minor) as total, sum(tip_minor) as tips, count(*) as n
                  from ok group by method_name, method) x), '[]'::jsonb),
      'by_hour', coalesce((select jsonb_agg(jsonb_build_object('hour', h, 'total', total) order by h)
          from (select extract(hour from local_at)::int as h, sum(amount_minor) as total from ok group by 1) x), '[]'::jsonb),
      'by_day', coalesce((select jsonb_agg(jsonb_build_object('day', d, 'total', total) order by d)
          from (select local_at::date as d, sum(amount_minor) as total from ok group by 1) x), '[]'::jsonb),
      'by_register', coalesce((select jsonb_agg(jsonb_build_object('name', name, 'total', total) order by total desc)
          from (select cr.name, sum(ok.amount_minor) as total from ok
                  join public.cash_sessions s on s.id = ok.session_id
                  join public.cash_registers cr on cr.id = s.register_id group by cr.name) x), '[]'::jsonb),
      'by_staff', coalesce((select jsonb_agg(jsonb_build_object('user_id', uid, 'orders', n, 'sales', sales, 'tips', tips)
                                             order by sales desc)
          from (select o.opened_by as uid, count(*) as n, sum(o.total_minor) as sales,
                       coalesce(sum((select sum(tip_minor) from ok where ok.order_id = o.id)), 0) as tips
                  from o where o.status = 'closed' group by o.opened_by) x), '[]'::jsonb),
      'sessions', coalesce((select jsonb_agg(jsonb_build_object('id', s.id, 'z_number', s.z_number, 'register', cr.name,
                                              'opened_at', s.opened_at, 'validated_at', s.validated_at, 'status', s.status,
                                              'expected', s.expected_cash_minor, 'counted', s.counted_cash_minor,
                                              'difference', s.difference_minor) order by s.opened_at desc)
          from public.cash_sessions s join public.cash_registers cr on cr.id = s.register_id
         where s.branch_id = p_branch and (s.opened_at at time zone v_tz)::date between p_from and p_to), '[]'::jsonb)));
end $$;

-- -----------------------------------------------------------------------------
-- Droits
-- -----------------------------------------------------------------------------
revoke all on function public.open_cash_session(uuid, bigint, uuid, jsonb), public.count_cash_session(uuid, bigint, text, jsonb),
  public.take_payment(uuid, uuid, uuid, bigint, bigint, bigint, text, uuid), public.staff_directory(uuid),
  public.cash_report(uuid, date, date) from public, anon;
grant execute on function public.open_cash_session(uuid, bigint, uuid, jsonb), public.count_cash_session(uuid, bigint, text, jsonb),
  public.take_payment(uuid, uuid, uuid, bigint, bigint, bigint, text, uuid), public.staff_directory(uuid),
  public.cash_report(uuid, date, date) to authenticated;

revoke all on all functions in schema app_private from public, anon, authenticated;
grant execute on function app_private.member_org_ids(), app_private.member_branch_ids(),
  app_private.org_ids_with(text), app_private.branch_ids_with(text),
  app_private.full_access_org_ids(), app_private.assigned_branch_ids(),
  app_private.org_ids_with_any_branch(text) to authenticated;
