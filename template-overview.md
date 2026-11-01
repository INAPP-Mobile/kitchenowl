[![Deploy on Railway](https://railway.app/button.svg)](https://railway.com/deploy/kitchenowl?utm_campaign=kitchenowl)

# Deploy and Host

KitchenOwl is a self-hosted household organizer for groceries, recipes, meal plans, and shared expenses. One-click deploy creates a single service with a persistent volume — no database companion needed. After deploy, open the public URL and complete onboarding to create the owner account (username + password, no email required). Public registration stays closed after that.

## About Hosting

Hosting KitchenOwl on Railway keeps your household's lists, recipes, and expenses on your own volume instead of a third-party cloud. The deployment is a single always-on Python service with SQLite: the wrapper maps Railway's injected `PORT` onto the app's web socket, the volume at `/data` holds the database and uploads, and the only deploy-form field is a generated session secret.

## Why Deploy

- Shared shopping lists the whole household edits in real time, with suggestions based on what you usually buy.
- Recipes with ingredient parsing plus a meal planner that feeds the shopping list.
- Shared expense tracking in the same app as the groceries.
- Self-hosted data: lists, recipes, and expenses live on your Railway volume.

## Common Use Cases

- A family sharing one grocery list across phones and browsers.
- Meal planning for the week, with the planner generating the shopping list.
- Tracking shared household expenses alongside the groceries they came from.
- Keeping a household recipe collection with web-imported recipes.

## Dependencies for

- A single KitchenOwl service (Python backend + Flutter web client, SQLite on the volume).
- One persistent volume mounted at `/data` (database + uploads).
- Environment variables (condensed reference — full documentation in the repo README):

| Variable | Default | Description |
| --- | --- | --- |
| `JWT_SECRET_KEY` | generated | Session-token signing secret; the only deploy-form field. |
| `STORAGE_PATH` | `/data` | Volume path (SQLite at `/data/database.db`, uploads at `/data/upload`). |
| `DB_DRIVER` | `sqlite` | SQLite backend; no companion database needed. |
| `OPEN_REGISTRATION` | `false` | Public signup closed after first-owner onboarding. |
| `EMAIL_MANDATORY` | `false` | Onboarding is username-only; no email verification. |
| `COLLECT_METRICS` | `false` | Prometheus metrics endpoint disabled. |
| `SMTP_*` | unset | Optional SMTP for password resets; not required. |
| `OIDC_*` | unset | Optional OpenID Connect login; username/password is the default. |

### Deployment Dependencies

- Plan tier: works on Railway's entry tiers; a single always-on service with a 5 GB volume.
- RAM needs: modest — one Python service with SQLite; no companion database or cache service.
