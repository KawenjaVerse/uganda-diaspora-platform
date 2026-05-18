import { useQuery } from "@tanstack/react-query";
import { api } from "@/lib/api";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Users, Newspaper, Building2, CalendarDays, Video, MessageSquare, Briefcase, Activity } from "lucide-react";
import { AppLayout } from "@/components/layout/app-layout";

interface Stats {
  totalUsers: number;
  totalNews: number;
  totalEmbassies: number;
  totalEvents: number;
  totalWebinars: number;
  totalPosts: number;
  totalOpportunities: number;
  recentUsersCount: number;
  publishedNewsCount: number;
  upcomingEventsCount: number;
}

interface ActivityItem {
  id: number;
  type: string;
  description: string;
  createdAt: string;
}

const statCards = [
  { key: "totalUsers" as keyof Stats, label: "Total Users", icon: Users, color: "text-blue-600", bg: "bg-blue-50" },
  { key: "totalNews" as keyof Stats, label: "News Articles", icon: Newspaper, color: "text-green-600", bg: "bg-green-50" },
  { key: "totalEmbassies" as keyof Stats, label: "Embassies", icon: Building2, color: "text-purple-600", bg: "bg-purple-50" },
  { key: "totalEvents" as keyof Stats, label: "Events", icon: CalendarDays, color: "text-orange-600", bg: "bg-orange-50" },
  { key: "totalWebinars" as keyof Stats, label: "Webinars", icon: Video, color: "text-red-600", bg: "bg-red-50" },
  { key: "totalPosts" as keyof Stats, label: "Community Posts", icon: MessageSquare, color: "text-teal-600", bg: "bg-teal-50" },
  { key: "totalOpportunities" as keyof Stats, label: "Opportunities", icon: Briefcase, color: "text-indigo-600", bg: "bg-indigo-50" },
  { key: "upcomingEventsCount" as keyof Stats, label: "Upcoming Events", icon: Activity, color: "text-yellow-600", bg: "bg-yellow-50" },
];

export default function Dashboard() {
  const { data: stats } = useQuery<Stats>({
    queryKey: ["dashboard-stats"],
    queryFn: () => api.get("/dashboard/stats"),
  });

  const { data: activity } = useQuery<ActivityItem[]>({
    queryKey: ["activity"],
    queryFn: () => api.get("/dashboard/activity"),
  });

  return (
    <AppLayout>
      <div className="p-8">
        <div className="mb-8">
          <h1 className="text-2xl font-bold text-slate-900">Dashboard</h1>
          <p className="text-slate-500 mt-1">Welcome to the Uganda Diaspora Admin Portal</p>
        </div>

        <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
          {statCards.map(({ key, label, icon: Icon, color, bg }) => (
            <Card key={key} className="border border-slate-100">
              <CardContent className="p-5">
                <div className="flex items-center justify-between">
                  <div>
                    <p className="text-sm text-slate-500 mb-1">{label}</p>
                    <p className="text-3xl font-bold text-slate-900">{stats?.[key] ?? "—"}</p>
                  </div>
                  <div className={`${bg} p-3 rounded-xl`}>
                    <Icon className={`w-6 h-6 ${color}`} />
                  </div>
                </div>
              </CardContent>
            </Card>
          ))}
        </div>

        <Card>
          <CardHeader>
            <CardTitle className="text-base">Recent Activity</CardTitle>
          </CardHeader>
          <CardContent>
            {activity && activity.length > 0 ? (
              <ul className="space-y-3">
                {activity.map((item) => (
                  <li key={item.id} className="flex items-start gap-3 text-sm">
                    <span className="w-2 h-2 rounded-full bg-yellow-400 mt-1.5 shrink-0" />
                    <div>
                      <p className="text-slate-700">{item.description}</p>
                      <p className="text-xs text-slate-400 mt-0.5">{new Date(item.createdAt).toLocaleString()}</p>
                    </div>
                  </li>
                ))}
              </ul>
            ) : (
              <p className="text-slate-400 text-sm">No recent activity</p>
            )}
          </CardContent>
        </Card>
      </div>
    </AppLayout>
  );
}
