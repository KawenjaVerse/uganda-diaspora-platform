import { pgTable, serial, text, boolean, timestamp, integer } from "drizzle-orm/pg-core";
import { createInsertSchema } from "drizzle-zod";
import { z } from "zod/v4";

export const eventsTable = pgTable("events", {
  id: serial("id").primaryKey(),
  title: text("title").notNull(),
  description: text("description"),
  location: text("location"),
  imageUrl: text("image_url"),
  category: text("category"),
  startDate: timestamp("start_date").notNull(),
  endDate: timestamp("end_date"),
  registrationUrl: text("registration_url"),
  isVirtual: boolean("is_virtual").notNull().default(false),
  isPublished: boolean("is_published").notNull().default(true),
  registrationCount: integer("registration_count").notNull().default(0),
  createdAt: timestamp("created_at").notNull().defaultNow(),
});

export const insertEventSchema = createInsertSchema(eventsTable).omit({ id: true, createdAt: true });
export type InsertEvent = z.infer<typeof insertEventSchema>;
export type Event = typeof eventsTable.$inferSelect;
