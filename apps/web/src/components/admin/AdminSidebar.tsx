'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { LayoutDashboard, Users, Image as ImageIcon, ShieldCheck, Sparkles, ExternalLink } from 'lucide-react';

export function AdminSidebar() {
  const pathname = usePathname();

  const navigation = [
    {
      name: 'Overview',
      href: '/admin',
      icon: LayoutDashboard,
      current: pathname === '/admin',
    },
    {
      name: 'Tailor Management',
      href: '/admin/tailors',
      icon: Users,
      current: pathname.startsWith('/admin/tailors'),
    },
    {
      name: 'Content Moderation',
      href: '/admin/designs',
      icon: ImageIcon,
      current: pathname.startsWith('/admin/designs'),
    },
  ];

  return (
    <aside className="w-64 flex-shrink-0 hidden md:flex flex-col bg-surface-900/90 border-r border-slate-800/80 backdrop-blur-xl">
      {/* Brand Header */}
      <div className="h-16 px-6 flex items-center gap-3 border-b border-slate-800/80">
        <div className="w-9 h-9 rounded-xl bg-gradient-to-tr from-brand-600 to-forest-500 p-0.5 shadow-md shadow-brand-500/10">
          <div className="w-full h-full bg-surface-950 rounded-xl flex items-center justify-center">
            <ShieldCheck className="w-5 h-5 text-brand-400" />
          </div>
        </div>
        <div>
          <span className="text-sm font-bold text-white tracking-wide block leading-none">Tailor Catalog</span>
          <span className="text-[10px] text-brand-400 font-medium uppercase tracking-wider block mt-1">Admin Portal</span>
        </div>
      </div>

      {/* Navigation Links */}
      <div className="flex-1 py-6 px-3 space-y-1.5 overflow-y-auto">
        <div className="px-3 pb-2 text-[11px] font-semibold text-slate-400 uppercase tracking-wider">
          Management
        </div>
        {navigation.map((item) => {
          const Icon = item.icon;
          return (
            <Link
              key={item.name}
              href={item.href}
              className={`flex items-center gap-3 px-3.5 py-2.5 rounded-xl text-sm font-medium transition-all ${
                item.current
                  ? 'bg-gradient-to-r from-brand-500/15 to-forest-500/10 text-brand-300 border border-brand-500/30 shadow-sm'
                  : 'text-slate-400 hover:text-slate-200 hover:bg-slate-800/50'
              }`}
            >
              <Icon className={`w-4 h-4 ${item.current ? 'text-brand-400' : 'text-slate-400'}`} />
              <span>{item.name}</span>
            </Link>
          );
        })}
      </div>

      {/* Bottom Status Card */}
      <div className="p-4 m-3 rounded-2xl bg-surface-950/80 border border-slate-800/80">
        <div className="flex items-center gap-2 text-forest-400 text-xs font-medium mb-1">
          <span className="relative flex h-2 w-2">
            <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-forest-400 opacity-75"></span>
            <span className="relative inline-flex rounded-full h-2 w-2 bg-forest-500"></span>
          </span>
          System Live
        </div>
        <p className="text-[11px] text-slate-400">Supabase Connected & Protected with RLS</p>
      </div>
    </aside>
  );
}
