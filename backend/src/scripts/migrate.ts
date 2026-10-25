/**
 * Applies the framework and app SQL migrations with drizzle-orm's migrator.
 * Used by the Docker image on startup (no drizzle-kit / Node.js needed there).
 * Keeps drizzle-kit's bookkeeping (schema "drizzle", tables base_migrations
 * and app_migrations), so both tools can be mixed.
 *
 *   bun run src/scripts/migrate.ts
 */
import { drizzle } from "drizzle-orm/node-postgres";
import { migrate } from "drizzle-orm/node-postgres/migrator";
import { Pool } from "pg";
import { resolve } from "path";
import { PREFIX } from "../db";

const ca = process.env.POSTGRES_CA ?? "";
const useSsl = ca.length > 0 && ca !== "none";

const pool = new Pool({
  host: process.env.POSTGRES_HOST,
  port: parseInt(process.env.POSTGRES_PORT ?? "5432"),
  user: process.env.POSTGRES_USER,
  password: process.env.POSTGRES_PASSWORD,
  database: process.env.POSTGRES_DB,
  ssl: useSsl ? { rejectUnauthorized: false, ca } : false,
});

const root = process.env.MIGRATIONS_ROOT ?? resolve(import.meta.dir, "../..");

try {
  const db = drizzle(pool);
  console.log("Applying framework migrations …");
  await migrate(db, {
    migrationsFolder: resolve(root, "framework/drizzle-sql"),
    migrationsTable: "base_migrations",
  });
  console.log("Applying app migrations …");
  await migrate(db, {
    migrationsFolder: resolve(root, "drizzle-sql"),
    migrationsTable: `${PREFIX}migrations`,
  });
  console.log("Migrations done.");
} catch (error) {
  console.error("Migration failed:", error);
  process.exitCode = 1;
} finally {
  await pool.end();
}
