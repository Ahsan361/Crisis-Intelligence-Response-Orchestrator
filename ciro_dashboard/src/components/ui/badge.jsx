import { cva } from "class-variance-authority"
import { cn } from "@/lib/utils"

const badgeVariants = cva("inline-flex items-center gap-1 rounded-button border px-2 py-1 text-xs font-semibold", {
  variants: {
    variant: {
      default: "border-divider bg-surface-variant text-foreground",
      outline: "border-divider bg-transparent text-muted",
    },
  },
  defaultVariants: {
    variant: "default",
  },
})

export function Badge({ className, variant, ...props }) {
  return <span className={cn(badgeVariants({ variant }), className)} {...props} />
}
