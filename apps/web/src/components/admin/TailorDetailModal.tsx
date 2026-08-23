'use client';

import React, { useState } from 'react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { Tailor, TailorStatus } from '@tailor-catalog/shared';
import { TailorActionButtons } from './TailorActionButtons';
import { deleteTailorByAdmin } from '@/app/admin/actions';
import {
  X,
  Store,
  Mail,
  Phone,
  Calendar,
  Hash,
  ExternalLink,
  Image as ImageIcon,
  ShieldCheck,
  Trash2,
  AlertTriangle,
  Loader2,
} from 'lucide-react';

interface TailorDetailModalProps {
  tailor: (Tailor & { designs_count?: number }) | null;
  isOpen: boolean;
  onClose: () => void;
  onDeleted?: (tailorId: string) => void;
}

export function TailorDetailModal({
  tailor,
  isOpen,
  onClose,
  onDeleted,
}: TailorDetailModalProps) {
  const router = useRouter();
  const [confirmDelete, setConfirmDelete] = useState(false);
  const [deleting, setDeleting] = useState(false);
  const [deleteError, setDeleteError] = useState<string | null>(null);

  if (!isOpen || !tailor) return null;

  const statusConfig: Record<TailorStatus, { label: string; badgeClass: string }> = {
    pending: {
      label: 'Pending Review',
      badgeClass: 'bg-amber-500/15 text-amber-400 border-amber-500/30',
    },
    approved: {
      label: 'Approved & Active',
      badgeClass: 'bg-forest-500/15 text-forest-400 border-forest-500/30',
    },
    rejected: {
      label: 'Rejected / Inactive',
      badgeClass: 'bg-rose-500/15 text-rose-400 border-rose-500/30',
    },
  };

  const statusInfo = statusConfig[tailor.status] || statusConfig.pending;

  const handleDeleteTailor = async () => {
    setDeleting(true);
    setDeleteError(null);

    try {
      const res = await deleteTailorByAdmin(tailor.id);
      if (res.success) {
        onDeleted?.(tailor.id);
        onClose();
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

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/75 backdrop-blur-sm animate-in fade-in duration-200">
      <div
        className="glass-panel w-full max-w-lg rounded-3xl p-6 sm:p-8 border border-slate-800 shadow-2xl space-y-6 relative overflow-hidden max-h-[90vh] overflow-y-auto"
        onClick={(e) => e.stopPropagation()}
      >
        {/* Background glow */}
        <div className="absolute -top-24 -right-24 w-48 h-48 bg-brand-500/10 rounded-full blur-2xl pointer-events-none" />

        {/* Header */}
        <div className="flex items-start justify-between gap-4">
          <div className="flex items-center gap-3">
            <div className="w-12 h-12 rounded-2xl bg-gradient-to-tr from-brand-600 to-forest-500 p-0.5 flex-shrink-0 shadow-lg shadow-brand-500/10">
              <div className="w-full h-full bg-surface-950 rounded-2xl flex items-center justify-center">
                <Store className="w-6 h-6 text-brand-400" />
              </div>
            </div>
            <div>
              <h2 className="text-xl font-bold text-white tracking-tight">{tailor.shop_name}</h2>
              <div className="flex items-center gap-2 mt-1">
                <span className={`text-xs px-2.5 py-0.5 rounded-full border font-semibold ${statusInfo.badgeClass}`}>
                  {statusInfo.label}
                </span>
                <span className="text-xs text-slate-400 font-mono bg-surface-900 px-2 py-0.5 rounded border border-slate-800">
                  /{tailor.shop_slug}
                </span>
              </div>
            </div>
          </div>

          <button
            onClick={onClose}
            className="p-2 rounded-xl text-slate-400 hover:text-white hover:bg-slate-800/80 transition"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Details Grid */}
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 text-xs">
          <div className="p-3.5 rounded-2xl bg-surface-900/80 border border-slate-800/80 space-y-1">
            <div className="flex items-center gap-1.5 text-slate-400 font-medium uppercase tracking-wider">
              <Mail className="w-3.5 h-3.5 text-brand-400" />
              <span>Email Address</span>
            </div>
            <p className="text-white font-medium text-sm break-all">{tailor.email}</p>
          </div>

          <div className="p-3.5 rounded-2xl bg-surface-900/80 border border-slate-800/80 space-y-1">
            <div className="flex items-center gap-1.5 text-slate-400 font-medium uppercase tracking-wider">
              <Phone className="w-3.5 h-3.5 text-forest-400" />
              <span>Phone Number</span>
            </div>
            <p className="text-white font-medium text-sm">{tailor.phone || 'Not provided'}</p>
          </div>

          <div className="p-3.5 rounded-2xl bg-surface-900/80 border border-slate-800/80 space-y-1">
            <div className="flex items-center gap-1.5 text-slate-400 font-medium uppercase tracking-wider">
              <Calendar className="w-3.5 h-3.5 text-blue-400" />
              <span>Registered Date</span>
            </div>
            <p className="text-white font-medium text-sm">
              {new Date(tailor.created_at).toLocaleDateString(undefined, {
                year: 'numeric',
                month: 'short',
                day: 'numeric',
                hour: '2-digit',
                minute: '2-digit',
              })}
            </p>
          </div>

          <div className="p-3.5 rounded-2xl bg-surface-900/80 border border-slate-800/80 space-y-1">
            <div className="flex items-center gap-1.5 text-slate-400 font-medium uppercase tracking-wider">
              <ImageIcon className="w-3.5 h-3.5 text-purple-400" />
              <span>Published Designs</span>
            </div>
            <p className="text-white font-medium text-sm">{tailor.designs_count ?? 0} designs</p>
          </div>
        </div>

        {/* System & Auth Details */}
        <div className="p-3.5 rounded-2xl bg-surface-950/60 border border-slate-800 text-xs space-y-2">
          <div className="flex items-center justify-between text-slate-400">
            <span className="flex items-center gap-1">
              <Hash className="w-3.5 h-3.5" /> Tailor ID:
            </span>
            <span className="font-mono text-slate-300 select-all">{tailor.id}</span>
          </div>
          {tailor.auth_id && (
            <div className="flex items-center justify-between text-slate-400">
              <span className="flex items-center gap-1">
                <ShieldCheck className="w-3.5 h-3.5" /> Auth User ID:
              </span>
              <span className="font-mono text-slate-300 select-all">{tailor.auth_id}</span>
            </div>
          )}
        </div>

        {/* Status & Catalog Actions */}
        <div className="pt-2 border-t border-slate-800 flex flex-col sm:flex-row items-center justify-between gap-4">
          <Link
            href={`/admin/designs?tailorId=${tailor.id}`}
            className="w-full sm:w-auto inline-flex items-center justify-center gap-2 px-4 py-2.5 rounded-xl bg-surface-800 hover:bg-surface-700 text-slate-200 text-xs font-medium border border-slate-700 transition"
          >
            <ImageIcon className="w-3.5 h-3.5 text-brand-400" />
            <span>View Tailor Designs</span>
            <ExternalLink className="w-3.5 h-3.5 text-slate-400" />
          </Link>

          <TailorActionButtons
            tailorId={tailor.id}
            currentStatus={tailor.status}
            shopName={tailor.shop_name}
          />
        </div>

        {/* Delete Tailor Section */}
        <div className="pt-4 border-t border-slate-800/80 space-y-3">
          {deleteError && (
            <div className="p-3 rounded-xl bg-rose-500/10 border border-rose-500/30 text-rose-300 text-xs">
              {deleteError}
            </div>
          )}

          {confirmDelete ? (
            <div className="p-4 rounded-2xl bg-rose-950/40 border border-rose-500/40 space-y-3 animate-in fade-in">
              <div className="flex items-center gap-2 text-rose-300 text-xs font-semibold">
                <AlertTriangle className="w-4 h-4 text-rose-400 flex-shrink-0" />
                <span>Delete tailor and ALL associated data?</span>
              </div>
              <p className="text-[11px] text-slate-400 leading-relaxed">
                This will permanently delete this tailor shop, all design records, all uploaded photos from Supabase storage, and the Supabase Auth user account. This cannot be undone.
              </p>
              <div className="flex items-center gap-2">
                <button
                  id={`confirm-delete-tailor-${tailor.id}`}
                  onClick={handleDeleteTailor}
                  disabled={deleting}
                  className="px-4 py-2 rounded-xl bg-rose-600 hover:bg-rose-500 text-white font-medium text-xs flex items-center gap-1.5 transition disabled:opacity-50"
                >
                  {deleting ? (
                    <Loader2 className="w-3.5 h-3.5 animate-spin" />
                  ) : (
                    <Trash2 className="w-3.5 h-3.5" />
                  )}
                  <span>Permanently Delete Tailor</span>
                </button>
                <button
                  onClick={() => setConfirmDelete(false)}
                  disabled={deleting}
                  className="px-4 py-2 rounded-xl bg-surface-800 hover:bg-surface-700 text-slate-300 text-xs transition"
                >
                  Cancel
                </button>
              </div>
            </div>
          ) : (
            <button
              id={`delete-tailor-btn-${tailor.id}`}
              onClick={() => setConfirmDelete(true)}
              className="w-full py-2.5 px-4 rounded-xl bg-rose-500/10 hover:bg-rose-600 text-rose-400 hover:text-white border border-rose-500/20 text-xs font-semibold transition flex items-center justify-center gap-2"
            >
              <Trash2 className="w-4 h-4" />
              <span>Delete Tailor Account & Catalog</span>
            </button>
          )}
        </div>
      </div>
    </div>
  );
}
