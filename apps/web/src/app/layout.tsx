import type { Metadata } from 'next';
import './globals.css';

export const metadata: Metadata = {
  title: 'Tailor Catalog Admin | Ethiopian Fashion & Tailor Management',
  description: 'Administration and moderation portal for Ethiopian Tailor Catalog platform.',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en" className="dark">
      <body className="min-h-screen bg-surface-950 text-slate-100 antialiased selection:bg-brand-500 selection:text-white">
        {children}
      </body>
    </html>
  );
}
