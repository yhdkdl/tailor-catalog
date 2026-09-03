import { createAdminClient, createClient } from '@/lib/supabase/server';
import { MarketplaceViewClient } from '@/components/catalog/MarketplaceViewClient';
import type { CatalogCategory, CatalogDesign } from '@/components/catalog/types';

export const dynamic = 'force-dynamic';

function getMarketplaceClient() {
  return process.env.SUPABASE_SERVICE_ROLE_KEY ? createAdminClient() : createClient();
}

export default async function MarketplacePage({ searchParams }: { searchParams?: { filter?: string } }) {
  const supabase = await getMarketplaceClient();
  const { data: approvedTailors } = await supabase.from('tailors').select('id, shop_name, shop_slug').eq('status', 'approved');
  const approvedTailorIds = (approvedTailors || []).map((tailor) => tailor.id);
  const [{ data: categories }, { data: designs, error: designsError }] = await Promise.all([
    supabase.from('categories').select('id, name_en, name_am, name_om, name_so, sort_order').order('sort_order'),
    supabase.from('designs').select('id, tailor_id, category_id, price, tag, is_grouped, is_trending, created_at, updated_at, category:categories(id, name_en, name_am, name_om, name_so, sort_order), photos:design_photos(id, cloudinary_public_id, cloudinary_url, order_index)').in('tailor_id', approvedTailorIds).order('created_at', { ascending: false }).range(0, 19),
  ]);
  let marketplaceDesigns: any[] | null = designs as any[] | null;
  if (designsError) {
    const fallback = await supabase
      .from('designs')
      .select('id, tailor_id, category_id, price, tag, is_grouped, created_at, updated_at, category:categories(id, name_en, name_am, name_om, name_so, sort_order), photos:design_photos(id, cloudinary_public_id, cloudinary_url, order_index)')
      .in('tailor_id', approvedTailorIds)
      .order('created_at', { ascending: false })
      .range(0, 19);
    marketplaceDesigns = fallback.data?.map((design: any) => ({ ...design, is_trending: false })) ?? null;
  }
  const mapped = (marketplaceDesigns || []).map((d: any) => ({
    ...d,
    category: Array.isArray(d.category) ? d.category[0] : d.category,
    tailor: approvedTailors?.find((tailor) => tailor.id === d.tailor_id),
    photos: (d.photos || []).sort((a: any, b: any) => a.order_index - b.order_index),
  })) as (CatalogDesign & { tailor: { shop_name: string; shop_slug: string } })[];
  return <MarketplaceViewClient designs={mapped} categories={(categories || []) as CatalogCategory[]} initialTrending={searchParams?.filter === 'trending'} />;
}
