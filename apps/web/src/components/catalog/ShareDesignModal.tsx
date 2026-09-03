'use client';

import React, { useState } from 'react';
import { useLanguage } from '@/lib/i18n/LanguageContext';
import { CatalogDesign, CatalogTailor } from './types';
import {
  X,
  Share2,
  Copy,
  Check,
  ExternalLink,
  MessageCircle,
  Send,
} from 'lucide-react';

interface ShareDesignModalProps {
  design: CatalogDesign | null;
  tailor: CatalogTailor;
  isOpen: boolean;
  onClose: () => void;
}

export function ShareDesignModal({
  design,
  tailor,
  isOpen,
  onClose,
}: ShareDesignModalProps) {
  const { t } = useLanguage();
  const [copied, setCopied] = useState(false);

  if (!isOpen || !design) return null;

  const baseUrl = typeof window !== 'undefined'
    ? window.location.origin
    : (process.env.NEXT_PUBLIC_APP_URL || 'https://tailor-catalog.vercel.app');

  const directLink = `${baseUrl}/${tailor.shop_slug}?design=${design.id}`;
  const catalogLink = `${baseUrl}/${tailor.shop_slug}`;

  const shareText = `Check out this handcrafted design from ${tailor.shop_name}!\n${directLink}\n\nBrowse more designs: ${catalogLink}`;

  const handleCopy = async () => {
    try {
      if (navigator.clipboard) {
        await navigator.clipboard.writeText(directLink);
      } else {
        const input = document.createElement('input');
        input.value = directLink;
        document.body.appendChild(input);
        input.select();
        document.execCommand('copy');
        document.body.removeChild(input);
      }
      setCopied(true);
      setTimeout(() => setCopied(false), 2500);
    } catch (e) {
      console.warn('Clipboard write failed:', e);
    }
  };

  const handleNativeShare = async () => {
    if (typeof navigator !== 'undefined' && navigator.share) {
      try {
        await navigator.share({
          title: `${tailor.shop_name} Design`,
          text: `Check out this design from ${tailor.shop_name}!`,
          url: directLink,
        });
      } catch (e) {
        // User cancelled or share failed
      }
    }
  };

  const handleWhatsApp = () => {
    const url = `https://api.whatsapp.com/send?text=${encodeURIComponent(shareText)}`;
    window.open(url, '_blank', 'noopener,noreferrer');
  };

  const handleTelegram = () => {
    const url = `https://t.me/share/url?url=${encodeURIComponent(directLink)}&text=${encodeURIComponent(
      `Check out this handcrafted design from ${tailor.shop_name}!`
    )}`;
    window.open(url, '_blank', 'noopener,noreferrer');
  };

  const hasNativeShare = typeof navigator !== 'undefined' && !!navigator.share;

  return (
    <div
      role="dialog"
      aria-modal="true"
      aria-label={t('share.title')}
      className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/80 backdrop-blur-md animate-in fade-in duration-200"
      onClick={onClose}
    >
      <div
        className="glass-panel w-full max-w-md rounded-3xl border border-slate-800 bg-surface-950 p-6 shadow-2xl space-y-6 relative"
        onClick={(e) => e.stopPropagation()}
      >
        {/* Header */}
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2.5">
            <div className="p-2.5 rounded-2xl bg-brand-500/15 border border-brand-500/30 text-brand-400">
              <Share2 className="w-5 h-5" />
            </div>
            <div>
              <h3 className="text-lg font-bold text-white tracking-tight">
                {t('share.title')}
              </h3>
              <p className="text-xs text-slate-400">{tailor.shop_name}</p>
            </div>
          </div>

          <button
            onClick={onClose}
            className="p-2 rounded-xl text-slate-400 hover:text-white hover:bg-slate-800 transition"
            aria-label="Close modal"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Copy Link Input */}
        <div className="space-y-2">
          <label className="text-xs font-semibold text-slate-300">
            Direct Link
          </label>
          <div className="flex items-center gap-2 p-2 rounded-2xl bg-surface-900 border border-slate-800">
            <input
              type="text"
              readOnly
              value={directLink}
              className="flex-1 bg-transparent text-xs text-slate-300 font-mono px-2 outline-none truncate"
            />
            <button
              onClick={handleCopy}
              className={`px-3.5 py-2 rounded-xl text-xs font-bold transition flex items-center gap-1.5 shadow-sm ${
                copied
                  ? 'bg-green-500/20 text-green-400 border border-green-500/30'
                  : 'bg-brand-500 hover:bg-brand-400 text-surface-950'
              }`}
            >
              {copied ? (
                <>
                  <Check className="w-3.5 h-3.5" />
                  <span>{t('share.copied')}</span>
                </>
              ) : (
                <>
                  <Copy className="w-3.5 h-3.5" />
                  <span>{t('share.copy')}</span>
                </>
              )}
            </button>
          </div>
        </div>

        {/* Social Share Buttons */}
        <div className="grid grid-cols-2 gap-3">
          {/* WhatsApp */}
          <button
            onClick={handleWhatsApp}
            className="p-3.5 rounded-2xl bg-[#25D366]/10 hover:bg-[#25D366]/20 border border-[#25D366]/30 text-[#25D366] font-semibold text-xs flex items-center justify-center gap-2 transition"
          >
            <MessageCircle className="w-4 h-4" />
            <span>{t('share.whatsapp')}</span>
          </button>

          {/* Telegram */}
          <button
            onClick={handleTelegram}
            className="p-3.5 rounded-2xl bg-[#0088cc]/10 hover:bg-[#0088cc]/20 border border-[#0088cc]/30 text-[#0088cc] font-semibold text-xs flex items-center justify-center gap-2 transition"
          >
            <Send className="w-4 h-4" />
            <span>{t('share.telegram')}</span>
          </button>
        </div>

        {/* Native Mobile Share if supported */}
        {hasNativeShare && (
          <button
            onClick={handleNativeShare}
            className="w-full py-3 px-4 rounded-2xl bg-surface-900 hover:bg-surface-800 border border-slate-700 text-slate-200 text-xs font-semibold flex items-center justify-center gap-2 transition"
          >
            <Share2 className="w-4 h-4 text-brand-400" />
            <span>Open System Share Sheet</span>
          </button>
        )}
      </div>
    </div>
  );
}
