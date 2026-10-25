import { getDb } from "@framework/lib/db/db-connection";
import { and, desc, eq, isNull } from "drizzle-orm";
import * as v from "valibot";
import {
  ideas,
  ideasInsertSchema,
  ideasUpdateSchema,
  durationTypes,
  type DurationType,
  type WeatherType,
} from "../db/schema";
import { getDestinationById } from "./destinations";

export type IdeaFilter = {
  /** "none" = only ideas without destination, a uuid = only that destination */
  destinationId?: string;
  weather?: WeatherType;
  duration?: DurationType;
};

export async function getIdeas(tenantId: string, filter: IdeaFilter = {}) {
  const conditions = [eq(ideas.tenantId, tenantId)];
  if (filter.destinationId === "none") {
    conditions.push(isNull(ideas.destinationId));
  } else if (filter.destinationId) {
    conditions.push(eq(ideas.destinationId, filter.destinationId));
  }
  if (filter.weather) conditions.push(eq(ideas.weather, filter.weather));
  if (filter.duration) conditions.push(eq(ideas.duration, filter.duration));

  return await getDb()
    .select()
    .from(ideas)
    .where(and(...conditions))
    .orderBy(ideas.done, desc(ideas.favorite), desc(ideas.createdAt));
}

export async function getIdeaById(tenantId: string, id: string) {
  const entry = await getDb()
    .select()
    .from(ideas)
    .where(and(eq(ideas.id, id), eq(ideas.tenantId, tenantId)))
    .limit(1);
  return entry.length > 0 ? entry[0] : null;
}

async function assertDestinationOfTenant(tenantId: string, destinationId: unknown) {
  if (typeof destinationId !== "string") return;
  const destination = await getDestinationById(tenantId, destinationId);
  if (!destination) {
    throw Object.assign(new Error("Destination not found"), { issues: [] });
  }
}

export async function createIdea(tenantId: string, data: unknown) {
  const validated = v.parse(ideasInsertSchema, {
    ...(data as Record<string, unknown>),
    tenantId,
  });
  await assertDestinationOfTenant(tenantId, validated.destinationId);
  const result = await getDb().insert(ideas).values(validated).returning();
  return result[0]!;
}

export async function updateIdea(tenantId: string, id: string, data: unknown) {
  const { tenantId: _t, id: _i, ...rest } = data as Record<string, unknown>;
  const validated = v.parse(ideasUpdateSchema, rest);
  await assertDestinationOfTenant(tenantId, validated.destinationId);
  const now = new Date().toISOString();
  const doneAt =
    validated.done === undefined ? {} : { doneAt: validated.done ? now : null };
  const result = await getDb()
    .update(ideas)
    .set({ ...validated, ...doneAt, updatedAt: now })
    .where(and(eq(ideas.id, id), eq(ideas.tenantId, tenantId)))
    .returning();
  return result.length > 0 ? result[0] : null;
}

export async function deleteIdea(tenantId: string, id: string): Promise<boolean> {
  const result = await getDb()
    .delete(ideas)
    .where(and(eq(ideas.id, id), eq(ideas.tenantId, tenantId)))
    .returning();
  return result.length > 0;
}

/** Durations that fit into the given maximum duration. */
export function durationsUpTo(max: DurationType): DurationType[] {
  return durationTypes.slice(0, durationTypes.indexOf(max) + 1);
}
