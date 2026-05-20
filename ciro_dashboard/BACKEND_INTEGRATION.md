# CIRO Admin Backend Integration Notes

The React admin panel expects the FastAPI backend at `VITE_API_BASE_URL`, defaulting to `http://localhost:8000`.

## Required CORS

Add CORS middleware in `main.py`:

```python
from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], #for dev puposes
    allow_methods=["*"],
    allow_headers=["*"],
)
```

## Endpoints Used

- `GET /reports`
- `GET /reports/{id}`
- `POST /reports`
- `PATCH /reports/{id}`
- `DELETE /reports/{id}`
- `POST /analyze-report`
- `POST /seeder/start`
- `POST /seeder/stop`
- `GET /seeder/status`

## Recommended Addition

- `POST /seeder/seed-now`

The UI includes a disabled Seed Now button until this endpoint exists.
