# CIRO Code Style Rules

## Python (Backend & Agents)
- **Style:** Strictly follow PEP8 conventions.
- **Async:** All FastAPI endpoints and background loops (`main.py`) must use `async`/`await`. Run blocking IO in threadpools (`asyncio.to_thread`) if necessary (e.g., `run_orchestrator`).
- **Typing:** Type hints are explicitly required for all function signatures and Pydantic models.
- **No Hardcoded Values:** Do not hardcode API keys or connection strings. Extract them from `.env`.

## Dart (Flutter Frontend)
- **State Management:** Use the modern Riverpod 3.0 `Notifier` / `AsyncNotifier` API (no deprecated `StateNotifier`).
- **Styling:** Use `CiroColors` and `CiroTextStyles` for all UI components to maintain the "NASA Mission Control" theme. Never use raw hex codes or hardcoded text styles.
- **Accessibility:** Ensure a minimum of 48px tap targets for all interactive elements (buttons, icons).
- **No Hardcoded Strings:** Use constants for routes (`CiroRoutes`) and environment config (`AppConfig`).

## General Directives
- **Production Readiness:** No mock data fallbacks in production. If an API fails, gracefully degrade or show an explicit error state to the user, rather than displaying mock simulation data.
