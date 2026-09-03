'use client';

import React, { useState } from 'react';
import { useLanguage } from '@/lib/i18n/LanguageContext';
import { useFavorites } from '@/lib/favorites/FavoritesContext';
import { CatalogDesign } from './types';
import { getThumbnailUrl } from '@/lib/cloudinary';
import { Layers, Tag, Eye, Sparkles, Heart, Flame, Store } from 'lucide-react';

interface DesignCardProps {
  design: CatalogDesign;
  onInspect: (design: CatalogDesign) => void;
  onView360: (design: CatalogDesign) => void;
  shopName?: string;
  shopSlug?: string;
}

export function DesignCard({
  design,
  onInspect,
  onView360,
  shopName,
  shopSlug,
}: DesignCardProps) {
  const { t, getCategoryName } = useLanguage();
  const { isFavorite, toggleFavorite } = useFavorites();
  const [imageLoaded, setImageLoaded] = useState(false);

  const firstPhoto = design.photos?.[0];
  const photoCount = design.photos?.length || 0;
  const thumbnailUrl = getThumbnailUrl(firstPhoto);
  const categoryName = getCategoryName(design.category);
  const favorited = isFavorite(design.id);

  const handleFavoriteClick = (e: React.MouseEvent) => {
    e.stopPropagation();
    toggleFavorite({
      id: design.id,
      cloudinary_url: thumbnailUrl || firstPhoto?.cloudinary_url || '',
      cloudinary_public_id: firstPhoto?.cloudinary_public_id ?? undefined,
      category: categoryName || 'Handcrafted Attire',
      category_id: design.category_id,
      tag: design.tag,
      shop_name: shopName || 'Tailor Shop',
      shop_slug: shopSlug || '',
      photos: design.photos,
      is_grouped: design.is_grouped,
      is_trending: design.is_trending,
    });
  };

  return (
    <div
      onClick={() => onInspect(design)}
      className="glass-panel group rounded-2xl sm:rounded-3xl border border-slate-800/80 hover:border-brand-500/50 bg-surface-900/60 hover:bg-surface-900/90 overflow-hidden shadow-lg hover:shadow-2xl hover:shadow-brand-500/5 transition-all duration-300 flex flex-col justify-between cursor-pointer"
    >
      {/* Image Container with Fixed Responsive Heights */}
      <div className="relative h-[180px] sm:h-[160px] w-full bg-surface-950 overflow-hidden">
        {/* Skeleton loader */}
        {!imageLoaded && (
          <div className="absolute inset-0 bg-slate-900 animate-pulse flex items-center justify-center">
            <div className="w-6 h-6 rounded-full border-2 border-brand-500/30 border-t-brand-500 animate-spin" />
          </div>
        )}

        {thumbnailUrl ? (
          <img
            src={thumbnailUrl}
            alt={design.tag || categoryName || 'Handcrafted Design'}
            loading="lazy"
            onLoad={() => setImageLoaded(true)}
            className={`w-full h-full object-cover group-hover:scale-105 transition-transform duration-500 ease-out ${
              imageLoaded ? 'opacity-100' : 'opacity-0'
            }`}
          />
        ) : (
          <div className="w-full h-full flex items-center justify-center text-slate-600">
            <span className="text-[10px]">No Photo</span>
          </div>
        )}

        {/* Top Badges */}
        <div className="absolute top-2 left-2 flex items-center gap-1.5 z-10">
          {/* Trending Flame Badge */}
          {design.is_trending && (
            <div className="px-2 py-0.5 rounded-full bg-amber-500/90 text-black text-[10px] font-extrabold flex items-center gap-0.5 shadow-lg shadow-amber-500/20 backdrop-blur-md">
              <Flame className="w-3 h-3 fill-black text-black" />
              <span className="hidden sm:inline">HOT</span>
            </div>
          )}

          {/* Multi-Photo Indicator */}
          {photoCount > 1 && (
            <div className="px-2 py-0.5 rounded-full bg-black/75 backdrop-blur-md text-white text-[10px] font-semibold border border-white/10 flex items-center gap-1 shadow-lg">
              <Layers className="w-2.5 h-2.5 text-brand-400" />
              <span>{photoCount}</span>
            </div>
          )}
        </div>

        {/* Favorite Button (Heart) Top Right */}
        <button
          onClick={handleFavoriteClick}
          className={`absolute top-2 right-2 p-1.5 sm:p-2 rounded-full backdrop-blur-md border transition shadow-lg z-10 active:scale-90 ${
            favorited
              ? 'bg-black/80 border-amber-400/60 text-amber-400'
              : 'bg-black/60 border-white/10 text-white/80 hover:text-white hover:bg-black/80'
          }`}
          aria-label={favorited ? 'Remove from favorites' : 'Save to favorites'}
        >
          <Heart
            className={`w-4 h-4 transition-colors ${
              favorited ? 'fill-amber-400 text-amber-400' : ''
            }`}
          />
        </button>

        {/* Category Pill at Bottom of Image */}
        {categoryName && (
          <div className="absolute bottom-2 left-2 px-2 py-0.5 rounded-lg bg-black/80 backdrop-blur-md text-brand-300 border border-brand-500/30 text-[10px] font-semibold shadow-lg max-w-[85%] truncate">
            {categoryName}
          </div>
        )}
      </div>

      {/* Card Content & Action Bar */}
      <div className="p-2.5 sm:p-3 space-y-2 flex-1 flex flex-col justify-between">
        <div className="space-y-1">
          {/* Shop Name (for Marketplace) */}
          {shopName && (
            <div className="flex items-center gap-1 text-[11px] text-slate-400 font-medium truncate">
              <Store className="w-3 h-3 text-brand-400 flex-shrink-0" />
              <span className="truncate">{shopName}</span>
            </div>
          )}

          {/* Optional Tag */}
          {design.tag ? (
            <div className="inline-flex items-center gap-1 text-[10px] px-2 py-0.5 rounded-md bg-surface-950 text-slate-300 border border-slate-700/60 truncate max-w-full">
              <Tag className="w-2.5 h-2.5 text-brand-400 flex-shrink-0" />
              <span className="truncate">{design.tag}</span>
            </div>
          ) : (
            <div className="text-[11px] text-slate-500 italic truncate">
              {categoryName}
            </div>
          )}
        </div>

        {/* Bottom Actions */}
        <div className="pt-2 border-t border-slate-800/80 grid grid-cols-2 gap-1.5">
          <button
            onClick={(e) => {
              e.stopPropagation();
              onInspect(design);
            }}
            className="py-1.5 px-2 rounded-xl bg-surface-950 hover:bg-slate-800 border border-slate-700/80 text-slate-300 hover:text-white text-[11px] font-semibold flex items-center justify-center gap-1 transition"
          >
            <Eye className="w-3 h-3 text-slate-400" />
            <span className="truncate">{t('design.view_details')}</span>
          </button>

          <button
            onClick={(e) => {
              e.stopPropagation();
              onView360(design);
            }}
            className="py-1.5 px-2 rounded-xl bg-brand-500/15 hover:bg-brand-500 text-brand-300 hover:text-surface-950 border border-brand-500/30 text-[11px] font-bold flex items-center justify-center gap-1 transition shadow-sm"
          >
            <Sparkles className="w-3 h-3" />
            <span className="truncate">{t('design.view_360')}</span>
          </button>
        </div>
      </div>
    </div>
  );
}
