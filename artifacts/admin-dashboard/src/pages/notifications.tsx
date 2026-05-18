import { useState } from "react";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { api } from "@/lib/api";
import { AppLayout } from "@/components/layout/app-layout";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Badge } from "@/components/ui/badge";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter } from "@/components/ui/dialog";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Plus, Send } from "lucide-react";
import { useToast } from "@/hooks/use-toast";

interface Notification {
  id: number;
  title: string;
  body: string;
  type: string;
  audience: string;
  sentCount: number;
  createdAt: string;
}

interface ListResponse { data: Notification[]; total: number; }

const empty = () => ({ title: "", body: "", type: "general", audience: "all" });

export default function NotificationsPage() {
  const qc = useQueryClient();
  const { toast } = useToast();
  const [open, setOpen] = useState(false);
  const [form, setForm] = useState(empty());

  const { data } = useQuery<ListResponse>({
    queryKey: ["notifications"],
    queryFn: () => api.get("/notifications?limit=100"),
  });

  const send = useMutation({
    mutationFn: () => api.post("/notifications", form),
    onSuccess: () => { qc.invalidateQueries({ queryKey: ["notifications"] }); setOpen(false); setForm(empty()); toast({ title: "Notification sent" }); },
    onError: (e) => toast({ title: "Error", description: e.message, variant: "destructive" }),
  });

  const typeColors: Record<string, string> = {
    news: "bg-blue-100 text-blue-700",
    event: "bg-orange-100 text-orange-700",
    webinar: "bg-purple-100 text-purple-700",
    general: "bg-slate-100 text-slate-700",
  };

  return (
    <AppLayout>
      <div className="p-8">
        <div className="flex items-center justify-between mb-6">
          <div>
            <h1 className="text-2xl font-bold text-slate-900">Notifications</h1>
            <p className="text-slate-500 text-sm mt-1">{data?.total ?? 0} sent</p>
          </div>
          <Button onClick={() => { setForm(empty()); setOpen(true); }} className="bg-yellow-500 hover:bg-yellow-400 text-slate-900 font-semibold gap-2">
            <Plus className="w-4 h-4" /> Send Notification
          </Button>
        </div>

        <div className="bg-white rounded-xl border border-slate-100 overflow-hidden">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Title</TableHead>
                <TableHead>Body</TableHead>
                <TableHead>Type</TableHead>
                <TableHead>Audience</TableHead>
                <TableHead>Sent To</TableHead>
                <TableHead>Date</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {data?.data.map(item => (
                <TableRow key={item.id}>
                  <TableCell className="font-medium">{item.title}</TableCell>
                  <TableCell className="max-w-xs"><p className="text-sm text-slate-500 line-clamp-2">{item.body}</p></TableCell>
                  <TableCell><Badge className={`${typeColors[item.type] ?? "bg-gray-100 text-gray-700"} border-0 capitalize`}>{item.type}</Badge></TableCell>
                  <TableCell><Badge variant="secondary" className="capitalize">{item.audience}</Badge></TableCell>
                  <TableCell className="text-slate-500 text-sm">{item.sentCount?.toLocaleString() ?? 0}</TableCell>
                  <TableCell className="text-slate-500 text-sm whitespace-nowrap">{new Date(item.createdAt).toLocaleDateString()}</TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </div>

        <Dialog open={open} onOpenChange={setOpen}>
          <DialogContent className="max-w-lg">
            <DialogHeader><DialogTitle>Send Notification</DialogTitle></DialogHeader>
            <div className="space-y-4 py-2">
              <div className="space-y-1"><Label>Title</Label><Input value={form.title} onChange={e => setForm(p => ({ ...p, title: e.target.value }))} /></div>
              <div className="space-y-1"><Label>Message</Label><Textarea rows={4} value={form.body} onChange={e => setForm(p => ({ ...p, body: e.target.value }))} /></div>
              <div className="grid grid-cols-2 gap-4">
                <div className="space-y-1"><Label>Type</Label>
                  <select className="w-full border border-slate-200 rounded-md px-3 py-2 text-sm" value={form.type} onChange={e => setForm(p => ({ ...p, type: e.target.value }))}>
                    {["general", "news", "event", "webinar"].map(t => <option key={t} value={t} className="capitalize">{t}</option>)}
                  </select>
                </div>
                <div className="space-y-1"><Label>Audience</Label>
                  <select className="w-full border border-slate-200 rounded-md px-3 py-2 text-sm" value={form.audience} onChange={e => setForm(p => ({ ...p, audience: e.target.value }))}>
                    {["all", "uk", "us", "canada", "europe", "africa", "asia"].map(a => <option key={a} value={a} className="capitalize">{a === "all" ? "All members" : a.toUpperCase()}</option>)}
                  </select>
                </div>
              </div>
            </div>
            <DialogFooter>
              <Button variant="outline" onClick={() => setOpen(false)}>Cancel</Button>
              <Button onClick={() => send.mutate()} disabled={send.isPending} className="bg-yellow-500 hover:bg-yellow-400 text-slate-900 gap-2">
                <Send className="w-4 h-4" />
                {send.isPending ? "Sending…" : "Send"}
              </Button>
            </DialogFooter>
          </DialogContent>
        </Dialog>
      </div>
    </AppLayout>
  );
}
