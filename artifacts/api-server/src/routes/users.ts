import { Router } from "express";
import { eq, ilike, and, sql } from "drizzle-orm";
import { db, usersTable } from "@workspace/db";
import { serializeRow, serializeRows } from "../lib/serialize";
import {
  ListUsersQueryParams,
  GetUserParams,
  GetUserResponse,
  UpdateUserParams,
  UpdateUserBody,
  DeleteUserParams,
  ListUsersResponse,
} from "@workspace/api-zod";

const router = Router();

router.get("/users", async (req, res): Promise<void> => {
  const parsed = ListUsersQueryParams.safeParse(req.query);
  if (!parsed.success) {
    res.status(400).json({ error: parsed.error.message });
    return;
  }
  const { page, limit, search, role } = parsed.data;
  const offset = ((page ?? 1) - 1) * (limit ?? 20);

  const conditions = [];
  if (search) conditions.push(ilike(usersTable.fullName, `%${search}%`));
  if (role) conditions.push(eq(usersTable.role, role));

  const whereClause = conditions.length > 0 ? and(...conditions) : undefined;

  const [{ count }] = await db.select({ count: sql<number>`count(*)::int` }).from(usersTable).where(whereClause);
  const data = await db.select().from(usersTable).where(whereClause).limit(limit ?? 20).offset(offset).orderBy(usersTable.createdAt);

  res.json(ListUsersResponse.parse({ data: serializeRows(data.map(u => ({ ...u, passwordHash: undefined }))), total: count, page: page ?? 1, limit: limit ?? 20 }));
});

router.get("/users/:id", async (req, res): Promise<void> => {
  const params = GetUserParams.safeParse(req.params);
  if (!params.success) { res.status(400).json({ error: params.error.message }); return; }

  const [user] = await db.select().from(usersTable).where(eq(usersTable.id, params.data.id));
  if (!user) { res.status(404).json({ error: "User not found" }); return; }

  res.json(GetUserResponse.parse(serializeRow(user)));
});

router.patch("/users/:id", async (req, res): Promise<void> => {
  const params = UpdateUserParams.safeParse(req.params);
  if (!params.success) { res.status(400).json({ error: params.error.message }); return; }

  const body = UpdateUserBody.safeParse(req.body);
  if (!body.success) { res.status(400).json({ error: body.error.message }); return; }

  const [user] = await db.update(usersTable).set({ ...body.data, updatedAt: new Date() }).where(eq(usersTable.id, params.data.id)).returning();
  if (!user) { res.status(404).json({ error: "User not found" }); return; }

  res.json(GetUserResponse.parse(serializeRow(user)));
});

router.delete("/users/:id", async (req, res): Promise<void> => {
  const params = DeleteUserParams.safeParse(req.params);
  if (!params.success) { res.status(400).json({ error: params.error.message }); return; }

  await db.delete(usersTable).where(eq(usersTable.id, params.data.id));
  res.sendStatus(204);
});

export default router;
