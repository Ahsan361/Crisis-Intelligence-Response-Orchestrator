# 🚨 CIRO — Crisis Intelligence & Response Orchestrator

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![FastAPI](https://img.shields.io/badge/FastAPI-005571?style=for-the-badge&logo=fastapi)
![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)
![Gemini](https://img.shields.io/badge/Gemini_2.5-8E75B2?style=for-the-badge&logo=google&logoColor=white)

---

## 🎬 **📱 MOBILE APP DEMO**

### **Watch the full mobile application demonstration:**

🔗 **[View Demo Video on Google Drive](https://drive.google.com/YOUR_DRIVE_LINK_HERE)**

#### 📹 Embedded Demo Player:
<!-- Replace the Google Drive link ID in the src below with your actual video ID -->
<iframe 
  src="https://drive.google.com/file/d/YOUR_DRIVE_FILE_ID/preview" 
  width="100%" 
  height="480" 
  allow="autoplay">
</iframe>

> **Note**: The video above shows the complete CIRO mobile client in action, including real-time crisis reporting, agent pipeline visualization, and emergency response simulation.

---

## 📖 Project Overview
CIRO is an AI-powered system built for the Innovista Hackathon. It acts as an intelligent command center for metropolitan areas (focusing on Islamabad), digesting crisis signals from citizens, weather[...]

## 🏗️ Architecture Diagram

```text
[ Citizen App (Flutter) ] & [ Web Dashboard (React) ]
          |                              |
          +------------> [ RESTful API ] <-------------+
                         (FastAPI + Python)            |
                                |                      |
[ Social Media Seeder ] --+     v                      |
[ Weather Monitor     ] --+--> [ Supabase PostgreSQL ] | (Real-time Sync)
[ Traffic Simulator   ] --+     |                      |
                                v                      |
                       [ Google Antigravity ]          |
                       [ 5-Agent Pipeline   ] ---------+
```

## 🤖 Agent Pipeline
CIRO employs a sequential 5-agent pipeline orchestrated by Google Antigravity:

| Agent | Purpose | Inputs | Outputs |
|-------|---------|--------|---------|
| **Signal Collector** | Cleans text and detects language (e.g. Roman Urdu). | Raw text, Location | Cleaned text, Detected Language |
| **Crisis Detector** | Categorizes intent and assigns an AI confidence score. | Cleaned text | Crisis Type, Confidence Score |
| **Reasoning Analyzer** | Evaluates the situation context to assign severity. | Crisis Type, Area | Severity Level, Priority Score |
| **Action Planner** | Generates response strategies mapped to departments. | Severity, Crisis Type | Action Plan (Rescue 1122, Police) |
| **Simulator** | Simulates logistics, route detours, and ETAs. | Action Plan, Area | Before/After ETAs, Emergency Ticket |

## 📊 Data Schemas
Key fields in the Supabase `reports` table:

| Column | Type | Description |
|--------|------|-------------|
| `id` / `created_at` | UUID / Timestamp | Unique identifier and creation time. |
| `report_text` / `area_name`| Text | Raw description and human-readable location. |
| `location_lat` / `location_lng` | Float | GPS Coordinates of the crisis. |
| `crisis_type` / `severity` | Enum | Categorization (e.g., flood, critical). |
| `crisis_confidence` / `detected_language` | Integer / Text | **AI Transparency Metrics.** |
| `agent_trace` / `simulation_result`| JSONB | Full pipeline reasoning log and ETA data. |

## 🛠️ Tools and APIs Used

| Tool/API | Usage in CIRO |
|----------|---------------|
| **Google Gemini 2.5 Flash** | Core LLM powering the 5 agents and orchestrator narrations. |
| **Supabase** | PostgreSQL database with real-time updates for UI sync. |
| **OpenWeatherMap** | Triggers automated weather crises (heavy rain, extreme heat). |
| **TomTom Simulation** | Heuristic fallback simulating Islamabad peak rush-hour blockages. |
| **OpenStreetMap** | Nominatim reverse geocoding for mobile incident reporting. |

## 🚀 Antigravity Role
Google Antigravity serves as the core orchestration engine. It utilizes a **Mechanism 4 Appearance** (Narrated Handover) where the central Orchestrator LLM not only passes state sequentially betwe[...]

## ⚙️ Setup Steps

**1. Environment Variables (`.env`)**
```env
GEMINI_API_KEY=your_gemini_key
SUPABASE_URL=your_supabase_url
SUPABASE_SERVICE_KEY=your_supabase_service_key
OWM_API_KEY=your_open_weather_map_key
```

**2. Backend Setup**
```bash
cd backend
pip install -r requirements.txt
uvicorn main:app --reload
```

**3. Mobile App (Flutter)**
```bash
cd ciro_mobile_client
flutter pub get
flutter run
```

**4. Web Dashboard (React/Vite)**
```bash
cd ciro_dashboard
npm install
npm run dev
```

## 📡 Multi-Source Ingestion
CIRO actively listens to four intelligence vectors:
1. **Manual Reports**: Submitted via the Flutter mobile client with exact GPS.
2. **Social Media Seeder**: A background script (`seeder.py`) pushing synthetic citizen tweets.
3. **Weather API**: OpenWeatherMap monitor triggering alerts on heavy rain (>0.1mm) or heat (>25°C).
4. **Traffic Simulation**: Time-based heuristic spawning congestion alerts on key Islamabad routes during rush hour.

## ⏱️ Auto-Resolve Logic
A background task `auto_resolve_reports` continually polls `simulated` reports. It extracts the `after_route.eta_minutes` generated by the Simulator agent, adds it to the report's `created_at` ti[...]

## 💰 Cost Per Operation Estimate
Each crisis report triggers a full pipeline run consisting of 5 distinct Agent calls + up to 4 Orchestrator transition calls. 
**Total Estimate**: ~9 Gemini 2.5 Flash API calls per report.

## 📈 Scalability (10x/100x Discussion)
CIRO can scale easily due to stateless FastAPI workers and Supabase's connection pooling. If reports increase 100x (e.g., major earthquake), the primary bottleneck becomes LLM rate limits (`429` [...]

## ⚖️ Baseline Comparison
- **Simple Heuristic System**: "If text contains 'fire', alert Fire Dept." (Fails on: "I just fired my boss" or "This song is fire").
- **CIRO Agentic System**: Context-aware pipeline that not only detects the true intent but assigns severity, simulates dynamic traffic detours around the crisis, and coordinates cross-department[...]

## 🛡️ Robustness Evidence (Failure Scenarios)
- **LLM Parsing Failures**: If the Simulator agent hallucinated bad JSON, it catches the exception and returns a pre-defined fallback JSON, ensuring the pipeline never breaks.
- **API Rate Limits**: Handled gracefully via the `ClientManager` rotating API keys.
- **Missing Traffic Data**: Used a time-based traffic heuristic (TomTom Simulation) when live local traffic coverage for Islamabad was unavailable.

## 🔒 Privacy Note
All personally identifiable information (PII) such as `reported_by` is entirely optional. Citizens can submit life-saving intelligence completely anonymously.

## ⚠️ Assumptions and Limitations
- Assumes mobile devices have active internet connectivity.
- Traffic ETAs are heuristic estimates for Islamabad, as live regional TomTom coverage is limited.
