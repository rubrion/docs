# Rubrion Platform

Rubrion builds open-source, white-label infrastructure products — publishing engines, job intelligence tools, and marketplace platforms — designed to be self-hosted, customised, and deployed at scale.

## Products

### EdgePress

EdgePress is a high-performance, white-label publishing engine. It ships as a single Cloudflare Worker (Astro SSR + D1 + R2) that runs a public blog, an admin editor, a media uploader, and a newsletter dispatcher — all in one deployment with zero sidecars.

Each white-label tenant gets **one Worker deployment + one D1 database**. Brand visuals (name, logo, theme color, email sender) are configured live from an admin panel — no redeploy required.

**Email providers:**
- **Resend** — HTTP API, called directly from the Worker.
- **Gmail SMTP** — TCP from the Worker to `smtp.gmail.com:465` via `cloudflare:sockets`.

Live demo: [edgepress.rubrion.ai](https://edgepress.rubrion.ai)  
Repository: [github.com/rubrion/edgepress](https://github.com/rubrion/edgepress)

### SpecFit

SpecFit is an open-source job application tracker with LLM-powered CV matching. Paste a job description and your CV to receive a structured fit score, matched skills, gaps, and a tailored recommendation. Track applications through their full lifecycle.

**Key capabilities:**
- CV PDF upload with text extraction (`pypdf`), 5 MB limit.
- LLM match analysis via [OpenRouter](https://openrouter.ai) (default `openai/gpt-4o-mini`), results cached per `(model, job_description, cv_text)` hash.
- LinkedIn profile suggestions powered by the Brave Search API.
- Authentication via Auth.js v5 — email + password (Resend-verified) and Google / GitHub OAuth.
- Per-user daily token budget with enforced cap.

**Platform:**

| Layer | Platform |
|-------|----------|
| Backend | [Railway](https://railway.app) — FastAPI, Python 3.12, Docker |
| Database | Railway Postgres 16 (JSONB) |
| Frontend | [Cloudflare Workers](https://workers.cloudflare.com) via `@opennextjs/cloudflare` (Next.js 16) |
| LLM gateway | [OpenRouter](https://openrouter.ai) |
| Email | [Resend](https://resend.com) |
| Observability | [Pydantic Logfire](https://logfire.pydantic.dev) |

Repository: [github.com/rubrion/specfit](https://github.com/rubrion/specfit)

### Rubot

Rubot is a multi-tenant, LLM-driven chat-agent scaffold built on Cloudflare Workers (gateway + middleware) and Railway (Python agents). Specialist agents are forked from a common template, registered in an orchestrator, and routed by an LLM planner — all connected through a short-lived, HMAC-signed bearer chain that never exposes long-lived credentials to the model.

**Services:**

| Service | Tech | Where |
|---------|------|-------|
| `rubot-gateway` | TypeScript / Hono | Cloudflare Workers |
| `rubot-middleware` | TypeScript / Hono + D1 | Cloudflare Workers |
| `rubot-orchestrator` | Python / FastAPI | Railway |
| `rubot-agent-*` | Python / pydantic_ai | Railway |
| `rubot-client` | Astro SSR | Cloudflare Workers |

**Two deployment modes:**
- **Bearer mode** — full multi-tenant identity: manager accounts, PIN-based sender→tenant binding, HMAC-signed short-lived data bearers, per-tenant agent toggles.
- **Open mode** — auth chain bypassed; all services share one implicit tenant. Suitable for single-tenant or development deployments.

Repository: [github.com/rubrion/docs](https://github.com/rubrion/docs) (under `rubot/`)

### Rubrion Store

Rubrion Store is a white-label marketplace platform — multi-tenant storefronts, vendor onboarding, product catalogue, and a CMS-driven front-end with transparent infrastructure costs. Run it for your community or your customers.

The platform is built on [Medusa](https://medusajs.com) + [Mercur](https://mercurjs.com) for commerce and marketplace logic, with a Next.js B2C storefront and a [Sanity](https://www.sanity.io) Studio for content management.

**Monorepo layout:**

| Package / App | Purpose |
|---------------|---------|
| `packages/api` | Medusa backend with marketplace workflows, subscribers, and custom modules |
| `apps/admin` | Admin dashboard extensions (React + Vite) |
| `apps/vendor` | Vendor portal extensions (React + Vite) |
| `apps/storefront` | Next.js B2C storefront + embedded Sanity Studio |

**CMS — Sanity Studio:**
- Hosted Studio (no self-hosting needed); schema lives in `apps/storefront/sanity/`.
- Supports Home pages, Landing pages, Navigation, and Static pages — each per locale (BR / ES / US).
- Storefront revalidates via signed webhook on publish (~1 s); ISR fallback at 60 s.

Live demo: [rubrion.store](https://rubrion.store)  
Repository: [github.com/rubrion/store](https://github.com/rubrion/store)

## Getting started

Each product has its own setup guide in this documentation. Choose a product from the sidebar to find prerequisites, environment variables, deployment instructions, and API references.

For access credentials, onboarding details, or white-label customisation, reach out to the Rubrion team:

- **Portal:** [rubrion.ai](https://rubrion.ai)
- **Email:** [hello@rubrion.ai](mailto:hello@rubrion.ai)
- **WhatsApp:** [Chat with Samuel](https://wa.me/5511992562478?text=Ol%C3%A1%20Samuel!%20Tenho%20interesse%20em%20discutir%20uma%20oportunidade%20de%20projeto.)
