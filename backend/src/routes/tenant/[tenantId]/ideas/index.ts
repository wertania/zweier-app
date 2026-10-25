/**
 * Routes for leisure ideas (also used as to-do items of a destination)
 */

import type { SymbiosikaFrameworkHonoApp } from "@framework/types";
import { Hono } from "hono";
import { HTTPException } from "hono/http-exception";
import { isTenantMember } from "@framework/routes/tenant";
import { validator } from "hono-openapi";
import * as v from "valibot";
import { durationTypes, weatherTypes } from "../../../../db/schema";
import {
  createIdea,
  deleteIdea,
  getIdeaById,
  getIdeas,
  updateIdea,
} from "../../../../lib/ideas";

const app: SymbiosikaFrameworkHonoApp = new Hono();

const handleError = (c: any, error: unknown, fallback: string) => {
  if (error instanceof HTTPException) throw error;
  if (error instanceof v.ValiError) {
    throw new HTTPException(400, { message: "Validation error", cause: error.issues });
  }
  if (error instanceof Error && (error as any).issues) {
    return c.json({ success: false, error: error.message }, 400);
  }
  return c.json({ success: false, error: fallback }, 500);
};

// GET / - List ideas (optionally filtered)
app.get(
  "/",
  isTenantMember,
  validator("param", v.object({ tenantId: v.string() })),
  validator(
    "query",
    v.object({
      destinationId: v.optional(v.string()),
      weather: v.optional(v.picklist(weatherTypes)),
      duration: v.optional(v.picklist(durationTypes)),
    })
  ),
  async (c) => {
    const { tenantId } = c.req.valid("param");
    try {
      const data = await getIdeas(tenantId, c.req.valid("query"));
      return c.json({ success: true, data });
    } catch (error) {
      return handleError(c, error, "Failed to fetch ideas");
    }
  }
);

// GET /:id - Get one idea
app.get(
  "/:id",
  isTenantMember,
  validator("param", v.object({ tenantId: v.string(), id: v.string() })),
  async (c) => {
    const { tenantId, id } = c.req.valid("param");
    try {
      const data = await getIdeaById(tenantId, id);
      if (!data) return c.json({ success: false, error: "Idea not found" }, 404);
      return c.json({ success: true, data });
    } catch (error) {
      return handleError(c, error, "Failed to fetch idea");
    }
  }
);

// POST / - Create
app.post(
  "/",
  isTenantMember,
  validator("param", v.object({ tenantId: v.string() })),
  async (c) => {
    const { tenantId } = c.req.valid("param");
    try {
      const data = await createIdea(tenantId, await c.req.json());
      return c.json({ success: true, data });
    } catch (error) {
      return handleError(c, error, "Failed to create idea");
    }
  }
);

// PUT /:id - Update
app.put(
  "/:id",
  isTenantMember,
  validator("param", v.object({ tenantId: v.string(), id: v.string() })),
  async (c) => {
    const { tenantId, id } = c.req.valid("param");
    try {
      const data = await updateIdea(tenantId, id, await c.req.json());
      if (!data) return c.json({ success: false, error: "Idea not found" }, 404);
      return c.json({ success: true, data });
    } catch (error) {
      return handleError(c, error, "Failed to update idea");
    }
  }
);

// DELETE /:id - Delete
app.delete(
  "/:id",
  isTenantMember,
  validator("param", v.object({ tenantId: v.string(), id: v.string() })),
  async (c) => {
    const { tenantId, id } = c.req.valid("param");
    try {
      const deleted = await deleteIdea(tenantId, id);
      if (!deleted) return c.json({ success: false, error: "Idea not found" }, 404);
      return c.json({ success: true, data: { id } });
    } catch (error) {
      return handleError(c, error, "Failed to delete idea");
    }
  }
);

export const defineIdeaRoutes = (honoApp: SymbiosikaFrameworkHonoApp) => {
  honoApp.route("/tenant/:tenantId/ideas", app);
};
