'use client';

import React from 'react';
import { useLanguage } from '@/lib/i18n/LanguageContext';
import { CatalogCategory } from './types';
import { Search, ArrowUpDown, Filter, X, Sparkles } from 'lucide-react';

export type SortOption = 'newest';

interface CatalogFilterBarProps {
  categories: CatalogCategory[];
  selectedCategory: string;
  onSelectCategory: (categoryId: string) => void;
  searchQuery: string;
  onSearchChange: (query: string) => void;
  sortBy: SortOption;
  onSortChange: (sort: SortOption) => void;
  showingCount: number;
  totalCount: number;
  onResetFilters: () => void;
}

export function CatalogFilterBar({
  categories,
  selectedCategory,
  onSelectCategory,
  searchQuery,
  onSearchChange,
  sortBy,
  onSortChange,
  showingCount,
  totalCount,
  onResetFilters,
}: CatalogFilterBarProps) {
  const { t, getCategoryName } = useLanguage();

  const isFiltered = selectedCategory !== 'all' || searchQuery.trim().length > 0;

  return (
    <div className="space-y-4">
      {/* Category Pills (Horizontal Scroll on Mobile) */}
      <div className="flex items-center gap-2 overflow-x-auto pb-2 scrollbar-none -mx-4 px-4 sm:mx-0 sm:px-0">
        {/* "All" category pill */}
        <button
          onClick={() => onSelectCategory('all')}
          className={`px-4 py-2 rounded-2xl text-xs font-semibold whitespace-nowrap transition-all duration-150 flex-shrink-0 flex items-center gap-1.5 ${
            selectedCategory === 'all'
              ? 'bg-brand-500 text-surface-950 shadow-lg shadow-brand-500/20 font-bold'
              : 'bg-surface-900/80 hover:bg-surface-800 text-slate-300 border border-slate-800'
          }`}
        >
          <span>{t('catalog.all_categories')}</span>
          <span
            className={`text-[10px] px-1.5 py-0.5 rounded-full ${
              selectedCategory === 'all'
                ? 'bg-surface-950/20 text-surface-950'
                : 'bg-slate-800 text-slate-400'
            }`}
          >
            {totalCount}
          </span>
        </button>

        {/* Dynamic Categories */}
        {categories.map((category) => {
          const isSelected = selectedCategory === category.id;
          const localizedName = getCategoryName(category);

          return (
            <button
              key={category.id}
              onClick={() => onSelectCategory(category.id)}
              className={`px-4 py-2 rounded-2xl text-xs font-semibold whitespace-nowrap transition-all duration-150 flex-shrink-0 ${
                isSelected
                  ? 'bg-brand-500 text-surface-950 shadow-lg shadow-brand-500/20 font-bold'
                  : 'bg-surface-900/80 hover:bg-surface-800 text-slate-300 border border-slate-800'
              }`}
            >
              {localizedName}
            </button>
          );
        })}
      </div>

      {/* Search & Sort Row */}
      <div className="flex flex-col sm:flex-row items-stretch sm:items-center justify-between gap-3">
        {/* Search Bar */}
        <div className="relative flex-1">
          <Search className="w-4 h-4 absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400 pointer-events-none" />
          <input
            type="text"
            value={searchQuery}
            onChange={(e) => onSearchChange(e.target.value)}
            placeholder={t('catalog.search_placeholder')}
            className="w-full pl-10 pr-10 py-2.5 bg-surface-900/90 border border-slate-700/80 rounded-2xl text-white placeholder-slate-500 text-xs focus:outline-none focus:ring-2 focus:ring-brand-500/40 focus:border-brand-500 transition shadow-inner"
          />
          {searchQuery && (
            <button
              onClick={() => onSearchChange('')}
              className="absolute right-3 top-1/2 -translate-y-1/2 p-1 text-slate-400 hover:text-white"
            >
              <X className="w-3.5 h-3.5" />
            </button>
          )}
        </div>

        {/* Sort Selector */}
        <div className="relative flex-shrink-0">
          <select
            value={sortBy}
            onChange={(e) => onSortChange(e.target.value as SortOption)}
            className="w-full sm:w-auto px-4 py-2.5 bg-surface-900/90 border border-slate-700/80 rounded-2xl text-slate-200 text-xs font-medium focus:outline-none focus:ring-2 focus:ring-brand-500/40 appearance-none cursor-pointer pr-9 shadow-sm"
          >
            <option value="newest">{t('catalog.sort.newest')}</option>
          </select>
          <ArrowUpDown className="w-3.5 h-3.5 absolute right-3.5 top-1/2 -translate-y-1/2 text-slate-400 pointer-events-none" />
        </div>
      </div>

      {/* Results Count & Reset Filter Indicator */}
      <div className="flex items-center justify-between text-xs text-slate-400 pt-1 px-1">
        <span>
          {t('catalog.showing_count', { count: showingCount, total: totalCount })}
        </span>

        {isFiltered && (
          <button
            onClick={onResetFilters}
            className="text-brand-400 hover:text-brand-300 font-semibold transition inline-flex items-center gap-1"
          >
            <X className="w-3 h-3" />
            <span>{t('catalog.reset_filters')}</span>
          </button>
        )}
      </div>
    </div>
  );
}
