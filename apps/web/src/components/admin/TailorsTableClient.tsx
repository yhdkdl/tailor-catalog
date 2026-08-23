'use client';

import React, { useState, useMemo } from 'react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { Tailor, TailorStatus } from '@tailor-catalog/shared';
import { TailorActionButtons } from './TailorActionButtons';
import { TailorDetailModal } from './TailorDetailModal';
import { deleteTailorByAdmin } from '@/app/admin/actions';
import {
  Search,
  Users,
  Clock,
  CheckCircle2,
  XCircle,
  Eye,
  ExternalLink,
  Store,
  Mail,
  Phone,
  Calendar,
  Filter,
  ArrowUpDown,
  UserPlus,
  Trash2,
  AlertTriangle,
  Loader2,
} from 'lucide-react';

interface TailorWithStats extends Tailor {
  designs_count?: number;
}

interface TailorsTableClientProps {
  initialTailors: TailorWithStats[];
  initialStatusFilter?: string;
}

export function TailorsTableClient({
  initialTailors,
  initialStatusFilter = 'all',
}: TailorsTableClientProps) {
  const router = useRouter();
  const [tailorsList, setTailorsList] = useState<TailorWithStats[]>(initialTailors);
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedStatus, setSelectedStatus] = useState<string>(initialStatusFilter);
  const [sortBy, setSortBy] = useState<'newest' | 'oldest' | 'name'>('newest');
  const [selectedTailor, setSelectedTailor] = useState<TailorWithStats | null>(null);

  // Quick deletion modal state
  const [tailorToDelete, setTailorToDelete] = useState<TailorWithStats | null>(null);
  const [deleting, setDeleting] = useState(false);
  const [deleteError, setDeleteError] = useState<string | null>(null);

  // Update list when prop changes
  React.useEffect(() => {
    setTailorsList(initialTailors);
  }, [initialTailors]);

  // Status counts
  const counts = useMemo(() => {
    const pending = tailorsList.filter((t) => t.status === 'pending').length;
    const approved = tailorsList.filter((t) => t.status === 'approved').length;
    const rejected = tailorsList.filter((t) => t.status === 'rejected').length;
    return {
      all: tailorsList.length,
      pending,
      approved,
      rejected,
    };
  }, [tailorsList]);

  // Filtered & sorted tailors
  const filteredTailors = useMemo(() => {
    return tailorsList
      .filter((tailor) => {
        // Status filter
        if (selectedStatus !== 'all' && tailor.status !== selectedStatus) {
          return false;
        }

        // Search query
        if (searchQuery.trim()) {
          const q = searchQuery.toLowerCase().trim();
          const matchName = tailor.shop_name.toLowerCase().includes(q);
          const matchSlug = tailor.shop_slug.toLowerCase().includes(q);
          const matchEmail = tailor.email.toLowerCase().includes(q);
          const matchPhone = tailor.phone ? tailor.phone.toLowerCase().includes(q) : false;
          return matchName || matchSlug || matchEmail || matchPhone;
        }

        return true;
      })
      .sort((a, b) => {
        if (sortBy === 'newest') {
          return new Date(b.created_at).getTime() - new Date(a.created_at).getTime();
        }
        if (sortBy === 'oldest') {
          return new Date(a.created_at).getTime() - new Date(b.created_at).getTime();
        }
        if (sortBy === 'name') {
          return a.shop_name.localeCompare(b.shop_name);
        }
        return 0;
      });
  }, [tailorsList, selectedStatus, searchQuery, sortBy]);

  const handleConfirmDelete = async () => {
    if (!tailorToDelete) return;
    setDeleting(true);
    setDeleteError(null);

    try {
      const res = await deleteTailorByAdmin(tailorToDelete.id);
      if (res.success) {
        setTailorsList((prev) => prev.filter((t) => t.id !== tailorToDelete.id));
        setTailorToDelete(null);
        router.refresh();
      } else {
        setDeleteError(res.error || 'Failed to delete tailor.');
      }
    } catch (err: any) {
      setDeleteError(err.message || 'An error occurred during deletion.');
    } finally {
      setDeleting(false);
    }
  };

  const statusBadge = (status: TailorStatus) => {
    switch (status) {
      case 'pending':
        return (
          <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-semibold bg-amber-500/15 text-amber-400 border border-amber-500/30">
            <Clock className="w-3.5 h-3.5" />
            <span>Pending Review</span>
          </span>
        );
      case 'approved':
        return (
          <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-semibold bg-forest-500/15 text-forest-400 border border-forest-500/30">
            <CheckCircle2 className="w-3.5 h-3.5" />
            <span>Approved</span>
          </span>
        );
      case 'rejected':
        return (
          <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-semibold bg-rose-500/15 text-rose-400 border border-rose-500/30">
            <XCircle className="w-3.5 h-3.5" />
            <span>Inactive / Rejected</span>
          </span>
        );
    }
  };

  return (
    <div className="space-y-6">
      {/* Header Action & Quick Link */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        {/* Status Filter Tabs */}
        <div className="flex items-center gap-1.5 p-1.5 bg-surface-900/90 rounded-2xl border border-slate-800/80 overflow-x-auto">
          <button
            onClick={() => setSelectedStatus('all')}
            className={`px-3.5 py-2 rounded-xl text-xs font-semibold transition-all whitespace-nowrap flex items-center gap-2 ${
              selectedStatus === 'all'
                ? 'bg-gradient-to-r from-brand-600 to-forest-600 text-white shadow-md'
                : 'text-slate-400 hover:text-white hover:bg-slate-800/50'
            }`}
          >
            <Users className="w-3.5 h-3.5" />
            <span>All Tailors</span>
            <span className="px-1.5 py-0.5 rounded-full text-[10px] bg-black/30 text-slate-300">
              {counts.all}
            </span>
          </button>

          <button
            onClick={() => setSelectedStatus('pending')}
            className={`px-3.5 py-2 rounded-xl text-xs font-semibold transition-all whitespace-nowrap flex items-center gap-2 ${
              selectedStatus === 'pending'
                ? 'bg-amber-600 text-white shadow-md'
                : 'text-slate-400 hover:text-amber-400 hover:bg-slate-800/50'
            }`}
          >
            <Clock className="w-3.5 h-3.5" />
            <span>Pending</span>
            <span className="px-1.5 py-0.5 rounded-full text-[10px] bg-amber-500/20 text-amber-300 border border-amber-500/30">
              {counts.pending}
            </span>
          </button>

          <button
            onClick={() => setSelectedStatus('approved')}
            className={`px-3.5 py-2 rounded-xl text-xs font-semibold transition-all whitespace-nowrap flex items-center gap-2 ${
              selectedStatus === 'approved'
                ? 'bg-forest-600 text-white shadow-md'
                : 'text-slate-400 hover:text-forest-400 hover:bg-slate-800/50'
            }`}
          >
            <CheckCircle2 className="w-3.5 h-3.5" />
            <span>Approved</span>
            <span className="px-1.5 py-0.5 rounded-full text-[10px] bg-forest-500/20 text-forest-300 border border-forest-500/30">
              {counts.approved}
            </span>
          </button>

          <button
            onClick={() => setSelectedStatus('rejected')}
            className={`px-3.5 py-2 rounded-xl text-xs font-semibold transition-all whitespace-nowrap flex items-center gap-2 ${
              selectedStatus === 'rejected'
                ? 'bg-rose-600 text-white shadow-md'
                : 'text-slate-400 hover:text-rose-400 hover:bg-slate-800/50'
            }`}
          >
            <XCircle className="w-3.5 h-3.5" />
            <span>Rejected</span>
            <span className="px-1.5 py-0.5 rounded-full text-[10px] bg-rose-500/20 text-rose-300 border border-rose-500/30">
              {counts.rejected}
            </span>
          </button>
        </div>

        {/* Register New Tailor Button */}
        <Link
          id="add-tailor-btn"
          href="/admin/tailors/new"
          className="inline-flex items-center justify-center gap-2 px-4 py-2.5 rounded-xl bg-brand-600 hover:bg-brand-500 text-white text-xs font-semibold shadow-lg shadow-brand-600/20 transition flex-shrink-0"
        >
          <UserPlus className="w-4 h-4" />
          <span>Register New Tailor</span>
        </Link>
      </div>

      {/* Search & Sort Controls */}
      <div className="flex flex-col sm:flex-row items-center justify-between gap-4">
        <div className="relative w-full sm:w-80">
          <Search className="w-4 h-4 absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400 pointer-events-none" />
          <input
            type="text"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            placeholder="Search shop, email, phone, slug..."
            className="w-full pl-10 pr-4 py-2 bg-surface-900/90 border border-slate-700/80 rounded-xl text-white placeholder-slate-500 text-xs focus:outline-none focus:ring-2 focus:ring-brand-500/50 focus:border-brand-500 transition"
          />
        </div>

        <div className="relative flex-shrink-0 w-full sm:w-auto">
          <select
            value={sortBy}
            onChange={(e: any) => setSortBy(e.target.value)}
            className="w-full sm:w-auto px-3 py-2 bg-surface-900/90 border border-slate-700/80 rounded-xl text-slate-300 text-xs font-medium focus:outline-none focus:ring-2 focus:ring-brand-500/50 appearance-none cursor-pointer pr-8"
          >
            <option value="newest">Sort: Newest First</option>
            <option value="oldest">Sort: Oldest First</option>
            <option value="name">Sort: Shop Name (A-Z)</option>
          </select>
          <ArrowUpDown className="w-3.5 h-3.5 absolute right-2.5 top-1/2 -translate-y-1/2 text-slate-400 pointer-events-none" />
        </div>
      </div>

      {/* Table for Desktop / Cards for Mobile */}
      {filteredTailors.length === 0 ? (
        <div className="glass-panel rounded-2xl border border-slate-800/80 p-12 text-center">
          <Users className="w-12 h-12 text-slate-600 mx-auto mb-3" />
          <h3 className="text-base font-semibold text-slate-300">No tailors found</h3>
          <p className="text-xs text-slate-500 mt-1 max-w-sm mx-auto">
            {searchQuery
              ? `No tailor records matching "${searchQuery}". Try changing your search query or filter.`
              : 'There are no tailor records registered in this category.'}
          </p>
        </div>
      ) : (
        <div className="glass-panel rounded-2xl border border-slate-800/80 overflow-hidden shadow-2xl">
          {/* Desktop Table View */}
          <div className="hidden lg:block overflow-x-auto">
            <table className="w-full text-left text-xs">
              <thead className="bg-surface-900/90 border-b border-slate-800 text-slate-400 uppercase tracking-wider font-semibold">
                <tr>
                  <th className="py-3.5 px-5">Tailor / Shop</th>
                  <th className="py-3.5 px-4">Contact Info</th>
                  <th className="py-3.5 px-4">Designs</th>
                  <th className="py-3.5 px-4">Registered</th>
                  <th className="py-3.5 px-4">Status</th>
                  <th className="py-3.5 px-5 text-right">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-800/60">
                {filteredTailors.map((tailor) => (
                  <tr
                    key={tailor.id}
                    className="hover:bg-slate-850/40 transition group cursor-pointer"
                    onClick={() => setSelectedTailor(tailor)}
                  >
                    <td className="py-4 px-5">
                      <div className="flex items-center gap-3">
                        <div className="w-10 h-10 rounded-xl bg-surface-900 border border-slate-700/60 flex items-center justify-center text-brand-400 group-hover:border-brand-500/50 transition">
                          <Store className="w-5 h-5" />
                        </div>
                        <div>
                          <span className="font-bold text-white text-sm block group-hover:text-brand-300 transition">
                            {tailor.shop_name}
                          </span>
                          <span className="text-xs text-slate-400 font-mono">/{tailor.shop_slug}</span>
                        </div>
                      </div>
                    </td>

                    <td className="py-4 px-4">
                      <div className="space-y-0.5">
                        <div className="flex items-center gap-1.5 text-slate-300">
                          <Mail className="w-3.5 h-3.5 text-slate-400 flex-shrink-0" />
                          <span className="truncate max-w-[200px]">{tailor.email}</span>
                        </div>
                        {tailor.phone && (
                          <div className="flex items-center gap-1.5 text-slate-400 text-[11px]">
                            <Phone className="w-3 h-3 text-slate-500 flex-shrink-0" />
                            <span>{tailor.phone}</span>
                          </div>
                        )}
                      </div>
                    </td>

                    <td className="py-4 px-4">
                      <span className="px-2.5 py-1 rounded-lg bg-surface-900 border border-slate-800 text-slate-300 font-medium">
                        {tailor.designs_count ?? 0} items
                      </span>
                    </td>

                    <td className="py-4 px-4 text-slate-400">
                      <span>{new Date(tailor.created_at).toLocaleDateString()}</span>
                    </td>

                    <td className="py-4 px-4">
                      {statusBadge(tailor.status)}
                    </td>

                    <td className="py-4 px-5 text-right" onClick={(e) => e.stopPropagation()}>
                      <div className="flex items-center justify-end gap-2">
                        <button
                          onClick={() => setSelectedTailor(tailor)}
                          className="p-1.5 text-slate-400 hover:text-white hover:bg-slate-800 rounded-lg transition"
                          title="View Details"
                        >
                          <Eye className="w-4 h-4" />
                        </button>

                        <TailorActionButtons
                          tailorId={tailor.id}
                          currentStatus={tailor.status}
                          shopName={tailor.shop_name}
                          compact
                        />

                        <button
                          id={`table-delete-tailor-${tailor.id}`}
                          onClick={() => setTailorToDelete(tailor)}
                          className="p-1.5 text-slate-400 hover:text-rose-400 hover:bg-rose-500/10 rounded-lg transition"
                          title="Delete Tailor"
                        >
                          <Trash2 className="w-4 h-4" />
                        </button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>

          {/* Mobile & Tablet Card View */}
          <div className="lg:hidden divide-y divide-slate-800/80">
            {filteredTailors.map((tailor) => (
              <div key={tailor.id} className="p-4 sm:p-5 space-y-4">
                <div className="flex items-start justify-between gap-3">
                  <div className="flex items-center gap-3">
                    <div className="w-10 h-10 rounded-xl bg-surface-900 border border-slate-700/60 flex items-center justify-center text-brand-400">
                      <Store className="w-5 h-5" />
                    </div>
                    <div>
                      <h4 className="font-bold text-white text-sm">{tailor.shop_name}</h4>
                      <span className="text-xs text-slate-400 font-mono">/{tailor.shop_slug}</span>
                    </div>
                  </div>

                  <div>{statusBadge(tailor.status)}</div>
                </div>

                <div className="grid grid-cols-2 gap-2 text-xs text-slate-400 pt-2 border-t border-slate-800/50">
                  <div className="flex items-center gap-1.5 truncate">
                    <Mail className="w-3.5 h-3.5 text-slate-500 flex-shrink-0" />
                    <span className="truncate">{tailor.email}</span>
                  </div>
                  {tailor.phone && (
                    <div className="flex items-center gap-1.5">
                      <Phone className="w-3.5 h-3.5 text-slate-500 flex-shrink-0" />
                      <span>{tailor.phone}</span>
                    </div>
                  )}
                  <div className="flex items-center gap-1.5">
                    <Calendar className="w-3.5 h-3.5 text-slate-500 flex-shrink-0" />
                    <span>{new Date(tailor.created_at).toLocaleDateString()}</span>
                  </div>
                  <div>
                    <span className="text-slate-300 font-medium">{tailor.designs_count ?? 0} designs</span>
                  </div>
                </div>

                <div className="flex items-center justify-between gap-2 pt-2">
                  <div className="flex items-center gap-2">
                    <button
                      onClick={() => setSelectedTailor(tailor)}
                      className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-xl bg-surface-900 border border-slate-800 text-slate-300 text-xs font-medium hover:bg-slate-800 transition"
                    >
                      <Eye className="w-3.5 h-3.5" />
                      <span>View Profile</span>
                    </button>

                    <button
                      onClick={() => setTailorToDelete(tailor)}
                      className="p-1.5 text-slate-400 hover:text-rose-400 hover:bg-rose-500/10 rounded-lg transition"
                      title="Delete Tailor"
                    >
                      <Trash2 className="w-3.5 h-3.5" />
                    </button>
                  </div>

                  <TailorActionButtons
                    tailorId={tailor.id}
                    currentStatus={tailor.status}
                    shopName={tailor.shop_name}
                    compact
                  />
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Tailor Detail Modal */}
      <TailorDetailModal
        tailor={selectedTailor}
        isOpen={!!selectedTailor}
        onClose={() => setSelectedTailor(null)}
        onDeleted={(deletedId) => {
          setTailorsList((prev) => prev.filter((t) => t.id !== deletedId));
          setSelectedTailor(null);
        }}
      />

      {/* Quick Delete Confirmation Modal */}
      {tailorToDelete && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/80 backdrop-blur-sm animate-in fade-in duration-200">
          <div className="glass-panel w-full max-w-md rounded-3xl p-6 sm:p-8 border border-rose-500/40 shadow-2xl space-y-5">
            <div className="flex items-center gap-3 text-rose-400">
              <div className="w-10 h-10 rounded-2xl bg-rose-500/20 border border-rose-500/30 flex items-center justify-center flex-shrink-0">
                <AlertTriangle className="w-5 h-5" />
              </div>
              <div>
                <h3 className="text-base font-bold text-white">Delete Tailor Account?</h3>
                <p className="text-xs text-slate-400">{tailorToDelete.shop_name}</p>
              </div>
            </div>

            {deleteError && (
              <div className="p-3 rounded-xl bg-rose-500/10 border border-rose-500/30 text-rose-300 text-xs">
                {deleteError}
              </div>
            )}

            <div className="p-4 rounded-2xl bg-surface-900 border border-slate-800 space-y-2 text-xs text-slate-300">
              <p className="font-semibold text-rose-300">This permanent action will:</p>
              <ul className="list-disc list-inside space-y-1 text-slate-400">
                <li>Delete all photo files from Supabase storage</li>
                <li>Delete all design records from the catalog</li>
                <li>Delete the tailor profile ({tailorToDelete.email})</li>
                <li>Delete the Supabase Auth user credentials</li>
              </ul>
            </div>

            <div className="flex items-center gap-3 pt-2">
              <button
                id="confirm-quick-delete-tailor"
                onClick={handleConfirmDelete}
                disabled={deleting}
                className="flex-1 py-2.5 px-4 rounded-xl bg-rose-600 hover:bg-rose-500 text-white font-semibold text-xs transition flex items-center justify-center gap-1.5 disabled:opacity-50"
              >
                {deleting ? (
                  <Loader2 className="w-3.5 h-3.5 animate-spin" />
                ) : (
                  <Trash2 className="w-3.5 h-3.5" />
                )}
                <span>Delete Permanently</span>
              </button>
              <button
                onClick={() => {
                  setTailorToDelete(null);
                  setDeleteError(null);
                }}
                disabled={deleting}
                className="py-2.5 px-4 rounded-xl bg-surface-800 hover:bg-surface-700 text-slate-300 text-xs font-semibold transition"
              >
                Cancel
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
