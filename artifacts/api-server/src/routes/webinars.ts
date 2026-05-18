import { Router } from "express";
import { eq, and, sql, desc, gte } from "drizzle-orm";
import { db, webinarsTable } from "@workspace/db";
import { serializeRow, serializeRows } from "../lib/serialize";
import {
  ListWebinarsQueryParams,
  ListWebinarsResponse,
  CreateWebinarBody,
  GetWebinarParams,
  GetWebinarResponse,
  UpdateWebinarParams,
  UpdateWebinarBody,
  UpdateWebinarResponse,
  DeleteWebinarParams,
} from "@workspace/api-zod";

const router = Router();

router.get("/webinars", async (req, res): Promise<void> => {
  const parsed = ListWebinarsQueryParams.safeParse(req.query);
  if (!parsed.success) { res.status(400).json({ error: parsed.error.message }); return; }

  const { page, limit, category, upcoming } = parsed.data;
  const offset = ((page ?? 1) - 1) * (limit ?? 20);
  const conditions = [];
  if (category) conditions.push(eq(webinarsTable.category, category));
  if (upcoming) conditions.push(gte(webinarsTable.scheduledAt, new Date()));

  const whereClause = conditions.length > 0 ? and(...conditions) : undefined;
  const [{ count }] = await db.select({ count: sql<number>`count(*)::int` }).from(webinarsTable).where(whereClause);
  const data = await db.select().from(webinarsTable).where(whereClause).limit(limit ?? 20).offset(offset).orderBy(desc(webinarsTable.createdAt));

  res.json(ListWebinarsResponse.parse({ data: serializeRows(data), total: count, page: page ?? 1, limit: limit ?? 20 }));
});

router.post("/webinars", async (req, res): Promise<void> => {
  const parsed = CreateWebinarBody.safeParse(req.body);
  if (!parsed.success) { res.status(400).json({ error: parsed.error.message }); return; }

  const [webinar] = await db.insert(webinarsTable).values({
    ...parsed.data,
    scheduledAt: parsed.data.scheduledAt ? new Date(parsed.data.scheduledAt) : null,
  }).returning();
  res.status(201).json(GetWebinarResponse.parse(serializeRow(webinar)));
});

router.get("/webinars/:id", async (req, res): Promise<void> => {
  const params = GetWebinarParams.safeParse(req.params);
  if (!params.success) { res.status(400).json({ error: params.error.message }); return; }

  const [webinar] = await db.select().from(webinarsTable).where(eq(webinarsTable.id, params.data.id));
  if (!webinar) { res.status(404).json({ error: "Webinar not found" }); return; }

  await db.update(webinarsTable).set({ viewCount: sql`${webinarsTable.viewCount} + 1` }).where(eq(webinarsTable.id, params.data.id));
  res.json(GetWebinarResponse.parse(serializeRow(webinar)));
});

router.patch("/webinars/:id", async (req, res): Promise<void> => {
  const params = UpdateWebinarParams.safeParse(req.params);
  if (!params.success) { res.status(400).json({ error: params.error.message }); return; }

  const body = UpdateWebinarBody.safeParse(req.body);
  if (!body.success) { res.status(400).json({ error: body.error.message }); return; }

  const updateData = { ...body.data, scheduledAt: body.data.scheduledAt ? new Date(body.data.scheduledAt) : undefined };
  const [webinar] = await db.update(webinarsTable).set(updateData).where(eq(webinarsTable.id, params.data.id)).returning();
  if (!webinar) { res.status(404).json({ error: "Webinar not found" }); return; }

  res.json(UpdateWebinarResponse.parse(serializeRow(webinar)));
});

router.delete("/webinars/:id", async (req, res): Promise<void> => {
  const params = DeleteWebinarParams.safeParse(req.params);
  if (!params.success) { res.status(400).json({ error: params.error.message }); return; }

  await db.delete(webinarsTable).where(eq(webinarsTable.id, params.data.id));
  res.sendStatus(204);
});

export default router;
