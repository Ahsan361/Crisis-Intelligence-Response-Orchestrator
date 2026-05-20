# CIRO Agents

This document defines the specialized AI agents operating within the `.agents` framework for CIRO development and maintenance.

## Agent A: Backend (FastAPI, Supabase, Python)
- **Role:** Backend API Developer & Database Integrator
- **Responsibilities:** Develop and maintain RESTful endpoints, orchestrate background tasks (e.g., `weather_monitor`, `traffic_monitor`), manage Supabase Python Client operations, and define Pydantic schemas.
- **Tools:** Python 3.11, FastAPI, Uvicorn, Supabase Python Client, Asyncio.
- **Files Owned:** `backend/main.py`, `backend/models.py`, `backend/database.py`.

## Agent B: AI Pipeline (Gemini agents, orchestrator)
- **Role:** Multi-Agent System Orchestrator
- **Responsibilities:** Design and maintain the 5-agent sequential pipeline, handle LLM prompting, execute Mechanism 4 narrated handovers, manage shared state updates, and ensure `client_manager.py` successfully rotates API keys to avoid 429s.
- **Tools:** Google GenAI SDK (Gemini 2.5 Flash), Google Antigravity.
- **Files Owned:** `backend/agents/*.py`.

## Agent C: Flutter Frontend (Dart, Riverpod, GoRouter)
- **Role:** Mobile Application Engineer
- **Responsibilities:** Build and maintain the "NASA Mission Control" themed UI, implement complex state management using Riverpod 3.x Notifier API, configure GoRouter navigation, and integrate OpenStreetMap (flutter_map).
- **Tools:** Flutter, Dart, Riverpod, GoRouter, flutter_map, dio.
- **Files Owned:** `ciro_mobile_client/lib/*`, `ciro_mobile_client/pubspec.yaml`.

## Agent D: DevOps & Config (env, deployment, seeder)
- **Role:** Infrastructure & Configuration Manager
- **Responsibilities:** Manage API keys, environment variables, standalone background scripts (like the social media `seeder.py`), and maintain dashboard configurations.
- **Tools:** Python subprocess, dotenv, Node.js (Dashboard).
- **Files Owned:** `backend/.env`, `backend/seeder.py`, `ciro_dashboard/*`, `ciro_mobile_client/lib/config/app_config.dart`.

## Agent E: Documentation & README
- **Role:** Technical Documentation Writer
- **Responsibilities:** Keep all project documentation aligned with the current codebase, write judge-ready Hackathon explanations, generate Mermaid/ASCII architecture diagrams, and ensure SKILL/Workflow docs are accurate.
- **Tools:** Markdown, Mermaid JS.
- **Files Owned:** `README.md`, `PROJECT_SPEC.md`, `ARCHITECTURE.md`, `.agents/**/*.md`.
