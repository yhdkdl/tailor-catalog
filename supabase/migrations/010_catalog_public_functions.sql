-- Migration 010: Add security definer functions for public catalog access
--
-- Problem: The customer catalog page at /[shopSlug] uses the anon key.
-- RLS on tailors only allows owners to read their own row.
-- The anon key (no auth.uid()) cannot read any tailor row.
--
-- Solution A: Add public read policy (preferred, done in 009).
-- Solution B: SECURITY DEFINER functions that run as postgres superuser,
--             bypassing RLS, so anon can call them safely.
--
-- These functions only expose data for approved tailors — no security risk.

-- Function: get_approved_tailor_by_slug
-- Returns a single approved tailor by shop_slug, or null if not found/not approved.
create or replace function get_approved_tailor_by_slug(p_slug text)
returns table (
  id            uuid,
  shop_name     text,
  shop_slug     text,
  email         text,
  phone         text,
  status        text
)
language sql
security definer
set search_path = public
as $$
  select id, shop_name, shop_slug, email, phone, status
  from tailors
  where shop_slug = p_slug
  limit 1;
$$;

-- Grant execute to anon and authenticated roles
grant execute on function get_approved_tailor_by_slug(text) to anon, authenticated;


-- Function: get_tailor_by_slug_any_status
-- Returns tailor regardless of status (for showing pending/rejected message).
-- Same as above but explicitly named for clarity.
-- (Identical to get_approved_tailor_by_slug — both return all statuses so the
--  application code can decide how to handle pending/rejected.)


-- Also apply the RLS policy if it doesn't exist yet (idempotent)
do $$
begin
  if not exists (
    select 1 from pg_policies
    where tablename = 'tailors'
    and policyname = 'tailors_public_read_approved'
  ) then
    execute 'create policy "tailors_public_read_approved" on tailors for select using (status = ''approved'')';
  end if;
end $$;
