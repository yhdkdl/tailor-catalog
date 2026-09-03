import { NextResponse } from 'next/server';
import { createClient } from '@/lib/supabase/server';

export async function GET(request: Request) {
  const page = Math.max(0, Number(new URL(request.url).searchParams.get('page') || 0));
  const supabase = await createClient();
  const from = page * 20;
  const { data, error } = await supabase.from('designs').select('id, tailor_id, category_id, price, tag, is_grouped, is_trending, created_at, updated_at, category:categories(id, name_en, name_am, name_om, name_so, sort_order), photos:design_photos(id, cloudinary_public_id, cloudinary_url, order_index), tailor:tailors!inner(id, shop_name, shop_slug, status)').eq('tailor.status', 'approved').order('created_at', { ascending: false }).range(from, from + 19);
  if (error) return NextResponse.json({ error: error.message }, { status: 500 });
  return NextResponse.json((data || []).map((d: any) => ({ ...d, category: Array.isArray(d.category) ? d.category[0] : d.category, tailor: Array.isArray(d.tailor) ? d.tailor[0] : d.tailor, photos: (d.photos || []).sort((a: any, b: any) => a.order_index - b.order_index) })));
}
