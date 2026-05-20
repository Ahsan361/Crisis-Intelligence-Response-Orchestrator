import { BarChart3, DatabaseZap, GitBranch, LayoutDashboard, Moon, Shield, Sun, TableProperties } from "lucide-react"
import { NavLink } from "react-router-dom"
import { Button } from "@/components/ui/button"
import { useBackendStatus } from "@/hooks/useBackendStatus"
import { useTheme } from "@/lib/theme"
import { cn } from "@/lib/utils"

const navItems = [
  { label: "Dashboard", href: "/", icon: LayoutDashboard },
  { label: "Reports", href: "/reports", icon: TableProperties },
  { label: "Trace Viewer", href: "/trace/latest", icon: GitBranch },
  { label: "Analytics", href: "/analytics", icon: BarChart3 },
  { label: "Seeder Control", href: "/seeder", icon: DatabaseZap },
]

export function Sidebar() {
  const { theme, toggleTheme } = useTheme()
  const backend = useBackendStatus()
  const live = backend.data === true

  return (
    <aside className="fixed inset-y-0 left-0 z-30 flex w-60 flex-col border-r bg-surface">
      <div className="flex h-16 items-center gap-3 border-b px-4">
        <div className="flex h-10 w-10 items-center justify-center rounded-card border border-primary/40 bg-primary/10 text-primary">
          <Shield className="h-5 w-5" />
        </div>
        <div>
          <p className="text-lg font-bold leading-none text-foreground">CIRO</p>
          <p className="mt-1 text-xs text-muted">Admin Command</p>
        </div>
      </div>

      <nav className="flex-1 space-y-1 p-3">
        {navItems.map((item) => (
          <NavLink
            key={item.href}
            to={item.href}
            className={({ isActive }) =>
              cn(
                "flex items-center gap-3 rounded-button border border-transparent px-3 py-2.5 text-sm font-semibold text-muted transition-colors hover:bg-surface-variant hover:text-foreground",
                isActive && "border-divider bg-surface-variant text-foreground",
              )
            }
          >
            <item.icon className="h-4 w-4" />
            {item.label}
          </NavLink>
        ))}
      </nav>

      <div className="space-y-3 border-t p-3">
        <div className="flex items-center justify-between rounded-button border bg-background px-3 py-2">
          <div className="flex items-center gap-2 text-sm font-semibold">
            <span className={cn("h-2.5 w-2.5 rounded-full", live ? "animate-pulse-live bg-secondary" : "bg-critical")} />
            {live ? "Live" : "Offline"}
          </div>
          <span className="text-xs text-muted">Backend</span>
        </div>
        <Button variant="outline" className="w-full" onClick={toggleTheme}>
          {theme === "dark" ? <Moon className="h-4 w-4" /> : <Sun className="h-4 w-4" />}
          {theme === "dark" ? "Dark Theme" : "Light Theme"}
        </Button>
      </div>
    </aside>
  )
}
