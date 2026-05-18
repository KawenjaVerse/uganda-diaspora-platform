import { Router } from "express";
import { eq, ilike, and, sql, desc, gte } from "drizzle-orm";
import { db, eventsTable } from "@workspace/db";
import { serializeRow, serializeRows } from "../lib/serialize";
import {
  ListEventsQueryParams,
  ListEventsResponse,
  CreateEventBody,
  GetEventParams,
  GetEventResponse,
  UpdateEventParams,
  UpdateEventBody,
  UpdateEventResponse,
  DeleteEventParams,
} from "@workspace/api-zod";

const router = Router();

router.get("/events", async (req, res): Promise<void> => {
  const parsed = ListEventsQueryParams.safeParse(req.query);
  if (!parsed.success) { res.status(400).json({ error: parsed.error.message }); return; }

  const { page, limit, search, upcoming } = parsed.data;
  const offset = ((page ?? 1) - 1) * (limit ?? 20);
  const conditions = [];
  if (search) conditions.push(ilike(eventsTable.title, `%${search}%`));
  if (upcoming) conditions.push(gte(eventsTable.startDate, new Date()));

  const whereClause = conditions.length > 0 ? and(...conditions) : undefined;
  const [{ count }] = await db.select({ count: sql<number>`count(*)::int` }).from(eventsTable).where(whereClause);
  const data = await db.select().from(eventsTable).where(whereClause).limit(limit ?? 20).offset(offset).orderBy(desc(eventsTable.startDate));

  res.json(ListEventsResponse.parse({ data: serializeRows(data), total: count, page: page ?? 1, limit: limit ?? 20 }));
});

router.post("/events", async (req, res): Promise<void> => {
  const parsed = CreateEventBody.safeParse(req.body);
  if (!parsed.success) { res.status(400).json({ error: parsed.error.message }); return; }

  const [event] = await db.insert(eventsTable).values({
    ...parsed.data,
    startDate: new Date(parsed.data.startDate),
    endDate: parsed.data.endDate ? new Date(parsed.data.endDate) : null,
  }).returning();
  res.status(201).json(GetEventResponse.parse(serializeRow(event)));
});

router.get("/events/:id", async (req, res): Promise<void> => {
  const params = GetEventParams.safeParse(req.params);
  if (!params.success) { res.status(400).json({ error: params.error.message }); return; }

  const [event] = await db.select().from(eventsTable).where(eq(eventsTable.id, params.data.id));
  if (!event) { res.status(404).json({ error: "Event not found" }); return; }

  res.json(GetEventResponse.parse(serializeRow(event)));
});

router.patch("/events/:id", async (req, res): Promise<void> => {
  const params = UpdateEventParams.safeParse(req.params);
  if (!params.success) { res.status(400).json({ error: params.error.message }); return; }

  const body = UpdateEventBody.safeParse(req.body);
  if (!body.success) { res.status(400).json({ error: body.error.message }); return; }

  const updateData = {
    ...body.data,
    startDate: body.data.startDate ? new Date(body.data.startDate) : undefined,
    endDate: body.data.endDate ? new Date(body.data.endDate) : undefined,
  };
  const [event] = await db.update(eventsTable).set(updateData).where(eq(eventsTable.id, params.data.id)).returning();
  if (!event) { res.status(404).json({ error: "Event not found" }); return; }

  res.json(UpdateEventResponse.parse(serializeRow(event)));
});

router.delete("/events/:id", async (req, res): Promise<void> => {
  const params = DeleteEventParams.safeParse(req.params);
  if (!params.success) { res.status(400).json({ error: params.error.message }); return; }

  await db.delete(eventsTable).where(eq(eventsTable.id, params.data.id));
  res.sendStatus(204);
});

export default router;
