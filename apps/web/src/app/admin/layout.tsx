import { createClient } from '@/lib/supabase/server';
import { AdminSidebar } from '@/components/admin/AdminSidebar';
import { AdminHeader } from '@/components/admin/AdminHeader';
import { headers } from 'next/headers';

export default async function AdminLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const headersList = headers();
  // Get current pathname if available from middleware header
  const pathname = headersList.get('x-pathname') || '';
  
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();

  // If user is not logged in or on login page, let login page render full screen
  if (!user) {
    return <>{children}</>;
  }

  return (
    <div className="min-h-screen flex bg-surface-950 text-slate-100">
      {/* Sidebar */}
      <AdminSidebar />

      {/* Main Content Area */}
      <div className="flex-1 flex flex-col min-w-0">
        <AdminHeader adminEmail={user.email || 'Admin'} />

        <main className="flex-1 p-4 sm:p-6 lg:p-8 overflow-y-auto max-w-7xl w-full mx-auto">
          {children}
        </main>
      </div>
    </div>
  );
}
