import { useState } from "react";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { api } from "@/lib/api";
import { AppLayout } from "@/components/layout/app-layout";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Badge } from "@/components/ui/badge";
import { Switch } from "@/components/ui/switch";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter } from "@/components/ui/dialog";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Plus, Pencil, Trash2 } from "lucide-react";
import { useToast } from "@/hooks/use-toast";

interface Webinar {
  id: number;
  title: string;
  description: string;
  youtubeUrl: string;
  thumbnailUrl: string;
  category: string;
  speakerName: string;
  scheduledAt: string;
  isLive: boolean;
  isPublished: boolean;
  viewCount: number;
}

interface ListResponse { data: Webinar[]; total: number; }

const empty = (): Partial<Webinar> => ({ title: "", description: "", youtubeUrl: "", thumbnailUrl: "", category: "", speakerName: "", scheduledAt: "", isLive: false, isPublished: false });

export default function WebinarsPage() {
  const qc = useQueryClient();
  const { toast } = useToast();
  const [open, setOpen] = useState(false);
  const [editing, setEditing] = useState<Partial<Webinar>>(empty());
  const [editId, setEditId] = useState<number | null>(null);

  const { data } = useQuery<ListResponse>({
    queryKey: ["webinars"],
    queryFn: () => api.get("/webinars?limit=100"),
  });

  const save = useMutation({
    mutationFn: () => editId ? api.patch(`/webinars/${editId}`, editing) : api.post("/webinars", editing),
    onSuccess: () => { qc.invalidateQueries({ queryKey: ["webinars"] }); setOpen(false); toast({ title: "Saved" }); },
    onError: (e) => toast({ title: "Error", description: e.message, variant: "destructive" }),
  });

  const del = useMutation({
    mutationFn: (id: number) => api.delete(`/webinars/${id}`),
    onSuccess: () => { qc.invalidateQueries({ queryKey: ["webinars"] }); toast({ title: "Deleted" }); },
  });

  const openCreate = () => { setEditing(empty()); setEditId(null); setOpen(true); };
  const openEdit = (item: Webinar) => { setEditing(item); setEditId(item.id); setOpen(true); };

  return (
    <AppLayout>
      <div className="p-8">
        <div className="flex items-center justify-between mb-6">
          <div>
            <h1 className="text-2xl font-bold text-slate-900">Webinars</h1>
            <p className="text-slate-500 text-sm mt-1">{data?.total ?? 0} webinars</p>
          </div>
          <Button onClick={openCreate} className="bg-yellow-500 hover:bg-yellow-400 text-slate-900 font-semibold gap-2">
            <Plus className="w-4 h-4" /> Add Webinar
          </Button>
        </div>

        <div className="bg-white rounded-xl border border-slate-100 overflow-hidden">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Title</TableHead>
                <TableHead>Category</TableHead>
                <TableHead>Speaker</TableHead>
                <TableHead>Scheduled</TableHead>
                <TableHead>Views</TableHead>
                <TableHead>Status</TableHead>
                <TableHead className="w-24">Actions</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {data?.data.map(item => (
                <TableRow key={item.id}>
                  <TableCell className="font-medium max-w-xs truncate">{item.title}</TableCell>
                  <TableCell><Badge variant="secondary">{item.category}</Badge></TableCell>
                  <TableCell className="text-slate-500 text-sm">{item.speakerName}</TableCell>
                  <TableCell className="text-slate-500 text-sm">
                    {item.scheduledAt ? new Date(item.scheduledAt).toLocaleDateString() : "—"}
                  </TableCell>
                  <TableCell className="text-slate-500 text-sm">{item.viewCount ?? 0}</TableCell>
                  <TableCell>
                    {item.isLive
                      ? <Badge className="bg-red-100 text-red-700 border-0">Live</Badge>
                      : item.isPublished
                        ? <Badge className="bg-green-100 text-green-700 border-0">Published</Badge>
                        : <Badge variant="outline">Draft</Badge>}
                  </TableCell>
                  <TableCell>
                    <div className="flex gap-1">
                      <Button variant="ghost" size="sm" onClick={() => openEdit(item)}><Pencil className="w-4 h-4" /></Button>
                      <Button variant="ghost" size="sm" onClick={() => del.mutate(item.id)} className="text-red-500 hover:text-red-700"><Trash2 className="w-4 h-4" /></Button>
                    </div>
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </div>

        <Dialog open={open} onOpenChange={setOpen}>
          <DialogContent className="max-w-2xl max-h-[90vh] overflow-y-auto">
            <DialogHeader><DialogTitle>{editId ? "Edit Webinar" : "Add Webinar"}</DialogTitle></DialogHeader>
            <div className="space-y-4 py-2">
              <div className="space-y-1"><Label>Title</Label><Input value={editing.title ?? ""} onChange={e => setEditing(p => ({ ...p, title: e.target.value }))} /></div>
              <div className="grid grid-cols-2 gap-4">
                <div className="space-y-1"><Label>Category</Label><Input value={editing.category ?? ""} onChange={e => setEditing(p => ({ ...p, category: e.target.value }))} /></div>
                <div className="space-y-1"><Label>Speaker</Label><Input value={editing.speakerName ?? ""} onChange={e => setEditing(p => ({ ...p, speakerName: e.target.value }))} /></div>
              </div>
              <div className="space-y-1"><Label>Description</Label><Textarea rows={4} value={editing.description ?? ""} onChange={e => setEditing(p => ({ ...p, description: e.target.value }))} /></div>
              <div className="space-y-1"><Label>YouTube URL</Label><Input value={editing.youtubeUrl ?? ""} onChange={e => setEditing(p => ({ ...p, youtubeUrl: e.target.value }))} /></div>
              <div className="space-y-1"><Label>Thumbnail URL</Label><Input value={editing.thumbnailUrl ?? ""} onChange={e => setEditing(p => ({ ...p, thumbnailUrl: e.target.value }))} /></div>
              <div className="space-y-1"><Label>Scheduled Date/Time</Label><Input type="datetime-local" value={editing.scheduledAt ? editing.scheduledAt.slice(0, 16) : ""} onChange={e => setEditing(p => ({ ...p, scheduledAt: e.target.value }))} /></div>
              <div className="flex gap-6">
                <div className="flex items-center gap-2"><Switch checked={!!editing.isPublished} onCheckedChange={v => setEditing(p => ({ ...p, isPublished: v }))} /><Label>Published</Label></div>
                <div className="flex items-center gap-2"><Switch checked={!!editing.isLive} onCheckedChange={v => setEditing(p => ({ ...p, isLive: v }))} /><Label>Live Now</Label></div>
              </div>
            </div>
            <DialogFooter>
              <Button variant="outline" onClick={() => setOpen(false)}>Cancel</Button>
              <Button onClick={() => save.mutate()} disabled={save.isPending} className="bg-yellow-500 hover:bg-yellow-400 text-slate-900">
                {save.isPending ? "Saving…" : "Save"}
              </Button>
            </DialogFooter>
          </DialogContent>
        </Dialog>
      </div>
    </AppLayout>
  );
}
