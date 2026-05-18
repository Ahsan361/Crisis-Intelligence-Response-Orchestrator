import { useMemo, useState } from "react"
import { ArrowDownUp, Eye, Search, Trash2, Zap } from "lucide-react"
import { useNavigate } from "react-router-dom"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { ConfirmDialog } from "@/components/ui/confirm-dialog"
import { Input, Select } from "@/components/ui/input"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import { ErrorState, LoadingState } from "@/components/shared/state-blocks"
import { SeverityBadge } from "@/components/shared/severity-badge"
import { StatusBadge } from "@/components/shared/status-badge"
import { useAnalyzeReport, useDeleteReport, useReports, useResolveReport } from "@/hooks/useReports"
import { formatDateTime, hasTrace, titleCase, truncateId } from "@/lib/format"
import { severityMeta } from "@/lib/constants"
import { cn } from "@/lib/utils"

const pageSize = 20
const emptyReports = []

export function ReportsPage() {
  const navigate = useNavigate()
  const reportsQuery = useReports()
  const analyze = useAnalyzeReport()
  const resolveReport = useResolveReport()
  const deleteReport = useDeleteReport()
  const [filters, setFilters] = useState({ search: "", status: "", crisis_type: "", source: "", severity: "", from: "", to: "" })
  const [sort, setSort] = useState({ key: "created_at", direction: "desc" })
  const [page, setPage] = useState(1)
  const [selected, setSelected] = useState([])
  const [deleteTarget, setDeleteTarget] = useState(null)
  const reports = reportsQuery.data ?? emptyReports

  const filtered = useMemo(() => {
    const search = filters.search.toLowerCase()
    return reports
      .filter((report) => !filters.status || report.status === filters.status)
      .filter((report) => !filters.crisis_type || report.crisis_type === filters.crisis_type)
      .filter((report) => !filters.source || report.source === filters.source)
      .filter((report) => !filters.severity || report.severity === filters.severity)
      .filter((report) => !filters.from || report.created_at?.slice(0, 10) >= filters.from)
      .filter((report) => !filters.to || report.created_at?.slice(0, 10) <= filters.to)
      .filter((report) => !search || `${report.area_name} ${report.report_text}`.toLowerCase().includes(search))
      .sort((a, b) => {
        const aValue = a[sort.key] ?? ""
        const bValue = b[sort.key] ?? ""
        return sort.direction === "asc" ? String(aValue).localeCompare(String(bValue)) : String(bValue).localeCompare(String(aValue))
      })
  }, [reports, filters, sort])

  const totalPages = Math.max(1, Math.ceil(filtered.length / pageSize))
  const paged = filtered.slice((page - 1) * pageSize, page * pageSize)
  const pendingSelected = selected.map((id) => reports.find((report) => report.id === id)).filter((report) => report?.status === "pending")

  function updateFilter(key, value) {
    setFilters((current) => ({ ...current, [key]: value }))
    setPage(1)
  }

  function toggleSort(key) {
    setSort((current) => ({ key, direction: current.key === key && current.direction === "asc" ? "desc" : "asc" }))
  }

  async function analyzeSelected() {
    if (pendingSelected.length > 3 && !window.confirm(`This will make ${pendingSelected.length} API calls. Continue?`)) return
    for (const report of pendingSelected) {
      await analyze.mutateAsync(report)
    }
    setSelected([])
  }

  if (reportsQuery.isLoading) return <LoadingState label="Loading report table..." />
  if (reportsQuery.isError) return <ErrorState error={reportsQuery.error} onRetry={reportsQuery.refetch} />

  return (
    <div className="space-y-4">
      <Card>
        <CardHeader>
          <CardTitle>Report Filters</CardTitle>
        </CardHeader>
        <CardContent className="grid grid-cols-7 gap-3">
          <div className="col-span-2">
            <Input placeholder="Search area or report text" value={filters.search} onChange={(event) => updateFilter("search", event.target.value)} />
          </div>
          {["status", "crisis_type", "source", "severity"].map((key) => (
            <Select key={key} value={filters[key]} onChange={(event) => updateFilter(key, event.target.value)}>
              <option value="">{titleCase(key)}</option>
              {[...new Set(reports.map((report) => report[key]).filter(Boolean))].map((value) => (
                <option key={value} value={value}>{titleCase(value)}</option>
              ))}
            </Select>
          ))}
          <Input type="date" value={filters.from} onChange={(event) => updateFilter("from", event.target.value)} />
          <Input type="date" value={filters.to} onChange={(event) => updateFilter("to", event.target.value)} />
        </CardContent>
      </Card>

      <Card>
        <CardHeader className="flex flex-row items-center justify-between">
          <CardTitle>Reports</CardTitle>
          <div className="flex items-center gap-2">
            <span className="text-sm text-muted">{filtered.length} records</span>
            <Button size="sm" disabled={!pendingSelected.length || analyze.isPending} onClick={analyzeSelected}>
              <Zap className="h-4 w-4" />
              Analyze Selected
            </Button>
          </div>
        </CardHeader>
        <CardContent className="overflow-x-auto p-0">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead className="w-10"></TableHead>
                {["id", "area_name", "crisis_type", "severity", "source", "status", "reported_by", "created_at"].map((key) => (
                  <TableHead key={key}>
                    <button className="inline-flex items-center gap-1" onClick={() => toggleSort(key)}>
                      {key === "area_name" ? "Area" : key === "reported_by" ? "Reporter" : titleCase(key)}
                      <ArrowDownUp className="h-3 w-3" />
                    </button>
                  </TableHead>
                ))}
                <TableHead>Actions</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {paged.map((report) => {
                const meta = severityMeta[report.severity || "unknown"] ?? severityMeta.unknown
                return (
                  <TableRow key={report.id} className={cn("border-l-4", meta.borderClass)}>
                    <TableCell>
                      <input
                        type="checkbox"
                        disabled={report.status !== "pending"}
                        checked={selected.includes(report.id)}
                        onChange={(event) => setSelected((current) => event.target.checked ? [...current, report.id] : current.filter((id) => id !== report.id))}
                      />
                    </TableCell>
                    <TableCell className="font-mono text-xs">{truncateId(report.id)}</TableCell>
                    <TableCell className="font-medium">{report.area_name || "Unknown Islamabad Sector"}</TableCell>
                    <TableCell>{titleCase(report.crisis_type)}</TableCell>
                    <TableCell><SeverityBadge severity={report.severity} /></TableCell>
                    <TableCell>{titleCase(report.source)}</TableCell>
                    <TableCell><StatusBadge status={report.status} /></TableCell>
                    <TableCell>{report.reported_by || "Unknown"}</TableCell>
                    <TableCell>{formatDateTime(report.created_at)}</TableCell>
                    <TableCell>
                      <div className="flex gap-2">
                        {report.status === "pending" ? <Button size="sm" onClick={() => analyze.mutate(report)} disabled={analyze.isPending}>Analyze</Button> : null}
                        {hasTrace(report) ? <Button size="icon" variant="outline" onClick={() => navigate(`/trace/${report.id}`)}><Eye className="h-4 w-4" /></Button> : null}
                        {report.status === "simulated" ? <Button size="sm" variant="secondary" onClick={() => resolveReport.mutate(report)}>Resolve</Button> : null}
                        <Button size="icon" variant="destructive" onClick={() => setDeleteTarget(report)}><Trash2 className="h-4 w-4" /></Button>
                      </div>
                    </TableCell>
                  </TableRow>
                )
              })}
            </TableBody>
          </Table>
          {!paged.length ? <div className="p-6 text-center text-sm text-muted"><Search className="mx-auto mb-2 h-5 w-5" />No reports match the current filters.</div> : null}
        </CardContent>
        <div className="flex items-center justify-between border-t p-4">
          <Button variant="outline" disabled={page === 1} onClick={() => setPage((value) => value - 1)}>Previous</Button>
          <span className="text-sm text-muted">Page {page} of {totalPages}</span>
          <Button variant="outline" disabled={page === totalPages} onClick={() => setPage((value) => value + 1)}>Next</Button>
        </div>
      </Card>

      <ConfirmDialog
        open={Boolean(deleteTarget)}
        title="Delete report"
        description={`Delete report ${truncateId(deleteTarget?.id)} from CIRO? This cannot be undone.`}
        confirmLabel="Delete"
        loading={deleteReport.isPending}
        onCancel={() => setDeleteTarget(null)}
        onConfirm={() => deleteReport.mutate(deleteTarget.id, { onSuccess: () => setDeleteTarget(null) })}
      />
    </div>
  )
}
