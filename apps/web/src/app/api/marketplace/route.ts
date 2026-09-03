import { NextResponse } from 'next/server';
import { createAdminClient, createClient } from '@/lib/supabase/server';

function getMarketplaceClient() {
  return process.env.SUPABASE_SERVICE_ROLE_KEY ? createAdminClient() : createClient();
}

export async function GET(request: Request) {
  const page = Math.max(0, Number(new URL(request.url).searchParams.get('page') || 0));
  const supabase = await getMarketplaceClient();
  const { data: approvedTailors } = await supabase.from('tailors').select('id, shop_name, shop_slug').eq('status', 'approved');
  const approvedTailorIds = (approvedTailors || []).map((tailor) => tailor.id);
  const from = page * 20;
  const { data, error } = await supabase.from('designs').select('id, tailor_id, category_id, price, tag, is_grouped, is_trending, created_at, updated_at, category:categories(id, name_en, name_am, name_om, name_so, sort_order), photos:design_photos(id, cloudinary_public_id, cloudinary_url, order_index)').in('tailor_id', approvedTailorIds).order('created_at', { ascending: false }).range(from, from + 19);
  let marketplaceData: any[] | null = data as any[] | null;
  if (error) {
    const fallback = await supabase.from('designs').select('id, tailor_id, category_id, price, tag, is_grouped, created_at, updated_at, category:categories(id, name_en, name_am, name_om, name_so, sort_order), photos:design_photos(id, cloudinary_public_id, cloudinary_url, order_index)').in('tailor_id', approvedTailorIds).order('created_at', { ascending: false }).range(from, from + 19);
    if (fallback.error) return NextResponse.json({ error: fallback.error.message }, { status: 500 });
    marketplaceData = fallback.data?.map((design: any) => ({ ...design, is_trending: false })) ?? null;
  }
  return NextResponse.json((marketplaceData || []).map((d: any) => ({ ...d, category: Array.isArray(d.category) ? d.category[0] : d.category, tailor: approvedTailors?.find((tailor) => tailor.id === d.tailor_id), photos: (d.photos || []).sort((a: any, b: any) => a.order_index - b.order_index) })));
}
