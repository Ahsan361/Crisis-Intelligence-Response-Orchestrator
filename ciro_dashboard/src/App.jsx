import { Navigate, Route, Routes } from "react-router-dom"
import { AppShell } from "@/components/layout/app-shell"
import { AnalyticsPage } from "@/pages/analytics"
import { DashboardPage } from "@/pages/dashboard"
import { ReportsPage } from "@/pages/reports"
import { SeederPage } from "@/pages/seeder"
import { TraceViewerPage } from "@/pages/trace-viewer"

export function App() {
  return (
    <Routes>
      <Route element={<AppShell />}>
        <Route index element={<DashboardPage />} />
        <Route path="reports" element={<ReportsPage />} />
        <Route path="trace/:id" element={<TraceViewerPage />} />
        <Route path="analytics" element={<AnalyticsPage />} />
        <Route path="seeder" element={<SeederPage />} />
        <Route path="*" element={<Navigate to="/" replace />} />
      </Route>
    </Routes>
  )
}
