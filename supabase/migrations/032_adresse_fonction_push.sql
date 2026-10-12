-- =============================================================================
-- Resto — 032 : adresse réelle de la fonction d'envoi des notifications push
-- (déployée sous le nom « send-push- » dans le tableau de bord Supabase).
-- À coller APRÈS 031.
-- =============================================================================

update app_private.push_settings
   set function_url = 'https://xpthqtcjqkpticezglbv.supabase.co/functions/v1/send-push-';

revoke all on all functions in schema app_private from public, anon, authenticated;
grant execute on function app_private.member_org_ids(), app_private.member_branch_ids(),
  app_private.org_ids_with(text), app_private.branch_ids_with(text),
  app_private.full_access_org_ids(), app_private.assigned_branch_ids(),
  app_private.org_ids_with_any_branch(text) to authenticated;
