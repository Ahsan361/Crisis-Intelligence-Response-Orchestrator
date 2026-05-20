---
name: fastapi-backend
description: Develop async REST APIs using FastAPI and Supabase.
---

# FastAPI Backend Skill

## Instructions
1. **Routing:** Add new endpoints in `backend/main.py`. Use descriptive, RESTful paths (e.g., `POST /analyze-report`).
2. **Validation:** Always define Pydantic schemas in `backend/models.py` for request and response payloads.
3. **Database:** Use the `supabase` Python client imported from `database.py`. Ensure you use `.execute()` on queries and handle potential `None` returns in `response.data`.
4. **Concurrency:** Endpoint functions should be `async def`. If calling blocking, CPU-bound, or synchronous code (like the `run_orchestrator` which uses synchronous Gemini calls), wrap it in `await asyncio.to_thread(...)`.

## Constraints
- Never connect to Supabase using a raw psycopg2/SQLAlchemy connection; strictly use the `supabase-py` client.
- Do not expose the `SUPABASE_KEY` to the public.

## Common Pitfalls
- **Missing `execute()`:** Supabase queries in python do nothing unless `.execute()` is chained at the end.
- **Blocking the Event Loop:** Running long Gemini pipeline tasks synchronously in `main.py` will freeze the server. Always use `asyncio.to_thread`.
