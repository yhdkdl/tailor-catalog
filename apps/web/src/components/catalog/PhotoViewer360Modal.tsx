'use client';

import React, { useState, useEffect, useRef, useCallback } from 'react';
import { useLanguage } from '@/lib/i18n/LanguageContext';
import { CatalogDesign } from './types';
import { getHighRes360PhotoUrl } from '@/lib/cloudinary';
import {
  X,
  ChevronLeft,
  ChevronRight,
  ZoomIn,
  ZoomOut,
  RotateCcw,
  Sparkles,
} from 'lucide-react';

interface PhotoViewer360ModalProps {
  design: CatalogDesign | null;
  isOpen: boolean;
  onClose: () => void;
}

export function PhotoViewer360Modal({
  design,
  isOpen,
  onClose,
}: PhotoViewer360ModalProps) {
  const { t } = useLanguage();
  const [currentIndex, setCurrentIndex] = useState(0);
  const [scale, setScale] = useState(1);
  const [pan, setPan] = useState({ x: 0, y: 0 });
  const [imageLoaded, setImageLoaded] = useState(false);

  // Touch tracking for swipe & pinch
  const touchStartRef = useRef<{ x: number; y: number } | null>(null);
  const touchDistanceRef = useRef<number | null>(null);
  const lastTapRef = useRef<number>(0);
  const isDraggingRef = useRef(false);
  const panStartRef = useRef<{ x: number; y: number }>({ x: 0, y: 0 });

  const photos = design?.photos || [];
  const isMultiPhoto = photos.length > 1;
  const currentPhoto = photos[currentIndex] || photos[0];
  const highResUrl = currentPhoto ? getHighRes360PhotoUrl(currentPhoto) : '';

  // Reset state when modal opens or design changes
  useEffect(() => {
    if (isOpen) {
      setCurrentIndex(0);
      setScale(1);
      setPan({ x: 0, y: 0 });
      setImageLoaded(false);
    }
  }, [isOpen, design?.id]);

  // Preload neighboring images for smooth transitions
  useEffect(() => {
    if (!isOpen || !photos.length) return;

    const nextIndex = (currentIndex + 1) % photos.length;
    const prevIndex = (currentIndex - 1 + photos.length) % photos.length;

    const preloadUrls = [
      getHighRes360PhotoUrl(photos[nextIndex]),
      getHighRes360PhotoUrl(photos[prevIndex]),
    ];

    preloadUrls.forEach((url) => {
      if (url) {
        const img = new Image();
        img.src = url;
      }
    });
  }, [isOpen, currentIndex, photos]);

  const goToNext = useCallback(() => {
    if (!isMultiPhoto) return;
    setScale(1);
    setPan({ x: 0, y: 0 });
    setImageLoaded(false);
    setCurrentIndex((prev) => (prev + 1) % photos.length);
  }, [isMultiPhoto, photos.length]);

  const goToPrev = useCallback(() => {
    if (!isMultiPhoto) return;
    setScale(1);
    setPan({ x: 0, y: 0 });
    setImageLoaded(false);
    setCurrentIndex((prev) => (prev - 1 + photos.length) % photos.length);
  }, [isMultiPhoto, photos.length]);

  // Keyboard navigation
  useEffect(() => {
    if (!isOpen) return;

    function handleKeyDown(e: KeyboardEvent) {
      if (e.key === 'Escape') {
        onClose();
      } else if (e.key === 'ArrowRight') {
        goToNext();
      } else if (e.key === 'ArrowLeft') {
        goToPrev();
      }
    }

    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [isOpen, goToNext, goToPrev, onClose]);

  // Handle double tap to zoom
  const handleDoubleTap = (clientX: number, clientY: number) => {
    if (scale > 1) {
      setScale(1);
      setPan({ x: 0, y: 0 });
    } else {
      setScale(2.2);
    }
  };

  // Touch handlers
  const handleTouchStart = (e: React.TouchEvent) => {
    if (e.touches.length === 1) {
      const touch = e.touches[0];
      touchStartRef.current = { x: touch.clientX, y: touch.clientY };
      panStartRef.current = { x: pan.x, y: pan.y };
      isDraggingRef.current = true;

      // Check for double tap
      const now = Date.now();
      if (now - lastTapRef.current < 300) {
        handleDoubleTap(touch.clientX, touch.clientY);
        lastTapRef.current = 0;
      } else {
        lastTapRef.current = now;
      }
    } else if (e.touches.length === 2) {
      // Pinch gesture start
      const touch1 = e.touches[0];
      const touch2 = e.touches[1];
      const distance = Math.hypot(
        touch2.clientX - touch1.clientX,
        touch2.clientY - touch1.clientY
      );
      touchDistanceRef.current = distance;
    }
  };

  const handleTouchMove = (e: React.TouchEvent) => {
    if (e.touches.length === 2 && touchDistanceRef.current !== null) {
      // Pinch to zoom
      const touch1 = e.touches[0];
      const touch2 = e.touches[1];
      const newDistance = Math.hypot(
        touch2.clientX - touch1.clientX,
        touch2.clientY - touch1.clientY
      );
      const factor = newDistance / touchDistanceRef.current;
      setScale((prev) => Math.min(Math.max(prev * factor, 1), 3.5));
      touchDistanceRef.current = newDistance;
    } else if (e.touches.length === 1 && touchStartRef.current && isDraggingRef.current) {
      const touch = e.touches[0];
      const deltaX = touch.clientX - touchStartRef.current.x;
      const deltaY = touch.clientY - touchStartRef.current.y;

      if (scale > 1) {
        // Pan image when zoomed
        setPan({
          x: panStartRef.current.x + deltaX,
          y: panStartRef.current.y + deltaY,
        });
      }
    }
  };

  const handleTouchEnd = (e: React.TouchEvent) => {
    touchDistanceRef.current = null;

    if (e.touches.length === 0 && touchStartRef.current && scale === 1) {
      const touch = e.changedTouches[0];
      const deltaX = touch.clientX - touchStartRef.current.x;
      const deltaY = touch.clientY - touchStartRef.current.y;
      const minSwipeDistance = 45;

      // Only swipe if horizontal movement is dominant
      if (
        Math.abs(deltaX) > minSwipeDistance &&
        Math.abs(deltaX) > Math.abs(deltaY) * 1.5 &&
        isMultiPhoto
      ) {
        if (deltaX < 0) {
          goToNext();
        } else {
          goToPrev();
        }
      }
    }

    touchStartRef.current = null;
    isDraggingRef.current = false;
  };

  if (!isOpen || !design) return null;

  return (
    <div
      role="dialog"
      aria-modal="true"
      aria-label={t('viewer360.title')}
      className="fixed inset-0 z-50 bg-black text-white flex flex-col justify-between select-none animate-in fade-in duration-200"
    >
      {/* Top Bar Controls */}
      <header className="relative z-20 flex items-center justify-between p-4 sm:p-6 bg-gradient-to-b from-black/80 to-transparent">
        {/* Close Button Top Left */}
        <button
          onClick={onClose}
          className="p-3 rounded-full bg-white/10 hover:bg-white/20 active:bg-white/30 backdrop-blur-md text-white transition duration-150 border border-white/10 flex items-center gap-2 group"
          aria-label={t('viewer360.close')}
        >
          <X className="w-5 h-5 group-hover:scale-110 transition-transform" />
          <span className="text-xs font-semibold pr-1 hidden sm:inline">
            {t('viewer360.close')}
          </span>
        </button>

        {/* Center Title Badge */}
        <div className="flex items-center gap-2 px-4 py-1.5 rounded-full bg-white/10 backdrop-blur-md border border-white/10">
          <Sparkles className="w-3.5 h-3.5 text-brand-400" />
          <span className="text-xs font-semibold tracking-wide text-brand-300">
            {t('design.view_360')}
          </span>
        </div>

        {/* Top Right Counter & Zoom Indicator */}
        <div className="flex items-center gap-2">
          {scale > 1 && (
            <button
              onClick={() => {
                setScale(1);
                setPan({ x: 0, y: 0 });
              }}
              className="p-2.5 rounded-full bg-brand-500/20 text-brand-300 hover:bg-brand-500/30 border border-brand-500/30 text-xs font-medium flex items-center gap-1.5 transition"
              title="Reset Zoom"
            >
              <RotateCcw className="w-3.5 h-3.5" />
              <span className="hidden sm:inline">1x</span>
            </button>
          )}

          {isMultiPhoto && (
            <div className="px-3.5 py-1.5 rounded-full bg-white/10 backdrop-blur-md text-xs font-bold tracking-wider border border-white/10">
              {currentIndex + 1} / {photos.length}
            </div>
          )}
        </div>
      </header>

      {/* Main Full-Screen Photo Display Area */}
      <main
        className="relative flex-1 flex items-center justify-center overflow-hidden touch-none"
        onTouchStart={handleTouchStart}
        onTouchMove={handleTouchMove}
        onTouchEnd={handleTouchEnd}
        onDoubleClick={(e) => handleDoubleTap(e.clientX, e.clientY)}
      >
        {/* Loading Spinner */}
        {!imageLoaded && (
          <div className="absolute inset-0 flex items-center justify-center">
            <div className="w-10 h-10 rounded-full border-2 border-brand-500/30 border-t-brand-500 animate-spin" />
          </div>
        )}

        {/* High Resolution Photo */}
        {highResUrl ? (
          <img
            key={highResUrl}
            src={highResUrl}
            alt={design.tag || 'Design photo'}
            onLoad={() => setImageLoaded(true)}
            style={{
              transform: `translate3d(${pan.x}px, ${pan.y}px, 0) scale(${scale})`,
              transition: isDraggingRef.current ? 'none' : 'transform 200ms ease-out',
              maxWidth: '100vw',
              maxHeight: '85vh',
            }}
            className={`object-contain select-none transition-opacity duration-300 ${
              imageLoaded ? 'opacity-100' : 'opacity-0'
            }`}
            draggable={false}
          />
        ) : (
          <div className="text-center text-slate-500">
            <p className="text-sm">Photo unavailable</p>
          </div>
        )}

        {/* Desktop Left / Right Arrow Buttons */}
        {isMultiPhoto && (
          <>
            <button
              onClick={(e) => {
                e.stopPropagation();
                goToPrev();
              }}
              className="absolute left-4 top-1/2 -translate-y-1/2 p-3.5 rounded-full bg-black/60 hover:bg-black/85 text-white backdrop-blur-md border border-white/15 transition shadow-2xl hover:scale-105 active:scale-95 hidden sm:flex items-center justify-center z-20"
              aria-label={t('viewer360.prev')}
            >
              <ChevronLeft className="w-6 h-6" />
            </button>

            <button
              onClick={(e) => {
                e.stopPropagation();
                goToNext();
              }}
              className="absolute right-4 top-1/2 -translate-y-1/2 p-3.5 rounded-full bg-black/60 hover:bg-black/85 text-white backdrop-blur-md border border-white/15 transition shadow-2xl hover:scale-105 active:scale-95 hidden sm:flex items-center justify-center z-20"
              aria-label={t('viewer360.next')}
            >
              <ChevronRight className="w-6 h-6" />
            </button>
          </>
        )}
      </main>

      {/* Bottom Bar: Dot Indicators & Zoom Controls */}
      <footer className="relative z-20 p-4 sm:p-6 bg-gradient-to-t from-black/90 via-black/50 to-transparent flex flex-col items-center gap-3">
        {/* Dot Indicators for Multi-Photo Designs */}
        {isMultiPhoto && (
          <div className="flex items-center justify-center gap-2 py-1 px-3 rounded-full bg-black/40 backdrop-blur-md border border-white/10">
            {photos.map((photo, index) => {
              const isActive = currentIndex === index;
              return (
                <button
                  key={photo.id || index}
                  onClick={() => {
                    setScale(1);
                    setPan({ x: 0, y: 0 });
                    setImageLoaded(false);
                    setCurrentIndex(index);
                  }}
                  className={`transition-all duration-200 rounded-full ${
                    isActive
                      ? 'w-6 h-2 bg-brand-400 shadow-md shadow-brand-500/50'
                      : 'w-2 h-2 bg-white/40 hover:bg-white/70'
                  }`}
                  aria-label={`Go to photo ${index + 1}`}
                />
              );
            })}
          </div>
        )}

        {/* Zoom Hint Text */}
        <div className="flex items-center gap-3 text-[11px] text-slate-400">
          <span>{t('viewer360.zoom_hint')}</span>
          <div className="flex items-center gap-1">
            <button
              onClick={() => setScale((prev) => Math.min(prev + 0.5, 3.5))}
              className="p-1.5 rounded-lg bg-white/10 hover:bg-white/20 transition text-white"
              title="Zoom In"
              aria-label="Zoom in"
            >
              <ZoomIn className="w-3.5 h-3.5" />
            </button>
            <button
              onClick={() => {
                setScale((prev) => {
                  const next = Math.max(prev - 0.5, 1);
                  if (next === 1) setPan({ x: 0, y: 0 });
                  return next;
                });
              }}
              className="p-1.5 rounded-lg bg-white/10 hover:bg-white/20 transition text-white"
              title="Zoom Out"
              aria-label="Zoom out"
            >
              <ZoomOut className="w-3.5 h-3.5" />
            </button>
          </div>
        </div>
      </footer>
    </div>
  );
}
