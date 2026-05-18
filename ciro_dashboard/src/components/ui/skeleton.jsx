import { cn } from "@/lib/utils"

export function Skeleton({ className, ...props }) {
  return <div className={cn("animate-pulse rounded-button bg-surface-variant", className)} {...props} />
}
