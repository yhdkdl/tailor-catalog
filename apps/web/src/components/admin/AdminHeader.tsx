'use client';

import { useState } from 'react';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { SignOutButton } from './SignOutButton';
import { Shield, Menu, X, LayoutDashboard, Users, Image as ImageIcon } from 'lucide-react';

export function AdminHeader({ adminEmail }: { adminEmail: string }) {
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
  const pathname = usePathname();

  const navigation = [
    { name: 'Overview', href: '/admin', icon: LayoutDashboard, current: pathname === '/admin' },
    { name: 'Tailor Management', href: '/admin/tailors', icon: Users, current: pathname.startsWith('/admin/tailors') },
    { name: 'Content Moderation', href: '/admin/designs', icon: ImageIcon, current: pathname.startsWith('/admin/designs') },
  ];

  return (
    <header className="h-16 flex-shrink-0 bg-surface-900/80 border-b border-slate-800/80 px-4 sm:px-6 flex items-center justify-between backdrop-blur-xl sticky top-0 z-30">
      <div className="flex items-center gap-3">
        <button
          onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
          className="md:hidden p-2 rounded-xl text-slate-400 hover:text-white hover:bg-slate-800/60"
        >
          {mobileMenuOpen ? <X className="w-5 h-5" /> : <Menu className="w-5 h-5" />}
        </button>

        <div className="flex items-center gap-2">
          <span className="text-xs px-2.5 py-1 rounded-full bg-brand-500/10 text-brand-400 border border-brand-500/20 font-medium">
            Ethiopia Edition
          </span>
        </div>
      </div>

      <div className="flex items-center gap-4">
        <div className="flex items-center gap-3 pl-3 border-l border-slate-800">
          <div className="w-8 h-8 rounded-full bg-gradient-to-tr from-brand-600 to-forest-600 p-0.5 flex-shrink-0">
            <div className="w-full h-full bg-surface-900 rounded-full flex items-center justify-center">
              <Shield className="w-4 h-4 text-brand-400" />
            </div>
          </div>
          <div className="hidden sm:block text-left">
            <span className="text-xs font-semibold text-white block max-w-[180px] truncate leading-tight">
              {adminEmail}
            </span>
            <span className="text-[10px] text-forest-400 block font-medium">Master Administrator</span>
          </div>
        </div>

        <SignOutButton />
      </div>

      {/* Mobile Dropdown Navigation */}
      {mobileMenuOpen && (
        <div className="md:hidden absolute top-16 left-0 right-0 bg-surface-900 border-b border-slate-800 p-4 space-y-2 shadow-2xl z-50 animate-in slide-in-from-top duration-200">
          {navigation.map((item) => {
            const Icon = item.icon;
            return (
              <Link
                key={item.name}
                href={item.href}
                onClick={() => setMobileMenuOpen(false)}
                className={`flex items-center gap-3 px-4 py-3 rounded-xl text-sm font-medium ${
                  item.current
                    ? 'bg-brand-500/15 text-brand-300 border border-brand-500/30'
                    : 'text-slate-400 hover:text-white hover:bg-slate-800'
                }`}
              >
                <Icon className="w-4 h-4" />
                <span>{item.name}</span>
              </Link>
            );
          })}
        </div>
      )}
    </header>
  );
}
