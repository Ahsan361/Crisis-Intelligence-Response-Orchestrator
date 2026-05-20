import { createContext, useCallback, useContext, useState } from "react"

const AnalysisContext = createContext({
  isAnalyzing: false,
  analyzingReport: null,
  setAnalyzing: () => {},
  clearAnalyzing: () => {},
})

export function AnalysisProvider({ children }) {
  const [analyzingReport, setAnalyzingReport] = useState(null)

  const setAnalyzing = useCallback((report) => {
    setAnalyzingReport(report)
  }, [])

  const clearAnalyzing = useCallback(() => {
    setAnalyzingReport(null)
  }, [])

  return (
    <AnalysisContext.Provider value={{ isAnalyzing: Boolean(analyzingReport), analyzingReport, setAnalyzing, clearAnalyzing }}>
      {children}
    </AnalysisContext.Provider>
  )
}

export function useAnalysisState() {
  return useContext(AnalysisContext)
}
