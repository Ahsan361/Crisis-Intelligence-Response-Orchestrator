import axios from "axios"
import { apiBaseUrl } from "@/lib/constants"

export const api = axios.create({
  baseURL: apiBaseUrl,
  timeout: 30000,
})

// Separate instance with longer timeout for the pipeline analyze call
export const analyzeApi = axios.create({
  baseURL: apiBaseUrl,
  timeout: 120000,
})

export function normalizeReports(payload) {
  if (Array.isArray(payload)) return payload
  if (Array.isArray(payload?.reports)) return payload.reports
  if (Array.isArray(payload?.data)) return payload.data
  return []
}

export async function fetchReports(params = {}) {
  const response = await api.get("/reports", { params })
  return normalizeReports(response.data)
}

export async function fetchReport(id) {
  const response = await api.get(`/reports/${id}`)
  return response.data
}

export async function updateReport(id, payload) {
  const response = await api.patch(`/reports/${id}`, payload)
  return response.data
}

export async function deleteReport(id) {
  const response = await api.delete(`/reports/${id}`)
  return response.data
}

export async function analyzeReport(report) {
  const response = await analyzeApi.post("/analyze-report", {
    report_id: report.id,
    report_text: report.report_text,
    area_name: report.area_name,
    location_lat: report.location_lat,
    location_lng: report.location_lng,
  })
  return response.data
}

export async function fetchSeederStatus() {
  const response = await api.get("/seeder/status")
  return response.data
}

export async function startSeeder(intervalMinutes) {
  const response = await api.post("/seeder/start", { interval_minutes: intervalMinutes })
  return response.data
}

export async function stopSeeder() {
  const response = await api.post("/seeder/stop")
  return response.data
}

export async function seedNow() {
  const response = await api.post("/seeder/seed-now")
  return response.data
}


export async function pingBackend() {
  try {
    await api.get("/reports", { params: { limit: 1 }, timeout: 5000 })
    return true
  } catch {
    return false
  }
}
