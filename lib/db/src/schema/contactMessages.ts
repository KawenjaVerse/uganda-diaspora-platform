import { pgTable, serial, text, timestamp } from "drizzle-orm/pg-core";

export const contactMessagesTable = pgTable("contact_messages", {
  id:        serial("id").primaryKey(),
  name:      text("name").notNull(),
  email:     text("email").notNull(),
  subject:   text("subject"),
  message:   text("message").notNull(),
  status:    text("status").notNull().default("unread"),
  createdAt: timestamp("created_at").notNull().defaultNow(),
});
