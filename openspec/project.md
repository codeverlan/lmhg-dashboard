# Project Context

## Purpose
Louisville Mental Health Dashboard (LMHG) — a unified, mobile-first dashboard and toolset for Louisville Mental Health (LMHG). The project consolidates company workflows, reduces dependency on Google Workspace, and provides a modular architecture for features such as video training delivery, ticketing, and client/referral tracking. The primary goal is to provide a user-friendly, responsive dashboard that non-technical staff can use, while keeping developer-friendly APIs and secure operations for sensitive data.

### Goals
- Replace core Google Workspace workflows (email, calendars, document references) with an integrated dashboard.
- Provide modular features (training videos, ticketing, client/referral tracking) that can be enabled independently.
- Mobile-first, responsive UX with consistent React components and accessible design.
- Fast, webhook- and API-friendly backend capable of integrating with SES and other third-party services.
- Strong security posture around sensitive data, with audit logging and role-based access.

## Tech Stack
Primary, recommended stack (selected for maintainability and your preference for Python backend):
- Frontend: Next.js (React) with TypeScript and Tailwind CSS (mobile-first responsive design)
- Backend: Python 3.11+ with FastAPI (async, performant, excellent DX)
- Database: PostgreSQL (primary transactional datastore)
- ORM / schema & migrations: SQLModel or SQLAlchemy + Alembic (SQLModel recommended for FastAPI alignment)
- Cache & background: Redis (caching, task queue broker)
- Background jobs: RQ or Celery (Celery for advanced workflows; RQ for simplicity)
- Email: Amazon SES (transactional email delivery) — SES can be used even if hosting is off-AWS; alternatively consider SendGrid or Mailgun if you prefer non-AWS email providers
- Object storage: S3-compatible store (DigitalOcean Spaces, Backblaze B2) or managed storage from chosen host (avoid AWS S3 if you prefer no AWS hosting)
- Hosting (non-AWS options): Render, Fly.io, DigitalOcean App Platform, or Vercel (frontend) + Render/Fly/DigitalOcean (backend)
- CI: (user asked not to focus on CI) GitHub Actions is recommended but optional
- Package managers: pnpm or npm for frontend; pip + virtualenv/venv or poetry for Python backend
- Monorepo / repo layout: single repository with `frontend/` and `backend/` folders (simple) or pnpm/monorepo if you want packages split later

### Rationale
- FastAPI is a strong fit for an API-first backend with excellent async support and automatic OpenAPI docs.
- TypeScript + Next.js gives a productive DX for frontend, strong typing across the UI, and seamless API calls to FastAPI endpoints.
- PostgreSQL is the best fit for transactional client/referral data and relational queries.

## Project Conventions

### Mobile & UI
- Mobile-first approach: design components with mobile as the baseline and progressively enhance for tablet/desktop.
- Tailwind CSS with a shared design tokens file (colors, spacing, breakpoints) to ensure consistent visuals.
- Build a small design system of reusable React components (Button, Input, Modal, Table, Card, Nav) documented in a `components/` directory and Storybook for visual testing.
- Accessibility: use semantic HTML, ARIA attributes when needed, and keyboard navigation for core flows.

### Code Style
- Frontend: TypeScript with `strict` enabled.
- Backend: Python with type hints and pydantic models (FastAPI uses pydantic for validation).
- Linting/formatting: ESLint + Prettier for frontend; ruff + Black + isort for backend.
- Naming conventions: kebab-case for file names in frontend routes where applicable, camelCase for JS/TS variables and functions, snake_case for Python modules and variables.
- Commenting: include conventional, informative comments for complex or critical logic. Use docstrings for Python modules and JSDoc/TSDoc for TypeScript where appropriate.

### Architecture Patterns
- Modular, pluggable architecture: features are implemented as modules that can be enabled or disabled; keep a clear API boundary between frontend and backend.
- API-first design: all functionality exposed via RESTful JSON endpoints (or GraphQL if you choose later), and webhook endpoints for external integrations.
- Single repo with `frontend/` and `backend/` folders to simplify onboarding for non-technical team members; move to a monorepo tool later if needed.

### Testing Strategy
- Backend: pytest for unit and integration tests; use testcontainers or local Docker Postgres for integration tests.
- Frontend: Vitest or Jest for unit tests, React Testing Library for component tests.
- E2E: Playwright (recommended) for critical flows (login, send email, submit ticket, record referral).
- Coverage: aim for solid unit coverage on critical modules and E2E coverage for user-facing flows; exact percentage negotiable but target >= 70% for core modules.

### Git Workflow
- Branches: `main` protected; feature branches `feature/<short-description>` or `fix/<short-description>`.
- Commits: Conventional Commits recommended to auto-generate changelogs.
- PRs: require description, testing steps, and at least one reviewer.

