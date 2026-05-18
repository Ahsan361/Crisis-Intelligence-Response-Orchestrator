import { RefreshCw } from "lucide-react"
import { useLocation } from "react-router-dom"
import { useQueryClient } from "@tanstack/react-query"
import { Button } from "@/components/ui/button"
import { useBackendStatus } from "@/hooks/useBackendStatus"
import { formatDateTime } from "@/lib/format"
import { cn } from "@/lib/utils"

const titles = {
  "/": "Dashboard",
  "/reports": "Reports",
  "/analytics": "Analytics",
  "/seeder": "Seeder Control",
}

export function Header() {
  const location = useLocation()
  const queryClient = useQueryClient()
  const backend = useBackendStatus()
  const title = location.pathname.startsWith("/trace") ? "Trace Viewer" : titles[location.pathname] || "CIRO"
  const live = backend.data === true

  return (
    <header className="sticky top-0 z-20 border-b bg-background/95 backdrop-blur-sm">
      <div className="mx-auto flex h-16 max-w-shell items-center justify-between px-4">
        <div>
          <h1 className="text-xl font-bold text-foreground">{title}</h1>
          <p className="text-xs text-muted">Last updated {formatDateTime(new Date().toISOString())}</p>
        </div>
        <div className="flex items-center gap-3">
          <div className="flex items-center gap-2 rounded-button border bg-surface px-3 py-2 text-sm font-semibold">
            <span className={cn("h-2.5 w-2.5 rounded-full", live ? "bg-secondary" : "bg-critical")} />
            {live ? "Backend reachable" : "Backend offline"}
          </div>
          <Button variant="outline" onClick={() => queryClient.invalidateQueries()}>
            <RefreshCw className="h-4 w-4" />
            Refresh
          </Button>
        </div>
      </div>
    </header>
  )
}
