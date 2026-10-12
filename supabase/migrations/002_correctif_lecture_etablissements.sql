-- =============================================================================
-- Resto — 002_correctif_lecture_etablissements
-- À coller dans le SQL Editor APRÈS 001 (et avant les tests).
--
-- Problème : la politique de lecture de public.branches utilisait
-- app_private.member_branch_ids(), qui lit elle-même la table branches. Lors
-- d'un « insert … returning » (ce que fait l'application avec insert().select()),
-- la nouvelle ligne doit passer la politique de lecture, mais elle n'est pas
-- encore visible pour cette fonction (instantané du début de la requête) :
--   ERROR 42501 new row violates row-level security policy for table "branches"
--
-- Correctif : la lecture d'un établissement ne dépend plus de la table
-- branches, seulement des adhésions (accès à toute l'organisation ou
-- établissements attribués). Les droits accordés restent identiques.
-- =============================================================================

-- Organisations dont je vois TOUS les établissements (adhésion all_branches).
create or replace function app_private.full_access_org_ids()
returns setof uuid language sql stable security definer set search_path = '' as $$
  select m.organization_id
    from public.memberships m
    join public.organizations o on o.id = m.organization_id and o.status <> 'closed'
   where m.user_id = auth.uid() and m.status = 'active' and m.all_branches
$$;

-- Établissements qui me sont attribués nommément (adhésion limitée).
create or replace function app_private.assigned_branch_ids()
returns setof uuid language sql stable security definer set search_path = '' as $$
  select mb.branch_id
    from public.memberships m
    join public.organizations o on o.id = m.organization_id and o.status <> 'closed'
    join public.membership_branches mb on mb.membership_id = m.id
   where m.user_id = auth.uid() and m.status = 'active' and not m.all_branches
$$;

revoke all on function app_private.full_access_org_ids(), app_private.assigned_branch_ids()
  from public, anon, authenticated;
grant execute on function app_private.full_access_org_ids(), app_private.assigned_branch_ids()
  to authenticated;

drop policy if exists branches_read on public.branches;
create policy branches_read on public.branches for select to authenticated
  using (organization_id in (select app_private.full_access_org_ids())
         or id in (select app_private.assigned_branch_ids()));
