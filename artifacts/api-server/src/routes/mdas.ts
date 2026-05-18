import { Router } from "express";
import { eq, asc } from "drizzle-orm";
import { db, mdasTable } from "@workspace/db";
import { serializeRow, serializeRows } from "../lib/serialize";
import {
  CreateMdaBody,
  GetMdaParams,
  GetMdaResponse,
  UpdateMdaParams,
  UpdateMdaBody,
  UpdateMdaResponse,
  DeleteMdaParams,
} from "@workspace/api-zod";

const router = Router();

router.get("/mdas", async (_req, res): Promise<void> => {
  const data = await db.select().from(mdasTable).orderBy(asc(mdasTable.name));
  res.json(serializeRows(data));
});

router.post("/mdas", async (req, res): Promise<void> => {
  const parsed = CreateMdaBody.safeParse(req.body);
  if (!parsed.success) { res.status(400).json({ error: parsed.error.message }); return; }

  const [mda] = await db.insert(mdasTable).values(parsed.data).returning();
  res.status(201).json(GetMdaResponse.parse(serializeRow(mda)));
});

router.get("/mdas/:id", async (req, res): Promise<void> => {
  const params = GetMdaParams.safeParse(req.params);
  if (!params.success) { res.status(400).json({ error: params.error.message }); return; }

  const [mda] = await db.select().from(mdasTable).where(eq(mdasTable.id, params.data.id));
  if (!mda) { res.status(404).json({ error: "MDA not found" }); return; }

  res.json(GetMdaResponse.parse(serializeRow(mda)));
});

router.patch("/mdas/:id", async (req, res): Promise<void> => {
  const params = UpdateMdaParams.safeParse(req.params);
  if (!params.success) { res.status(400).json({ error: params.error.message }); return; }

  const body = UpdateMdaBody.safeParse(req.body);
  if (!body.success) { res.status(400).json({ error: body.error.message }); return; }

  const [mda] = await db.update(mdasTable).set(body.data).where(eq(mdasTable.id, params.data.id)).returning();
  if (!mda) { res.status(404).json({ error: "MDA not found" }); return; }

  res.json(UpdateMdaResponse.parse(serializeRow(mda)));
});

router.delete("/mdas/:id", async (req, res): Promise<void> => {
  const params = DeleteMdaParams.safeParse(req.params);
  if (!params.success) { res.status(400).json({ error: params.error.message }); return; }

  await db.delete(mdasTable).where(eq(mdasTable.id, params.data.id));
  res.sendStatus(204);
});

export default router;
