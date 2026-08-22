# Tailor Catalog

A QR-based fashion design catalog platform for local tailor businesses.

## Apps

| App | Tech | Purpose |
|-----|------|---------|
| `apps/web` | Next.js + Vercel | Admin panel + Customer catalog |
| `apps/mobile` | Flutter | Tailor app (iOS + Android) |
| `packages/shared` | TypeScript | Shared types |

## Languages Supported
- English (en)
- Amharic / አማርኛ (am)
- Oromifa / Afaan Oromoo (om)
- Somali / Af Soomaali (so)

## Branch Strategy

| Branch | Purpose |
|--------|---------|
| `main` | Production only — never commit directly |
| `develop` | Integration branch — all features merge here |
| `feature/sprint-X-name` | One branch per sprint |

## Commit Convention
- `feat:` new feature
- `fix:` bug fix
- `chore:` config or setup
- `docs:` documentation only