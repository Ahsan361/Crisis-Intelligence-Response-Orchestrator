import { cva } from "class-variance-authority"
import { cn } from "@/lib/utils"

const buttonVariants = cva(
  "inline-flex items-center justify-center gap-2 whitespace-nowrap rounded-button border px-3 py-2 text-sm font-semibold transition-colors disabled:pointer-events-none disabled:opacity-50 focus-visible:outline-hidden focus-visible:ring-2 focus-visible:ring-primary/50",
  {
    variants: {
      variant: {
        default: "border-primary bg-primary text-white hover:bg-primary/90",
        secondary: "border-secondary bg-secondary text-[#0D1117] hover:bg-secondary/90",
        outline: "border-divider bg-transparent text-foreground hover:bg-surface-variant",
        ghost: "border-transparent bg-transparent text-muted hover:bg-surface-variant hover:text-foreground",
        destructive: "border-critical bg-critical text-white hover:bg-critical/90",
        warning: "border-warning bg-warning text-[#0D1117] hover:bg-warning/90",
      },
      size: {
        sm: "h-8 px-2.5 text-xs",
        md: "h-10",
        lg: "h-11 px-4",
        icon: "h-9 w-9 p-0",
      },
    },
    defaultVariants: {
      variant: "default",
      size: "md",
    },
  },
)

export function Button({ className, variant, size, type = "button", ...props }) {
  return <button type={type} className={cn(buttonVariants({ variant, size }), className)} {...props} />
}
