
## Key Decisions Already Made
1. Auth: Email OTP (no password) for tailors. Email+password for admin.
   - Will migrate to Africa's Talking SMS OTP after MVP
2. Bulk upload: each photo = its own design card by default
   OR tailor groups multiple photos into one multi-photo design (carousel)
3. Design fields: category + price + optional tag (no name, no description)
4. Language: customer picks on first visit, stored in localStorage
   - English (en), Amharic (am), Oromifa (om), Somali (so)
5. Tailor approval: admin manually approves each tailor
6. Storage paths: {authUid}/{designId}/{filename} for design photos
7. Hosting: Vercel (web) + Supabase (backend). No Railway needed.

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

## Sprint Plan Overview
### Phase 1 — Foundation (COMPLETE ✓)
- Sprint 1: Monorepo + Git setup ✓
- Sprint 2: Database schema + RLS ✓
- Sprint 3: Auth + Storage config ✓
- Sprint 3.5: Email OTP adjustment + email column added to tailors ✓

### Phase 2 — Admin Panel (Next.js) (COMPLETE ✓)
- Sprint 4: Next.js bootstrap + admin login page ✓
- Sprint 5: Admin tailor management (approve/reject) ✓
- Sprint 6: Admin content moderation ✓

### Phase 3 — Flutter Tailor App
- Sprint 7: Flutter bootstrap ✓
- Sprint 8: Tailor auth + profile (email OTP login)
- Sprint 9: Single design upload
- Sprint 10: Bulk upload + multi-photo designs
- Sprint 11: Offline support (Drift/SQLite)
- Sprint 12: QR code generation

### Phase 4 — Customer Web Catalog
- Sprint 13: i18n foundation (next-intl, all 4 languages)
- Sprint 14: Public catalog page /[shopSlug]
- Sprint 15: Design detail + multi-photo carousel
- Sprint 16: Try-on camera overlay feature

### Phase 5 — Production Hardening
- Sprint 17: Image optimization
- Sprint 18: Security + RLS audit
- Sprint 19: Error handling + loading states
- Sprint 20: Sentry monitoring
- Sprint 21: CI/CD pipeline
- Sprint 22: End-to-end launch test

## Agent Rules (follow these strictly)
1. Work one sprint at a time — never start the next sprint until told
2. Create a feature branch before writing any code
3. Never rewrite code from previous sprints unless a bug requires it
4. If modifying existing files show only the changed lines with context
5. Always run npm install or flutter pub get after adding dependencies
6. Always push the feature branch to GitHub after completing a sprint
7. Merge into develop only — never into main
8. If uncertain about a decision ask before proceeding
9. Design photos go to Cloudinary — never Supabase Storage
   Store only cloudinary_public_id in the database
   Build all image URLs using cloudinaryPresets from shared package
   QR codes still go to Supabase Storage bucket: qr-codes
10. All UI text must use i18n keys — never hardcode English strings in Phase 4+

## Phase Completion Checklists (agent must verify all before marking done)

### Phase 2 Checklist
- [x] Next.js app runs on localhost:3000
- [x] /admin route redirects to login if not authenticated
- [x] Admin can log in with email+password
- [x] Admin dashboard shows list of pending tailors
- [x] Admin can approve a tailor (status changes to approved)
- [x] Admin can reject a tailor (status changes to rejected)
- [x] Admin can create tailor accounts directly from panel
- [x] Admin can fully delete a tailor (auth + profile + designs + photos)
- [x] Admin can view all designs across all tailors
- [x] Admin can delete any design
- [x] Admin can deactivate a tailor account
- [x] Deployed and accessible on Vercel preview URL (ready for production deploy)

### Phase 3 Checklist
- [ ] Flutter app builds and runs on Android emulator or real device
- [ ] Tailor can enter email and receive OTP
- [ ] Tailor can enter OTP and log in successfully
- [ ] Pending tailors see a waiting for approval screen
- [ ] Approved tailors reach the main dashboard
- [ ] Tailor can upload a single design photo with category + price + optional tag
- [ ] Design appears in Supabase database after upload
- [ ] Tailor can select multiple photos and upload as individual designs
- [ ] Tailor can group multiple photos into one multi-photo design
- [ ] Upload queue works when offline — syncs when back online
- [ ] Tailor can view their full catalog in the app
- [ ] Tailor can delete their own design
- [ ] Approved tailor sees their QR code
- [ ] QR code links to correct /[shopSlug] URL
- [ ] Session persists across app restarts

### Phase 4 Checklist
- [ ] /[shopSlug] loads correctly in browser
- [ ] Language picker appears on first visit
- [ ] All 4 languages switch correctly (EN, AM, OM, SO)
- [ ] Language preference persists across page refreshes
- [ ] Design grid shows all approved tailor designs
- [ ] Category filter works correctly
- [ ] Tapping a design opens the detail sheet
- [ ] Multi-photo designs show swipeable carousel
- [ ] Price, category, tag displayed correctly
- [ ] Try-on opens camera and overlays design photo
- [ ] Overlay is draggable in all directions
- [ ] Pinch to resize works on mobile
- [ ] Opacity slider works
- [ ] Page loads fast on slow mobile connection
- [ ] 404 page shown for unknown shopSlug

### Phase 5 Checklist
- [ ] All images load as WebP thumbnails
- [ ] Lazy loading works on catalog page
- [ ] No tailor can read another tailor's unpublished designs
- [ ] Pending tailor designs not visible on public catalog
- [ ] Rate limiting on image uploads
- [ ] Skeleton loaders on all async content
- [ ] Graceful error shown when Supabase is unreachable
- [ ] Sentry captures errors in both Next.js and Flutter
- [ ] GitHub Actions runs lint on every PR
- [ ] Auto deploy to Vercel on merge to develop
- [ ] Full end-to-end flow works without any manual intervention
- [ ] App works correctly in all 4 languages end to end

## Current State (update this after every sprint)
- Phase 1: COMPLETE
- Phase 2: COMPLETE
- Phase 3: IN PROGRESS (Sprints 7-8 complete; Sprint 8 needs human Supabase/device verification)
- Phase 4: NOT STARTED
- Phase 5: NOT STARTED