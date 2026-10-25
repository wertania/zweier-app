import { getDb } from "@framework/lib/db/db-connection";
import { and, asc, desc, eq, sql } from "drizzle-orm";
import * as v from "valibot";
import {
  destinations,
  destinationsInsertSchema,
  destinationsUpdateSchema,
  ideas,
} from "../db/schema";

export async function getDestinations(tenantId: string) {
  return await getDb()
    .select({
      destination: destinations,
      todoCount: sql<number>`count(${ideas.id})::int`,
      doneCount: sql<number>`count(${ideas.id}) filter (where ${ideas.done})::int`,
    })
    .from(destinations)
    .leftJoin(ideas, eq(ideas.destinationId, destinations.id))
    .where(eq(destinations.tenantId, tenantId))
    .groupBy(destinations.id)
    .orderBy(asc(destinations.visited), desc(destinations.createdAt))
    .then((rows) =>
      rows.map((r) => ({
        ...r.destination,
        todoCount: r.todoCount,
        doneCount: r.doneCount,
      }))
    );
}

export async function getDestinationById(tenantId: string, id: string) {
  const entry = await getDb()
    .select()
    .from(destinations)
    .where(and(eq(destinations.id, id), eq(destinations.tenantId, tenantId)))
    .limit(1);
  return entry.length > 0 ? entry[0] : null;
}

export async function createDestination(tenantId: string, data: unknown) {
  const validated = v.parse(destinationsInsertSchema, {
    ...(data as Record<string, unknown>),
    tenantId,
  });
  const result = await getDb().insert(destinations).values(validated).returning();
  return result[0]!;
}

export async function updateDestination(tenantId: string, id: string, data: unknown) {
  const { tenantId: _t, id: _i, ...rest } = data as Record<string, unknown>;
  const validated = v.parse(destinationsUpdateSchema, rest);
  const result = await getDb()
    .update(destinations)
    .set({ ...validated, updatedAt: new Date().toISOString() })
    .where(and(eq(destinations.id, id), eq(destinations.tenantId, tenantId)))
    .returning();
  return result.length > 0 ? result[0] : null;
}

export async function deleteDestination(tenantId: string, id: string): Promise<boolean> {
  const result = await getDb()
    .delete(destinations)
    .where(and(eq(destinations.id, id), eq(destinations.tenantId, tenantId)))
    .returning();
  return result.length > 0;
}
