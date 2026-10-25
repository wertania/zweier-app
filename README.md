<p align="center">
  <img src="app/assets/icon/icon.png" width="96" alt="Zweier icon">
</p>

<h1 align="center">Zweier 💞</h1>

<p align="center">
  A cosy Android app for couples: collect ideas for your time together, keep a list of travel dreams
  and let the app suggest what to do on a Saturday morning – based on the weather forecast and the time you have.
</p>

<p align="center">
  <a href="../../releases/latest">Download the latest APK</a> ·
  <a href="#self-hosting">Self-hosting</a> ·
  <a href="CONTRIBUTING.md">Contributing</a>
</p>

| Login | Today | Ideas | Trips | Us |
|---|---|---|---|---|
| ![](docs/screenshots/1-login.png) | ![](docs/screenshots/2-today.png) | ![](docs/screenshots/3-ideas.png) | ![](docs/screenshots/4-trips.png) | ![](docs/screenshots/5-us.png) |

## Features

- **Ideas** for free days, tagged by **weather** (sunny, cloudy, rainy, snow, any) and **duration**
  (short, half a day, full day, several days). Mark favourites ("heart ideas") and tick off what you did.
- **Travel destinations** with a planned date and a to-do list of things to experience there – the
  entries are the same kind of ideas you use for a normal Saturday.
- **Suggestions**: pick a day and how much time you have; the backend checks the
  [Open-Meteo](https://open-meteo.com) forecast for your location (no API key) and picks fitting ideas,
  preferring favourites and pushing recently done ones back.
- **Shared space for two**: one partner creates the space and invites the other by email.
- Passwordless login with an email code. English and German UI.

## Repository layout

| Path | What |
|---|---|
| `app/` | Flutter Android app |
| `backend/` | Bun + Hono API on the [symbiosika-framework](https://github.com/symbiosika/symbiosika-framework) (git submodule in `backend/framework`, Apache-2.0) |
| `.github/workflows/` | CI (backend tests, Flutter analyze/test) and the APK release workflow |

### Data model

| Table | Content |
|---|---|
| `app_ideas` | Title, notes, emoji, `weather`, `duration`, favourite, done. With a `destinationId` the idea is a to-do of that destination. |
| `app_destinations` | Name, country, emoji, planned date, visited. |

A couple is a *tenant* of the framework; all data is scoped to it.

### API (`/api/v1`, JWT, tenant members only)

- `GET/POST /tenant/:tenantId/ideas` (`?destinationId=none|<id>&weather=&duration=`), `GET/PUT/DELETE /tenant/:tenantId/ideas/:id`
- `GET/POST /tenant/:tenantId/destinations` (includes `todoCount`/`doneCount`), `GET/PUT/DELETE /tenant/:tenantId/destinations/:id`
- `GET /tenant/:tenantId/suggestions?maxDuration=&weather=&latitude=&longitude=&date=&count=`

Authentication, tenants and invitations come from the framework (`/user/request-login-code`,
`/user/login-with-code`, `/tenant/:id/invite`, …).

## Self-hosting

The app needs a running backend. The APK has no server built in – enter your server URL on the login screen
(e.g. `https://zweier.example.com/api/v1`). Release builds only talk HTTPS.

```bash
git clone --recurse-submodules https://github.com/wertania/zweier-app.git
cd zweier-app/backend
bun install
bun run init              # generates secrets into .env
# configure POSTGRES_* and SMTP_* in .env (login codes are sent by email)
bun run migrate
bun run build && bun ./dist/index.js
```

The `Dockerfile` in the repository root runs a pre-built `dist/` and applies migrations on start.

## Development

```bash
# backend
cd backend
bun install && bun run init
bun run db:local          # embedded Postgres (PGlite); or `bun run docker:up`
bun run migrate
bun run dev               # http://localhost:3000, SMTP_HOST=console.localhost prints login codes to the log
bun run test:app          # app tests against an embedded database (test:local = incl. framework)

# app
cd app
flutter pub get
flutter run               # emulator default backend: http://10.0.2.2:3000/api/v1
flutter run --dart-define=API_BASE_URL=https://your-server/api/v1
```

Translations live in `app/lib/l10n/app_*.arb` – adding a language is a new ARB file.

## Releasing

Push a tag like `v1.0.0`; the [release workflow](.github/workflows/release.yml) builds the APK and attaches it to a
GitHub release. To sign with your own key (needed for in-place updates), add these repository secrets:
`ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`.
Without them the APK is signed with a throwaway debug key. The optional repository variable `API_BASE_URL`
sets a default server URL in the app.

Locally, put the same values into `app/android/key.properties` (`storeFile`, `storePassword`, `keyAlias`, `keyPassword`).

## License

[MIT](LICENSE). The bundled framework submodule is licensed under Apache-2.0.
