import { Router, type Request } from "express";
import { eq, ilike, and, sql, desc } from "drizzle-orm";
import { db, postsTable, commentsTable, usersTable } from "@workspace/db";
import { serializeRow, serializeRows } from "../lib/serialize";
import {
  ListPostsQueryParams,
  CreatePostBody,
  GetPostParams,
  DeletePostParams,
  CreateCommentBody,
} from "@workspace/api-zod";
import { verifyToken } from "./auth";

const router = Router();

async function resolveAuthor(req: Request): Promise<{ authorName: string; authorAvatarUrl: string | null }> {
  const authHeader = req.headers.authorization;
  const token = authHeader?.startsWith("Bearer ") ? authHeader.slice(7) : null;
  if (!token) return { authorName: "Community Member", authorAvatarUrl: null };
  const payload = verifyToken(token);
  if (!payload) return { authorName: "Community Member", authorAvatarUrl: null };
  try {
    const [user] = await db.select().from(usersTable).where(eq(usersTable.id, payload.userId));
    if (!user) return { authorName: "Community Member", authorAvatarUrl: null };
    return { authorName: user.fullName, authorAvatarUrl: user.avatarUrl ?? null };
  } catch {
    return { authorName: "Community Member", authorAvatarUrl: null };
  }
}

router.get("/posts", async (req, res): Promise<void> => {
  const parsed = ListPostsQueryParams.safeParse(req.query);
  if (!parsed.success) { res.status(400).json({ error: parsed.error.message }); return; }

  const { page, limit, search } = parsed.data;
  const offset = ((page ?? 1) - 1) * (limit ?? 20);
  const conditions = [];
  if (search) conditions.push(ilike(postsTable.content, `%${search}%`));
  const whereClause = conditions.length > 0 ? and(...conditions) : undefined;

  const [{ count }] = await db.select({ count: sql<number>`count(*)::int` }).from(postsTable).where(whereClause);
  const data = await db.select().from(postsTable).where(whereClause)
    .limit(limit ?? 20).offset(offset).orderBy(desc(postsTable.createdAt));

  // Return raw so authorAvatarUrl is included (not stripped by Zod)
  res.json({ data: serializeRows(data), total: count, page: page ?? 1, limit: limit ?? 20 });
});

router.post("/posts", async (req, res): Promise<void> => {
  const parsed = CreatePostBody.safeParse(req.body);
  if (!parsed.success) { res.status(400).json({ error: parsed.error.message }); return; }

  const { authorName, authorAvatarUrl } = await resolveAuthor(req);
  const [post] = await db.insert(postsTable)
    .values({ ...parsed.data, authorName, authorAvatarUrl })
    .returning();
  res.status(201).json(serializeRow(post));
});

router.get("/posts/:id", async (req, res): Promise<void> => {
  const params = GetPostParams.safeParse(req.params);
  if (!params.success) { res.status(400).json({ error: params.error.message }); return; }

  const [post] = await db.select().from(postsTable).where(eq(postsTable.id, params.data.id));
  if (!post) { res.status(404).json({ error: "Post not found" }); return; }
  res.json(serializeRow(post));
});

router.delete("/posts/:id", async (req, res): Promise<void> => {
  const params = DeletePostParams.safeParse(req.params);
  if (!params.success) { res.status(400).json({ error: params.error.message }); return; }

  await db.delete(postsTable).where(eq(postsTable.id, params.data.id));
  res.sendStatus(204);
});

router.post("/posts/:id/like", async (req, res): Promise<void> => {
  const raw = Array.isArray(req.params.id) ? req.params.id[0] : req.params.id;
  const id = parseInt(raw, 10);

  const [post] = await db.update(postsTable)
    .set({ likeCount: sql`${postsTable.likeCount} + 1` })
    .where(eq(postsTable.id, id)).returning();
  if (!post) { res.status(404).json({ error: "Post not found" }); return; }
  res.json(serializeRow(post));
});

// ── Comments ──────────────────────────────────────────────────────────────

router.get("/posts/:postId/comments", async (req, res): Promise<void> => {
  const raw = Array.isArray(req.params.postId) ? req.params.postId[0] : req.params.postId;
  const postId = parseInt(raw, 10);
  const comments = await db.select().from(commentsTable)
    .where(eq(commentsTable.postId, postId)).orderBy(desc(commentsTable.createdAt));
  res.json(serializeRows(comments));
});

router.post("/posts/:postId/comments", async (req, res): Promise<void> => {
  const raw = Array.isArray(req.params.postId) ? req.params.postId[0] : req.params.postId;
  const postId = parseInt(raw, 10);

  const parsed = CreateCommentBody.safeParse(req.body);
  if (!parsed.success) { res.status(400).json({ error: parsed.error.message }); return; }

  const { authorName, authorAvatarUrl } = await resolveAuthor(req);
  const [comment] = await db.insert(commentsTable).values({
    postId,
    content: parsed.data.content,
    authorName,
    authorAvatarUrl,
  }).returning();

  await db.update(postsTable)
    .set({ commentCount: sql`${postsTable.commentCount} + 1` })
    .where(eq(postsTable.id, postId));

  res.status(201).json(serializeRow(comment));
});

router.delete("/posts/:postId/comments/:id", async (req, res): Promise<void> => {
  const rawId = Array.isArray(req.params.id) ? req.params.id[0] : req.params.id;
  const id = parseInt(rawId, 10);
  await db.delete(commentsTable).where(eq(commentsTable.id, id));
  res.sendStatus(204);
});

export default router;
