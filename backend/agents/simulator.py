import os
import json
import datetime
from typing import Dict, Any
from dotenv import load_dotenv
from google.genai import types
from agents.client_manager import get_client

# Load environment variables
load_dotenv()

def simulator(state: Dict[str, Any]) -> Dict[str, Any]:
    """
    Simulates execution and produces before/after state, including detailed routing data.
    """
    action_plan = state.get("action_plan", [])
    normalized_location = state.get("normalized_location", "Unknown")
    raw_input = state.get("raw_input", {})
    start_lat = raw_input.get("location_lat", 0.0)
    start_lng = raw_input.get("location_lng", 0.0)
    crisis_type = state.get("crisis_type", "unknown")
    severity = state.get("severity", "medium")
    
    prompt = f"""
    You are the Simulator agent for CIRO (Crisis Intelligence & Response Orchestrator).
    Your job is to simulate the outcome of the proposed response actions and determine the best emergency destination based on crisis context.

    Input Data:
    Crisis Location: ({start_lat}, {start_lng})
    Normalized Location Name: {normalized_location}
    Crisis Type: {crisis_type}
    Severity: {severity}
    Action Plan: {json.dumps(action_plan)}

    Available Islamabad emergency service destinations:
    - Rescue 1122 HQ: lat=33.7180, lng=73.0551 (Use for general rescue, fires, major disasters)
    - PIMS Hospital: lat=33.7180, lng=73.0607 (Use for medical emergencies, critical accidents, casualties)
    - Poly Clinic Hospital: lat=33.7097, lng=73.0684 (Use for general medical/health response, minor accidents)
    - Traffic Police HQ: lat=33.6938, lng=73.0479 (Use for blockages, traffic accidents, route congestion)
    - CDA Emergency: lat=33.7215, lng=73.0434 (Use for infrastructure issues, flooding, landsliding)
    - Shifa Hospital: lat=33.7267, lng=73.0360 (Use for medical emergencies, trauma/accident response)

    Tasks:
    1. Select the most appropriate emergency destination from the list above based on the crisis type, severity, and action plan.
    2. Simulate "before_route" (blocked/affected route due to the crisis):
       - Determine an ETA in minutes (higher due to the crisis).
       - Set congestion level (e.g., "high", "critical").
       - Provide a "description" explaining what route is blocked/affected starting from the crisis location ({start_lat}, {start_lng}) towards the chosen destination.
    3. Simulate "after_route" (recommended alternate route bypassing the crisis/blockage):
       - Determine an ETA in minutes (lower, representing successful response/diversion).
       - Set congestion level (e.g., "low", "medium").
       - Provide a "description" explaining the alternate route/detour.
    4. Populate the "destination" with name, lat, and lng from the selected Islamabad destination.
    5. Populate "blocked_segment" representing the road segment blocked by the crisis (near {normalized_location}). Explain the blockage and its severity level.
    6. Generate an "emergency_ticket" with a ticket ID and status.
    7. List "alerts_dispatched" to authorities/citizens.

    Output format:
    Return ONLY a JSON object with the following keys:
    {{
      "simulation_result": {{
        "before_route": {{
          "eta_minutes": integer,
          "congestion_level": "string",
          "description": "string explaining what route is blocked"
        }},
        "after_route": {{
          "eta_minutes": integer,
          "congestion_level": "string",
          "description": "string explaining the alternate route"
        }},
        "destination": {{
          "name": "string — name of emergency destination",
          "lat": float,
          "lng": float
        }},
        "blocked_segment": {{
          "description": "string explaining what road/segment is blocked",
          "severity": "string"
        }},
        "emergency_ticket": {{
          "ticket_id": "string",
          "status": "string"
        }},
        "alerts_dispatched": ["string"]
      }},
      "decision": "string explaining the simulation outcomes and destination choice",
      "confidence": integer (0-100)
    }}
    """

    # Fallback state in case of failure
    fallback_output = {
        "simulation_result": {
            "before_route": {
                "eta_minutes": 30,
                "congestion_level": "high",
                "description": f"Main access route from ({start_lat}, {start_lng}) is blocked due to the crisis."
            },
            "after_route": {
                "eta_minutes": 15,
                "congestion_level": "low",
                "description": "Alternate route via service road detour is clear."
            },
            "destination": {
                "name": "Rescue 1122 HQ",
                "lat": 33.7180,
                "lng": 73.0551
            },
            "blocked_segment": {
                "description": f"Blocked segment near ({start_lat}, {start_lng})",
                "severity": "high"
            },
            "emergency_ticket": {
                "ticket_id": "TKT-FAIL-001",
                "status": "simulated"
            },
            "alerts_dispatched": ["Authority alerted"]
        },
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
        print(f"Simulator Vertex AI call error: {e}")
        result = fallback_output

    # Update the shared state
    state["simulation_result"] = result.get("simulation_result", fallback_output["simulation_result"])
    
    # Append trace log
    trace_entry = {
        "agent": "Simulator",
        "timestamp": datetime.datetime.now(datetime.timezone.utc).isoformat(),
        "input_summary": f"Simulating {len(action_plan)} actions at {normalized_location}",
        "decision": result.get("decision", "Completed response simulation"),
        "confidence": result.get("confidence", 0),
        "output_summary": f"Simulated ticket {state['simulation_result']['emergency_ticket']['ticket_id']}. ETA reduced by {state['simulation_result']['before_route']['eta_minutes'] - state['simulation_result']['after_route']['eta_minutes']} mins."
    }
    
    state.setdefault("trace", [])
    state["trace"].append(trace_entry)

    return state