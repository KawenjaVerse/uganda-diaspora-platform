import { Router } from "express";
import { desc, sql } from "drizzle-orm";
import { db, diasporaRegistrationsTable, insertDiasporaRegistrationSchema } from "@workspace/db";
import { serializeRows, serializeRow } from "../lib/serialize";

const router = Router();

router.post("/registrations", async (req, res): Promise<void> => {
  const parsed = insertDiasporaRegistrationSchema.safeParse(req.body);
  if (!parsed.success) {
    res.status(400).json({ error: parsed.error.message });
    return;
  }
  const [row] = await db
    .insert(diasporaRegistrationsTable)
    .values(parsed.data)
    .returning();
  res.status(201).json(serializeRow(row));
});

router.get("/registrations/stats", async (_req, res): Promise<void> => {
  const [{ total }] = await db
    .select({ total: sql<number>`count(*)::int` })
    .from(diasporaRegistrationsTable);
  res.json({ total });
});

router.get("/registrations", async (req, res): Promise<void> => {
  const page = Math.max(1, parseInt((req.query["page"] as string) ?? "1"));
  const limit = Math.min(200, Math.max(1, parseInt((req.query["limit"] as string) ?? "100")));
  const offset = (page - 1) * limit;

  const [{ total }] = await db
    .select({ total: sql<number>`count(*)::int` })
    .from(diasporaRegistrationsTable);

  const data = await db
    .select()
    .from(diasporaRegistrationsTable)
    .orderBy(desc(diasporaRegistrationsTable.createdAt))
    .limit(limit)
    .offset(offset);

  res.json({ data: serializeRows(data), total, page, limit });
});

export default router;
