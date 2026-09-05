# Copyright (c) 2026 Team laccha paratha (Adarsh A, Twinkle B, Kashish, Utkarsh, Pratibha, Akash).
# All rights reserved.
# SMRITIVAN (स्मृतिवन) - SIH 2026 Problem Statement ID: 26003
# Cognitive Gaming & Memory Assistance Platform for Dementia Patients in NER.

from typing import List, Optional
from pydantic import BaseModel

class SessionDataPoint(BaseModel):
    session_id: str
    game_type: str
    difficulty_level: float
    reaction_time_ms: int
    error_rate: float
    cvs_score: float
    timestamp: str

class LongitudinalAnalyticsResponse(BaseModel):
    user_id: str
    patient_name: str
    dementia_stage: str
    total_sessions_played: int
    average_cvs_score: float
    average_reaction_latency_ms: int
    average_error_rate: float
    clinical_trajectory_status: str # 'STABLE', 'IMPROVING', 'ATTENTION_REQUIRED', 'DELIRIUM_RISK'
    session_history: List[SessionDataPoint]

class CaregiverAlertCreate(BaseModel):
    trigger_reason: str
    urgency: str # 'LOW', 'MEDIUM', 'HIGH', 'CRITICAL'
    timestamp: Optional[str] = None

class CaregiverAlertResponse(BaseModel):
    alert_id: str
    trigger_reason: str
    urgency: str
    timestamp: str
    sync_status: str
