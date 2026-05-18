import { Link, useLocation } from "wouter";
import {
  LayoutDashboard, Newspaper, Users, Building2, MapPin,
  Video, CalendarDays, MessageSquare, Briefcase, Bell, Landmark, LogOut
} from "lucide-react";
import { cn } from "@/lib/utils";
import { useAuth } from "@/hooks/useAuth";
import { Button } from "@/components/ui/button";

const links = [
  { href: "/", label: "Dashboard", icon: LayoutDashboard },
  { href: "/news", label: "News", icon: Newspaper },
  { href: "/users", label: "Users", icon: Users },
  { href: "/embassies", label: "Embassies", icon: Building2 },
  { href: "/tourism", label: "Tourism", icon: MapPin },
  { href: "/webinars", label: "Webinars", icon: Video },
  { href: "/events", label: "Events", icon: CalendarDays },
  { href: "/community", label: "Community", icon: MessageSquare },
  { href: "/opportunities", label: "Opportunities", icon: Briefcase },
  { href: "/notifications", label: "Notifications", icon: Bell },
  { href: "/mdas", label: "MDAs", icon: Landmark },
];

export function Sidebar() {
  const [location] = useLocation();
  const { user, logout } = useAuth();

  return (
    <aside className="w-64 bg-slate-900 text-white flex flex-col h-screen sticky top-0">
      <div className="p-5 border-b border-slate-700">
        <div className="flex items-center gap-3">
          <div className="w-8 h-8 bg-yellow-400 rounded-full flex items-center justify-center">
            <span className="text-slate-900 font-bold text-sm">U</span>
          </div>
          <div>
            <p className="text-sm font-semibold leading-tight">Uganda Diaspora</p>
            <p className="text-xs text-slate-400">Admin Portal</p>
          </div>
        </div>
      </div>

      <nav className="flex-1 overflow-y-auto py-4">
        {links.map(({ href, label, icon: Icon }) => {
          const active = href === "/" ? location === "/" : location.startsWith(href);
          return (
            <Link key={href} href={href}>
              <a className={cn(
                "flex items-center gap-3 px-5 py-2.5 text-sm transition-colors",
                active
                  ? "bg-yellow-500/20 text-yellow-400 border-r-2 border-yellow-400"
                  : "text-slate-300 hover:bg-slate-800 hover:text-white"
              )}>
                <Icon className="w-4 h-4 shrink-0" />
                {label}
              </a>
            </Link>
          );
        })}
      </nav>

      <div className="p-4 border-t border-slate-700">
        <div className="flex items-center gap-3 mb-3">
          <div className="w-8 h-8 bg-slate-600 rounded-full flex items-center justify-center">
            <span className="text-xs font-medium">{user?.fullName?.[0] ?? "A"}</span>
          </div>
          <div className="flex-1 min-w-0">
            <p className="text-sm font-medium truncate">{user?.fullName}</p>
            <p className="text-xs text-slate-400 capitalize">{user?.role}</p>
          </div>
        </div>
        <Button
          variant="ghost"
          size="sm"
          className="w-full justify-start text-slate-400 hover:text-white hover:bg-slate-800 gap-2"
          onClick={logout}
        >
          <LogOut className="w-4 h-4" />
          Sign out
        </Button>
      </div>
    </aside>
  );
}
