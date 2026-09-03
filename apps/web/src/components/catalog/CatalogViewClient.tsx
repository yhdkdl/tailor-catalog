'use client';

import React, { useState, useMemo, useEffect } from 'react';
import { useLanguage } from '@/lib/i18n/LanguageContext';
import { CatalogTailor, CatalogCategory, CatalogDesign } from './types';
import { CatalogHeader } from './CatalogHeader';
import { CatalogFilterBar, SortOption } from './CatalogFilterBar';
import { DesignCard } from './DesignCard';
import { CustomerDesignDetailModal } from './CustomerDesignDetailModal';
import { PhotoViewer360Modal } from './PhotoViewer360Modal';
import { Shirt } from 'lucide-react';

interface CatalogViewClientProps {
  tailor: CatalogTailor;
  categories: CatalogCategory[];
  initialDesigns: CatalogDesign[];
  initialDesignId?: string;
}

export function CatalogViewClient({
  tailor,
  categories,
  initialDesigns,
  initialDesignId,
}: CatalogViewClientProps) {
  const { t } = useLanguage();

  const [selectedCategory, setSelectedCategory] = useState<string>('all');
  const [searchQuery, setSearchQuery] = useState<string>('');
  const [sortBy, setSortBy] = useState<SortOption>('newest');
  const [selectedDesign, setSelectedDesign] = useState<CatalogDesign | null>(null);
  const [viewer360Design, setViewer360Design] = useState<CatalogDesign | null>(null);
  useEffect(() => {
    if (initialDesignId) setSelectedDesign(initialDesigns.find((d) => d.id === initialDesignId) || null);
  }, [initialDesignId, initialDesigns]);

  // Filter and sort logic
  const filteredDesigns = useMemo(() => {
    return initialDesigns
      .filter((design) => {
        // Category filter
        if (selectedCategory !== 'all' && design.category_id !== selectedCategory) {
          return false;
        }

        // Search query filter (tag or category)
        if (searchQuery.trim()) {
          const q = searchQuery.toLowerCase().trim();
          const matchTag = design.tag ? design.tag.toLowerCase().includes(q) : false;
          const matchCategoryEn = design.category?.name_en.toLowerCase().includes(q) || false;
          const matchCategoryAm = design.category?.name_am?.toLowerCase().includes(q) || false;
          const matchCategoryOm = design.category?.name_om?.toLowerCase().includes(q) || false;
          const matchCategorySo = design.category?.name_so?.toLowerCase().includes(q) || false;

          return (
            matchTag ||
            matchCategoryEn ||
            matchCategoryAm ||
            matchCategoryOm ||
            matchCategorySo
          );
        }

        return true;
      })
      .sort((a, b) => {
        if (sortBy === 'newest') {
          return new Date(b.created_at).getTime() - new Date(a.created_at).getTime();
        }
        return 0;
      });
  }, [initialDesigns, selectedCategory, searchQuery, sortBy]);

  const handleResetFilters = () => {
    setSelectedCategory('all');
    setSearchQuery('');
  };

  return (
    <div className="min-h-screen bg-surface-950 text-slate-100 flex flex-col">
      {/* Shop Header */}
      <CatalogHeader tailor={tailor} />

      {/* Main Content Area */}
      <main className="flex-1 max-w-7xl w-full mx-auto px-4 sm:px-6 lg:px-8 py-6 sm:py-8 space-y-6">
        {/* Banner / Intro */}
        <div className="space-y-1">
          <h2 className="text-xl sm:text-2xl font-bold text-white tracking-tight">
            {t('catalog.title')}
          </h2>
          <p className="text-xs sm:text-sm text-slate-400">
            {t('catalog.subtitle')}
          </p>
        </div>

        {/* Filter and Search Bar */}
        <CatalogFilterBar
          categories={categories}
          selectedCategory={selectedCategory}
          onSelectCategory={setSelectedCategory}
          searchQuery={searchQuery}
          onSearchChange={setSearchQuery}
          sortBy={sortBy}
          onSortChange={setSortBy}
          showingCount={filteredDesigns.length}
          totalCount={initialDesigns.length}
          onResetFilters={handleResetFilters}
        />

        {initialDesigns.some((design) => design.is_trending) && (
          <section className="space-y-3">
            <h3 className="text-lg font-bold text-white">{t('trending.title')}</h3>
            <div className="flex gap-3 overflow-x-auto pb-2">
              {initialDesigns.filter((design) => design.is_trending).slice(0, 6).map((design) => (
                <div key={design.id} className="min-w-[180px] sm:min-w-[220px]">
                  <DesignCard design={design} onInspect={setSelectedDesign} />
                </div>
              ))}
            </div>
          </section>
        )}

        {/* Designs Grid */}
        {filteredDesigns.length === 0 ? (
          <div className="glass-panel rounded-3xl border border-slate-800/80 p-12 sm:p-16 text-center space-y-3">
            <div className="w-12 h-12 rounded-2xl bg-surface-900 border border-slate-800 flex items-center justify-center mx-auto text-slate-500">
              <Shirt className="w-6 h-6" />
            </div>
            <h3 className="text-base font-bold text-slate-200">
              {t('catalog.no_designs')}
            </h3>
            <p className="text-xs text-slate-400 max-w-sm mx-auto">
              {t('catalog.no_designs_desc')}
            </p>
            {(selectedCategory !== 'all' || searchQuery) && (
              <button
                onClick={handleResetFilters}
                className="mt-2 px-4 py-2 rounded-xl bg-brand-500 hover:bg-brand-400 text-surface-950 font-bold text-xs transition"
              >
                {t('catalog.reset_filters')}
              </button>
            )}
          </div>
        ) : (
          <div className="grid grid-cols-2 sm:grid-cols-3 gap-3">
            {filteredDesigns.map((design) => (
              <DesignCard
                key={design.id}
                design={design}
                onInspect={(d) => setSelectedDesign(d)}
              />
            ))}
          </div>
        )}
      </main>

      {/* Customer Design Detail & Multi-Photo Carousel Modal */}
      <CustomerDesignDetailModal
        design={selectedDesign}
        tailor={tailor}
        isOpen={!!selectedDesign}
        onClose={() => setSelectedDesign(null)}
        onView360={(d) => {
          setSelectedDesign(null);
          setViewer360Design(d);
        }}
      />

      {/* 360 Photo Viewer Full-Screen Modal */}
      <PhotoViewer360Modal
        design={viewer360Design}
        isOpen={!!viewer360Design}
        onClose={() => setViewer360Design(null)}
      />

      {/* Footer */}
      <footer className="border-t border-slate-800/80 bg-surface-950/80 py-6 text-center text-xs text-slate-500 space-y-1">
        <p>
          {tailor.shop_name} • Powered by{' '}
          <span className="text-brand-400 font-semibold">Ethiopian Tailor Catalog</span>
        </p>
      </footer>
    </div>
  );
}
