import { pgTable, serial, text, boolean, timestamp, real } from "drizzle-orm/pg-core";
import { createInsertSchema } from "drizzle-zod";
import { z } from "zod/v4";

export const tourismTable = pgTable("tourism_attractions", {
  id: serial("id").primaryKey(),
  name: text("name").notNull(),
  description: text("description"),
  category: text("category").notNull().default("attraction"),
  location: text("location"),
  imageUrl: text("image_url"),
  gallery: text("gallery"),
  latitude: real("latitude"),
  longitude: real("longitude"),
  entryFee: text("entry_fee"),
  openingHours: text("opening_hours"),
  contactPhone: text("contact_phone"),
  website: text("website"),
  isFeatured: boolean("is_featured").notNull().default(false),
  createdAt: timestamp("created_at").notNull().defaultNow(),
});

export const insertTourismSchema = createInsertSchema(tourismTable).omit({ id: true, createdAt: true });
export type InsertTourism = z.infer<typeof insertTourismSchema>;
export type Tourism = typeof tourismTable.$inferSelect;
