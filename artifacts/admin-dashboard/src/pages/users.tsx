import { useState } from "react";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { api } from "@/lib/api";
import { AppLayout } from "@/components/layout/app-layout";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Badge } from "@/components/ui/badge";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Trash2, Search } from "lucide-react";
import { useToast } from "@/hooks/use-toast";

interface User {
  id: number;
  email: string;
  fullName: string;
  role: string;
  country: string;
  profession: string;
  isVerified: boolean;
  isActive: boolean;
  createdAt: string;
}

interface ListResponse { data: User[]; total: number; }

export default function UsersPage() {
  const qc = useQueryClient();
  const { toast } = useToast();
  const [search, setSearch] = useState("");

  const { data } = useQuery<ListResponse>({
    queryKey: ["users", search],
    queryFn: () => api.get(`/users?limit=100${search ? `&search=${encodeURIComponent(search)}` : ""}`),
  });

  const del = useMutation({
    mutationFn: (id: number) => api.delete(`/users/${id}`),
    onSuccess: () => { qc.invalidateQueries({ queryKey: ["users"] }); toast({ title: "User deleted" }); },
    onError: (e) => toast({ title: "Error", description: e.message, variant: "destructive" }),
  });

  return (
    <AppLayout>
      <div className="p-8">
        <div className="flex items-center justify-between mb-6">
          <div>
            <h1 className="text-2xl font-bold text-slate-900">Users</h1>
            <p className="text-slate-500 text-sm mt-1">{data?.total ?? 0} registered members</p>
          </div>
        </div>

        <div className="relative mb-4">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400" />
          <Input placeholder="Search users…" value={search} onChange={e => setSearch(e.target.value)} className="pl-9" />
        </div>

        <div className="bg-white rounded-xl border border-slate-100 overflow-hidden">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Name</TableHead>
                <TableHead>Email</TableHead>
                <TableHead>Country</TableHead>
                <TableHead>Profession</TableHead>
                <TableHead>Role</TableHead>
                <TableHead>Status</TableHead>
                <TableHead className="w-16">Actions</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {data?.data.map(user => (
                <TableRow key={user.id}>
                  <TableCell className="font-medium">{user.fullName}</TableCell>
                  <TableCell className="text-slate-500 text-sm">{user.email}</TableCell>
                  <TableCell className="text-slate-500 text-sm">{user.country}</TableCell>
                  <TableCell className="text-slate-500 text-sm">{user.profession}</TableCell>
                  <TableCell><Badge variant={user.role === "admin" ? "default" : "secondary"} className="capitalize">{user.role}</Badge></TableCell>
                  <TableCell>
                    {user.isActive
                      ? <Badge className="bg-green-100 text-green-700 border-0">Active</Badge>
                      : <Badge variant="outline">Inactive</Badge>}
                  </TableCell>
                  <TableCell>
                    <Button variant="ghost" size="sm" onClick={() => del.mutate(user.id)} className="text-red-500 hover:text-red-700">
                      <Trash2 className="w-4 h-4" />
                    </Button>
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
