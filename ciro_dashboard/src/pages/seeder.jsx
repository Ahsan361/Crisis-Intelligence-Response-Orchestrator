import { DatabaseZap, Play, Square } from "lucide-react"
import { useState } from "react"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { ErrorState, LoadingState } from "@/components/shared/state-blocks"
import { useSeederStatus, useStartSeeder, useStopSeeder, useSeedNow } from "@/hooks/useSeeder"
import { formatDateTime } from "@/lib/format"

export function SeederPage() {
  const [interval, setInterval] = useState(4)
  const statusQuery = useSeederStatus()
  const startSeeder = useStartSeeder()
  const stopSeeder = useStopSeeder()
  const seedNow = useSeedNow()
  const status = statusQuery.data
  const running = status?.running || status?.status === "running"
  const logs = status?.logs || []

  if (statusQuery.isLoading) return <LoadingState label="Loading seeder status..." />
  if (statusQuery.isError) return <ErrorState error={statusQuery.error} onRetry={statusQuery.refetch} title="Seeder endpoint unavailable" />

  return (
    <div className="space-y-4">
      <div className="grid grid-cols-3 gap-4">
        <Card>
          <CardContent className="flex items-center justify-between">
            <div><p className="text-sm text-muted">Seeder Status</p><p className={running ? "mt-2 text-2xl font-bold text-secondary" : "mt-2 text-2xl font-bold text-muted"}>{running ? "Running" : "Stopped"}</p></div>
            <DatabaseZap className="h-8 w-8 text-primary" />
          </CardContent>
        </Card>
        <Card>
          <CardContent><p className="text-sm text-muted">Total Reports Seeded</p><p className="mt-2 text-2xl font-bold text-foreground">{status?.total_seeded ?? status?.count ?? 0}</p></CardContent>
        </Card>
        <Card>
          <CardContent><p className="text-sm text-muted">Last Updated</p><p className="mt-2 text-lg font-bold text-foreground">{formatDateTime(status?.last_updated || new Date().toISOString())}</p></CardContent>
        </Card>
      </div>

      <Card>
        <CardHeader><CardTitle>Seeder Controls</CardTitle></CardHeader>
        <CardContent className="space-y-5">
          <div>
            <div className="mb-2 flex items-center justify-between">
              <label className="text-sm font-semibold text-foreground">Interval</label>
              <span className="text-sm text-muted">{interval} minutes</span>
            </div>
            <input className="w-full accent-[#2F81F7]" type="range" min="2" max="8" value={interval} onChange={(event) => setInterval(Number(event.target.value))} />
          </div>
          <div className="flex gap-2">
            <Button disabled={running || startSeeder.isPending} onClick={() => startSeeder.mutate(interval)}><Play className="h-4 w-4" />Start Seeder</Button>
            <Button variant="warning" disabled={!running || stopSeeder.isPending} onClick={() => stopSeeder.mutate()}><Square className="h-4 w-4" />Stop Seeder</Button>
            <Button variant="outline" disabled={seedNow.isPending} onClick={() => seedNow.mutate()}><DatabaseZap className="h-4 w-4" />Seed Now</Button>
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardHeader><CardTitle>Live Seeder Log</CardTitle></CardHeader>
        <CardContent className="space-y-2">
          {logs.length ? logs.slice(0, 20).map((log, index) => (
            <div key={log.id || index} className="rounded-button border bg-background p-3 text-sm">
              <span className="font-semibold text-foreground">{formatDateTime(log.created_at)}</span>
              <span className="ml-2 text-muted">{log.message}</span>
            </div>
          )) : <p className="rounded-button border bg-background p-4 text-sm text-muted">No seeder events are exposed by the backend yet.</p>}
        </CardContent>
      </Card>
    </div>
  )
}
