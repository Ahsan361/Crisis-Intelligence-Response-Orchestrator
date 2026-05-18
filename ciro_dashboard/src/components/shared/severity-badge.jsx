import { Badge } from "@/components/ui/badge"
import { severityMeta } from "@/lib/constants"
import { cn } from "@/lib/utils"

export function SeverityBadge({ severity }) {
  const meta = severityMeta[severity || "unknown"] ?? severityMeta.unknown
  return (
    <Badge className={cn("capitalize", meta.className)}>
      <span className={cn("h-2 w-2 rounded-full", meta.dotClass)} />
      {meta.label}
    </Badge>
  )
}
