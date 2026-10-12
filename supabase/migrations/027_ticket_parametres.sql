-- =============================================================================
-- Resto — 027 : textes du ticket de caisse réglables par établissement
-- (nom affiché, sous-titre, slogan, site web, bloc fidélité, formule d'au revoir).
-- À coller APRÈS 026.
-- =============================================================================

alter table public.branches
  add column if not exists receipt_title text check (length(receipt_title) <= 80),
  add column if not exists receipt_subtitle text check (length(receipt_subtitle) <= 80),
  add column if not exists receipt_slogan text check (length(receipt_slogan) <= 160),
  add column if not exists website text check (website is null or (length(website) <= 200 and website !~ '\s')),
  add column if not exists receipt_qr_title text check (length(receipt_qr_title) <= 80),
  add column if not exists receipt_qr_caption text check (length(receipt_qr_caption) <= 200),
  add column if not exists receipt_farewell text check (length(receipt_farewell) <= 160);

grant insert (receipt_title, receipt_subtitle, receipt_slogan, website, receipt_qr_title, receipt_qr_caption, receipt_farewell),
  update (receipt_title, receipt_subtitle, receipt_slogan, website, receipt_qr_title, receipt_qr_caption, receipt_farewell)
  on public.branches to authenticated;

revoke all on all functions in schema app_private from public, anon, authenticated;
grant execute on function app_private.member_org_ids(), app_private.member_branch_ids(),
  app_private.org_ids_with(text), app_private.branch_ids_with(text),
  app_private.full_access_org_ids(), app_private.assigned_branch_ids(),
  app_private.org_ids_with_any_branch(text) to authenticated;
