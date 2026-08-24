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
  cloudinary_public_id: string;
  cloudinary_url: string;
  order_index: number;
  created_at: string;
};

// Cloudinary URL builder
// Use this everywhere instead of raw URLs
// It generates optimized URLs on the fly
export const cloudinaryUrl = (
  publicId: string,
  options: {
    width?: number;
    height?: number;
    quality?: 'auto' | number;
    format?: 'auto' | 'webp' | 'jpg';
  } = {}
): string => {
  const { width, height, quality = 'auto', format = 'auto' } = options;
  const transforms = [
    `q_${quality}`,
    `f_${format}`,
    width ? `w_${width}` : '',
    height ? `h_${height}` : '',
    'c_limit',
  ]
    .filter(Boolean)
    .join(',');

  return `https://res.cloudinary.com/${process.env.NEXT_PUBLIC_CLOUDINARY_CLOUD_NAME}/image/upload/${transforms}/${publicId}`;
};

// Preset sizes used across the app
export const cloudinaryPresets = {
  thumbnail: (id: string) => cloudinaryUrl(id, { width: 400, height: 400, quality: 'auto', format: 'auto' }),
  catalog: (id: string) => cloudinaryUrl(id, { width: 800, quality: 'auto', format: 'auto' }),
  full: (id: string) => cloudinaryUrl(id, { quality: 'auto', format: 'auto' }),
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
  // Design photos now go to Cloudinary — not Supabase Storage
  // Cloudinary public ID format: tailor-designs/{authUid}/{designId}/{filename}
  cloudinaryFolder: (authUid: string, designId: string) =>
    `tailor-designs/${authUid}/${designId}`,

  // QR codes stay in Supabase Storage — they are tiny
  qrCode: (authUid: string, shopSlug: string) =>
    `${authUid}/${shopSlug}-qr.png`,
};

export const storageUrl = (bucket: string, path: string): string =>
  `${(globalThis as { process?: { env?: { NEXT_PUBLIC_SUPABASE_URL?: string } } }).process?.env?.NEXT_PUBLIC_SUPABASE_URL ?? ''}/storage/v1/object/public/${bucket}/${path}`;