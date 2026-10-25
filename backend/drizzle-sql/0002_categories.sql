CREATE TYPE "public"."app_category" AS ENUM('city', 'outdoor', 'friends', 'culture');--> statement-breakpoint
ALTER TABLE "app_ideas" ADD COLUMN "categories" "app_category"[] DEFAULT '{}' NOT NULL;