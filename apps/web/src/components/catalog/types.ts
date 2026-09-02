export interface CatalogTailor {
  id: string;
  shop_name: string;
  shop_slug: string;
  email?: string;
  phone?: string | null;
  status: 'pending' | 'approved' | 'rejected';
}

export interface CatalogCategory {
  id: string;
  name_en: string;
  name_am: string;
  name_om: string;
  name_so: string;
  sort_order: number;
}

export interface CatalogDesignPhoto {
  id: string;
  cloudinary_public_id: string | null;
  cloudinary_url: string | null;
  order_index: number;
}

export interface CatalogDesign {
  id: string;
  tailor_id: string;
  category_id: string;
  price: number;
  tag: string | null;
  is_grouped: boolean;
  created_at: string;
  updated_at: string;
  category?: CatalogCategory | null;
  photos: CatalogDesignPhoto[];
}
