import { Link, useLocation } from "wouter";
import {
  LayoutDashboard, Newspaper, Users, Building2, MapPin,
  Video, CalendarDays, MessageSquare, Briefcase, Bell, Landmark, LogOut,
  ChevronRight, ClipboardList, Mail,
} from "lucide-react";
import { cn } from "@/lib/utils";
import { useAuth } from "@/hooks/useAuth";

const navGroups = [
  {
    label: "Overview",
    items: [
      { href: "/", label: "Dashboard", icon: LayoutDashboard },
    ],
  },
  {
    label: "Content",
    items: [
      { href: "/news",          label: "News",          icon: Newspaper   },
      { href: "/tourism",       label: "Tourism",       icon: MapPin      },
      { href: "/webinars",      label: "Webinars",      icon: Video       },
      { href: "/events",        label: "Events",        icon: CalendarDays},
      { href: "/opportunities", label: "Opportunities", icon: Briefcase   },
    ],
  },
  {
    label: "Network",
    items: [
      { href: "/embassies", label: "Embassies",   icon: Building2 },
      { href: "/mdas",      label: "Gov't MDAs",  icon: Landmark  },
    ],
  },
  {
    label: "People",
    items: [
      { href: "/users",         label: "Users",         icon: Users          },
      { href: "/registrations", label: "Registrations", icon: ClipboardList  },
      { href: "/community",     label: "Community",     icon: MessageSquare  },
      { href: "/notifications", label: "Notifications", icon: Bell           },
      { href: "/messages",      label: "Messages",      icon: Mail            },
    ],
  },
];

export function Sidebar() {
  const [location] = useLocation();
  const { user, logout } = useAuth();

  const isActive = (href: string) =>
    href === "/" ? location === "/" : location.startsWith(href);

  const initials = (user?.fullName ?? "Admin")
    .split(" ")
    .map((p: string) => p[0] ?? "")
    .slice(0, 2)
    .join("")
    .toUpperCase();

  return (
    <aside className="w-[210px] bg-[#0f0f0f] text-white flex flex-col h-screen sticky top-0 shrink-0 border-r border-white/5">
      {/* ── Brand ─────────────────────────────────────────────── */}
      <div className="px-4 pt-5 pb-3">
        <div className="flex items-center gap-3">
          <div className="w-9 h-9 rounded-xl bg-[#D97706] flex items-center justify-center shrink-0 shadow-lg shadow-orange-900/30">
            <span className="text-white font-black text-base leading-none tracking-tight">U</span>
          </div>
          <div className="min-w-0">
            <p className="text-[13px] font-black text-white tracking-tight leading-tight">
              Uganda Diaspora
            </p>
            <p className="text-[9.5px] text-white/35 tracking-widest uppercase mt-0.5">
              Admin Portal
            </p>
          </div>
        </div>

        {/* Uganda flag strip */}
        <div className="flex mt-3.5 rounded-full overflow-hidden h-[3px] gap-0.5">
          {["#1A1A1A","#FFCE00","#D90026","#1A1A1A","#FFCE00","#D90026"].map((c, i) => (
            <div key={i} className="flex-1" style={{ background: c }} />
          ))}
        </div>
      </div>

      {/* ── Nav ───────────────────────────────────────────────── */}
      <nav className="flex-1 overflow-y-auto px-2.5 py-2 space-y-4">
        {navGroups.map((group) => (
          <div key={group.label}>
            <p className="text-[9px] font-bold text-white/25 uppercase tracking-widest px-2 mb-1">
              {group.label}
            </p>
            <div className="space-y-0.5">
              {group.items.map(({ href, label, icon: Icon }) => {
                const active = isActive(href);
                return (
                  <Link
                    key={href}
                    href={href}
                    className={cn(
                      "flex items-center gap-2.5 px-3 py-[7px] rounded-lg text-[12.5px] font-medium transition-all duration-150 group cursor-pointer",
                      active
                        ? "bg-[#D97706]/15 text-[#D97706]"
                        : "text-white/45 hover:text-white hover:bg-white/5"
                    )}
                  >
                    <Icon
                      className={cn(
                        "w-3.5 h-3.5 shrink-0",
                        active ? "text-[#D97706]" : "text-white/35 group-hover:text-white/70"
                      )}
                    />
                    <span className="flex-1 truncate">{label}</span>
                    {active && <ChevronRight className="w-3 h-3 text-[#D97706] shrink-0" />}
                  </Link>
                );
              })}
            </div>
          </div>
        ))}
      </nav>

      {/* ── Orange accent line ─────────────────────────────────── */}
      <div className="h-px bg-gradient-to-r from-transparent via-[#D97706]/30 to-transparent mx-4 mb-0" />

      {/* ── User card ─────────────────────────────────────────── */}
      <div className="p-3">
        <div className="bg-white/[0.04] rounded-xl p-3 border border-white/5">
          <div className="flex items-center gap-2.5 mb-2.5">
            <div className="w-7 h-7 rounded-lg bg-gradient-to-br from-[#D97706] to-[#B45309] flex items-center justify-center shrink-0">
              <span className="text-white font-bold text-[10px]">{initials}</span>
            </div>
            <div className="flex-1 min-w-0">
              <p className="text-[11.5px] font-semibold text-white truncate">
                {user?.fullName ?? "Administrator"}
              </p>
              <p className="text-[9.5px] text-white/35 capitalize">{user?.role ?? "admin"}</p>
            </div>
          </div>
          <button
            onClick={logout}
            className="w-full flex items-center gap-2 px-2.5 py-1.5 rounded-lg text-[11px] font-medium text-white/35 hover:text-white hover:bg-white/5 transition-colors cursor-pointer"
          >
            <LogOut className="w-3 h-3" />
            Sign out
          </button>
        </div>
      </div>
    </aside>
  );
}
