import { useEffect, useState, useMemo } from "react"
import { Brain, CheckCircle2, Circle, Clock, Loader2, MapPin, Radio, Shield, Zap } from "lucide-react"
import { cn } from "@/lib/utils"

const PIPELINE_STEPS = [
  { id: "signal",    icon: Radio,       label: "Collecting Signal",          desc: "Gathering raw crisis signal data from the report",         expectedDuration: 3000,   minPct: 0,   maxPct: 16 },
  { id: "detect",    icon: Brain,       label: "Detecting Crisis Type",      desc: "AI is classifying the nature and scope of the incident",   expectedDuration: 16000,  minPct: 16,  maxPct: 33 },
  { id: "analyze",   icon: Zap,         label: "Reasoning & Analysis",       desc: "Evaluating severity, context, and response requirements",  expectedDuration: 16000,  minPct: 33,  maxPct: 50 },
  { id: "plan",      icon: Shield,      label: "Planning Response Actions",  desc: "Generating a coordinated action plan for responders",      expectedDuration: 16000,  minPct: 50,  maxPct: 66 },
  { id: "simulate",  icon: MapPin,      label: "Simulating ETA Impact",      desc: "Running route simulation to compute CIRO improvement",     expectedDuration: 16000,  minPct: 66,  maxPct: 83 },
  { id: "done",      icon: CheckCircle2, label: "Finalizing Report",         desc: "Writing results to database and closing pipeline",         expectedDuration: 4000,   minPct: 83,  maxPct: 100 },
]

export function AnalysisProgressDialog({ open, reportName, trace }) {
  const [elapsed, setElapsed] = useState(0)
  const [stepStartTime, setStepStartTime] = useState(0)

  // Derive current step from agent_trace array
  const currentStep = useMemo(() => {
    if (!trace || !Array.isArray(trace) || trace.length === 0) return 0
    
    const hasAgent = (name) => trace.some(t => t.agent === name)
    
    if (hasAgent("Simulator")) return 5
    if (hasAgent("ActionPlanner")) return 4
    if (hasAgent("ReasoningAnalyzer")) return 3
    if (hasAgent("CrisisDetector")) return 2
    if (hasAgent("SignalCollector")) return 1
    return 0
  }, [trace])

  useEffect(() => {
    if (!open) {
      setElapsed(0)
      setStepStartTime(0)
      return
    }

    const openTime = Date.now()
    setStepStartTime(openTime)
    
    const interval = setInterval(() => {
      setElapsed(Date.now() - openTime)
    }, 100)
    
    return () => clearInterval(interval)
  }, [open])

  // Reset step start time when currentStep changes
  useEffect(() => {
    if (open) {
      setStepStartTime(Date.now())
    }
  }, [currentStep, open])

  // Get active narration or description
  const activeNarration = useMemo(() => {
    if (!trace || !Array.isArray(trace) || trace.length === 0) return null
    const latest = trace[trace.length - 1]
    return latest?.decision || latest?.output_summary || null
  }, [trace])

  if (!open) return null

  // Calculate progress percent based on current step config & elapsed time
  const progress = (() => {
    const config = PIPELINE_STEPS[currentStep] || { minPct: 0, maxPct: 100, expectedDuration: 1000 }
    const stepElapsed = Math.max(0, Date.now() - stepStartTime)
    const stepProgress = Math.min(stepElapsed / config.expectedDuration, 0.99)
    const pct = config.minPct + stepProgress * (config.maxPct - config.minPct)
    return Math.min(pct, 99)
  })()

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-background/80 p-6 backdrop-blur-sm">
      <div className="w-full max-w-lg rounded-card border bg-surface shadow-2xl">
        {/* Header */}
        <div className="flex items-center gap-3 border-b px-5 py-4">
          <div className="flex h-10 w-10 items-center justify-center rounded-button border border-primary/40 bg-primary/10 text-primary">
            <Loader2 className="h-5 w-5 animate-spin" />
          </div>
          <div>
            <h2 className="text-base font-semibold text-foreground">CIRO Pipeline Running</h2>
            <p className="text-xs text-muted">
              Analyzing{reportName ? `: ${reportName}` : " report"} — live agent execution
            </p>
          </div>
          <div className="ml-auto text-right">
            <Clock className="h-4 w-4 text-muted inline-block mr-1" />
            <span className="text-xs font-mono text-muted">{(elapsed / 1000).toFixed(1)}s</span>
          </div>
        </div>

        {/* Progress bar */}
        <div className="px-5 pt-4">
          <div className="relative h-1.5 w-full overflow-hidden rounded-full bg-surface-variant">
            <div
              className="absolute inset-y-0 left-0 rounded-full bg-primary transition-all duration-300 animate-pulse"
              style={{ width: `${progress}%` }}
            />
          </div>
          <div className="flex justify-between items-center mt-1">
            <span className="text-[10px] text-primary/80 font-medium">Real-time Orchestration</span>
            <span className="text-right text-[10px] text-muted font-mono">{Math.round(progress)}%</span>
          </div>
        </div>

        {/* Step list */}
        <div className="space-y-1 px-5 py-3">
          {PIPELINE_STEPS.map((step, index) => {
            const isDone = index < currentStep
            const isActive = index === currentStep
            const isPending = index > currentStep
            const Icon = step.icon

            return (
              <div
                key={step.id}
                className={cn(
                  "flex items-start gap-3 rounded-button border px-3 py-2.5 transition-all duration-300",
                  isActive  && "border-primary/30 bg-primary/5 shadow-sm",
                  isDone    && "border-secondary/20 bg-secondary/5 opacity-70",
                  isPending && "border-transparent bg-transparent opacity-40",
                )}
              >
                <div className={cn(
                  "flex h-7 w-7 items-center justify-center rounded-full shrink-0 mt-0.5",
                  isActive  && "bg-primary/15 text-primary",
                  isDone    && "bg-secondary/15 text-secondary",
                  isPending && "bg-surface-variant text-muted",
                )}>
                  {isDone ? (
                    <CheckCircle2 className="h-4 w-4" />
                  ) : isActive ? (
                    <Loader2 className="h-4 w-4 animate-spin" />
                  ) : (
                    <Circle className="h-4 w-4" />
                  )}
                </div>
                <div className="min-w-0 flex-1">
                  <div className="flex items-center justify-between">
                    <p className={cn(
                      "text-sm font-semibold leading-none",
                      isActive  && "text-foreground",
                      isDone    && "text-muted",
                      isPending && "text-muted",
                    )}>
                      {step.label}
                    </p>
                    {isDone && <span className="text-[9px] text-secondary font-bold uppercase tracking-wider">Done</span>}
                    {isActive && <span className="text-[9px] text-primary font-bold uppercase tracking-wider animate-pulse">Active</span>}
                  </div>
                  {isActive && (
                    <div className="mt-1.5 text-[11px] leading-normal text-muted bg-background/50 border border-border/30 rounded px-2.5 py-1.5 font-sans whitespace-pre-line max-h-24 overflow-y-auto">
                      {activeNarration ? (
                        <div className="flex flex-col gap-1">
                          <span className="text-[9px] font-bold text-primary uppercase tracking-wider">Live Trace:</span>
                          <span>{activeNarration}</span>
                        </div>
                      ) : (
                        <span>{step.desc}</span>
                      )}
                    </div>
                  )}
                </div>
              </div>
            )
          })}
        </div>

        <div className="border-t px-5 py-3">
          <p className="text-xs text-muted text-center">
            CIRO is executing multiple LLM agents sequentially. Progress corresponds to actual backend state transitions.
          </p>
        </div>
      </div>
    </div>
  )
}
