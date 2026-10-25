/**
 * Public routes for the mobile app (no login needed)
 */

import type { SymbiosikaFrameworkHonoApp } from "@framework/types";
import { Hono } from "hono";
import { getAppVersionInfo } from "../../lib/app-version";

const app: SymbiosikaFrameworkHonoApp = new Hono();

// GET /version - newest app version and where to download it
app.get("/version", async (c) => {
  try {
    const data = await getAppVersionInfo();
    c.header("Cache-Control", "public, max-age=300");
    return c.json({ success: true, data });
  } catch (error) {
    return c.json({ success: false, error: "Failed to get app version" }, 500);
  }
});

export const defineAppRoutes = (honoApp: SymbiosikaFrameworkHonoApp) => {
  honoApp.route("/app", app);
};
