'use client';

import React, { useState, useMemo } from 'react';
import { AdminDesignItem, DesignDetailModal } from './DesignDetailModal';
import { deleteDesign } from '@/app/admin/actions';
import {
  Image as ImageIcon,
  Search,
  Filter,
  Layers,
  Tag as TagIcon,
  Store,
  Trash2,
  Eye,
  ArrowUpDown,
  Sparkles,
  AlertCircle,
  Loader2,
} from 'lucide-react';

interface CategoryItem {
  id: string;
  name_en: string;
  name_am: string;
  name_om: string;
  name_so: string;
}

interface TailorOption {
  id: string;
  shop_name: string;
}

interface DesignsGalleryClientProps {
  initialDesigns: AdminDesignItem[];
  categories: CategoryItem[];
  tailors: TailorOption[];
  initialTailorId?: string;
}

export function DesignsGalleryClient({
  initialDesigns,
  categories,
  tailors,
  initialTailorId = '',
}: DesignsGalleryClientProps) {
  const [designs, setDesigns] = useState<AdminDesignItem[]>(initialDesigns);
  const [selectedCategory, setSelectedCategory] = useState<string>('all');
  const [selectedTailorId, setSelectedTailorId] = useState<string>(initialTailorId);
  const [searchQuery, setSearchQuery] = useState('');
  const [sortBy, setSortBy] = useState<'newest' | 'oldest' | 'price_desc' | 'price_asc'>('newest');
  const [selectedDesign, setSelectedDesign] = useState<AdminDesignItem | null>(null);
  const [deletingId, setDeletingId] = useState<string | null>(null);

  const getPhotoUrl = (photo?: { cloudinary_url: string | null; cloudinary_public_id: string | null }) => {
    if (!photo) return '';
    if (photo.cloudinary_url) return photo.cloudinary_url;
    if (photo.cloudinary_public_id) {
      const cloudName = process.env.NEXT_PUBLIC_CLOUDINARY_CLOUD_NAME ?? 'tailor-catalog';
      return `https://res.cloudinary.com/${cloudName}/image/upload/f_auto,q_auto,w_800/${photo.cloudinary_public_id}`;
    }
    return '';
  };

  const handleQuickDelete = async (e: React.MouseEvent, designId: string) => {
    e.stopPropagation();
    if (!confirm('Are you sure you want to delete this design?')) return;

    setDeletingId(designId);
    try {
      const res = await deleteDesign(designId);
      if (res.success) {
        setDesigns((prev) => prev.filter((d) => d.id !== designId));
      } else {
        alert(res.error || 'Failed to delete design');
      }
    } catch (err: any) {
      alert(err.message || 'An error occurred during deletion');
    } finally {
      setDeletingId(null);
    }
  };

  const handleDesignDeleted = (deletedId: string) => {
    setDesigns((prev) => prev.filter((d) => d.id !== deletedId));
  };

  const filteredDesigns = useMemo(() => {
    return designs
      .filter((design) => {
        // Category filter
        if (selectedCategory !== 'all' && design.category_id !== selectedCategory) {
          return false;
        }

        // Tailor filter
        if (selectedTailorId && design.tailor_id !== selectedTailorId) {
          return false;
        }

        // Search query (tag, price, tailor name)
        if (searchQuery.trim()) {
          const q = searchQuery.toLowerCase().trim();
          const matchTag = design.tag ? design.tag.toLowerCase().includes(q) : false;
          const matchPrice = design.price.toString().includes(q);
          const matchTailor = design.tailor?.shop_name
            ? design.tailor.shop_name.toLowerCase().includes(q)
            : false;
          return matchTag || matchPrice || matchTailor;
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
        if (sortBy === 'price_desc') {
          return Number(b.price) - Number(a.price);
        }
        if (sortBy === 'price_asc') {
          return Number(a.price) - Number(b.price);
        }
        return 0;
      });
  }, [designs, selectedCategory, selectedTailorId, searchQuery, sortBy]);

  return (
    <div className="space-y-6">
      {/* Controls & Filter Bar */}
      <div className="glass-panel p-5 rounded-2xl border border-slate-800/80 space-y-4 shadow-xl">
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-3">
          {/* Search */}
          <div className="relative">
            <Search className="w-4 h-4 absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400 pointer-events-none" />
            <input
              type="text"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              placeholder="Search tag, price, tailor..."
              className="w-full pl-10 pr-4 py-2 bg-surface-900/90 border border-slate-700/80 rounded-xl text-white placeholder-slate-500 text-xs focus:outline-none focus:ring-2 focus:ring-brand-500/50 focus:border-brand-500 transition"
            />
          </div>

          {/* Category Filter */}
          <div className="relative">
            <select
              value={selectedCategory}
              onChange={(e) => setSelectedCategory(e.target.value)}
              className="w-full px-3 py-2 bg-surface-900/90 border border-slate-700/80 rounded-xl text-slate-200 text-xs font-medium focus:outline-none focus:ring-2 focus:ring-brand-500/50 appearance-none cursor-pointer pr-8"
            >
              <option value="all">All Categories ({categories.length})</option>
              {categories.map((cat) => (
                <option key={cat.id} value={cat.id}>
                  {cat.name_en} ({cat.name_am})
                </option>
              ))}
            </select>
            <Filter className="w-3.5 h-3.5 absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 pointer-events-none" />
          </div>

          {/* Tailor Filter */}
          <div className="relative">
            <select
              value={selectedTailorId}
              onChange={(e) => setSelectedTailorId(e.target.value)}
              className="w-full px-3 py-2 bg-surface-900/90 border border-slate-700/80 rounded-xl text-slate-200 text-xs font-medium focus:outline-none focus:ring-2 focus:ring-brand-500/50 appearance-none cursor-pointer pr-8"
            >
              <option value="">All Tailors ({tailors.length})</option>
              {tailors.map((t) => (
                <option key={t.id} value={t.id}>
                  {t.shop_name}
                </option>
              ))}
            </select>
            <Store className="w-3.5 h-3.5 absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 pointer-events-none" />
          </div>

          {/* Sort By */}
          <div className="relative">
            <select
              value={sortBy}
              onChange={(e: any) => setSortBy(e.target.value)}
              className="w-full px-3 py-2 bg-surface-900/90 border border-slate-700/80 rounded-xl text-slate-200 text-xs font-medium focus:outline-none focus:ring-2 focus:ring-brand-500/50 appearance-none cursor-pointer pr-8"
            >
              <option value="newest">Sort: Newest First</option>
              <option value="oldest">Sort: Oldest First</option>
              <option value="price_desc">Sort: Price (High to Low)</option>
              <option value="price_asc">Sort: Price (Low to High)</option>
            </select>
            <ArrowUpDown className="w-3.5 h-3.5 absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 pointer-events-none" />
          </div>
        </div>

        {/* Active Filters summary */}
        <div className="flex items-center justify-between text-xs text-slate-400 pt-2 border-t border-slate-800/60">
          <span>
            Showing <strong className="text-white">{filteredDesigns.length}</strong> of{' '}
            <strong className="text-white">{designs.length}</strong> designs
          </span>

          {(selectedCategory !== 'all' || selectedTailorId || searchQuery) && (
            <button
              onClick={() => {
                setSelectedCategory('all');
                setSelectedTailorId('');
                setSearchQuery('');
              }}
              className="text-brand-400 hover:text-brand-300 font-medium transition"
            >
              Reset Filters
            </button>
          )}
        </div>
      </div>

      {/* Designs Grid */}
      {filteredDesigns.length === 0 ? (
        <div className="glass-panel rounded-2xl border border-slate-800/80 p-16 text-center shadow-xl">
          <ImageIcon className="w-12 h-12 text-slate-600 mx-auto mb-3" />
          <h3 className="text-base font-semibold text-slate-300">No designs match your criteria</h3>
          <p className="text-xs text-slate-500 mt-1 max-w-sm mx-auto">
            Try adjusting your category, tailor filter, or search query.
          </p>
        </div>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-6">
          {filteredDesigns.map((design) => {
            const firstPhoto = design.photos?.[0];
            const photoCount = design.photos?.length || 0;

            return (
              <div
                key={design.id}
                onClick={() => setSelectedDesign(design)}
                className="glass-panel rounded-2xl border border-slate-800/80 overflow-hidden group hover:border-brand-500/50 hover:shadow-2xl hover:shadow-brand-500/5 transition cursor-pointer flex flex-col justify-between"
              >
                {/* Image Cover */}
                <div className="relative aspect-[4/5] bg-surface-950 overflow-hidden">
                  {firstPhoto ? (
                    <img
                      src={getPhotoUrl(firstPhoto)}
                      alt={design.tag || 'Design'}
                      className="w-full h-full object-cover group-hover:scale-105 transition duration-300"
                    />
                  ) : (
                    <div className="w-full h-full flex flex-col items-center justify-center text-slate-600">
                      <ImageIcon className="w-8 h-8 mb-1 opacity-50" />
                      <span className="text-[11px]">No Photo</span>
                    </div>
                  )}

                  {/* Photo count indicator */}
                  {photoCount > 1 && (
                    <div className="absolute top-3 right-3 px-2 py-0.5 rounded-full bg-black/70 backdrop-blur-sm text-white text-[11px] font-semibold border border-white/10 flex items-center gap-1">
                      <Layers className="w-3 h-3" />
                      <span>{photoCount}</span>
                    </div>
                  )}

                  {/* Category Pill */}
                  <div className="absolute bottom-3 left-3 px-2.5 py-1 rounded-xl bg-black/75 backdrop-blur-md text-brand-300 border border-brand-500/20 text-xs font-semibold">
                    {design.category?.name_en || 'Design'}
                  </div>
                </div>

                {/* Card Content */}
                <div className="p-4 space-y-3 flex-1 flex flex-col justify-between">
                  <div className="space-y-1">
                    <div className="flex items-center justify-between gap-2">
                      <span className="text-lg font-bold text-white tracking-tight">
                        {Number(design.price).toLocaleString()} ETB
                      </span>
                      {design.tag && (
                        <span className="inline-flex items-center gap-1 text-[11px] px-2 py-0.5 rounded-md bg-surface-900 text-slate-300 border border-slate-700/60 truncate max-w-[110px]">
                          <TagIcon className="w-3 h-3 text-brand-400 flex-shrink-0" />
                          <span className="truncate">{design.tag}</span>
                        </span>
                      )}
                    </div>

                    <div className="flex items-center gap-1.5 text-xs text-slate-400">
                      <Store className="w-3.5 h-3.5 text-brand-400 flex-shrink-0" />
                      <span className="truncate font-medium">
                        {design.tailor?.shop_name || 'Tailor'}
                      </span>
                    </div>
                  </div>

                  {/* Actions */}
                  <div className="pt-2 border-t border-slate-800/80 flex items-center justify-between gap-2">
                    <button
                      onClick={(e) => {
                        e.stopPropagation();
                        setSelectedDesign(design);
                      }}
                      className="inline-flex items-center gap-1 text-xs text-slate-300 hover:text-white px-2.5 py-1.5 rounded-lg bg-surface-900 hover:bg-slate-800 transition"
                    >
                      <Eye className="w-3.5 h-3.5" />
                      <span>Inspect</span>
                    </button>

                    <button
                      id={`delete-design-${design.id}`}
                      onClick={(e) => handleQuickDelete(e, design.id)}
                      disabled={deletingId === design.id}
                      className="p-1.5 rounded-lg text-slate-400 hover:text-rose-400 hover:bg-rose-500/10 transition disabled:opacity-50"
                      title="Delete design"
                    >
                      {deletingId === design.id ? (
                        <Loader2 className="w-4 h-4 animate-spin text-rose-400" />
                      ) : (
                        <Trash2 className="w-4 h-4" />
                      )}
                    </button>
                  </div>
                </div>
              </div>
            );
          })}
        </div>
      )}

      {/* Modal Detail View */}
      <DesignDetailModal
        design={selectedDesign}
        isOpen={!!selectedDesign}
        onClose={() => setSelectedDesign(null)}
        onDeleted={handleDesignDeleted}
      />
    </div>
  );
}
