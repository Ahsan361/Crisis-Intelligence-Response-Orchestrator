import { cn } from "@/lib/utils"

export function Card({ className, ...props }) {
  return <div className={cn("rounded-card border bg-surface", className)} {...props} />
}

export function CardHeader({ className, ...props }) {
  return <div className={cn("space-y-1.5 border-b px-4 py-3", className)} {...props} />
}

export function CardTitle({ className, ...props }) {
  return <h2 className={cn("text-base font-semibold text-foreground", className)} {...props} />
}

export function CardDescription({ className, ...props }) {
  return <p className={cn("text-sm text-muted", className)} {...props} />
}

export function CardContent({ className, ...props }) {
  return <div className={cn("p-4", className)} {...props} />
}