## Domain Context
- LMHG is a small mental health practice. Core domain objects include: clients, referrals, staff users, appointments, training progress, and support tickets.
- Sensitive data: client identifiers, referral details, and case notes may be sensitive. Minimize PHI storage where possible. Consider pseudonymization and strict access control.

## Important Constraints
- Mobile-first/responsive UI required.
- No AWS hosting (rendering/backend hosting should use non-AWS hosts per your instruction). SES may still be used for email delivery if acceptable; otherwise use SendGrid/Mailgun.
- Fast APIs and webhook handling are required for integrations.
- Secure defaults: HTTPS everywhere, RBAC, audit logging, encrypted storage for sensitive files.

## Security & Compliance Notes
- Determine HIPAA applicability early. If HIPAA applies, use only providers who will sign a BAA and follow required operational controls.
- TLS for all endpoints, HSTS, strict cookie flags.
- Encrypt data at rest and in transit; use DB encryption and secure object storage.
- Use RBAC for staff users. Keep an audit log of access and critical operations.
- Store secrets in host-provided secrets manager or external secret store (Vault) rather than committing `.env` files.

## Data Classification & Storage Rules

- Default classification: all records and fields are treated as HIPAA-sensitive by default unless explicitly marked otherwise.
- Designator: include a metadata boolean field `hipaa_exempt` (default: `false`) on records and file objects. When `hipaa_exempt: true` the record may be stored/served from cloud hosts; when `false`, the record must remain on-prem and must not be replicated to non-HIPAA storage.
- Enforcement: the backend must enforce storage rules at the persistence layer. Any write or migration job must check the `hipaa_exempt` flag before moving or copying data. Design the storage layer with an API that accepts a `storage_policy` parameter which maps to either `local_only` or `cloud_allowed`.
- Views & APIs: API endpoints must enforce policy — responses for `local_only` records should only be returned to authenticated sessions originating from approved networks (e.g., internal VPN or requests routed through the on-prem server) per deployment rules.
- Backups: HIPAA-sensitive data backups must be stored only on local/on-prem backup targets and encrypted. Non-sensitive backups can be stored in cloud backups per chosen retention policies.

## Authentication (chosen approach)

- Chosen approach: self-hosted, open-source authentication compatible with many services. This keeps authentication and session data under local control for staff and HIPAA-accessible users.
- Recommended implementations: Ory Kratos + Ory Hydra (modular, modern), or Keycloak (full-featured, widely adopted). Both can be run on-prem behind your firewall and integrate with SSO/OAuth2/OIDC flows for any cloud-hosted components.
- Features to enable for MVP: secure password storage (bcrypt/argon2), optional 2FA (TOTP), session management with secure HttpOnly cookies, account lockout/monitoring, and admin-managed user provisioning.

- MFA policy: for the MVP, multi-factor authentication will not be required (C). However, the platform must be designed so 2FA can be rolled out and then enforced as HIPAA-required for all staff accounts shortly after MVP. Plan to support TOTP (authenticator apps) and WebAuthn (hardware keys) as the primary methods; SMS may be supported only as a fallback with explicit risk acceptance.

### OIDC / OAuth2 plan — Ory Hydra (planned)

Given the long-term goal of supporting robust OAuth2/OIDC flows for integrations and SSO, we will plan for Ory Hydra as the token and OAuth2 provider for LMHG. Hydra provides a secure, standards-compliant OAuth2 and OpenID Connect server that delegates user identity to an identity/identity management component (for example Ory Kratos) or a custom consent/auth flow implemented by the application.

High-level architecture and responsibilities:
- Ory Kratos (optional, recommended) — user identity, registration, password policies, account management. Kratos handles identity lifecycles and user profiles.
- Ory Hydra — OAuth2 / OIDC server: issues access tokens, refresh tokens, implements token introspection, revocation, consent flows, and client registration (or managed via configuration).
- Consent & Login Apps — lightweight web endpoints (can be hosted on the backend) that Kratos/Hydra redirect to when a login or consent step is required. These apps perform user interaction and then redirect back to Hydra with a decision.
- Reverse proxy (nginx/traefik) — terminates TLS and routes traffic to Hydra, Kratos, and the main app. For on-prem HIPAA deployments TLS should be terminated on a controlled boundary (the reverse proxy) and keys held locally.

Deployment & hosting decisions for HIPAA on-prem MVP:
- For HIPAA-sensitive operations, run Hydra and Kratos on-prem (the same or separate local server) so that token storage, client secrets, and identity data remain under your control.
- Hydra requires a Postgres database and persistent storage for keys and consent state — use your on-prem Postgres or the Postgres container in the compose setup and ensure backups are local-only for any PHI-linked clients.
- Configure Hydra to use rotating signing keys and store private keys securely (local HSM or file-protected storage). Key rotation and compromise procedures must be documented.
- Use short access token lifetimes and enforce refresh token rotation and revocation to keep sessions secure.

