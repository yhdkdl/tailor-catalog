'use client';

import React, { useState, useEffect, useRef, useCallback } from 'react';
import { useLanguage } from '@/lib/i18n/LanguageContext';
import { CatalogDesign } from './types';
import { getFullPhotoUrl } from '@/lib/cloudinary';
import {
  X,
  Camera,
  RefreshCw,
  RotateCcw,
  Sliders,
  Sparkles,
  Download,
  AlertTriangle,
  Move,
  Maximize2,
  Eye,
  Check,
} from 'lucide-react';

interface TryOnModalProps {
  design: CatalogDesign | null;
  isOpen: boolean;
  onClose: () => void;
}

export function TryOnModal({ design, isOpen, onClose }: TryOnModalProps) {
  const { t } = useLanguage();

  const videoRef = useRef<HTMLVideoElement | null>(null);
  const streamRef = useRef<MediaStream | null>(null);
  const overlayRef = useRef<HTMLDivElement | null>(null);
  const containerRef = useRef<HTMLDivElement | null>(null);

  // Camera state
  const [facingMode, setFacingMode] = useState<'user' | 'environment'>('user');
  const [cameraActive, setCameraActive] = useState(false);
  const [cameraError, setCameraError] = useState<string | null>(null);

  // Overlay transform state
  const [position, setPosition] = useState<{ x: number; y: number }>({ x: 0, y: 0 });
  const [scale, setScale] = useState<number>(1.0);
  const [opacity, setOpacity] = useState<number>(0.88);
  const [isMirrored, setIsMirrored] = useState<boolean>(true);

  // Hint banner state (fades out after 3 seconds)
  const [showHint, setShowHint] = useState<boolean>(true);

  // Snapshot preview state
  const [snapshotUrl, setSnapshotUrl] = useState<string | null>(null);
  const [controlsExpanded, setControlsExpanded] = useState<boolean>(false);

  // Drag state tracking
  const isDragging = useRef(false);
  const dragStart = useRef<{ x: number; y: number }>({ x: 0, y: 0 });
  const startPos = useRef<{ x: number; y: number }>({ x: 0, y: 0 });

  // Pinch zoom tracking
  const initialPinchDistance = useRef<number | null>(null);
  const initialScale = useRef<number>(1.0);

  const photo = design?.photos?.[0];
  const photoUrl = getFullPhotoUrl(photo);

  // Start / Stop Camera Stream
  const startCamera = useCallback(async () => {
    if (streamRef.current) {
      streamRef.current.getTracks().forEach((track) => track.stop());
    }

    setCameraError(null);
    try {
      if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) {
        throw new Error('Camera not supported on this browser/device.');
      }

      const stream = await navigator.mediaDevices.getUserMedia({
        video: {
          facingMode: { ideal: facingMode },
          width: { ideal: 1280 },
          height: { ideal: 720 },
        },
        audio: false,
      });

      streamRef.current = stream;
      if (videoRef.current) {
        videoRef.current.srcObject = stream;
        await videoRef.current.play();
      }
      setCameraActive(true);
    } catch (err: any) {
      console.error('Camera stream error:', err);
      setCameraError(
        err.name === 'NotAllowedError' || err.name === 'PermissionDeniedError'
          ? t('tryon.camera_permission_desc')
          : t('tryon.camera_error')
      );
      setCameraActive(false);
    }
  }, [facingMode, t]);

  const stopCamera = useCallback(() => {
    if (streamRef.current) {
      streamRef.current.getTracks().forEach((track) => track.stop());
      streamRef.current = null;
    }
    setCameraActive(false);
  }, []);

  // Initialize camera and auto-dismiss hint on open
  useEffect(() => {
    if (isOpen && design) {
      setPosition({ x: 0, y: 0 });
      setScale(1.0);
      setOpacity(0.88);
      setShowHint(true);
      setSnapshotUrl(null);
      startCamera();

      const timer = setTimeout(() => {
        setShowHint(false);
      }, 3500);

      return () => {
        clearTimeout(timer);
        stopCamera();
      };
    } else {
      stopCamera();
    }
  }, [isOpen, design, facingMode, startCamera, stopCamera]);

  // Flip camera
  const handleFlipCamera = () => {
    setFacingMode((prev) => (prev === 'user' ? 'environment' : 'user'));
    setIsMirrored((prev) => !prev);
  };

  // Reset overlay
  const handleReset = () => {
    setPosition({ x: 0, y: 0 });
    setScale(1.0);
    setOpacity(0.88);
  };

  // -------------------------------------------------------------
  // Pointer / Touch Handlers (Drag & Pinch)
  // -------------------------------------------------------------
  const handleMouseDown = (e: React.MouseEvent) => {
    e.preventDefault();
    isDragging.current = true;
    dragStart.current = { x: e.clientX, y: e.clientY };
    startPos.current = { ...position };
  };

  const handleMouseMove = (e: React.MouseEvent) => {
    if (!isDragging.current) return;
    const deltaX = e.clientX - dragStart.current.x;
    const deltaY = e.clientY - dragStart.current.y;
    setPosition({
      x: startPos.current.x + deltaX,
      y: startPos.current.y + deltaY,
    });
  };

  const handleMouseUp = () => {
    isDragging.current = false;
  };

  // Touch Drag & Pinch
  const handleTouchStart = (e: React.TouchEvent) => {
    if (e.touches.length === 1) {
      isDragging.current = true;
      dragStart.current = { x: e.touches[0].clientX, y: e.touches[0].clientY };
      startPos.current = { ...position };
    } else if (e.touches.length === 2) {
      // 2-finger pinch
      isDragging.current = false;
      const dx = e.touches[0].clientX - e.touches[1].clientX;
      const dy = e.touches[0].clientY - e.touches[1].clientY;
      initialPinchDistance.current = Math.hypot(dx, dy);
      initialScale.current = scale;
    }
  };

  const handleTouchMove = (e: React.TouchEvent) => {
    if (e.touches.length === 1 && isDragging.current) {
      const deltaX = e.touches[0].clientX - dragStart.current.x;
      const deltaY = e.touches[0].clientY - dragStart.current.y;
      setPosition({
        x: startPos.current.x + deltaX,
        y: startPos.current.y + deltaY,
      });
    } else if (e.touches.length === 2 && initialPinchDistance.current) {
      const dx = e.touches[0].clientX - e.touches[1].clientX;
      const dy = e.touches[0].clientY - e.touches[1].clientY;
      const currentDistance = Math.hypot(dx, dy);
      const factor = currentDistance / initialPinchDistance.current;
      const newScale = Math.min(Math.max(initialScale.current * factor, 0.4), 2.5);
      setScale(newScale);
    }
  };

  const handleTouchEnd = () => {
    isDragging.current = false;
    initialPinchDistance.current = null;
  };

  // -------------------------------------------------------------
  // Take Snapshot
  // -------------------------------------------------------------
  const handleTakeSnapshot = () => {
    if (!videoRef.current || !overlayRef.current || !containerRef.current) return;

    const video = videoRef.current;
    const canvas = document.createElement('canvas');
    canvas.width = video.videoWidth || 1280;
    canvas.height = video.videoHeight || 720;
    const ctx = canvas.getContext('2d');
    if (!ctx) return;

    // Draw video frame
    if (isMirrored) {
      ctx.translate(canvas.width, 0);
      ctx.scale(-1, 1);
    }
    ctx.drawImage(video, 0, 0, canvas.width, canvas.height);

    // Reset transform for overlay
    ctx.setTransform(1, 0, 0, 1, 0, 0);

    // Draw outfit overlay
    const overlayImg = new Image();
    overlayImg.crossOrigin = 'anonymous';
    overlayImg.onload = () => {
      ctx.globalAlpha = opacity;
      const targetWidth = canvas.width * 0.5 * scale;
      const aspectRatio = overlayImg.height / overlayImg.width;
      const targetHeight = targetWidth * aspectRatio;

      const centerX = (canvas.width - targetWidth) / 2 + position.x * (canvas.width / window.innerWidth);
      const centerY = (canvas.height - targetHeight) / 2 + position.y * (canvas.height / window.innerHeight);

      ctx.drawImage(overlayImg, centerX, centerY, targetWidth, targetHeight);
      setSnapshotUrl(canvas.toDataURL('image/png'));
    };
    overlayImg.src = photoUrl;
  };

  if (!isOpen || !design) return null;

  return (
    <div
      role="dialog"
      aria-modal="true"
      className="fixed inset-0 z-50 flex items-center justify-center bg-black select-none overflow-hidden"
      onMouseMove={handleMouseMove}
      onMouseUp={handleMouseUp}
    >
      {/* Container holding camera feed & overlay */}
      <div
        ref={containerRef}
        className="relative w-full h-full flex items-center justify-center overflow-hidden"
        onTouchStart={handleTouchStart}
        onTouchMove={handleTouchMove}
        onTouchEnd={handleTouchEnd}
      >
        {/* Live Camera Video */}
        <video
          ref={videoRef}
          playsInline
          muted
          autoPlay
          className={`absolute inset-0 w-full h-full object-cover pointer-events-none transition-transform duration-300 ${
            isMirrored ? 'scale-x-[-1]' : ''
          }`}
        />

        {/* Camera Permission / Error Fallback */}
        {cameraError && (
          <div className="absolute inset-0 bg-surface-950/95 p-6 flex flex-col items-center justify-center text-center space-y-4 z-20">
            <div className="w-16 h-16 rounded-3xl bg-rose-500/15 border border-rose-500/30 text-rose-400 flex items-center justify-center">
              <AlertTriangle className="w-8 h-8" />
            </div>
            <div className="space-y-1 max-w-sm">
              <h3 className="text-lg font-bold text-white">
                {t('tryon.camera_permission')}
              </h3>
              <p className="text-xs text-slate-400">{cameraError}</p>
            </div>
            <button
              onClick={startCamera}
              className="px-5 py-2.5 rounded-xl bg-brand-500 hover:bg-brand-400 text-surface-950 font-bold text-xs shadow-lg transition"
            >
              {t('common.retry')}
            </button>
          </div>
        )}

        {/* Draggable & Resizable Outfit Overlay */}
        {photoUrl && !cameraError && (
          <div
            ref={overlayRef}
            onMouseDown={handleMouseDown}
            style={{
              transform: `translate(${position.x}px, ${position.y}px) scale(${scale})`,
              opacity,
              cursor: isDragging.current ? 'grabbing' : 'grab',
            }}
            className="absolute z-10 touch-none select-none max-w-[70vw] max-h-[70vh] flex items-center justify-center transition-opacity duration-150"
          >
            <img
              src={photoUrl}
              alt="Try on overlay"
              draggable={false}
              className="w-auto h-auto max-w-full max-h-[70vh] object-contain drop-shadow-2xl pointer-events-none select-none filter contrast-105"
            />
          </div>
        )}

        {/* Fading Hint Banner (auto-fades after 3 seconds) */}
        <div
          className={`absolute top-16 z-30 px-4 py-2 rounded-2xl bg-black/80 backdrop-blur-md border border-brand-500/30 text-brand-300 text-xs font-semibold shadow-2xl flex items-center gap-2 pointer-events-none transition-all duration-700 ${
            showHint ? 'opacity-100 translate-y-0' : 'opacity-0 -translate-y-3 pointer-events-none'
          }`}
        >
          <Sparkles className="w-4 h-4 text-brand-400" />
          <span>{t('tryon.hint')}</span>
        </div>

        {/* Top Floating Controls */}
        <div className="absolute top-4 inset-x-4 z-30 flex items-center justify-between pointer-events-auto">
          {/* Design Info Pill */}
          <div className="px-3.5 py-1.5 rounded-2xl bg-black/75 backdrop-blur-md border border-white/10 text-white text-xs font-semibold flex items-center gap-2 shadow-lg">
            <span className="w-2 h-2 rounded-full bg-forest-400 animate-pulse" />
            <span className="truncate max-w-[140px] sm:max-w-[200px]">
              {design.tag || t('tryon.title')}
            </span>
          </div>

          {/* Close Button */}
          <button
            onClick={onClose}
            className="p-2.5 rounded-2xl bg-black/75 backdrop-blur-md border border-white/15 text-slate-300 hover:text-white hover:bg-slate-800 transition shadow-xl active:scale-95"
            aria-label={t('tryon.close')}
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Bottom Floating Control Panel */}
        <div className="absolute bottom-6 inset-x-4 max-w-md mx-auto z-30 space-y-3 pointer-events-auto">
          {/* Collapsible Sliders (Opacity & Size) */}
          {controlsExpanded && (
            <div className="glass-panel p-4 rounded-3xl border border-slate-700/80 bg-surface-950/90 backdrop-blur-xl shadow-2xl space-y-3 animate-in fade-in slide-in-from-bottom-2 duration-200">
              {/* Opacity Slider */}
              <div className="space-y-1">
                <div className="flex items-center justify-between text-xs text-slate-300 font-medium">
                  <span className="flex items-center gap-1.5">
                    <Eye className="w-3.5 h-3.5 text-brand-400" />
                    <span>{t('tryon.opacity')}</span>
                  </span>
                  <span className="font-mono text-[11px] text-brand-400 font-bold">
                    {Math.round(opacity * 100)}%
                  </span>
                </div>
                <input
                  type="range"
                  min="0.2"
                  max="1.0"
                  step="0.02"
                  value={opacity}
                  onChange={(e) => setOpacity(parseFloat(e.target.value))}
                  className="w-full h-1.5 bg-slate-800 rounded-lg appearance-none cursor-pointer accent-brand-500"
                />
              </div>

              {/* Size Slider */}
              <div className="space-y-1">
                <div className="flex items-center justify-between text-xs text-slate-300 font-medium">
                  <span className="flex items-center gap-1.5">
                    <Maximize2 className="w-3.5 h-3.5 text-brand-400" />
                    <span>{t('tryon.size')}</span>
                  </span>
                  <span className="font-mono text-[11px] text-brand-400 font-bold">
                    {Math.round(scale * 100)}%
                  </span>
                </div>
                <input
                  type="range"
                  min="0.4"
                  max="2.2"
                  step="0.05"
                  value={scale}
                  onChange={(e) => setScale(parseFloat(e.target.value))}
                  className="w-full h-1.5 bg-slate-800 rounded-lg appearance-none cursor-pointer accent-brand-500"
                />
              </div>
            </div>
          )}

          {/* Main Action Bar */}
          <div className="p-2.5 rounded-3xl bg-black/85 backdrop-blur-xl border border-white/15 shadow-2xl flex items-center justify-between gap-2">
            {/* Sliders toggle */}
            <button
              onClick={() => setControlsExpanded((prev) => !prev)}
              className={`p-3 rounded-2xl transition ${
                controlsExpanded
                  ? 'bg-brand-500 text-surface-950 shadow-lg font-bold'
                  : 'bg-surface-900/80 text-slate-300 hover:text-white border border-slate-700/60'
              }`}
              title="Adjust sliders"
            >
              <Sliders className="w-5 h-5" />
            </button>

            {/* Reset Position */}
            <button
              onClick={handleReset}
              className="p-3 rounded-2xl bg-surface-900/80 hover:bg-surface-800 text-slate-300 hover:text-white border border-slate-700/60 transition active:scale-95"
              title={t('tryon.reset_overlay')}
            >
              <RotateCcw className="w-5 h-5" />
            </button>

            {/* Shutter / Snapshot Button */}
            <button
              onClick={handleTakeSnapshot}
              className="p-4 rounded-full bg-gradient-to-tr from-brand-500 to-brand-400 hover:from-brand-400 hover:to-brand-300 text-surface-950 font-bold shadow-xl shadow-brand-500/30 transition transform active:scale-90"
              title={t('tryon.take_snapshot')}
            >
              <Camera className="w-6 h-6 stroke-[2.5]" />
            </button>

            {/* Flip Camera */}
            <button
              onClick={handleFlipCamera}
              className="p-3 rounded-2xl bg-surface-900/80 hover:bg-surface-800 text-slate-300 hover:text-white border border-slate-700/60 transition active:scale-95"
              title={t('tryon.flip_camera')}
            >
              <RefreshCw className="w-5 h-5" />
            </button>

            {/* Close */}
            <button
              onClick={onClose}
              className="p-3 rounded-2xl bg-surface-900/80 hover:bg-rose-500/20 text-slate-300 hover:text-rose-400 border border-slate-700/60 transition"
              title={t('tryon.close')}
            >
              <X className="w-5 h-5" />
            </button>
          </div>
        </div>
      </div>

      {/* Snapshot Preview Modal */}
      {snapshotUrl && (
        <div
          role="dialog"
          aria-modal="true"
          className="fixed inset-0 z-60 flex items-center justify-center p-4 bg-black/90 backdrop-blur-md animate-in fade-in"
        >
          <div className="glass-panel w-full max-w-sm rounded-3xl border border-slate-800 overflow-hidden p-6 bg-surface-950 text-center space-y-4 shadow-2xl">
            <h3 className="text-lg font-bold text-white tracking-tight">
              Snapshot Saved!
            </h3>
            <div className="relative aspect-[3/4] rounded-2xl overflow-hidden bg-surface-900 border border-slate-800">
              <img src={snapshotUrl} alt="Snapshot" className="w-full h-full object-cover" />
            </div>

            <div className="grid grid-cols-2 gap-2 pt-2">
              <a
                href={snapshotUrl}
                download={`tryon-${design.tag || 'design'}.png`}
                className="py-2.5 px-3 rounded-xl bg-brand-500 hover:bg-brand-400 text-surface-950 font-bold text-xs flex items-center justify-center gap-1.5 transition shadow-lg"
              >
                <Download className="w-4 h-4" />
                <span>Save Image</span>
              </a>

              <button
                onClick={() => setSnapshotUrl(null)}
                className="py-2.5 px-3 rounded-xl bg-surface-900 hover:bg-surface-800 border border-slate-700 text-slate-200 text-xs font-semibold transition"
              >
                Done
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
