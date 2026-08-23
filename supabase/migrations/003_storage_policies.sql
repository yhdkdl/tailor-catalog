-- Anyone can view design photos (public catalog)
create policy "design_photos_public_read"
  on storage.objects for select
  using (bucket_id = 'design-photos');

-- Only approved tailors can upload their own photos
create policy "design_photos_tailor_upload"
  on storage.objects for insert
  with check (
    bucket_id = 'design-photos'
    and auth.uid() is not null
    and exists (
      select 1 from tailors
      where auth_id = auth.uid()
      and status = 'approved'
    )
  );

-- Tailors can only delete their own photos
create policy "design_photos_tailor_delete"
  on storage.objects for delete
  using (
    bucket_id = 'design-photos'
    and auth.uid() is not null
    and (storage.foldername(name))[1] = auth.uid()::text
  );

-- QR codes: public read, tailor write own
create policy "qr_codes_public_read"
  on storage.objects for select
  using (bucket_id = 'qr-codes');

create policy "qr_codes_tailor_upload"
  on storage.objects for insert
  with check (
    bucket_id = 'qr-codes'
    and auth.uid() is not null
    and exists (
      select 1 from tailors
      where auth_id = auth.uid()
      and status = 'approved'
    )
  );