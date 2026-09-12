import React from 'react';

export function CatalogHeaderSkeleton() {
  return (
    <header className="border-b border-slate-800/80 bg-surface-950/80 backdrop-blur-xl">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4 sm:py-6">
        <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
          <div className="flex items-center gap-3 sm:gap-4">
            {/* Avatar skeleton */}
            <div className="w-12 h-12 sm:w-14 sm:h-14 rounded-2xl bg-slate-800 animate-pulse flex-shrink-0" />
            <div className="space-y-2">
              <div className="h-5 w-36 bg-slate-800 rounded animate-pulse" />
              <div className="h-3 w-24 bg-slate-800/70 rounded animate-pulse" />
            </div>
          </div>
          <div className="flex items-center gap-2">
            <div className="h-9 w-24 rounded-xl bg-slate-800 animate-pulse" />
            <div className="h-9 w-20 rounded-xl bg-slate-800 animate-pulse" />
          </div>
        </div>
      </div>
    </header>
  );
}

export function FilterBarSkeleton() {
  return (
    <div className="space-y-3">
      {/* Search Input skeleton */}
      <div className="h-10 w-full max-w-md rounded-xl bg-slate-800/80 animate-pulse" />
      {/* Category Pills skeleton */}
      <div className="flex gap-2 overflow-x-auto pb-1 scrollbar-none">
        {Array.from({ length: 6 }).map((_, i) => (
          <div
            key={i}
            className="h-8 w-24 rounded-xl bg-slate-800/60 animate-pulse flex-shrink-0"
          />
        ))}
      </div>
    </div>
  );
}

export function DesignGridSkeleton({ count = 6 }: { count?: number }) {
  return (
    <div className="grid grid-cols-2 sm:grid-cols-3 gap-3">
      {Array.from({ length: count }).map((_, i) => (
        <div
          key={i}
          className="glass-panel rounded-2xl sm:rounded-3xl border border-slate-800/80 bg-surface-900/60 overflow-hidden flex flex-col justify-between"
        >
          {/* Image skeleton */}
          <div className="relative h-[180px] sm:h-[160px] w-full bg-slate-800/80 animate-pulse">
            <div className="absolute inset-0 bg-gradient-to-t from-black/40 to-transparent" />
          </div>

          {/* Content skeleton */}
          <div className="p-2.5 sm:p-3 space-y-2">
            <div className="h-3.5 w-3/4 bg-slate-800 rounded animate-pulse" />
            <div className="h-2.5 w-1/2 bg-slate-800/70 rounded animate-pulse" />
          </div>
        </div>
      ))}
    </div>
  );
}

export function CatalogPageSkeleton() {
  return (
    <div className="min-h-screen bg-surface-950 text-slate-100 flex flex-col">
      <CatalogHeaderSkeleton />
      <main className="flex-1 max-w-7xl w-full mx-auto px-4 sm:px-6 lg:px-8 py-6 sm:py-8 space-y-6">
        <div className="space-y-1">
          <div className="h-7 w-48 bg-slate-800 rounded animate-pulse" />
          <div className="h-4 w-72 bg-slate-800/70 rounded animate-pulse" />
        </div>
        <FilterBarSkeleton />
        <DesignGridSkeleton count={9} />
      </main>
    </div>
  );
}
