/* eslint-disable react-refresh/only-export-components */
import { createContext, useContext, useEffect, useMemo, useState } from "react"

const AuthContext = createContext(undefined)
const storageKey = "ciro-admin-auth"

// Default credentials for admin 
const DEFAULT_USER = "admin"
const DEFAULT_PASS = "admin"

export function AuthProvider({ children }) {
  const [user, setUser] = useState(() => {
    const saved = window.localStorage.getItem(storageKey)
    if (saved) {
      try {
        return JSON.parse(saved)
      } catch {
        return null
      }
    }
    return null
  })

  const login = async (username, password) => {
    // Artificial slight delay for a premium interactive feel
    await new Promise((resolve) => setTimeout(resolve, 800))

    if (username.toLowerCase() === DEFAULT_USER && password === DEFAULT_PASS) {
      const userData = { username: DEFAULT_USER, loggedAt: new Date().toISOString() }
      setUser(userData)
      window.localStorage.setItem(storageKey, JSON.stringify(userData))
      return { success: true }
    } else {
      return { success: false, error: "Invalid username or password" }
    }
  }

  const logout = () => {
    setUser(null)
    window.localStorage.removeItem(storageKey)
  }

  const value = useMemo(
    () => ({
      user,
      login,
      logout,
      isAuthenticated: !!user,
    }),
    [user],
  )

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>
}

export function useAuth() {
  const context = useContext(AuthContext)
  if (!context) {
    throw new Error("useAuth must be used inside AuthProvider")
  }
  return context
}
