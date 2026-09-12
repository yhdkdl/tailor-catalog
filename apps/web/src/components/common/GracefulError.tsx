'use client';

import React from 'react';
import Link from 'next/link';
import { useLanguage } from '@/lib/i18n/LanguageContext';
import { WifiOff, RefreshCw, Home } from 'lucide-react';

interface GracefulErrorProps {
  title?: string;
  message?: string;
  onRetry?: () => void;
  showHomeButton?: boolean;
}

export function GracefulError({
  title,
  message,
  onRetry,
  showHomeButton = true,
}: GracefulErrorProps) {
  const { t } = useLanguage();

  const displayTitle = title || t('error.unreachable_title');
  const displayMessage = message || t('error.unreachable_desc');

  return (
    <div className="min-h-[60vh] flex items-center justify-center p-4">
      <div className="glass-panel w-full max-w-md rounded-3xl border border-rose-500/20 bg-surface-950/80 p-8 text-center space-y-6 shadow-2xl backdrop-blur-xl">
        <div className="mx-auto w-16 h-16 rounded-2xl bg-rose-500/10 border border-rose-500/20 flex items-center justify-center text-rose-400">
          <WifiOff className="w-8 h-8" />
        </div>

        <div className="space-y-2">
          <h2 className="text-xl font-bold text-white tracking-tight">
            {displayTitle}
          </h2>
          <p className="text-xs sm:text-sm text-slate-400 leading-relaxed">
            {displayMessage}
          </p>
        </div>

        <div className="flex flex-col sm:flex-row gap-3 justify-center pt-2">
          {onRetry && (
            <button
              onClick={onRetry}
              className="inline-flex items-center justify-center gap-2 px-5 py-2.5 rounded-xl bg-brand-500 hover:bg-brand-400 text-surface-950 font-bold text-xs transition active:scale-95 shadow-lg shadow-brand-500/10"
            >
              <RefreshCw className="w-4 h-4" />
              <span>{t('common.retry')}</span>
            </button>
          )}

          {showHomeButton && (
            <Link
              href="/"
              className="inline-flex items-center justify-center gap-2 px-5 py-2.5 rounded-xl bg-surface-900 hover:bg-surface-800 text-slate-200 border border-slate-700 font-semibold text-xs transition active:scale-95"
            >
              <Home className="w-4 h-4" />
              <span>{t('error.back_home')}</span>
            </Link>
          )}
        </div>
      </div>
    </div>
  );
}
