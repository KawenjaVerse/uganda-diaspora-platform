import { useQuery } from "@tanstack/react-query";
import { api } from "@/lib/api";
import {
  Users, Newspaper, Building2, CalendarDays, Video,
  MessageSquare, Briefcase, TrendingUp, ArrowUpRight,
  Globe, Bell, ClipboardList,
} from "lucide-react";
import { AppLayout } from "@/components/layout/app-layout";
import { useAuth } from "@/hooks/useAuth";

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

interface RegStats { total: number; }

const statCards = [
  { key: "totalUsers"          as keyof Stats, label: "Total Members",    icon: Users,         accent: "#2563EB", href: "/users"         },
  { key: "totalNews"           as keyof Stats, label: "News Articles",    icon: Newspaper,     accent: "#16A34A", href: "/news"          },
  { key: "totalEmbassies"      as keyof Stats, label: "Embassies",        icon: Building2,     accent: "#7C3AED", href: "/embassies"     },
  { key: "totalEvents"         as keyof Stats, label: "Events",           icon: CalendarDays,  accent: "#D97706", href: "/events"        },
  { key: "totalWebinars"       as keyof Stats, label: "Webinars",         icon: Video,         accent: "#B91C1C", href: "/webinars"      },
  { key: "totalPosts"          as keyof Stats, label: "Community Posts",  icon: MessageSquare, accent: "#0891B2", href: "/community"     },
  { key: "totalOpportunities"  as keyof Stats, label: "Opportunities",    icon: Briefcase,     accent: "#059669", href: "/opportunities" },
  { key: "upcomingEventsCount" as keyof Stats, label: "Upcoming Events",  icon: TrendingUp,    accent: "#D97706", href: "/events"        },
];

const activityColors: Record<string, string> = {
  news:         "#16A34A",
  event:        "#D97706",
  webinar:      "#7C3AED",
  user:         "#2563EB",
  post:         "#0891B2",
  opportunity:  "#059669",
  embassy:      "#B91C1C",
};

