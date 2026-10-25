/**
 * Routes for "what shall we do today?" suggestions
 */

import type { SymbiosikaFrameworkHonoApp } from "@framework/types";
import { Hono } from "hono";
import { isTenantMember } from "@framework/routes/tenant";
import { validator } from "hono-openapi";
import * as v from "valibot";
import { categoryTypes, durationTypes, timeOfDayTypes, weatherTypes } from "../../../../db/schema";
import { getSuggestions } from "../../../../lib/suggestions";

const app: SymbiosikaFrameworkHonoApp = new Hono();

const numberString = v.pipe(v.string(), v.transform(Number), v.number());

// GET / - Suggest ideas for a day, based on weather (given or forecast) and time
app.get(
  "/",
  isTenantMember,
  validator("param", v.object({ tenantId: v.string() })),
  validator(
    "query",
    v.object({
      weather: v.optional(v.picklist(weatherTypes)),
      maxDuration: v.optional(v.picklist(durationTypes)),
      timeOfDay: v.optional(v.picklist(timeOfDayTypes)),
      category: v.optional(v.picklist(categoryTypes)),
      latitude: v.optional(numberString),
      longitude: v.optional(numberString),
      date: v.optional(v.pipe(v.string(), v.isoDate())),
      destinationId: v.optional(v.string()),
      count: v.optional(v.pipe(numberString, v.integer(), v.minValue(1), v.maxValue(20))),
    })
  ),
  async (c) => {
    const { tenantId } = c.req.valid("param");
    try {
      const data = await getSuggestions(tenantId, c.req.valid("query"));
      return c.json({ success: true, data });
    } catch (error) {
      return c.json({ success: false, error: "Failed to get suggestions" }, 500);
    }
  }
);

export const defineSuggestionRoutes = (honoApp: SymbiosikaFrameworkHonoApp) => {
  honoApp.route("/tenant/:tenantId/suggestions", app);
};
