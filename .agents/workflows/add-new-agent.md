# Workflow: Adding a New AI Agent

Follow these steps to integrate a new specialized agent into the CIRO pipeline:

1. **Create the File:**
   Create a new Python file in `backend/agents/`, e.g., `backend/agents/new_agent.py`.

2. **Define the Interface:**
   Define a main function that accepts and returns the state dictionary:
   ```python
   from typing import Dict, Any
   from agents.client_manager import get_client
   import json
   import datetime

   def new_agent(state: Dict[str, Any]) -> Dict[str, Any]:
       # ... logic here ...
       return state
   ```

3. **Construct the Prompt:**
   Extract necessary data from `state` (e.g., `state.get('cleaned_text')`) and construct an LLM prompt requiring JSON output.

4. **Invoke Gemini via Client Manager:**
   ```python
   client = get_client() # Handles API key rotation
   response = client.models.generate_content(
       model="gemini-2.5-flash",
       contents=prompt,
       config={"response_mime_type": "application/json"}
   )
   result = json.loads(response.text)
   ```

5. **Update State and Trace:**
   Mutate `state` with the result, and crucially, append to `state["trace"]`:
   ```python
   state["new_field"] = result["new_field"]
   state.setdefault("trace", []).append({
       "agent": "NewAgent",
       "timestamp": datetime.datetime.now(datetime.timezone.utc).isoformat(),
       "decision": "Generated new insights.",
       "confidence": 95,
   })
   ```

6. **Register with Orchestrator:**
   Open `backend/agents/orchestrator.py`, import `new_agent`, and add it to the sequence array inside `run_orchestrator()`.
