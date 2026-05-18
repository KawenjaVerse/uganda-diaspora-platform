import { Router } from "express";
import { eq } from "drizzle-orm";
import { db, usersTable } from "@workspace/db";
import { LoginBody, RegisterBody, GetMeResponse } from "@workspace/api-zod";
import { createHash } from "crypto";
import { logger } from "../lib/logger";

const router = Router();

function hashPassword(password: string): string {
  return createHash("sha256").update(password + "diaspora_salt_2024").digest("hex");
}

function generateToken(userId: number, email: string): string {
  const payload = Buffer.from(JSON.stringify({ userId, email, exp: Date.now() + 7 * 24 * 60 * 60 * 1000 })).toString("base64");
  const secret = process.env.SESSION_SECRET ?? "secret";
  return `${payload}.${createHash("sha256").update(payload + secret).digest("hex").slice(0, 16)}`;
}

export function verifyToken(token: string): { userId: number; email: string } | null {
  try {
    const [payload] = token.split(".");
    const data = JSON.parse(Buffer.from(payload, "base64").toString());
    if (data.exp < Date.now()) return null;
    return data;
  } catch {
    return null;
  }
}

router.post("/auth/login", async (req, res): Promise<void> => {
  const parsed = LoginBody.safeParse(req.body);
  if (!parsed.success) {
    res.status(400).json({ error: parsed.error.message });
    return;
  }

  const [user] = await db.select().from(usersTable).where(eq(usersTable.email, parsed.data.email));
  if (!user || user.passwordHash !== hashPassword(parsed.data.password)) {
    res.status(401).json({ error: "Invalid email or password" });
    return;
  }

  if (!user.isActive) {
    res.status(401).json({ error: "Account is deactivated" });
    return;
  }

  const token = generateToken(user.id, user.email);
  res.json({
    token,
    user: GetMeResponse.parse(user),
  });
});

router.post("/auth/register", async (req, res): Promise<void> => {
  const parsed = RegisterBody.safeParse(req.body);
  if (!parsed.success) {
    res.status(400).json({ error: parsed.error.message });
    return;
  }

  const [existing] = await db.select({ id: usersTable.id }).from(usersTable).where(eq(usersTable.email, parsed.data.email));
  if (existing) {
    res.status(400).json({ error: "Email already registered" });
    return;
  }

  const [user] = await db.insert(usersTable).values({
    email: parsed.data.email,
    passwordHash: hashPassword(parsed.data.password),
    fullName: parsed.data.fullName,
    role: parsed.data.role ?? "member",
    country: parsed.data.country ?? null,
  }).returning();

  const token = generateToken(user.id, user.email);
  res.status(201).json({ token, user: GetMeResponse.parse(user) });
});

router.get("/auth/me", async (req, res): Promise<void> => {
  const authHeader = req.headers.authorization;
  if (!authHeader?.startsWith("Bearer ")) {
    res.status(401).json({ error: "Unauthorized" });
    return;
  }

  const token = authHeader.slice(7);
  const payload = verifyToken(token);
  if (!payload) {
    res.status(401).json({ error: "Invalid or expired token" });
    return;
  }

  const [user] = await db.select().from(usersTable).where(eq(usersTable.id, payload.userId));
  if (!user) {
    res.status(404).json({ error: "User not found" });
    return;
  }

  res.json(GetMeResponse.parse(user));
});

export default router;
