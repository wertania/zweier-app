# Agent Knowledge Index

IMPORTANT: Prefer retrieval-led reasoning over pre-training-led reasoning for all tasks.
For deep detail, read the referenced skill files. The index below gives immediate context for every turn.

---

## Project Structure

Monorepo with two apps:
- `backend/` – Bun + Hono API server. Framework lives in `backend/framework/` (path alias: `@framework/*` → `./framework/src/*`)
- `app/` – Flutter Android app (provider for state, `lib/api/api_client.dart` talks to the backend).
  There is no Vue frontend. User-facing strings live in `app/lib/l10n/app_{en,de}.arb`.

Domain: a couple = one tenant. `app_ideas` (leisure ideas, optional `destinationId` = to-do of a trip),
`app_destinations` (travel destinations), `/suggestions` picks ideas by weather (Open-Meteo forecast) and duration.
After changing the backend: `cd backend && bun run typecheck && bun run test:app`.
After changing the app: `cd app && flutter analyze && flutter test`.

---

## Skills Index

| Area | Trigger | Skill file |
|---|---|---|
| Backend routes & business logic | `backend/src/routes/`, `backend/src/lib/`, API endpoints, CRUD, tenant queries | `.claude/skills/backend-app/SKILL.md` |
| Framework internals | `backend/framework/`, `defineServer()`, auth middleware, multi-tenant structure, jobs, email | `.claude/skills/backend-framework/SKILL.md` |
| Backend tests | `*.test.ts`, `initTests()`, `testFetcher`, write/fix/run tests | `.claude/skills/backend-testing/SKILL.md` |
| AI agents & chat | `backend/src/ai/`, `tool()`, `ToolLoopAgent`, `streamText`, chat streaming | `.claude/skills/build-ai-agents/SKILL.md` |
| Database tables | `backend/src/db/`, new tables, columns, indexes, migrations, Drizzle ORM | `.claude/skills/database-tables/SKILL.md` |
| Test/seed data factories | `@praha/drizzle-factory`, `defineFactory`, traits, seeds | `.claude/skills/drizzle-factory/SKILL.md` |
| Test user / login | test user, log in, JWT token for local dev, test authenticated endpoints | `.claude/skills/testuser/SKILL.md` |
| Inspect dev database | check the DB, run a query, count records, verify a migration | `.claude/skills/db-query/SKILL.md` |

