'use client';

import React, { useState } from 'react';
import { updateTailorStatus } from '@/app/admin/actions';
import { TailorStatus } from '@tailor-catalog/shared';
import { Check, X, Ban, RefreshCw, Loader2, AlertCircle } from 'lucide-react';

interface TailorActionButtonsProps {
  tailorId: string;
  currentStatus: TailorStatus;
  shopName: string;
  compact?: boolean;
}

export function TailorActionButtons({
  tailorId,
  currentStatus,
  shopName,
  compact = false,
}: TailorActionButtonsProps) {
  const [loading, setLoading] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);

  const handleStatusChange = async (newStatus: TailorStatus) => {
    setLoading(newStatus);
    setError(null);
    try {
      const res = await updateTailorStatus(tailorId, newStatus);
      if (!res.success) {
        setError(res.error || 'Failed to update status');
      }
    } catch (err: any) {
      setError(err.message || 'An error occurred');
    } finally {
      setLoading(null);
    }
  };

  return (
    <div className="flex flex-col items-end gap-1">
      <div className="flex items-center gap-2">
        {/* Approve Button */}
        {currentStatus !== 'approved' && (
          <button
            id={`approve-tailor-${tailorId}`}
            onClick={() => handleStatusChange('approved')}
            disabled={loading !== null}
            className={`inline-flex items-center gap-1.5 font-medium rounded-xl text-xs bg-forest-600/20 text-forest-300 border border-forest-500/30 hover:bg-forest-600 hover:text-white transition disabled:opacity-50 ${
              compact ? 'px-2.5 py-1.5' : 'px-3 py-1.5'
            }`}
            title={`Approve ${shopName}`}
          >
            {loading === 'approved' ? (
              <Loader2 className="w-3.5 h-3.5 animate-spin" />
            ) : (
              <Check className="w-3.5 h-3.5" />
            )}
            <span>Approve</span>
          </button>
        )}

        {/* Reject Button (for pending tailors) */}
        {currentStatus === 'pending' && (
          <button
            id={`reject-tailor-${tailorId}`}
            onClick={() => handleStatusChange('rejected')}
            disabled={loading !== null}
            className={`inline-flex items-center gap-1.5 font-medium rounded-xl text-xs bg-rose-500/10 text-rose-400 border border-rose-500/20 hover:bg-rose-600 hover:text-white transition disabled:opacity-50 ${
              compact ? 'px-2.5 py-1.5' : 'px-3 py-1.5'
            }`}
            title={`Reject ${shopName}`}
          >
            {loading === 'rejected' ? (
              <Loader2 className="w-3.5 h-3.5 animate-spin" />
            ) : (
              <X className="w-3.5 h-3.5" />
            )}
            <span>Reject</span>
          </button>
        )}

        {/* Deactivate Button (for approved tailors) */}
        {currentStatus === 'approved' && (
          <button
            id={`deactivate-tailor-${tailorId}`}
            onClick={() => handleStatusChange('rejected')}
            disabled={loading !== null}
            className={`inline-flex items-center gap-1.5 font-medium rounded-xl text-xs bg-rose-500/10 text-rose-400 border border-rose-500/20 hover:bg-rose-600 hover:text-white transition disabled:opacity-50 ${
              compact ? 'px-2.5 py-1.5' : 'px-3 py-1.5'
            }`}
            title={`Deactivate account for ${shopName}`}
          >
            {loading === 'rejected' ? (
              <Loader2 className="w-3.5 h-3.5 animate-spin" />
            ) : (
              <Ban className="w-3.5 h-3.5" />
            )}
            <span>Deactivate</span>
          </button>
        )}

        {/* Re-activate Button (for rejected/deactivated tailors) */}
        {currentStatus === 'rejected' && (
          <button
            id={`reactivate-tailor-${tailorId}`}
            onClick={() => handleStatusChange('approved')}
            disabled={loading !== null}
            className={`inline-flex items-center gap-1.5 font-medium rounded-xl text-xs bg-brand-500/10 text-brand-400 border border-brand-500/20 hover:bg-brand-600 hover:text-white transition disabled:opacity-50 ${
              compact ? 'px-2.5 py-1.5' : 'px-3 py-1.5'
            }`}
            title={`Reactivate account for ${shopName}`}
          >
            {loading === 'approved' ? (
              <Loader2 className="w-3.5 h-3.5 animate-spin" />
            ) : (
              <RefreshCw className="w-3.5 h-3.5" />
            )}
            <span>Re-activate</span>
          </button>
        )}
      </div>

      {error && (
        <span className="text-[11px] text-rose-400 flex items-center gap-1 mt-0.5">
          <AlertCircle className="w-3 h-3" /> {error}
        </span>
      )}
    </div>
  );
}
