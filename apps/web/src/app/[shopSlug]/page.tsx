import { notFound } from 'next/navigation';
import type { Metadata } from 'next';
import { createAdminClient, createClient } from '@/lib/supabase/server';
import { CatalogViewClient } from '@/components/catalog/CatalogViewClient';
import { CatalogTailor, CatalogCategory, CatalogDesign } from '@/components/catalog/types';
import { Store, Clock } from 'lucide-react';

export const dynamic = 'force-dynamic';

interface PageProps {
  params: {
    shopSlug: string;
  };
  searchParams?: { design?: string };
}

/**
 * Returns a Supabase client for catalog reads.
 * Prefers service role (bypasses RLS) if the key is configured.
 * Falls back to anon key — works once RLS policy 009/010 is applied.
 */
function getCatalogClient() {
  const svcKey = process.env.SUPABASE_SERVICE_ROLE_KEY;
  if (svcKey && svcKey.length > 20) {
    return createAdminClient();
  }
  // Anon client — requires "tailors_public_read_approved" RLS policy on tailors
  return createClient();
}

export async function generateMetadata({ params }: PageProps): Promise<Metadata> {
  const shopSlug = params.shopSlug;
  const supabase = await getCatalogClient();

  const { data: tailor } = await supabase
    .from('tailors')
    .select('shop_name, shop_slug, status')
    .eq('shop_slug', shopSlug)
    .maybeSingle();

  if (!tailor) {
    return {
      title: 'Shop Not Found | Ethiopian Tailor Catalog',
      description: 'The requested tailor catalog does not exist.',
    };
  }

  if (tailor.status !== 'approved') {
    return {
      title: `${tailor.shop_name} — Pending Verification | Ethiopian Tailor Catalog`,
      description: 'This tailor shop is currently pending verification and is not yet public.',
    };
  }

  return {
    title: `${tailor.shop_name} | Ethiopian Handcrafted Fashion Catalog`,
    description: `Browse custom designs, traditional attire, and modern fashion from ${tailor.shop_name}. Try on outfits virtually.`,
  };
}

/** Shown when the slug exists but the tailor is pending or rejected */
function ShopNotPublished({ shopName, status }: { shopName: string; status: string }) {
  return (
    <div className="min-h-screen bg-[#0a0a0f] text-slate-100 flex flex-col items-center justify-center p-6">
      <div className="w-full max-w-sm text-center space-y-6">
        <div className="w-16 h-16 rounded-3xl bg-amber-500/10 border border-amber-500/20 flex items-center justify-center mx-auto">
          <Clock className="w-8 h-8 text-amber-400" />
        </div>
        <div className="space-y-2">
          <div className="flex items-center justify-center gap-2 text-amber-400 font-semibold text-lg">
            <Store className="w-5 h-5" />
            <span>{shopName}</span>
          </div>
          <h1 className="text-2xl font-bold text-white">
            {status === 'rejected' ? 'Shop Unavailable' : 'Pending Verification'}
          </h1>
          <p className="text-slate-400 text-sm max-w-xs mx-auto leading-relaxed">
            {status === 'rejected'
              ? 'This tailor shop is not available. Please contact the shop directly.'
              : 'This tailor shop is currently awaiting approval and will be available soon.'}
          </p>
        </div>
        <a
          href="/"
          className="inline-flex items-center justify-center gap-2 w-full py-3 px-6 rounded-2xl bg-amber-500 hover:bg-amber-400 text-black font-bold text-sm transition"
        >
          Go to Homepage
        </a>
      </div>
    </div>
  );
}

export default async function TailorCatalogPage({ params, searchParams }: PageProps) {
  const shopSlug = params.shopSlug;

  // Uses service role if SUPABASE_SERVICE_ROLE_KEY is set on the server,
  // otherwise falls back to anon key (requires RLS policy 009/010 applied).
  const supabase = await getCatalogClient();

  const usingServiceRole = !!(process.env.SUPABASE_SERVICE_ROLE_KEY?.length ?? 0 > 20);
  console.log(`[catalog] shopSlug="${shopSlug}" usingServiceRole=${usingServiceRole}`);

  // 1. Fetch tailor by slug — no status filter so we can distinguish pending vs missing
  const { data: tailorData, error: tailorError } = await supabase
    .from('tailors')
    .select('id, shop_name, shop_slug, email, phone, status')
    .eq('shop_slug', shopSlug)
    .maybeSingle();

  console.log(`[catalog] found=${!!tailorData} status=${tailorData?.status ?? 'N/A'} error=${tailorError?.message ?? 'none'}`);

  // Slug doesn't exist at all
  if (tailorError || !tailorData) {
    console.log(`[catalog] 404 — tailor not found for slug="${shopSlug}"`);
    notFound();
  }

  // Slug exists but tailor is not approved yet
  if (tailorData.status !== 'approved') {
    return (
      <ShopNotPublished shopName={tailorData.shop_name} status={tailorData.status} />
    );
  }

  const tailor: CatalogTailor = {
    id: tailorData.id,
    shop_name: tailorData.shop_name,
    shop_slug: tailorData.shop_slug,
    email: tailorData.email,
    phone: tailorData.phone,
    status: tailorData.status as 'approved',
  };

  // 2. Fetch categories (public read RLS exists — anon can always read)
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
      is_trending,
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
    is_trending: d.is_trending ?? false,
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
      initialDesignId={searchParams?.design}
    />
  );
}
