import { Switch, Route, Router as WouterRouter, useLocation, Redirect } from "wouter";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { Toaster } from "@/components/ui/toaster";
import { TooltipProvider } from "@/components/ui/tooltip";
import { AuthProvider, useAuth } from "@/hooks/useAuth";
import { Loader2 } from "lucide-react";

import Login from "@/pages/login";
import Dashboard from "@/pages/dashboard";
import NewsPage from "@/pages/news";
import UsersPage from "@/pages/users";
import EmbassiesPage from "@/pages/embassies";
import TourismPage from "@/pages/tourism";
import WebinarsPage from "@/pages/webinars";
import EventsPage from "@/pages/events";
import CommunityPage from "@/pages/community";
import OpportunitiesPage from "@/pages/opportunities";
import NotificationsPage from "@/pages/notifications";
import MdasPage from "@/pages/mdas";
import RegistrationsPage from "@/pages/registrations";
import MessagesPage from "@/pages/messages";
import NotFound from "@/pages/not-found";

const queryClient = new QueryClient({
  defaultOptions: { queries: { retry: 1, staleTime: 30_000 } },
});

function ProtectedRoute({ component: Component }: { component: React.ComponentType }) {
  const { user, loading } = useAuth();
  const [location] = useLocation();

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-slate-50">
        <Loader2 className="w-8 h-8 animate-spin text-yellow-500" />
      </div>
    );
  }

  if (!user) {
    return <Redirect to="/login" />;
  }

  return <Component />;
}

function AppRoutes() {
  const { user, loading } = useAuth();
  const [location] = useLocation();

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-slate-50">
        <Loader2 className="w-8 h-8 animate-spin text-yellow-500" />
      </div>
    );
  }

  if (location === "/login" && user) {
    return <Redirect to="/" />;
  }

  return (
    <Switch>
      <Route path="/login" component={Login} />
      <Route path="/">{() => <ProtectedRoute component={Dashboard} />}</Route>
      <Route path="/news">{() => <ProtectedRoute component={NewsPage} />}</Route>
      <Route path="/users">{() => <ProtectedRoute component={UsersPage} />}</Route>
      <Route path="/embassies">{() => <ProtectedRoute component={EmbassiesPage} />}</Route>
      <Route path="/tourism">{() => <ProtectedRoute component={TourismPage} />}</Route>
      <Route path="/webinars">{() => <ProtectedRoute component={WebinarsPage} />}</Route>
      <Route path="/events">{() => <ProtectedRoute component={EventsPage} />}</Route>
      <Route path="/community">{() => <ProtectedRoute component={CommunityPage} />}</Route>
      <Route path="/opportunities">{() => <ProtectedRoute component={OpportunitiesPage} />}</Route>
      <Route path="/notifications">{() => <ProtectedRoute component={NotificationsPage} />}</Route>
      <Route path="/mdas">{() => <ProtectedRoute component={MdasPage} />}</Route>
      <Route path="/registrations">{() => <ProtectedRoute component={RegistrationsPage} />}</Route>
      <Route path="/messages">{() => <ProtectedRoute component={MessagesPage} />}</Route>
      <Route component={NotFound} />
    </Switch>
  );
}

function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <TooltipProvider>
        <AuthProvider>
          <WouterRouter base={import.meta.env.BASE_URL.replace(/\/$/, "")}>
            <AppRoutes />
          </WouterRouter>
        </AuthProvider>
        <Toaster />
      </TooltipProvider>
    </QueryClientProvider>
  );
}

export default App;
