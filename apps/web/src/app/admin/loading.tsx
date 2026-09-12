export default function AdminLoading() {
  return (
    <div className="p-6 space-y-6 max-w-7xl mx-auto">
      <div className="space-y-2">
        <div className="h-8 w-48 bg-slate-800 rounded animate-pulse" />
        <div className="h-4 w-72 bg-slate-800/70 rounded animate-pulse" />
      </div>

      {/* Metrics Row Skeleton */}
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
        {Array.from({ length: 3 }).map((_, i) => (
          <div
            key={i}
            className="glass-panel p-6 rounded-2xl border border-slate-800 bg-surface-900/60 space-y-3"
          >
            <div className="h-4 w-28 bg-slate-800 rounded animate-pulse" />
            <div className="h-8 w-16 bg-slate-800 rounded animate-pulse" />
          </div>
        ))}
      </div>

      {/* Table / List Skeleton */}
      <div className="glass-panel rounded-2xl border border-slate-800 bg-surface-900/40 p-6 space-y-4">
        <div className="h-5 w-36 bg-slate-800 rounded animate-pulse" />
        <div className="space-y-3">
          {Array.from({ length: 5 }).map((_, i) => (
            <div
              key={i}
              className="h-12 w-full bg-slate-800/50 rounded-xl animate-pulse"
            />
          ))}
        </div>
      </div>
    </div>
  );
}
