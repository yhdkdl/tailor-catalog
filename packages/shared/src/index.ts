// ─────────────────────────────────────────
// Shared types across the tailor catalog
// These match the Supabase database schema
// exactly — we define them here in Sprint 2
// ─────────────────────────────────────────

export type Language = 'en' | 'am' | 'om' | 'so';

export type TailorStatus = 'pending' | 'approved' | 'rejected';

export type Design = {
  id: string;
  tailor_id: string;
  category: string;
  price: number;
  tag: string | null;
  photos: DesignPhoto[];
  created_at: string;
};

export type DesignPhoto = {
  id: string;
  design_id: string;
  url: string;
  order: number;
};

export type Tailor = {
  id: string;
  auth_id: string;
  shop_name: string;
  shop_slug: string;
  email: string;
  status: TailorStatus;
  phone: string | null;
  created_at: string;
};

// ─────────────────────────────────────────
// Storage path helpers
// All file paths follow this convention so
// RLS delete policies work correctly
// ─────────────────────────────────────────

export const storagePaths = {
  designPhoto: (authUid: string, designId: string, filename: string) =>
    `${authUid}/${designId}/${filename}`,

  qrCode: (authUid: string, shopSlug: string) =>
    `${authUid}/${shopSlug}-qr.png`,
};

export const storageUrl = (bucket: string, path: string): string =>
  `${(globalThis as { process?: { env?: { NEXT_PUBLIC_SUPABASE_URL?: string } } }).process?.env?.NEXT_PUBLIC_SUPABASE_URL ?? ''}/storage/v1/object/public/${bucket}/${path}`;