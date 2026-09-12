'use client';

import { useEffect } from 'react';
import { GracefulError } from '@/components/common/GracefulError';

export default function AdminError({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  useEffect(() => {
    console.error('Admin panel error:', error);
  }, [error]);

  return (
    <div className="min-h-screen bg-surface-950 flex items-center justify-center p-4">
      <GracefulError
        title="Admin Panel Error"
        message="A database or network error occurred while loading administration data."
        onRetry={reset}
        showHomeButton={true}
      />
    </div>
  );
}
