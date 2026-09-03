'use client';

import { useEffect, useMemo, useState } from 'react';
import { useLanguage } from '@/lib/i18n/LanguageContext';
import { CatalogCategory, CatalogDesign } from './types';
import { DesignCard } from './DesignCard';
import { CustomerDesignDetailModal } from './CustomerDesignDetailModal';
import { PhotoViewer360Modal } from './PhotoViewer360Modal';

type MarketplaceDesign = CatalogDesign & { tailor: { shop_name: string; shop_slug: string } };

export function MarketplaceViewClient({ designs, categories, initialTrending = false }: { designs: MarketplaceDesign[]; categories: CatalogCategory[]; initialTrending?: boolean }) {
  const { t, getCategoryName } = useLanguage();
  const [query, setQuery] = useState('');
  const [category, setCategory] = useState('all');
  const [tailor, setTailor] = useState('all');
  const [trending, setTrending] = useState(initialTrending);
  const [items, setItems] = useState(designs);
  const [page, setPage] = useState(1);
  const [loading, setLoading] = useState(false);
  const [hasMore, setHasMore] = useState(designs.length === 20);
  const [selected, setSelected] = useState<MarketplaceDesign | null>(null);
  const [viewer, setViewer] = useState<MarketplaceDesign | null>(null);
  const tailors = Array.from(new Map(items.map((d) => [d.tailor.shop_slug, d.tailor])).values());
  const filtered = useMemo(() => designs.filter((d) => {
    if (category !== 'all' && d.category_id !== category) return false;
    if (tailor !== 'all' && d.tailor.shop_slug !== tailor) return false;
    if (trending && !d.is_trending) return false;
    return !query.trim() || (d.tag || '').toLowerCase().includes(query.toLowerCase().trim());
  }), [items, category, tailor, trending, query]);
  const loadMore = async () => {
    if (loading || !hasMore) return;
    setLoading(true);
    try {
      const response = await fetch(`/api/marketplace?page=${page}`);
      const next = await response.json() as MarketplaceDesign[];
      setItems((current) => [...current, ...next]);
      setPage((current) => current + 1);
      setHasMore(next.length === 20);
    } finally { setLoading(false); }
  };
  useEffect(() => {
    const onScroll = () => { if (window.innerHeight + window.scrollY >= document.body.offsetHeight - 500) loadMore(); };
    window.addEventListener('scroll', onScroll);
    return () => window.removeEventListener('scroll', onScroll);
  });
  return <main className="min-h-screen bg-surface-950 text-slate-100 px-4 py-6 sm:px-8">
    <div className="mx-auto max-w-7xl space-y-5">
      <h1 className="text-2xl font-bold">{t('marketplace.title')}</h1>
      <div className="flex flex-wrap gap-2">
        <button onClick={() => setTrending(false)} className={!trending ? 'bg-brand-500 text-black px-3 py-2 rounded-xl text-xs font-bold' : 'bg-surface-900 px-3 py-2 rounded-xl text-xs'}>{t('marketplace.all_tab')}</button>
        <button onClick={() => setTrending(true)} className={trending ? 'bg-brand-500 text-black px-3 py-2 rounded-xl text-xs font-bold' : 'bg-surface-900 px-3 py-2 rounded-xl text-xs'}>{t('marketplace.trending_tab')}</button>
        <input value={query} onChange={(e) => setQuery(e.target.value)} placeholder={t('catalog.search_placeholder')} className="min-w-48 flex-1 rounded-xl border border-slate-700 bg-surface-900 px-3 py-2 text-xs" />
        <select value={category} onChange={(e) => setCategory(e.target.value)} className="rounded-xl border border-slate-700 bg-surface-900 px-3 py-2 text-xs"><option value="all">{t('catalog.all_categories')}</option>{categories.map((c) => <option key={c.id} value={c.id}>{getCategoryName(c)}</option>)}</select>
        <select value={tailor} onChange={(e) => setTailor(e.target.value)} className="rounded-xl border border-slate-700 bg-surface-900 px-3 py-2 text-xs"><option value="all">{t('marketplace.filter_tailor')}</option>{tailors.map((s) => <option key={s.shop_slug} value={s.shop_slug}>{s.shop_name}</option>)}</select>
      </div>
      {filtered.length === 0 ? <p className="py-16 text-center text-slate-400">{t('catalog.no_designs')}</p> : <div className="grid grid-cols-2 gap-3 sm:grid-cols-3">{filtered.map((d) => <DesignCard key={d.id} design={d} shopName={d.tailor.shop_name} shopSlug={d.tailor.shop_slug} onInspect={(design) => setSelected(design as MarketplaceDesign)} />)}</div>}
      <div className="py-6 text-center text-sm text-slate-400">{loading ? <span className="inline-flex items-center gap-2"><span className="h-4 w-4 animate-spin rounded-full border-2 border-brand-400 border-t-transparent" />{t('common.loading')}</span> : hasMore ? t('marketplace.load_more') : t('marketplace.no_more')}</div>
    </div>
    <CustomerDesignDetailModal design={selected} tailor={selected ? { id: selected.tailor_id, shop_name: selected.tailor.shop_name, shop_slug: selected.tailor.shop_slug, status: 'approved' } : { id: '', shop_name: '', shop_slug: '', status: 'approved' }} isOpen={!!selected} onClose={() => setSelected(null)} onView360={(d) => { setSelected(null); setViewer(d as MarketplaceDesign); }} />
    <PhotoViewer360Modal design={viewer} isOpen={!!viewer} onClose={() => setViewer(null)} />
  </main>;
}
