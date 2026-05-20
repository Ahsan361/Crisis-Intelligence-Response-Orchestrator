from fastapi import FastAPI, HTTPException, Query
from fastapi.middleware.cors import CORSMiddleware
from typing import List, Optional
from pydantic import BaseModel
from contextlib import asynccontextmanager
from datetime import datetime, timezone, timedelta
import asyncio
import json
import os
import httpx
import random

from database import supabase
from models import Report, ReportCreate, ReportUpdate, ReportStatus, CrisisType
from agents.orchestrator import run_orchestrator

async def weather_monitor():
    owm_api_key = os.environ.get("OWM_API_KEY")
    if not owm_api_key or owm_api_key == "your_key_here":
        print("OWM_API_KEY is not configured properly. Weather monitor will not run.")
        return
        
    while True:
        try:
            url = f"https://api.openweathermap.org/data/2.5/weather?q=Islamabad,PK&appid={owm_api_key}&units=metric"
            async with httpx.AsyncClient() as client:
                response = await client.get(url)
                if response.status_code == 200:
                    data = response.json()
                    
                    # Extract conditions
                    rain_1h = data.get("rain", {}).get("1h", 0)
                    temp = data.get("main", {}).get("temp", 0)
                    wind_speed = data.get("wind", {}).get("speed", 0)
                    lat = data.get("coord", {}).get("lat", 33.6844)
                    lon = data.get("coord", {}).get("lon", 73.0479)
                    
                    hint_keyword = None
                    report_text = None
                    
                    if rain_1h > 0.1: #10 orignally changed to 0.1 for testing with light rain
                        hint_keyword = "flood"
                        report_text = f"OpenWeatherMap detected heavy rainfall of {rain_1h}mm/hr in Islamabad. Flood risk elevated."
                    elif temp > 25: #42 orignally chhanged to 25
                        hint_keyword = "heatwave"
                        report_text = f"OpenWeatherMap detected extreme temperature of {temp}°C in Islamabad. Heatwave risk elevated."
                    elif wind_speed > 3:  #16 orignally
                        hint_keyword = "infrastructure"
                        report_text = f"OpenWeatherMap detected high wind speeds of {wind_speed}m/s in Islamabad. Infrastructure damage risk elevated."
                        
                    if hint_keyword and report_text:
                        # Check for duplicates in the last 2 hours
                        two_hours_ago = (datetime.now(timezone.utc) - timedelta(hours=2)).isoformat()
                        
                        recent_reports = supabase.table("reports").select("report_text").eq("source", "weather_api").gte("created_at", two_hours_ago).execute()
                        
                        is_duplicate = False
                        if recent_reports.data:
                            for r in recent_reports.data:
                                text_lower = r.get("report_text", "").lower()
                                if hint_keyword in text_lower or (hint_keyword == "infrastructure" and "wind" in text_lower):
                                    is_duplicate = True
                                    break
                                    
                        if not is_duplicate:
                            print(f"Weather monitor threshold crossed! Inserting report for: {hint_keyword}")
                            new_report = {
                                "report_text": report_text,
                                "area_name": "Islamabad",
                                "location_lat": lat,
                                "location_lng": lon,
                                "source": "weather_api",
                                "reported_by": "OpenWeatherMap",
                                "status": "pending"
                            }
                            supabase.table("reports").insert(new_report).execute()
        except Exception as e:
            print(f"Weather monitor error: {e}")
            
        await asyncio.sleep(1800)  # every 30 minutes

