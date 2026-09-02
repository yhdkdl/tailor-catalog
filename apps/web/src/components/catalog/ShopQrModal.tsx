'use client';

import React from 'react';
import { useLanguage } from '@/lib/i18n/LanguageContext';
import { X, QrCode, Share2, Copy, Check } from 'lucide-react';
import { CatalogTailor } from './types';

interface ShopQrModalProps {
  tailor: CatalogTailor;
  isOpen: boolean;
  onClose: () => void;
}

export function ShopQrModal({ tailor, isOpen, onClose }: ShopQrModalProps) {
  const { t } = useLanguage();
  const [copied, setCopied] = React.useState(false);

  if (!isOpen) return null;

  const catalogUrl = typeof window !== 'undefined'
    ? window.location.href
    : `https://tailor-catalog.vercel.app/${tailor.shop_slug}`;

  // QR Code URL using high-contrast rendering service
  const qrImageUrl = `https://api.qrserver.com/v1/create-qr-code/?size=300x300&data=${encodeURIComponent(
    catalogUrl
  )}&margin=10`;

  const handleCopyLink = () => {
    navigator.clipboard.writeText(catalogUrl);
    setCopied(true);
    setTimeout(() => setCopied(false), 2500);
  };

  const handleShare = async () => {
    if (navigator.share) {
      try {
        await navigator.share({
          title: `${tailor.shop_name} Catalog`,
          text: `Explore handcrafted fashion designs from ${tailor.shop_name}`,
          url: catalogUrl,
        });
      } catch {}
    } else {
      handleCopyLink();
    }
  };

  return (
    <div
      role="dialog"
      aria-modal="true"
      className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/85 backdrop-blur-md animate-in fade-in duration-200"
      onClick={onClose}
    >
      <div
        className="glass-panel w-full max-w-sm rounded-3xl border border-slate-800 shadow-2xl overflow-hidden p-6 bg-surface-950/95 relative space-y-5 text-center"
        onClick={(e) => e.stopPropagation()}
      >
        <button
          onClick={onClose}
          className="absolute top-4 right-4 p-2 rounded-xl text-slate-400 hover:text-white hover:bg-slate-800/80 transition"
        >
          <X className="w-5 h-5" />
        </button>

        <div className="space-y-1 pt-2">
          <h3 className="text-xl font-bold text-white tracking-tight">{tailor.shop_name}</h3>
          <p className="text-xs text-brand-400 font-medium">/{tailor.shop_slug}</p>
        </div>

        {/* QR Code Canvas Card */}
        <div className="p-4 bg-white rounded-2xl shadow-xl inline-block border-4 border-brand-500/20">
          <img
            src={qrImageUrl}
            alt={`${tailor.shop_name} QR Code`}
            className="w-48 h-48 mx-auto"
            loading="eager"
          />
        </div>

        <p className="text-xs text-slate-400">
          Scan to browse this tailor&apos;s full fashion catalog on any smartphone.
        </p>

        {/* Action buttons */}
        <div className="grid grid-cols-2 gap-2 pt-1">
          <button
            onClick={handleShare}
            className="py-2.5 px-3 rounded-xl bg-brand-500 hover:bg-brand-400 text-surface-950 font-bold text-xs flex items-center justify-center gap-1.5 transition shadow-lg shadow-brand-500/10"
          >
            <Share2 className="w-3.5 h-3.5" />
            <span>{t('header.share_catalog')}</span>
          </button>

          <button
            onClick={handleCopyLink}
            className="py-2.5 px-3 rounded-xl bg-surface-900 hover:bg-surface-800 border border-slate-700 text-slate-200 hover:text-white font-medium text-xs flex items-center justify-center gap-1.5 transition"
          >
            {copied ? <Check className="w-3.5 h-3.5 text-forest-400" /> : <Copy className="w-3.5 h-3.5" />}
            <span>{copied ? t('header.link_copied') : 'Copy Link'}</span>
          </button>
        </div>
      </div>
    </div>
  );
}
