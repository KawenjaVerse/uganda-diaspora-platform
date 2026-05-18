import { pgTable, serial, text, boolean, timestamp } from "drizzle-orm/pg-core";
import { createInsertSchema } from "drizzle-zod";
import { z } from "zod/v4";

export const mdasTable = pgTable("mdas", {
  id: serial("id").primaryKey(),
  name: text("name").notNull(),
  description: text("description"),
  logoUrl: text("logo_url"),
  website: text("website"),
  category: text("category"),
  isActive: boolean("is_active").notNull().default(true),
  createdAt: timestamp("created_at").notNull().defaultNow(),
});

export const insertMdaSchema = createInsertSchema(mdasTable).omit({ id: true, createdAt: true });
export type InsertMda = z.infer<typeof insertMdaSchema>;
export type Mda = typeof mdasTable.$inferSelect;
