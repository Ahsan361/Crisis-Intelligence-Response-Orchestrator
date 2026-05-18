import { AlertCircle, Inbox, Loader2 } from "lucide-react"
import { Button } from "@/components/ui/button"
import { Card, CardContent } from "@/components/ui/card"

export function LoadingState({ label = "Loading CIRO data..." }) {
  return (
    <Card>
      <CardContent className="flex min-h-40 items-center justify-center gap-3 text-muted">
        <Loader2 className="h-5 w-5 animate-spin text-primary" />
        <span className="text-sm font-medium">{label}</span>
      </CardContent>
    </Card>
  )
}

export function EmptyState({ title = "No records found", description = "CIRO has no matching records for this view." }) {
  return (
    <Card>
      <CardContent className="flex min-h-40 flex-col items-center justify-center text-center">
        <Inbox className="h-8 w-8 text-muted" />
        <h3 className="mt-3 text-sm font-semibold text-foreground">{title}</h3>
        <p className="mt-1 max-w-md text-sm text-muted">{description}</p>
      </CardContent>
    </Card>
  )
}

export function ErrorState({ title = "Unable to load data", error, onRetry }) {
  return (
    <Card className="border-critical/40">
      <CardContent className="flex min-h-40 flex-col items-center justify-center text-center">
        <AlertCircle className="h-8 w-8 text-critical" />
        <h3 className="mt-3 text-sm font-semibold text-foreground">{title}</h3>
        <p className="mt-1 max-w-xl text-sm text-muted">{error?.message || "The FastAPI backend is unavailable or returned an error."}</p>
        {onRetry ? (
          <Button className="mt-4" variant="outline" onClick={onRetry}>
            Retry
          </Button>
        ) : null}
      </CardContent>
    </Card>
  )
}
