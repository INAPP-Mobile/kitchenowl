# KitchenOwl

KitchenOwl is a self-hosted household organizer for groceries, recipes, meal plans, and shared expenses — one app for the whole household, with a Flutter web client and a Python backend. Deploy it on Railway and every member of the household shares the same shopping lists, recipes, and expense tracking from any browser.

[![Deploy on Railway](https://railway.app/button.svg)](https://railway.com/deploy/kitchenowl?utm_campaign=kitchenowl)

## Source Repository

[https://github.com/INAPP-Mobile/kitchenowl](https://github.com/INAPP-Mobile/kitchenowl)

## Deploy and Host

One-click deploy creates a single KitchenOwl service with a persistent volume. No database companion is needed: KitchenOwl stores its data in SQLite on the volume. On first boot the app runs its database migrations and imports its default grocery items, then serves the web client on Railway's injected `PORT` (the wrapper maps it onto uWSGI's public socket).

After deploy, open the public URL and complete onboarding: create the owner account (username + password, no email required). Public registration stays closed after that, so nobody else can claim accounts on your instance.

## Why Deploy

- Shared shopping lists the whole household edits in real time, with item suggestions based on what you usually buy.
- Recipes with ingredient parsing, meal planning, and a planner that feeds the shopping list.
- Shared expense tracking for the household, in the same app as the groceries.
- Everything self-hosted: your household's lists, recipes, and expenses live on your own Railway volume, not a third-party cloud.

## Common Use Cases

- A family sharing one grocery list across phones and browsers.
- Meal planning for the week, with the planner generating the shopping list.
- Tracking shared household expenses alongside the groceries they came from.
- Keeping a household recipe collection with web-imported recipes.

## Configuration

Only one variable appears on the deploy form, and it is generated:

| Variable | Default | Description |
| --- | --- | --- |
| `JWT_SECRET_KEY` | `${{secret(32)}}` | Secret key signing session tokens. Generated on deploy; keep it stable across restarts or all sessions are invalidated. |

Everything else is baked into the image. Applicable upstream variables and their baked values:

| Variable | Value | Description |
| --- | --- | --- |
| `STORAGE_PATH` | `/data` | Volume path; SQLite database at `/data/database.db`, uploads at `/data/upload`. |
| `DB_DRIVER` | `sqlite` | Database backend (SQLite on the volume; no companion needed). |
| `OPEN_REGISTRATION` | `false` | Public account registration stays closed after first-owner onboarding. |
| `EMAIL_MANDATORY` | `false` | Onboarding is username-only; no email verification step. |
| `COLLECT_METRICS` | `false` | Prometheus metrics endpoint disabled. |
| `DISABLE_ONBOARDING` | unset (false) | First-run onboarding stays open so the deployer can create the owner account. |
| `FRONT_URL` | unset | Not needed: the web client calls same-origin `/api` paths, so no CORS allow-origin header is required. |
| `SKIP_UPGRADE_DEFAULT_ITEMS` | unset (false) | Default grocery items are imported/updated on every restart. |
| `SMTP_HOST` / `SMTP_PORT` / `SMTP_USER` / `SMTP_PASS` / `SMTP_FROM` | unset | Optional: SMTP for password resets and email verification. Not required — onboarding and login work without it. |
| `OIDC_ISSUER` / `OIDC_CLIENT_ID` / `OIDC_CLIENT_SECRET` | unset | Optional: OpenID Connect login. Username/password login is the default. |

## Persistence

A single volume is mounted at `/data` and holds the SQLite database (`database.db`) and uploaded images (`upload/`). Restarts and redeploys keep household data; deleting the volume wipes it.

## Details

- Runtime: Python (uWSGI + Flask backend, Flutter web client) in a single service; an in-container Celery worker handles background jobs.
- Memory at rest: a single small Python service (SQLite, no companion database).
- Port: listens on Railway's injected `PORT` (mapped onto uWSGI's public socket by the wrapper entrypoint).
- Upstream: [TomBursch/kitchenowl](https://github.com/TomBursch/kitchenowl) v0.7.10, AGPL-3.0, image pinned by digest.
- Healthcheck: `GET /api/health/8M4F88S8ooi4sMbLBfkkV7ctWwgibW6V` (the upstream image's own health endpoint, no auth required).

### Deployment Dependencies

- Plan tier: works on Railway's entry tiers; a single always-on service with a 5 GB volume.
- RAM needs: modest — one Python service with SQLite; no companion database or cache service.
