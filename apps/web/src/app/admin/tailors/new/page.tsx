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
  Clock,
  Sparkles,
  ExternalLink,
} from 'lucide-react';

export default function NewTailorPage() {
  const router = useRouter();
  const [shopName, setShopName] = useState('');
  const [email, setEmail] = useState('');
  const [phone, setPhone] = useState('');
  const [loading, setLoading] = useState(false);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);
  const [createdTailor, setCreatedTailor] = useState<Tailor | null>(null);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setErrorMessage(null);

    try {
      const res = await createTailorByAdmin({
        shopName: shopName.trim(),
        email: email.trim(),
        phone: phone.trim() || undefined,
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
    setCreatedTailor(null);
    setErrorMessage(null);
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

      {/* Success State Card */}
      {createdTailor ? (
        <div className="glass-panel p-6 sm:p-8 rounded-3xl border border-forest-500/30 space-y-6 shadow-2xl animate-in zoom-in-95">
          <div className="flex items-center gap-3">
            <div className="w-12 h-12 rounded-2xl bg-forest-500/20 border border-forest-500/30 flex items-center justify-center text-forest-400 flex-shrink-0">
              <CheckCircle2 className="w-6 h-6" />
            </div>
            <div>
              <h2 className="text-lg font-bold text-white">Tailor Account Created Successfully!</h2>
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
              <span className="text-slate-400">Generated Shop Slug:</span>
              <span className="font-mono text-brand-400 bg-surface-950 px-2 py-0.5 rounded border border-slate-800">
                /{createdTailor.shop_slug}
              </span>
            </div>
            <div className="flex items-center justify-between">
              <span className="text-slate-400">Email Address:</span>
              <span className="text-white">{createdTailor.email}</span>
            </div>
            {createdTailor.phone && (
              <div className="flex items-center justify-between">
                <span className="text-slate-400">Phone Number:</span>
                <span className="text-white">{createdTailor.phone}</span>
              </div>
            )}
            <div className="flex items-center justify-between">
              <span className="text-slate-400">Initial Status:</span>
              <span className="inline-flex items-center gap-1 text-xs px-2.5 py-0.5 rounded-full bg-amber-500/15 text-amber-400 border border-amber-500/30 font-semibold">
                <Clock className="w-3 h-3" /> Pending Review
              </span>
            </div>
          </div>

          <div className="flex flex-col sm:flex-row items-center gap-3 pt-2">
            <Link
              href="/admin/tailors"
              className="w-full sm:w-auto flex-1 py-2.5 px-4 rounded-xl bg-forest-600 hover:bg-forest-500 text-white text-xs font-semibold text-center shadow-lg shadow-forest-600/20 transition"
            >
              View in Tailors Directory
            </Link>
            <button
              onClick={handleReset}
              className="w-full sm:w-auto py-2.5 px-4 rounded-xl bg-surface-800 hover:bg-surface-700 text-slate-200 text-xs font-semibold transition border border-slate-700"
            >
              Register Another Tailor
            </button>
          </div>
        </div>
      ) : (
        /* Registration Form */
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
                disabled={loading || !shopName || !email}
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
      )}
    </div>
  );
}
