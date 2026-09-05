# Copyright (c) 2026 Team laccha paratha (Adarsh A, Twinkle B, Kashish, Utkarsh, Pratibha, Akash).
# All rights reserved.
# SMRITIVAN (स्मृतिवन) - SIH 2026 Problem Statement ID: 26003
# Cognitive Gaming & Memory Assistance Platform for Dementia Patients in NER.

from typing import Optional
from pydantic import BaseModel

class UserCreate(BaseModel):
    id: str
    name: str
    native_language: str = "as"
    dementia_stage: str = "Early-Stage MCI"
    caregiver_id: Optional[str] = None

class UserResponse(BaseModel):
    id: str
    name: str
    native_language: str
    dementia_stage: str
    caregiver_id: Optional[str]
    created_at: str
    updated_at: str
    hlc_timestamp: str
