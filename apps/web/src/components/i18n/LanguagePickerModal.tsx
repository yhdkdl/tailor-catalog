'use client';

import React from 'react';
import { useLanguage } from '@/lib/i18n/LanguageContext';
import { Globe, Check, Sparkles, X } from 'lucide-react';
import type { Language } from '@tailor-catalog/shared';

export function LanguagePickerModal() {
  const {
    language,
    setLanguage,
    isLanguageModalOpen,
    closeLanguageModal,
    supportedLanguages,
    t,
    hasSelectedLanguage,
  } = useLanguage();

  if (!isLanguageModalOpen) return null;

  return (
    <div
      role="dialog"
      aria-modal="true"
      aria-labelledby="language-modal-title"
      className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/80 backdrop-blur-md animate-in fade-in duration-200"
    >
      <div
        className="glass-panel w-full max-w-lg rounded-3xl border border-slate-800 shadow-2xl overflow-hidden p-6 sm:p-8 bg-surface-950/95 relative space-y-6"
        onClick={(e) => e.stopPropagation()}
      >
        {/* Close Button (if user already had a language selected) */}
        {hasSelectedLanguage && (
          <button
            onClick={closeLanguageModal}
            className="absolute top-5 right-5 p-2 rounded-xl text-slate-400 hover:text-white hover:bg-slate-800/80 transition"
            aria-label="Close language selector"
          >
            <X className="w-5 h-5" />
          </button>
        )}

        {/* Header */}
        <div className="text-center space-y-2 pt-2">
          <div className="inline-flex items-center justify-center w-12 h-12 rounded-2xl bg-brand-500/10 border border-brand-500/20 text-brand-400 mb-1 shadow-lg shadow-brand-500/10">
            <Globe className="w-6 h-6" />
          </div>
          <h2
            id="language-modal-title"
            className="text-2xl font-bold text-white tracking-tight"
          >
            {t('language.picker.title')}
          </h2>
          <p className="text-xs sm:text-sm text-slate-400 max-w-sm mx-auto">
            {t('language.picker.subtitle')}
          </p>
        </div>

        {/* Language Grid */}
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-3 py-2">
          {supportedLanguages.map((lang) => {
            const isSelected = language === lang.code;

            return (
              <button
                key={lang.code}
                onClick={() => setLanguage(lang.code)}
                className={`relative p-4 rounded-2xl border text-left transition-all duration-200 flex flex-col justify-between group ${
                  isSelected
                    ? 'border-brand-500 bg-brand-500/10 shadow-lg shadow-brand-500/10 ring-1 ring-brand-500'
                    : 'border-slate-800/80 bg-surface-900/60 hover:bg-surface-900 hover:border-slate-700'
                }`}
              >
                <div className="flex items-center justify-between w-full mb-2">
                  <span
                    className={`text-lg font-bold tracking-tight ${
                      isSelected ? 'text-brand-300' : 'text-white'
                    }`}
                  >
                    {lang.nativeLabel}
                  </span>
                  {isSelected ? (
                    <div className="w-5 h-5 rounded-full bg-brand-500 flex items-center justify-center text-surface-950">
                      <Check className="w-3.5 h-3.5 stroke-[3]" />
                    </div>
                  ) : (
                    <div className="w-5 h-5 rounded-full border border-slate-700 group-hover:border-slate-500 transition" />
                  )}
                </div>

                <div className="flex items-center justify-between text-xs text-slate-400">
                  <span>{lang.label}</span>
                  <span className="text-[11px] text-slate-500 font-mono">
                    {lang.code.toUpperCase()}
                  </span>
                </div>
              </button>
            );
          })}
        </div>

        {/* Footer / Confirmation */}
        <div className="space-y-3 pt-2">
          <button
            onClick={closeLanguageModal}
            className="w-full py-3.5 px-6 rounded-2xl bg-gradient-to-r from-brand-500 to-brand-600 hover:from-brand-400 hover:to-brand-500 text-surface-950 font-bold text-sm shadow-xl shadow-brand-500/20 transition duration-200 flex items-center justify-center gap-2 active:scale-[0.99]"
          >
            <span>{t('language.picker.continue')}</span>
          </button>
          <p className="text-[11px] text-center text-slate-500">
            {t('language.picker.change_anytime')}
          </p>
        </div>
      </div>
    </div>
  );
}
