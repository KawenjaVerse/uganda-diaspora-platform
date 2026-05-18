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
import { Plus, Pencil, Trash2, Search } from "lucide-react";
import { useToast } from "@/hooks/use-toast";

interface Opportunity {
  id: number;
  title: string;
  description: string;
  type: string;
  organization: string;
  location: string;
  deadline: string;
  applicationUrl: string;
  isActive: boolean;
}

interface ListResponse { data: Opportunity[]; total: number; }

const empty = (): Partial<Opportunity> => ({ title: "", description: "", type: "job", organization: "", location: "", deadline: "", applicationUrl: "", isActive: true });

const typeColors: Record<string, string> = {
  job: "bg-blue-100 text-blue-700",
  scholarship: "bg-purple-100 text-purple-700",
  business: "bg-orange-100 text-orange-700",
  volunteer: "bg-green-100 text-green-700",
  training: "bg-teal-100 text-teal-700",
};

export default function OpportunitiesPage() {
  const qc = useQueryClient();
  const { toast } = useToast();
  const [search, setSearch] = useState("");
  const [open, setOpen] = useState(false);
  const [editing, setEditing] = useState<Partial<Opportunity>>(empty());
  const [editId, setEditId] = useState<number | null>(null);

  const { data } = useQuery<ListResponse>({
    queryKey: ["opportunities", search],
    queryFn: () => api.get(`/opportunities?limit=100${search ? `&search=${encodeURIComponent(search)}` : ""}`),
  });

  const save = useMutation({
    mutationFn: () => editId ? api.patch(`/opportunities/${editId}`, editing) : api.post("/opportunities", editing),
    onSuccess: () => { qc.invalidateQueries({ queryKey: ["opportunities"] }); setOpen(false); toast({ title: "Saved" }); },
    onError: (e) => toast({ title: "Error", description: e.message, variant: "destructive" }),
  });

  const del = useMutation({
    mutationFn: (id: number) => api.delete(`/opportunities/${id}`),
    onSuccess: () => { qc.invalidateQueries({ queryKey: ["opportunities"] }); toast({ title: "Deleted" }); },
  });

  const openCreate = () => { setEditing(empty()); setEditId(null); setOpen(true); };
  const openEdit = (item: Opportunity) => { setEditing(item); setEditId(item.id); setOpen(true); };

  return (
    <AppLayout>
      <div className="p-8">
        <div className="flex items-center justify-between mb-6">
          <div>
            <h1 className="text-2xl font-bold text-slate-900">Opportunities</h1>
            <p className="text-slate-500 text-sm mt-1">{data?.total ?? 0} opportunities</p>
          </div>
          <Button onClick={openCreate} className="bg-yellow-500 hover:bg-yellow-400 text-slate-900 font-semibold gap-2">
            <Plus className="w-4 h-4" /> Add Opportunity
          </Button>
        </div>

        <div className="relative mb-4">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400" />
          <Input placeholder="Search opportunities…" value={search} onChange={e => setSearch(e.target.value)} className="pl-9" />
        </div>

        <div className="bg-white rounded-xl border border-slate-100 overflow-hidden">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Title</TableHead>
                <TableHead>Type</TableHead>
                <TableHead>Organization</TableHead>
                <TableHead>Location</TableHead>
                <TableHead>Deadline</TableHead>
                <TableHead>Status</TableHead>
                <TableHead className="w-24">Actions</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {data?.data.map(item => (
                <TableRow key={item.id}>
                  <TableCell className="font-medium max-w-xs truncate">{item.title}</TableCell>
                  <TableCell>
                    <Badge className={`${typeColors[item.type] ?? "bg-gray-100 text-gray-700"} border-0 capitalize`}>{item.type}</Badge>
                  </TableCell>
                  <TableCell className="text-slate-500 text-sm">{item.organization}</TableCell>
                  <TableCell className="text-slate-500 text-sm">{item.location}</TableCell>
                  <TableCell className="text-slate-500 text-sm">{item.deadline ? new Date(item.deadline).toLocaleDateString() : "—"}</TableCell>
                  <TableCell>
                    {item.isActive
                      ? <Badge className="bg-green-100 text-green-700 border-0">Active</Badge>
                      : <Badge variant="outline">Closed</Badge>}
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
            <DialogHeader><DialogTitle>{editId ? "Edit Opportunity" : "Add Opportunity"}</DialogTitle></DialogHeader>
            <div className="space-y-4 py-2">
              <div className="space-y-1"><Label>Title</Label><Input value={editing.title ?? ""} onChange={e => setEditing(p => ({ ...p, title: e.target.value }))} /></div>
              <div className="grid grid-cols-2 gap-4">
                <div className="space-y-1"><Label>Type</Label>
                  <select className="w-full border border-slate-200 rounded-md px-3 py-2 text-sm" value={editing.type ?? "job"} onChange={e => setEditing(p => ({ ...p, type: e.target.value }))}>
                    {["job", "scholarship", "business", "volunteer", "training"].map(t => <option key={t} value={t} className="capitalize">{t}</option>)}
                  </select>
                </div>
                <div className="space-y-1"><Label>Organization</Label><Input value={editing.organization ?? ""} onChange={e => setEditing(p => ({ ...p, organization: e.target.value }))} /></div>
              </div>
              <div className="space-y-1"><Label>Description</Label><Textarea rows={4} value={editing.description ?? ""} onChange={e => setEditing(p => ({ ...p, description: e.target.value }))} /></div>
              <div className="grid grid-cols-2 gap-4">
                <div className="space-y-1"><Label>Location</Label><Input value={editing.location ?? ""} onChange={e => setEditing(p => ({ ...p, location: e.target.value }))} /></div>
                <div className="space-y-1"><Label>Deadline</Label><Input type="date" value={editing.deadline ?? ""} onChange={e => setEditing(p => ({ ...p, deadline: e.target.value }))} /></div>
              </div>
              <div className="space-y-1"><Label>Application URL</Label><Input value={editing.applicationUrl ?? ""} onChange={e => setEditing(p => ({ ...p, applicationUrl: e.target.value }))} /></div>
              <div className="flex items-center gap-2"><Switch checked={!!editing.isActive} onCheckedChange={v => setEditing(p => ({ ...p, isActive: v }))} /><Label>Active</Label></div>
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
