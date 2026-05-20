import { AlertTriangle } from "lucide-react"
import { Button } from "@/components/ui/button"

export function ConfirmDialog({
  open,
  title,
  description,
  confirmLabel = "Confirm",
  cancelLabel = "Cancel",
  loading = false,
  onConfirm,
  onCancel,
}) {
  if (!open) return null

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-background/80 p-6 backdrop-blur-xs">
      <div className="w-full max-w-md rounded-card border bg-surface">
        <div className="flex gap-3 border-b p-4">
          <div className="flex h-10 w-10 items-center justify-center rounded-button border border-critical/40 bg-critical/10 text-critical">
            <AlertTriangle className="h-5 w-5" />
          </div>
          <div>
            <h2 className="text-base font-semibold text-foreground">{title}</h2>
            <p className="mt-1 text-sm leading-6 text-muted">{description}</p>
          </div>
        </div>
        <div className="flex justify-end gap-2 p-4">
          <Button variant="outline" onClick={onCancel} disabled={loading}>
            {cancelLabel}
          </Button>
          <Button variant="destructive" onClick={onConfirm} disabled={loading}>
            {loading ? "Working..." : confirmLabel}
          </Button>
        </div>
      </div>
    </div>
  )
}
