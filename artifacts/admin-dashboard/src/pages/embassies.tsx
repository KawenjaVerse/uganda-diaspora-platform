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
import { Plus, Pencil, Trash2, Search } from "lucide-react";
import { useToast } from "@/hooks/use-toast";

interface Embassy {
  id: number;
  country: string;
  city: string;
  continent: string;
  address: string;
  phone: string;
  email: string;
  ambassadorName: string;
  ambassadorImageUrl: string;
  officeHours: string;
  servicesOffered: string;
  isActive: boolean;
}

interface ListResponse { data: Embassy[]; total: number; }

const empty = (): Partial<Embassy> => ({ country: "", city: "", continent: "", address: "", phone: "", email: "", ambassadorName: "", ambassadorImageUrl: "", officeHours: "", servicesOffered: "", isActive: true });

export default function EmbassiesPage() {
  const qc = useQueryClient();
  const { toast } = useToast();
  const [search, setSearch] = useState("");
  const [open, setOpen] = useState(false);
  const [editing, setEditing] = useState<Partial<Embassy>>(empty());
  const [editId, setEditId] = useState<number | null>(null);

  const { data } = useQuery<ListResponse>({
    queryKey: ["embassies", search],
    queryFn: () => api.get(`/embassies?limit=100${search ? `&search=${encodeURIComponent(search)}` : ""}`),
  });

  const save = useMutation({
    mutationFn: () => editId ? api.patch(`/embassies/${editId}`, editing) : api.post("/embassies", editing),
    onSuccess: () => { qc.invalidateQueries({ queryKey: ["embassies"] }); setOpen(false); toast({ title: editId ? "Embassy updated" : "Embassy added" }); },
    onError: (e) => toast({ title: "Error", description: e.message, variant: "destructive" }),
  });

  const del = useMutation({
    mutationFn: (id: number) => api.delete(`/embassies/${id}`),
    onSuccess: () => { qc.invalidateQueries({ queryKey: ["embassies"] }); toast({ title: "Embassy deleted" }); },
  });

  const openCreate = () => { setEditing(empty()); setEditId(null); setOpen(true); };
  const openEdit = (item: Embassy) => { setEditing(item); setEditId(item.id); setOpen(true); };

  return (
    <AppLayout>
      <div className="p-8">
        <div className="flex items-center justify-between mb-6">
          <div>
            <h1 className="text-2xl font-bold text-slate-900">Embassies</h1>
            <p className="text-slate-500 text-sm mt-1">{data?.total ?? 0} diplomatic missions</p>
          </div>
          <Button onClick={openCreate} className="bg-[#121212] hover:bg-[#1f1f1f] text-white font-semibold gap-2">
            <Plus className="w-4 h-4" /> Add Embassy
          </Button>
        </div>

        <div className="relative mb-4">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400" />
          <Input placeholder="Search embassies…" value={search} onChange={e => setSearch(e.target.value)} className="pl-9" />
        </div>

        <div className="bg-white rounded-xl border border-slate-100 overflow-hidden">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Country</TableHead>
                <TableHead>City</TableHead>
                <TableHead>Continent</TableHead>
                <TableHead>Ambassador</TableHead>
                <TableHead>Status</TableHead>
                <TableHead className="w-24">Actions</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {data?.data.map(item => (
                <TableRow key={item.id}>
                  <TableCell className="font-medium">{item.country}</TableCell>
                  <TableCell className="text-slate-500">{item.city}</TableCell>
                  <TableCell><Badge variant="secondary">{item.continent}</Badge></TableCell>
                  <TableCell className="text-slate-500 text-sm">{item.ambassadorName}</TableCell>
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
          <DialogContent className="max-w-2xl max-h-[90vh] overflow-y-auto">
            <DialogHeader><DialogTitle>{editId ? "Edit Embassy" : "Add Embassy"}</DialogTitle></DialogHeader>
            <div className="space-y-4 py-2">
              <div className="grid grid-cols-2 gap-4">
                <div className="space-y-1"><Label>Country</Label><Input value={editing.country ?? ""} onChange={e => setEditing(p => ({ ...p, country: e.target.value }))} /></div>
                <div className="space-y-1"><Label>City</Label><Input value={editing.city ?? ""} onChange={e => setEditing(p => ({ ...p, city: e.target.value }))} /></div>
              </div>
              <div className="grid grid-cols-2 gap-4">
                <div className="space-y-1"><Label>Continent</Label><Input value={editing.continent ?? ""} onChange={e => setEditing(p => ({ ...p, continent: e.target.value }))} /></div>
                <div className="space-y-1"><Label>Ambassador Name</Label><Input value={editing.ambassadorName ?? ""} onChange={e => setEditing(p => ({ ...p, ambassadorName: e.target.value }))} /></div>
              </div>
              <div className="space-y-1">
                <Label>Ambassador Photo URL</Label>
                <Input
                  placeholder="https://example.com/photo.jpg"
                  value={editing.ambassadorImageUrl ?? ""}
                  onChange={e => setEditing(p => ({ ...p, ambassadorImageUrl: e.target.value }))}
                />
                {editing.ambassadorImageUrl && (
                  <div className="flex items-center gap-3 mt-2">
                    <img
                      src={editing.ambassadorImageUrl}
                      alt="Ambassador preview"
                      className="w-12 h-12 rounded-full object-cover border border-slate-200"
                      onError={e => { (e.target as HTMLImageElement).style.display = "none"; }}
                    />
                    <span className="text-xs text-slate-400">Preview</span>
                  </div>
                )}
              </div>
              <div className="space-y-1"><Label>Address</Label><Input value={editing.address ?? ""} onChange={e => setEditing(p => ({ ...p, address: e.target.value }))} /></div>
              <div className="grid grid-cols-2 gap-4">
                <div className="space-y-1"><Label>Phone</Label><Input value={editing.phone ?? ""} onChange={e => setEditing(p => ({ ...p, phone: e.target.value }))} /></div>
                <div className="space-y-1"><Label>Email</Label><Input value={editing.email ?? ""} onChange={e => setEditing(p => ({ ...p, email: e.target.value }))} /></div>
              </div>
              <div className="space-y-1"><Label>Office Hours</Label><Input value={editing.officeHours ?? ""} onChange={e => setEditing(p => ({ ...p, officeHours: e.target.value }))} /></div>
              <div className="space-y-1"><Label>Services Offered</Label><Textarea rows={3} value={editing.servicesOffered ?? ""} onChange={e => setEditing(p => ({ ...p, servicesOffered: e.target.value }))} /></div>
            </div>
            <DialogFooter>
              <Button variant="outline" onClick={() => setOpen(false)}>Cancel</Button>
              <Button onClick={() => save.mutate()} disabled={save.isPending} className="bg-[#121212] hover:bg-[#1f1f1f] text-white">
                {save.isPending ? "Saving…" : "Save"}
              </Button>
            </DialogFooter>
          </DialogContent>
        </Dialog>
      </div>
    </AppLayout>
  );
}
