import { getDb } from "@framework/lib/db/db-connection";
import { and, arrayContains, arrayOverlaps, desc, eq, inArray, isNull } from "drizzle-orm";
import * as v from "valibot";
import {
  ideas,
  ideasInsertSchema,
  ideasUpdateSchema,
  durationTypes,
  type CategoryType,
  type DurationType,
  type IdeasSelect,
  type TimeOfDayType,
  type WeatherType,
} from "../db/schema";
import { getDestinationById } from "./destinations";

export type IdeaFilter = {
  /** "none" = only ideas without destination, a uuid = only that destination */
  destinationId?: string;
  /** Ideas that fit this weather (including "any weather" ideas). */
  weather?: WeatherType;
  duration?: DurationType;
  /** Ideas that fit this time of day (including "any time" ideas). */
  timeOfDay?: TimeOfDayType;
  category?: CategoryType;
};

/** An idea as returned by the API. */
export type IdeaResponse = IdeasSelect & {
  /** @deprecated single weather for app versions before 1.2 – use `weathers` */
  weather: WeatherType;
};

export function toIdeaResponse(idea: IdeasSelect): IdeaResponse {
  return {
    ...idea,
    weather: idea.weathers.length === 1 ? idea.weathers[0]! : "any",
  };
}

/** True if the idea can be done in this weather. */
export function fitsWeather(idea: Pick<IdeasSelect, "weathers">, weather: WeatherType) {
  return weather === "any" || idea.weathers.includes("any") || idea.weathers.includes(weather);
}

/** True if the idea can be done at this time of day. */
export function fitsTimeOfDay(idea: Pick<IdeasSelect, "timeOfDay">, timeOfDay: TimeOfDayType) {
  return timeOfDay === "any" || idea.timeOfDay === "any" || idea.timeOfDay === timeOfDay;
}

/**
 * Accepts the old single `weather` field (app versions before 1.2) and
 * normalizes `weathers`: no duplicates, "any" wins, empty means "any".
 */
function normalizeInput(data: unknown) {
  const { weather, weathers, categories, ...input } = (data ?? {}) as Record<string, unknown>;
  const rest = Array.isArray(categories) ? { ...input, categories: [...new Set(categories)] } : input;
  const list = Array.isArray(weathers)
    ? weathers
    : typeof weather === "string"
      ? [weather]
      : undefined;
  if (list === undefined) return rest;
  const unique = [...new Set(list)];
  return {
    ...rest,
    weathers: unique.length === 0 || unique.includes("any") ? ["any"] : unique,
  };
}

export async function getIdeas(tenantId: string, filter: IdeaFilter = {}) {
  const conditions = [eq(ideas.tenantId, tenantId)];
  if (filter.destinationId === "none") {
    conditions.push(isNull(ideas.destinationId));
  } else if (filter.destinationId) {
    conditions.push(eq(ideas.destinationId, filter.destinationId));
  }
  if (filter.weather && filter.weather !== "any") {
    conditions.push(arrayOverlaps(ideas.weathers, [filter.weather, "any"]));
  }
  if (filter.duration) conditions.push(eq(ideas.duration, filter.duration));
  if (filter.timeOfDay && filter.timeOfDay !== "any") {
    conditions.push(inArray(ideas.timeOfDay, [filter.timeOfDay, "any"]));
  }
  if (filter.category) conditions.push(arrayContains(ideas.categories, [filter.category]));

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
    ...normalizeInput(data),
    tenantId,
  });
  await assertDestinationOfTenant(tenantId, validated.destinationId);
  const result = await getDb().insert(ideas).values(validated).returning();
  return result[0]!;
}

export async function updateIdea(tenantId: string, id: string, data: unknown) {
  const { tenantId: _t, id: _i, ...rest } = normalizeInput(data);
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
