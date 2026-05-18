import { Router } from "express";
import { eq, ilike, and, sql, desc } from "drizzle-orm";
import { db, opportunitiesTable } from "@workspace/db";
import { serializeRow, serializeRows } from "../lib/serialize";
import {
  ListOpportunitiesQueryParams,
  ListOpportunitiesResponse,
  CreateOpportunityBody,
  GetOpportunityParams,
  GetOpportunityResponse,
  UpdateOpportunityParams,
  UpdateOpportunityBody,
  UpdateOpportunityResponse,
  DeleteOpportunityParams,
} from "@workspace/api-zod";

const router = Router();

router.get("/opportunities", async (req, res): Promise<void> => {
  const parsed = ListOpportunitiesQueryParams.safeParse(req.query);
  if (!parsed.success) { res.status(400).json({ error: parsed.error.message }); return; }

  const { page, limit, search, type } = parsed.data;
  const offset = ((page ?? 1) - 1) * (limit ?? 20);
  const conditions = [];
  if (search) conditions.push(ilike(opportunitiesTable.title, `%${search}%`));
  if (type) conditions.push(eq(opportunitiesTable.type, type));

  const whereClause = conditions.length > 0 ? and(...conditions) : undefined;
  const [{ count }] = await db.select({ count: sql<number>`count(*)::int` }).from(opportunitiesTable).where(whereClause);
  const data = await db.select().from(opportunitiesTable).where(whereClause).limit(limit ?? 20).offset(offset).orderBy(desc(opportunitiesTable.createdAt));

  res.json(ListOpportunitiesResponse.parse({ data: serializeRows(data), total: count, page: page ?? 1, limit: limit ?? 20 }));
});

router.post("/opportunities", async (req, res): Promise<void> => {
  const parsed = CreateOpportunityBody.safeParse(req.body);
  if (!parsed.success) { res.status(400).json({ error: parsed.error.message }); return; }

  const [opp] = await db.insert(opportunitiesTable).values(parsed.data).returning();
  res.status(201).json(GetOpportunityResponse.parse(serializeRow(opp)));
});

router.get("/opportunities/:id", async (req, res): Promise<void> => {
  const params = GetOpportunityParams.safeParse(req.params);
  if (!params.success) { res.status(400).json({ error: params.error.message }); return; }

  const [opp] = await db.select().from(opportunitiesTable).where(eq(opportunitiesTable.id, params.data.id));
  if (!opp) { res.status(404).json({ error: "Opportunity not found" }); return; }

  res.json(GetOpportunityResponse.parse(serializeRow(opp)));
});

router.patch("/opportunities/:id", async (req, res): Promise<void> => {
  const params = UpdateOpportunityParams.safeParse(req.params);
  if (!params.success) { res.status(400).json({ error: params.error.message }); return; }

  const body = UpdateOpportunityBody.safeParse(req.body);
  if (!body.success) { res.status(400).json({ error: body.error.message }); return; }

  const [opp] = await db.update(opportunitiesTable).set(body.data).where(eq(opportunitiesTable.id, params.data.id)).returning();
  if (!opp) { res.status(404).json({ error: "Opportunity not found" }); return; }

  res.json(UpdateOpportunityResponse.parse(serializeRow(opp)));
});

router.delete("/opportunities/:id", async (req, res): Promise<void> => {
  const params = DeleteOpportunityParams.safeParse(req.params);
  if (!params.success) { res.status(400).json({ error: params.error.message }); return; }

  await db.delete(opportunitiesTable).where(eq(opportunitiesTable.id, params.data.id));
  res.sendStatus(204);
});

export default router;
