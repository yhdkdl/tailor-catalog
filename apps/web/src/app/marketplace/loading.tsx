import { DesignGridSkeleton, FilterBarSkeleton } from '@/components/catalog/CatalogSkeleton';

export default function MarketplaceLoading() {
  return (
    <main className="min-h-screen bg-surface-950 text-slate-100 px-4 py-6 sm:px-8">
      <div className="mx-auto max-w-7xl space-y-6">
        <div className="h-8 w-40 bg-slate-800 rounded animate-pulse" />
        <FilterBarSkeleton />
        <DesignGridSkeleton count={12} />
      </div>
    </main>
  );
}
