import { useState } from "react"
import { useNavigate } from "react-router-dom"
import { Eye, EyeOff, Lock, Shield, User, AlertCircle, Loader2 } from "lucide-react"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { useAuth } from "@/lib/authContext"

export function LoginPage() {
  const { login } = useAuth()
  const navigate = useNavigate()

  const [username, setUsername] = useState("")
  const [password, setPassword] = useState("")
  const [showPassword, setShowPassword] = useState(false)
  
  const [isLoading, setIsLoading] = useState(false)
  const [error, setError] = useState("")

  const handleSubmit = async (e) => {
    e.preventDefault()
    if (!username || !password) {
      setError("Please fill in all fields")
      return
    }

    setError("")
    setIsLoading(true)

    try {
      const res = await login(username, password)
      if (res.success) {
        navigate("/", { replace: true })
      } else {
        setError(res.error || "Login failed")
      }
    } catch {
      setError("An unexpected error occurred. Please try again.")
    } finally {
      setIsLoading(false)
    }
  }

  return (
    <div className="flex min-h-screen items-center justify-center bg-background px-4 py-12 sm:px-6 lg:px-8 transition-colors duration-300">
      {/* Dynamic ambient glow effects matching NASA Mission Control styling */}
      <div className="pointer-events-none absolute inset-0 overflow-hidden">
        <div className="absolute top-[10%] left-[10%] h-[30vw] w-[30vw] rounded-full bg-primary/5 blur-[120px]" />
        <div className="absolute bottom-[10%] right-[10%] h-[30vw] w-[30vw] rounded-full bg-teal-500/5 blur-[120px]" />
      </div>

      <div className="relative w-full max-w-md space-y-8 rounded-card border border-divider/60 bg-surface/50 p-8 shadow-xl backdrop-blur-md sm:p-10">
        
        {/* Header Section */}
        <div className="flex flex-col items-center text-center">
          <div className="flex h-16 w-16 items-center justify-center rounded-full bg-gradient-to-br from-primary to-teal-600 shadow-lg ring-4 ring-primary/20">
            <Shield className="h-8 w-8 text-white animate-pulse" />
          </div>
          <h2 className="mt-6 text-2xl font-bold tracking-tight text-foreground">
            CIRO Admin Command
          </h2>
          <p className="mt-2 text-sm text-muted">
            Enter your credentials to access the crisis responder panel
          </p>
        </div>

        {/* Form Section */}
        <form onSubmit={handleSubmit} className="mt-8 space-y-6">
          {error && (
            <div className="flex items-center gap-2.5 rounded-button border border-critical/20 bg-critical/10 p-3.5 text-sm font-semibold text-critical">
              <AlertCircle className="h-4.5 w-4.5 shrink-0" />
              <span>{error}</span>
            </div>
          )}

          <div className="space-y-4">
            {/* Username Input */}
            <div className="space-y-1">
              <label htmlFor="username" className="text-xs font-bold uppercase tracking-wider text-muted">
                Username
              </label>
              <div className="relative">
                <span className="absolute inset-y-0 left-0 flex items-center pl-3 text-muted">
                  <User className="h-4 w-4" />
                </span>
                <Input
                  id="username"
                  name="username"
                  type="text"
                  required
                  placeholder="admin"
                  value={username}
                  onChange={(e) => setUsername(e.target.value)}
                  className="pl-10"
                  disabled={isLoading}
                />
              </div>
            </div>

            {/* Password Input */}
            <div className="space-y-1">
              <label htmlFor="password" className="text-xs font-bold uppercase tracking-wider text-muted">
                Password
              </label>
              <div className="relative">
                <span className="absolute inset-y-0 left-0 flex items-center pl-3 text-muted">
                  <Lock className="h-4 w-4" />
                </span>
                <Input
                  id="password"
                  name="password"
                  type={showPassword ? "text" : "password"}
                  required
                  placeholder="••••••••"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  className="pl-10 pr-10"
                  disabled={isLoading}
                />
                <button
                  type="button"
                  onClick={() => setShowPassword(!showPassword)}
                  className="absolute inset-y-0 right-0 flex items-center pr-3 text-muted hover:text-foreground focus:outline-hidden"
                  tabIndex="-1"
                >
                  {showPassword ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
                </button>
              </div>
            </div>
          </div>

          {/* Action Button */}
          <Button
            type="submit"
            className="w-full flex justify-center py-2.5"
            disabled={isLoading}
          >
            {isLoading ? (
              <>
                <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                Authenticating...
              </>
            ) : (
              "Sign In to Control Center"
            )}
          </Button>
        </form>

        <div className="text-center pt-2">
          <span className="text-xs text-muted/80">
            For local evaluation, use credentials <code className="bg-surface-variant/80 border px-1.5 py-0.5 rounded font-mono text-[11px] text-foreground">admin / admin</code>
          </span>
        </div>
      </div>
    </div>
  )
}