async def traffic_monitor():
    # tomtom_api_key = os.environ.get("TOMTOM_API_KEY")
    # if not tomtom_api_key or tomtom_api_key == "your_key_here":
    #     print("TOMTOM_API_KEY is not configured properly. Traffic monitor will not run.")
    #     return
    # Initially I was planning to use TomTom API to check traffic but it doesnt have coverage for Islamabad, so I am using a simulation approach based on rush hours.
        
    RUSH_HOURS = [
        (6, 9),   # morning rush
        (12, 14), # lunch
        (17, 20), # evening rush
    ]

    ROADS = [
        {"name": "Islamabad Highway", "lat": 33.6938, "lng": 73.0479},
        {"name": "Faizabad Interchange", "lat": 33.7180, "lng": 73.0551},
        {"name": "Blue Area", "lat": 33.7215, "lng": 73.0434},
        {"name": "G-10 Markaz", "lat": 33.6844, "lng": 73.0146},
        {"name": "F-7 Markaz", "lat": 33.7267, "lng": 73.0360},
    ]
    
    while True:
        try:
            # Get current hour in PKT (UTC+5)
            current_hour = datetime.now(timezone(timedelta(hours=5))).hour
            
            is_rush_hour = any(start <= current_hour < end for start, end in RUSH_HOURS)
            
            if is_rush_hour:
                road = random.choice(ROADS)
                report_text = f"Traffic simulation detected severe congestion on {road['name']} during peak hours. Estimated speed reduced to 15km/h."
                
                # Check for duplicates in the last 2 hours
                two_hours_ago = (datetime.now(timezone.utc) - timedelta(hours=2)).isoformat()
                
                recent_reports = supabase.table("reports").select("area_name").eq("source", "traffic_api").gte("created_at", two_hours_ago).execute()
                
                is_duplicate = False
                if recent_reports.data:
                    for r in recent_reports.data:
                        if r.get("area_name") == road["name"]:
                            is_duplicate = True
                            break
                            
                if not is_duplicate:
                    print(f"Traffic monitor simulation! Inserting blockage report for: {road['name']}")
                    new_report = {
                        "report_text": report_text,
                        "area_name": road["name"],
                        "location_lat": road["lat"],
                        "location_lng": road["lng"],
                        "source": "traffic_api",
                        "reported_by": "CIRO Traffic Monitor",
                        "status": "pending"
                    }
                    supabase.table("reports").insert(new_report).execute()
        except Exception as e:
            print(f"Traffic monitor error: {e}")
            
        await asyncio.sleep(1800)  # every 30 seconds for testing

async def auto_resolve_reports():
    while True:
        await asyncio.sleep(300)
        try:
            response = supabase.table("reports").select("*").eq("status", "simulated").execute()
            if response.data:
                for report in response.data:
                    sim_result = report.get("simulation_result")
                    if not sim_result or not isinstance(sim_result, dict):
                        continue
                    
                    after_route = sim_result.get("after_route")
                    if not after_route or not isinstance(after_route, dict):
                        continue
                        
                    eta_minutes = after_route.get("eta_minutes")
                    if eta_minutes is None or eta_minutes == 0:
                        continue
                    
                    created_at_str = report.get("created_at")
                    if not created_at_str:
                        continue
                        
                    try:
                        created_at = datetime.fromisoformat(created_at_str)
                        if created_at.tzinfo is None:
                            created_at = created_at.replace(tzinfo=timezone.utc)
                    except Exception as parse_err:
                        print(f"Error parsing created_at for report {report.get('id')}: {parse_err}")
                        continue
                    
                    try:
                        eta_val = float(eta_minutes)
                    except (ValueError, TypeError):
                        continue
                        
                    resolve_at = created_at + timedelta(minutes=eta_val)
                    
                    if datetime.now(timezone.utc) > resolve_at:
                        # Update status to resolved
                        print(f"Auto-resolving report {report.get('id')} (ETA: {eta_val} mins)")
                        supabase.table("reports").update({
                            "status": ReportStatus.RESOLVED.value,
                            "updated_at": datetime.now(timezone.utc).isoformat()
                        }).eq("id", report.get("id")).execute()
                        
        except Exception as e:
            print(f"Auto-resolve error: {e}")

import subprocess
import sys

# Seeder State Management for Dashboard Simulator (triggers standalone seeder.py)
class SeederState:
    def __init__(self):
        self.running: bool = False
        self.interval_minutes: int = 4
        self.process: Optional[subprocess.Popen] = None
        self.task: Optional[asyncio.Task] = None
        self.total_seeded: int = 0
        self.last_updated: str = datetime.now(timezone.utc).isoformat()
        self.logs: list = []

seeder_state = SeederState()

async def read_seeder_stdout():
    """Reads stdout of the seeder.py subprocess and logs it in real-time."""
    proc = seeder_state.process
    if not proc:
        return
        
    loop = asyncio.get_running_loop()
    
    try:
        while proc.poll() is None and seeder_state.running:
            # Read stdout line non-blockingly using loop executor
            line = await loop.run_in_executor(None, proc.stdout.readline)
            if not line:
                await asyncio.sleep(0.2)
                continue
                
            stripped = line.strip()
            if not stripped:
                continue
                
            print(f"[seeder.py] {stripped}")
            
            # Detect successful insert from seeder.py output
            if "SUCCESS" in stripped:
                seeder_state.total_seeded += 1
                seeder_state.last_updated = datetime.now(timezone.utc).isoformat()
                
            # Log the message
            seeder_state.logs.insert(0, {
                "created_at": datetime.now(timezone.utc).isoformat(),
                "message": stripped
            })
            if len(seeder_state.logs) > 50:
                seeder_state.logs = seeder_state.logs[:50]
                
    except asyncio.CancelledError:
        pass
    except Exception as e:
        print(f"Error reading seeder subprocess stdout: {e}")

