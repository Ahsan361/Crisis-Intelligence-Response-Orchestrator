# Workflow: Debugging the Pipeline

When the 5-agent pipeline fails or returns unexpected data, follow this diagnostic checklist:

1. **Check the Agent Trace Database:**
   Look at the Supabase `reports` table for the failing report. Inspect the `agent_trace` JSONB array. Identify which agent was the *last* to successfully log a trace entry. The failure likely occurred in the subsequent agent.

2. **Verify API Key Rotation (`client_manager.py`):**
   Check the FastAPI backend logs. If you see `429 Too Many Requests`, ensure that `client_manager.py` has multiple valid keys in the `.env` (e.g., `GEMINI_API_KEY_1`, `GEMINI_API_KEY_2`) and is successfully rotating through them.

3. **Check LLM JSON Parsing Fallbacks:**
   Occasionally, Gemini may return markdown-wrapped JSON (e.g., ` ```json {...} ``` `) or malformed JSON.
   - Go to the failing agent (e.g., `simulator.py`).
   - Verify the `try...except` block around `json.loads(response.text)`.
   - Ensure the `fallback_output` is a syntactically correct dictionary that matches the expected schema, so the pipeline can gracefully degrade rather than crashing.

4. **Analyze Orchestrator Handover:**
   If an agent returns the expected data but the next agent fails, the issue may be in `backend/agents/orchestrator.py`. Ensure the `state` dictionary is properly passed between the sequential stages and that the Mechanism 4 narration is correctly summarizing the handover.
