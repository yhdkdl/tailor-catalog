'use client';

import React, { createContext, useContext, useState, useEffect, useCallback, useMemo } from 'react';
import type { Language } from '@tailor-catalog/shared';
import { translations, TranslationKey, SUPPORTED_LANGUAGES, LanguageOption } from './translations';

export interface CategoryMultilingual {
  name_en: string;
  name_am?: string | null;
  name_om?: string | null;
  name_so?: string | null;
}

interface LanguageContextType {
  language: Language;
  setLanguage: (lang: Language) => void;
  t: (key: TranslationKey, params?: Record<string, string | number>) => string;
  getCategoryName: (category?: CategoryMultilingual | null) => string;
  isLanguageModalOpen: boolean;
  openLanguageModal: () => void;
  closeLanguageModal: () => void;
  supportedLanguages: LanguageOption[];
  hasSelectedLanguage: boolean;
}

const STORAGE_KEY = 'tailor_catalog_lang';
const HAS_SELECTED_KEY = 'tailor_catalog_lang_selected';

const LanguageContext = createContext<LanguageContextType | null>(null);

export function LanguageProvider({
  children,
  defaultLanguage = 'en',
}: {
  children: React.ReactNode;
  defaultLanguage?: Language;
}) {
  const [language, setLanguageState] = useState<Language>(defaultLanguage);
  const [hasSelectedLanguage, setHasSelectedLanguage] = useState<boolean>(true); // default true for SSR to avoid flash
  const [isLanguageModalOpen, setIsLanguageModalOpen] = useState<boolean>(false);
  const [mounted, setMounted] = useState<boolean>(false);

  // Initialize from localStorage on mount
  useEffect(() => {
    setMounted(true);
    try {
      const storedLang = localStorage.getItem(STORAGE_KEY) as Language | null;
      const hasChosen = localStorage.getItem(HAS_SELECTED_KEY) === 'true';

      if (storedLang && ['en', 'am', 'om', 'so'].includes(storedLang)) {
        setLanguageState(storedLang);
        document.documentElement.lang = storedLang;
      }

      setHasSelectedLanguage(hasChosen);

      // If user hasn't selected language yet on first visit, open the modal
      if (!hasChosen && !storedLang) {
        setIsLanguageModalOpen(true);
      }
    } catch {
      // localStorage may be disabled / in private browsing
    }
  }, []);

  const setLanguage = useCallback((newLang: Language) => {
    setLanguageState(newLang);
    setHasSelectedLanguage(true);
    setIsLanguageModalOpen(false);

    try {
      localStorage.setItem(STORAGE_KEY, newLang);
      localStorage.setItem(HAS_SELECTED_KEY, 'true');
      document.documentElement.lang = newLang;
    } catch {
      // localStorage may fail
    }
  }, []);

  const openLanguageModal = useCallback(() => {
    setIsLanguageModalOpen(true);
  }, []);

  const closeLanguageModal = useCallback(() => {
    setIsLanguageModalOpen(false);
    // Mark as selected so it doesn't pop up again even if they closed with default
    try {
      localStorage.setItem(HAS_SELECTED_KEY, 'true');
    } catch {}
  }, []);

  const t = useCallback(
    (key: TranslationKey, params?: Record<string, string | number>): string => {
      const langDict = translations[language] || translations.en;
      let text: string = (langDict as Record<string, string>)[key] || (translations.en as Record<string, string>)[key] || key;

      if (params) {
        Object.entries(params).forEach(([paramKey, paramVal]) => {
          text = text.replace(new RegExp(`\\{${paramKey}\\}`, 'g'), String(paramVal));
        });
      }

      return text;
    },
    [language]
  );

  const getCategoryName = useCallback(
    (category?: CategoryMultilingual | null): string => {
      if (!category) return '';
      switch (language) {
        case 'am':
          return category.name_am || category.name_en;
        case 'om':
          return category.name_om || category.name_en;
        case 'so':
          return category.name_so || category.name_en;
        case 'en':
        default:
          return category.name_en;
      }
    },
    [language]
  );

  const value = useMemo(
    () => ({
      language,
      setLanguage,
      t,
      getCategoryName,
      isLanguageModalOpen,
      openLanguageModal,
      closeLanguageModal,
      supportedLanguages: SUPPORTED_LANGUAGES,
      hasSelectedLanguage,
    }),
    [
      language,
      setLanguage,
      t,
      getCategoryName,
      isLanguageModalOpen,
      openLanguageModal,
      closeLanguageModal,
      hasSelectedLanguage,
    ]
  );

  return <LanguageContext.Provider value={value}>{children}</LanguageContext.Provider>;
}

export function useLanguage() {
  const context = useContext(LanguageContext);
  if (!context) {
    throw new Error('useLanguage must be used within a LanguageProvider');
  }
  return context;
}

export const useTranslation = useLanguage;
