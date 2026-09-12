'use client';

import { useEffect } from 'react';
import { GracefulError } from '@/components/common/GracefulError';

export default function RootError({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  useEffect(() => {
    console.error('Unhandled app error:', error);
  }, [error]);

  return (
    <main className="min-h-screen bg-surface-950 flex items-center justify-center p-4">
      <GracefulError
        onRetry={reset}
        showHomeButton={true}
      />
    </main>
  );
}
