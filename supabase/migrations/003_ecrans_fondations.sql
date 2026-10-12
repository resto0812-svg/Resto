-- =============================================================================
-- Resto — 003_ecrans_fondations
-- Fonctions utilisées par les premiers écrans : fuseaux horaires IANA,
-- horaires d'ouverture enregistrés d'un bloc, journal d'audit lisible.
-- À coller dans le SQL Editor APRÈS 002.
-- =============================================================================

-- Fuseaux IANA « Région/Ville » connus du serveur (liste maintenue par
-- PostgreSQL, sans les alias posix/ ni Etc/).
create or replace function public.list_timezones()
returns setof text language sql stable security definer set search_path = '' as $$
  select name from pg_catalog.pg_timezone_names
   where name ~ '^(Africa|America|Antarctica|Asia|Atlantic|Australia|Europe|Indian|Pacific)/'
   order by name
$$;

-- Remplace toute la semaine d'horaires d'un établissement, en une transaction.
-- p_hours : [{"weekday":1,"opens_at":"08:00","closes_at":"22:30"}, …]
create or replace function public.set_opening_hours(p_branch uuid, p_hours jsonb)
returns void language plpgsql security definer set search_path = '' as $$
declare
  v_org uuid;
  v_bad boolean;
begin
  select organization_id into v_org from public.branches where id = p_branch;
  if v_org is null or not exists (
    select 1 from app_private.branch_ids_with('branches.manage') x where x = p_branch) then
    raise exception 'resto.forbidden' using errcode = '42501';
  end if;
  -- Tableau attendu, 28 plages au plus (4 par jour).
  v_bad := jsonb_typeof(coalesce(p_hours, '[]'::jsonb)) <> 'array';
  if not v_bad then
    v_bad := jsonb_array_length(coalesce(p_hours, '[]'::jsonb)) > 28;
  end if;
  if v_bad then
    perform app_private.fail('resto.invalid_hours');
  end if;

  delete from public.branch_opening_hours where branch_id = p_branch;
  insert into public.branch_opening_hours (organization_id, branch_id, weekday, opens_at, closes_at)
  select v_org, p_branch, (h ->> 'weekday')::smallint, (h ->> 'opens_at')::time, (h ->> 'closes_at')::time
    from jsonb_array_elements(coalesce(p_hours, '[]'::jsonb)) h;
exception
  when invalid_text_representation or invalid_datetime_format or check_violation
       or not_null_violation or unique_violation or datetime_field_overflow then
    perform app_private.fail('resto.invalid_hours');
end $$;

-- Journal d'audit avec le nom de l'auteur (réservé à audit.read), page par page.
create or replace function public.audit_entries(p_org uuid, p_before bigint default null, p_limit int default 50)
returns table (id bigint, created_at timestamptz, actor_name text, action text, entity text,
               entity_id uuid, details jsonb)
language plpgsql stable security definer set search_path = '' as $$
begin
  if not app_private.has_org_perm(p_org, 'audit.read') then
    raise exception 'resto.forbidden' using errcode = '42501';
  end if;
  return query
  select a.id, a.created_at,
         coalesce(nullif(p.display_name, ''), u.email::text, ''), a.action, a.entity, a.entity_id, a.details
    from public.audit_log a
    left join public.profiles p on p.id = a.actor_id
    left join auth.users u on u.id = a.actor_id
   where a.organization_id = p_org and (p_before is null or a.id < p_before)
   order by a.id desc
   limit least(greatest(coalesce(p_limit, 50), 1), 200);
end $$;

revoke all on function public.list_timezones(), public.set_opening_hours(uuid, jsonb),
  public.audit_entries(uuid, bigint, int) from public, anon;
grant execute on function public.list_timezones() to anon, authenticated;
grant execute on function public.set_opening_hours(uuid, jsonb), public.audit_entries(uuid, bigint, int)
  to authenticated;
