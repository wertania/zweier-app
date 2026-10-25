import { sql } from "drizzle-orm";
import {
  uuid,
  index,
  varchar,
  text,
  timestamp,
  boolean,
  date,
  doublePrecision,
} from "drizzle-orm/pg-core";
import { relations } from "drizzle-orm";
import {
  createInsertSchema,
  createSelectSchema,
  createUpdateSchema,
} from "drizzle-valibot";
import { tenants } from "@framework/lib/db/schema/users";
import { pgBaseTable } from "../schema-base";

/** Travel destinations of a couple (tenant). */
export const destinations = pgBaseTable(
  "destinations",
  {
    id: uuid("id").primaryKey().default(sql`gen_random_uuid()`),
    tenantId: uuid("tenant_id")
      .references(() => tenants.id, { onDelete: "cascade" })
      .notNull(),
    name: varchar("name", { length: 255 }).notNull(),
    country: varchar("country", { length: 255 }),
    description: text("description"),
    emoji: varchar("emoji", { length: 16 }).notNull().default("🗺️"),
    latitude: doublePrecision("latitude"),
    longitude: doublePrecision("longitude"),
    plannedFor: date("planned_for", { mode: "string" }),
    visited: boolean("visited").notNull().default(false),
    createdAt: timestamp("created_at", { mode: "string" }).notNull().defaultNow(),
    updatedAt: timestamp("updated_at", { mode: "string" }).notNull().defaultNow(),
  },
  (table) => [index("destinations_tenant_id_idx").on(table.tenantId)]
);

export const destinationsRelations = relations(destinations, ({ one }) => ({
  tenant: one(tenants, {
    fields: [destinations.tenantId],
    references: [tenants.id],
  }),
}));

export type DestinationsSelect = typeof destinations.$inferSelect;
export type DestinationsInsert = typeof destinations.$inferInsert;
export const destinationsSelectSchema = createSelectSchema(destinations);
export const destinationsInsertSchema = createInsertSchema(destinations);
export const destinationsUpdateSchema = createUpdateSchema(destinations);
