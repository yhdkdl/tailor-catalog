-- Migration 009: Add public read policy on tailors for customer catalog
--
-- Root cause: The customer catalog page at /[shopSlug] is a public route
-- accessed with the anon key (no auth). The existing tailors_read_own policy
-- only allows a tailor to read their own row (auth.uid() = auth_id).
-- The anon key has auth.uid() = null, so no tailors rows were visible —
-- causing the catalog page to always call notFound() even for approved tailors.
--
-- Fix: Add a policy allowing anyone (including anon) to read approved tailors.

create policy "tailors_public_read_approved"
  on tailors for select
  using (status = 'approved');
