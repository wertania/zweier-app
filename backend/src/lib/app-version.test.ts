import { describe, test, expect, beforeEach, afterEach } from "bun:test";
import { Hono } from "hono";
import { testFetcher } from "@framework/test/fetcher.test";
import { getAppVersionInfo, normalizeVersion, resetAppVersionCache } from "./app-version";
import { defineAppRoutes } from "../routes/app";

const fakeGitHub = (tag: string, ok = true) =>
  (async () =>
    new Response(JSON.stringify({ tag_name: tag }), { status: ok ? 200 : 500 })) as unknown as typeof fetch;

describe("app version", () => {
  beforeEach(() => {
    resetAppVersionCache();
    delete process.env.APP_LATEST_VERSION;
    delete process.env.APP_MIN_VERSION;
  });
  afterEach(() => {
    delete process.env.APP_LATEST_VERSION;
    delete process.env.APP_MIN_VERSION;
  });

  test("normalizes tags", () => {
    expect(normalizeVersion("v1.2.3")).toBe("1.2.3");
    expect(normalizeVersion("1.4.0+5")).toBe("1.4.0");
    expect(normalizeVersion("latest")).toBeNull();
    expect(normalizeVersion(undefined)).toBeNull();
  });

  test("uses the latest GitHub release and caches it", async () => {
    expect((await getAppVersionInfo(fakeGitHub("v1.3.0"))).latestVersion).toBe("1.3.0");
    // cached: a newer tag is not fetched again right away
    expect((await getAppVersionInfo(fakeGitHub("v9.9.9"))).latestVersion).toBe("1.3.0");
  });

  test("env overrides GitHub, min version is optional", async () => {
    process.env.APP_LATEST_VERSION = "v2.0.0";
    process.env.APP_MIN_VERSION = "1.2.0";
    const info = await getAppVersionInfo(fakeGitHub("v1.3.0"));
    expect(info.latestVersion).toBe("2.0.0");
    expect(info.minVersion).toBe("1.2.0");
    expect(info.downloadUrl).toContain("releases/latest");
  });

  test("GitHub errors give null instead of failing", async () => {
    expect((await getAppVersionInfo(fakeGitHub("x", false))).latestVersion).toBeNull();
  });

  test("public route works without a token", async () => {
    process.env.APP_LATEST_VERSION = "1.3.0";
    const app = new Hono();
    defineAppRoutes(app as any);
    const res = await testFetcher.get(app as any, "/app/version", undefined);
    expect(res.status).toBe(200);
    expect(res.jsonResponse?.data.latestVersion).toBe("1.3.0");
  });
});
