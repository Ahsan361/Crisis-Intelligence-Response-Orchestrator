export const severityMeta = {
  critical: {
    label: "Critical",
    value: "critical",
    className: "border-critical/40 bg-critical/10 text-critical",
    dotClass: "bg-critical",
    borderClass: "border-l-critical",
    chartColor: "#F85149",
  },
  high: {
    label: "High",
    value: "high",
    className: "border-warning/40 bg-warning/10 text-warning",
    dotClass: "bg-warning",
    borderClass: "border-l-warning",
    chartColor: "#E3B341",
  },
  medium: {
    label: "Medium",
    value: "medium",
    className: "border-primary/40 bg-primary/10 text-primary",
    dotClass: "bg-primary",
    borderClass: "border-l-primary",
    chartColor: "#2F81F7",
  },
  low: {
    label: "Low",
    value: "low",
    className: "border-secondary/40 bg-secondary/10 text-secondary",
    dotClass: "bg-secondary",
    borderClass: "border-l-secondary",
    chartColor: "#3FB950",
  },
  unknown: {
    label: "Unknown",
    value: "unknown",
    className: "border-muted/40 bg-muted/10 text-muted",
    dotClass: "bg-muted",
    borderClass: "border-l-muted",
    chartColor: "#8B949E",
  },
}

export const statusMeta = {
  pending: { label: "Pending", value: "pending", className: "border-warning/40 bg-warning/10 text-warning" },
  analyzing: { label: "Analyzing", value: "analyzing", className: "border-primary/40 bg-primary/10 text-primary" },
  simulated: { label: "Simulated", value: "simulated", className: "border-secondary/40 bg-secondary/10 text-secondary" },
  analyzed: { label: "Analyzed", value: "analyzed", className: "border-secondary/40 bg-secondary/10 text-secondary" },
  resolved: { label: "Resolved", value: "resolved", className: "border-muted/40 bg-muted/10 text-muted" },
  failed: { label: "Failed", value: "failed", className: "border-critical/40 bg-critical/10 text-critical" },
}

export const agentColors = {
  Orchestrator: "#2F81F7",
  SignalCollector: "#A371F7",
  CrisisDetector: "#F85149",
  ReasoningAnalyzer: "#E3B341",
  ActionPlanner: "#3FB950",
  Simulator: "#39C5CF",
}

export const crisisTypeColors = ["#2F81F7", "#3FB950", "#F85149", "#E3B341", "#8B949E"]
export const apiBaseUrl = import.meta.env.VITE_API_BASE_URL ?? "http://localhost:8000"
