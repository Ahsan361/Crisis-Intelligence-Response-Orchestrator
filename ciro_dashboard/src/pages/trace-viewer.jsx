import { Download, Megaphone } from "lucide-react"
import { useMemo } from "react"
import { useNavigate, useParams } from "react-router-dom"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import { ErrorState, LoadingState, EmptyState } from "@/components/shared/state-blocks"
import { SeverityBadge } from "@/components/shared/severity-badge"
import { StatusBadge } from "@/components/shared/status-badge"
import { useReport, useReports } from "@/hooks/useReports"
import { traceEntries } from "@/lib/analytics"
import { formatDateTime, numericValue, percent, titleCase, truncateId } from "@/lib/format"
import { cn } from "@/lib/utils"

const agentToneClasses = {
  Orchestrator: "border-l-primary text-primary before:border-primary",
  SignalCollector: "border-l-[#A371F7] text-[#A371F7] before:border-[#A371F7]",
  CrisisDetector: "border-l-critical text-critical before:border-critical",
  ReasoningAnalyzer: "border-l-warning text-warning before:border-warning",
  ActionPlanner: "border-l-secondary text-secondary before:border-secondary",
  Simulator: "border-l-[#39C5CF] text-[#39C5CF] before:border-[#39C5CF]",
}

function simulationValue(simulation, keys) {
  for (const key of keys) {
    const value = numericValue(simulation?.[key])
    if (value !== null) return value
  }
  return null
}

