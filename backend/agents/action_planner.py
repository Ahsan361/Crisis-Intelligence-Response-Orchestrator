import os
import json
import datetime
from typing import Dict, Any, List
from dotenv import load_dotenv
from google.genai import types
from agents.client_manager import get_client

# Load environment variables
load_dotenv()

def action_planner(state: Dict[str, Any]) -> Dict[str, Any]:
    """
    Generates coordinated response actions based on severity and crisis type.
    """
    severity = state.get("severity", "medium")
    crisis_type = state.get("crisis_type", "unknown")
    explanation = state.get("severity_explanation", "")
    
    prompt = f"""
    You are the Action Planner agent for CIRO (Crisis Intelligence & Response Orchestrator).
    Your job is to generate a list of actionable response steps for a crisis.

    Input Situation:
    Crisis Type: {crisis_type}
    Severity: {severity}
    Reasoning: {explanation}

    Tasks:
    1. Create a list of actions (3-5 items).
    2. Each action must have:
       - action_type: (e.g., dispatch, alert, logistics, medical)
       - description: specific instructions
       - priority: (low, medium, high, critical)
       - assigned_to: (e.g., Police, Fire Department, Rescue 1122, Municipal Corp)

    Output format:
    Return ONLY a JSON object with the following keys:
    {{
      "action_plan": [
        {{
          "action_type": "string",
          "description": "string",
          "priority": "string",
          "assigned_to": "string"
        }}
      ],
      "decision": "string explaining how you coordinated these actions",
      "confidence": integer (0-100)
    }}
    """

    # Fallback state in case of failure
    fallback_output = {
        "action_plan": [
            {
                "action_type": "alert",
                "description": "General emergency alert dispatched to area.",
                "priority": "high",
                "assigned_to": "Rescue 1122"
            }
        ],
        "decision": "Fallback triggered due to API error or parsing failure.",
        "confidence": 0
    }

    def call_gemini():
        client = get_client()
        response = client.models.generate_content(
            model="gemini-2.5-flash",
            contents=prompt,
            config=types.GenerateContentConfig(
                response_mime_type="application/json"
            )
        )
        return json.loads(response.text)

    try:
        result = call_gemini()
    except Exception as e:
        print(f"Error in ActionPlanner Vertex AI call: {e}")
        result = fallback_output

    # Update the shared state
    state["action_plan"] = result.get("action_plan", [])
    
    # Append trace log
    trace_entry = {
        "agent": "ActionPlanner",
        "timestamp": datetime.datetime.now(datetime.timezone.utc).isoformat(),
        "input_summary": f"Planning actions for {severity} {crisis_type} crisis",
        "decision": result.get("decision", "Generated response strategy"),
        "confidence": result.get("confidence", 0),
        "output_summary": f"Created {len(state['action_plan'])} response actions"
    }
    
    state.setdefault("trace", [])
    state["trace"].append(trace_entry)

    return state

# if __name__ == "__main__":
#     # Test script for ActionPlanner
#     test_state = {
#         "report_id": "test-uuid",
#         "severity": "critical",
#         "crisis_type": "flood",
#         "severity_explanation": "Massive flooding with people stranded on roofs.",
#         "trace": []
#     }
    
#     updated_state = action_planner(test_state)
#     print(json.dumps(updated_state, indent=2))