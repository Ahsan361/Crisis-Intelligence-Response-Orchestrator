import { useQuery } from "@tanstack/react-query"
import { pingBackend } from "@/lib/api"

export function useBackendStatus() {
  return useQuery({
    queryKey: ["backend-status"],
    queryFn: pingBackend,
    refetchInterval: 10000,
    retry: false,
  })
}
