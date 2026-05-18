# Uganda Diaspora Platform

A national-level digital platform connecting the Ugandan diaspora worldwide — with a React/Vite Admin Dashboard, Express/Node.js backend APIs, PostgreSQL database, and a Flutter mobile app.

## Run & Operate

- `pnpm --filter @workspace/api-server run dev` — run the API server (port 8080, proxied at `/api`)
- `pnpm --filter @workspace/admin-dashboard run dev` — run the admin dashboard (port 22133, proxied at `/`)
- `pnpm run typecheck` — full typecheck across all packages
- `pnpm run build` — typecheck + build all packages
- `pnpm --filter @workspace/api-spec run codegen` — regenerate API hooks and Zod schemas from the OpenAPI spec
- `pnpm --filter @workspace/db run push` — push DB schema changes (dev only)
- Required env: `DATABASE_URL` — Postgres connection string, `SESSION_SECRET` — JWT signing secret

## Stack

- pnpm workspaces, Node.js 24, TypeScript 5.9
- API: Express 5 (port 8080, base path `/api`)
- DB: PostgreSQL + Drizzle ORM
- Validation: Zod (`zod/v4`), `drizzle-zod`
- API codegen: Orval (from OpenAPI spec)
- Build: esbuild (CJS bundle)
- Admin Dashboard: React + Vite + Shadcn UI + TanStack Query + Wouter

## Where things live

- `lib/db/src/schema/` — all 11 Drizzle table definitions (source of truth for DB schema)
- `lib/api-spec/openapi.yaml` — OpenAPI spec (source of truth for API contract)
- `lib/api-zod/src/generated/api.ts` — generated Zod schemas (do not edit manually)
- `artifacts/api-server/src/routes/` — 13 route modules (auth, users, news, embassies, tourism, webinars, events, posts, notifications, mdas, opportunities, dashboard)
- `artifacts/api-server/src/lib/serialize.ts` — `serializeRow/serializeRows` helpers for Date→ISO string conversion before Zod parse
- `artifacts/admin-dashboard/src/pages/` — one page per resource (login, dashboard, news, users, embassies, tourism, webinars, events, community, opportunities, notifications, mdas)
- `artifacts/admin-dashboard/src/lib/api.ts` — fetch wrapper with auth token injection
- `flutter/uganda_diaspora_app/` — Flutter mobile app (run on local machine)

## Architecture decisions

- Auth: JWT-style tokens (base64 payload + SHA256 HMAC signature), stored in localStorage (`diaspora_token` on web, `auth_token` on Flutter)
- Password hashing: SHA256 + static salt `diaspora_salt_2024` (simple for demo; upgrade to bcrypt for production)
- All API responses serialize DB `Date` objects to ISO strings via `serializeRow/serializeRows` before Zod validation to avoid parse failures
- Date fields: `createdAt` uses `zod.coerce.date()` (accepts both strings and Dates), `publishedAt` uses `zod.string().nullish()` (always serialized before parse)
- Flutter base URL is a placeholder `https://your-api-domain.replit.app/api` — update after deployment

## Product

- **Admin Dashboard** (`/`): Login, stats overview, full CRUD for all 11 content types
- **Mobile App** (Flutter): Splash, login/register, home feed, news, embassies, tourism, webinars, events, community, opportunities, notifications, profile
- **APIs** (`/api`): 13 route groups with Zod validation, JWT auth, and full CRUD

## Demo Credentials

- Admin: `admin@ugandadiaspora.go.ug` / `Admin@2024!`
- Member: `john.doe@example.com` / `Test@1234`

## User preferences

- Flutter (not Expo) for mobile app — all Flutter files live in `flutter/uganda_diaspora_app/`
- Admin dashboard uses yellow/slate color scheme matching Uganda flag aesthetics

## Gotchas

- Always call `serializeRow/serializeRows` before `.parse()` on any DB result — Drizzle returns `Date` objects but Zod schemas may expect strings
- The auth.ts token uses `SESSION_SECRET` env var; falls back to `"secret"` in development
- `pnpm --filter @workspace/db run push` must be run after any schema changes
- Flutter app needs `flutter pub get` and correct base URL before running

## Pointers

- See the `pnpm-workspace` skill for workspace structure, TypeScript setup, and package details
