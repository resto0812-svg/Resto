-- =============================================================================
-- Resto — 036 : une ville = une seule entrée dans la liste des villes.
-- « Douala », « DOUALA » et « Douala  » désignaient trois villes différentes
-- dans le choix de ville du client ; les filtres, eux, ignoraient déjà la
-- casse. La liste regroupe désormais sans tenir compte des majuscules ni des
-- espaces, et la ville d'un établissement est enregistrée sans espaces autour.
-- =============================================================================

-- Ville enregistrée sans espaces superflus (les filtres comparent lower(city)).
create or replace function app_private.trim_branch_city()
returns trigger language plpgsql set search_path = '' as $$
begin
  new.city := btrim(new.city);
  return new;
end $$;

drop trigger if exists branches_trim_city on public.branches;
create trigger branches_trim_city before insert or update of city on public.branches
  for each row execute function app_private.trim_branch_city();

update public.branches set city = btrim(city) where city <> btrim(city);

-- Villes des établissements publiés, regroupées sans tenir compte de la casse.
-- Nom affiché : l'orthographe la plus fréquente, de préférence pas tout en
-- majuscules (« Douala » plutôt que « DOUALA »).
create or replace function public.public_cities()
returns jsonb language sql stable security definer set search_path = '' as $$
  with spellings as (
    select lower(b.city) as k, b.city, count(*) as n
      from public.branches b
      join public.organizations o on o.id = b.organization_id and o.status = 'active'
     where b.is_published and b.status = 'active'
     group by lower(b.city), b.city
  ), cities as (
    select (array_agg(s.city order by s.n desc, (s.city = upper(s.city)), s.city))[1] as city,
           sum(s.n)::integer as n
      from spellings s
     group by s.k
  )
  select coalesce(jsonb_agg(jsonb_build_object('city', c.city, 'count', c.n) order by c.n desc, c.city), '[]'::jsonb)
    from cities c;
$$;

revoke all on function public.public_cities() from public;
grant execute on function public.public_cities() to anon, authenticated;

revoke all on all functions in schema app_private from public, anon, authenticated;
grant execute on function app_private.member_org_ids(), app_private.member_branch_ids(),
  app_private.org_ids_with(text), app_private.branch_ids_with(text),
  app_private.full_access_org_ids(), app_private.assigned_branch_ids(),
  app_private.org_ids_with_any_branch(text) to authenticated;
