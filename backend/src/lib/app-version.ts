import { APP_DOWNLOAD_URL } from "./email-templates";

/**
 * Which app version is current, so the app can ask for an update.
 *
 * `latestVersion` comes from APP_LATEST_VERSION or, if unset, from the latest
 * GitHub release (cached). `minVersion` (APP_MIN_VERSION) marks versions that
 * no longer work with this server – the app then insists on the update.
 */
export type AppVersionInfo = {
  latestVersion: string | null;
  minVersion: string | null;
  downloadUrl: string;
};

const RELEASES_API =
  process.env.APP_RELEASES_API ??
  "https://api.github.com/repos/wertania/zweier-app/releases/latest";
const CACHE_MS = 30 * 60 * 1000;

let cache: { version: string | null; fetchedAt: number } | null = null;

/** "v1.2.0" → "1.2.0"; anything that is not x.y.z → null. */
export function normalizeVersion(value: unknown): string | null {
  if (typeof value !== "string") return null;
  const match = value.trim().match(/^v?(\d+)\.(\d+)\.(\d+)/);
  return match ? `${match[1]}.${match[2]}.${match[3]}` : null;
}

/** Fetches the newest release tag; keeps the last known value on errors. */
async function latestReleaseVersion(fetchImpl: typeof fetch = fetch) {
  if (cache && Date.now() - cache.fetchedAt < CACHE_MS) return cache.version;
  try {
    const res = await fetchImpl(RELEASES_API, {
      headers: { Accept: "application/vnd.github+json" },
      signal: AbortSignal.timeout(5000),
    });
    if (!res.ok) throw new Error(`GitHub answered ${res.status}`);
    const json = (await res.json()) as { tag_name?: string };
    cache = { version: normalizeVersion(json.tag_name), fetchedAt: Date.now() };
  } catch {
    // retry in a minute instead of hammering GitHub
    cache = { version: cache?.version ?? null, fetchedAt: Date.now() - CACHE_MS + 60_000 };
  }
  return cache.version;
}

export async function getAppVersionInfo(fetchImpl?: typeof fetch): Promise<AppVersionInfo> {
  const fixed = normalizeVersion(process.env.APP_LATEST_VERSION);
  return {
    latestVersion: fixed ?? (await latestReleaseVersion(fetchImpl)),
    minVersion: normalizeVersion(process.env.APP_MIN_VERSION),
    downloadUrl: APP_DOWNLOAD_URL,
  };
}

/** For tests. */
export function resetAppVersionCache() {
  cache = null;
}
