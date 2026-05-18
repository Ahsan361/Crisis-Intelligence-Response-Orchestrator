import os
import json
import datetime
import time
from typing import Dict, Any, List
from dotenv import load_dotenv
from google.genai import types
from agents.client_manager import get_client, rotate_client

# Import agents
from agents.signal_collector import signal_collector
from agents.crisis_detector import crisis_detector
from agents.reasoning_analyzer import reasoning_analyzer
from agents.action_planner import action_planner
from agents.simulator import simulator

# Load environment variables
load_dotenv()

def narrate_decision(state: Dict[str, Any], next_agent: str) -> Dict[str, Any]:
    """
    Uses Gemini to narrate the decision to move to the next agent.
    """
    trace_history = json.dumps(state.get("trace", [])[-1:] if state.get("trace") else "No history")
    
    prompt = f"""
    You are the CIRO Orchestrator Agent. 
    Current Pipeline State History (Last Entry): {trace_history}
    
    The next agent in the sequence is: {next_agent}
    
    Your task is to narrate your decision to invoke {next_agent}. 
    Explain what you have observed so far and why this next step is necessary for crisis management.
    
    Output format:
    Return ONLY a JSON object with:
    {{
      "narration": "A first-person narration of your decision (e.g., 'I have analyzed the cleaned text and now I must determine the type of crisis...')",
      "confidence": integer (0-100)
    }}
    """
    
    fallback_result = {"narration": f"Proceeding to {next_agent} for further analysis.", "confidence": 100}

    def call_gemini():
        client = get_client()
        response = client.models.generate_content(
            model="gemini-flash-latest",
            contents=prompt,
            config=types.GenerateContentConfig(
                response_mime_type="application/json"
            )
        )
        return json.loads(response.text)

    try:
        result = call_gemini()
    except Exception as e:
        if "429" in str(e):
            print("Rate limit hit. Rotating API key...")
            rotate_client()
            try:
                result = call_gemini()
            except Exception as e2:
                print(f"Retry also failed: {e2}")
                result = fallback_result
        else:
            print(f"Orchestrator narration error: {e}")
            result = fallback_result

    # Append Orchestrator trace entry
    trace_entry = {
        "agent": "Orchestrator",
        "timestamp": datetime.datetime.now(datetime.timezone.utc).isoformat(),
        "decision": result.get("narration", f"Invoking {next_agent}"),
        "confidence": result.get("confidence", 100)
    }
    
    if "trace" not in state:
        state["trace"] = []
    state["trace"].append(trace_entry)
    
    return state

def run_orchestrator(report_id: str, report_text: str, area_name: str, lat: float, lng: float) -> Dict[str, Any]:
    """
    Main entry point for the CIRO Agent Pipeline.
    Executes agents in hardcoded order with LLM-narrated transitions.
    """
    # Initialize Shared State
    state = {
        "report_id": report_id,
        "raw_input": {
            "report_text": report_text,
            "area_name": area_name,
            "location_lat": lat,
            "location_lng": lng
        },
        "weather_data": {},
        "cleaned_text": "",
        "detected_language": "",
        "normalized_location": "",
        "crisis_type": "",
        "crisis_confidence": 0,
        "severity": "",
        "severity_explanation": "",
        "confirming_sources": 0,
        "action_plan": [],
        "simulation_result": {
            "before_route": {},
            "after_route": {},
            "emergency_ticket": {},
            "alerts_dispatched": []
        },
        "trace": []
    }

    print(f"--- Starting CIRO Pipeline for Report {report_id} ---")

    # Step 0: Orchestrator Initial Narration
    state = narrate_decision(state, "SignalCollector")
    
    # Step 1: Signal Collector
    state = signal_collector(state)
    time.sleep(15)
    
    # Step 2: Transition to Crisis Detector
    state = narrate_decision(state, "CrisisDetector")
    state = crisis_detector(state)
    time.sleep(15)
    
    # Step 3: Transition to Reasoning Analyzer
    state = narrate_decision(state, "ReasoningAnalyzer")
    state = reasoning_analyzer(state)
    time.sleep(15)
    
    # Step 4: Transition to Action Planner
    state = narrate_decision(state, "ActionPlanner")
    state = action_planner(state)
    time.sleep(15)
    
    # Step 5: Transition to Simulator
    state = narrate_decision(state, "Simulator")
    state = simulator(state)

    print(f"--- CIRO Pipeline Complete ---")
    return state

if __name__ == "__main__":
    # Test full pipeline
    final_state = run_orchestrator(
        report_id="demo-uuid-123",
        report_text="Help! G-10 markaz mein road block hai accident ki wajah se. Ambulances cannot pass.",
        area_name="G-10 Islamabad",
        lat=33.6938,
        lng=73.0146
    )
    
    print("\nFINAL TRACE LOG:")
    for entry in final_state["trace"]:
        print(f"[{entry['agent']}] {entry.get('decision', entry.get('output_summary', 'No summary'))}")
    
    # Optional: Save to file for inspection
    with open("pipeline_result.json", "w") as f:
        json.dump(final_state, f, indent=2)
