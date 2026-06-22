import { useState } from "react";
import { Loader2, ShieldCheck, Trash2, CheckCircle2, ChevronDown } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Checkbox } from "@/components/ui/checkbox";
import { api } from "@/lib/api";

const DATA_TYPES = [
  { id: "profile",      label: "Profile & personal information",  desc: "Name, email, country, profession, bio, profile photo" },
  { id: "posts",        label: "Posts & comments",                desc: "All community posts and comments you have made" },
  { id: "registration", label: "Diaspora registration data",      desc: "Registration form submission and related documents" },
  { id: "all",          label: "All data (full erasure)",         desc: "Permanently delete everything associated with your account" },
];

export default function DataDeletionPage() {
  const [name,     setName]     = useState("");
  const [email,    setEmail]    = useState("");
  const [reason,   setReason]   = useState("");
  const [selected, setSelected] = useState<string[]>([]);
  const [sending,  setSending]  = useState(false);
  const [done,     setDone]     = useState(false);
  const [error,    setError]    = useState("");

  const toggle = (id: string) => {
    if (id === "all") {
      setSelected(prev => prev.includes("all") ? [] : ["all"]);
    } else {
      setSelected(prev => {
        const next = prev.filter(x => x !== "all");
        return next.includes(id) ? next.filter(x => x !== id) : [...next, id];
      });
    }
  };

  const submit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError("");

    if (!name.trim() || !email.trim()) { setError("Please enter your full name and email address."); return; }
    if (selected.length === 0) { setError("Please select at least one type of data to delete."); return; }

    const dataList = selected.includes("all")
      ? "All data (full erasure)"
      : selected.map(id => DATA_TYPES.find(d => d.id === id)?.label ?? id).join("; ");

    const message = [
      `Data Deletion Request`,
      ``,
      `Name: ${name.trim()}`,
      `Email: ${email.trim()}`,
      `Data to delete: ${dataList}`,
      reason.trim() ? `Additional notes: ${reason.trim()}` : "",
    ].filter(Boolean).join("\n");

    setSending(true);
    try {
      await api.post("/contact-messages", {
        name: name.trim(),
        email: email.trim(),
        subject: "Data Deletion Request",
        message,
      });
      setDone(true);
    } catch {
      setError("Something went wrong. Please try again or email us directly at privacy@ugandadiaspora.go.ug");
    } finally {
      setSending(false);
    }
  };

  return (
    <div className="min-h-screen bg-slate-50 flex flex-col">
      {/* Header */}
      <header className="bg-[#0f0f0f] border-b border-white/5">
        <div className="max-w-2xl mx-auto px-6 py-4 flex items-center gap-3">
          <div className="w-8 h-8 rounded-lg bg-[#D97706] flex items-center justify-center shrink-0">
            <span className="text-white font-black text-sm">U</span>
          </div>
          <div>
            <p className="text-white text-sm font-bold leading-tight">Uganda Diaspora Platform</p>
            <p className="text-white/40 text-[10px] tracking-widest uppercase">Data &amp; Privacy</p>
          </div>
        </div>
      </header>

      <main className="flex-1 max-w-2xl mx-auto w-full px-6 py-10">
        {done ? (
          /* ── Success ──────────────────────────────────────────────── */
          <div className="bg-white rounded-2xl border border-slate-100 p-10 text-center">
            <div className="w-16 h-16 rounded-full bg-green-50 flex items-center justify-center mx-auto mb-5">
              <CheckCircle2 className="w-8 h-8 text-green-500" />
            </div>
            <h2 className="text-xl font-bold text-slate-900 mb-2">Request Received</h2>
            <p className="text-slate-500 text-sm leading-relaxed max-w-sm mx-auto">
              We have received your data deletion request. Our privacy team will review it and
              respond to <strong>{email}</strong> within 30 days.
            </p>
            <div className="mt-8 p-4 bg-slate-50 rounded-xl text-xs text-slate-400 text-left space-y-1">
              <p><strong className="text-slate-600">Reference:</strong> {email.toLowerCase().replace(/\W/g, "")}_{Date.now().toString(36).toUpperCase()}</p>
              <p><strong className="text-slate-600">Submitted:</strong> {new Date().toLocaleDateString("en-GB", { day: "numeric", month: "long", year: "numeric" })}</p>
            </div>
          </div>
        ) : (
          <>
            {/* ── Page title ─────────────────────────────────────────── */}
            <div className="mb-8">
              <div className="flex items-center gap-3 mb-4">
                <div className="w-10 h-10 rounded-xl bg-red-50 flex items-center justify-center">
                  <Trash2 className="w-5 h-5 text-red-500" />
                </div>
                <div>
                  <h1 className="text-2xl font-black text-slate-900 leading-tight">Data Deletion Request</h1>
                  <p className="text-slate-400 text-sm">Uganda Diaspora Platform</p>
                </div>
              </div>
              <p className="text-slate-600 text-sm leading-relaxed">
                Use this form to request that we delete some or all of the personal data we hold about you.
                You do not need to delete your account to submit this request.
                We will review your request and respond within <strong>30 days</strong>.
              </p>
            </div>

            {/* ── Form ───────────────────────────────────────────────── */}
            <form onSubmit={submit} className="space-y-6">

              {/* Identity */}
              <div className="bg-white rounded-2xl border border-slate-100 p-6 space-y-4">
                <h2 className="font-bold text-slate-800 text-sm flex items-center gap-2">
                  <ShieldCheck className="w-4 h-4 text-[#D97706]" />
                  Your Identity
                </h2>
                <div className="space-y-1">
                  <Label className="text-xs font-semibold">Full Name <span className="text-red-400">*</span></Label>
                  <Input
                    placeholder="e.g. John Doe"
                    value={name}
                    onChange={e => setName(e.target.value)}
                    className="border-slate-200 focus-visible:ring-[#D97706]"
                  />
                </div>
                <div className="space-y-1">
                  <Label className="text-xs font-semibold">Email Address (registered on the platform) <span className="text-red-400">*</span></Label>
                  <Input
                    type="email"
                    placeholder="your@email.com"
                    value={email}
                    onChange={e => setEmail(e.target.value)}
                    className="border-slate-200 focus-visible:ring-[#D97706]"
                  />
                  <p className="text-[11px] text-slate-400">We will use this to locate your account and send you a confirmation.</p>
                </div>
              </div>

              {/* Data types */}
              <div className="bg-white rounded-2xl border border-slate-100 p-6 space-y-4">
                <h2 className="font-bold text-slate-800 text-sm flex items-center gap-2">
                  <ChevronDown className="w-4 h-4 text-[#D97706]" />
                  What data would you like deleted? <span className="text-red-400">*</span>
                </h2>
                <div className="space-y-3">
                  {DATA_TYPES.map(dt => (
                    <label
                      key={dt.id}
                      className={`flex items-start gap-3 p-3 rounded-xl border cursor-pointer transition-colors ${
                        selected.includes(dt.id)
                          ? "border-[#D97706] bg-yellow-50"
                          : "border-slate-100 hover:border-slate-200 hover:bg-slate-50"
                      }`}
                    >
                      <Checkbox
                        checked={selected.includes(dt.id)}
                        onCheckedChange={() => toggle(dt.id)}
                        className="mt-0.5 data-[state=checked]:bg-[#D97706] data-[state=checked]:border-[#D97706]"
                      />
                      <div>
                        <p className="text-sm font-semibold text-slate-800">{dt.label}</p>
                        <p className="text-xs text-slate-400 mt-0.5">{dt.desc}</p>
                      </div>
                    </label>
                  ))}
                </div>
              </div>

              {/* Reason */}
              <div className="bg-white rounded-2xl border border-slate-100 p-6 space-y-2">
                <Label className="text-xs font-semibold text-slate-700">Additional notes (optional)</Label>
                <Textarea
                  rows={3}
                  placeholder="Any additional context about your request…"
                  value={reason}
                  onChange={e => setReason(e.target.value)}
                  className="border-slate-200 resize-none focus-visible:ring-[#D97706]"
                />
              </div>

              {error && (
                <div className="bg-red-50 border border-red-100 rounded-xl px-4 py-3 text-sm text-red-600">
                  {error}
                </div>
              )}

              <Button
                type="submit"
                disabled={sending}
                className="w-full bg-[#121212] hover:bg-[#1f1f1f] text-white font-bold h-12 rounded-xl text-sm"
              >
                {sending ? <><Loader2 className="w-4 h-4 animate-spin mr-2" />Submitting…</> : "Submit Deletion Request"}
              </Button>
            </form>
          </>
        )}
      </main>

      {/* Footer */}
      <footer className="border-t border-slate-200 mt-10">
        <div className="max-w-2xl mx-auto px-6 py-6 flex flex-col sm:flex-row items-center justify-between gap-2">
          <p className="text-xs text-slate-400">© {new Date().getFullYear()} Uganda Diaspora Platform · Ministry of Foreign Affairs</p>
          <p className="text-xs text-slate-400">
            Questions? Email{" "}
            <a href="mailto:privacy@ugandadiaspora.go.ug" className="text-[#D97706] hover:underline">
              privacy@ugandadiaspora.go.ug
            </a>
          </p>
        </div>
      </footer>
    </div>
  );
}
