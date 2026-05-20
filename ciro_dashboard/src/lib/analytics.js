import { crisisTypeColors, severityMeta } from "@/lib/constants"
import { isActiveReport, isResolved, isToday, numericValue } from "@/lib/format"

export function dashboardStats(reports) {
  return {
    totalReports: reports.length,
    activeCrises: reports.filter(isActiveReport).length,
    resolvedToday: reports.filter((report) => isResolved(report) && isToday(report.created_at)).length,
    criticalAlerts: reports.filter((report) => report.severity === "critical" && !isResolved(report)).length,
  }
}

export function systemStatus(reports) {
  const activeReports = reports.filter(isActiveReport)
  if (activeReports.some((report) => report.severity === "critical")) {
    return { level: "red", title: "Critical response posture", description: "Active critical incidents require command attention.", className: "border-critical/50 bg-critical/10 text-critical" }
  }
  if (activeReports.some((report) => report.severity === "high")) {
    return { level: "amber", title: "Elevated response posture", description: "High severity incidents are active across the city.", className: "border-warning/50 bg-warning/10 text-warning" }
  }
  return { level: "green", title: "System stable", description: "No active high or critical incidents detected.", className: "border-secondary/50 bg-secondary/10 text-secondary" }
}

export function countBy(reports, key, fallback = "unknown") {
  const counts = new Map()
  reports.forEach((report) => {
    const value = report[key] || fallback
    counts.set(value, (counts.get(value) ?? 0) + 1)
  })

  const crisisColorsMap = {
    flood: "#2F81F7",           // Blue
    flooding: "#2F81F7",        // Blue
    accident: "#A371F7",        // Purple
    heatwave: "#E3B341",        // Yellow/Amber
    blockage: "#F78166",        // Orange (distinct from fire/red)
    fire: "#F85149",            // Red
    wildfire: "#F85149",        // Red
    infrastructure: "#3FB950",  // Green
    unknown: "#8B949E",         // Gray
  }

  const sourceColorsMap = {
    social_media: "#39C5CF",    // Cyan/Teal
    twitter: "#39C5CF",         // Cyan/Teal
    manual: "#8B949E",          // Gray
    email: "#2F81F7",           // Blue
    phone: "#A371F7",           // Purple
    telephony: "#A371F7",       // Purple
    api: "#3FB950",             // Green
  }

  const colorMap = key === "source" ? sourceColorsMap : crisisColorsMap

  return Array.from(counts, ([name, value], index) => {
    const normalized = (name || "").toLowerCase().trim()
    const fill = colorMap[normalized] || crisisTypeColors[index % crisisTypeColors.length]
    return { name, value, fill }
  })
}

export function severityBreakdown(reports) {
  return ["critical", "high", "medium", "low", "unknown"].map((severity) => ({
    severity,
    count: reports.filter((report) => (report.severity || "unknown") === severity).length,
    fill: severityMeta[severity].chartColor,
  }))
}

export function lastThirtyDaysSeries(reports) {
  const days = []
  const today = new Date()
  for (let index = 29; index >= 0; index -= 1) {
    const date = new Date(today)
    date.setDate(today.getDate() - index)
    const key = date.toISOString().slice(0, 10)
    days.push({ date: key, total: 0 })
  }

  reports.forEach((report) => {
    const key = report.created_at?.slice(0, 10)
    const bucket = days.find((day) => day.date === key)
    if (!bucket) return
    const crisisType = report.crisis_type || "unknown"
    bucket.total += 1
    bucket[crisisType] = (bucket[crisisType] ?? 0) + 1
  })

  return days
}

export function areaHeatmap(reports) {
  const rows = new Map()
  reports.forEach((report) => {
    const area = report.area_name || "Unknown Islamabad Sector"
    const current = rows.get(area) ?? { area, count: 0, urgent: 0 }
    current.count += 1
    if (report.severity === "critical" || report.severity === "high") current.urgent += 1
    rows.set(area, current)
  })
  return Array.from(rows.values()).sort((a, b) => b.count - a.count)
}

function getSimulationMetric(simulation, candidates, routeKey) {
  if (routeKey && simulation?.[routeKey]) {
    const value = numericValue(simulation[routeKey]?.eta_minutes)
    if (value !== null) return value
  }
  for (const key of candidates) {
    const value = numericValue(simulation?.[key])
    if (value !== null) return value
  }
  return null
}

export function responseTimeByType(reports) {
  const groups = new Map()
  reports.forEach((report) => {
    const simulation = report.simulation_result
    const before = getSimulationMetric(simulation, ["eta_before_minutes", "before_eta_minutes", "eta_before"], "before_route")
    const after = getSimulationMetric(simulation, ["eta_after_minutes", "after_eta_minutes", "eta_after"], "after_route")
    if (before === null || after === null) return
    const type = report.crisis_type || "unknown"
    const current = groups.get(type) ?? { crisisType: type, beforeTotal: 0, afterTotal: 0, count: 0 }
    current.beforeTotal += before
    current.afterTotal += after
    current.count += 1
    groups.set(type, current)
  })

  return Array.from(groups.values()).map((item) => ({
    crisisType: item.crisisType,
    before: Math.round(item.beforeTotal / item.count),
    after: Math.round(item.afterTotal / item.count),
    saved: Math.round((item.beforeTotal - item.afterTotal) / item.count),
  }))
}

export function traceEntries(report) {
  const trace = report?.agent_trace
  if (Array.isArray(trace)) return trace
  if (trace && typeof trace === "object") return Object.values(trace).filter((value) => value && typeof value === "object")
  return []
}

export function pipelinePerformance(reports) {
  const groups = new Map()
  reports.flatMap(traceEntries).forEach((entry) => {
    const agent = entry.agent || entry.agent_name || "UnknownAgent"
    const current = groups.get(agent) ?? { agent, confidenceTotal: 0, confidenceCount: 0, success: 0, fallback: 0 }
    const confidence = numericValue(entry.confidence)
    if (confidence !== null) {
      current.confidenceTotal += confidence
      current.confidenceCount += 1
    }
    if (entry.fallback || entry.status === "fallback") current.fallback += 1
    else current.success += 1
    groups.set(agent, current)
  })

  return Array.from(groups.values()).map((item) => ({
    agent: item.agent,
    confidence: item.confidenceCount ? Math.round(item.confidenceTotal / item.confidenceCount) : 0,
    success: item.success,
    fallback: item.fallback,
  }))
}
