import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { api } from "@/lib/api";
import { AppLayout } from "@/components/layout/app-layout";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Trash2, Shield } from "lucide-react";
import { useToast } from "@/hooks/use-toast";

interface Post {
  id: number;
  content: string;
  authorName: string;
  likeCount: number;
  commentCount: number;
  isModerated: boolean;
  createdAt: string;
}

interface ListResponse { data: Post[]; total: number; }

export default function CommunityPage() {
  const qc = useQueryClient();
  const { toast } = useToast();

  const { data } = useQuery<ListResponse>({
    queryKey: ["posts"],
    queryFn: () => api.get("/posts?limit=100"),
  });

  const del = useMutation({
    mutationFn: (id: number) => api.delete(`/posts/${id}`),
    onSuccess: () => { qc.invalidateQueries({ queryKey: ["posts"] }); toast({ title: "Post deleted" }); },
    onError: (e) => toast({ title: "Error", description: e.message, variant: "destructive" }),
  });

  const moderate = useMutation({
    mutationFn: ({ id, isModerated }: { id: number; isModerated: boolean }) =>
      api.patch(`/posts/${id}`, { isModerated }),
    onSuccess: () => { qc.invalidateQueries({ queryKey: ["posts"] }); toast({ title: "Post updated" }); },
  });

  return (
    <AppLayout>
      <div className="p-8">
        <div className="mb-6">
          <h1 className="text-2xl font-bold text-slate-900">Community Posts</h1>
          <p className="text-slate-500 text-sm mt-1">{data?.total ?? 0} posts</p>
        </div>

        <div className="bg-white rounded-xl border border-slate-100 overflow-hidden">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Content</TableHead>
                <TableHead>Author</TableHead>
                <TableHead>Likes</TableHead>
                <TableHead>Comments</TableHead>
                <TableHead>Date</TableHead>
                <TableHead>Status</TableHead>
                <TableHead className="w-24">Actions</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {data?.data.map(item => (
                <TableRow key={item.id}>
                  <TableCell className="max-w-sm">
                    <p className="text-sm text-slate-700 line-clamp-2">{item.content}</p>
                  </TableCell>
                  <TableCell className="text-slate-500 text-sm whitespace-nowrap">{item.authorName}</TableCell>
                  <TableCell className="text-slate-500 text-sm">{item.likeCount}</TableCell>
                  <TableCell className="text-slate-500 text-sm">{item.commentCount}</TableCell>
                  <TableCell className="text-slate-500 text-sm whitespace-nowrap">{new Date(item.createdAt).toLocaleDateString()}</TableCell>
                  <TableCell>
                    {item.isModerated
                      ? <Badge className="bg-red-100 text-red-700 border-0">Moderated</Badge>
                      : <Badge className="bg-green-100 text-green-700 border-0">Visible</Badge>}
                  </TableCell>
                  <TableCell>
                    <div className="flex gap-1">
                      <Button
                        variant="ghost"
                        size="sm"
                        title={item.isModerated ? "Unmoderate" : "Moderate"}
                        onClick={() => moderate.mutate({ id: item.id, isModerated: !item.isModerated })}
                        className={item.isModerated ? "text-green-600" : "text-orange-500"}
                      >
                        <Shield className="w-4 h-4" />
                      </Button>
                      <Button variant="ghost" size="sm" onClick={() => del.mutate(item.id)} className="text-red-500 hover:text-red-700">
                        <Trash2 className="w-4 h-4" />
                      </Button>
                    </div>
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </div>
      </div>
    </AppLayout>
  );
}
