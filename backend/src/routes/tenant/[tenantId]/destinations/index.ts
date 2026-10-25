/**
 * Routes for travel destinations
 */

import type { SymbiosikaFrameworkHonoApp } from "@framework/types";
import { Hono } from "hono";
import { HTTPException } from "hono/http-exception";
import { isTenantMember } from "@framework/routes/tenant";
import { validator } from "hono-openapi";
import * as v from "valibot";
import {
  createDestination,
  deleteDestination,
  getDestinationById,
  getDestinations,
  updateDestination,
} from "../../../../lib/destinations";

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

// GET / - List destinations with to-do counts
app.get(
  "/",
  isTenantMember,
  validator("param", v.object({ tenantId: v.string() })),
  async (c) => {
    const { tenantId } = c.req.valid("param");
    try {
      const data = await getDestinations(tenantId);
      return c.json({ success: true, data });
    } catch (error) {
      return handleError(c, error, "Failed to fetch destinations");
    }
  }
);

// GET /:id - Get one destination
app.get(
  "/:id",
  isTenantMember,
  validator("param", v.object({ tenantId: v.string(), id: v.string() })),
  async (c) => {
    const { tenantId, id } = c.req.valid("param");
    try {
      const data = await getDestinationById(tenantId, id);
      if (!data) return c.json({ success: false, error: "Destination not found" }, 404);
      return c.json({ success: true, data });
    } catch (error) {
      return handleError(c, error, "Failed to fetch destination");
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
      const data = await createDestination(tenantId, await c.req.json());
      return c.json({ success: true, data });
    } catch (error) {
      return handleError(c, error, "Failed to create destination");
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
      const data = await updateDestination(tenantId, id, await c.req.json());
      if (!data) return c.json({ success: false, error: "Destination not found" }, 404);
      return c.json({ success: true, data });
    } catch (error) {
      return handleError(c, error, "Failed to update destination");
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
      const deleted = await deleteDestination(tenantId, id);
      if (!deleted) return c.json({ success: false, error: "Destination not found" }, 404);
      return c.json({ success: true, data: { id } });
    } catch (error) {
      return handleError(c, error, "Failed to delete destination");
    }
  }
);

export const defineDestinationRoutes = (honoApp: SymbiosikaFrameworkHonoApp) => {
  honoApp.route("/tenant/:tenantId/destinations", app);
};
