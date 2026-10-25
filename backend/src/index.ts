import { defineServer } from "@framework/index";
import * as appDbSchema from "./db/schema";
import defineChatRoutes from "./routes/tenant/[tenantId]/chat";
import { defineIdeaRoutes } from "./routes/tenant/[tenantId]/ideas";
import { defineDestinationRoutes } from "./routes/tenant/[tenantId]/destinations";
import { defineSuggestionRoutes } from "./routes/tenant/[tenantId]/suggestions";

const server = defineServer({
  port: 3000,
  jwtExpiresAfter: 60 * 60 * 24 * 30, // 30 days
  appName: "Zweier",
  basePath: "/api/v1",
  loginUrl: "/login.html",
  magicLoginVerifyUrl: "/magic-login-verify.html",
  staticPublicDataPath: "./public",
  staticPrivateDataPath: "./static",
  customDbSchema: {
    ...appDbSchema,
  },
  customHonoAppsWithAuth: [
    {
      baseRoute: "",
      app: (app) => {
        defineChatRoutes(app);
        defineIdeaRoutes(app);
        defineDestinationRoutes(app);
        defineSuggestionRoutes(app);
      },
    },
  ],
});

export default server;
