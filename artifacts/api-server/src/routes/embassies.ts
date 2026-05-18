import { Router } from "express";
import { eq, ilike, and, sql, asc } from "drizzle-orm";
import { db, embassiesTable } from "@workspace/db";
import { serializeRow, serializeRows } from "../lib/serialize";
import {
  ListEmbassiesQueryParams,
  ListEmbassiesResponse,
  CreateEmbassyBody,
  GetEmbassyParams,
  GetEmbassyResponse,
  UpdateEmbassyParams,
  UpdateEmbassyBody,
  UpdateEmbassyResponse,
  DeleteEmbassyParams,
} from "@workspace/api-zod";

const router = Router();

router.get("/embassies", async (req, res): Promise<void> => {
  const parsed = ListEmbassiesQueryParams.safeParse(req.query);
  if (!parsed.success) { res.status(400).json({ error: parsed.error.message }); return; }

  const { page, limit, search, continent, region } = parsed.data;
  const offset = ((page ?? 1) - 1) * (limit ?? 50);
  const conditions = [];
  if (search) conditions.push(ilike(embassiesTable.country, `%${search}%`));
  if (continent) conditions.push(eq(embassiesTable.continent, continent));
  if (region) conditions.push(eq(embassiesTable.region, region));

  const whereClause = conditions.length > 0 ? and(...conditions) : undefined;
  const [{ count }] = await db.select({ count: sql<number>`count(*)::int` }).from(embassiesTable).where(whereClause);
  const data = await db.select().from(embassiesTable).where(whereClause).limit(limit ?? 50).offset(offset).orderBy(asc(embassiesTable.country));

  res.json(ListEmbassiesResponse.parse({ data: serializeRows(data), total: count, page: page ?? 1, limit: limit ?? 50 }));
});

router.post("/embassies", async (req, res): Promise<void> => {
  const parsed = CreateEmbassyBody.safeParse(req.body);
  if (!parsed.success) { res.status(400).json({ error: parsed.error.message }); return; }

  const [embassy] = await db.insert(embassiesTable).values(parsed.data).returning();
  res.status(201).json(GetEmbassyResponse.parse(serializeRow(embassy)));
});

router.get("/embassies/:id", async (req, res): Promise<void> => {
  const params = GetEmbassyParams.safeParse(req.params);
  if (!params.success) { res.status(400).json({ error: params.error.message }); return; }

  const [embassy] = await db.select().from(embassiesTable).where(eq(embassiesTable.id, params.data.id));
  if (!embassy) { res.status(404).json({ error: "Embassy not found" }); return; }

  res.json(GetEmbassyResponse.parse(serializeRow(embassy)));
});

router.patch("/embassies/:id", async (req, res): Promise<void> => {
  const params = UpdateEmbassyParams.safeParse(req.params);
  if (!params.success) { res.status(400).json({ error: params.error.message }); return; }

  const body = UpdateEmbassyBody.safeParse(req.body);
  if (!body.success) { res.status(400).json({ error: body.error.message }); return; }

  const [embassy] = await db.update(embassiesTable).set(body.data).where(eq(embassiesTable.id, params.data.id)).returning();
  if (!embassy) { res.status(404).json({ error: "Embassy not found" }); return; }

  res.json(UpdateEmbassyResponse.parse(serializeRow(embassy)));
});

router.delete("/embassies/:id", async (req, res): Promise<void> => {
  const params = DeleteEmbassyParams.safeParse(req.params);
  if (!params.success) { res.status(400).json({ error: params.error.message }); return; }

  await db.delete(embassiesTable).where(eq(embassiesTable.id, params.data.id));
  res.sendStatus(204);
});

export default router;
