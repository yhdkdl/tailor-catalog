-- Remove upload policy for design photos
-- (we keep read policy in case of old data)
drop policy if exists "design_photos_tailor_upload" on storage.objects;
drop policy if exists "design_photos_tailor_delete" on storage.objects;