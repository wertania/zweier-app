import type { WeatherType } from "../db/schema";

export type WeatherForecast = {
  date: string;
  weather: Exclude<WeatherType, "any">;
  temperatureMax: number | null;
  temperatureMin: number | null;
  precipitationProbability: number | null;
};

/** Maps a WMO weather code (used by Open-Meteo) to our weather categories. */
export function weatherFromWmoCode(code: number): Exclude<WeatherType, "any"> {
  if (code <= 1) return "sunny";
  if (code <= 48) return "cloudy";
  if ((code >= 71 && code <= 77) || code === 85 || code === 86) return "snowy";
  return "rainy";
}

/**
 * Fetches the daily forecast for a date from Open-Meteo (free, no API key).
 * Returns null if the forecast is not available.
 */
export async function getForecast(
  latitude: number,
  longitude: number,
  date: string
): Promise<WeatherForecast | null> {
  const url = new URL("https://api.open-meteo.com/v1/forecast");
  url.searchParams.set("latitude", String(latitude));
  url.searchParams.set("longitude", String(longitude));
  url.searchParams.set(
    "daily",
    "weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max"
  );
  url.searchParams.set("timezone", "auto");
  url.searchParams.set("start_date", date);
  url.searchParams.set("end_date", date);
  try {
    const res = await fetch(url, { signal: AbortSignal.timeout(5000) });
    if (!res.ok) return null;
    const json = (await res.json()) as any;
    const code = json?.daily?.weather_code?.[0];
    if (typeof code !== "number") return null;
    return {
      date,
      weather: weatherFromWmoCode(code),
      temperatureMax: json.daily.temperature_2m_max?.[0] ?? null,
      temperatureMin: json.daily.temperature_2m_min?.[0] ?? null,
      precipitationProbability: json.daily.precipitation_probability_max?.[0] ?? null,
    };
  } catch {
    return null;
  }
}
