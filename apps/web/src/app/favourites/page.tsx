'use client';

import Link from 'next/link';
import { useFavorites } from '@/lib/favorites/FavoritesContext';
import { useLanguage } from '@/lib/i18n/LanguageContext';
import { Heart, Trash2 } from 'lucide-react';

export default function FavouritesPage() {
  const { favorites, removeFavorite } = useFavorites();
  const { t } = useLanguage();
  return <main className="min-h-screen bg-surface-950 px-4 py-8 text-slate-100 sm:px-8">
    <div className="mx-auto max-w-7xl space-y-6">
      <h1 className="text-2xl font-bold">{t('favourites.title')}</h1>
      {favorites.length === 0 ? <div className="py-20 text-center text-slate-400"><Heart className="mx-auto mb-3 h-10 w-10" />{t('favourites.empty')}<p className="mt-2 text-sm">{t('favourites.empty_desc')}</p><Link className="mt-5 inline-block rounded-xl bg-brand-500 px-4 py-2 text-sm font-bold text-black" href="/marketplace">{t('favourites.browse')}</Link></div> : <div className="grid grid-cols-2 gap-3 sm:grid-cols-3">{favorites.map((design) => <article key={design.id} className="overflow-hidden rounded-2xl border border-slate-800 bg-surface-900"><img src={design.cloudinary_url} alt={design.tag || design.category} className="h-[180px] w-full object-cover sm:h-[160px]" /><div className="flex items-center justify-between gap-2 p-3"><div className="min-w-0"><p className="truncate text-sm font-semibold">{design.category}</p>{design.tag && <p className="truncate text-xs text-slate-400">{design.tag}</p>}<p className="truncate text-xs text-slate-500">{design.shop_name}</p></div><button onClick={() => removeFavorite(design.id)} title={t('favourites.remove')} className="rounded-lg p-2 text-slate-400 hover:text-rose-400"><Trash2 className="h-4 w-4" /></button></div></article>)}</div>}
    </div>
  </main>;
}
