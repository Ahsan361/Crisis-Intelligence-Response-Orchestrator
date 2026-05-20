import os
import json
import datetime
from typing import Dict, Any
from dotenv import load_dotenv
from google.genai import types
from agents.client_manager import get_client

# Load environment variables
load_dotenv()

def reasoning_analyzer(state: Dict[str, Any]) -> Dict[str, Any]:
    """
    Estimates severity, explains reasoning, and counts confirming sources.
    """
    cleaned_text = state.get("cleaned_text", "")
    crisis_type = state.get("crisis_type", "unknown")
    
    prompt = f"""
    You are the Reasoning Analyzer agent for CIRO (Crisis Intelligence & Response Orchestrator).
    Your job is to analyze the crisis report to determine severity and extract supporting details.

    Input Data:
    Crisis Type: {crisis_type}
    Report Text: {cleaned_text}

    Tasks:
    1. Estimate Severity: Choose from [low, medium, high, critical].
    2. Explain Reasoning: Provide a brief explanation for the chosen severity level.
    3. Confirming Sources: Based on the text, estimate how many distinct sources or reports seem to confirm this (e.g., if the text mentions "many people calling" or "multiple reports"). If not clear, default to 1.

    Output format:
    Return ONLY a JSON object with the following keys:
    {{
      "severity": "string",
      "severity_explanation": "string",
      "confirming_sources": integer,
      "decision": "string explaining your reasoning process",
      "confidence": integer (0-100)
    }}
    """

    # Fallback state in case of failure
    fallback_output = {
        "severity": "medium",
        "severity_explanation": "Unable to analyze severity; defaulting to medium.",
        "confirming_sources": 1,
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
        print(f"Error in ReasoningAnalyzer Vertex AI call: {e}")
        result = fallback_output

    # Update the shared state
    state["severity"] = result.get("severity", "medium")
    state["severity_explanation"] = result.get("severity_explanation", "")
    state["confirming_sources"] = result.get("confirming_sources", 1)
    
    # Append trace log
    trace_entry = {
        "agent": "ReasoningAnalyzer",
        "timestamp": datetime.datetime.now(datetime.timezone.utc).isoformat(),
        "input_summary": f"Analyzing severity for {crisis_type} crisis",
        "decision": result.get("decision", "Evaluated crisis severity"),
        "confidence": result.get("confidence", 0),
        "output_summary": f"Severity: {state['severity']}. Sources: {state['confirming_sources']}"
    }
    
    state.setdefault("trace", [])
    state["trace"].append(trace_entry)

    return state

# if __name__ == "__main__":
#     # Test script for ReasoningAnalyzer
#     test_state = {
#         "report_id": "test-uuid",
#         "cleaned_text": "Massive flooding in G-10. Multiple houses submerged. People are stranded on roofs.",
#         "crisis_type": "flood",
#         "trace": []
#     }
    
#     updated_state = reasoning_analyzer(test_state)
#     print(json.dumps(updated_state, indent=2))
