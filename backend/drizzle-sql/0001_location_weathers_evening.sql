CREATE TYPE "public"."app_time_of_day" AS ENUM('any', 'day', 'evening');--> statement-breakpoint
ALTER TABLE "app_ideas" ADD COLUMN "location" varchar(255);--> statement-breakpoint
ALTER TABLE "app_ideas" ADD COLUMN "weathers" "app_weather"[] DEFAULT '{any}' NOT NULL;--> statement-breakpoint
ALTER TABLE "app_ideas" ADD COLUMN "time_of_day" "app_time_of_day" DEFAULT 'any' NOT NULL;--> statement-breakpoint
-- keep the weather of existing ideas
UPDATE "app_ideas" SET "weathers" = ARRAY["weather"];--> statement-breakpoint
ALTER TABLE "app_ideas" DROP COLUMN "weather";