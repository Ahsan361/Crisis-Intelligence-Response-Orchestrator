import { Badge } from "@/components/ui/badge"
import { statusMeta } from "@/lib/constants"
import { titleCase } from "@/lib/format"
import { cn } from "@/lib/utils"

export function StatusBadge({ status }) {
  const meta = statusMeta[status] ?? { label: titleCase(status), className: "border-divider bg-surface-variant text-muted" }
  return <Badge className={cn("capitalize", meta.className)}>{meta.label}</Badge>
}
