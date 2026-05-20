# CIRO Dashboard & FastAPI Backend Connection Report

This report summarizes all modifications made to connect the **Crisis Intelligence & Response Orchestrator (CIRO) React Dashboard** to the running **FastAPI Backend** (at `http://127.0.0.1:8000`).

---

## 1. Frontend Environment Setup
**File modified**: `ciro_dashboard/.env`  
**Purpose**: Update the base API URL to point to the user's running Uvicorn backend (`127.0.0.1:8000`).

### Code Diff:
```diff
-VITE_API_BASE_URL=http://localhost:8000
+VITE_API_BASE_URL=http://127.0.0.1:8000
```

---

## 2. FastAPI CORS Configuration
**File modified**: `backend/main.py`  
**Purpose**: Import and register FastAPI's `CORSMiddleware` to allow local cross-origin requests from the React dashboard (e.g., `http://localhost:5173`). Without this, browser security blocks all frontend API calls.

### Code Added:
```python
# Imports added at the top
from fastapi.middleware.cors import CORSMiddleware

# Middleware registration added after app initialization
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

---

## 3. Dynamic Subprocess Management for Standalone `seeder.py`
**File modified**: `backend/main.py`  
**Purpose**: Update the seeder backend architecture to launch the standalone, independent `seeder.py` script as a parallel Python subprocess. This separates simulation scheduling from the main FastAPI server execution thread and captures `seeder.py` prints in real-time, feeding them back to the React UI log console.

### Code Added:
```python
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
```

Also, the `lifespan` application event handler was updated to guarantee the `seeder.py` subprocess is stopped cleanly (and killed if it times out) when the main Uvicorn server shuts down:
```python
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
```

---

## 4. Seeder REST API Endpoints
**File modified**: `backend/main.py`  
**Purpose**: Update REST API routes to spawn, monitor, and stop the standalone `seeder.py` script.

### Endpoints Implemented:
- **`GET /seeder/status`**: Fetches the status of the seeder (is it running, total seeded count parsed from subprocess logs, last updated, and the live log array).
- **`POST /seeder/start`**: Accepts a chosen interval, starts `seeder.py` in a parallel OS thread with `PYTHONUNBUFFERED=1` to guarantee instant unbuffered stdout pipes, and kicks off `read_seeder_stdout`.
- **`POST /seeder/stop`**: Halts and terminates the running `seeder.py` subprocess cleanly.
- **`POST /seeder/seed-now`**: Triggers a manual, immediate single-shot injection of a crisis report into the database, updates dashboard metrics, and registers a manual-seed log entry.

### Code Implemented:
```python
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
```

---

## 5. Frontend API Function
**File modified**: `ciro_dashboard/src/lib/api.js`  
**Purpose**: Add a client function `seedNow()` to issue an Axios POST request to `/seeder/seed-now`.

### Code Added:
```javascript
export async function seedNow() {
  const response = await api.post("/seeder/seed-now")
  return response.data
}
```

---

## 6. React Query Custom Mutation Hook
**File modified**: `ciro_dashboard/src/hooks/useSeeder.js`  
**Purpose**: Create a custom hook `useSeedNow()` using React Query. When executed successfully, this hook triggers an invalidation of both the `"seeder-status"` query cache and the `"reports"` query cache, forcing the dashboard and report tables to reload and display the newly seeded reports instantaneously.

### Code Added:
```javascript
export function useSeedNow() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: seedNow,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["seeder-status"] })
      queryClient.invalidateQueries({ queryKey: ["reports"] })
    },
  })
}
```

---

## 7. Enabling the "Seed Now" Button
**File modified**: `ciro_dashboard/src/pages/seeder.jsx`  
**Purpose**: Import the `useSeedNow` hook, bind it to the **Seed Now** button, enable the button, and wire up a database-zap icon alongside responsive pending states.

### Code Diff:
```diff
-import { useSeederStatus, useStartSeeder, useStopSeeder } from "@/hooks/useSeeder"
+import { useSeederStatus, useStartSeeder, useStopSeeder, useSeedNow } from "@/hooks/useSeeder"
 ...
 export function SeederPage() {
   const [interval, setInterval] = useState(4)
   const statusQuery = useSeederStatus()
   const startSeeder = useStartSeeder()
   const stopSeeder = useStopSeeder()
+  const seedNow = useSeedNow()
   const status = statusQuery.data
 ...
           <div className="flex gap-2">
             <Button disabled={running || startSeeder.isPending} onClick={() => startSeeder.mutate(interval)}><Play className="h-4 w-4" />Start Seeder</Button>
             <Button variant="warning" disabled={!running || stopSeeder.isPending} onClick={() => stopSeeder.mutate()}><Square className="h-4 w-4" />Stop Seeder</Button>
-            <Button variant="outline" disabled title="Requires POST /seeder/seed-now">Seed Now</Button>
+            <Button variant="outline" disabled={seedNow.isPending} onClick={() => seedNow.mutate()}><DatabaseZap className="h-4 w-4" />Seed Now</Button>
           </div>
```

---

## Connection & Testing Verification
With these integrations in place, the dashboard and the backend are fully connected:
1. CORS blocks are resolved.
2. Status queries automatically ping and pull real-time logs from the Uvicorn thread.
3. The "Seed Now" button triggers immediate, secure event database injections with direct UI synchronization.
