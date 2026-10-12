-- =============================================================================
-- Resto — 024_correctif_limites_favoris
-- Correctif de 023 : la fonction de limite commune aux trois tables citait
-- new.list_id dans une condition préparée en entier par PL/pgSQL, ce qui
-- échouait pour les favoris (pas de colonne list_id). Une fonction par table.
-- À coller APRÈS 023, puis supabase/tests/023_fidelisation_tests.sql.
-- =============================================================================

-- 500 plats favoris par client.
create or replace function app_private.limit_customer_favorites()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  if (select count(*) from public.customer_item_favorites where user_id = new.user_id) >= 500 then
    perform app_private.fail('resto.limit_reached');
  end if;
  return new;
end $$;

-- 20 listes par client.
create or replace function app_private.limit_customer_lists()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  if (select count(*) from public.customer_lists where user_id = new.user_id) >= 20 then
    perform app_private.fail('resto.limit_reached');
  end if;
  return new;
end $$;

-- 200 plats par liste.
create or replace function app_private.limit_customer_list_items()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  if (select count(*) from public.customer_list_items where list_id = new.list_id) >= 200 then
    perform app_private.fail('resto.limit_reached');
  end if;
  return new;
end $$;

drop trigger if exists customer_item_favorites_limit on public.customer_item_favorites;
drop trigger if exists customer_lists_limit on public.customer_lists;
drop trigger if exists customer_list_items_limit on public.customer_list_items;
create trigger customer_item_favorites_limit before insert on public.customer_item_favorites
  for each row execute function app_private.limit_customer_favorites();
create trigger customer_lists_limit before insert on public.customer_lists
  for each row execute function app_private.limit_customer_lists();
create trigger customer_list_items_limit before insert on public.customer_list_items
  for each row execute function app_private.limit_customer_list_items();

drop function if exists app_private.limit_customer_saves();

revoke all on all functions in schema app_private from public, anon, authenticated;
grant execute on function app_private.member_org_ids(), app_private.member_branch_ids(),
  app_private.org_ids_with(text), app_private.branch_ids_with(text),
  app_private.full_access_org_ids(), app_private.assigned_branch_ids(),
  app_private.org_ids_with_any_branch(text) to authenticated;
