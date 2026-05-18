export function titleCase(value) {
  if (!value) return "Unknown"

  return String(value)
    .replace(/_/g, " ")
    .replace(/\s+/g, " ")
    .trim()
    .replace(/\b\w/g, (letter) => letter.toUpperCase())
}

export function truncateId(id) {
  if (!id) return "Unavailable"
  return id.length > 12 ? `${id.slice(0, 8)}...${id.slice(-4)}` : id
}

export function formatDateTime(value) {
  if (!value) return "Unavailable"
  const date = new Date(value)
  if (Number.isNaN(date.getTime())) return "Unavailable"
  return new Intl.DateTimeFormat(undefined, { dateStyle: "medium", timeStyle: "short" }).format(date)
}

export function timeAgo(value) {
  if (!value) return "Unavailable"
  const date = new Date(value)
  const diffSeconds = Math.floor((Date.now() - date.getTime()) / 1000)
  if (Number.isNaN(diffSeconds)) return "Unavailable"
  if (diffSeconds < 60) return "Just now"
  const minutes = Math.floor(diffSeconds / 60)
  if (minutes < 60) return `${minutes}m ago`
  const hours = Math.floor(minutes / 60)
  if (hours < 24) return `${hours}h ago`
  return `${Math.floor(hours / 24)}d ago`
}

export function isToday(value) {
  if (!value) return false
  const date = new Date(value)
  const today = new Date()
  return date.getFullYear() === today.getFullYear() && date.getMonth() === today.getMonth() && date.getDate() === today.getDate()
}

export function isActiveReport(report) {
  return report.status === "pending" || report.status === "analyzing"
}

export function isResolved(report) {
  return report.status === "resolved"
}

export function hasTrace(report) {
  const trace = report.agent_trace
  return Array.isArray(trace) ? trace.length > 0 : Boolean(trace)
}

export function numericValue(value) {
  if (typeof value === "number" && Number.isFinite(value)) return value
  if (typeof value === "string") {
    const parsed = Number.parseFloat(value)
    return Number.isFinite(parsed) ? parsed : null
  }
  return null
}

export function percent(value) {
  const numeric = numericValue(value)
  return numeric === null ? "Unavailable" : `${Math.round(numeric)}%`
}
