# Contributing to Zweier

Thanks for wanting to help! Bug reports, ideas and pull requests are welcome.

## Getting started

1. Fork and clone with submodules: `git clone --recurse-submodules …`
2. Follow the *Development* section in the [README](README.md).

## Before you open a pull request

- Backend: `cd backend && bun run typecheck && bun run test:app`
- App: `cd app && flutter analyze && flutter test`
- New user-facing strings go into `app/lib/l10n/app_en.arb` **and** `app_de.arb`.
- Database changes: edit `backend/src/db/tables/*` and run `bun run app:generate` to create a migration.
- Keep business logic in `backend/src/lib/` and routes thin (see `AGENTS.md`).

Please keep pull requests focused – one change per PR – and describe what and why.

## Code of conduct

Be kind. This project follows the [Contributor Covenant](CODE_OF_CONDUCT.md).
