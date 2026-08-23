'use client';

import React, { useState, useEffect, Suspense } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import { createClient } from '@/lib/supabase/client';
import { Lock, Mail, Eye, EyeOff, ShieldCheck, AlertCircle, Loader2 } from 'lucide-react';

function LoginFormContent() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [loading, setLoading] = useState(false);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);

  useEffect(() => {
    const err = searchParams.get('error');
    if (err === 'unauthorized') {
      setErrorMessage('Access denied. You do not have administrator permissions.');
    }
  }, [searchParams]);

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setErrorMessage(null);

    try {
      const supabase = createClient();
      
      const { data: authData, error: authError } = await supabase.auth.signInWithPassword({
        email: email.trim(),
        password,
      });

      if (authError || !authData.user) {
        setErrorMessage(authError?.message || 'Invalid login credentials.');
        setLoading(false);
        return;
      }

      // Verify that user is in admin_users table
      const { data: adminRecord, error: adminCheckError } = await supabase
        .from('admin_users')
        .select('id')
        .eq('auth_id', authData.user.id)
        .maybeSingle();

      if (adminCheckError || !adminRecord) {
        // Sign out since they are not an admin
        await supabase.auth.signOut();
        setErrorMessage('Access denied. This account is not authorized as an administrator.');
        setLoading(false);
        return;
      }

      // Success - redirect to /admin or requested URL
      const redirectUrl = searchParams.get('redirect') || '/admin';
      router.push(redirectUrl);
      router.refresh();
    } catch (err: any) {
      setErrorMessage(err.message || 'An unexpected error occurred during login.');
      setLoading(false);
    }
  };

  return (
    <div className="glass-panel rounded-2xl p-8 shadow-2xl border border-slate-800/80">
      <div className="mb-6">
        <h2 className="text-lg font-semibold text-white">Administrator Sign In</h2>
        <p className="text-xs text-slate-400 mt-1">Enter your admin email and password to access the panel</p>
      </div>

      {errorMessage && (
        <div className="mb-6 p-3.5 rounded-xl bg-rose-500/10 border border-rose-500/30 flex items-start gap-3 text-rose-300 text-sm animate-in fade-in">
          <AlertCircle className="w-5 h-5 flex-shrink-0 text-rose-400 mt-0.5" />
          <span>{errorMessage}</span>
        </div>
      )}

      <form onSubmit={handleLogin} className="space-y-5">
        <div>
          <label className="block text-xs font-medium text-slate-300 mb-1.5 uppercase tracking-wider">
            Admin Email
          </label>
          <div className="relative">
            <div className="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-slate-400">
              <Mail className="w-4 h-4" />
            </div>
            <input
              id="admin-email-input"
              type="email"
              required
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              placeholder="admin@tailorcatalog.com"
              className="w-full pl-10 pr-4 py-2.5 bg-surface-900/90 border border-slate-700/80 rounded-xl text-white placeholder-slate-500 text-sm focus:outline-none focus:ring-2 focus:ring-brand-500/50 focus:border-brand-500 transition-all"
            />
          </div>
        </div>

        <div>
          <label className="block text-xs font-medium text-slate-300 mb-1.5 uppercase tracking-wider">
            Password
          </label>
          <div className="relative">
            <div className="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-slate-400">
              <Lock className="w-4 h-4" />
            </div>
            <input
              id="admin-password-input"
              type={showPassword ? 'text' : 'password'}
              required
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              placeholder="••••••••••••"
              className="w-full pl-10 pr-11 py-2.5 bg-surface-900/90 border border-slate-700/80 rounded-xl text-white placeholder-slate-500 text-sm focus:outline-none focus:ring-2 focus:ring-brand-500/50 focus:border-brand-500 transition-all"
            />
            <button
              type="button"
              onClick={() => setShowPassword(!showPassword)}
              className="absolute inset-y-0 right-0 pr-3.5 flex items-center text-slate-400 hover:text-slate-200 transition-colors"
              tabIndex={-1}
            >
              {showPassword ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
            </button>
          </div>
        </div>

        <button
          id="admin-login-button"
          type="submit"
          disabled={loading}
          className="w-full mt-2 py-3 px-4 bg-gradient-to-r from-brand-600 to-forest-600 hover:from-brand-500 hover:to-forest-500 text-white font-medium text-sm rounded-xl shadow-lg shadow-brand-600/20 hover:shadow-brand-600/30 active:scale-[0.99] disabled:opacity-50 disabled:cursor-not-allowed transition-all flex items-center justify-center gap-2"
        >
          {loading ? (
            <>
              <Loader2 className="w-4 h-4 animate-spin" />
              <span>Verifying Credentials...</span>
            </>
          ) : (
            <span>Sign In to Admin Panel</span>
          )}
        </button>
      </form>

      <div className="mt-8 pt-6 border-t border-slate-800/80 text-center">
        <p className="text-xs text-slate-500">
          Ethiopian Tailor Catalog Platform &copy; 2026. Secure Admin Access.
        </p>
      </div>
    </div>
  );
}

export default function AdminLoginPage() {
  return (
    <div className="relative min-h-screen flex items-center justify-center p-4 bg-surface-950 overflow-hidden">
      {/* Background Decorative Gradient Orbs */}
      <div className="absolute -top-40 -left-40 w-96 h-96 bg-brand-500/10 rounded-full blur-3xl pointer-events-none" />
      <div className="absolute -bottom-40 -right-40 w-96 h-96 bg-forest-500/10 rounded-full blur-3xl pointer-events-none" />
      
      <div className="w-full max-w-md z-10">
        {/* Brand Header */}
        <div className="text-center mb-8">
          <div className="inline-flex items-center justify-center w-16 h-16 rounded-2xl bg-gradient-to-tr from-brand-600 to-forest-500 p-0.5 shadow-xl shadow-brand-500/10 mb-4">
            <div className="w-full h-full bg-surface-950 rounded-2xl flex items-center justify-center">
              <ShieldCheck className="w-8 h-8 text-brand-400" />
            </div>
          </div>
          <h1 className="text-2xl font-bold text-white tracking-tight">Tailor Catalog</h1>
          <p className="text-sm text-slate-400 mt-1">Admin Portal & Management Dashboard</p>
        </div>

        <Suspense fallback={<div className="glass-panel p-8 rounded-2xl text-center text-slate-400">Loading...</div>}>
          <LoginFormContent />
        </Suspense>
      </div>
    </div>
  );
}
