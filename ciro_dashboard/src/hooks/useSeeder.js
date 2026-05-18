import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query"
import { fetchSeederStatus, seedNow, startSeeder, stopSeeder } from "@/lib/api"

export function useSeederStatus() {
  return useQuery({
    queryKey: ["seeder-status"],
    queryFn: fetchSeederStatus,
    refetchInterval: 10000,
    retry: 1,
  })
}

export function useStartSeeder() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: startSeeder,
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ["seeder-status"] }),
  })
}

export function useStopSeeder() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: stopSeeder,
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ["seeder-status"] }),
  })
}

export function useSeedNow() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: seedNow,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["seeder-status"] })
      queryClient.invalidateQueries({ queryKey: ["reports"] })
    },
  })
}