export function TraceViewerPage() {
  const params = useParams()
  const navigate = useNavigate()
  const reportsQuery = useReports()
  const latestTraceReport = useMemo(() => (reportsQuery.data ?? []).find((report) => traceEntries(report).length), [reportsQuery.data])
  const targetId = params.id === "latest" ? latestTraceReport?.id : params.id
  const reportQuery = useReport(targetId)
  const report = reportQuery.data
  const simulation = report?.simulation_result ?? {}
  const trace = traceEntries(report)
  const before = simulationValue(simulation, ["eta_before_minutes", "before_eta_minutes", "eta_before"])
  const after = simulationValue(simulation, ["eta_after_minutes", "after_eta_minutes", "eta_after"])
  const actions = simulation.action_plan || simulation.actions || []
  const alerts = simulation.alerts_dispatched || simulation.alerts || []
  const ticketId = simulation.emergency_ticket_id || simulation.ticket_id || simulation.ticket?.id || "Unavailable"

  function exportJson() {
    const blob = new Blob([JSON.stringify(report, null, 2)], { type: "application/json" })
    const url = URL.createObjectURL(blob)
    const link = document.createElement("a")
    link.href = url
    link.download = `ciro-trace-${report.id}.json`
    link.click()
    URL.revokeObjectURL(url)
  }

  if (params.id === "latest" && reportsQuery.isLoading) return <LoadingState label="Finding latest trace..." />
  if (!targetId) return <EmptyState title="No analyzed trace found" description="Analyze a pending Islamabad report, then return to the Trace Viewer." />
  if (reportQuery.isLoading) return <LoadingState label="Loading pipeline trace..." />
  if (reportQuery.isError) return <ErrorState error={reportQuery.error} onRetry={reportQuery.refetch} />
  if (!report) return <EmptyState title="Trace unavailable" description="CIRO could not find this report." />

  return (
    <div className="space-y-4">
      <Card>
        <CardContent className="flex items-center justify-between gap-4">
          <div>
            <p className="font-mono text-xs text-muted">{truncateId(report.id)}</p>
            <h2 className="mt-1 text-2xl font-bold text-foreground">{report.area_name || "Unknown Islamabad Sector"}</h2>
            <p className="mt-1 text-sm text-muted">{titleCase(report.crisis_type)} · Confidence {percent(report.crisis_confidence)} · {report.detected_language || "Unknown language"}</p>
            <p className="mt-1 text-xs text-muted">Created {formatDateTime(report.created_at)} · Analyzed {formatDateTime(report.analyzed_at || report.updated_at)}</p>
          </div>
          <div className="flex items-center gap-2">
            <SeverityBadge severity={report.severity} />
            <StatusBadge status={report.status} />
            <Button onClick={exportJson}><Download className="h-4 w-4" />Export JSON</Button>
            <Button variant="outline" onClick={() => navigate("/reports")}>Reports</Button>
          </div>
        </CardContent>
      </Card>

      <div className="grid grid-cols-3 gap-4">
        <Card>
          <CardHeader><CardTitle>Before Simulation</CardTitle></CardHeader>
          <CardContent><p className="text-3xl font-bold text-warning">{before ?? "—"} min</p><p className="mt-1 text-sm text-muted">Baseline emergency ETA</p></CardContent>
        </Card>
        <Card>
          <CardHeader><CardTitle>After CIRO</CardTitle></CardHeader>
          <CardContent><p className="text-3xl font-bold text-secondary">{after ?? "—"} min</p><p className="mt-1 text-sm text-muted">{before !== null && after !== null ? `${Math.max(0, before - after)} minutes saved` : "Awaiting simulation metrics"}</p></CardContent>
        </Card>
        <Card>
          <CardHeader><CardTitle>Emergency Ticket</CardTitle></CardHeader>
          <CardContent><p className="font-mono text-lg font-bold text-foreground">{ticketId}</p><p className="mt-1 text-sm text-muted">Status: {titleCase(simulation.status || report.status)}</p></CardContent>
        </Card>
      </div>

      <Card>
        <CardHeader><CardTitle>Response Actions</CardTitle></CardHeader>
        <CardContent className="p-0">
          <Table>
            <TableHeader><TableRow><TableHead>Type</TableHead><TableHead>Description</TableHead><TableHead>Priority</TableHead><TableHead>Assigned To</TableHead></TableRow></TableHeader>
            <TableBody>
              {actions.map((action, index) => (
                <TableRow key={`${action.type}-${index}`}>
                  <TableCell>{titleCase(action.type)}</TableCell>
                  <TableCell>{action.description || "No action description provided"}</TableCell>
                  <TableCell><SeverityBadge severity={String(action.priority || "unknown").toLowerCase()} /></TableCell>
                  <TableCell>{action.assigned_to || action.assignedTo || "Command center"}</TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
          {!actions.length ? <p className="p-4 text-sm text-muted">No action plan has been recorded for this trace.</p> : null}
        </CardContent>
      </Card>

      <div className="grid grid-cols-[1fr_2fr] gap-4">
        <Card>
          <CardHeader><CardTitle>Alerts Dispatched</CardTitle></CardHeader>
          <CardContent className="space-y-2">
            {alerts.length ? alerts.map((alert, index) => (
              <div key={`${alert}-${index}`} className="flex gap-2 rounded-button border bg-background p-3 text-sm">
                <Megaphone className="h-4 w-4 text-primary" />
                <span>{alert}</span>
              </div>
            )) : <p className="text-sm text-muted">No dispatched alerts are attached to this simulation.</p>}
          </CardContent>
        </Card>

        <Card>
          <CardHeader><CardTitle>Pipeline Reasoning Timeline</CardTitle></CardHeader>
          <CardContent className="space-y-4">
            {trace.length ? trace.map((entry, index) => {
              const agent = entry.agent || entry.agent_name || "UnknownAgent"
              return (
                <div
                  key={`${agent}-${index}`}
                  className={cn(
                    "relative border-l pl-4 before:absolute before:-left-1.5 before:top-1 before:h-3 before:w-3 before:rounded-full before:border before:bg-background",
                    agentToneClasses[agent] || "border-l-muted text-muted before:border-muted",
                  )}
                >
                  <div className="flex items-center justify-between">
                    <h3 className="font-semibold text-foreground">{agent}</h3>
                    <span className="text-xs text-muted">{formatDateTime(entry.timestamp)}</span>
                  </div>
                  <p className="mt-1 text-xs font-semibold">Confidence {percent(entry.confidence)}</p>
                  <p className="mt-2 text-sm leading-6 text-foreground">{entry.decision || entry.decision_text || "No decision text recorded."}</p>
                  <p className="mt-2 text-xs text-muted">Input: {entry.input_summary || JSON.stringify(entry.input ?? "Unavailable")}</p>
                  <p className="mt-1 text-xs text-muted">Output: {entry.output_summary || JSON.stringify(entry.output ?? "Unavailable")}</p>
                </div>
              )
            }) : <p className="text-sm text-muted">No agent trace entries are attached to this report.</p>}
          </CardContent>
        </Card>
      </div>
    </div>
  )
}
