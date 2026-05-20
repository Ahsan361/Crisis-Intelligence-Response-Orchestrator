import { Navigate, Route, Routes, Outlet } from "react-router-dom"
import { AppShell } from "@/components/layout/app-shell"
import { AnalyticsPage } from "@/pages/analytics"
import { DashboardPage } from "@/pages/dashboard"
import { ReportsPage } from "@/pages/reports"
import { SeederPage } from "@/pages/seeder"
import { TraceViewerPage } from "@/pages/trace-viewer"
import { LoginPage } from "@/pages/login"
import { useAuth } from "@/lib/authContext"

function ProtectedLayout() {
  const { isAuthenticated } = useAuth()
  if (!isAuthenticated) {
    return <Navigate to="/login" replace />
  }
  return <AppShell />
}

function PublicLayout() {
  const { isAuthenticated } = useAuth()
  if (isAuthenticated) {
    return <Navigate to="/" replace />
  }
  return <Outlet />
}

export function App() {
  return (
    <Routes>
      {/* Public Routes */}
      <Route element={<PublicLayout />}>
        <Route path="login" element={<LoginPage />} />
      </Route>

      {/* Protected Routes */}
      <Route element={<ProtectedLayout />}>
        <Route index element={<DashboardPage />} />
        <Route path="reports" element={<ReportsPage />} />
        <Route path="trace/:id" element={<TraceViewerPage />} />
        <Route path="analytics" element={<AnalyticsPage />} />
        <Route path="seeder" element={<SeederPage />} />
      </Route>

      {/* Fallback */}
      <Route path="*" element={<Navigate to="/" replace />} />
    </Routes>
  )
}