@asynccontextmanager
async def lifespan(app: FastAPI):
    task1 = asyncio.create_task(auto_resolve_reports())
    task2 = asyncio.create_task(weather_monitor())
    task3 = asyncio.create_task(traffic_monitor())
    yield
    task1.cancel()
    task2.cancel()
    task3.cancel()
    if seeder_state.running or seeder_state.process:
        seeder_state.running = False
        if seeder_state.task:
            seeder_state.task.cancel()
        if seeder_state.process:
            try:
                seeder_state.process.terminate()
                seeder_state.process.wait(timeout=2)
            except Exception:
                try:
                    seeder_state.process.kill()
                except Exception:
                    pass

app = FastAPI(
    title="CIRO API", 
    description="Crisis Intelligence & Response Orchestrator Backend",
    lifespan=lifespan
)

# Configure CORS Middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class AnalyzeRequest(BaseModel):
    report_id: str
    report_text: str
    area_name: str
    location_lat: float
    location_lng: float

@app.get("/")
async def root():
    return {"message": "Welcome to CIRO API - Crisis Intelligence & Response Orchestrator"}

@app.post("/reports", response_model=Report, status_code=201)
async def create_report(report: ReportCreate):
    report_data = report.model_dump()
    
    # Insert report into Supabase
    response = supabase.table("reports").insert(report_data).execute()
    
    if not response.data:
        raise HTTPException(status_code=400, detail="Failed to create report")
        
    return response.data[0]

@app.get("/reports", response_model=List[Report])
async def get_reports(
    status: Optional[ReportStatus] = None,
    crisis_type: Optional[CrisisType] = None,
    limit: int = Query(100, le=1000)
):
    query = supabase.table("reports").select("*")
    
    # Apply filters if provided
    if status:
        query = query.eq("status", status)
    if crisis_type:
        query = query.eq("crisis_type", crisis_type)
        
    response = query.order("created_at", desc=True).limit(limit).execute()
    
    return response.data

@app.get("/reports/{report_id}", response_model=Report)
async def get_report(report_id: str):
    response = supabase.table("reports").select("*").eq("id", report_id).execute()
    
    if not response.data:
        raise HTTPException(status_code=404, detail="Report not found")
        
    return response.data[0]

@app.patch("/reports/{report_id}", response_model=Report)
async def update_report(report_id: str, report_update: ReportUpdate):
    update_data = report_update.model_dump(exclude_unset=True)
    update_data["updated_at"] = datetime.now(timezone.utc).isoformat()
    
    response = supabase.table("reports").update(update_data).eq("id", report_id).execute()
    
    if not response.data:
        raise HTTPException(status_code=404, detail="Report not found or update failed")
        
    return response.data[0]

@app.delete("/reports/{report_id}")
async def delete_report(report_id: str):
    response = supabase.table("reports").delete().eq("id", report_id).execute()
    
    if not response.data:
        raise HTTPException(status_code=404, detail="Report not found or already deleted")
        
    return {"message": "Report deleted successfully"}

@app.post("/analyze-report")
async def analyze_report(req: AnalyzeRequest):
    # 1. Call run_orchestrator with the provided values in a background thread
    state = await asyncio.to_thread(
        run_orchestrator,
        report_id=req.report_id,
        report_text=req.report_text,
        area_name=req.area_name,
        lat=req.location_lat,
        lng=req.location_lng
    )

    valid_crisis_types = ["flood", "accident", "heatwave", "blockage", "infrastructure"]
    valid_severities = ["low", "medium", "high", "critical"]

    crisis_type = state.get("crisis_type", "")
    severity = state.get("severity", "")    
    
    # 2. Extract relevant fields from the pipeline state to save to Supabase
    # The pipeline state dict contains "trace", "simulation_result", etc.
    update_data = {
        "status": ReportStatus.SIMULATED.value,  # Mark as simulated since the pipeline finished
        "agent_trace": state.get("trace", []),
        "simulation_result": state.get("simulation_result", {}),
        "crisis_type": crisis_type if crisis_type in valid_crisis_types else None,
        "severity": severity if severity in valid_severities else None,
        "crisis_confidence": state.get("crisis_confidence", 0),
        "detected_language": state.get("detected_language", "Unknown"),
        "updated_at": datetime.now(timezone.utc).isoformat()
    }
    
    # 3. Save the result to Supabase
    response = supabase.table("reports").update(update_data).eq("id", req.report_id).execute()
    
    if not response.data:
        raise HTTPException(status_code=404, detail="Report not found when attempting to save pipeline results")
        
    # 4. Return the full state dict
    return state

