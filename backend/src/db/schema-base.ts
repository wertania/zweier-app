import { pgTableCreator } from "drizzle-orm/pg-core";
import { PREFIX } from "./index";

export const pgBaseTable = pgTableCreator((name: string) => `${PREFIX}${name}`);
