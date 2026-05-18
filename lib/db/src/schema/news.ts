import { pgTable, serial, text, boolean, timestamp, integer } from "drizzle-orm/pg-core";
import { createInsertSchema } from "drizzle-zod";
import { z } from "zod/v4";

export const newsCategoriesTable = pgTable("news_categories", {
  id: serial("id").primaryKey(),
  name: text("name").notNull(),
  slug: text("slug").notNull().unique(),
});

export const newsTable = pgTable("news", {
  id: serial("id").primaryKey(),
  title: text("title").notNull(),
  content: text("content").notNull(),
  summary: text("summary"),
  category: text("category").notNull().default("general"),
  imageUrl: text("image_url"),
  isFeatured: boolean("is_featured").notNull().default(false),
  isPublished: boolean("is_published").notNull().default(false),
  authorName: text("author_name"),
  viewCount: integer("view_count").notNull().default(0),
  createdAt: timestamp("created_at").notNull().defaultNow(),
  publishedAt: timestamp("published_at"),
});

export const insertNewsSchema = createInsertSchema(newsTable).omit({ id: true, createdAt: true });
export type InsertNews = z.infer<typeof insertNewsSchema>;
export type News = typeof newsTable.$inferSelect;

export const insertNewsCategorySchema = createInsertSchema(newsCategoriesTable).omit({ id: true });
export type InsertNewsCategory = z.infer<typeof insertNewsCategorySchema>;
export type NewsCategory = typeof newsCategoriesTable.$inferSelect;
