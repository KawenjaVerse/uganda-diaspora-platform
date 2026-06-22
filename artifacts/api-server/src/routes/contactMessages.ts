import { Router } from "express";
import { eq, sql, desc } from "drizzle-orm";
import { db } from "@workspace/db";
import { contactMessagesTable } from "@workspace/db";
import { serializeRows, serializeRow } from "../lib/serialize";
import { verifyToken } from "./auth";

const router = Router();

router.post("/contact-messages", async (req, res): Promise<void> => {
  const { name, email, subject, message } = req.body ?? {};
  if (!name || !email || !message) {
    res.status(400).json({ error: "name, email, and message are required" });
    return;
  }
  if (typeof name !== "string" || typeof email !== "string" || typeof message !== "string") {
    res.status(400).json({ error: "Invalid field types" });
    return;
  }

  const [row] = await db.insert(contactMessagesTable).values({
    name: String(name).trim(),
    email: String(email).trim(),
    subject: subject ? String(subject).trim() : null,
    message: String(message).trim(),
  }).returning();

  res.status(201).json(serializeRow(row));
});

router.get("/contact-messages", async (req, res): Promise<void> => {
  const token = (req.headers.authorization ?? "").replace("Bearer ", "");
  const user = verifyToken(token);
  if (!user || user.role !== "admin") { res.status(403).json({ error: "Forbidden" }); return; }

  const page  = Math.max(1, parseInt(String(req.query.page  ?? "1"), 10));
  const limit = Math.min(100, parseInt(String(req.query.limit ?? "50"), 10));
  const offset = (page - 1) * limit;

  const [{ count }] = await db.select({ count: sql<number>`count(*)::int` }).from(contactMessagesTable);
  const data = await db.select().from(contactMessagesTable).limit(limit).offset(offset).orderBy(desc(contactMessagesTable.createdAt));

  res.json({ data: serializeRows(data), total: count, page, limit });
});

router.patch("/contact-messages/:id", async (req, res): Promise<void> => {
  const token = (req.headers.authorization ?? "").replace("Bearer ", "");
  const user = verifyToken(token);
  if (!user || user.role !== "admin") { res.status(403).json({ error: "Forbidden" }); return; }

  const id = parseInt(req.params.id, 10);
  if (isNaN(id)) { res.status(400).json({ error: "Invalid id" }); return; }

  const { status } = req.body ?? {};
  if (status !== "read" && status !== "unread") {
    res.status(400).json({ error: "status must be 'read' or 'unread'" });
    return;
  }

  const [row] = await db.update(contactMessagesTable).set({ status }).where(eq(contactMessagesTable.id, id)).returning();
  if (!row) { res.status(404).json({ error: "Not found" }); return; }
  res.json(serializeRow(row));
});

router.delete("/contact-messages/:id", async (req, res): Promise<void> => {
  const token = (req.headers.authorization ?? "").replace("Bearer ", "");
  const user = verifyToken(token);
  if (!user || user.role !== "admin") { res.status(403).json({ error: "Forbidden" }); return; }

  const id = parseInt(req.params.id, 10);
  if (isNaN(id)) { res.status(400).json({ error: "Invalid id" }); return; }

  await db.delete(contactMessagesTable).where(eq(contactMessagesTable.id, id));
  res.status(204).send();
});

export default router;
