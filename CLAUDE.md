# CLAUDE.md - Tailor Catalog Development Guide

## Key Decisions Already Made
1. Auth: Email + password for tailors. Admin sets initial password on account creation.
   Email+password for admin.
2. Bulk upload: each photo = its own design card by default
   OR tailor groups multiple photos into one multi-photo design (carousel)
3. Design fields: category + price + optional tag (no name, no description)
4. Language: customer picks on first visit, stored in localStorage
   - English (en), Amharic (am), Oromifa (om), Somali (so)
5. Tailor approval: admin manually approves each tailor
6. Storage paths: {authUid}/{designId}/{filename} for design photos
7. Hosting: Vercel (web) + Supabase (backend). No Railway needed.

## Auth flow for tailors
- Email + password (no OTP)
- Admin creates tailor account with initial password
- Admin shares credentials manually with tailor
- `email_confirm: true` set on creation so no email verification needed
- Session persists across app restarts
- Pending tailors see waiting screen
- Approved tailors reach main dashboard
- Rejected tailors see rejection screen

## Database Tables (all created in Supabase)
- tailors (id, auth_id, shop_name, shop_slug, email, status, phone, created_at, updated_at)
- categories (id, name_en, name_am, name_om, name_so, sort_order)
- designs (id, tailor_id, category_id, price, tag, is_grouped, created_at, updated_at)
- design_photos (id, design_id, storage_path, order_index, created_at)
- admin_users (id, auth_id, created_at)

## Categories Already Seeded (6 rows, all 4 languages)
Women's Dress, Men's Suit, Traditional Attire, Children's Wear, Casual, Formal

## Storage Architecture
### Cloudinary (design photos)
- All design photos uploaded directly from Flutter to Cloudinary
- Upload preset: tailor-designs (unsigned, allows direct upload)
- Folder structure: tailor-designs/{authUid}/{designId}/
- Public IDs stored in design_photos.cloudinary_public_id
- Use cloudinaryPresets helpers from @tailor-catalog/shared for all URLs
- Never store full URLs — always store public_id and build URL at runtime

### Supabase Storage (QR codes only)
- Bucket: qr-codes (public)
- Path: {authUid}/{shopSlug}-qr.png
- QR codes are tiny — Supabase 1GB is more than enough

## Cloudinary Environment Variables
NEXT_PUBLIC_CLOUDINARY_CLOUD_NAME (used in web + referenced in mobile)
CLOUDINARY_API_KEY (server side only)
CLOUDINARY_API_SECRET (server side only — never expose)
NEXT_PUBLIC_CLOUDINARY_UPLOAD_PRESET=tailor-designs

## Branch Strategy (NEVER break these rules)
- main = production only, never commit directly
- develop = integration branch, all features merge here
- feature/sprint-X-description = one branch per sprint
- Always create feature branch from develop
- Always merge feature branch back into develop
- Never commit directly to main or develop

## Commit Convention
- feat: new feature
- fix: bug fix
- chore: config or setup
- docs: documentation only
- test: tests only

## Environment Variables
### apps/web needs:
NEXT_PUBLIC_SUPABASE_URL=
NEXT_PUBLIC_SUPABASE_ANON_KEY=
SUPABASE_SERVICE_ROLE_KEY= (server side admin only, never expose to client)
NEXT_PUBLIC_APP_URL=

### apps/mobile needs (Flutter):
SUPABASE_URL=
SUPABASE_ANON_KEY=
