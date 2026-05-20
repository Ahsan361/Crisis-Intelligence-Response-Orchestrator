import os
import json
import datetime
from typing import Dict, Any
from dotenv import load_dotenv
from google.genai import types
from agents.client_manager import get_client


# Load environment variables
load_dotenv()

# Initialize the model
def crisis_detector(state: Dict[str, Any]) -> Dict[str, Any]:
    """
    Identifies the crisis type and confidence based on the cleaned text.
    """
    cleaned_text = state.get("cleaned_text", "")
    
    prompt = f"""
    You are the Crisis Detector agent for CIRO (Crisis Intelligence & Response Orchestrator).
    Your job is to identify the type of crisis from the cleaned report text.

    Input Text:
    {cleaned_text}

    Valid Crisis Types:
    - flood
    - accident
    - heatwave
    - blockage
    - infrastructure

    Tasks:
    1. Identify the most likely crisis_type from the list above.
    2. Assign a confidence score (0-100) to this identification.

    Output format:
    Return ONLY a JSON object with the following keys:
    {{
      "crisis_type": "string",
      "crisis_confidence": integer,
      "decision": "string explaining why you chose this crisis type",
      "confidence": integer (0-100)
    }}
    """

    # Fallback state in case of failure
    fallback_output = {
        "crisis_type": "unknown",
        "crisis_confidence": 0,
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
        print(f"Error in CrisisDetector Vertex AI call: {e}")
        result = fallback_output

    # Update the shared state
    state["crisis_type"] = result.get("crisis_type", "unknown")
    state["crisis_confidence"] = result.get("crisis_confidence", 0)
    
    # Append trace log
    trace_entry = {
        "agent": "CrisisDetector",
        "timestamp": datetime.datetime.now(datetime.timezone.utc).isoformat(),
        "input_summary": f"Analyzing cleaned text: '{cleaned_text[:50]}...'",
        "decision": result.get("decision", "Identified crisis type"),
        "confidence": result.get("confidence", 0),
        "output_summary": f"Detected {state['crisis_type']} with {state['crisis_confidence']}% confidence"
    }
    
    state.setdefault("trace", [])
    state["trace"].append(trace_entry)

    return state
