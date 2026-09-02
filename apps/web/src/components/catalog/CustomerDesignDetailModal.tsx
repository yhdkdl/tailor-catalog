'use client';

import React, { useState, useEffect, useRef } from 'react';
import { useLanguage } from '@/lib/i18n/LanguageContext';
import { CatalogDesign, CatalogTailor } from './types';
import { getFullPhotoUrl, getThumbnailUrl } from '@/lib/cloudinary';
import {
  X,
  ChevronLeft,
  ChevronRight,
  Layers,
  Tag,
  Store,
  Sparkles,
  Shirt,
} from 'lucide-react';

interface CustomerDesignDetailModalProps {
  design: CatalogDesign | null;
  tailor: CatalogTailor;
  isOpen: boolean;
  onClose: () => void;
  onView360: (design: CatalogDesign) => void;
}

export function CustomerDesignDetailModal({
  design,
  tailor,
  isOpen,
  onClose,
  onView360,
}: CustomerDesignDetailModalProps) {
  const { t, getCategoryName } = useLanguage();
  const [activePhotoIndex, setActivePhotoIndex] = useState(0);
  const [imageLoaded, setImageLoaded] = useState(false);

  // Touch swipe support
  const touchStartX = useRef<number | null>(null);
  const touchEndX = useRef<number | null>(null);

  // Reset active photo index when design changes
  useEffect(() => {
    setActivePhotoIndex(0);
    setImageLoaded(false);
  }, [design?.id]);

  // Keyboard navigation (Esc to close, Left/Right arrows for carousel)
  useEffect(() => {
    if (!isOpen) return;

    function handleKeyDown(e: KeyboardEvent) {
      if (e.key === 'Escape') {
        onClose();
      } else if (e.key === 'ArrowLeft' && design && design.photos.length > 1) {
        setActivePhotoIndex((prev) => (prev > 0 ? prev - 1 : design.photos.length - 1));
        setImageLoaded(false);
      } else if (e.key === 'ArrowRight' && design && design.photos.length > 1) {
        setActivePhotoIndex((prev) => (prev < design.photos.length - 1 ? prev + 1 : 0));
        setImageLoaded(false);
      }
    }

    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [isOpen, design, onClose]);

  if (!isOpen || !design) return null;

  const photos = design.photos || [];
  const currentPhoto = photos[activePhotoIndex] || photos[0];
  const fullPhotoUrl = getFullPhotoUrl(currentPhoto);
  const categoryName = getCategoryName(design.category);

  // Swipe handlers
  const handleTouchStart = (e: React.TouchEvent) => {
    touchStartX.current = e.targetTouches[0].clientX;
  };

  const handleTouchMove = (e: React.TouchEvent) => {
    touchEndX.current = e.targetTouches[0].clientX;
  };

  const handleTouchEnd = () => {
    if (!touchStartX.current || !touchEndX.current) return;
    const distance = touchStartX.current - touchEndX.current;
    const minSwipeDistance = 45;

    if (distance > minSwipeDistance && photos.length > 1) {
      // Swiped left -> next photo
      setActivePhotoIndex((prev) => (prev < photos.length - 1 ? prev + 1 : 0));
      setImageLoaded(false);
    } else if (distance < -minSwipeDistance && photos.length > 1) {
      // Swiped right -> prev photo
      setActivePhotoIndex((prev) => (prev > 0 ? prev - 1 : photos.length - 1));
      setImageLoaded(false);
    }

    touchStartX.current = null;
    touchEndX.current = null;
  };

  return (
    <div
      role="dialog"
      aria-modal="true"
      className="fixed inset-0 z-50 flex items-end sm:items-center justify-center sm:p-4 bg-black/85 backdrop-blur-md animate-in fade-in duration-200"
      onClick={onClose}
    >
      <div
        className="glass-panel w-full max-w-4xl max-h-[92vh] sm:rounded-3xl rounded-t-3xl border border-slate-800 shadow-2xl overflow-hidden flex flex-col md:flex-row bg-surface-950/98 relative"
        onClick={(e) => e.stopPropagation()}
      >
        {/* Mobile top drag indicator / close */}
        <div className="sm:hidden flex items-center justify-between p-3 border-b border-slate-800/80">
          <div className="w-10 h-1 rounded-full bg-slate-700 mx-auto" />
          <button
            onClick={onClose}
            className="absolute right-3 top-3 p-1.5 rounded-full bg-slate-800 text-slate-300 hover:text-white"
            aria-label="Close modal"
          >
            <X className="w-4 h-4" />
          </button>
        </div>

        {/* Left: Photo Carousel */}
        <div
          className="md:w-1/2 bg-surface-950 p-4 sm:p-6 flex flex-col justify-between relative border-b md:border-b-0 md:border-r border-slate-800/80"
          onTouchStart={handleTouchStart}
          onTouchMove={handleTouchMove}
          onTouchEnd={handleTouchEnd}
        >
          {/* Main Photo Container */}
          <div className="relative w-full aspect-[3/4] rounded-2xl overflow-hidden bg-surface-900 border border-slate-800/80 flex items-center justify-center">
            {!imageLoaded && (
              <div className="absolute inset-0 bg-slate-900 animate-pulse flex items-center justify-center">
                <div className="w-8 h-8 rounded-full border-2 border-brand-500/30 border-t-brand-500 animate-spin" />
              </div>
            )}

            {fullPhotoUrl ? (
              <img
                src={fullPhotoUrl}
                alt={design.tag || categoryName || 'Design Photo'}
                onLoad={() => setImageLoaded(true)}
                className={`w-full h-full object-cover select-none transition-opacity duration-300 ${
                  imageLoaded ? 'opacity-100' : 'opacity-0'
                }`}
              />
            ) : (
              <div className="text-center p-6 text-slate-500">
                <Shirt className="w-12 h-12 mx-auto mb-2 opacity-50" />
                <p className="text-xs">No Photo Available</p>
              </div>
            )}

            {/* Photo Counter Badge */}
            {photos.length > 1 && (
              <div className="absolute bottom-3 right-3 px-3 py-1 rounded-full bg-black/75 backdrop-blur-md text-white text-xs font-semibold border border-white/10 shadow-lg">
                {activePhotoIndex + 1} / {photos.length}
              </div>
            )}

            {/* Category Pill */}
            {categoryName && (
              <div className="absolute top-3 left-3 px-3 py-1 rounded-xl bg-black/75 backdrop-blur-md text-brand-300 border border-brand-500/30 text-xs font-semibold shadow-lg">
                {categoryName}
              </div>
            )}

            {/* Carousel Navigation Arrows */}
            {photos.length > 1 && (
              <>
                <button
                  onClick={(e) => {
                    e.stopPropagation();
                    setActivePhotoIndex((prev) =>
                      prev > 0 ? prev - 1 : photos.length - 1
                    );
                    setImageLoaded(false);
                  }}
                  className="absolute left-2.5 top-1/2 -translate-y-1/2 p-2 rounded-full bg-black/60 hover:bg-black/80 text-white backdrop-blur-sm border border-white/10 transition shadow-lg"
                  aria-label="Previous photo"
                >
                  <ChevronLeft className="w-5 h-5" />
                </button>
                <button
                  onClick={(e) => {
                    e.stopPropagation();
                    setActivePhotoIndex((prev) =>
                      prev < photos.length - 1 ? prev + 1 : 0
                    );
                    setImageLoaded(false);
                  }}
                  className="absolute right-2.5 top-1/2 -translate-y-1/2 p-2 rounded-full bg-black/60 hover:bg-black/80 text-white backdrop-blur-sm border border-white/10 transition shadow-lg"
                  aria-label="Next photo"
                >
                  <ChevronRight className="w-5 h-5" />
                </button>
              </>
            )}
          </div>

          {/* Thumbnail Strip */}
          {photos.length > 1 && (
            <div className="flex items-center gap-2 mt-4 overflow-x-auto pb-1 scrollbar-none">
              {photos.map((photo, index) => {
                const thumb = getThumbnailUrl(photo);
                const isSelected = activePhotoIndex === index;

                return (
                  <button
                    key={photo.id || index}
                    onClick={() => {
                      setActivePhotoIndex(index);
                      setImageLoaded(false);
                    }}
                    className={`relative w-14 h-14 rounded-xl overflow-hidden flex-shrink-0 border-2 transition-all duration-150 ${
                      isSelected
                        ? 'border-brand-400 ring-2 ring-brand-500/30 scale-105'
                        : 'border-transparent opacity-60 hover:opacity-100'
                    }`}
                  >
                    {thumb ? (
                      <img
                        src={thumb}
                        alt={`Photo ${index + 1}`}
                        className="w-full h-full object-cover"
                      />
                    ) : (
                      <div className="w-full h-full bg-slate-800" />
                    )}
                  </button>
                );
              })}
            </div>
          )}
        </div>

        {/* Right: Design Details & Actions */}
        <div className="md:w-1/2 p-6 sm:p-8 flex flex-col justify-between overflow-y-auto space-y-6">
          {/* Header */}
          <div className="space-y-4">
            <div className="flex items-start justify-between gap-4">
              <div className="space-y-1">
                <span className="text-xs font-semibold px-2.5 py-1 rounded-full bg-brand-500/15 text-brand-300 border border-brand-500/30">
                  {categoryName || t('design.category')}
                </span>
                <h3 className="text-2xl sm:text-3xl font-bold text-white tracking-tight mt-1">
                  {t('catalog.currency', { price: Number(design.price).toLocaleString() })}
                </h3>
              </div>

              <button
                onClick={onClose}
                className="hidden sm:inline-flex p-2 rounded-xl text-slate-400 hover:text-white hover:bg-slate-800/80 transition"
                aria-label="Close modal"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            {/* Tag Badge */}
            {design.tag && (
              <div className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-xl bg-surface-900 border border-slate-700/80 text-xs font-medium text-slate-200 shadow-sm">
                <Tag className="w-3.5 h-3.5 text-brand-400" />
                <span>{design.tag}</span>
              </div>
            )}
          </div>

          {/* Details List */}
          <div className="space-y-3.5 text-xs">
            {/* Tailor Info */}
            <div className="p-3.5 rounded-2xl bg-surface-900/80 border border-slate-800/80 space-y-1 shadow-inner">
              <div className="flex items-center gap-1.5 text-slate-400 font-medium uppercase tracking-wider text-[10px]">
                <Store className="w-3.5 h-3.5 text-brand-400" />
                <span>Tailor Shop</span>
              </div>
              <p className="text-white font-bold text-sm">
                {tailor.shop_name}
              </p>
              <p className="text-[11px] text-slate-400 font-mono">
                /{tailor.shop_slug}
              </p>
            </div>

            {/* Format & Details */}
            <div className="grid grid-cols-2 gap-3 text-slate-400">
              <div className="p-3 rounded-2xl bg-surface-900/60 border border-slate-800/80">
                <span className="block text-slate-500 text-[10px] uppercase font-semibold">
                  {t('design.format')}
                </span>
                <span className="text-white font-medium text-xs mt-0.5 block">
                  {design.is_grouped
                    ? t('design.format_grouped')
                    : t('design.format_single')}
                </span>
              </div>

              <div className="p-3 rounded-2xl bg-surface-900/60 border border-slate-800/80">
                <span className="block text-slate-500 text-[10px] uppercase font-semibold">
                  {t('design.price')}
                </span>
                <span className="text-brand-300 font-bold text-xs mt-0.5 block">
                  {t('catalog.currency', { price: Number(design.price).toLocaleString() })}
                </span>
              </div>
            </div>
          </div>

          {/* Action Buttons */}
          <div className="pt-4 border-t border-slate-800/80 space-y-2">
            <button
              onClick={() => {
                onClose();
                onView360(design);
              }}
              className="w-full py-3.5 px-6 rounded-2xl bg-gradient-to-r from-brand-500 to-brand-600 hover:from-brand-400 hover:to-brand-500 text-surface-950 font-bold text-sm shadow-xl shadow-brand-500/20 transition duration-200 flex items-center justify-center gap-2 active:scale-[0.99]"
            >
              <Sparkles className="w-4 h-4" />
              <span>{t('design.view_360')}</span>
            </button>

            <button
              onClick={onClose}
              className="w-full py-2.5 px-4 rounded-xl bg-surface-900 hover:bg-surface-800 border border-slate-700/60 text-slate-300 hover:text-white text-xs font-semibold transition"
            >
              {t('design.close')}
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
