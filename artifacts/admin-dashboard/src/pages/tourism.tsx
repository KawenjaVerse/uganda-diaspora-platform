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

interface Attraction {
  id: number;
  name: string;
  description: string;
  category: string;
  location: string;
  imageUrl: string;
  isFeatured: boolean;
}

interface ListResponse { data: Attraction[]; total: number; }

const empty = (): Partial<Attraction> => ({ name: "", description: "", category: "", location: "", imageUrl: "", isFeatured: false });

export default function TourismPage() {
  const qc = useQueryClient();
  const { toast } = useToast();
  const [search, setSearch] = useState("");
  const [open, setOpen] = useState(false);
  const [editing, setEditing] = useState<Partial<Attraction>>(empty());
  const [editId, setEditId] = useState<number | null>(null);

  const { data } = useQuery<ListResponse>({
    queryKey: ["tourism", search],
    queryFn: () => api.get(`/tourism?limit=100${search ? `&search=${encodeURIComponent(search)}` : ""}`),
  });

  const save = useMutation({
    mutationFn: () => editId ? api.patch(`/tourism/${editId}`, editing) : api.post("/tourism", editing),
    onSuccess: () => { qc.invalidateQueries({ queryKey: ["tourism"] }); setOpen(false); toast({ title: "Saved" }); },
    onError: (e) => toast({ title: "Error", description: e.message, variant: "destructive" }),
  });

  const del = useMutation({
    mutationFn: (id: number) => api.delete(`/tourism/${id}`),
    onSuccess: () => { qc.invalidateQueries({ queryKey: ["tourism"] }); toast({ title: "Deleted" }); },
  });

  const openCreate = () => { setEditing(empty()); setEditId(null); setOpen(true); };
  const openEdit = (item: Attraction) => { setEditing(item); setEditId(item.id); setOpen(true); };

  return (
    <AppLayout>
      <div className="p-8">
        <div className="flex items-center justify-between mb-6">
          <div>
            <h1 className="text-2xl font-bold text-slate-900">Tourism</h1>
            <p className="text-slate-500 text-sm mt-1">{data?.total ?? 0} attractions</p>
          </div>
          <Button onClick={openCreate} className="bg-yellow-500 hover:bg-yellow-400 text-slate-900 font-semibold gap-2">
            <Plus className="w-4 h-4" /> Add Attraction
          </Button>
        </div>

        <div className="relative mb-4">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400" />
          <Input placeholder="Search attractions…" value={search} onChange={e => setSearch(e.target.value)} className="pl-9" />
        </div>

        <div className="bg-white rounded-xl border border-slate-100 overflow-hidden">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Name</TableHead>
                <TableHead>Category</TableHead>
                <TableHead>Location</TableHead>
                <TableHead>Featured</TableHead>
                <TableHead className="w-24">Actions</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {data?.data.map(item => (
                <TableRow key={item.id}>
                  <TableCell className="font-medium">{item.name}</TableCell>
                  <TableCell><Badge variant="secondary">{item.category}</Badge></TableCell>
                  <TableCell className="text-slate-500 text-sm">{item.location}</TableCell>
                  <TableCell>
                    {item.isFeatured
                      ? <Badge className="bg-yellow-100 text-yellow-700 border-0">Featured</Badge>
                      : <span className="text-slate-400 text-sm">—</span>}
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
            <DialogHeader><DialogTitle>{editId ? "Edit Attraction" : "Add Attraction"}</DialogTitle></DialogHeader>
            <div className="space-y-4 py-2">
              <div className="space-y-1"><Label>Name</Label><Input value={editing.name ?? ""} onChange={e => setEditing(p => ({ ...p, name: e.target.value }))} /></div>
              <div className="grid grid-cols-2 gap-4">
                <div className="space-y-1"><Label>Category</Label><Input value={editing.category ?? ""} onChange={e => setEditing(p => ({ ...p, category: e.target.value }))} /></div>
                <div className="space-y-1"><Label>Location</Label><Input value={editing.location ?? ""} onChange={e => setEditing(p => ({ ...p, location: e.target.value }))} /></div>
              </div>
              <div className="space-y-1"><Label>Description</Label><Textarea rows={5} value={editing.description ?? ""} onChange={e => setEditing(p => ({ ...p, description: e.target.value }))} /></div>
              <div className="space-y-1"><Label>Image URL</Label><Input value={editing.imageUrl ?? ""} onChange={e => setEditing(p => ({ ...p, imageUrl: e.target.value }))} /></div>
              <div className="flex items-center gap-2"><Switch checked={!!editing.isFeatured} onCheckedChange={v => setEditing(p => ({ ...p, isFeatured: v }))} /><Label>Featured</Label></div>
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
