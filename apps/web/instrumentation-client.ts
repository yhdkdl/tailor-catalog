// instrumentation-client.ts — Next.js client instrumentation hook
// Runs in the browser bundle — replaces the deprecated sentry.client.config.ts.
import * as Sentry from '@sentry/nextjs';

Sentry.init({
  dsn: process.env.NEXT_PUBLIC_SENTRY_DSN,

  // Performance tracing
  tracesSampleRate: process.env.NODE_ENV === 'production' ? 0.1 : 1.0,

  // Session replay
  replaysSessionSampleRate: 0.1,
  replaysOnErrorSampleRate: 1.0,

  integrations: [
    Sentry.replayIntegration(),
  ],

  enabled: !!process.env.NEXT_PUBLIC_SENTRY_DSN,
});

export function onRouterTransitionStart() {
  Sentry.startBrowserTracingNavigationSpan(Sentry.getCurrentScope().getClient()!, {
    name: 'navigation',
  });
}
