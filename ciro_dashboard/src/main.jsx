import React from "react"
import ReactDOM from "react-dom/client"
import { BrowserRouter } from "react-router-dom"
import { QueryClient, QueryClientProvider } from "@tanstack/react-query"
import { App } from "@/App"
import { ThemeProvider } from "@/lib/theme"
import { AnalysisProvider } from "@/lib/analysisContext"
import "@/index.css"

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 15000,
    },
  },
})

ReactDOM.createRoot(document.getElementById("root")).render(
  <React.StrictMode>
    <QueryClientProvider client={queryClient}>
      <ThemeProvider>
        <AnalysisProvider>
          <BrowserRouter>
            <App />
          </BrowserRouter>
        </AnalysisProvider>
      </ThemeProvider>
    </QueryClientProvider>
  </React.StrictMode>,
)
