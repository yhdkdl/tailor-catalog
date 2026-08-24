-- Add cloudinary fields to design_photos
-- We keep storage_path for QR codes (still in Supabase)
-- but add cloudinary_public_id for design photos

alter table design_photos 
  add column cloudinary_public_id text,
  add column cloudinary_url text;

-- Make storage_path optional now
alter table design_photos 
  alter column storage_path drop not null;