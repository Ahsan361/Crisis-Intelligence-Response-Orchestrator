import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { EmptyState } from "@/components/shared/state-blocks"

export function ChartCard({ title, description, empty, children }) {
  return (
    <Card>
      <CardHeader>
        <CardTitle>{title}</CardTitle>
        {description ? <CardDescription>{description}</CardDescription> : null}
      </CardHeader>
      <CardContent>
        {empty ? (
          <EmptyState title="No chart data" description="CIRO will populate this view as reports arrive from Islamabad sources." />
        ) : (
          <div className="h-72">{children}</div>
        )}
      </CardContent>
    </Card>
  )
}
