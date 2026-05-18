import { useState } from "react";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { api } from "@/lib/api";
import { AppLayout } from "@/components/layout/app-layout";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Badge } from "@/components/ui/badge";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter } from "@/components/ui/dialog";
import { Label } from "@/components/ui/label";
import { Switch } from "@/components/ui/switch";
import { Textarea } from "@/components/ui/textarea";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Plus, Pencil, Trash2, Search } from "lucide-react";
import { useToast } from "@/hooks/use-toast";

interface NewsItem {
  id: number;
  title: string;
  category: string;
  isPublished: boolean;
  isFeatured: boolean;
  authorName: string;
  viewCount: number;
  createdAt: string;
  content: string;
  summary: string;
  imageUrl: string;
}

interface ListResponse { data: NewsItem[]; total: number; }

const empty = (): Partial<NewsItem> => ({ title: "", content: "", summary: "", category: "general", imageUrl: "", authorName: "", isPublished: false, isFeatured: false });

export default function NewsPage() {
  const qc = useQueryClient();
  const { toast } = useToast();
  const [search, setSearch] = useState("");
  const [open, setOpen] = useState(false);
  const [editing, setEditing] = useState<Partial<NewsItem>>(empty());
  const [editId, setEditId] = useState<number | null>(null);

  const { data } = useQuery<ListResponse>({
    queryKey: ["news", search],
    queryFn: () => api.get(`/news?limit=100${search ? `&search=${encodeURIComponent(search)}` : ""}`),
  });

  const save = useMutation({
    mutationFn: () => editId
      ? api.patch(`/news/${editId}`, editing)
      : api.post("/news", editing),
    onSuccess: () => { qc.invalidateQueries({ queryKey: ["news"] }); setOpen(false); toast({ title: editId ? "Article updated" : "Article created" }); },
    onError: (e) => toast({ title: "Error", description: e.message, variant: "destructive" }),
  });

  const del = useMutation({
    mutationFn: (id: number) => api.delete(`/news/${id}`),
    onSuccess: () => { qc.invalidateQueries({ queryKey: ["news"] }); toast({ title: "Article deleted" }); },
  });

  const openCreate = () => { setEditing(empty()); setEditId(null); setOpen(true); };
  const openEdit = (item: NewsItem) => { setEditing(item); setEditId(item.id); setOpen(true); };

  return (
    <AppLayout>
      <div className="p-8">
        <div className="flex items-center justify-between mb-6">
          <div>
            <h1 className="text-2xl font-bold text-slate-900">News</h1>
            <p className="text-slate-500 text-sm mt-1">{data?.total ?? 0} articles total</p>
          </div>
          <Button onClick={openCreate} className="bg-yellow-500 hover:bg-yellow-400 text-slate-900 font-semibold gap-2">
            <Plus className="w-4 h-4" /> New Article
          </Button>
        </div>

        <div className="relative mb-4">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400" />
          <Input placeholder="Search articles…" value={search} onChange={e => setSearch(e.target.value)} className="pl-9" />
        </div>

        <div className="bg-white rounded-xl border border-slate-100 overflow-hidden">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Title</TableHead>
                <TableHead>Category</TableHead>
                <TableHead>Author</TableHead>
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
                  <TableCell className="text-slate-500 text-sm">{item.authorName}</TableCell>
                  <TableCell className="text-slate-500 text-sm">{item.viewCount ?? 0}</TableCell>
                  <TableCell>
                    {item.isPublished
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
            <DialogHeader><DialogTitle>{editId ? "Edit Article" : "New Article"}</DialogTitle></DialogHeader>
            <div className="space-y-4 py-2">
              <div className="space-y-1"><Label>Title</Label><Input value={editing.title ?? ""} onChange={e => setEditing(p => ({ ...p, title: e.target.value }))} /></div>
              <div className="space-y-1"><Label>Summary</Label><Input value={editing.summary ?? ""} onChange={e => setEditing(p => ({ ...p, summary: e.target.value }))} /></div>
              <div className="space-y-1"><Label>Content</Label><Textarea rows={6} value={editing.content ?? ""} onChange={e => setEditing(p => ({ ...p, content: e.target.value }))} /></div>
              <div className="grid grid-cols-2 gap-4">
                <div className="space-y-1"><Label>Category</Label><Input value={editing.category ?? ""} onChange={e => setEditing(p => ({ ...p, category: e.target.value }))} /></div>
                <div className="space-y-1"><Label>Author</Label><Input value={editing.authorName ?? ""} onChange={e => setEditing(p => ({ ...p, authorName: e.target.value }))} /></div>
              </div>
              <div className="space-y-1"><Label>Image URL</Label><Input value={editing.imageUrl ?? ""} onChange={e => setEditing(p => ({ ...p, imageUrl: e.target.value }))} /></div>
              <div className="flex gap-6">
                <div className="flex items-center gap-2"><Switch checked={!!editing.isPublished} onCheckedChange={v => setEditing(p => ({ ...p, isPublished: v }))} /><Label>Published</Label></div>
                <div className="flex items-center gap-2"><Switch checked={!!editing.isFeatured} onCheckedChange={v => setEditing(p => ({ ...p, isFeatured: v }))} /><Label>Featured</Label></div>
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
