import { pgEnum } from "drizzle-orm/pg-core";
import { PREFIX } from "../index";

/** Which weather an idea fits. "any" fits every weather. */
export const weatherTypes = ["sunny", "cloudy", "rainy", "snowy", "any"] as const;
export const weatherEnum = pgEnum(`${PREFIX}weather`, weatherTypes);
export type WeatherType = (typeof weatherTypes)[number];

/** Rough duration of an idea, ordered from short to long. */
export const durationTypes = ["short", "half_day", "full_day", "multi_day"] as const;
export const durationEnum = pgEnum(`${PREFIX}duration`, durationTypes);
export type DurationType = (typeof durationTypes)[number];

/** When an idea can be done. "any" fits day and evening. */
export const timeOfDayTypes = ["any", "day", "evening"] as const;
export const timeOfDayEnum = pgEnum(`${PREFIX}time_of_day`, timeOfDayTypes);
export type TimeOfDayType = (typeof timeOfDayTypes)[number];

/** Optional categories, an idea can have several. */
export const categoryTypes = ["city", "outdoor", "friends", "culture"] as const;
export const categoryEnum = pgEnum(`${PREFIX}category`, categoryTypes);
export type CategoryType = (typeof categoryTypes)[number];
