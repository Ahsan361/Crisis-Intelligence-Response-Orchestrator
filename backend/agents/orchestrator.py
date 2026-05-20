import os
import json
import datetime
import time
from typing import Dict, Any, List
from dotenv import load_dotenv
from google.genai import types
from agents.client_manager import get_client

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
        print(f"Error in Orchestrator narration: {e}")
        result = fallback_result

    # Append Orchestrator trace entry
    trace_entry = {
        "agent": "Orchestrator",
        "timestamp": datetime.datetime.now(datetime.timezone.utc).isoformat(),
        "decision": result.get("narration", f"Invoking {next_agent}"),
        "confidence": result.get("confidence", 100)
    }
    
    state.setdefault("trace", [])
    state["trace"].append(trace_entry)
    
    return state

def save_pipeline_progress(report_id: str, state: Dict[str, Any], status: str = "analyzing"):
    try:
        from database import supabase
        
        valid_crisis_types = ["flood", "accident", "heatwave", "blockage", "infrastructure"]
        valid_severities = ["low", "medium", "high", "critical"]

        crisis_type = state.get("crisis_type", "")
        severity = state.get("severity", "")    
        
        update_data = {
            "status": status,
            "agent_trace": state.get("trace", []),
            "simulation_result": state.get("simulation_result", {}),
            "crisis_type": crisis_type if crisis_type in valid_crisis_types else None,
            "severity": severity if severity in valid_severities else None,
            "crisis_confidence": state.get("crisis_confidence", 0),
            "detected_language": state.get("detected_language", "Unknown"),
            "updated_at": datetime.datetime.now(datetime.timezone.utc).isoformat()
        }
        supabase.table("reports").update(update_data).eq("id", report_id).execute()
    except Exception as e:
        print(f"Error saving pipeline progress: {e}")

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
    save_pipeline_progress(report_id, state)
    
    # Step 1: Signal Collector
    state = signal_collector(state)
    save_pipeline_progress(report_id, state)
    time.sleep(15)
    
    # Step 2: Transition to Crisis Detector
    state = narrate_decision(state, "CrisisDetector")
    save_pipeline_progress(report_id, state)
    state = crisis_detector(state)
    save_pipeline_progress(report_id, state)
    time.sleep(15)
    
    # Step 3: Transition to Reasoning Analyzer
    state = narrate_decision(state, "ReasoningAnalyzer")
    save_pipeline_progress(report_id, state)
    state = reasoning_analyzer(state)
    save_pipeline_progress(report_id, state)
    time.sleep(15)
    
    # Step 4: Transition to Action Planner
    state = narrate_decision(state, "ActionPlanner")
    save_pipeline_progress(report_id, state)
    state = action_planner(state)
    save_pipeline_progress(report_id, state)
    time.sleep(15)
    
    # Step 5: Transition to Simulator
    state = narrate_decision(state, "Simulator")
    save_pipeline_progress(report_id, state)
    state = simulator(state)
    save_pipeline_progress(report_id, state, "simulated")

    print(f"--- CIRO Pipeline Complete ---")
    return state
