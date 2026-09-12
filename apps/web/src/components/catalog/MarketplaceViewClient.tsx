'use client';

import { useEffect, useMemo, useState } from 'react';
import Link from 'next/link';
import { useLanguage } from '@/lib/i18n/LanguageContext';
import { useFavorites } from '@/lib/favorites/FavoritesContext';
import { LanguageSwitcher } from '@/components/i18n/LanguageSwitcher';
import { CatalogCategory, CatalogDesign } from './types';
import { DesignCard } from './DesignCard';
import { CustomerDesignDetailModal } from './CustomerDesignDetailModal';
import { PhotoViewer360Modal } from './PhotoViewer360Modal';
import { Sparkles, Heart, RefreshCw, Shirt } from 'lucide-react';

type MarketplaceDesign = CatalogDesign & {
  tailor?: { shop_name: string; shop_slug: string };
};

export function MarketplaceViewClient({
  designs,
  categories,
  initialTrending = false,
}: {
  designs: MarketplaceDesign[];
  categories: CatalogCategory[];
  initialTrending?: boolean;
}) {
  const { t, getCategoryName } = useLanguage();
  const { count } = useFavorites();

  const [query, setQuery] = useState('');
  const [category, setCategory] = useState('all');
  const [tailor, setTailor] = useState('all');
  const [trending, setTrending] = useState(initialTrending);
  const [items, setItems] = useState<MarketplaceDesign[]>(designs);
  const [page, setPage] = useState(1);
  const [loading, setLoading] = useState(false);
  const [hasMore, setHasMore] = useState(designs.length === 20);
  const [selected, setSelected] = useState<MarketplaceDesign | null>(null);
  const [viewer, setViewer] = useState<MarketplaceDesign | null>(null);

  // Sync with prop if it updates
  useEffect(() => {
    setItems(designs);
    setHasMore(designs.length === 20);
  }, [designs]);

  // Distinct tailors list derived from all loaded items
  const tailors = useMemo(() => {
    const map = new Map<string, { shop_name: string; shop_slug: string }>();
    items.forEach((d) => {
      if (d.tailor?.shop_slug) {
        map.set(d.tailor.shop_slug, d.tailor);
      }
    });
    return Array.from(map.values());
  }, [items]);

  // Filtered designs based on current filters applied to all loaded items
  const filtered = useMemo(() => {
    return items.filter((d) => {
      if (category !== 'all' && d.category_id !== category) return false;
      if (tailor !== 'all' && d.tailor?.shop_slug !== tailor) return false;
      if (trending && !d.is_trending) return false;
      if (query.trim()) {
        const q = query.toLowerCase().trim();
        const tagMatch = (d.tag || '').toLowerCase().includes(q);
        const catMatch = (d.category?.name_en || '').toLowerCase().includes(q);
        const shopMatch = (d.tailor?.shop_name || '').toLowerCase().includes(q);
        return tagMatch || catMatch || shopMatch;
      }
      return true;
    });
  }, [items, category, tailor, trending, query]);

  // Load more handler
  const loadMore = async () => {
    if (loading || !hasMore) return;
    setLoading(true);
    try {
      const response = await fetch(`/api/marketplace?page=${page}`);
      if (!response.ok) throw new Error('Failed to fetch designs');
      const next = (await response.json()) as MarketplaceDesign[];
      if (Array.isArray(next) && next.length > 0) {
        setItems((current) => {
          const existingIds = new Set(current.map((i) => i.id));
          const fresh = next.filter((n) => !existingIds.has(n.id));
          return [...current, ...fresh];
        });
        setPage((current) => current + 1);
        setHasMore(next.length === 20);
      } else {
        setHasMore(false);
      }
    } catch (err) {
      console.error('Error loading more designs:', err);
    } finally {
      setLoading(false);
    }
  };

  // Optional infinite scroll
  useEffect(() => {
    const onScroll = () => {
      if (
        window.innerHeight + window.scrollY >=
        document.body.offsetHeight - 600
      ) {
        loadMore();
      }
    };
    window.addEventListener('scroll', onScroll, { passive: true });
    return () => window.removeEventListener('scroll', onScroll);
  });

  return (
    <div className="min-h-screen bg-surface-950 text-slate-100 flex flex-col">
      {/* Header with Shop Navigation, Live Saved Favorites Counter, and Language Switcher */}
      <header className="sticky top-0 z-40 bg-surface-950/90 backdrop-blur-xl border-b border-slate-800/80 shadow-lg">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-3.5 flex items-center justify-between gap-4">
          <div className="flex items-center gap-3 min-w-0">
            <div className="w-10 h-10 rounded-2xl bg-gradient-to-br from-brand-500/20 to-brand-600/10 border border-brand-500/30 flex items-center justify-center text-brand-400 flex-shrink-0 shadow-lg shadow-brand-500/5">
              <Sparkles className="w-5 h-5" />
            </div>
            <div className="min-w-0">
              <h1 className="text-base sm:text-lg font-bold text-white tracking-tight truncate">
                {t('marketplace.title')}
              </h1>
              <p className="text-[11px] text-slate-400 truncate hidden sm:block">
                {t('marketplace.subtitle')}
              </p>
            </div>
          </div>

          <div className="flex items-center gap-2 sm:gap-3 flex-shrink-0">
            {/* Live Saved Favorites Button */}
            <Link
              href="/favourites"
              className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-xl bg-surface-900/90 hover:bg-surface-800 border border-slate-700/80 text-xs font-semibold text-brand-300 hover:text-brand-200 transition shadow-sm active:scale-95"
              title="View Saved Favorites"
            >
              <Heart className={`w-3.5 h-3.5 ${count > 0 ? 'fill-amber-400 text-amber-400' : 'text-slate-400'}`} />
              <span>{t('header.favourites', { count })}</span>
            </Link>

            {/* Language Switcher */}
            <LanguageSwitcher />
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="flex-1 max-w-7xl w-full mx-auto px-4 sm:px-6 lg:px-8 py-6 space-y-6">
        {/* Filter & Search Bar */}
        <div className="flex flex-wrap gap-2.5">
          <button
            onClick={() => setTrending(false)}
            className={
              !trending
                ? 'bg-brand-500 text-black px-4 py-2 rounded-xl text-xs font-bold transition shadow-sm'
                : 'bg-surface-900 hover:bg-surface-800 text-slate-300 px-4 py-2 rounded-xl text-xs font-medium border border-slate-700 transition'
            }
          >
            {t('marketplace.all_tab')}
          </button>
          <button
            onClick={() => setTrending(true)}
            className={
              trending
                ? 'bg-brand-500 text-black px-4 py-2 rounded-xl text-xs font-bold transition shadow-sm'
                : 'bg-surface-900 hover:bg-surface-800 text-slate-300 px-4 py-2 rounded-xl text-xs font-medium border border-slate-700 transition'
            }
          >
            {t('marketplace.trending_tab')}
          </button>
          <input
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            placeholder={t('catalog.search_placeholder')}
            className="min-w-48 flex-1 rounded-xl border border-slate-700 bg-surface-900 px-3 py-2 text-xs text-slate-100 placeholder-slate-500 focus:outline-none focus:border-brand-500"
          />
          <select
            value={category}
            onChange={(e) => setCategory(e.target.value)}
            className="rounded-xl border border-slate-700 bg-surface-900 px-3 py-2 text-xs text-slate-200 focus:outline-none focus:border-brand-500 cursor-pointer"
          >
            <option value="all">{t('catalog.all_categories')}</option>
            {categories.map((c) => (
              <option key={c.id} value={c.id}>
                {getCategoryName(c)}
              </option>
            ))}
          </select>
          <select
            value={tailor}
            onChange={(e) => setTailor(e.target.value)}
            className="rounded-xl border border-slate-700 bg-surface-900 px-3 py-2 text-xs text-slate-200 focus:outline-none focus:border-brand-500 cursor-pointer"
          >
            <option value="all">{t('marketplace.filter_tailor')}</option>
            {tailors.map((s) => (
              <option key={s.shop_slug} value={s.shop_slug}>
                {s.shop_name}
              </option>
            ))}
          </select>
        </div>

        {/* Designs Grid */}
        {filtered.length === 0 ? (
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
          </div>
        ) : (
          <div className="grid grid-cols-2 gap-3 sm:grid-cols-3">
            {filtered.map((d) => (
              <DesignCard
                key={d.id}
                design={d}
                shopName={d.tailor?.shop_name || 'Tailor Shop'}
                shopSlug={d.tailor?.shop_slug || ''}
                onInspect={(design) => setSelected(design as MarketplaceDesign)}
              />
            ))}
          </div>
        )}

        {/* Load More Section */}
        <div className="py-8 text-center">
          {hasMore ? (
            <button
              onClick={loadMore}
              disabled={loading}
              className="px-6 py-3 rounded-2xl bg-surface-900 hover:bg-surface-800 border border-slate-700/80 hover:border-brand-500/50 text-white font-semibold text-xs transition shadow-lg inline-flex items-center gap-2 active:scale-95 disabled:opacity-50"
            >
              {loading ? (
                <>
                  <RefreshCw className="h-4 w-4 animate-spin text-brand-400" />
                  <span>{t('common.loading')}</span>
                </>
              ) : (
                <span>{t('marketplace.load_more')}</span>
              )}
            </button>
          ) : (
            <p className="text-xs text-slate-500">{t('marketplace.no_more')}</p>
          )}
        </div>
      </main>

      {/* Customer Design Detail & Multi-Photo Carousel Modal */}
      <CustomerDesignDetailModal
        design={selected}
        tailor={
          selected?.tailor
            ? {
                id: selected.tailor_id,
                shop_name: selected.tailor.shop_name,
                shop_slug: selected.tailor.shop_slug,
                status: 'approved',
              }
            : { id: '', shop_name: '', shop_slug: '', status: 'approved' }
        }
        isOpen={!!selected}
        onClose={() => setSelected(null)}
        onView360={(d) => {
          setSelected(null);
          setViewer(d as MarketplaceDesign);
        }}
      />

      {/* 360 Photo Viewer Modal */}
      <PhotoViewer360Modal
        design={viewer}
        isOpen={!!viewer}
        onClose={() => setViewer(null)}
      />
    </div>
  );
}
