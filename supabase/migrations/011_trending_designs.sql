-- Migration 011: Add is_trending column to designs table
-- Allows admins to mark designs as trending for special visibility
-- in tailor catalogs, marketplace, and landing page.

alter table designs add column if not exists is_trending boolean not null default false;

create index if not exists idx_designs_is_trending on designs(is_trending);
