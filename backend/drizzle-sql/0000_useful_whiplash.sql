CREATE TYPE "public"."app_duration" AS ENUM('short', 'half_day', 'full_day', 'multi_day');--> statement-breakpoint
CREATE TYPE "public"."app_weather" AS ENUM('sunny', 'cloudy', 'rainy', 'snowy', 'any');--> statement-breakpoint
CREATE TABLE "app_destinations" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"tenant_id" uuid NOT NULL,
	"name" varchar(255) NOT NULL,
	"country" varchar(255),
	"description" text,
	"emoji" varchar(16) DEFAULT '🗺️' NOT NULL,
	"latitude" double precision,
	"longitude" double precision,
	"planned_for" date,
	"visited" boolean DEFAULT false NOT NULL,
	"created_at" timestamp DEFAULT now() NOT NULL,
	"updated_at" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "app_ideas" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"tenant_id" uuid NOT NULL,
	"destination_id" uuid,
	"title" varchar(255) NOT NULL,
	"description" text,
	"emoji" varchar(16) DEFAULT '💡' NOT NULL,
	"weather" "app_weather" DEFAULT 'any' NOT NULL,
	"duration" "app_duration" DEFAULT 'half_day' NOT NULL,
	"favorite" boolean DEFAULT false NOT NULL,
	"done" boolean DEFAULT false NOT NULL,
	"done_at" timestamp,
	"created_at" timestamp DEFAULT now() NOT NULL,
	"updated_at" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint
ALTER TABLE "app_destinations" ADD CONSTRAINT "app_destinations_tenant_id_base_tenants_id_fk" FOREIGN KEY ("tenant_id") REFERENCES "public"."base_tenants"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "app_ideas" ADD CONSTRAINT "app_ideas_tenant_id_base_tenants_id_fk" FOREIGN KEY ("tenant_id") REFERENCES "public"."base_tenants"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "app_ideas" ADD CONSTRAINT "app_ideas_destination_id_app_destinations_id_fk" FOREIGN KEY ("destination_id") REFERENCES "public"."app_destinations"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
CREATE INDEX "destinations_tenant_id_idx" ON "app_destinations" USING btree ("tenant_id");--> statement-breakpoint
CREATE INDEX "ideas_tenant_id_idx" ON "app_ideas" USING btree ("tenant_id");--> statement-breakpoint
CREATE INDEX "ideas_destination_id_idx" ON "app_ideas" USING btree ("destination_id");