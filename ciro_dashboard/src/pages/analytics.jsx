import { useState } from "react"
import { Bar, BarChart, CartesianGrid, Cell, Legend, Line, LineChart, ResponsiveContainer, Tooltip, XAxis, YAxis } from "recharts"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import { ChartCard } from "@/components/charts/chart-card"
import { ErrorState, LoadingState } from "@/components/shared/state-blocks"
import { useReports } from "@/hooks/useReports"
import { areaHeatmap, countBy, lastThirtyDaysSeries, pipelinePerformance, responseTimeByType } from "@/lib/analytics"
import { titleCase } from "@/lib/format"

const crisisLineColors = {
  flood: "#2F81F7",
  flooding: "#2F81F7",
  accident: "#A371F7",
  heatwave: "#E3B341",
  blockage: "#F78166",
  fire: "#F85149",
  wildfire: "#F85149",
  infrastructure: "#3FB950",
  unknown: "#8B949E",
}

const fallbackLineColors = ["#2F81F7", "#A371F7", "#E3B341", "#F78166", "#3FB950", "#39C5CF", "#8B949E"]

function CustomBarTooltip({ active, payload, label, labelFormatter }) {
  if (active && payload && payload.length) {
    return (
      <div className="rounded-button border bg-card/90 backdrop-blur-md p-3 shadow-xl border-border/50 min-w-[120px]">
        <p className="text-[11px] font-semibold text-muted-foreground uppercase tracking-wider mb-1">
          {labelFormatter ? labelFormatter(label) : label}
        </p>
        {payload.map((entry) => (
          <p key={entry.dataKey} className="text-sm font-bold text-foreground flex items-center gap-1.5">
            <span className="h-2 w-2 rounded-full" style={{ backgroundColor: entry.fill || entry.color }} />
            {entry.name ? `${titleCase(entry.name)}: ` : ""}{entry.value}
          </p>
        ))}
      </div>
    )
  }
  return null
}

function HoverBarChart({ data, dataKey = "value", nameKey = "name", labelFormatter }) {
  const [hovered, setHovered] = useState(null)
  return (
    <BarChart data={data} margin={{ top: 12, right: 10, left: -20, bottom: 0 }}>
      <CartesianGrid stroke="#30363D" strokeDasharray="3 3" vertical={false} opacity={0.3} />
      <XAxis dataKey={nameKey} tickFormatter={titleCase} tick={{ fill: "#888888", fontSize: 12 }} axisLine={false} tickLine={false} />
      <YAxis allowDecimals={false} tick={{ fill: "#888888", fontSize: 12 }} axisLine={false} tickLine={false} />
      <Tooltip content={<CustomBarTooltip labelFormatter={labelFormatter} />} cursor={{ fill: "rgba(255,255,255,0.03)" }} />
      <Bar dataKey={dataKey} radius={[8, 8, 0, 0]}>
        {data.map((entry) => {
          const key = entry[nameKey]
          const isHovered = hovered === key
          return (
            <Cell
              key={key}
              fill={isHovered ? entry.fill : `${entry.fill}bb`}
              style={{
                cursor: "pointer",
                transform: isHovered ? "scaleY(1.04)" : "none",
                transformOrigin: "bottom",
                transition: "all 0.25s cubic-bezier(0.4, 0, 0.2, 1)",
              }}
              onMouseEnter={() => setHovered(key)}
              onMouseLeave={() => setHovered(null)}
            />
          )
        })}
      </Bar>
    </BarChart>
  )
}

