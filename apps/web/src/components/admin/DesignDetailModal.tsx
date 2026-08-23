'use client';

import React, { useState } from 'react';
import Image from 'next/image';
import { deleteDesign } from '@/app/admin/actions';
import { getSupabaseUrl } from '@/lib/supabase/client';
import {
  X,
  Trash2,
  Store,
  Tag as TagIcon,
  Layers,
  Calendar,
  DollarSign,
  ChevronLeft,
  ChevronRight,
  AlertTriangle,
  Loader2,
  Globe,
  ExternalLink,
} from 'lucide-react';

export interface AdminDesignItem {
  id: string;
  tailor_id: string;
  category_id: string;
  price: number;
  tag: string | null;
  is_grouped: boolean;
  created_at: string;
  updated_at: string;
  tailor?: {
    id: string;
    shop_name: string;
    shop_slug: string;
    email: string;
    status: string;
  } | null;
  category?: {
    id: string;
    name_en: string;
    name_am: string;
    name_om: string;
    name_so: string;
  } | null;
  photos?: Array<{
    id: string;
    storage_path: string;
    order_index: number;
  }>;
}

interface DesignDetailModalProps {
  design: AdminDesignItem | null;
  isOpen: boolean;
  onClose: () => void;
  onDeleted?: (designId: string) => void;
}