# Seeder REST API Endpoints
class SeederStartRequest(BaseModel):
    interval_minutes: int

@app.get("/seeder/status")
async def get_seeder_status():
    return {
        "running": seeder_state.running,
        "status": "running" if seeder_state.running else "stopped",
        "total_seeded": seeder_state.total_seeded,
        "last_updated": seeder_state.last_updated,
        "logs": seeder_state.logs
    }

@app.post("/seeder/start")
async def start_seeder_endpoint(req: SeederStartRequest):
    if seeder_state.running or seeder_state.process is not None:
        return {"message": "Seeder is already running", "status": "running"}
        
    import subprocess
    import sys
    
    env = os.environ.copy()
    env["PYTHONUNBUFFERED"] = "1"
    
    backend_dir = os.path.dirname(os.path.abspath(__file__))
    seeder_path = os.path.join(backend_dir, "seeder.py")
    
    try:
        seeder_state.process = subprocess.Popen(
            [sys.executable, seeder_path],
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            env=env,
            cwd=backend_dir
        )
        seeder_state.running = True
        seeder_state.interval_minutes = req.interval_minutes
        seeder_state.task = asyncio.create_task(read_seeder_stdout())
        
        log_msg = f"Seeder process (seeder.py) spawned successfully (PID: {seeder_state.process.pid})"
        print(log_msg)
        seeder_state.logs.insert(0, {
            "created_at": datetime.now(timezone.utc).isoformat(),
            "message": log_msg
        })
        
        return {
            "message": "Seeder process started successfully",
            "running": seeder_state.running,
            "status": "running"
        }
    except Exception as e:
        seeder_state.running = False
        seeder_state.process = None
        raise HTTPException(status_code=500, detail=f"Failed to start seeder process: {e}")

@app.post("/seeder/stop")
async def stop_seeder_endpoint():
    if not seeder_state.running or seeder_state.process is None:
        return {"message": "Seeder is not running", "status": "stopped"}
        
    seeder_state.running = False
    
    if seeder_state.task:
        seeder_state.task.cancel()
        seeder_state.task = None
        
    proc = seeder_state.process
    try:
        proc.terminate()
        try:
            proc.wait(timeout=2)
        except subprocess.TimeoutExpired:
            proc.kill()
            proc.wait()
    except Exception as e:
        print(f"Error terminating seeder process: {e}")
    finally:
        seeder_state.process = None
        
    log_msg = "Seeder process (seeder.py) stopped manually"
    print(log_msg)
    seeder_state.logs.insert(0, {
        "created_at": datetime.now(timezone.utc).isoformat(),
        "message": log_msg
    })
    
    return {
        "message": "Seeder stopped successfully",
        "running": seeder_state.running,
        "status": "stopped"
    }

@app.post("/seeder/seed-now")
async def seed_now_endpoint():
    from data.seed_reports import REPORTS_POOL
    import random
    
    try:
        report_data = random.choice(REPORTS_POOL)
        db_report = {
            "report_text": report_data["report_text"],
            "source": "social_media",
            "reported_by": report_data["reported_by"],
            "area_name": report_data["area_name"],
            "location_lat": report_data["location_lat"],
            "location_lng": report_data["location_lng"],
            "status": "pending"
        }
        
        response = supabase.table("reports").insert(db_report).execute()
        if not response.data:
            raise HTTPException(status_code=400, detail="Failed to insert report via Supabase")
            
        inserted_report = response.data[0]
        seeder_state.total_seeded += 1
        seeder_state.last_updated = datetime.now(timezone.utc).isoformat()
        
        log_msg = f"SUCCESS (Manual): Seeded report in {db_report['area_name']} (ID: {inserted_report['id']})"
        print(log_msg)
        
        seeder_state.logs.insert(0, {
            "id": inserted_report['id'],
            "created_at": datetime.now(timezone.utc).isoformat(),
            "message": log_msg
        })
        if len(seeder_state.logs) > 50:
            seeder_state.logs = seeder_state.logs[:50]
            
        return {
            "message": "Report seeded successfully",
            "report": inserted_report
        }
    except Exception as e:
        err_msg = f"Manual Seed Error: {e}"
        print(err_msg)
        seeder_state.logs.insert(0, {
            "created_at": datetime.now(timezone.utc).isoformat(),
            "message": err_msg
        })
        if len(seeder_state.logs) > 50:
            seeder_state.logs = seeder_state.logs[:50]
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
