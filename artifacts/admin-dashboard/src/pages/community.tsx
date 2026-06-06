import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { api } from "@/lib/api";
import { AppLayout } from "@/components/layout/app-layout";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Trash2, Shield, Heart, MessageCircle, Image } from "lucide-react";
import { useToast } from "@/hooks/use-toast";

interface Post {
  id: number;
  content: string;
  imageUrl?: string;
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
      <div className="min-h-screen bg-[#F7F7F8]">
        {/* Page header */}
        <div className="bg-[#121212] px-8 py-6">
          <div className="flex items-center justify-between">
            <div>
              <h1 className="text-xl font-black text-white tracking-tight">Community Posts</h1>
              <p className="text-white/40 text-sm mt-0.5">{data?.total ?? 0} posts in the feed</p>
            </div>
            <div className="flex items-center gap-3">
              <div className="bg-white/8 border border-white/10 rounded-xl px-4 py-2 text-center">
                <p className="text-[#D97706] font-black text-lg leading-none">
                  {data?.data.filter(p => !p.isModerated).length ?? "—"}
                </p>
                <p className="text-white/35 text-[10px] mt-0.5">Visible</p>
              </div>
              <div className="bg-white/8 border border-white/10 rounded-xl px-4 py-2 text-center">
                <p className="text-[#B91C1C] font-black text-lg leading-none">
                  {data?.data.filter(p => p.isModerated).length ?? "—"}
                </p>
                <p className="text-white/35 text-[10px] mt-0.5">Moderated</p>
              </div>
            </div>
          </div>
          <div className="flex mt-4 h-[2px] gap-0">
            {["#1A1A1A","#FFCE00","#D90026","#1A1A1A","#FFCE00","#D90026"].map((c, i) => (
              <div key={i} className="flex-1" style={{ background: c }} />
            ))}
          </div>
        </div>

        <div className="px-8 py-6">
          <div className="bg-white rounded-2xl border border-slate-100 overflow-hidden shadow-sm">
            <Table>
              <TableHeader>
                <TableRow className="bg-slate-50/70">
                  <TableHead className="font-bold text-slate-600 text-[11px] uppercase tracking-wide">Content</TableHead>
                  <TableHead className="font-bold text-slate-600 text-[11px] uppercase tracking-wide">Media</TableHead>
                  <TableHead className="font-bold text-slate-600 text-[11px] uppercase tracking-wide">Author</TableHead>
                  <TableHead className="font-bold text-slate-600 text-[11px] uppercase tracking-wide">Engagement</TableHead>
                  <TableHead className="font-bold text-slate-600 text-[11px] uppercase tracking-wide">Date</TableHead>
                  <TableHead className="font-bold text-slate-600 text-[11px] uppercase tracking-wide">Status</TableHead>
                  <TableHead className="w-28 font-bold text-slate-600 text-[11px] uppercase tracking-wide">Actions</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {data?.data.map(item => (
                  <TableRow key={item.id} className="hover:bg-slate-50/50 transition-colors">
                    <TableCell className="max-w-[260px]">
                      <p className="text-[13px] text-slate-700 line-clamp-2 leading-relaxed">{item.content}</p>
                    </TableCell>
                    <TableCell>
                      {item.imageUrl ? (
                        <div className="relative group">
                          <img
                            src={item.imageUrl}
                            alt=""
                            className="w-12 h-12 rounded-lg object-cover border border-slate-100"
                            onError={e => { (e.target as HTMLImageElement).style.display = "none"; }}
                          />
                          <div className="absolute inset-0 bg-black/40 rounded-lg opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center">
                            <Image className="w-4 h-4 text-white" />
                          </div>
                        </div>
                      ) : (
                        <span className="text-slate-300 text-xs">—</span>
                      )}
                    </TableCell>
                    <TableCell>
                      <div className="flex items-center gap-2">
                        <div className="w-7 h-7 rounded-full bg-slate-100 flex items-center justify-center shrink-0">
                          <span className="text-[10px] font-bold text-slate-500">
                            {item.authorName?.[0]?.toUpperCase() ?? "?"}
                          </span>
                        </div>
                        <span className="text-[12.5px] text-slate-600 font-medium whitespace-nowrap">{item.authorName}</span>
                      </div>
                    </TableCell>
                    <TableCell>
                      <div className="flex items-center gap-3">
                        <div className="flex items-center gap-1 text-[12px] text-slate-500">
                          <Heart className="w-3 h-3 text-rose-400" />
                          {item.likeCount}
                        </div>
                        <div className="flex items-center gap-1 text-[12px] text-slate-500">
                          <MessageCircle className="w-3 h-3 text-sky-400" />
                          {item.commentCount}
                        </div>
                      </div>
                    </TableCell>
                    <TableCell className="text-[12px] text-slate-400 whitespace-nowrap">
                      {new Date(item.createdAt).toLocaleDateString("en-GB", {
                        day: "numeric", month: "short", year: "numeric"
                      })}
                    </TableCell>
                    <TableCell>
                      {item.isModerated ? (
                        <Badge className="bg-[#B91C1C]/10 text-[#B91C1C] border-[#B91C1C]/20 text-[11px]">Hidden</Badge>
                      ) : (
                        <Badge className="bg-green-50 text-green-700 border-green-200 text-[11px]">Visible</Badge>
                      )}
                    </TableCell>
                    <TableCell>
                      <div className="flex items-center gap-1">
                        <Button
                          variant="ghost"
                          size="sm"
                          title={item.isModerated ? "Make visible" : "Hide post"}
                          onClick={() => moderate.mutate({ id: item.id, isModerated: !item.isModerated })}
                          className={`h-8 w-8 p-0 ${item.isModerated ? "text-green-600 hover:text-green-700 hover:bg-green-50" : "text-[#D97706] hover:text-orange-700 hover:bg-orange-50"}`}
                        >
                          <Shield className="w-3.5 h-3.5" />
                        </Button>
                        <Button
                          variant="ghost"
                          size="sm"
                          onClick={() => del.mutate(item.id)}
                          className="h-8 w-8 p-0 text-slate-400 hover:text-[#B91C1C] hover:bg-red-50"
                        >
                          <Trash2 className="w-3.5 h-3.5" />
                        </Button>
                      </div>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>

            {(!data || data.data.length === 0) && (
              <div className="py-16 text-center">
                <MessageCircle className="w-10 h-10 text-slate-200 mx-auto mb-3" />
                <p className="text-slate-400 text-sm">No posts yet</p>
              </div>
            )}
          </div>
        </div>
      </div>
    </AppLayout>
  );
}