export function AnalyticsPage() {
  const reportsQuery = useReports()
  const reports = reportsQuery.data ?? []
  const series = lastThirtyDaysSeries(reports)
  const sources = countBy(reports, "source")
  const areas = areaHeatmap(reports)
  const responseTimes = responseTimeByType(reports)
  const pipeline = pipelinePerformance(reports)
  const crisisTypes = [...new Set(reports.map((report) => report.crisis_type || "unknown"))]

  const [showAllAreas, setShowAllAreas] = useState(false)
  const visibleAreas = showAllAreas ? areas : areas.slice(0, 5)

  const [hoveredBar, setHoveredBar] = useState(null)

  if (reportsQuery.isLoading) return <LoadingState label="Loading analytics..." />
  if (reportsQuery.isError) return <ErrorState error={reportsQuery.error} onRetry={reportsQuery.refetch} />

  return (
    <div className="space-y-4">
      <ChartCard title="Reports Per Day" description="Last 30 days with crisis type breakdown" empty={!reports.length} className="h-80">
        <ResponsiveContainer width="100%" height="100%">
          <LineChart data={series} margin={{ top: 12, right: 10, left: -20, bottom: 0 }}>
            <CartesianGrid stroke="#30363D" strokeDasharray="3 3" vertical={false} opacity={0.3} />
            <XAxis dataKey="date" tick={{ fill: "#888888", fontSize: 11 }} axisLine={false} tickLine={false} />
            <YAxis allowDecimals={false} tick={{ fill: "#888888", fontSize: 12 }} axisLine={false} tickLine={false} />
            <Tooltip
              content={({ active, payload, label }) => {
                if (!active || !payload?.length) return null
                return (
                  <div className="rounded-button border bg-card/90 backdrop-blur-md p-3 shadow-xl border-border/50 min-w-[150px]">
                    <p className="text-[11px] font-semibold text-muted-foreground uppercase tracking-wider mb-1">{label}</p>
                    {payload.map((entry) => (
                      <p key={entry.dataKey} className="text-sm font-bold text-foreground flex items-center gap-1.5">
                        <span className="h-2 w-2 rounded-full" style={{ backgroundColor: entry.stroke }} />
                        {titleCase(entry.dataKey)}: {entry.value}
                      </p>
                    ))}
                  </div>
                )
              }}
              cursor={{ stroke: "rgba(255,255,255,0.1)", strokeWidth: 1 }}
            />
            <Legend
              formatter={(value) => <span style={{ color: "#888888", fontSize: 12 }}>{titleCase(value)}</span>}
              wrapperStyle={{ paddingTop: 8 }}
            />
            <Line type="monotone" dataKey="total" stroke="#E6EDF3" strokeWidth={2} dot={false} strokeOpacity={0.6} />
            {crisisTypes.map((type, index) => (
              <Line
                key={type}
                type="monotone"
                dataKey={type}
                stroke={crisisLineColors[(type || "").toLowerCase().trim()] || fallbackLineColors[index % fallbackLineColors.length]}
                strokeWidth={2}
                dot={false}
              />
            ))}
          </LineChart>
        </ResponsiveContainer>
      </ChartCard>

      <div className="grid grid-cols-2 gap-4">
        <ChartCard title="Source Distribution" description="Signal volume by ingestion source" empty={!sources.length} className="h-72">
          <ResponsiveContainer width="100%" height="100%">
            <HoverBarChart data={sources} dataKey="value" nameKey="name" labelFormatter={titleCase} />
          </ResponsiveContainer>
        </ChartCard>

        <ChartCard title="Response Time Impact" description="Average ETA before vs after CIRO" empty={!responseTimes.length} className="h-72">
          <ResponsiveContainer width="100%" height="100%">
            <BarChart data={responseTimes} margin={{ top: 12, right: 10, left: -20, bottom: 0 }}>
              <CartesianGrid stroke="#30363D" strokeDasharray="3 3" vertical={false} opacity={0.3} />
              <XAxis dataKey="crisisType" tickFormatter={titleCase} tick={{ fill: "#888888", fontSize: 12 }} axisLine={false} tickLine={false} />
              <YAxis tick={{ fill: "#888888", fontSize: 12 }} axisLine={false} tickLine={false} />
              <Tooltip content={<CustomBarTooltip labelFormatter={titleCase} />} cursor={{ fill: "rgba(255,255,255,0.03)" }} />
              <Legend
                formatter={(value) => <span style={{ color: "#888888", fontSize: 12 }}>{titleCase(value)}</span>}
                wrapperStyle={{ paddingTop: 8 }}
              />
              <Bar dataKey="before" name="before" fill="#F85149" radius={[8, 8, 0, 0]}>
                {responseTimes.map((entry) => {
                  const isHovered = hoveredBar === `before-${entry.crisisType}`
                  return (
                    <Cell
                      key={`before-${entry.crisisType}`}
                      fill={isHovered ? "#F85149" : "#F85149bb"}
                      style={{
                        cursor: "pointer",
                        transform: isHovered ? "scaleY(1.04)" : "none",
                        transformOrigin: "bottom",
                        transition: "all 0.25s cubic-bezier(0.4, 0, 0.2, 1)",
                      }}
                      onMouseEnter={() => setHoveredBar(`before-${entry.crisisType}`)}
                      onMouseLeave={() => setHoveredBar(null)}
                    />
                  )
                })}
              </Bar>
              <Bar dataKey="after" name="after" fill="#3FB950" radius={[8, 8, 0, 0]}>
                {responseTimes.map((entry) => {
                  const isHovered = hoveredBar === `after-${entry.crisisType}`
                  return (
                    <Cell
                      key={`after-${entry.crisisType}`}
                      fill={isHovered ? "#3FB950" : "#3FB950bb"}
                      style={{
                        cursor: "pointer",
                        transform: isHovered ? "scaleY(1.04)" : "none",
                        transformOrigin: "bottom",
                        transition: "all 0.25s cubic-bezier(0.4, 0, 0.2, 1)",
                      }}
                      onMouseEnter={() => setHoveredBar(`after-${entry.crisisType}`)}
                      onMouseLeave={() => setHoveredBar(null)}
                    />
                  )
                })}
              </Bar>
            </BarChart>
          </ResponsiveContainer>
        </ChartCard>
      </div>

      <div className="grid grid-cols-2 gap-4">
        <Card>
          <CardHeader><CardTitle>Islamabad Area Heatmap</CardTitle></CardHeader>
          <CardContent className="p-0">
            <Table>
              <TableHeader><TableRow><TableHead>Area</TableHead><TableHead>Reports</TableHead><TableHead>High/Critical</TableHead></TableRow></TableHeader>
              <TableBody>{visibleAreas.map((area) => <TableRow key={area.area}><TableCell>{area.area}</TableCell><TableCell>{area.count}</TableCell><TableCell>{area.urgent}</TableCell></TableRow>)}</TableBody>
            </Table>
            {!areas.length ? <p className="p-4 text-sm text-muted">No Islamabad sector reports available yet.</p> : null}
            {areas.length > 5 && (
              <div className="flex justify-center p-3 border-t border-border/40">
                <Button variant="outline" size="sm" onClick={() => setShowAllAreas((prev) => !prev)} className="w-full max-w-[200px]">
                  {showAllAreas ? "Show Less" : `View More (${areas.length - 5} more)`}
                </Button>
              </div>
            )}
          </CardContent>
        </Card>

        <Card>
          <CardHeader><CardTitle>Pipeline Performance</CardTitle></CardHeader>
          <CardContent className="p-0">
            <Table>
              <TableHeader><TableRow><TableHead>Agent</TableHead><TableHead>Avg Confidence</TableHead><TableHead>Success</TableHead><TableHead>Fallback</TableHead></TableRow></TableHeader>
              <TableBody>{pipeline.map((agent) => <TableRow key={agent.agent}><TableCell>{agent.agent}</TableCell><TableCell>{agent.confidence}%</TableCell><TableCell>{agent.success}</TableCell><TableCell>{agent.fallback}</TableCell></TableRow>)}</TableBody>
            </Table>
            {!pipeline.length ? <p className="p-4 text-sm text-muted">Agent confidence appears after reports are analyzed.</p> : null}
          </CardContent>
        </Card>
      </div>
    </div>
  )
}
