import { useState } from "react";
import { useAuth } from "@/hooks/useAuth";
import { useLocation } from "wouter";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Alert, AlertDescription } from "@/components/ui/alert";
import { Loader2, Shield, Globe, Users, Newspaper } from "lucide-react";

const features = [
  { icon: Globe,     label: "Global Reach",    desc: "54+ diplomatic missions worldwide" },
  { icon: Users,     label: "Diaspora Members", desc: "Connecting Ugandans globally"      },
  { icon: Newspaper, label: "Content Hub",      desc: "News, events & announcements"      },
];

const FLAG_COLORS = ["#1A1A1A","#FFCE00","#D90026","#1A1A1A","#FFCE00","#D90026"];

export default function Login() {
  const { login } = useAuth();
  const [, navigate] = useLocation();
  const [email, setEmail]       = useState("");
  const [password, setPassword] = useState("");
  const [error, setError]       = useState("");
  const [loading, setLoading]   = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError("");
    setLoading(true);
    try {
      await login(email, password);
      navigate("/");
    } catch (err) {
      setError(err instanceof Error ? err.message : "Invalid credentials");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex bg-[#0f0f0f]">
      {/* ── Left branding panel ──────────────────────────────── */}
      <div className="hidden lg:flex flex-col w-[460px] shrink-0 relative overflow-hidden p-12">
        <div className="absolute inset-0 bg-[#0f0f0f]" />
        <div
          className="absolute inset-0 opacity-[0.025]"
          style={{
            backgroundImage: "radial-gradient(circle at 1px 1px, white 1px, transparent 0)",
            backgroundSize: "28px 28px",
          }}
        />
        <div className="absolute top-0 right-0 w-72 h-72 bg-[#D97706]/10 rounded-full blur-3xl pointer-events-none" />
        <div className="absolute bottom-24 left-0 w-56 h-56 bg-[#B91C1C]/8 rounded-full blur-3xl pointer-events-none" />

        <div className="relative z-10 flex flex-col h-full">
          {/* Brand mark */}
          <div className="flex items-center gap-3 mb-16">
            <div className="w-10 h-10 rounded-xl bg-[#D97706] flex items-center justify-center shadow-lg shadow-orange-900/40">
              <span className="text-white font-black text-lg leading-none">U</span>
            </div>
            <div>
              <p className="text-white font-black text-[13px] tracking-tight">Uganda Diaspora</p>
              <p className="text-white/30 text-[9.5px] uppercase tracking-widest">Admin Portal</p>
            </div>
          </div>

          {/* Headline */}
          <div className="mb-12">
            <div className="inline-flex items-center gap-1.5 bg-[#D97706]/15 border border-[#D97706]/25 rounded-full px-3 py-1 mb-5">
              <Shield className="w-3 h-3 text-[#D97706]" />
              <span className="text-[#D97706] text-[10px] font-bold uppercase tracking-widest">Secure Access</span>
            </div>
            <h1 className="text-[38px] font-black text-white leading-[1.12] mb-4 tracking-tight">
              Manage the<br />
              <span className="text-[#D97706]">Diaspora</span><br />
              Platform
            </h1>
            <p className="text-white/35 text-[13px] leading-relaxed">
              Uganda's national digital platform connecting citizens across the globe.
              One portal for content, communities, and communications.
            </p>
          </div>

          {/* Features */}
          <div className="space-y-4">
            {features.map(({ icon: Icon, label, desc }) => (
              <div key={label} className="flex items-center gap-4">
                <div className="w-9 h-9 rounded-xl bg-white/5 border border-white/8 flex items-center justify-center shrink-0">
                  <Icon className="w-4 h-4 text-[#D97706]" />
                </div>
                <div>
                  <p className="text-white text-[13px] font-semibold">{label}</p>
                  <p className="text-white/35 text-[11px]">{desc}</p>
                </div>
              </div>
            ))}
          </div>

          {/* Flag strip */}
          <div className="mt-auto">
            <div className="flex rounded-full overflow-hidden h-[3px] gap-0.5 mb-4">
              {FLAG_COLORS.map((c, i) => (
                <div key={i} className="flex-1" style={{ background: c }} />
              ))}
            </div>
            <p className="text-white/18 text-[10px]">
              © {new Date().getFullYear()} Republic of Uganda · Ministry of Foreign Affairs
            </p>
          </div>
        </div>
      </div>

      {/* ── Right form panel ─────────────────────────────────── */}
      <div className="flex-1 flex items-center justify-center p-8 bg-white">
        <div className="w-full max-w-sm">
          {/* Mobile logo */}
          <div className="flex items-center gap-3 mb-10 lg:hidden">
            <div className="w-9 h-9 rounded-xl bg-[#D97706] flex items-center justify-center">
              <span className="text-white font-black text-base">U</span>
            </div>
            <div>
              <p className="font-black text-sm text-[#121212]">Uganda Diaspora</p>
              <p className="text-slate-400 text-[10px] uppercase tracking-widest">Admin Portal</p>
            </div>
          </div>

          <div className="mb-8">
            <h2 className="text-[26px] font-black text-[#121212] tracking-tight mb-1.5">Welcome back</h2>
            <p className="text-slate-400 text-sm">Sign in to your admin account to continue</p>
          </div>

          <form onSubmit={handleSubmit} className="space-y-5">
            {error && (
              <Alert className="border-[#B91C1C]/25 bg-[#B91C1C]/5">
                <AlertDescription className="text-[#B91C1C] text-sm">{error}</AlertDescription>
              </Alert>
            )}

            <div className="space-y-1.5">
              <Label className="text-[13px] font-semibold text-slate-700">Email address</Label>
              <Input
                type="email"
                placeholder="admin@ugandadiaspora.go.ug"
                value={email}
                onChange={e => setEmail(e.target.value)}
                required
                autoFocus
                className="h-11 border-slate-200 text-sm rounded-xl"
              />
            </div>

            <div className="space-y-1.5">
              <Label className="text-[13px] font-semibold text-slate-700">Password</Label>
              <Input
                type="password"
                placeholder="••••••••"
                value={password}
                onChange={e => setPassword(e.target.value)}
                required
                className="h-11 border-slate-200 text-sm rounded-xl"
              />
            </div>

            <button
              type="submit"
              disabled={loading}
              className="w-full h-11 bg-[#121212] hover:bg-[#1f1f1f] active:bg-[#0a0a0a] text-white font-bold text-sm rounded-xl transition-colors flex items-center justify-center gap-2 disabled:opacity-60 cursor-pointer mt-1"
            >
              {loading && <Loader2 className="w-4 h-4 animate-spin" />}
              {loading ? "Signing in…" : "Sign in to Dashboard"}
            </button>
          </form>

          {/* Demo credentials */}
          <div className="mt-8 p-4 bg-slate-50 rounded-xl border border-slate-100">
            <p className="text-[10px] font-bold text-slate-400 uppercase tracking-widest mb-2">Demo Credentials</p>
            <div className="space-y-0.5">
              <p className="text-[12px] text-slate-600 font-mono">admin@ugandadiaspora.go.ug</p>
              <p className="text-[12px] text-slate-600 font-mono">Admin@2024!</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
