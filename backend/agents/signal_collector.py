import os
import json
import datetime
from typing import Dict, Any
from dotenv import load_dotenv
from google.genai import types
from agents.client_manager import get_client, rotate_client

# Load environment variables
load_dotenv()

def signal_collector(state: Dict[str, Any]) -> Dict[str, Any]:
    """
    Cleans and normalizes the report text, detects the language, 
    and normalizes the location.
    """
    raw_input = state.get("raw_input", {})
    report_text = raw_input.get("report_text", "")
    area_name = raw_input.get("area_name", "Unknown")
    lat = raw_input.get("location_lat", 0.0)
    lng = raw_input.get("location_lng", 0.0)

    prompt = f"""
    You are the Signal Collector agent for CIRO (Crisis Intelligence & Response Orchestrator).
    Your job is to clean/normalize text and detect the language used in a crisis report.

    Input Report:
    Text: {report_text}
    Area: {area_name}
    Location: ({lat}, {lng})

    Tasks:
    1. Clean the text: Remove noise, fix minor typos, and ensure it's readable while preserving the original meaning.
    2. Detect Language: Identify if the text is English, Urdu (Perso-Arabic script), Roman Urdu (Urdu written in English alphabets), or Mixed.
    3. Normalize Location: Create a clean location string based on the area name and coordinates.

    Output format:
    Return ONLY a JSON object with the following keys:
    {{
      "cleaned_text": "string",
      "detected_language": "string",
      "normalized_location": "string",
      "decision": "string explaining how you cleaned and detected the language",
      "confidence": integer (0-100)
    }}
    """

    # Fallback state in case of failure
    fallback_output = {
        "cleaned_text": report_text,
        "detected_language": "unknown",
        "normalized_location": f"{area_name} ({lat}, {lng})",
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
        if "429" in str(e):
            print("Rate limit hit. Rotating API key...")
            rotate_client()
            try:
                result = call_gemini()
            except Exception as e2:
                print(f"Retry also failed: {e2}")
                result = fallback_output
        else:
            print(f"Error in SignalCollector Gemini call: {e}")
            result = fallback_output

    # Update the shared state
    state["cleaned_text"] = result.get("cleaned_text", report_text)
    state["detected_language"] = result.get("detected_language", "unknown")
    state["normalized_location"] = result.get("normalized_location", f"{area_name} ({lat}, {lng})")
    
    # Append trace log
    trace_entry = {
        "agent": "SignalCollector",
        "timestamp": datetime.datetime.now(datetime.timezone.utc).isoformat(),
        "input_summary": f"Received report text of length {len(report_text)}",
        "decision": result.get("decision", "Processed input signals"),
        "confidence": result.get("confidence", 0),
        "output_summary": f"Detected {state['detected_language']} language. Normalized location to {state['normalized_location']}"
    }
    
    if "trace" not in state:
        state["trace"] = []
    state["trace"].append(trace_entry)

    return state

if __name__ == "__main__":
    # Test script for SignalCollector
    test_state = {
        "report_id": "test-uuid",
        "raw_input": {
            "report_text": "G-10 mein pani bhar gaya hai heavy rain ki wajah se",
            "area_name": "G-10 Markaz",
            "location_lat": 33.6938,
            "location_lng": 73.0146
        },
        "trace": []
    }
    
    updated_state = signal_collector(test_state)
    print(json.dumps(updated_state, indent=2))
