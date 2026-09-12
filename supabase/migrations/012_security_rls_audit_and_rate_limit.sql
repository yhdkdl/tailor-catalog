-- Migration 012: Security + RLS Audit and Image Upload Rate Limiting
-- Phase 5 Sprint 18

-- 1. Ensure design_photos has update policy for photo reordering by owner tailor
do $$
begin
  if not exists (
    select 1 from pg_policies
    where tablename = 'design_photos'
    and policyname = 'photos_update_own'
  ) then
    create policy "photos_update_own"
      on design_photos for update
      using (
        auth.uid() = (
          select t.auth_id from tailors t
          join designs d on d.tailor_id = t.id
          where d.id = design_photos.design_id
        )
      );
  end if;
end $$;

-- 2. Ensure admin can delete any photo directly
do $$
begin
  if not exists (
    select 1 from pg_policies
    where tablename = 'design_photos'
    and policyname = 'admin_delete_any_photo'
  ) then
    create policy "admin_delete_any_photo"
      on design_photos for delete
      using (is_admin());
  end if;
end $$;

-- 3. Verify and reinforce that pending tailor designs are not visible to public or other tailors
-- The existing policy designs_public_read requires tailors.status = 'approved'.
-- designs_read_own requires auth.uid() = tailors.auth_id.
-- This ensures:
--   a) No tailor can read another tailor's pending/unpublished designs.
--   b) Pending tailor designs are never visible on the public catalog.

-- 4. Rate Limiting: Prevent abuse by limiting design inserts per tailor
create or replace function check_design_upload_rate_limit()
returns trigger as $$
declare
  recent_count integer;
begin
  select count(*)
  into recent_count
  from designs
  where tailor_id = new.tailor_id
    and created_at > (now() - interval '1 minute');

  if recent_count >= 30 then
    raise exception 'Upload rate limit exceeded: Maximum 30 designs per minute. Please wait before uploading again.';
  end if;

  return new;
end;
$$ language plpgsql security definer;

drop trigger if exists trg_design_upload_rate_limit on designs;
create trigger trg_design_upload_rate_limit
  before insert on designs
  for each row
  execute function check_design_upload_rate_limit();

-- 5. Rate Limiting: Prevent abuse by limiting photo inserts per tailor
create or replace function check_photo_upload_rate_limit()
returns trigger as $$
declare
  t_id uuid;
  recent_count integer;
begin
  select tailor_id into t_id from designs where id = new.design_id;

  if t_id is not null then
    select count(*)
    into recent_count
    from design_photos dp
    join designs d on d.id = dp.design_id
    where d.tailor_id = t_id
      and dp.created_at > (now() - interval '1 minute');

    if recent_count >= 60 then
      raise exception 'Upload rate limit exceeded: Maximum 60 photos per minute. Please wait before uploading again.';
    end if;
  end if;

  return new;
end;
$$ language plpgsql security definer;

drop trigger if exists trg_photo_upload_rate_limit on design_photos;
create trigger trg_photo_upload_rate_limit
  before insert on design_photos
  for each row
  execute function check_photo_upload_rate_limit();
