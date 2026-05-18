import { pgTable, serial, text, boolean, timestamp, real } from "drizzle-orm/pg-core";
import { createInsertSchema } from "drizzle-zod";
import { z } from "zod/v4";

export const embassiesTable = pgTable("embassies", {
  id: serial("id").primaryKey(),
  country: text("country").notNull(),
  city: text("city").notNull(),
  continent: text("continent"),
  region: text("region"),
  address: text("address"),
  phone: text("phone"),
  email: text("email"),
  website: text("website"),
  imageUrl: text("image_url"),
  flagUrl: text("flag_url"),
  ambassadorName: text("ambassador_name"),
  ambassadorImageUrl: text("ambassador_image_url"),
  officeHours: text("office_hours"),
  servicesOffered: text("services_offered"),
  emergencyContact: text("emergency_contact"),
  latitude: real("latitude"),
  longitude: real("longitude"),
  isActive: boolean("is_active").notNull().default(true),
  createdAt: timestamp("created_at").notNull().defaultNow(),
});

export const insertEmbassySchema = createInsertSchema(embassiesTable).omit({ id: true, createdAt: true });
export type InsertEmbassy = z.infer<typeof insertEmbassySchema>;
export type Embassy = typeof embassiesTable.$inferSelect;
