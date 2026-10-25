# Zweier backend – self-contained image.
#   docker build -t zweier-backend .
#   docker run -p 3000:3000 --env-file backend/.env zweier-backend
# Framework + app migrations run on every start, then the server listens on :3000.

# ---- build ----
FROM oven/bun:1.4 AS build
WORKDIR /src
COPY backend/package.json backend/bun.lock ./
RUN bun install --frozen-lockfile
COPY backend/ ./
RUN bun run build \
  && bun build ./src/scripts/migrate.ts --outfile ./dist/migrate.js --target bun --minify

# ---- runtime ----
FROM oven/bun:1.4-slim AS release
WORKDIR /app
ENV NODE_ENV=production \
    MIGRATIONS_ROOT=/app

COPY --from=build /src/dist ./dist
COPY --from=build /src/public ./public
COPY --from=build /src/static ./static
COPY --from=build /src/drizzle-sql ./drizzle-sql
COPY --from=build /src/framework/drizzle-sql ./framework/drizzle-sql

EXPOSE 3000
CMD ["sh", "-c", "bun ./dist/migrate.js && exec bun ./dist/index.js"]
