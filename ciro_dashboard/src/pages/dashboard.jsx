import { useState } from "react"
import { AlertTriangle, CheckCircle2, RadioTower, Siren } from "lucide-react"
import { Bar, BarChart, Cell, Pie, PieChart, ResponsiveContainer, Tooltip, XAxis, YAxis, Sector, CartesianGrid } from "recharts"
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

  const [activeIndex, setActiveIndex] = useState(-1)
  const [hoveredSeverity, setHoveredSeverity] = useState(null)
  const [visibleCount, setVisibleCount] = useState(10)

  const sortedReports = [...reports].sort((a, b) => new Date(b.created_at) - new Date(a.created_at))
  const recent = sortedReports.slice(0, visibleCount)

  const getActiveDetails = (categoryName) => {
    if (!categoryName) return { total: 0, percentage: 0, severityStr: "" }
    const categoryReports = reports.filter((r) => (r.crisis_type || "").toLowerCase() === categoryName.toLowerCase())
    const total = categoryReports.length
    const critical = categoryReports.filter((r) => r.severity === "critical").length
    const high = categoryReports.filter((r) => r.severity === "high").length
    const medium = categoryReports.filter((r) => r.severity === "medium").length
    const low = categoryReports.filter((r) => r.severity === "low").length

    const severities = []
    if (critical > 0) severities.push(`${critical} Crit`)
    if (high > 0) severities.push(`${high} High`)
    if (medium > 0) severities.push(`${medium} Med`)
    if (low > 0) severities.push(`${low} Low`)

    return {
      total,
      percentage: reports.length ? Math.round((total / reports.length) * 100) : 0,
      severityStr: severities.join(", ") || "No severity details"
    }
  }

  const renderActiveShape = (props) => {
    const { cx, cy, innerRadius, outerRadius, startAngle, endAngle, fill } = props
    return (
      <g>
        <Sector
          cx={cx}
          cy={cy}
          innerRadius={innerRadius}
          outerRadius={outerRadius + 3}
          startAngle={startAngle}
          endAngle={endAngle}
          fill={fill}
        />
      </g>
    )
  }

  const onPieEnter = (_, index) => {
    setActiveIndex(index)
  }

  const onPieLeave = () => {
    setActiveIndex(-1)
  }

  const CustomTooltip = ({ active, payload, label }) => {
    if (active && payload && payload.length) {
      const data = payload[0].payload
      return (
        <div className="rounded-button border bg-card/90 backdrop-blur-md p-3 shadow-xl border-border/50">
          <p className="text-xs font-semibold text-muted-foreground uppercase tracking-wider">{titleCase(label)} Severity</p>
          <p className="text-lg font-bold text-foreground mt-1 flex items-center gap-1.5">
            <span className="h-2 w-2 rounded-full" style={{ backgroundColor: data.fill }} />
            {payload[0].value} {payload[0].value === 1 ? 'Incident' : 'Incidents'}
          </p>
        </div>
      )
    }
    return null
  }

  if (reportsQuery.isLoading) return <LoadingState label="Loading CIRO dashboard..." />
  if (reportsQuery.isError) return <ErrorState error={reportsQuery.error} onRetry={reportsQuery.refetch} />

  return (
    <div className="space-y-4">
      <Card className={status.className}>
        <CardContent className="flex items-center justify-between">
          <div>
            <p className="text-base font-bold">{status.title}</p>
            <p className="mt-1 text-sm opacity-90">{status.description}</p>
          </div>
          <Siren className="h-6 w-6" />
        </CardContent>
      </Card>

      <div className="grid grid-cols-4 gap-4">
        <DataCard title="Total Reports" value={stats.totalReports} description="All-time city signals" icon={RadioTower} />
        <DataCard title="Active Crises" value={stats.activeCrises} description="Pending and analyzing" icon={Siren} tone="warning" />
        <DataCard title="Resolved Today" value={stats.resolvedToday} description="Closed since midnight" icon={CheckCircle2} tone="secondary" />
        <DataCard title="Critical Alerts" value={stats.criticalAlerts} description="Unresolved critical reports" icon={AlertTriangle} tone="critical" />
      </div>

      <div className="grid grid-cols-2 gap-4">
        <ChartCard title="Crisis Distribution" description="Reports grouped by crisis type" empty={!crisisData.length} className="h-[390px] flex flex-col justify-between pb-2">
          <div className="relative flex flex-col items-center">
            <div className="relative w-full h-[240px] flex items-center justify-center">
              <ResponsiveContainer width="100%" height="100%">
                <PieChart>
                  <Pie
                    data={crisisData}
                    dataKey="value"
                    nameKey="name"
                    innerRadius={80}
                    outerRadius={112}
                    paddingAngle={3}
                    activeIndex={activeIndex}
                    activeShape={renderActiveShape}
                    onMouseEnter={onPieEnter}
                    onMouseLeave={onPieLeave}
                  >
                    {crisisData.map((entry) => (
                      <Cell key={entry.name} fill={entry.fill} style={{ cursor: "pointer", outline: "none" }} />
                    ))}
                  </Pie>
                </PieChart>
              </ResponsiveContainer>
              <div className="absolute inset-0 flex flex-col items-center justify-center pointer-events-none select-none px-8 py-6 text-center">
                {activeIndex === -1 ? (
                  <>
                    <span className="text-3xl font-extrabold text-foreground">{stats.totalReports}</span>
                    <span className="text-[10px] font-bold text-muted-foreground uppercase tracking-widest mt-1">Total Reports</span>
                  </>
                ) : (
                  <>
                    <span className="text-[11px] font-extrabold uppercase tracking-widest" style={{ color: crisisData[activeIndex]?.fill }}>
                      {titleCase(crisisData[activeIndex]?.name)}
                    </span>
                    <span className="text-2xl font-black text-foreground mt-1">
                      {crisisData[activeIndex]?.value} {crisisData[activeIndex]?.value === 1 ? 'Report' : 'Reports'}
                    </span>
                    <span className="text-[10px] text-muted-foreground font-semibold mt-0.5">
                      {stats.totalReports ? Math.round((crisisData[activeIndex]?.value / stats.totalReports) * 100) : 0}% of total
                    </span>
                    <span className="text-[10px] text-muted-foreground mt-1.5 max-w-[130px] text-center font-mono opacity-80 leading-normal border-t border-border/40 pt-1">
                      {getActiveDetails(crisisData[activeIndex]?.name).severityStr}
                    </span>
                  </>
                )}
              </div>
            </div>

            <div className="mt-2 grid grid-cols-2 gap-2 w-full px-4">
              {crisisData.map((entry, index) => {
                const pct = stats.totalReports ? Math.round((entry.value / stats.totalReports) * 100) : 0
                const isActive = activeIndex === index
                return (
                  <div
                    key={entry.name}
                    className={`flex items-center gap-2 rounded-button border p-2 text-xs transition-all duration-200 ${
                      isActive ? "bg-accent/45 border-accent-foreground/30 scale-[1.02] shadow-sm" : "bg-card border-border/40 hover:bg-accent/10"
                    }`}
                    style={{ cursor: "pointer" }}
                    onMouseEnter={() => setActiveIndex(index)}
                    onMouseLeave={() => setActiveIndex(-1)}
                  >
                    <span className="h-2.5 w-2.5 rounded-full shrink-0" style={{ backgroundColor: entry.fill }} />
                    <span className={`font-semibold transition-colors ${isActive ? "text-foreground" : "text-muted-foreground"}`}>{titleCase(entry.name)}</span>
                    <span className="ml-auto font-bold text-foreground">{entry.value} ({pct}%)</span>
                  </div>
                )
              })}
            </div>
          </div>
        </ChartCard>

        <ChartCard title="Severity Breakdown" description="Counts by severity level" empty={!reports.length} className="h-[390px] flex flex-col justify-between pb-2">
          <ResponsiveContainer width="100%" height="100%">
            <BarChart data={severityData} margin={{ top: 20, right: 10, left: -20, bottom: 0 }}>
              <CartesianGrid stroke="#30363D" strokeDasharray="3 3" vertical={false} opacity={0.3} />
              <XAxis dataKey="severity" tickFormatter={titleCase} tick={{ fill: '#888888', fontSize: 12 }} axisLine={false} tickLine={false} />
              <YAxis allowDecimals={false} tick={{ fill: '#888888', fontSize: 12 }} axisLine={false} tickLine={false} />
              <Tooltip content={<CustomTooltip />} cursor={{ fill: 'rgba(255,255,255,0.03)' }} />
              <Bar dataKey="count" radius={[8, 8, 0, 0]}>
                {severityData.map((entry) => {
                  const isHovered = hoveredSeverity === entry.severity
                  return (
                    <Cell
                      key={entry.severity}
                      fill={isHovered ? entry.fill : `${entry.fill}bb`}
                      style={{
                        cursor: "pointer",
                        transform: isHovered ? "scaleY(1.04)" : "none",
                        transformOrigin: "bottom",
                        transition: "all 0.25s cubic-bezier(0.4, 0, 0.2, 1)",
                      }}
                      onMouseEnter={() => setHoveredSeverity(entry.severity)}
                      onMouseLeave={() => setHoveredSeverity(null)}
                    />
                  )
                })}
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
            <>
              {recent.map((report) => (
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
              ))}
              {sortedReports.length > visibleCount && (
                <div className="flex justify-center pt-2">
                  <Button
                    variant="outline"
                    onClick={() => setVisibleCount((prev) => prev + 10)}
                    className="w-full max-w-[200px]"
                  >
                    View More
                  </Button>
                </div>
              )}
            </>
          ) : (
            <p className="rounded-button border bg-background p-4 text-sm text-muted">No Islamabad crisis reports have reached CIRO yet.</p>
          )}
        </CardContent>
      </Card>
    </div>
  )
}
