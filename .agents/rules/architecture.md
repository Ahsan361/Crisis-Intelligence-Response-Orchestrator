# CIRO Architecture Rules

## 1. Data Access Abstraction
- **Rule:** The Flutter mobile application MUST NEVER call the Supabase database directly.
- **Reason:** To maintain security, pipeline integrity, and centralized logic, all read/write/update actions must pass through the FastAPI backend (`POST /reports`, `PATCH /reports/{id}`).

## 2. API Key Management
- **Rule:** All API keys and secrets must reside in the backend `.env` file and NEVER be checked into source code.
- **Exception (ORS Key):** The OpenRouteService (ORS) API key is the sole exception. Because the mobile client draws routes directly on `flutter_map`, the ORS key is securely managed via `ciro_mobile_client/lib/config/app_config.dart`.

## 3. Background Tasks
- **Rule:** All background polling and monitoring (e.g., `weather_monitor`, `traffic_monitor`, `auto_resolve_reports`) must use the Python `asyncio` pattern established in `backend/main.py`.
- **Implementation:** Tasks should be spawned in the FastAPI `lifespan` context manager and cleanly cancelled upon shutdown. Do not use standalone threads for background loops within the main application.
