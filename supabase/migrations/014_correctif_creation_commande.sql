-- =============================================================================
-- Resto — 014_correctif_creation_commande
-- create_order (013) reconnaissait une commande déjà existante en comparant
-- son heure d'ouverture à now() ; dans une même transaction now() ne change
-- pas, et un appel rejoué pouvait écraser les informations de la commande.
-- Désormais : commande déjà enregistrée (même identifiant) ou table déjà
-- occupée (vérifiée sous le même verrou que l'ouverture) → renvoyée telle
-- quelle, avant toute création.
-- À coller APRÈS 013, puis relancer supabase/tests/013_service_tests.sql.
-- =============================================================================

create or replace function public.create_order(
  p_branch uuid, p_channel text, p_table uuid default null, p_guests smallint default null,
  p_source text default 'staff', p_customer_name text default null, p_contact_phone text default null,
  p_delivery_address text default null, p_delivery_instructions text default null,
  p_scheduled_for timestamptz default null, p_note text default null, p_client_id uuid default null)
returns uuid language plpgsql security definer set search_path = '' as $$
declare
  v_id uuid;
  v_fee bigint;
begin
  perform app_private.assert_branch_perm(p_branch, 'orders.write');
  -- Appel rejoué : la commande existe déjà, rien n'est modifié.
  if p_client_id is not null then
    select id into v_id from public.orders where id = p_client_id and branch_id = p_branch;
    if v_id is not null then return v_id; end if;
  end if;
  if coalesce(p_source, '') not in ('staff', 'phone') then perform app_private.fail('resto.invalid_order'); end if;
  if p_channel = 'delivery' and length(btrim(coalesce(p_delivery_address, ''))) < 3 then
    perform app_private.fail('resto.address_required');
  end if;
  if p_scheduled_for is not null and (p_scheduled_for < now() - interval '1 hour' or p_scheduled_for > now() + interval '30 days') then
    perform app_private.fail('resto.invalid_order');
  end if;
  -- Table déjà occupée : on renvoie sa commande en cours, sans la modifier.
  -- Même verrou que open_order (verrou réentrant dans la transaction).
  if p_table is not null then
    perform pg_advisory_xact_lock(hashtext('resto.table.' || p_table::text));
    select id into v_id from public.orders where table_id = p_table and status = 'open';
    if v_id is not null then return v_id; end if;
  end if;

  v_id := public.open_order(p_branch, p_channel, p_table, p_guests, p_note, p_client_id);
  select delivery_fee_minor into v_fee from public.branches where id = p_branch;
  update public.orders
     set source = p_source,
         customer_name = nullif(btrim(p_customer_name), ''),
         contact_phone = nullif(btrim(p_contact_phone), ''),
         delivery_address = nullif(btrim(p_delivery_address), ''),
         delivery_instructions = nullif(btrim(p_delivery_instructions), ''),
         scheduled_for = p_scheduled_for,
         delivery_fee_minor = case when p_channel = 'delivery' then v_fee else 0 end
   where id = v_id;
  perform app_private.recompute_order(v_id);
  return v_id;
end $$;

revoke all on function public.create_order(uuid, text, uuid, smallint, text, text, text, text, text, timestamptz, text, uuid)
  from public, anon;
grant execute on function public.create_order(uuid, text, uuid, smallint, text, text, text, text, text, timestamptz, text, uuid)
  to authenticated;

revoke all on all functions in schema app_private from public, anon, authenticated;
grant execute on function app_private.member_org_ids(), app_private.member_branch_ids(),
  app_private.org_ids_with(text), app_private.branch_ids_with(text),
  app_private.full_access_org_ids(), app_private.assigned_branch_ids(),
  app_private.org_ids_with_any_branch(text) to authenticated;
