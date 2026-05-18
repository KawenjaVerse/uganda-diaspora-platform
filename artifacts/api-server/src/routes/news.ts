import { Router } from "express";
import { eq, ilike, and, sql, desc } from "drizzle-orm";
import { db, newsTable, newsCategoriesTable } from "@workspace/db";
import { serializeRow, serializeRows } from "../lib/serialize";
import {
  ListNewsQueryParams,
  ListNewsResponse,
  CreateNewsBody,
  GetNewsParams,
  GetNewsResponse,
  UpdateNewsParams,
  UpdateNewsBody,
  UpdateNewsResponse,
  DeleteNewsParams,
  ListNewsCategoriesResponseItem,
} from "@workspace/api-zod";
import { activityTable } from "@workspace/db";

const router = Router();

router.get("/news/categories", async (_req, res): Promise<void> => {
  const categories = await db.select().from(newsCategoriesTable).orderBy(newsCategoriesTable.name);
  res.json(categories.map(c => ListNewsCategoriesResponseItem.parse(c)));
});

router.get("/news", async (req, res): Promise<void> => {
  const parsed = ListNewsQueryParams.safeParse(req.query);
  if (!parsed.success) { res.status(400).json({ error: parsed.error.message }); return; }

  const { page, limit, search, category, featured } = parsed.data;
  const offset = ((page ?? 1) - 1) * (limit ?? 20);
  const conditions = [];
  if (search) conditions.push(ilike(newsTable.title, `%${search}%`));
  if (category) conditions.push(eq(newsTable.category, category));
  if (featured != null) conditions.push(eq(newsTable.isFeatured, featured));

  const whereClause = conditions.length > 0 ? and(...conditions) : undefined;
  const [{ count }] = await db.select({ count: sql<number>`count(*)::int` }).from(newsTable).where(whereClause);
  const data = await db.select().from(newsTable).where(whereClause).limit(limit ?? 20).offset(offset).orderBy(desc(newsTable.createdAt));

  res.json(ListNewsResponse.parse({ data: serializeRows(data), total: count, page: page ?? 1, limit: limit ?? 20 }));
});

router.post("/news", async (req, res): Promise<void> => {
  const parsed = CreateNewsBody.safeParse(req.body);
  if (!parsed.success) { res.status(400).json({ error: parsed.error.message }); return; }

  const [article] = await db.insert(newsTable).values({
    ...parsed.data,
    publishedAt: parsed.data.isPublished ? new Date() : null,
  }).returning();

  await db.insert(activityTable).values({ type: "news_created", description: `News article "${article.title}" was published` });
  res.status(201).json(GetNewsResponse.parse(serializeRow(article)));
});

router.get("/news/:id", async (req, res): Promise<void> => {
  const params = GetNewsParams.safeParse(req.params);
  if (!params.success) { res.status(400).json({ error: params.error.message }); return; }

  const [article] = await db.select().from(newsTable).where(eq(newsTable.id, params.data.id));
  if (!article) { res.status(404).json({ error: "News article not found" }); return; }

  await db.update(newsTable).set({ viewCount: sql`${newsTable.viewCount} + 1` }).where(eq(newsTable.id, params.data.id));
  res.json(GetNewsResponse.parse(serializeRow(article)));
});

router.patch("/news/:id", async (req, res): Promise<void> => {
  const params = UpdateNewsParams.safeParse(req.params);
  if (!params.success) { res.status(400).json({ error: params.error.message }); return; }

  const body = UpdateNewsBody.safeParse(req.body);
  if (!body.success) { res.status(400).json({ error: body.error.message }); return; }

  const updateData: Record<string, unknown> = { ...body.data };
  if (body.data.isPublished) updateData.publishedAt = new Date();

  const [article] = await db.update(newsTable).set(updateData).where(eq(newsTable.id, params.data.id)).returning();
  if (!article) { res.status(404).json({ error: "News article not found" }); return; }

  res.json(UpdateNewsResponse.parse(serializeRow(article)));
});

router.delete("/news/:id", async (req, res): Promise<void> => {
  const params = DeleteNewsParams.safeParse(req.params);
  if (!params.success) { res.status(400).json({ error: params.error.message }); return; }

  await db.delete(newsTable).where(eq(newsTable.id, params.data.id));
  res.sendStatus(204);
});

export default router;
