import type { DurationType, IdeasSelect, WeatherType } from "../db/schema";
import { durationsUpTo, getIdeas } from "./ideas";
import { getForecast, type WeatherForecast } from "./weather";

export type SuggestionRequest = {
  weather?: WeatherType;
  maxDuration?: DurationType;
  latitude?: number;
  longitude?: number;
  /** ISO date (YYYY-MM-DD) the suggestion is for. Defaults to today. */
  date?: string;
  /** Restrict to the to-do list of a destination. Default: ideas without destination. */
  destinationId?: string;
  count?: number;
};

export type SuggestionResult = {
  weather: WeatherType;
  forecast: WeatherForecast | null;
  suggestions: IdeasSelect[];
};

/**
 * Scores an idea: open ideas first, favourites and exact weather matches get a
 * bonus, ideas done long ago are fine again. A bit of randomness keeps it fresh.
 */
export function scoreIdea(idea: IdeasSelect, weather: WeatherType, random = Math.random()) {
  let score = random * 2;
  if (idea.favorite) score += 1.5;
  if (weather !== "any" && idea.weather === weather) score += 1;
  if (idea.done) {
    const daysAgo = idea.doneAt
      ? (Date.now() - new Date(idea.doneAt).getTime()) / 86_400_000
      : 0;
    score -= daysAgo > 60 ? 0.5 : 3;
  }
  return score;
}

export async function getSuggestions(
  tenantId: string,
  req: SuggestionRequest
): Promise<SuggestionResult> {
  const date = req.date ?? new Date().toISOString().slice(0, 10);
  let forecast: WeatherForecast | null = null;
  let weather: WeatherType = req.weather ?? "any";
  if (!req.weather && req.latitude !== undefined && req.longitude !== undefined) {
    forecast = await getForecast(req.latitude, req.longitude, date);
    if (forecast) weather = forecast.weather;
  }

  const allowedDurations = durationsUpTo(req.maxDuration ?? "multi_day");
  const candidates = (
    await getIdeas(tenantId, { destinationId: req.destinationId ?? "none" })
  ).filter(
    (idea) =>
      allowedDurations.includes(idea.duration) &&
      (weather === "any" || idea.weather === "any" || idea.weather === weather)
  );

  const suggestions = candidates
    .map((idea) => ({ idea, score: scoreIdea(idea, weather) }))
    .sort((a, b) => b.score - a.score)
    .slice(0, req.count ?? 3)
    .map((s) => s.idea);

  return { weather, forecast, suggestions };
}
