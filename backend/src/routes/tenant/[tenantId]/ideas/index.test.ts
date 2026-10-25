import { describe, test, expect, beforeAll, afterAll } from "bun:test";
import {
  initTests,
  TEST_ORGANISATION_1,
} from "@framework/test/init.test";
import { testFetcher } from "@framework/test/fetcher.test";
import { authAndSetUsersInfo } from "@framework/lib/utils/hono-middlewares";
import { getDb } from "@framework/lib/db/db-connection";
import { Hono } from "hono";
import type { SymbiosikaFrameworkHonoApp } from "@framework/types";
import { eq } from "drizzle-orm";
import { defineIdeaRoutes } from "./index";
import { defineDestinationRoutes } from "../destinations";
import { defineSuggestionRoutes } from "../suggestions";
import { destinations, ideas } from "../../../../db/schema";

let app: SymbiosikaFrameworkHonoApp;
let ownerToken: string;
let otherTenantToken: string;
const base = `/tenant/${TEST_ORGANISATION_1.id}`;

const cleanup = () =>
  getDb().delete(destinations).where(eq(destinations.tenantId, TEST_ORGANISATION_1.id))
    .then(() => getDb().delete(ideas).where(eq(ideas.tenantId, TEST_ORGANISATION_1.id)));

describe("Ideas, destinations & suggestions", () => {
  beforeAll(async () => {
    const { user1Token, user2Token } = await initTests();
    ownerToken = user1Token;
    otherTenantToken = user2Token;
    app = new Hono();
    // in the server, customHonoAppsWithAuth adds this middleware
    app.use("*", authAndSetUsersInfo);
    defineIdeaRoutes(app);
    defineDestinationRoutes(app);
    defineSuggestionRoutes(app);
    await cleanup();
  });

  afterAll(() => {
    cleanup().catch((error) => console.warn("afterAll cleanup failed:", error));
  });

  test("full idea lifecycle", async () => {
    const created = await testFetcher.post(app, `${base}/ideas`, ownerToken, {
      title: "Picknick am See",
      emoji: "🧺",
      weather: "sunny",
      duration: "half_day",
    });
    expect(created.status).toBe(200);
    const id = created.jsonResponse?.data.id;
    expect(created.jsonResponse?.data.done).toBe(false);

    const read = await testFetcher.get(app, `${base}/ideas/${id}`, ownerToken);
    expect(read.jsonResponse?.data.title).toBe("Picknick am See");

    const updated = await testFetcher.put(app, `${base}/ideas/${id}`, ownerToken, {
      done: true,
    });
    expect(updated.status).toBe(200);
    expect(updated.jsonResponse?.data.done).toBe(true);
    expect(updated.jsonResponse?.data.doneAt).toBeTruthy();

    const rows = await getDb().select().from(ideas).where(eq(ideas.id, id));
    expect(rows[0]?.done).toBe(true);

    const deleted = await testFetcher.delete(app, `${base}/ideas/${id}`, ownerToken);
    expect(deleted.status).toBe(200);
    const gone = await testFetcher.get(app, `${base}/ideas/${id}`, ownerToken);
    expect(gone.status).toBe(404);
  });

  test("destination with to-do list", async () => {
    const dest = await testFetcher.post(app, `${base}/destinations`, ownerToken, {
      name: "Lissabon",
      country: "Portugal",
      emoji: "🇵🇹",
    });
    expect(dest.status).toBe(200);
    const destinationId = dest.jsonResponse?.data.id;

    await testFetcher.post(app, `${base}/ideas`, ownerToken, {
      title: "Tram 28 fahren",
      destinationId,
    });
    const todo2 = await testFetcher.post(app, `${base}/ideas`, ownerToken, {
      title: "Pastéis de Nata essen",
      destinationId,
    });
    await testFetcher.put(app, `${base}/ideas/${todo2.jsonResponse?.data.id}`, ownerToken, {
      done: true,
    });

    const list = await testFetcher.get(app, `${base}/destinations`, ownerToken);
    const entry = list.jsonResponse?.data.find((d: any) => d.id === destinationId);
    expect(entry.todoCount).toBe(2);
    expect(entry.doneCount).toBe(1);

    const todos = await testFetcher.get(
      app,
      `${base}/ideas?destinationId=${destinationId}`,
      ownerToken
    );
    expect(todos.jsonResponse?.data.length).toBe(2);

    const homeIdeas = await testFetcher.get(app, `${base}/ideas?destinationId=none`, ownerToken);
    expect(
      homeIdeas.jsonResponse?.data.every((i: any) => i.destinationId === null)
    ).toBe(true);

    // deleting the destination removes its to-dos
    await testFetcher.delete(app, `${base}/destinations/${destinationId}`, ownerToken);
    const after = await getDb().select().from(ideas).where(eq(ideas.destinationId, destinationId));
    expect(after.length).toBe(0);
  });

  test("suggestions respect weather and duration", async () => {
    const make = (title: string, weather: string, duration: string) =>
      testFetcher.post(app, `${base}/ideas`, ownerToken, { title, weather, duration });
    await make("Museum", "rainy", "half_day");
    await make("Kochen", "any", "short");
    await make("Wandern", "sunny", "full_day");
    await make("Kurztrip", "sunny", "multi_day");

    const rainy = await testFetcher.get(
      app,
      `${base}/suggestions?weather=rainy&count=10`,
      ownerToken
    );
    expect(rainy.status).toBe(200);
    const rainyTitles = rainy.jsonResponse?.data.suggestions.map((i: any) => i.title).sort();
    expect(rainyTitles).toEqual(["Kochen", "Museum"]);
    expect(rainy.jsonResponse?.data.weather).toBe("rainy");

    const sunnyShort = await testFetcher.get(
      app,
      `${base}/suggestions?weather=sunny&maxDuration=full_day&count=10`,
      ownerToken
    );
    const sunnyTitles = sunnyShort.jsonResponse?.data.suggestions.map((i: any) => i.title).sort();
    expect(sunnyTitles).toEqual(["Kochen", "Wandern"]);
  });

  test("validation errors return 400", async () => {
    const res = await testFetcher.post(app, `${base}/ideas`, ownerToken, {
      title: "Ohne Wetter",
      weather: "tornado",
    });
    expect(res.status).toBe(400);

    const foreignDestination = await testFetcher.post(app, `${base}/ideas`, ownerToken, {
      title: "Falsches Ziel",
      destinationId: "00000000-0000-0000-0000-000000000000",
    });
    expect(foreignDestination.status).toBe(400);
  });

  test("auth and tenant isolation", async () => {
    const noToken = await testFetcher.get(app, `${base}/ideas`, undefined);
    expect(noToken.status).toBe(401);

    const foreign = await testFetcher.get(app, `${base}/ideas`, otherTenantToken);
    expect([403, 404]).toContain(foreign.status);
    const foreignDest = await testFetcher.get(app, `${base}/destinations`, otherTenantToken);
    expect([403, 404]).toContain(foreignDest.status);
  });
});
