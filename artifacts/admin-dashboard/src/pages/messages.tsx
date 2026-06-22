import { useState } from "react";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { api } from "@/lib/api";
import { AppLayout } from "@/components/layout/app-layout";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Badge } from "@/components/ui/badge";
import { Search, Mail, MailOpen, Trash2, MessageCircle, Clock } from "lucide-react";
import { useToast } from "@/hooks/use-toast";

interface ContactMessage {
  id: number;
  name: string;
  email: string;
  subject: string | null;
  message: string;
  status: "unread" | "read";
  createdAt: string;
}

interface ListResponse { data: ContactMessage[]; total: number; }

export default function MessagesPage() {
  const { toast } = useToast();
  const qc = useQueryClient();
  const [search, setSearch] = useState("");
  const [expanded, setExpanded] = useState<number | null>(null);

  const { data, isLoading } = useQuery<ListResponse>({
    queryKey: ["contact-messages"],
    queryFn: () => api.get("/contact-messages?limit=200"),
  });

  const markRead = useMutation({
    mutationFn: ({ id, status }: { id: number; status: string }) =>
      api.patch(`/contact-messages/${id}`, { status }),
    onSuccess: () => qc.invalidateQueries({ queryKey: ["contact-messages"] }),
  });

  const deleteMsg = useMutation({
    mutationFn: (id: number) => api.delete(`/contact-messages/${id}`),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["contact-messages"] });
      toast({ title: "Message deleted", variant: "default" });
    },
  });

  const messages = (data?.data ?? []).filter(m =>
    !search ||
    m.name?.toLowerCase().includes(search.toLowerCase()) ||
    m.email?.toLowerCase().includes(search.toLowerCase()) ||
    m.subject?.toLowerCase().includes(search.toLowerCase()) ||
    m.message?.toLowerCase().includes(search.toLowerCase())
  );

  const unreadCount = (data?.data ?? []).filter(m => m.status === "unread").length;
  const total = data?.total ?? 0;

  const fmt = (iso: string) => {
    const d = new Date(iso);
    return d.toLocaleDateString("en-GB", { day: "numeric", month: "short", year: "numeric" }) +
      " · " + d.toLocaleTimeString("en-GB", { hour: "2-digit", minute: "2-digit" });
  };

  return (
    <AppLayout>
      <div className="p-8">
        {/* Header */}
        <div className="flex items-start justify-between mb-8">
          <div>
            <h1 className="text-2xl font-bold text-slate-900">Contact Messages</h1>
            <p className="text-slate-500 text-sm mt-1">Messages submitted via the mobile app contact form</p>
          </div>
          {unreadCount > 0 && (
            <Badge className="bg-yellow-500 text-white text-sm px-3 py-1">
              {unreadCount} unread
            </Badge>
          )}
        </div>

        {/* Stats */}
        <div className="grid grid-cols-3 gap-4 mb-8">
          {[
            { icon: MessageCircle, label: "Total Messages",  value: total,       color: "#D97706" },
            { icon: Mail,          label: "Unread",           value: unreadCount, color: "#DC2626" },
            { icon: MailOpen,      label: "Read",             value: total - unreadCount, color: "#16A34A" },
          ].map(({ icon: Icon, label, value, color }) => (
            <div key={label} className="bg-white rounded-xl border border-slate-100 p-5 flex items-center gap-4">
              <div className="w-11 h-11 rounded-xl flex items-center justify-center shrink-0" style={{ background: `${color}18` }}>
                <Icon className="w-5 h-5" style={{ color }} />
              </div>
              <div>
                <p className="text-2xl font-black text-slate-900">{value}</p>
                <p className="text-xs text-slate-400 font-medium mt-0.5">{label}</p>
              </div>
            </div>
          ))}
        </div>

        {/* Search */}
        <div className="relative mb-6 max-w-sm">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400" />
          <Input
            placeholder="Search messages…"
            className="pl-9 bg-white border-slate-200 text-sm"
            value={search}
            onChange={e => setSearch(e.target.value)}
          />
        </div>

        {/* Messages list */}
        {isLoading ? (
          <div className="bg-white rounded-xl border border-slate-100 p-12 text-center text-slate-400">Loading…</div>
        ) : messages.length === 0 ? (
          <div className="bg-white rounded-xl border border-slate-100 p-12 text-center">
            <MessageCircle className="w-10 h-10 text-slate-200 mx-auto mb-3" />
            <p className="text-slate-400 text-sm">{search ? "No messages match your search." : "No messages yet."}</p>
          </div>
        ) : (
          <div className="space-y-3">
            {messages.map(msg => (
              <div
                key={msg.id}
                className={`bg-white rounded-xl border transition-all ${msg.status === "unread" ? "border-yellow-200 shadow-sm shadow-yellow-50" : "border-slate-100"}`}
              >
                {/* Header row */}
                <div
                  className="flex items-start gap-4 p-5 cursor-pointer"
                  onClick={() => {
                    setExpanded(expanded === msg.id ? null : msg.id);
                    if (msg.status === "unread") markRead.mutate({ id: msg.id, status: "read" });
                  }}
                >
                  {/* Avatar */}
                  <div className="w-9 h-9 rounded-full bg-slate-100 flex items-center justify-center shrink-0 text-sm font-bold text-slate-500 uppercase">
                    {msg.name.trim().split(" ").map(p => p[0]).slice(0, 2).join("")}
                  </div>

                  <div className="flex-1 min-w-0">
                    <div className="flex items-center gap-2 flex-wrap">
                      <span className="font-semibold text-slate-900 text-sm">{msg.name}</span>
                      <span className="text-slate-400 text-xs">{msg.email}</span>
                      {msg.status === "unread" && (
                        <Badge className="bg-yellow-500 text-white text-[10px] px-1.5 py-0">New</Badge>
                      )}
                    </div>
                    {msg.subject && (
                      <p className="text-xs font-medium text-slate-600 mt-0.5">{msg.subject}</p>
                    )}
                    <p className={`text-sm mt-1 text-slate-500 ${expanded === msg.id ? "" : "line-clamp-2"}`}>
                      {msg.message}
                    </p>
                  </div>

                  <div className="flex flex-col items-end gap-2 shrink-0">
                    <span className="flex items-center gap-1 text-[11px] text-slate-400">
                      <Clock className="w-3 h-3" />
                      {fmt(msg.createdAt)}
                    </span>
                    <div className="flex items-center gap-1" onClick={e => e.stopPropagation()}>
                      <button
                        className="p-1.5 rounded-lg hover:bg-slate-50 text-slate-400 hover:text-slate-600 transition-colors"
                        title={msg.status === "read" ? "Mark as unread" : "Mark as read"}
                        onClick={() => markRead.mutate({ id: msg.id, status: msg.status === "read" ? "unread" : "read" })}
                      >
                        {msg.status === "read" ? <Mail className="w-3.5 h-3.5" /> : <MailOpen className="w-3.5 h-3.5" />}
                      </button>
                      <button
                        className="p-1.5 rounded-lg hover:bg-red-50 text-slate-400 hover:text-red-500 transition-colors"
                        title="Delete message"
                        onClick={() => deleteMsg.mutate(msg.id)}
                      >
                        <Trash2 className="w-3.5 h-3.5" />
                      </button>
                    </div>
                  </div>
                </div>

                {/* Expanded full message */}
                {expanded === msg.id && (
                  <div className="px-5 pb-5 pt-0 border-t border-slate-50">
                    <div className="bg-slate-50 rounded-lg p-4 mt-3">
                      <p className="text-sm text-slate-700 whitespace-pre-wrap leading-relaxed">{msg.message}</p>
                    </div>
                    <a
                      href={`mailto:${msg.email}?subject=Re: ${msg.subject ?? "Your message"}`}
                      className="inline-flex items-center gap-1.5 mt-3 text-xs font-semibold text-yellow-600 hover:text-yellow-700"
                    >
                      <Mail className="w-3.5 h-3.5" />
                      Reply via email
                    </a>
                  </div>
                )}
              </div>
            ))}
          </div>
        )}
        <div className="h-12" />
      </div>
    </AppLayout>
  );
}
