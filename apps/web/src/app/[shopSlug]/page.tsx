import { notFound } from 'next/navigation';
import type { Metadata } from 'next';
import { createClient } from '@/lib/supabase/server';
import { CatalogViewClient } from '@/components/catalog/CatalogViewClient';
import { CatalogTailor, CatalogCategory, CatalogDesign } from '@/components/catalog/types';

export const dynamic = 'force-dynamic';

interface PageProps {
  params: {
    shopSlug: string;
  };
}

export async function generateMetadata({ params }: PageProps): Promise<Metadata> {
  const shopSlug = params.shopSlug;
  const supabase = await createClient();

  const { data: tailor } = await supabase
    .from('tailors')
    .select('shop_name, shop_slug, status')
    .eq('shop_slug', shopSlug)
    .maybeSingle();

  if (!tailor || tailor.status !== 'approved') {
    return {
      title: 'Shop Not Found | Ethiopian Tailor Catalog',
      description: 'The requested tailor catalog does not exist or is pending verification.',
    };
  }

  return {
    title: `${tailor.shop_name} | Ethiopian Handcrafted Fashion Catalog`,
    description: `Browse custom designs, traditional attire, and modern fashion from ${tailor.shop_name}. Try on outfits virtually.`,
  };
}

export default async function TailorCatalogPage({ params }: PageProps) {
  const shopSlug = params.shopSlug;
  const supabase = await createClient();

  // 1. Fetch tailor by slug (must be approved)
  const { data: tailorData, error: tailorError } = await supabase
    .from('tailors')
    .select('id, shop_name, shop_slug, email, phone, status')
    .eq('shop_slug', shopSlug)
    .maybeSingle();

  if (tailorError || !tailorData || tailorData.status !== 'approved') {
    notFound();
  }

  const tailor: CatalogTailor = {
    id: tailorData.id,
    shop_name: tailorData.shop_name,
    shop_slug: tailorData.shop_slug,
    email: tailorData.email,
    phone: tailorData.phone,
    status: tailorData.status as 'approved',
  };

  // 2. Fetch categories
  const { data: categoriesData } = await supabase
    .from('categories')
    .select('id, name_en, name_am, name_om, name_so, sort_order')
    .order('sort_order', { ascending: true });

  const categories: CatalogCategory[] = (categoriesData || []).map((c) => ({
    id: c.id,
    name_en: c.name_en,
    name_am: c.name_am || c.name_en,
    name_om: c.name_om || c.name_en,
    name_so: c.name_so || c.name_en,
    sort_order: c.sort_order,
  }));

  // 3. Fetch designs for this tailor
  const { data: designsData } = await supabase
    .from('designs')
    .select(`
      id,
      tailor_id,
      category_id,
      price,
      tag,
      is_grouped,
      created_at,
      updated_at,
      category:categories(id, name_en, name_am, name_om, name_so, sort_order),
      photos:design_photos(id, cloudinary_public_id, cloudinary_url, order_index)
    `)
    .eq('tailor_id', tailor.id)
    .order('created_at', { ascending: false });

  const designs: CatalogDesign[] = (designsData || []).map((d: any) => ({
    id: d.id,
    tailor_id: d.tailor_id,
    category_id: d.category_id,
    price: Number(d.price),
    tag: d.tag,
    is_grouped: d.is_grouped,
    created_at: d.created_at,
    updated_at: d.updated_at,
    category: Array.isArray(d.category) ? d.category[0] : d.category,
    photos: (d.photos || []).sort(
      (a: any, b: any) => (a.order_index ?? 0) - (b.order_index ?? 0)
    ),
  }));

  return (
    <CatalogViewClient
      tailor={tailor}
      categories={categories}
      initialDesigns={designs}
    />
  );
}
