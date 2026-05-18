import { Bar, BarChart, CartesianGrid, Cell, Legend, Line, LineChart, ResponsiveContainer, Tooltip, XAxis, YAxis } from "recharts"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import { ChartCard } from "@/components/charts/chart-card"
import { ErrorState, LoadingState } from "@/components/shared/state-blocks"
import { useReports } from "@/hooks/useReports"
import { areaHeatmap, countBy, lastThirtyDaysSeries, pipelinePerformance, responseTimeByType } from "@/lib/analytics"
import { crisisTypeColors } from "@/lib/constants"
import { titleCase } from "@/lib/format"

export function AnalyticsPage() {
  const reportsQuery = useReports()
  const reports = reportsQuery.data ?? []
  const series = lastThirtyDaysSeries(reports)
  const sources = countBy(reports, "source")
  const areas = areaHeatmap(reports)
  const responseTimes = responseTimeByType(reports)
  const pipeline = pipelinePerformance(reports)
  const crisisTypes = [...new Set(reports.map((report) => report.crisis_type || "unknown"))]

  if (reportsQuery.isLoading) return <LoadingState label="Loading analytics..." />
  if (reportsQuery.isError) return <ErrorState error={reportsQuery.error} onRetry={reportsQuery.refetch} />

  return (
    <div className="space-y-4">
      <ChartCard title="Reports Per Day" description="Last 30 days with crisis type breakdown" empty={!reports.length}>
        <ResponsiveContainer width="100%" height="100%">
          <LineChart data={series}>
            <CartesianGrid stroke="#30363D" vertical={false} />
            <XAxis dataKey="date" tick={{ fontSize: 11 }} />
            <YAxis allowDecimals={false} />
            <Tooltip />
            <Legend />
            <Line type="monotone" dataKey="total" stroke="#E6EDF3" strokeWidth={2} dot={false} />
            {crisisTypes.map((type, index) => <Line key={type} type="monotone" dataKey={type} stroke={crisisTypeColors[index % crisisTypeColors.length]} strokeWidth={2} dot={false} />)}
          </LineChart>
        </ResponsiveContainer>
      </ChartCard>

      <div className="grid grid-cols-2 gap-4">
        <ChartCard title="Source Distribution" description="Signal volume by ingestion source" empty={!sources.length}>
          <ResponsiveContainer width="100%" height="100%">
            <BarChart data={sources}>
              <XAxis dataKey="name" tickFormatter={titleCase} />
              <YAxis allowDecimals={false} />
              <Tooltip labelFormatter={titleCase} />
              <Bar dataKey="value" radius={[8, 8, 0, 0]}>
                {sources.map((entry) => <Cell key={entry.name} fill={entry.fill} />)}
              </Bar>
            </BarChart>
          </ResponsiveContainer>
        </ChartCard>

        <ChartCard title="Response Time Impact" description="Average ETA before vs after CIRO" empty={!responseTimes.length}>
          <ResponsiveContainer width="100%" height="100%">
            <BarChart data={responseTimes}>
              <XAxis dataKey="crisisType" tickFormatter={titleCase} />
              <YAxis />
              <Tooltip labelFormatter={titleCase} />
              <Legend />
              <Bar dataKey="before" fill="#E3B341" radius={[8, 8, 0, 0]} />
              <Bar dataKey="after" fill="#3FB950" radius={[8, 8, 0, 0]} />
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
              <TableBody>{areas.map((area) => <TableRow key={area.area}><TableCell>{area.area}</TableCell><TableCell>{area.count}</TableCell><TableCell>{area.urgent}</TableCell></TableRow>)}</TableBody>
            </Table>
            {!areas.length ? <p className="p-4 text-sm text-muted">No Islamabad sector reports available yet.</p> : null}
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
