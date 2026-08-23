import { createAdminClient } from '@/lib/supabase/admin';
import { TailorsTableClient } from '@/components/admin/TailorsTableClient';
import { Users, Store, Clock, CheckCircle2, XCircle } from 'lucide-react';

export const dynamic = 'force-dynamic';

export default async function AdminTailorsPage({
  searchParams,
}: {
  searchParams?: { status?: string };
}) {
  const initialStatus = searchParams?.status || 'all';
  const supabase = createAdminClient();

  // Fetch tailors
  const { data: tailors, error } = await supabase
    .from('tailors')
    .select('*')
    .order('created_at', { ascending: false });

  // Fetch designs count per tailor
  const { data: designs } = await supabase
    .from('designs')
    .select('tailor_id');

  const designCountMap = new Map<string, number>();
  if (designs) {
    for (const d of designs) {
      designCountMap.set(d.tailor_id, (designCountMap.get(d.tailor_id) || 0) + 1);
    }
  }

  const tailorsWithStats = (tailors || []).map((t) => ({
    ...t,
    designs_count: designCountMap.get(t.id) || 0,
  }));

  return (
    <div className="space-y-8 animate-in fade-in duration-300">
      {/* Page Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <div className="flex items-center gap-2">
            <Users className="w-5 h-5 text-brand-400" />
            <h1 className="text-2xl font-bold text-white tracking-tight">Tailor Directory & Approvals</h1>
          </div>
          <p className="text-xs sm:text-sm text-slate-400 mt-1">
            Manage tailor shop registrations, approve pending partners, or deactivate accounts.
          </p>
        </div>
      </div>

      {/* Tailor Table Component */}
      <TailorsTableClient
        initialTailors={tailorsWithStats}
        initialStatusFilter={initialStatus}
      />
    </div>
  );
}
