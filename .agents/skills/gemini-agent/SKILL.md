---
name: gemini-agent
description: Implement AI pipeline agents using Gemini.
---

# Gemini Agent Skill

## Instructions
1. **Agent Definition:** Create a new python file in `backend/agents/`. Define a function accepting a `state: dict` and returning a `dict`.
2. **Client Management:** Always instantiate the GenAI client using `get_client()` from `agents.client_manager`. This guarantees API key rotation.
3. **Structured Output:** Ensure the prompt asks for `application/json` output, and set `response_mime_type="application/json"` in `GenerateContentConfig`.
4. **State Mutation:** Append the agent's outcome to `state["trace"]` as a dictionary containing `agent`, `timestamp`, `decision`, `confidence`, and `input_summary`/`output_summary`.

## Constraints
- Do not initialize the `google.genai.Client` directly with an environment variable. The `ClientManager` must handle it.
- Agents must be deterministic in output schema. Always provide a clear JSON format block in the prompt.

## Common Pitfalls
- **Missing Fallbacks:** If `json.loads(response.text)` fails, the agent must catch the exception and return a default fallback state dict to prevent the pipeline from crashing.
- **Trace Formatting:** Forgetting to update `state["trace"]` breaks the mobile app's Agent Trace screen, which relies on the `agent_trace` JSONB column.
