import type { Metadata } from 'next';
import './globals.css';
import { LanguageProvider } from '@/lib/i18n/LanguageContext';
import { FavoritesProvider } from '@/lib/favorites/FavoritesContext';
import { LanguagePickerModal } from '@/components/i18n/LanguagePickerModal';

export const metadata: Metadata = {
  title: 'Tailor Catalog | Ethiopian Fashion & Tailor Management',
  description: 'Digital catalog and 360 photo viewer portal for Ethiopian tailoring and handcrafted fashion.',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en" className="dark">
      <body className="min-h-screen bg-surface-950 text-slate-100 antialiased selection:bg-brand-500 selection:text-white">
        <LanguageProvider>
          <FavoritesProvider>
            {children}
            <LanguagePickerModal />
          </FavoritesProvider>
        </LanguageProvider>
      </body>
    </html>
  );
}
