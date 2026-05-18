import { Router } from "express";
import { sql, gte, desc } from "drizzle-orm";
import { db, usersTable, newsTable, embassiesTable, eventsTable, webinarsTable, postsTable, opportunitiesTable, activityTable } from "@workspace/db";
import { GetDashboardStatsResponse, GetRecentActivityResponse } from "@workspace/api-zod";

const router = Router();

router.get("/dashboard/stats", async (_req, res): Promise<void> => {
  const thirtyDaysAgo = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);
  const now = new Date();

  const [[{ total: totalUsers }], [{ total: totalNews }], [{ total: totalEmbassies }],
    [{ total: totalEvents }], [{ total: totalWebinars }], [{ total: totalPosts }],
    [{ total: totalOpportunities }], [{ total: recentUsersCount }], [{ total: publishedNewsCount }],
    [{ total: upcomingEventsCount }]] = await Promise.all([
    db.select({ total: sql<number>`count(*)::int` }).from(usersTable),
    db.select({ total: sql<number>`count(*)::int` }).from(newsTable),
    db.select({ total: sql<number>`count(*)::int` }).from(embassiesTable),
    db.select({ total: sql<number>`count(*)::int` }).from(eventsTable),
    db.select({ total: sql<number>`count(*)::int` }).from(webinarsTable),
    db.select({ total: sql<number>`count(*)::int` }).from(postsTable),
    db.select({ total: sql<number>`count(*)::int` }).from(opportunitiesTable),
    db.select({ total: sql<number>`count(*)::int` }).from(usersTable).where(gte(usersTable.createdAt, thirtyDaysAgo)),
    db.select({ total: sql<number>`count(*)::int` }).from(newsTable).where(sql`${newsTable.isPublished} = true`),
    db.select({ total: sql<number>`count(*)::int` }).from(eventsTable).where(gte(eventsTable.startDate, now)),
  ]);

  res.json(GetDashboardStatsResponse.parse({
    totalUsers,
    totalNews,
    totalEmbassies,
    totalEvents,
    totalWebinars,
    totalPosts,
    totalOpportunities,
    recentUsersCount,
    publishedNewsCount,
    upcomingEventsCount,
  }));
});

router.get("/dashboard/recent-activity", async (_req, res): Promise<void> => {
  const activity = await db.select().from(activityTable).orderBy(desc(activityTable.createdAt)).limit(20);
  res.json(GetRecentActivityResponse.parse(activity));
});

export default router;
