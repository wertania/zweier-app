import { sql } from "drizzle-orm";
import {
  uuid,
  index,
  varchar,
  text,
  timestamp,
  boolean,
} from "drizzle-orm/pg-core";
import { relations } from "drizzle-orm";
import {
  createInsertSchema,
  createSelectSchema,
  createUpdateSchema,
} from "drizzle-valibot";
import { tenants } from "@framework/lib/db/schema/users";
import { pgBaseTable } from "../schema-base";
import { weatherEnum, durationEnum } from "./enums";
import { destinations } from "./destinations";

/**
 * Leisure ideas. Without a destination they are ideas for a free day at home
 * (e.g. Saturday). With a destination they form the to-do list of that trip.
 */
export const ideas = pgBaseTable(
  "ideas",
  {
    id: uuid("id").primaryKey().default(sql`gen_random_uuid()`),
    tenantId: uuid("tenant_id")
      .references(() => tenants.id, { onDelete: "cascade" })
      .notNull(),
    destinationId: uuid("destination_id").references(() => destinations.id, {
      onDelete: "cascade",
    }),
    title: varchar("title", { length: 255 }).notNull(),
    description: text("description"),
    emoji: varchar("emoji", { length: 16 }).notNull().default("💡"),
    weather: weatherEnum("weather").notNull().default("any"),
    duration: durationEnum("duration").notNull().default("half_day"),
    favorite: boolean("favorite").notNull().default(false),
    done: boolean("done").notNull().default(false),
    doneAt: timestamp("done_at", { mode: "string" }),
    createdAt: timestamp("created_at", { mode: "string" }).notNull().defaultNow(),
    updatedAt: timestamp("updated_at", { mode: "string" }).notNull().defaultNow(),
  },
  (table) => [
    index("ideas_tenant_id_idx").on(table.tenantId),
    index("ideas_destination_id_idx").on(table.destinationId),
  ]
);

export const ideasRelations = relations(ideas, ({ one }) => ({
  tenant: one(tenants, { fields: [ideas.tenantId], references: [tenants.id] }),
  destination: one(destinations, {
    fields: [ideas.destinationId],
    references: [destinations.id],
  }),
}));

export type IdeasSelect = typeof ideas.$inferSelect;
export type IdeasInsert = typeof ideas.$inferInsert;
export const ideasSelectSchema = createSelectSchema(ideas);
export const ideasInsertSchema = createInsertSchema(ideas);
export const ideasUpdateSchema = createUpdateSchema(ideas);
