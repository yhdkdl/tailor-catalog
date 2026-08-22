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
  shop_name: string;
  shop_slug: string;
  status: TailorStatus;
  phone: string | null;
  created_at: string;
};