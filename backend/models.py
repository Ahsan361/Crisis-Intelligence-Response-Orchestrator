from pydantic import BaseModel, Field
from typing import Optional, List
from enum import Enum
from datetime import datetime

class ReportSource(str, Enum):
    SOCIAL_MEDIA = "social_media"
    WEATHER_API = "weather_api"
    TRAFFIC_API = "traffic_api"
    MANUAL = "manual"

class CrisisType(str, Enum):
    FLOOD = "flood"
    ACCIDENT = "accident"
    HEATWAVE = "heatwave"
    BLOCKAGE = "blockage"
    INFRASTRUCTURE = "infrastructure"

class SeverityLevel(str, Enum):
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"
    CRITICAL = "critical"

class ReportStatus(str, Enum):
    PENDING = "pending"
    ANALYZING = "analyzing"
    RESOLVED = "resolved"
    SIMULATED = "simulated"

class ReportBase(BaseModel):
    report_text: str
    source: ReportSource = ReportSource.MANUAL
    reported_by: Optional[str] = "Unknown"
    area_name: Optional[str] = None
    location_lat: Optional[float] = None
    location_lng: Optional[float] = None
    crisis_type: Optional[CrisisType] = None
    severity: Optional[SeverityLevel] = None
    priority_score: int = Field(default=0, ge=0, le=100)
    status: ReportStatus = ReportStatus.PENDING
    agent_trace: Optional[list] = None         
    simulation_result: Optional[dict] = None
    crisis_confidence: Optional[int] = Field(default=0, ge=0, le=100)
    detected_language: Optional[str] = "Unknown"
    
class ReportCreate(ReportBase):
    pass

class ReportUpdate(BaseModel):
    report_text: Optional[str] = None
    source: Optional[ReportSource] = None
    reported_by: Optional[str] = None
    area_name: Optional[str] = None
    location_lat: Optional[float] = None
    location_lng: Optional[float] = None
    crisis_type: Optional[CrisisType] = None
    severity: Optional[SeverityLevel] = None
    priority_score: Optional[int] = Field(None, ge=0, le=100)
    status: Optional[ReportStatus] = None
    agent_trace: Optional[list] = None
    simulation_result: Optional[dict] = None
    crisis_confidence: Optional[int] = Field(None, ge=0, le=100)
    detected_language: Optional[str] = None

class Report(ReportBase):
    id: str
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True
