import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query"
import { analyzeReport, deleteReport, fetchReport, fetchReports, updateReport } from "@/lib/api"

export function useReports(options = {}) {
  return useQuery({
    queryKey: ["reports", options.params ?? {}],
    queryFn: () => fetchReports(options.params),
    refetchInterval: options.refetchInterval,
    retry: 1,
  })
}

export function useReport(id, options = {}) {
  return useQuery({
    queryKey: ["report", id],
    queryFn: () => fetchReport(id),
    enabled: Boolean(id),
    retry: 1,
    ...options
  })
}

export function useAnalyzeReport() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: analyzeReport,
    onSuccess: (_data, report) => {
      queryClient.invalidateQueries({ queryKey: ["reports"] })
      queryClient.invalidateQueries({ queryKey: ["report", report.id] })
    },
  })
}

export function useResolveReport() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: (report) => updateReport(report.id, { status: "resolved" }),
    onSuccess: (_data, report) => {
      queryClient.invalidateQueries({ queryKey: ["reports"] })
      queryClient.invalidateQueries({ queryKey: ["report", report.id] })
    },
  })
}

export function useDeleteReport() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: deleteReport,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["reports"] })
    },
  })
}
