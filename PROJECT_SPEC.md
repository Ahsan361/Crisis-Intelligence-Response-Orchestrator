# CIRO — Project Specification Document
## Crisis Intelligence & Response Orchestrator
**Last Updated:** 2026-05-16 (Phase 4 complete)

---

# Project Overview

CIRO is an AI-powered crisis response system for metropolitan areas.  
It ingests crisis reports from multiple sources, runs them through a
multi-agent AI pipeline, and simulates coordinated emergency responses.

Built for Innovista Hackathon using Google Antigravity (ADK) for
multi-agent orchestration.

---

# Tech Stack

| Layer        | Technology                        |
|--------------|-----------------------------------|
| Backend      | Python, FastAPI, Uvicorn          |
| Database     | Supabase (PostgreSQL)             |
| AI Agents    | Google ADK, Gemini 2.0 Flash      |
| Weather API  | OpenWeatherMap                    |
| Maps API     | Google Maps Directions API        |
| Mobile App   | Flutter (Riverpod, GoRouter)      |

---

# Folder Structure

```text
Hackathon Innovista/
├── backend/
│   ├── .env
│   ├── main.py
│   ├── database.py
│   ├── models.py
│   ├── requirements.txt
│   └── agents/
│       ├── client_manager.py     # API Key rotation logic
│       ├── signal_collector.py   # Agent 1: Input Processing
│       ├── crisis_detector.py    # Agent 2: Classification
│       ├── reasoning_analyzer.py # Agent 3: Severity Assessment
│       ├── action_planner.py     # Agent 4: Response Strategy
│       ├── simulator.py          # Agent 5: Execution Simulation
│       └── orchestrator.py       # Pipeline Orchestration
├── ciro_mobile_client/
│   └── (Flutter project)
├── PROJECT_SPEC.md
└── ARCHITECTURE.md
```

---

# Database — Supabase

**Project:** Supabase hosted PostgreSQL
**Table:** `reports`

## Table Schema

| Column            | Type        | Nullable | Default   | Notes                          |
| ----------------- | ----------- | -------- | --------- | ------------------------------ |
| id                | uuid        | NO       | generated | Primary key                    |
| report_text       | text        | NO       | —         | Raw crisis report text         |
| source            | enum        | NO       | manual    | social_media, weather_api, etc.|
| reported_by       | text        | YES      | Unknown   | Free text                      |
| area_name         | text        | YES      | null      | Human readable area name       |
| location_lat      | float       | YES      | null      | Latitude coordinate            |
| location_lng      | float       | YES      | null      | Longitude coordinate           |
| crisis_type       | enum        | YES      | null      | flood, accident, etc.          |
| severity          | enum        | YES      | null      | low, medium, high, critical    |
| priority_score    | integer     | YES      | 0         | 0-100                          |
| status            | enum        | NO       | pending   | pending, simulated, etc.       |
| crisis_confidence | integer     | YES      | 0         | 0-100 (AI confidence)          |
| detected_language | text        | YES      | Unknown   | Detected input language        |
| agent_trace       | jsonb       | YES      | null      | Full pipeline reasoning log    |
| simulation_result | jsonb       | YES      | null      | Before/after simulation data   |
| created_at        | timestamptz | NO       | now()     | Auto set on insert             |
| updated_at        | timestamptz | NO       | now()     | Auto updated via trigger       |

---

# Backend — FastAPI

**Base URL (local):** `http://127.0.0.1:8000`
**Docs:** `http://127.0.0.1:8000/docs`

## Endpoints

### POST /reports
Create a new crisis report.
**Response:** `{"id": "uuid", ...}`

### GET /reports
Get all reports sorted by date.
**Query params:** `status`, `crisis_type`, `limit`.

### PATCH /reports/{report_id}
Update a report manually or via agents.

### POST /analyze-report
Trigger the full agent pipeline on a specific report.
**Request Body:**
```json
{
  "report_id": "uuid",
  "report_text": "text",
  "area_name": "area",
  "location_lat": 0.0,
  "location_lng": 0.0
}
```
**Response:** Full `state` dictionary including `trace` and `simulation_result`.

---

# Agent Pipeline

**Framework:** Google ADK
**Model:** `gemini-flash-latest` (with 4-key rotation)

## Agent Execution Order

1. **SignalCollector**: Cleans text, handles multi-language support.
2. **CrisisDetector**: Identifies crisis type (flood, accident, etc.).
3. **ReasoningAnalyzer**: Calculates severity and priority score.
4. **ActionPlanner**: Generates response actions for emergency services.
5. **Simulator**: Simulates routes and generates emergency tickets.

---

# Build Status

| Phase | Description                   | Status      |
| ----- | ----------------------------- | ----------- |
| 1     | DB setup + FastAPI connection | COMPLETE    |
| 2     | ADK agents build              | COMPLETE    |
| 3     | FastAPI pipeline server       | COMPLETE    |
| 4     | Flutter mobile app            | COMPLETE    |
| 5     | Simulation layer + routing    | COMPLETE    |
| 6     | Demo prep + video             | IN PROGRESS |

---

# Rules for Development

* Use `.env` for all credentials.
* Backend always uses `SERVICE_ROLE` key; Mobile uses `ANON` key.
* Maintain `agent_trace` as a valid JSON list of agent decisions.
* All new features must be documented here first.