Integration notes (developer guidance):
- The backend services (FastAPI) will treat Hydra as the authorization server. For APIs, the backend should validate incoming access tokens via token introspection or by verifying JWT signatures (depending on Hydra configuration).
- For service-to-service flows (webhooks, IntakeQ integration), register OAuth2 clients in Hydra and use client credentials flows or appropriate grant types. Keep client secrets local-only when PHI is involved.
- Implement an admin flow for registering trusted OAuth2 clients and auditing client secrets and consent records.

Migration path: for the MVP we can start with the FastAPI session-based auth or the smaller Kratos-only identity stack, then add Hydra when we need OAuth2/OIDC clients and external integrations. However, preparing the system for Hydra now (e.g., adding token-introspection hooks, client metadata storage, and a consent UI stub) will make the transition smoother.



## External Dependencies
- Amazon SES (email delivery) — optional if you prefer non-AWS email providers
- S3-compatible object storage (DigitalOcean Spaces, Backblaze B2) for uploaded documents
- Postgres (managed Postgres from host) for relational data
- Redis for caching and background queues
- Integrations as needed: Stripe, Twilio (planned/eventual), Zoom, calendar providers, EHR/EMR systems (if required)

### Selected integrations (MVP & near-term)
- IntakeQ (EMR/intake system): API-based integration. Records will flow to/from the on-prem solution. All PHI-bearing flows must be proxied through the on-prem integration gateway and stored only on-prem unless explicitly marked `hipaa_exempt`.
- Calendar workflows: migrate existing calendar workflows (Google Calendar / CalDAV / iCal). Appointment syncs that include PHI must be routed through on-prem. Provide an option for limited, non-PHI calendar metadata to be synced to cloud calendars for convenience.
- Twilio (SMS/voice): planned for notifications and reminders (eventual). SMS may carry PHI risk; avoid sending PHI via SMS unless explicitly consented and necessary.
- Document storage: S3-compatible object store for non-PHI artifacts; PHI file uploads must be stored on-prem or in a storage target designated `local_only`.
- Webhooks: yes — the platform will support incoming and outgoing webhooks. Implement HMAC-signed payloads, timestamp checks, and retry/backoff. Incoming webhook handlers that contain PHI must be routed to on-prem endpoints only.

## Integrations (MVP notes)

- IntakeQ: integrate using IntakeQ's REST API. Implement an on-prem gateway service that performs authentication to IntakeQ and enforces PHI routing/storage rules. Keep idempotency keys and reconciliation logs for referral synchronization.
	- Status: IntakeQ API credentials available; IntakeQ webhook/payloads will include PHI. The on-prem gateway must store credentials securely (on local secrets manager) and ensure all IntakeQ-originated PHI is written only to local-only storage targets. Design the gateway to verify webhook signatures and to record an audit trail for each inbound PHI-bearing event.
- Calendar: provide a one-way export/sync option for appointments to staff calendars (strip PHI), and a controlled two-way sync for non-sensitive calendar metadata. Offer manual reconciliation for conflicting edits.
- Twilio: keep Twilio integration optional and disabled by default for MVP. Use SES for appointment notifications initially; if Twilio is enabled, require templates that exclude PHI or explicit patient consent records.
- Webhooks: all webhook endpoints require verification (HMAC) and optional IP allowlists. Outgoing webhook deliveries should include delivery status logs and DLQ (dead-letter queue) handling for failed deliveries.


## Operational (Monitoring & Backups)
- Error tracking: Sentry or similar.
- Metrics: Prometheus/Grafana or a managed metrics provider supported by host.
- Logs: centralized logs (host-provided or third-party like LogDNA/Datadog).
- Backups: automated database snapshots; lifecycle/versioning for object storage.

## Database Migrations (Alembic rationale)

Why Alembic?
- Alembic is the de-facto migration tool for SQLAlchemy, which SQLModel uses under the hood. It provides a reliable, versioned migration system that integrates with your codebase and deployment pipelines.
- Key benefits:
	- Versioned migrations: each schema change is a tracked revision, so schema evolution is auditable and reversible.
	- Autogenerate support: Alembic can generate migration skeletons by comparing models to the current DB schema — saves time and reduces human error.
	- Production-ready: battle-tested for many deployment patterns (single-instance, migrations in CI, zero-downtime patterns with feature flags).
	- Database portability: Alembic works well with Postgres (our target) and supports SQL dialects needed for migrations.

