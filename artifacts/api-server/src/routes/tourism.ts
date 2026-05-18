import { Router } from "express";
import { eq, ilike, and, sql, desc } from "drizzle-orm";
import { db, tourismTable } from "@workspace/db";
import { serializeRow, serializeRows } from "../lib/serialize";
import {
  ListTourismQueryParams,
  ListTourismResponse,
  CreateTourismBody,
  GetTourismParams,
  GetTourismResponse,
  UpdateTourismParams,
  UpdateTourismBody,
  UpdateTourismResponse,
  DeleteTourismParams,
} from "@workspace/api-zod";

const router = Router();

router.get("/tourism", async (req, res): Promise<void> => {
  const parsed = ListTourismQueryParams.safeParse(req.query);
  if (!parsed.success) { res.status(400).json({ error: parsed.error.message }); return; }

  const { page, limit, search, category } = parsed.data;
  const offset = ((page ?? 1) - 1) * (limit ?? 20);
  const conditions = [];
  if (search) conditions.push(ilike(tourismTable.name, `%${search}%`));
  if (category) conditions.push(eq(tourismTable.category, category));

  const whereClause = conditions.length > 0 ? and(...conditions) : undefined;
  const [{ count }] = await db.select({ count: sql<number>`count(*)::int` }).from(tourismTable).where(whereClause);
  const data = await db.select().from(tourismTable).where(whereClause).limit(limit ?? 20).offset(offset).orderBy(desc(tourismTable.isFeatured));

  res.json(ListTourismResponse.parse({ data: serializeRows(data), total: count, page: page ?? 1, limit: limit ?? 20 }));
});

router.post("/tourism", async (req, res): Promise<void> => {
  const parsed = CreateTourismBody.safeParse(req.body);
  if (!parsed.success) { res.status(400).json({ error: parsed.error.message }); return; }

  const [attraction] = await db.insert(tourismTable).values(parsed.data).returning();
  res.status(201).json(GetTourismResponse.parse(serializeRow(attraction)));
});

router.get("/tourism/:id", async (req, res): Promise<void> => {
  const params = GetTourismParams.safeParse(req.params);
  if (!params.success) { res.status(400).json({ error: params.error.message }); return; }

  const [attraction] = await db.select().from(tourismTable).where(eq(tourismTable.id, params.data.id));
  if (!attraction) { res.status(404).json({ error: "Attraction not found" }); return; }

  res.json(GetTourismResponse.parse(serializeRow(attraction)));
});

router.patch("/tourism/:id", async (req, res): Promise<void> => {
  const params = UpdateTourismParams.safeParse(req.params);
  if (!params.success) { res.status(400).json({ error: params.error.message }); return; }

  const body = UpdateTourismBody.safeParse(req.body);
  if (!body.success) { res.status(400).json({ error: body.error.message }); return; }

  const [attraction] = await db.update(tourismTable).set(body.data).where(eq(tourismTable.id, params.data.id)).returning();
  if (!attraction) { res.status(404).json({ error: "Attraction not found" }); return; }

  res.json(UpdateTourismResponse.parse(serializeRow(attraction)));
});

router.delete("/tourism/:id", async (req, res): Promise<void> => {
  const params = DeleteTourismParams.safeParse(req.params);
  if (!params.success) { res.status(400).json({ error: params.error.message }); return; }

  await db.delete(tourismTable).where(eq(tourismTable.id, params.data.id));
  res.sendStatus(204);
});

export default router;
