import { Router } from "express";
import { eq, sql, desc } from "drizzle-orm";
import { db, notificationsTable } from "@workspace/db";
import { serializeRow, serializeRows } from "../lib/serialize";
import {
  ListNotificationsQueryParams,
  ListNotificationsResponse,
  SendNotificationBody,
  DeleteNotificationParams,
} from "@workspace/api-zod";

const router = Router();

router.get("/notifications", async (req, res): Promise<void> => {
  const parsed = ListNotificationsQueryParams.safeParse(req.query);
  if (!parsed.success) { res.status(400).json({ error: parsed.error.message }); return; }

  const { page, limit } = parsed.data;
  const offset = ((page ?? 1) - 1) * (limit ?? 20);
  const [{ count }] = await db.select({ count: sql<number>`count(*)::int` }).from(notificationsTable);
  const data = await db.select().from(notificationsTable).limit(limit ?? 20).offset(offset).orderBy(desc(notificationsTable.createdAt));

  res.json(ListNotificationsResponse.parse({ data: serializeRows(data), total: count, page: page ?? 1, limit: limit ?? 20 }));
});

router.post("/notifications", async (req, res): Promise<void> => {
  const parsed = SendNotificationBody.safeParse(req.body);
  if (!parsed.success) { res.status(400).json({ error: parsed.error.message }); return; }

  const [notification] = await db.insert(notificationsTable).values({
    ...parsed.data,
    sentCount: 0,
  }).returning();

  res.status(201).json(notification);
});

router.delete("/notifications/:id", async (req, res): Promise<void> => {
  const params = DeleteNotificationParams.safeParse(req.params);
  if (!params.success) { res.status(400).json({ error: params.error.message }); return; }

  await db.delete(notificationsTable).where(eq(notificationsTable.id, params.data.id));
  res.sendStatus(204);
});

export default router;
