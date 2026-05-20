# CIRO API Keys Inventory

This document maps all API keys used across the CIRO ecosystem and specifies where they must be configured.

## Backend (`backend/.env`)
The backend uses multiple keys for database access, AI processing, and environment monitoring:
- `SUPABASE_URL`: The REST URL for the Supabase instance.
- `SUPABASE_KEY`: The `service_role` key (backend has elevated privileges).
- `GEMINI_API_KEY_1` to `GEMINI_API_KEY_4`: A pool of 4 Gemini keys. These are rotated automatically by `client_manager.py` to circumvent `429 Too Many Requests` limits.
- `OWM_API_KEY`: OpenWeatherMap key used by `weather_monitor` in `main.py` to trigger flood/heatwave alerts.

## Flutter Frontend (`ciro_mobile_client/lib/config/app_config.dart`)
The mobile client requires specific configuration to communicate with the backend and map services:
- `API_BASE_URL`: The address of the FastAPI backend (e.g., `http://10.0.2.2:8000` for Android emulators).
- `ORS_API_KEY`: The OpenRouteService key, explicitly allowed on the frontend to draw real-time map routes.