export function DesignDetailModal({
  design,
  isOpen,
  onClose,
  onDeleted,
}: DesignDetailModalProps) {
  const [activePhotoIndex, setActivePhotoIndex] = useState(0);
  const [confirmDelete, setConfirmDelete] = useState(false);
  const [deleting, setDeleting] = useState(false);
  const [deleteError, setDeleteError] = useState<string | null>(null);

  if (!isOpen || !design) return null;

  const photos = design.photos || [];
  const supabaseUrl = getSupabaseUrl();

  const getPhotoUrl = (storagePath: string) => {
    return `${supabaseUrl}/storage/v1/object/public/design-photos/${storagePath}`;
  };

  const currentPhoto = photos[activePhotoIndex] || photos[0];

  const handleDelete = async () => {
    setDeleting(true);
    setDeleteError(null);

    try {
      const res = await deleteDesign(design.id);
      if (res.success) {
        onDeleted?.(design.id);
        onClose();
      } else {
        setDeleteError(res.error || 'Failed to delete design.');
      }
    } catch (err: any) {
      setDeleteError(err.message || 'An error occurred during deletion.');
    } finally {
      setDeleting(false);
    }
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/80 backdrop-blur-md animate-in fade-in duration-200">
      <div
        className="glass-panel w-full max-w-4xl max-h-[90vh] rounded-3xl border border-slate-800 shadow-2xl overflow-hidden flex flex-col md:flex-row"
        onClick={(e) => e.stopPropagation()}
      >
        {/* Left / Top: Photo Gallery & Carousel */}
        <div className="md:w-1/2 bg-surface-950/80 p-6 flex flex-col justify-between relative border-b md:border-b-0 md:border-r border-slate-800">
          {/* Main Photo Display */}
          <div className="relative w-full aspect-[4/5] rounded-2xl overflow-hidden bg-surface-900 border border-slate-800/80 flex items-center justify-center">
            {currentPhoto ? (
              <img
                src={getPhotoUrl(currentPhoto.storage_path)}
                alt={design.tag || 'Design photo'}
                className="w-full h-full object-cover"
              />
            ) : (
              <div className="text-center p-6 text-slate-500">
                <Layers className="w-12 h-12 mx-auto mb-2 opacity-50" />
                <p className="text-xs">No photos uploaded for this design</p>
              </div>
            )}

            {/* Photo Counter Badge */}
            {photos.length > 1 && (
              <div className="absolute bottom-3 right-3 px-2.5 py-1 rounded-full bg-black/70 backdrop-blur-md text-white text-xs font-semibold border border-white/10">
                {activePhotoIndex + 1} / {photos.length}
              </div>
            )}

            {/* Carousel Navigation Arrows */}
            {photos.length > 1 && (
              <>
                <button
                  onClick={() =>
                    setActivePhotoIndex((prev) => (prev > 0 ? prev - 1 : photos.length - 1))
                  }
                  className="absolute left-2 top-1/2 -translate-y-1/2 p-2 rounded-full bg-black/60 hover:bg-black/80 text-white backdrop-blur-sm transition"
                >
                  <ChevronLeft className="w-4 h-4" />
                </button>
                <button
                  onClick={() =>
                    setActivePhotoIndex((prev) => (prev < photos.length - 1 ? prev + 1 : 0))
                  }
                  className="absolute right-2 top-1/2 -translate-y-1/2 p-2 rounded-full bg-black/60 hover:bg-black/80 text-white backdrop-blur-sm transition"
                >
                  <ChevronRight className="w-4 h-4" />
                </button>
              </>
            )}
          </div>

          {/* Thumbnail Strip */}
          {photos.length > 1 && (
            <div className="flex items-center gap-2 mt-4 overflow-x-auto pb-1">
              {photos.map((photo, index) => (
                <button
                  key={photo.id}
                  onClick={() => setActivePhotoIndex(index)}
                  className={`relative w-14 h-14 rounded-xl overflow-hidden flex-shrink-0 border-2 transition ${
                    activePhotoIndex === index
                      ? 'border-brand-400 ring-2 ring-brand-500/30 scale-105'
                      : 'border-transparent opacity-60 hover:opacity-100'
                  }`}
                >
                  <img
                    src={getPhotoUrl(photo.storage_path)}
                    alt={`Thumbnail ${index + 1}`}
                    className="w-full h-full object-cover"
                  />
                </button>
              ))}
            </div>
          )}
        </div>

        {/* Right / Bottom: Metadata & Moderation Actions */}
        <div className="md:w-1/2 p-6 sm:p-8 flex flex-col justify-between overflow-y-auto space-y-6">
          {/* Header */}
          <div className="space-y-4">
            <div className="flex items-start justify-between gap-4">
              <div>
                <span className="text-xs font-semibold px-2.5 py-1 rounded-full bg-brand-500/15 text-brand-300 border border-brand-500/30">
                  {design.category?.name_en || 'Fashion Design'}
                </span>
                <h3 className="text-2xl font-bold text-white mt-2">
                  {Number(design.price).toLocaleString()} ETB
                </h3>
              </div>

              <button
                onClick={onClose}
                className="p-2 rounded-xl text-slate-400 hover:text-white hover:bg-slate-800/80 transition"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            {/* Tag Badge */}
            {design.tag && (
              <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-xl bg-surface-900 border border-slate-700 text-xs font-medium text-slate-200">
                <TagIcon className="w-3.5 h-3.5 text-brand-400" />
                <span>{design.tag}</span>
              </div>
            )}
          </div>

          {/* Details List */}
          <div className="space-y-4 text-xs">
            {/* Tailor Info */}
            <div className="p-3.5 rounded-2xl bg-surface-900/80 border border-slate-800/80 space-y-1">
              <div className="flex items-center gap-1.5 text-slate-400 font-medium uppercase tracking-wider">
                <Store className="w-3.5 h-3.5 text-brand-400" />
                <span>Tailor Shop</span>
              </div>
              <p className="text-white font-semibold text-sm">
                {design.tailor?.shop_name || 'Unknown Tailor'}
              </p>
              <div className="flex items-center gap-2 text-slate-400">
                <span className="font-mono text-[11px]">/{design.tailor?.shop_slug}</span>
                <span>• {design.tailor?.email}</span>
              </div>
            </div>

            {/* Category Names in all 4 languages */}
            {design.category && (
              <div className="p-3.5 rounded-2xl bg-surface-900/80 border border-slate-800/80 space-y-2">
                <div className="flex items-center gap-1.5 text-slate-400 font-medium uppercase tracking-wider">
                  <Globe className="w-3.5 h-3.5 text-forest-400" />
                  <span>Multilingual Category</span>
                </div>
                <div className="grid grid-cols-2 gap-2 text-[11px]">
                  <div>
                    <span className="text-slate-500">English:</span>{' '}
                    <span className="text-slate-200 font-medium">{design.category.name_en}</span>
                  </div>
                  <div>
                    <span className="text-slate-500">Amharic:</span>{' '}
                    <span className="text-slate-200 font-medium">{design.category.name_am}</span>
                  </div>
                  <div>
                    <span className="text-slate-500">Oromifa:</span>{' '}
                    <span className="text-slate-200 font-medium">{design.category.name_om}</span>
                  </div>
                  <div>
                    <span className="text-slate-500">Somali:</span>{' '}
                    <span className="text-slate-200 font-medium">{design.category.name_so}</span>
                  </div>
                </div>
              </div>
            )}

            {/* Design Type & Created Date */}
            <div className="grid grid-cols-2 gap-3 text-slate-400">
              <div className="p-3 rounded-xl bg-surface-900/50 border border-slate-800">
                <span className="block text-slate-500 text-[10px] uppercase">Format</span>
                <span className="text-white font-medium">
                  {design.is_grouped ? 'Multi-Photo Set' : 'Single Photo Card'}
                </span>
              </div>
              <div className="p-3 rounded-xl bg-surface-900/50 border border-slate-800">
                <span className="block text-slate-500 text-[10px] uppercase">Published</span>
                <span className="text-white font-medium">
                  {new Date(design.created_at).toLocaleDateString()}
                </span>
              </div>
            </div>
          </div>

          {/* Delete Action Section */}
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
                  <span>Are you sure you want to permanently delete this design?</span>
                </div>
                <p className="text-[11px] text-slate-400">
                  This will remove the design and all its images from storage. This action cannot be undone.
                </p>
                <div className="flex items-center gap-2">
                  <button
                    id="confirm-delete-design-btn"
                    onClick={handleDelete}
                    disabled={deleting}
                    className="px-4 py-2 rounded-xl bg-rose-600 hover:bg-rose-500 text-white font-medium text-xs flex items-center gap-1.5 transition disabled:opacity-50"
                  >
                    {deleting ? (
                      <Loader2 className="w-3.5 h-3.5 animate-spin" />
                    ) : (
                      <Trash2 className="w-3.5 h-3.5" />
                    )}
                    <span>Confirm Delete</span>
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
                id="delete-design-trigger-btn"
                onClick={() => setConfirmDelete(true)}
                className="w-full py-2.5 px-4 rounded-xl bg-rose-500/10 hover:bg-rose-600 text-rose-400 hover:text-white border border-rose-500/20 text-xs font-semibold transition flex items-center justify-center gap-2"
              >
                <Trash2 className="w-4 h-4" />
                <span>Delete Design (Moderation)</span>
              </button>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
