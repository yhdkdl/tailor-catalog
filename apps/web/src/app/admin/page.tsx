import Link from 'next/link';
import { createAdminClient } from '@/lib/supabase/admin';
import { Users, Clock, CheckCircle2, XCircle, Image as ImageIcon, ArrowRight, ShieldCheck, Sparkles, Store } from 'lucide-react';
import { TailorActionButtons } from '@/components/admin/TailorActionButtons';

export const dynamic = 'force-dynamic';

export default async function AdminDashboardPage() {
  const supabase = createAdminClient();

  // Fetch tailors stats
  const { data: tailors, error: tailorsError } = await supabase
    .from('tailors')
    .select('*')
    .order('created_at', { ascending: false });

  // Fetch designs count
  const { count: designsCount } = await supabase
    .from('designs')
    .select('*', { count: 'exact', head: true });

  const allTailors = tailors || [];
  const pendingTailors = allTailors.filter((t) => t.status === 'pending');
  const approvedTailors = allTailors.filter((t) => t.status === 'approved');
  const rejectedTailors = allTailors.filter((t) => t.status === 'rejected');

  return (
    <div className="space-y-8 animate-in fade-in duration-300">
      {/* Welcome Banner */}
      <div className="relative overflow-hidden rounded-3xl p-6 sm:p-8 bg-gradient-to-r from-surface-900 via-surface-900 to-brand-950/40 border border-slate-800/80 shadow-2xl">
        <div className="relative z-10 flex flex-col md:flex-row md:items-center justify-between gap-6">
          <div className="space-y-2">
            <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-brand-500/10 text-brand-400 border border-brand-500/20 text-xs font-semibold">
              <Sparkles className="w-3.5 h-3.5" />
              <span>Admin Control Center</span>
            </div>
            <h1 className="text-2xl sm:text-3xl font-bold text-white tracking-tight">
              Ethiopian Tailor Catalog Portal
            </h1>
            <p className="text-sm text-slate-400 max-w-xl">
              Monitor tailor registrations, approve verified shops, and curate quality fashion catalog designs.
            </p>
          </div>

          <div className="flex flex-wrap items-center gap-3">
            <Link
              href="/admin/tailors/new"
              className="inline-flex items-center gap-2 px-4 py-2.5 rounded-xl bg-forest-600 hover:bg-forest-500 text-white text-sm font-medium transition shadow-lg shadow-forest-600/20"
            >
              <Store className="w-4 h-4" />
              <span>Register Tailor</span>
            </Link>
            <Link
              href="/admin/tailors?status=pending"
              className="inline-flex items-center gap-2 px-4 py-2.5 rounded-xl bg-brand-600 hover:bg-brand-500 text-white text-sm font-medium transition shadow-lg shadow-brand-600/20"
            >
              <Clock className="w-4 h-4" />
              <span>Review Pending ({pendingTailors.length})</span>
            </Link>
            <Link
              href="/admin/designs"
              className="inline-flex items-center gap-2 px-4 py-2.5 rounded-xl bg-surface-800 hover:bg-surface-700 text-slate-200 text-sm font-medium border border-slate-700 transition"
            >
              <ImageIcon className="w-4 h-4" />
              <span>Moderation</span>
            </Link>
          </div>
        </div>
      </div>

      {/* Metrics Grid */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        {/* Total Tailors */}
        <div className="glass-panel p-5 rounded-2xl border border-slate-800/80 flex items-center justify-between">
          <div>
            <p className="text-xs font-medium text-slate-400 uppercase tracking-wider">Total Tailors</p>
            <p className="text-2xl font-bold text-white mt-1">{allTailors.length}</p>
            <p className="text-xs text-slate-500 mt-1">Registered shops</p>
          </div>
          <div className="w-12 h-12 rounded-2xl bg-blue-500/10 border border-blue-500/20 flex items-center justify-center text-blue-400">
            <Users className="w-6 h-6" />
          </div>
        </div>

        {/* Pending Approvals */}
        <div className="glass-panel p-5 rounded-2xl border border-slate-800/80 flex items-center justify-between">
          <div>
            <p className="text-xs font-medium text-slate-400 uppercase tracking-wider">Pending Review</p>
            <p className="text-2xl font-bold text-amber-400 mt-1">{pendingTailors.length}</p>
            <p className="text-xs text-amber-500/80 mt-1">Awaiting verification</p>
          </div>
          <div className="w-12 h-12 rounded-2xl bg-amber-500/10 border border-amber-500/20 flex items-center justify-center text-amber-400">
            <Clock className="w-6 h-6" />
          </div>
        </div>

        {/* Approved Tailors */}
        <div className="glass-panel p-5 rounded-2xl border border-slate-800/80 flex items-center justify-between">
          <div>
            <p className="text-xs font-medium text-slate-400 uppercase tracking-wider">Active Approved</p>
            <p className="text-2xl font-bold text-forest-400 mt-1">{approvedTailors.length}</p>
            <p className="text-xs text-forest-500/80 mt-1">Live in catalog</p>
          </div>
          <div className="w-12 h-12 rounded-2xl bg-forest-500/10 border border-forest-500/20 flex items-center justify-center text-forest-400">
            <CheckCircle2 className="w-6 h-6" />
          </div>
        </div>

        {/* Total Designs */}
        <div className="glass-panel p-5 rounded-2xl border border-slate-800/80 flex items-center justify-between">
          <div>
            <p className="text-xs font-medium text-slate-400 uppercase tracking-wider">Published Designs</p>
            <p className="text-2xl font-bold text-brand-400 mt-1">{designsCount ?? 0}</p>
            <p className="text-xs text-brand-500/80 mt-1">Across all categories</p>
          </div>
          <div className="w-12 h-12 rounded-2xl bg-brand-500/10 border border-brand-500/20 flex items-center justify-center text-brand-400">
            <ImageIcon className="w-6 h-6" />
          </div>
        </div>
      </div>

      {/* Pending Tailors Queue Section */}
      <div className="glass-panel rounded-2xl border border-slate-800/80 p-6 space-y-4">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2">
            <Clock className="w-5 h-5 text-amber-400" />
            <h2 className="text-lg font-bold text-white">Pending Tailor Approvals</h2>
            <span className="ml-2 px-2.5 py-0.5 rounded-full text-xs font-semibold bg-amber-500/15 text-amber-400 border border-amber-500/30">
              {pendingTailors.length} New
            </span>
          </div>
          <Link
            href="/admin/tailors"
            className="text-xs font-medium text-brand-400 hover:text-brand-300 flex items-center gap-1 transition"
          >
            <span>View All Tailors</span>
            <ArrowRight className="w-3.5 h-3.5" />
          </Link>
        </div>

        {pendingTailors.length === 0 ? (
          <div className="py-12 text-center rounded-xl bg-surface-900/50 border border-slate-800/50">
            <CheckCircle2 className="w-10 h-10 text-forest-400 mx-auto mb-2 opacity-80" />
            <p className="text-sm font-semibold text-slate-300">All caught up!</p>
            <p className="text-xs text-slate-500 mt-1">No pending tailor applications at this time.</p>
          </div>
        ) : (
          <div className="divide-y divide-slate-800/80 overflow-x-auto">
            {pendingTailors.slice(0, 5).map((tailor) => (
              <div
                key={tailor.id}
                className="py-4 flex flex-col sm:flex-row sm:items-center justify-between gap-4 hover:bg-slate-850/40 px-3 rounded-xl transition"
              >
                <div className="space-y-1">
                  <div className="flex items-center gap-2">
                    <Store className="w-4 h-4 text-brand-400" />
                    <span className="font-semibold text-white text-sm">{tailor.shop_name}</span>
                    <span className="text-xs text-slate-400 font-mono bg-surface-950 px-2 py-0.5 rounded border border-slate-800">
                      /{tailor.shop_slug}
                    </span>
                  </div>
                  <div className="flex items-center gap-4 text-xs text-slate-400">
                    <span>{tailor.email}</span>
                    {tailor.phone && <span>• {tailor.phone}</span>}
                    <span>• {new Date(tailor.created_at).toLocaleDateString()}</span>
                  </div>
                </div>

                <TailorActionButtons
                  tailorId={tailor.id}
                  currentStatus={tailor.status}
                  shopName={tailor.shop_name}
                />
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
