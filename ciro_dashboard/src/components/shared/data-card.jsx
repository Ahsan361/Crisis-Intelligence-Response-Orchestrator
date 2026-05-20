import { Card, CardContent } from "@/components/ui/card"
import { cn } from "@/lib/utils"

export function DataCard({ title, value, description, icon: Icon, tone = "primary" }) {
  const toneClass = {
    primary: "border-primary/35 bg-primary/10 text-primary",
    secondary: "border-secondary/35 bg-secondary/10 text-secondary",
    warning: "border-warning/35 bg-warning/10 text-warning",
    critical: "border-critical/35 bg-critical/10 text-critical",
  }[tone]

  return (
    <Card>
      <CardContent className="flex items-center justify-between gap-4">
        <div>
          <p className="text-sm font-medium text-muted">{title}</p>
          <p className="mt-2 text-3xl font-bold text-foreground">{value}</p>
          <p className="mt-1 text-xs text-muted">{description}</p>
        </div>
        {Icon ? (
          <div className={cn("flex h-11 w-11 items-center justify-center rounded-button border", toneClass)}>
            <Icon className="h-5 w-5" />
          </div>
        ) : null}
      </CardContent>
    </Card>
  )
}