export default function Dashboard() {
  const { user } = useAuth();

  const { data: stats } = useQuery<Stats>({
    queryKey: ["dashboard-stats"],
    queryFn: () => api.get("/dashboard/stats"),
  });

  const { data: activity } = useQuery<ActivityItem[]>({
    queryKey: ["activity"],
    queryFn: () => api.get("/dashboard/activity"),
  });

  const { data: regStats } = useQuery<RegStats>({
    queryKey: ["registrations-stats"],
    queryFn: () => api.get("/registrations/stats"),
  });

  const firstName = user?.fullName?.split(" ")[0] ?? "Admin";

  return (
    <AppLayout>
      <div className="min-h-screen bg-[#F7F7F8]">
        {/* ── Hero banner ───────────────────────────────────── */}
        <div className="relative bg-[#121212] overflow-hidden">
          <div
            className="absolute inset-0 opacity-[0.03]"
            style={{
              backgroundImage: "radial-gradient(circle at 1px 1px, white 1px, transparent 0)",
              backgroundSize: "24px 24px",
            }}
          />
          <div className="absolute top-0 right-0 w-96 h-full bg-gradient-to-l from-[#D97706]/8 to-transparent pointer-events-none" />

          <div className="relative z-10 px-8 py-8">
            <div className="flex items-center justify-between">
              <div>
                <div className="flex items-center gap-2 mb-2">
                  <div className="w-1.5 h-1.5 rounded-full bg-[#D97706] animate-pulse" />
                  <span className="text-white/40 text-[11px] font-medium uppercase tracking-widest">
                    Live Dashboard
                  </span>
                </div>
                <h1 className="text-2xl font-black text-white tracking-tight mb-1">
                  Good {getTimeOfDay()}, {firstName} 👋
                </h1>
                <p className="text-white/40 text-sm">
                  {new Date().toLocaleDateString("en-GB", { weekday: "long", day: "numeric", month: "long", year: "numeric" })}
                </p>
              </div>

              <div className="flex items-center gap-3">
                <div className="bg-white/5 border border-white/8 rounded-xl px-4 py-3 text-center">
                  <p className="text-[#D97706] font-black text-xl leading-none">{stats?.recentUsersCount ?? "—"}</p>
                  <p className="text-white/35 text-[10px] mt-1 whitespace-nowrap">New this week</p>
                </div>
                <div className="bg-white/5 border border-white/8 rounded-xl px-4 py-3 text-center">
                  <p className="text-[#D97706] font-black text-xl leading-none">{stats?.publishedNewsCount ?? "—"}</p>
                  <p className="text-white/35 text-[10px] mt-1 whitespace-nowrap">Published</p>
                </div>
                <a href="/registrations" className="bg-[#D97706]/15 border border-[#D97706]/30 rounded-xl px-4 py-3 text-center hover:bg-[#D97706]/20 transition-colors cursor-pointer">
                  <p className="text-[#D97706] font-black text-xl leading-none">{regStats?.total ?? "—"}</p>
                  <p className="text-white/35 text-[10px] mt-1 whitespace-nowrap">Registrations</p>
                </a>
              </div>
            </div>
          </div>

          {/* Uganda flag strip */}
          <div className="flex h-[3px] gap-0">
            {["#1A1A1A","#FFCE00","#D90026","#1A1A1A","#FFCE00","#D90026"].map((c, i) => (
              <div key={i} className="flex-1" style={{ background: c }} />
            ))}
          </div>
        </div>

        <div className="px-8 py-8 space-y-8">
          {/* ── KPI Grid ──────────────────────────────────────── */}
          <div>
            <div className="flex items-center justify-between mb-4">
              <h2 className="text-[13px] font-bold text-slate-400 uppercase tracking-widest">Platform Overview</h2>
              <div className="flex items-center gap-1.5 text-[11px] text-slate-400">
                <Globe className="w-3 h-3" />
                All time
              </div>
            </div>

            <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
              {statCards.map(({ key, label, icon: Icon, accent, href }) => (
                <a
                  key={key}
                  href={href}
                  className="bg-white rounded-2xl p-5 border border-slate-100 hover:shadow-md transition-shadow group block"
                >
                  <div className="flex items-start justify-between mb-4">
                    <div
                      className="w-10 h-10 rounded-xl flex items-center justify-center"
                      style={{ background: `${accent}14` }}
                    >
                      <Icon className="w-5 h-5" style={{ color: accent }} />
                    </div>
                    <ArrowUpRight
                      className="w-4 h-4 text-slate-300 group-hover:text-slate-500 transition-colors"
                    />
                  </div>
                  <p className="text-[11px] font-semibold text-slate-400 uppercase tracking-widest mb-1">{label}</p>
                  <p
                    className="text-3xl font-black tracking-tight"
                    style={{ color: accent }}
                  >
                    {stats?.[key]?.toLocaleString() ?? "—"}
                  </p>
                  <div
                    className="mt-3 h-0.5 rounded-full"
                    style={{ background: `linear-gradient(to right, ${accent}, transparent)` }}
                  />
                </a>
              ))}

              {/* Registrations card */}
              <a
                href="/registrations"
                className="bg-white rounded-2xl p-5 border border-slate-100 hover:shadow-md transition-shadow group block"
              >
                <div className="flex items-start justify-between mb-4">
                  <div className="w-10 h-10 rounded-xl flex items-center justify-center" style={{ background: "#D97706" + "14" }}>
                    <ClipboardList className="w-5 h-5 text-[#D97706]" />
                  </div>
                  <ArrowUpRight className="w-4 h-4 text-slate-300 group-hover:text-slate-500 transition-colors" />
                </div>
                <p className="text-[11px] font-semibold text-slate-400 uppercase tracking-widest mb-1">Diaspora Registrations</p>
                <p className="text-3xl font-black tracking-tight text-[#D97706]">
                  {regStats?.total?.toLocaleString() ?? "—"}
                </p>
                <div className="mt-3 h-0.5 rounded-full" style={{ background: "linear-gradient(to right, #D97706, transparent)" }} />
              </a>
            </div>
          </div>

          {/* ── Activity + Quick links ─────────────────────────── */}
          <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
            {/* Recent Activity (2/3) */}
            <div className="lg:col-span-2 bg-white rounded-2xl border border-slate-100 overflow-hidden">
              <div className="px-6 py-4 border-b border-slate-50 flex items-center justify-between">
                <div className="flex items-center gap-2.5">
                  <div className="w-2 h-2 rounded-full bg-[#D97706] animate-pulse" />
                  <h3 className="text-[13px] font-bold text-slate-800">Recent Activity</h3>
                </div>
                <span className="text-[11px] text-slate-400">{activity?.length ?? 0} events</span>
              </div>
              <div className="divide-y divide-slate-50">
                {activity && activity.length > 0 ? (
                  activity.map((item) => {
                    const color = activityColors[item.type] ?? "#6B7280";
                    return (
                      <div key={item.id} className="px-6 py-3.5 flex items-start gap-4 hover:bg-slate-50/50 transition-colors">
                        <div
                          className="w-2 h-2 rounded-full mt-1.5 shrink-0"
                          style={{ background: color }}
                        />
                        <div className="flex-1 min-w-0">
                          <p className="text-[13px] text-slate-700 leading-relaxed">{item.description}</p>
                          <p className="text-[11px] text-slate-400 mt-0.5">
                            {new Date(item.createdAt).toLocaleString("en-GB", {
                              day: "numeric", month: "short", hour: "2-digit", minute: "2-digit"
                            })}
                          </p>
                        </div>
                        <span
                          className="text-[9.5px] font-bold uppercase tracking-widest px-2 py-0.5 rounded-full shrink-0"
                          style={{ background: `${color}14`, color }}
                        >
                          {item.type}
                        </span>
                      </div>
                    );
                  })
                ) : (
                  <div className="px-6 py-12 text-center">
                    <Bell className="w-8 h-8 text-slate-200 mx-auto mb-3" />
                    <p className="text-slate-400 text-sm">No recent activity</p>
                  </div>
                )}
              </div>
            </div>

            {/* Quick links (1/3) */}
            <div className="bg-white rounded-2xl border border-slate-100 overflow-hidden">
              <div className="px-5 py-4 border-b border-slate-50">
                <h3 className="text-[13px] font-bold text-slate-800">Quick Access</h3>
              </div>
              <div className="p-3 space-y-1">
                {[
                  { label: "Publish News",        href: "/news",          color: "#16A34A", icon: Newspaper     },
                  { label: "Manage Members",       href: "/users",         color: "#2563EB", icon: Users         },
                  { label: "Embassy Directory",    href: "/embassies",     color: "#7C3AED", icon: Building2     },
                  { label: "Schedule Webinar",     href: "/webinars",      color: "#B91C1C", icon: Video         },
                  { label: "Post Opportunity",     href: "/opportunities", color: "#059669", icon: Briefcase     },
                  { label: "Registrations",        href: "/registrations", color: "#D97706", icon: ClipboardList },
                  { label: "Send Notification",    href: "/notifications", color: "#0891B2", icon: Bell         },
                  { label: "Community Posts",      href: "/community",     color: "#6B7280", icon: MessageSquare },
                ].map(({ label, href, color, icon: Icon }) => (
                  <a
                    key={href}
                    href={href}
                    className="flex items-center gap-3 px-3 py-2.5 rounded-xl hover:bg-slate-50 transition-colors group"
                  >
                    <div
                      className="w-7 h-7 rounded-lg flex items-center justify-center shrink-0"
                      style={{ background: `${color}12` }}
                    >
                      <Icon className="w-3.5 h-3.5" style={{ color }} />
                    </div>
                    <span className="text-[13px] font-medium text-slate-600 group-hover:text-slate-900 transition-colors">
                      {label}
                    </span>
                    <ArrowUpRight className="w-3 h-3 text-slate-300 ml-auto group-hover:text-slate-500 transition-colors" />
                  </a>
                ))}
              </div>
            </div>
          </div>
        </div>
      </div>
    </AppLayout>
  );
}

function getTimeOfDay() {
  const h = new Date().getHours();
  if (h < 12) return "morning";
  if (h < 17) return "afternoon";
  return "evening";
}
