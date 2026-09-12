'use client';

import { useEffect } from 'react';
import * as Sentry from '@sentry/nextjs';
import { GracefulError } from '@/components/common/GracefulError';

export default function MarketplaceError({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  useEffect(() => {
    Sentry.captureException(error);
    console.error('Marketplace page error:', error);
  }, [error]);

  return (
    <div className="min-h-screen bg-surface-950 flex items-center justify-center p-4">
      <GracefulError
        onRetry={reset}
        showHomeButton={true}
      />
    </div>
  );
}
