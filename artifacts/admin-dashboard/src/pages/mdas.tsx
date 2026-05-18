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

interface Mda {
  id: number;
  name: string;
  description: string;
  website: string;
  category: string;
  isActive: boolean;
}

const empty = (): Partial<Mda> => ({ name: "", description: "", website: "", category: "Ministry", isActive: true });

export default function MdasPage() {
  const qc = useQueryClient();
  const { toast } = useToast();
  const [search, setSearch] = useState("");
  const [open, setOpen] = useState(false);
  const [editing, setEditing] = useState<Partial<Mda>>(empty());
  const [editId, setEditId] = useState<number | null>(null);

  const { data } = useQuery<Mda[]>({
    queryKey: ["mdas"],
    queryFn: () => api.get("/mdas"),
  });

  const filtered = data?.filter(m =>
    !search || m.name.toLowerCase().includes(search.toLowerCase())
  ) ?? [];

  const save = useMutation({
    mutationFn: () => editId ? api.patch(`/mdas/${editId}`, editing) : api.post("/mdas", editing),
    onSuccess: () => { qc.invalidateQueries({ queryKey: ["mdas"] }); setOpen(false); toast({ title: "Saved" }); },
    onError: (e) => toast({ title: "Error", description: e.message, variant: "destructive" }),
  });

  const del = useMutation({
    mutationFn: (id: number) => api.delete(`/mdas/${id}`),
    onSuccess: () => { qc.invalidateQueries({ queryKey: ["mdas"] }); toast({ title: "Deleted" }); },
  });

  const openCreate = () => { setEditing(empty()); setEditId(null); setOpen(true); };
  const openEdit = (item: Mda) => { setEditing(item); setEditId(item.id); setOpen(true); };

  return (
    <AppLayout>
      <div className="p-8">
        <div className="flex items-center justify-between mb-6">
          <div>
            <h1 className="text-2xl font-bold text-slate-900">MDAs</h1>
            <p className="text-slate-500 text-sm mt-1">Ministries, Departments & Agencies — {filtered.length} total</p>
          </div>
          <Button onClick={openCreate} className="bg-yellow-500 hover:bg-yellow-400 text-slate-900 font-semibold gap-2">
            <Plus className="w-4 h-4" /> Add MDA
          </Button>
        </div>

        <div className="relative mb-4">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400" />
          <Input placeholder="Search MDAs…" value={search} onChange={e => setSearch(e.target.value)} className="pl-9" />
        </div>

        <div className="bg-white rounded-xl border border-slate-100 overflow-hidden">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Name</TableHead>
                <TableHead>Category</TableHead>
                <TableHead>Website</TableHead>
                <TableHead>Status</TableHead>
                <TableHead className="w-24">Actions</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {filtered.map(item => (
                <TableRow key={item.id}>
                  <TableCell className="font-medium">{item.name}</TableCell>
                  <TableCell><Badge variant="secondary">{item.category}</Badge></TableCell>
                  <TableCell>
                    {item.website
                      ? <a href={item.website} target="_blank" rel="noopener noreferrer" className="text-blue-600 text-sm hover:underline truncate block max-w-xs">{item.website}</a>
                      : <span className="text-slate-400 text-sm">—</span>}
                  </TableCell>
                  <TableCell>
                    {item.isActive
                      ? <Badge className="bg-green-100 text-green-700 border-0">Active</Badge>
                      : <Badge variant="outline">Inactive</Badge>}
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
          <DialogContent className="max-w-lg">
            <DialogHeader><DialogTitle>{editId ? "Edit MDA" : "Add MDA"}</DialogTitle></DialogHeader>
            <div className="space-y-4 py-2">
              <div className="space-y-1"><Label>Name</Label><Input value={editing.name ?? ""} onChange={e => setEditing(p => ({ ...p, name: e.target.value }))} /></div>
              <div className="grid grid-cols-2 gap-4">
                <div className="space-y-1"><Label>Category</Label>
                  <select className="w-full border border-slate-200 rounded-md px-3 py-2 text-sm" value={editing.category ?? "Ministry"} onChange={e => setEditing(p => ({ ...p, category: e.target.value }))}>
                    {["Ministry", "Authority", "Board", "Commission", "University", "Regulatory Body"].map(c => <option key={c}>{c}</option>)}
                  </select>
                </div>
                <div className="space-y-1"><Label>Website</Label><Input value={editing.website ?? ""} onChange={e => setEditing(p => ({ ...p, website: e.target.value }))} /></div>
              </div>
              <div className="space-y-1"><Label>Description</Label><Textarea rows={4} value={editing.description ?? ""} onChange={e => setEditing(p => ({ ...p, description: e.target.value }))} /></div>
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
