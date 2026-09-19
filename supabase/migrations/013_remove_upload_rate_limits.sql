-- Migration 013: Remove restrictive upload rate limits
-- Tailors need to be able to bulk upload catalogs with dozens of designs/photos without artificial throttling.

-- 1. Drop trigger on designs
drop trigger if exists trg_design_upload_rate_limit on designs;
drop function if exists check_design_upload_rate_limit();

-- 2. Drop trigger on design_photos
drop trigger if exists trg_photo_upload_rate_limit on design_photos;
drop function if exists check_photo_upload_rate_limit();
