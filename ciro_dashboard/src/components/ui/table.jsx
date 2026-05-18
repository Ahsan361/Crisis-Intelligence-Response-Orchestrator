import { cn } from "@/lib/utils"

export function Table({ className, ...props }) {
  return <table className={cn("w-full caption-bottom text-left text-sm", className)} {...props} />
}

export function TableHeader({ className, ...props }) {
  return <thead className={cn("border-b bg-surface-variant/70 text-muted", className)} {...props} />
}

export function TableBody({ className, ...props }) {
  return <tbody className={cn("divide-y", className)} {...props} />
}

export function TableRow({ className, ...props }) {
  return <tr className={cn("transition-colors hover:bg-surface-variant/55", className)} {...props} />
}

export function TableHead({ className, ...props }) {
  return <th className={cn("px-3 py-3 text-xs font-semibold uppercase tracking-normal", className)} {...props} />
}

export function TableCell({ className, ...props }) {
  return <td className={cn("px-3 py-3 align-middle text-sm", className)} {...props} />
}
