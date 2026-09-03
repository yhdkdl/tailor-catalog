'use client';

import React from 'react';
import Link from 'next/link';
import { useLanguage } from '@/lib/i18n/LanguageContext';
import { LanguageSwitcher } from '@/components/i18n/LanguageSwitcher';
import { Store, AlertCircle, Home, ArrowLeft } from 'lucide-react';

export default function ShopNotFound() {
  const { t } = useLanguage();

  return (
    <div className="min-h-screen bg-surface-950 text-slate-100 flex flex-col justify-between">
      {/* Header */}
      <header className="p-4 sm:p-6 border-b border-slate-800/80 flex items-center justify-between">
        <div className="flex items-center gap-2 text-brand-400 font-bold tracking-tight">
          <Store className="w-5 h-5" />
          <span>Tailor Catalog</span>
        </div>
        <LanguageSwitcher />
      </header>

      {/* Main 404 Body */}
      <main className="flex-1 flex items-center justify-center p-4">
        <div className="glass-panel w-full max-w-md p-8 sm:p-10 rounded-3xl border border-slate-800 text-center space-y-6 shadow-2xl bg-surface-900/60">
          <div className="w-16 h-16 rounded-3xl bg-rose-500/10 border border-rose-500/20 text-rose-400 flex items-center justify-center mx-auto shadow-xl shadow-rose-500/10">
            <AlertCircle className="w-8 h-8" />
          </div>

          <div className="space-y-2">
            <span className="text-[11px] font-mono uppercase tracking-widest text-slate-500">
              404 • Not Found
            </span>
            <h1 className="text-2xl font-bold text-white tracking-tight">
              {t('error.tailor_not_found')}
            </h1>
            <p className="text-xs sm:text-sm text-slate-400 max-w-xs mx-auto">
              {t('error.tailor_not_found_desc')}
            </p>
          </div>

          <div className="pt-2 space-y-2">
            <Link
              href="/"
              className="inline-flex items-center justify-center gap-2 w-full py-3 px-6 rounded-2xl bg-brand-500 hover:bg-brand-400 text-surface-950 font-bold text-xs transition shadow-lg shadow-brand-500/10 active:scale-98"
            >
              <ArrowLeft className="w-4 h-4" />
              <span>{t('error.back_home')}</span>
            </Link>
            <Link href="/marketplace" className="inline-flex items-center justify-center gap-2 w-full py-3 px-6 rounded-2xl border border-slate-700 text-slate-200 font-bold text-xs transition">
              {t('error.browse_all')}
            </Link>
          </div>
        </div>
      </main>

      {/* Footer */}
      <footer className="p-4 border-t border-slate-800/80 text-center text-xs text-slate-500">
        Ethiopian Tailor Catalog Platform
      </footer>
    </div>
  );
}
