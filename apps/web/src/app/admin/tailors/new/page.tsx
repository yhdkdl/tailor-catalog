'use client';

import React, { useState } from 'react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { createTailorByAdmin } from '@/app/admin/actions';
import { Tailor } from '@tailor-catalog/shared';
import {
  UserPlus,
  Store,
  Mail,
  Phone,
  ArrowLeft,
  CheckCircle2,
  AlertCircle,
  Loader2,
  Copy,
  Eye,
  EyeOff,
} from 'lucide-react';

export default function NewTailorPage() {
  const router = useRouter();
  const [shopName, setShopName] = useState('');
  const [email, setEmail] = useState('');
  const [phone, setPhone] = useState('');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [showConfirmPassword, setShowConfirmPassword] = useState(false);
  const [passwordCopied, setPasswordCopied] = useState(false);
  const [loading, setLoading] = useState(false);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);
  const [createdTailor, setCreatedTailor] = useState<Tailor | null>(null);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (password.length < 8) {
      setErrorMessage('Password must be at least 8 characters.');
      return;
    }
    if (password !== confirmPassword) {
      setErrorMessage('Passwords do not match.');
      return;
    }
    setLoading(true);
    setErrorMessage(null);

    try {
      const res = await createTailorByAdmin({
        shopName: shopName.trim(),
        email: email.trim(),
        phone: phone.trim() || undefined,
        password,
      });

      if (!res.success) {
        setErrorMessage(res.error || 'Failed to register tailor.');
        setLoading(false);
        return;
      }

      setCreatedTailor(res.tailor);
      setLoading(false);
    } catch (err: any) {
      setErrorMessage(err.message || 'An unexpected error occurred.');
      setLoading(false);
    }
  };

  const handleReset = () => {
    setShopName('');
    setEmail('');
    setPhone('');
    setPassword('');
    setConfirmPassword('');
    setCreatedTailor(null);
    setPasswordCopied(false);
    setErrorMessage(null);
  };

  const handleCopyPassword = async () => {
    await navigator.clipboard.writeText(password);
    setPasswordCopied(true);
  };

  const handleDone = () => {
    handleReset();
    router.push('/admin/tailors');
  };

  return (
    <div className="max-w-2xl mx-auto space-y-6 animate-in fade-in duration-300">
      {/* Back Link & Header */}
      <div>
        <Link
          href="/admin/tailors"
          className="inline-flex items-center gap-2 text-xs font-medium text-slate-400 hover:text-slate-200 transition mb-4"
        >
          <ArrowLeft className="w-3.5 h-3.5" />
          <span>Back to Tailors Directory</span>
        </Link>

        <div className="flex items-center gap-3">
          <div className="w-10 h-10 rounded-2xl bg-gradient-to-tr from-brand-600 to-forest-500 p-0.5 flex items-center justify-center shadow-lg shadow-brand-500/10">
            <div className="w-full h-full bg-surface-950 rounded-2xl flex items-center justify-center">
              <UserPlus className="w-5 h-5 text-brand-400" />
            </div>
          </div>
          <div>
            <h1 className="text-2xl font-bold text-white tracking-tight">Register New Tailor</h1>
            <p className="text-xs text-slate-400 mt-0.5">
              Directly onboard a local tailor shop to the catalog platform.
            </p>
          </div>
        </div>
      </div>

      {createdTailor && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-slate-950/80 p-4" role="dialog" aria-modal="true" aria-labelledby="tailor-created-title">
          <div className="glass-panel w-full max-w-lg p-6 sm:p-8 rounded-3xl border border-forest-500/30 space-y-6 shadow-2xl animate-in zoom-in-95">
          <div className="flex items-center gap-3">
            <div className="w-12 h-12 rounded-2xl bg-forest-500/20 border border-forest-500/30 flex items-center justify-center text-forest-400 flex-shrink-0">
              <CheckCircle2 className="w-6 h-6" />
            </div>
            <div>
              <h2 id="tailor-created-title" className="text-lg font-bold text-white">Tailor account created successfully</h2>
              <p className="text-xs text-slate-400">
                The account has been created in Supabase Auth and registered with status: <strong>Pending Review</strong>.
              </p>
            </div>
          </div>

          <div className="p-4 rounded-2xl bg-surface-900/90 border border-slate-800 space-y-3 text-xs">
            <div className="flex items-center justify-between">
              <span className="text-slate-400">Shop Name:</span>
              <span className="text-white font-semibold">{createdTailor.shop_name}</span>
            </div>
            <div className="flex items-center justify-between">
              <span className="text-slate-400">Email:</span>
              <span className="text-white">{createdTailor.email}</span>
            </div>
            <div className="flex items-center justify-between">
              <span className="text-slate-400">Temporary password:</span>
              <span className="font-mono text-white">{password}</span>
            </div>
          </div>

          <div className="flex flex-col sm:flex-row items-center gap-3 pt-2">
            <button
              type="button"
              onClick={handleCopyPassword}
              className="w-full sm:w-auto flex-1 py-2.5 px-4 rounded-xl bg-surface-800 hover:bg-surface-700 text-slate-200 text-xs font-semibold transition border border-slate-700 inline-flex items-center justify-center gap-2"
            >
              <Copy className="w-4 h-4" /> {passwordCopied ? 'Copied' : 'Copy password to clipboard'}
            </button>
            <button type="button" onClick={handleDone} className="w-full sm:w-auto py-2.5 px-6 rounded-xl bg-forest-600 hover:bg-forest-500 text-white text-xs font-semibold transition">Done</button>
          </div>
        </div>
        </div>
      )}
      {/* Registration Form */}
        <div className="glass-panel p-6 sm:p-8 rounded-3xl border border-slate-800/80 shadow-2xl">
          {errorMessage && (
            <div className="mb-6 p-4 rounded-2xl bg-rose-500/10 border border-rose-500/30 flex items-start gap-3 text-rose-300 text-xs animate-in fade-in">
              <AlertCircle className="w-4 h-4 flex-shrink-0 text-rose-400 mt-0.5" />
              <span>{errorMessage}</span>
            </div>
          )}

          <form onSubmit={handleSubmit} className="space-y-5">
            {/* Shop Name */}
            <div>
              <label className="block text-xs font-medium text-slate-300 mb-1.5 uppercase tracking-wider">
                Shop Name <span className="text-rose-400">*</span>
              </label>
              <div className="relative">
                <div className="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-slate-400">
                  <Store className="w-4 h-4" />
                </div>
                <input
                  id="create-tailor-shop-name"
                  type="text"
                  required
                  value={shopName}
                  onChange={(e) => setShopName(e.target.value)}
                  placeholder="e.g. Addis Habesha Tailors"
                  className="w-full pl-10 pr-4 py-2.5 bg-surface-900/90 border border-slate-700/80 rounded-xl text-white placeholder-slate-500 text-xs focus:outline-none focus:ring-2 focus:ring-brand-500/50 focus:border-brand-500 transition"
                />
              </div>
              <p className="text-[11px] text-slate-500 mt-1">
                A URL slug will be automatically created from this shop name (e.g. /addis-habesha-tailors).
              </p>
            </div>

            {/* Email Address */}
            <div>
              <label className="block text-xs font-medium text-slate-300 mb-1.5 uppercase tracking-wider">
                Email Address <span className="text-rose-400">*</span>
              </label>
              <div className="relative">
                <div className="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-slate-400">
                  <Mail className="w-4 h-4" />
                </div>
                <input
                  id="create-tailor-email"
                  type="email"
                  required
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  placeholder="tailor@example.com"
                  className="w-full pl-10 pr-4 py-2.5 bg-surface-900/90 border border-slate-700/80 rounded-xl text-white placeholder-slate-500 text-xs focus:outline-none focus:ring-2 focus:ring-brand-500/50 focus:border-brand-500 transition"
                />
              </div>
              <p className="text-[11px] text-slate-500 mt-1">
                Used for tailor login. Email confirmation is automatically pre-verified.
              </p>
            </div>

            {/* Password */}
            <div>
              <label className="block text-xs font-medium text-slate-300 mb-1.5 uppercase tracking-wider">
                Initial Password <span className="text-rose-400">*</span>
              </label>
              <div className="relative">
                <input
                  id="create-tailor-password"
                  type={showPassword ? 'text' : 'password'}
                  required
                  minLength={8}
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  placeholder="Min. 8 characters"
                  className="w-full pl-4 pr-10 py-2.5 bg-surface-900/90 border border-slate-700/80 rounded-xl text-white placeholder-slate-500 text-xs focus:outline-none focus:ring-2 focus:ring-brand-500/50 focus:border-brand-500 transition"
                />
                <button
                  type="button"
                  onClick={() => setShowPassword((v) => !v)}
                  className="absolute inset-y-0 right-0 pr-3 flex items-center text-slate-400 hover:text-slate-200 transition"
                  tabIndex={-1}
                >
                  {showPassword ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
                </button>
              </div>
              <p className="text-[11px] text-slate-500 mt-1">
                The tailor will use this password to sign in on the mobile app.
              </p>
            </div>

            {/* Confirm Password */}
            <div>
              <label className="block text-xs font-medium text-slate-300 mb-1.5 uppercase tracking-wider">
                Confirm Password <span className="text-rose-400">*</span>
              </label>
              <div className="relative">
                <input
                  id="create-tailor-confirm-password"
                  type={showConfirmPassword ? 'text' : 'password'}
                  required
                  minLength={8}
                  value={confirmPassword}
                  onChange={(e) => setConfirmPassword(e.target.value)}
                  placeholder="Re-enter password"
                  className="w-full pl-4 pr-10 py-2.5 bg-surface-900/90 border border-slate-700/80 rounded-xl text-white placeholder-slate-500 text-xs focus:outline-none focus:ring-2 focus:ring-brand-500/50 focus:border-brand-500 transition"
                />
                <button
                  type="button"
                  onClick={() => setShowConfirmPassword((v) => !v)}
                  className="absolute inset-y-0 right-0 pr-3 flex items-center text-slate-400 hover:text-slate-200 transition"
                  aria-label="Show or hide confirm password"
                >
                  {showConfirmPassword ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
                </button>
              </div>
            </div>

            {/* Phone Number */}
            <div>
              <label className="block text-xs font-medium text-slate-300 mb-1.5 uppercase tracking-wider">
                Phone Number <span className="text-slate-500">(Optional)</span>
              </label>
              <div className="relative">
                <div className="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-slate-400">
                  <Phone className="w-4 h-4" />
                </div>
                <input
                  id="create-tailor-phone"
                  type="tel"
                  value={phone}
                  onChange={(e) => setPhone(e.target.value)}
                  placeholder="+251 91 123 4567"
                  className="w-full pl-10 pr-4 py-2.5 bg-surface-900/90 border border-slate-700/80 rounded-xl text-white placeholder-slate-500 text-xs focus:outline-none focus:ring-2 focus:ring-brand-500/50 focus:border-brand-500 transition"
                />
              </div>
            </div>

            {/* Submit Button */}
            <div className="pt-2">
              <button
                id="create-tailor-submit-btn"
                type="submit"
                disabled={loading || !shopName || !email || password.length < 8 || password !== confirmPassword}
                className="w-full py-3 px-4 bg-gradient-to-r from-brand-600 to-forest-600 hover:from-brand-500 hover:to-forest-500 text-white font-semibold text-xs rounded-xl shadow-lg shadow-brand-600/20 active:scale-[0.99] disabled:opacity-50 disabled:cursor-not-allowed transition flex items-center justify-center gap-2"
              >
                {loading ? (
                  <>
                    <Loader2 className="w-4 h-4 animate-spin" />
                    <span>Creating Tailor Account in Supabase...</span>
                  </>
                ) : (
                  <>
                    <UserPlus className="w-4 h-4" />
                    <span>Register Tailor Account</span>
                  </>
                )}
              </button>
            </div>
          </form>
        </div>
    </div>
  );
}
