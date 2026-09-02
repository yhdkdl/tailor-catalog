import Link from 'next/link';
import type { Metadata } from 'next';
import { Scissors, QrCode, Sparkles, Globe } from 'lucide-react';

export const metadata: Metadata = {
  title: 'Tailor Catalog — Ethiopian Handcrafted Fashion',
  description:
    'Discover beautiful handcrafted Ethiopian fashion. Scan a tailor\'s QR code to browse their full design catalog and try on outfits virtually.',
};

export default function HomePage() {
  return (
    <div className="min-h-screen bg-[#0a0a0f] text-slate-100 flex flex-col">
      {/* Header */}
      <header className="p-5 sm:p-6 flex items-center gap-2">
        <div className="flex items-center gap-2 text-amber-400 font-bold text-lg tracking-tight">
          <Scissors className="w-5 h-5" />
          <span>Tailor Catalog</span>
        </div>
      </header>

      {/* Hero */}
      <main className="flex-1 flex flex-col items-center justify-center px-4 py-16 text-center">
        {/* Glow orb */}
        <div
          aria-hidden="true"
          className="absolute top-32 left-1/2 -translate-x-1/2 w-[500px] h-[500px] rounded-full"
          style={{
            background:
              'radial-gradient(circle, rgba(217,119,6,0.15) 0%, transparent 70%)',
            pointerEvents: 'none',
          }}
        />

        {/* Logo icon */}
        <div className="relative mb-8 flex items-center justify-center">
          <div
            className="w-24 h-24 rounded-3xl flex items-center justify-center shadow-2xl"
            style={{
              background: 'linear-gradient(135deg, #d97706 0%, #b45309 100%)',
              boxShadow: '0 0 60px rgba(217,119,6,0.35)',
            }}
          >
            <Scissors className="w-12 h-12 text-white" />
          </div>
          <span
            className="absolute -bottom-2 -right-2 w-8 h-8 rounded-full bg-emerald-500 flex items-center justify-center shadow-lg"
            style={{ boxShadow: '0 0 12px rgba(16,185,129,0.5)' }}
          >
            <Sparkles className="w-4 h-4 text-white" />
          </span>
        </div>

        {/* Heading */}
        <h1
          className="text-4xl sm:text-5xl md:text-6xl font-extrabold tracking-tight mb-4"
          style={{
            background: 'linear-gradient(135deg, #fbbf24 0%, #f59e0b 50%, #d97706 100%)',
            WebkitBackgroundClip: 'text',
            WebkitTextFillColor: 'transparent',
          }}
        >
          Ethiopian Fashion,
          <br />
          Reimagined
        </h1>

        {/* Tagline */}
        <p className="text-slate-400 text-base sm:text-lg max-w-sm sm:max-w-md mx-auto mb-10 leading-relaxed">
          Scan a tailor&apos;s QR code to browse designs, see pricing, and
          virtually try on outfits — all from your phone.
        </p>

        {/* QR call-to-action card */}
        <div
          className="w-full max-w-xs sm:max-w-sm rounded-3xl p-6 border border-slate-800 text-center space-y-4 mb-10"
          style={{ background: 'rgba(255,255,255,0.03)' }}
        >
          <div className="flex justify-center">
            <div
              className="w-14 h-14 rounded-2xl flex items-center justify-center"
              style={{ background: 'rgba(217,119,6,0.15)' }}
            >
              <QrCode className="w-7 h-7 text-amber-400" />
            </div>
          </div>
          <p className="text-sm text-slate-300 font-medium">
            Visit a tailor&apos;s shop and scan their QR code to open their
            personal design catalog.
          </p>
        </div>

        {/* Features row */}
        <div className="flex flex-wrap items-center justify-center gap-4 text-xs text-slate-500 mb-10">
          {[
            { icon: Globe, label: '4 Languages' },
            { icon: Sparkles, label: 'Virtual Try-On' },
            { icon: QrCode, label: 'Instant Access' },
          ].map(({ icon: Icon, label }) => (
            <div key={label} className="flex items-center gap-1.5">
              <Icon className="w-3.5 h-3.5 text-amber-500/70" />
              <span>{label}</span>
            </div>
          ))}
        </div>

        {/* Subtle tailor link hint */}
        <p className="text-xs text-slate-600">
          Are you a tailor?{' '}
          <Link
            href="/admin/login"
            className="text-amber-600 hover:text-amber-400 transition-colors underline underline-offset-2"
          >
            Sign in to your dashboard
          </Link>
        </p>
      </main>

      {/* Footer */}
      <footer className="p-5 text-center text-xs text-slate-600 border-t border-slate-800/60">
        © {new Date().getFullYear()} Tailor Catalog · Ethiopian Handcrafted Fashion Platform
      </footer>
    </div>
  );
}
