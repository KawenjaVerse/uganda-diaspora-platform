import { useState } from "react";
import { useQuery } from "@tanstack/react-query";
import { api } from "@/lib/api";
import { AppLayout } from "@/components/layout/app-layout";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Badge } from "@/components/ui/badge";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Download, Search, Users2, Globe, Briefcase } from "lucide-react";

interface Registration {
  id: number;
  fullName: string;
  email: string | null;
  phone: string | null;
  country: string | null;
  city: string | null;
  gender: string | null;
  profession: string | null;
  yearsAbroad: string | null;
  reasonForDiaspora: string | null;
  nationalId: string | null;
  dateOfBirth: string | null;
  createdAt: string;
}

interface ListResponse { data: Registration[]; total: number; }

export default function RegistrationsPage() {
  const [search, setSearch] = useState("");

  const { data, isLoading } = useQuery<ListResponse>({
    queryKey: ["registrations"],
    queryFn: () => api.get("/registrations?limit=200"),
  });

  const filtered = (data?.data ?? []).filter(r =>
    !search ||
    r.fullName?.toLowerCase().includes(search.toLowerCase()) ||
    r.email?.toLowerCase().includes(search.toLowerCase()) ||
    r.country?.toLowerCase().includes(search.toLowerCase())
  );

  const downloadCSV = () => {
    const headers = ["ID", "Full Name", "Email", "Phone", "Country", "City", "Gender", "Profession", "Years Abroad", "Reason", "Date Registered"];
    const rows = (data?.data ?? []).map(r => [
      r.id,
      r.fullName ?? "",
      r.email ?? "",
      r.phone ?? "",
      r.country ?? "",
      r.city ?? "",
      r.gender ?? "",
      r.profession ?? "",
      r.yearsAbroad ?? "",
      r.reasonForDiaspora ?? "",
      new Date(r.createdAt).toLocaleDateString("en-GB"),
    ]);
    const csv = [headers, ...rows]
      .map(row => row.map(v => `"${String(v).replace(/"/g, '""')}"`).join(","))
      .join("\n");
    const blob = new Blob([csv], { type: "text/csv;charset=utf-8;" });
    const url = URL.createObjectURL(blob);
    const a = document.createElement("a");
    a.href = url;
    a.download = `diaspora-registrations-${new Date().toISOString().split("T")[0]}.csv`;
    a.click();
    URL.revokeObjectURL(url);
  };

  const total = data?.total ?? 0;
  const countries = new Set((data?.data ?? []).map(r => r.country).filter(Boolean)).size;
  const professionals = (data?.data ?? []).filter(r => r.profession).length;

  return (
    <AppLayout>
      <div className="p-8">
        {/* Header */}
        <div className="flex items-start justify-between mb-8">
          <div>
            <h1 className="text-2xl font-bold text-slate-900">Diaspora Registrations</h1>
            <p className="text-slate-500 text-sm mt-1">All submitted diaspora registration forms</p>
          </div>
          <Button
            onClick={downloadCSV}
            disabled={!data?.data?.length}
            className="bg-[#121212] hover:bg-[#1f1f1f] text-white font-semibold gap-2"
          >
            <Download className="w-4 h-4" />
            Export CSV
          </Button>
        </div>

        {/* Stats */}
        <div className="grid grid-cols-3 gap-4 mb-8">
          {[
            { icon: Users2, label: "Total Registrations", value: total, color: "#D97706" },
            { icon: Globe, label: "Countries Represented", value: countries, color: "#2563EB" },
            { icon: Briefcase, label: "With Profession Listed", value: professionals, color: "#16A34A" },
          ].map(({ icon: Icon, label, value, color }) => (
            <div key={label} className="bg-white rounded-2xl p-5 border border-slate-100">
              <div className="flex items-start justify-between mb-3">
                <div className="w-10 h-10 rounded-xl flex items-center justify-center" style={{ background: `${color}14` }}>
                  <Icon className="w-5 h-5" style={{ color }} />
                </div>
              </div>
              <p className="text-[11px] font-semibold text-slate-400 uppercase tracking-widest mb-1">{label}</p>
              <p className="text-3xl font-black tracking-tight" style={{ color }}>{value.toLocaleString()}</p>
            </div>
          ))}
        </div>

        {/* Search */}
        <div className="relative mb-4">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400" />
          <Input
            placeholder="Search by name, email, or country…"
            value={search}
            onChange={e => setSearch(e.target.value)}
            className="pl-9"
          />
        </div>

        {/* Table */}
        <div className="bg-white rounded-xl border border-slate-100 overflow-hidden">
          {isLoading ? (
            <div className="p-12 text-center text-slate-400">Loading registrations…</div>
          ) : filtered.length === 0 ? (
            <div className="p-12 text-center">
              <Users2 className="w-10 h-10 text-slate-200 mx-auto mb-3" />
              <p className="text-slate-400">No registrations found</p>
            </div>
          ) : (
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>#</TableHead>
                  <TableHead>Name</TableHead>
                  <TableHead>Email</TableHead>
                  <TableHead>Country</TableHead>
                  <TableHead>Profession</TableHead>
                  <TableHead>Gender</TableHead>
                  <TableHead>Years Abroad</TableHead>
                  <TableHead>Registered</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {filtered.map(r => (
                  <TableRow key={r.id}>
                    <TableCell className="text-slate-400 text-xs">{r.id}</TableCell>
                    <TableCell className="font-medium">{r.fullName}</TableCell>
                    <TableCell className="text-slate-500 text-sm">{r.email ?? "—"}</TableCell>
                    <TableCell>
                      {r.country
                        ? <Badge variant="secondary" className="text-xs">{r.country}{r.city ? `, ${r.city}` : ""}</Badge>
                        : <span className="text-slate-300">—</span>}
                    </TableCell>
                    <TableCell className="text-slate-500 text-sm">{r.profession ?? "—"}</TableCell>
                    <TableCell>
                      {r.gender
                        ? <span className={`text-xs font-medium px-2 py-0.5 rounded-full ${r.gender === "Male" ? "bg-blue-50 text-blue-700" : r.gender === "Female" ? "bg-pink-50 text-pink-700" : "bg-slate-50 text-slate-600"}`}>{r.gender}</span>
                        : <span className="text-slate-300">—</span>}
                    </TableCell>
                    <TableCell className="text-slate-500 text-sm">{r.yearsAbroad ? `${r.yearsAbroad} yrs` : "—"}</TableCell>
                    <TableCell className="text-slate-400 text-xs">
                      {new Date(r.createdAt).toLocaleDateString("en-GB", { day: "numeric", month: "short", year: "numeric" })}
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          )}
        </div>

        {filtered.length > 0 && (
          <p className="text-xs text-slate-400 mt-3">
            Showing {filtered.length} of {total} registrations
          </p>
        )}
      </div>
    </AppLayout>
  );
}
