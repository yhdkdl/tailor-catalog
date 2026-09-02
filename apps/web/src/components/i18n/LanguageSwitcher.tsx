'use client';

import React, { useState, useRef, useEffect } from 'react';
import { useLanguage } from '@/lib/i18n/LanguageContext';
import { Globe, ChevronDown, Check } from 'lucide-react';
import type { Language } from '@tailor-catalog/shared';

export function LanguageSwitcher({ variant = 'pill' }: { variant?: 'pill' | 'dropdown' | 'compact' }) {
  const { language, setLanguage, openLanguageModal, supportedLanguages, t } = useLanguage();
  const [isOpen, setIsOpen] = useState(false);
  const dropdownRef = useRef<HTMLDivElement>(null);

  const currentOption = supportedLanguages.find((l) => l.code === language) || supportedLanguages[0];

  useEffect(() => {
    function handleClickOutside(event: MouseEvent) {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target as Node)) {
        setIsOpen(false);
      }
    }
    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  if (variant === 'compact') {
    return (
      <button
        onClick={openLanguageModal}
        className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-xl bg-surface-900/90 hover:bg-surface-800 border border-slate-800 text-xs font-medium text-slate-200 hover:text-white transition shadow-sm"
        title={t('header.change_language')}
      >
        <Globe className="w-3.5 h-3.5 text-brand-400" />
        <span className="font-semibold">{currentOption.nativeLabel}</span>
      </button>
    );
  }

  return (
    <div className="relative inline-block text-left" ref={dropdownRef}>
      <button
        onClick={() => setIsOpen((prev) => !prev)}
        className="inline-flex items-center gap-2 px-3 py-1.5 rounded-xl bg-surface-900/90 hover:bg-surface-800 border border-slate-700/80 text-xs font-medium text-slate-200 hover:text-white transition shadow-sm active:scale-95"
        aria-expanded={isOpen}
        aria-haspopup="true"
        title={t('header.change_language')}
      >
        <Globe className="w-3.5 h-3.5 text-brand-400 flex-shrink-0" />
        <span className="font-semibold">{currentOption.nativeLabel}</span>
        <ChevronDown className={`w-3.5 h-3.5 text-slate-400 transition-transform duration-200 ${isOpen ? 'rotate-180' : ''}`} />
      </button>

      {isOpen && (
        <div className="absolute right-0 mt-2 w-48 rounded-2xl bg-surface-950 border border-slate-800 shadow-2xl p-1.5 z-50 animate-in fade-in zoom-in-95 duration-150">
          <div className="px-3 py-1.5 text-[10px] font-bold text-slate-400 uppercase tracking-wider border-b border-slate-800/80 mb-1">
            {t('language.picker.title')}
          </div>
          {supportedLanguages.map((lang) => {
            const isSelected = language === lang.code;
            return (
              <button
                key={lang.code}
                onClick={() => {
                  setLanguage(lang.code);
                  setIsOpen(false);
                }}
                className={`w-full flex items-center justify-between px-3 py-2 rounded-xl text-xs font-medium transition ${
                  isSelected
                    ? 'bg-brand-500/15 text-brand-300 font-bold'
                    : 'text-slate-300 hover:bg-surface-900 hover:text-white'
                }`}
              >
                <div className="flex flex-col text-left">
                  <span>{lang.nativeLabel}</span>
                  <span className="text-[10px] text-slate-500 font-normal">{lang.label}</span>
                </div>
                {isSelected && <Check className="w-4 h-4 text-brand-400" />}
              </button>
            );
          })}
        </div>
      )}
    </div>
  );
}
