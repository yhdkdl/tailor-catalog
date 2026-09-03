import { createClient } from '@/lib/supabase/server';
import { MarketplaceViewClient } from '@/components/catalog/MarketplaceViewClient';
import type { CatalogCategory, CatalogDesign } from '@/components/catalog/types';

export const dynamic = 'force-dynamic';

export default async function MarketplacePage({ searchParams }: { searchParams?: { filter?: string } }) {
  const supabase = await createClient();
  const [{ data: categories }, { data: designs }] = await Promise.all([
    supabase.from('categories').select('id, name_en, name_am, name_om, name_so, sort_order').order('sort_order'),
    supabase.from('designs').select('id, tailor_id, category_id, price, tag, is_grouped, is_trending, created_at, updated_at, category:categories(id, name_en, name_am, name_om, name_so, sort_order), photos:design_photos(id, cloudinary_public_id, cloudinary_url, order_index), tailor:tailors!inner(id, shop_name, shop_slug, status)').eq('tailor.status', 'approved').order('created_at', { ascending: false }).range(0, 19),
  ]);
  const mapped = (designs || []).map((d: any) => ({
    ...d,
    category: Array.isArray(d.category) ? d.category[0] : d.category,
    tailor: Array.isArray(d.tailor) ? d.tailor[0] : d.tailor,
    photos: (d.photos || []).sort((a: any, b: any) => a.order_index - b.order_index),
  })) as (CatalogDesign & { tailor: { shop_name: string; shop_slug: string } })[];
  return <MarketplaceViewClient designs={mapped} categories={(categories || []) as CatalogCategory[]} initialTrending={searchParams?.filter === 'trending'} />;
}
