import { Outlet } from "react-router-dom"
import { Header } from "@/components/layout/header"
import { Sidebar } from "@/components/layout/sidebar"

export function AppShell() {
  return (
    <div className="min-h-screen bg-background text-foreground">
      <Sidebar />
      <div className="pl-60">
        <Header />
        <main className="mx-auto max-w-shell p-4">
          <Outlet />
        </main>
      </div>
    </div>
  )
}
