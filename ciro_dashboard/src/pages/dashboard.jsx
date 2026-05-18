import { AlertTriangle, CheckCircle2, RadioTower, Siren } from "lucide-react"
import { Bar, BarChart, Cell, Pie, PieChart, ResponsiveContainer, Tooltip, XAxis, YAxis } from "recharts"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { ChartCard } from "@/components/charts/chart-card"
import { DataCard } from "@/components/shared/data-card"
import { ErrorState, LoadingState } from "@/components/shared/state-blocks"
import { SeverityBadge } from "@/components/shared/severity-badge"
import { StatusBadge } from "@/components/shared/status-badge"
import { useAnalyzeReport, useReports } from "@/hooks/useReports"
import { countBy, dashboardStats, severityBreakdown, systemStatus } from "@/lib/analytics"
import { timeAgo, titleCase } from "@/lib/format"

export function DashboardPage() {
  const reportsQuery = useReports({ refetchInterval: 10000 })
  const analyze = useAnalyzeReport()
  const reports = reportsQuery.data ?? []
  const stats = dashboardStats(reports)
  const status = systemStatus(reports)
  const crisisData = countBy(reports, "crisis_type")
  const severityData = severityBreakdown(reports)
  const recent = [...reports].sort((a, b) => new Date(b.created_at) - new Date(a.created_at)).slice(0, 10)

  if (reportsQuery.isLoading) return <LoadingState label="Loading CIRO dashboard..." />
  if (reportsQuery.isError) return <ErrorState error={reportsQuery.error} onRetry={reportsQuery.refetch} />

  return (
    <div className="space-y-4">
      <div className="grid grid-cols-4 gap-4">
        <DataCard title="Total Reports" value={stats.totalReports} description="All-time city signals" icon={RadioTower} />
        <DataCard title="Active Crises" value={stats.activeCrises} description="Pending and analyzing" icon={Siren} tone="warning" />
        <DataCard title="Resolved Today" value={stats.resolvedToday} description="Closed since midnight" icon={CheckCircle2} tone="secondary" />
        <DataCard title="Critical Alerts" value={stats.criticalAlerts} description="Unresolved critical reports" icon={AlertTriangle} tone="critical" />
      </div>

      <Card className={status.className}>
        <CardContent className="flex items-center justify-between">
          <div>
            <p className="text-base font-bold">{status.title}</p>
            <p className="mt-1 text-sm opacity-90">{status.description}</p>
          </div>
          <Siren className="h-6 w-6" />
        </CardContent>
      </Card>

      <div className="grid grid-cols-2 gap-4">
        <ChartCard title="Crisis Distribution" description="Reports grouped by crisis type" empty={!crisisData.length}>
          <ResponsiveContainer width="100%" height="100%">
            <PieChart>
              <Pie data={crisisData} dataKey="value" nameKey="name" innerRadius={62} outerRadius={96} paddingAngle={3}>
                {crisisData.map((entry) => (
                  <Cell key={entry.name} fill={entry.fill} />
                ))}
              </Pie>
              <Tooltip formatter={(value, name) => [value, titleCase(name)]} />
            </PieChart>
          </ResponsiveContainer>
        </ChartCard>

        <ChartCard title="Severity Breakdown" description="Counts by severity level" empty={!reports.length}>
          <ResponsiveContainer width="100%" height="100%">
            <BarChart data={severityData}>
              <XAxis dataKey="severity" tickFormatter={titleCase} />
              <YAxis allowDecimals={false} />
              <Tooltip labelFormatter={titleCase} />
              <Bar dataKey="count" radius={[8, 8, 0, 0]}>
                {severityData.map((entry) => (
                  <Cell key={entry.severity} fill={entry.fill} />
                ))}
              </Bar>
            </BarChart>
          </ResponsiveContainer>
        </ChartCard>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Recent Activity Feed</CardTitle>
        </CardHeader>
        <CardContent className="space-y-2">
          {recent.length ? (
            recent.map((report) => (
              <div key={report.id} className="grid grid-cols-[1fr_auto_auto_auto_auto] items-center gap-3 rounded-button border bg-background px-3 py-2">
                <div>
                  <p className="font-semibold text-foreground">{report.area_name || "Unknown Islamabad Sector"}</p>
                  <p className="text-xs text-muted">{titleCase(report.crisis_type)} · {timeAgo(report.created_at)}</p>
                </div>
                <SeverityBadge severity={report.severity} />
                <StatusBadge status={report.status} />
                <span className="text-sm text-muted">{report.source || "manual"}</span>
                <Button size="sm" disabled={report.status !== "pending" || analyze.isPending} onClick={() => analyze.mutate(report)}>
                  Analyze
                </Button>
              </div>
            ))
          ) : (
            <p className="rounded-button border bg-background p-4 text-sm text-muted">No Islamabad crisis reports have reached CIRO yet.</p>
          )}
        </CardContent>
      </Card>
    </div>
  )
}
