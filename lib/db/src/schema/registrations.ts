import { pgTable, serial, text, timestamp } from "drizzle-orm/pg-core";
import { createInsertSchema } from "drizzle-zod";
import { z } from "zod/v4";

export const diasporaRegistrationsTable = pgTable("diaspora_registrations", {
  id: serial("id").primaryKey(),
  fullName: text("full_name").notNull(),
  dateOfBirth: text("date_of_birth"),
  gender: text("gender"),
  nationalId: text("national_id"),
  country: text("country"),
  city: text("city"),
  phone: text("phone"),
  email: text("email"),
  profession: text("profession"),
  yearsAbroad: text("years_abroad"),
  reasonForDiaspora: text("reason_for_diaspora"),
  createdAt: timestamp("created_at").notNull().defaultNow(),
});

export const insertDiasporaRegistrationSchema = createInsertSchema(diasporaRegistrationsTable).omit({
  id: true,
  createdAt: true,
});

export type InsertDiasporaRegistration = z.infer<typeof insertDiasporaRegistrationSchema>;
export type DiasporaRegistration = typeof diasporaRegistrationsTable.$inferSelect;
