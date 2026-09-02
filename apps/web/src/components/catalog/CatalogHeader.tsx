'use client';

import React, { useState } from 'react';
import { useLanguage } from '@/lib/i18n/LanguageContext';
import { LanguageSwitcher } from '@/components/i18n/LanguageSwitcher';
import { CatalogTailor } from './types';
import {
  Store,
  Phone,
  Share2,
  QrCode,
  CheckCircle2,
  Copy,
  Check,
  Sparkles,
} from 'lucide-react';
import { ShopQrModal } from './ShopQrModal';

interface CatalogHeaderProps {
  tailor: CatalogTailor;
}

export function CatalogHeader({ tailor }: CatalogHeaderProps) {
  const { t } = useLanguage();
  const [isQrOpen, setIsQrOpen] = useState(false);
  const [copied, setCopied] = useState(false);

  const handleShare = async () => {
    const url = window.location.href;
    if (navigator.share) {
      try {
        await navigator.share({
          title: `${tailor.shop_name} - Ethiopian Fashion Catalog`,
          text: `Check out bespoke designs and traditional fashion from ${tailor.shop_name}`,
          url,
        });
      } catch {}
    } else {
      navigator.clipboard.writeText(url);
      setCopied(true);
      setTimeout(() => setCopied(false), 2500);
    }
  };

  return (
    <>
      <header className="sticky top-0 z-40 bg-surface-950/80 backdrop-blur-xl border-b border-slate-800/80 shadow-lg">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-3.5 flex items-center justify-between gap-4">
          {/* Left: Shop Brand */}
          <div className="flex items-center gap-3 min-w-0">
            <div className="w-10 h-10 rounded-2xl bg-gradient-to-br from-brand-500/20 to-brand-600/10 border border-brand-500/30 flex items-center justify-center text-brand-400 flex-shrink-0 shadow-lg shadow-brand-500/5">
              <Store className="w-5 h-5" />
            </div>

            <div className="min-w-0">
              <div className="flex items-center gap-2">
                <h1 className="text-base sm:text-lg font-bold text-white tracking-tight truncate">
                  {tailor.shop_name}
                </h1>
                <span
                  className="inline-flex items-center gap-1 px-2 py-0.5 rounded-full bg-forest-500/15 border border-forest-500/30 text-[11px] font-semibold text-forest-400 flex-shrink-0"
                  title="Verified Tailor Shop"
                >
                  <CheckCircle2 className="w-3 h-3" />
                  <span className="hidden sm:inline">{t('header.verified_tailor')}</span>
                </span>
              </div>
              <p className="text-[11px] text-slate-400 font-mono truncate">
                /{tailor.shop_slug}
              </p>
            </div>
          </div>

          {/* Right: Actions & Language Switcher */}
          <div className="flex items-center gap-2 flex-shrink-0">
            {tailor.phone && (
              <a
                href={`tel:${tailor.phone}`}
                className="hidden sm:inline-flex items-center gap-1.5 px-3 py-1.5 rounded-xl bg-surface-900/90 hover:bg-surface-800 border border-slate-700/80 text-xs font-medium text-slate-200 hover:text-white transition shadow-sm"
                title={t('header.call_phone')}
              >
                <Phone className="w-3.5 h-3.5 text-brand-400" />
                <span>{t('header.call_phone')}</span>
              </a>
            )}

            <button
              onClick={() => setIsQrOpen(true)}
              className="p-2 rounded-xl bg-surface-900/90 hover:bg-surface-800 border border-slate-700/80 text-slate-300 hover:text-white transition shadow-sm"
              title={t('header.qr_code')}
              aria-label="View QR Code"
            >
              <QrCode className="w-4 h-4 text-brand-400" />
            </button>

            <button
              onClick={handleShare}
              className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-xl bg-brand-500 hover:bg-brand-400 text-surface-950 font-bold text-xs transition shadow-md shadow-brand-500/10 active:scale-95"
              title={t('header.share_catalog')}
            >
              {copied ? (
                <>
                  <Check className="w-3.5 h-3.5 stroke-[3]" />
                  <span className="hidden sm:inline">{t('header.link_copied')}</span>
                </>
              ) : (
                <>
                  <Share2 className="w-3.5 h-3.5" />
                  <span className="hidden sm:inline">{t('header.share_catalog')}</span>
                </>
              )}
            </button>

            {/* Language Switcher */}
            <LanguageSwitcher />
          </div>
        </div>
      </header>

      {/* QR Modal */}
      <ShopQrModal
        tailor={tailor}
        isOpen={isQrOpen}
        onClose={() => setIsQrOpen(false)}
      />
    </>
  );
}
