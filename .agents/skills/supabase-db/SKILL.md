---
name: supabase-db
description: Manage database operations for the `reports` table.
---

# Supabase DB Skill

## Instructions
1. **Table Interactions:** All interactions target the `reports` table.
2. **JSONB Handling:** Columns like `agent_trace` and `simulation_result` are JSONB. Ensure you pass valid Python dictionaries or lists when inserting/updating; the Supabase client handles serialization.
3. **Timestamps:** When updating a record manually in `main.py`, always update the `updated_at` field explicitly using `datetime.now(timezone.utc).isoformat()`.

## Constraints
- Never execute destructive commands (`DELETE`, `DROP`) without explicit verification, as this is the primary operational datastore for CIRO.

## Common Pitfalls
- **Timezone Naivety:** Passing a naive Python `datetime` object to Supabase causes serialization errors. Always use UTC aware datetime objects (`timezone.utc`).
- **Response Validation:** Assuming `response.data` is populated. Always check `if not response.data:` as updates or queries might yield empty results.
