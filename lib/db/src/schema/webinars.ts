import { pgTable, serial, text, boolean, timestamp, integer } from "drizzle-orm/pg-core";
import { createInsertSchema } from "drizzle-zod";
import { z } from "zod/v4";

export const webinarsTable = pgTable("webinars", {
  id: serial("id").primaryKey(),
  title: text("title").notNull(),
  description: text("description"),
  youtubeUrl: text("youtube_url"),
  thumbnailUrl: text("thumbnail_url"),
  category: text("category"),
  speakerName: text("speaker_name"),
  scheduledAt: timestamp("scheduled_at"),
  isLive: boolean("is_live").notNull().default(false),
  isPublished: boolean("is_published").notNull().default(true),
  viewCount: integer("view_count").notNull().default(0),
  registrationCount: integer("registration_count").notNull().default(0),
  createdAt: timestamp("created_at").notNull().defaultNow(),
});

export const insertWebinarSchema = createInsertSchema(webinarsTable).omit({ id: true, createdAt: true });
export type InsertWebinar = z.infer<typeof insertWebinarSchema>;
export type Webinar = typeof webinarsTable.$inferSelect;