How we'll use Alembic in LMHG:
- Keep migration scripts under `backend/migrations/` and check them into git. Treat migrations as part of the code change that introduces model changes.
- Use autogenerate for developer iteration, but always review autogenerated scripts for non-trivial changes.
- Run migrations during deploy (CI or startup script) against the on-prem Postgres instance. For safety, run migrations under a dedicated migration user with required privileges.
- For the MVP, use a simple pattern: apply migrations in a pre-deploy step executed by the maintainer; later we can add automatic migration runs in a controlled CI/CD flow.

Practical notes & best practices:
- Use a separate alembic.ini that reads `DATABASE_URL` from env so local and on-prem builds use the same configuration.
- Maintain small, focused migration revisions (one logical change per revision).
- Add a preflight check step before migrations that verifies backups exist and that the DB replica (if any) is healthy.


## Developer Experience & Onboarding
- Local development: `frontend/` and `backend/` each provide a `README.md` and `scripts` for local dev. Consider a `dev` script that runs both (docker-compose or local proxies).
- `.env.example` file for required environment variables.
- Developer docs in `/docs` covering local setup, deploy steps, and incident runbooks.

- Repository layout: simple two-folder layout chosen for onboarding ease. Top-level folders will be:
	- `frontend/` — Next.js + TypeScript + Tailwind project
	- `backend/` — FastAPI Python project with a clear API surface
	This layout keeps the MVP approachable for non-developers and small teams while allowing modular growth later.

## Assumptions & Open Questions
- You prefer a Python backend (FastAPI) and asked for mobile-first React components with Tailwind.
- You will not use AWS for hosting, but email via SES is acceptable unless you want a non-AWS email provider.

- Repository layout (decision): simple `frontend/` + `backend/` folder structure confirmed.

## Implementation departures and notes (audit)

This section records any departures between the high-level spec and the current implementation for audit and HIPAA compliance. Keep this updated as the codebase changes.

- Dockerized Hydra/Kratos: The spec recommended planning for Hydra/Kratos. The repo includes a development Docker Compose arrangement that adds minimal Kratos and Hydra placeholders and a reverse proxy (nginx). These are development stubs and are not yet fully configured for production; they should not be used for production-facing identity until properly configured and tested.
- Local certs: a self-signed certificate script is included for local testing only. For production, obtain official TLS certificates and manage keys via a secure store.
- Alembic: Alembic migration scaffolding and an initial migration were added to align the DB schema with the `Record` model. The migration is created but must be run manually or via the provided migration container; backups must be taken before applying to production DBs.
- On-prem constraints: the implemented docker-compose includes services for Postgres and Redis for local development. In production on-prem deployments, use the existing on-prem Postgres instance and ensure backups remain local-only for HIPAA-sensitive data.

- Hydra client registration helper: a small script `backend/hydra/register_client.py` is included to help register OAuth2 clients in Hydra for testing. In production, client secrets must be created and stored in a secure secret store and audited.
- Backup & restore scripts: simple `scripts/backup_postgres.sh` and `scripts/restore_postgres.sh` were added along with a `docs/backup_policy.md` that defines retention and restore procedures. These scripts are developer-friendly and must be hardened for production.

Refer to `docs/security-checklist.md` and `docs/backup_policy.md` for the operational controls and procedures.

If any of the above diverge from organizational policy or HIPAA requirements, update this section and notify the compliance officer.

### Questions to finalize the spec
1. Do you need HIPAA-level compliance (yes/no)? If yes, we will limit providers to those who sign a BAA.
2. Which hosting provider would you prefer for the backend and frontend? (suggestions: Render, Fly.io, DigitalOcean, Vercel for the frontend)
3. Authentication: prefer a managed provider (Auth0, Clerk), an OAuth/SSO provider, or a custom email/password + 2FA system?
4. Will the system store PHI or client documents (PDFs, images)? If yes, we will mark stricter security controls and longer retention/backup rules.
5. Expected operational scale (number of staff/users and concurrent sessions) — rough estimate helps sizing decisions.
6. Do you want a single repository with `frontend/` and `backend/` folders (simpler for onboarding) or separate repos per module?
7. Any required third-party integrations beyond SES (Stripe, Twilio, Zoom, calendar providers, EMR/EHR)?
8. Do you want mandatory E2E tests in CI for releases, or is unit + manual QA acceptable initially?
9. Storage preference for uploaded files: DigitalOcean Spaces / Backblaze / other?
10. Would you like me to generate a starter scaffold (minimal Next.js frontend + FastAPI backend + README) once this spec is finalized?

---

If you confirm or answer those questions I will update this file and can optionally scaffold the initial repo layout and a minimal working demo (auth + one example module) documented for non-programmers.
