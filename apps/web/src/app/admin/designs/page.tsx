import { createAdminClient } from '@/lib/supabase/admin';
import { DesignsGalleryClient } from '@/components/admin/DesignsGalleryClient';
import { Image as ImageIcon, Sparkles, Filter } from 'lucide-react';

export const dynamic = 'force-dynamic';

export default async function AdminDesignsPage({
  searchParams,
}: {
  searchParams?: { tailorId?: string };
}) {
  const tailorId = searchParams?.tailorId || '';
  const supabase = createAdminClient();

  // Fetch categories
  const { data: categories } = await supabase
    .from('categories')
    .select('*')
    .order('sort_order', { ascending: true });

  // Fetch tailors for filter list
  const { data: tailors } = await supabase
    .from('tailors')
    .select('id, shop_name')
    .order('shop_name', { ascending: true });

  // Fetch designs with joined tailor, category, and photos
  const { data: designs, error } = await supabase
    .from('designs')
    .select(`
      *,
      tailor:tailors(id, shop_name, shop_slug, email, status),
      category:categories(id, name_en, name_am, name_om, name_so),
      photos:design_photos(id, cloudinary_public_id, cloudinary_url, order_index)
    `)
    .order('created_at', { ascending: false });

  if (error) {
    console.error('Error fetching designs:', error);
  }

  return (
    <div className="space-y-8 animate-in fade-in duration-300">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <div className="flex items-center gap-2">
            <ImageIcon className="w-5 h-5 text-brand-400" />
            <h1 className="text-2xl font-bold text-white tracking-tight">Content Moderation & Catalog</h1>
          </div>
          <p className="text-xs sm:text-sm text-slate-400 mt-1">
            Audit fashion designs uploaded across all tailor shops, inspect details, and remove inappropriate content.
          </p>
        </div>
      </div>

      {/* Gallery Client */}
      <DesignsGalleryClient
        initialDesigns={designs || []}
        categories={categories || []}
        tailors={tailors || []}
        initialTailorId={tailorId}
      />
    </div>
  );
}
