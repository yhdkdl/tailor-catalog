'use client';

import { useState } from 'react';
import { useLanguage } from '@/lib/i18n/LanguageContext';
import { CatalogDesign, CatalogTailor } from './types';
import { DesignCard } from './DesignCard';
import { CustomerDesignDetailModal } from './CustomerDesignDetailModal';
import { PhotoViewer360Modal } from './PhotoViewer360Modal';

export default function HomeTrendingPreview({ designs }: { designs: CatalogDesign[] }) {
  const { t } = useLanguage();
  const [selected, setSelected] = useState<CatalogDesign | null>(null);
  const [viewer, setViewer] = useState<CatalogDesign | null>(null);
  if (!designs.length) return null;
  const tailor = (design: CatalogDesign): CatalogTailor => ({ id: design.tailor_id, shop_name: (design as CatalogDesign & { tailor?: { shop_name: string } }).tailor?.shop_name || 'Tailor Shop', shop_slug: (design as CatalogDesign & { tailor?: { shop_slug: string } }).tailor?.shop_slug || '', status: 'approved' });
  return <section className="mx-auto w-full max-w-6xl px-4 pb-10"><div className="mb-4 flex items-center justify-between"><h2 className="text-xl font-bold text-white">{t('trending.preview_title')}</h2><a href="/marketplace?filter=trending" className="text-xs font-semibold text-brand-400">{t('trending.preview_link')}</a></div><div className="grid grid-cols-2 gap-3 sm:grid-cols-3">{designs.map((design) => <DesignCard key={design.id} design={design} shopName={tailor(design).shop_name} shopSlug={tailor(design).shop_slug} onInspect={setSelected} />)}</div><CustomerDesignDetailModal design={selected} tailor={selected ? tailor(selected) : { id: '', shop_name: '', shop_slug: '', status: 'approved' }} isOpen={!!selected} onClose={() => setSelected(null)} onView360={(design) => { setSelected(null); setViewer(design); }} /><PhotoViewer360Modal design={viewer} isOpen={!!viewer} onClose={() => setViewer(null)} /></section>;
}
