'use client';

import React, { useState } from 'react';
import { useLanguage } from '@/lib/i18n/LanguageContext';
import { CatalogDesign } from './types';
import { getThumbnailUrl } from '@/lib/cloudinary';
import { Layers, Tag, Eye, Sparkles } from 'lucide-react';

interface DesignCardProps {
  design: CatalogDesign;
  onInspect: (design: CatalogDesign) => void;
  onView360: (design: CatalogDesign) => void;
}

export function DesignCard({ design, onInspect, onView360 }: DesignCardProps) {
  const { t, getCategoryName } = useLanguage();
  const [imageLoaded, setImageLoaded] = useState(false);

  const firstPhoto = design.photos?.[0];
  const photoCount = design.photos?.length || 0;
  const thumbnailUrl = getThumbnailUrl(firstPhoto);
  const categoryName = getCategoryName(design.category);

  return (
    <div
      onClick={() => onInspect(design)}
      className="glass-panel group rounded-3xl border border-slate-800/80 hover:border-brand-500/50 bg-surface-900/60 hover:bg-surface-900/90 overflow-hidden shadow-xl hover:shadow-2xl hover:shadow-brand-500/5 transition-all duration-300 flex flex-col justify-between cursor-pointer"
    >
      {/* Image Container with Skeleton */}
      <div className="relative aspect-[3/4] bg-surface-950 overflow-hidden">
        {/* Skeleton loader */}
        {!imageLoaded && (
          <div className="absolute inset-0 bg-slate-900 animate-pulse flex items-center justify-center">
            <div className="w-8 h-8 rounded-full border-2 border-brand-500/30 border-t-brand-500 animate-spin" />
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
            <span className="text-xs">No Photo</span>
          </div>
        )}

        {/* Multi-Photo Indicator */}
        {photoCount > 1 && (
          <div className="absolute top-3 right-3 px-2.5 py-1 rounded-full bg-black/75 backdrop-blur-md text-white text-[11px] font-semibold border border-white/10 flex items-center gap-1.5 shadow-lg">
            <Layers className="w-3 h-3 text-brand-400" />
            <span>{t('catalog.photos_count', { count: photoCount })}</span>
          </div>
        )}

        {/* Category Pill */}
        {categoryName && (
          <div className="absolute bottom-3 left-3 px-3 py-1 rounded-xl bg-black/80 backdrop-blur-md text-brand-300 border border-brand-500/30 text-xs font-semibold shadow-lg">
            {categoryName}
          </div>
        )}
      </div>

      {/* Card Content & Action Bar */}
      <div className="p-4 space-y-3 flex-1 flex flex-col justify-between">
        <div className="space-y-1.5">
          <div className="flex items-center justify-between gap-2">
            <span className="text-lg font-bold text-white tracking-tight">
              {t('catalog.currency', { price: Number(design.price).toLocaleString() })}
            </span>

            {design.tag && (
              <span className="inline-flex items-center gap-1 text-[11px] px-2.5 py-0.5 rounded-lg bg-surface-950 text-slate-300 border border-slate-700/60 truncate max-w-[130px]">
                <Tag className="w-3 h-3 text-brand-400 flex-shrink-0" />
                <span className="truncate">{design.tag}</span>
              </span>
            )}
          </div>
        </div>

        {/* Bottom Actions */}
        <div className="pt-2 border-t border-slate-800/80 grid grid-cols-2 gap-2">
          <button
            onClick={(e) => {
              e.stopPropagation();
              onInspect(design);
            }}
            className="py-2 px-2.5 rounded-xl bg-surface-950 hover:bg-slate-800 border border-slate-700/80 text-slate-300 hover:text-white text-xs font-semibold flex items-center justify-center gap-1.5 transition"
          >
            <Eye className="w-3.5 h-3.5 text-slate-400" />
            <span className="truncate">{t('design.view_details')}</span>
          </button>

          <button
            onClick={(e) => {
              e.stopPropagation();
              onView360(design);
            }}
            className="py-2 px-2.5 rounded-xl bg-brand-500/15 hover:bg-brand-500 text-brand-300 hover:text-surface-950 border border-brand-500/30 text-xs font-bold flex items-center justify-center gap-1.5 transition shadow-sm"
          >
            <Sparkles className="w-3.5 h-3.5" />
            <span className="truncate">{t('design.view_360')}</span>
          </button>
        </div>
      </div>
    </div>
  );
}
