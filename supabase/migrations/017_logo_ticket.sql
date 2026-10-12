-- =============================================================================
-- Resto — 017_logo_ticket
-- Logo du restaurant (par marque) : fichier dans le bucket public
-- « brand-logos », rangé sous le dossier de l'organisation ; seul un
-- responsable (org.manage) l'envoie, le remplace ou le retire.
-- QR code du ticket (par établissement) : affiché ou non, lien libre
-- (site, avis en ligne…) ou, à défaut, la page du restaurant sur Resto.
-- À coller APRÈS 016, puis supabase/tests/017_logo_ticket_tests.sql.
-- =============================================================================

alter table public.brands
  add column if not exists logo_path text;
alter table public.brands drop constraint if exists brands_logo_path_check;
alter table public.brands add constraint brands_logo_path_check
  check (logo_path is null or (length(logo_path) <= 300 and logo_path like organization_id::text || '/%'));
grant update (logo_path) on public.brands to authenticated;

alter table public.branches
  add column if not exists receipt_qr boolean not null default true,
  add column if not exists receipt_qr_url text check (receipt_qr_url is null
    or (length(receipt_qr_url) <= 300 and receipt_qr_url ~ '^https?://\S+$'));
grant insert (receipt_qr, receipt_qr_url), update (receipt_qr, receipt_qr_url) on public.branches to authenticated;

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('brand-logos', 'brand-logos', true, 1048576, array['image/png', 'image/jpeg', 'image/webp'])
on conflict (id) do update set public = true, file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists resto_brand_logos_read on storage.objects;
drop policy if exists resto_brand_logos_insert on storage.objects;
drop policy if exists resto_brand_logos_update on storage.objects;
drop policy if exists resto_brand_logos_delete on storage.objects;
-- Lecture par les membres (impression du ticket par le caissier) ; le public
-- passe par l'adresse publique du bucket.
create policy resto_brand_logos_read on storage.objects for select to authenticated
  using (bucket_id = 'brand-logos'
    and (storage.foldername(name))[1] in (select x::text from app_private.member_org_ids() x));
create policy resto_brand_logos_insert on storage.objects for insert to authenticated
  with check (bucket_id = 'brand-logos'
    and (storage.foldername(name))[1] in (select x::text from app_private.org_ids_with('org.manage') x));
create policy resto_brand_logos_update on storage.objects for update to authenticated
  using (bucket_id = 'brand-logos'
    and (storage.foldername(name))[1] in (select x::text from app_private.org_ids_with('org.manage') x))
  with check (bucket_id = 'brand-logos'
    and (storage.foldername(name))[1] in (select x::text from app_private.org_ids_with('org.manage') x));
create policy resto_brand_logos_delete on storage.objects for delete to authenticated
  using (bucket_id = 'brand-logos'
    and (storage.foldername(name))[1] in (select x::text from app_private.org_ids_with('org.manage') x));

revoke all on all functions in schema app_private from public, anon, authenticated;
grant execute on function app_private.member_org_ids(), app_private.member_branch_ids(),
  app_private.org_ids_with(text), app_private.branch_ids_with(text),
  app_private.full_access_org_ids(), app_private.assigned_branch_ids(),
  app_private.org_ids_with_any_branch(text) to authenticated;
