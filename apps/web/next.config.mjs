import { withSentryConfig } from '@sentry/nextjs/config';

/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  transpilePackages: ['@tailor-catalog/shared'],
  images: {
    remotePatterns: [
      {
        protocol: 'https',
        hostname: '**.supabase.co',
        pathname: '/storage/v1/object/public/**',
      },
      {
        protocol: 'https',
        hostname: 'res.cloudinary.com',
      },
    ],
  },
};

export default withSentryConfig(nextConfig, {
  // Sentry organisation + project slugs are read from environment variables
  // SENTRY_ORG and SENTRY_PROJECT during builds so we keep them out of source.
  silent: true,          // suppress non-error build output
  hideSourceMaps: true,  // don't expose source maps to the client bundle

  // Tree-shake Sentry logger in production to reduce bundle size.
  webpack: {
    treeshake: {
      removeDebugLogging: true,
    },
  },

  // Upload source maps only when SENTRY_AUTH_TOKEN is present (CI/CD).
  sourceMaps: {
    disable: !process.env.SENTRY_AUTH_TOKEN,
  },
});
