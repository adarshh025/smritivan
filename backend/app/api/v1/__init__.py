# Copyright (c) 2026 Team laccha paratha (Adarsh A, Twinkle B, Kashish, Utkarsh, Pratibha, Akash).
# All rights reserved.
# SMRITIVAN (स्मृतिवन) - SIH 2026 Problem Statement ID: 26003
# Cognitive Gaming & Memory Assistance Platform for Dementia Patients in NER.

from fastapi import APIRouter
from app.api.v1.sync_routes import router as sync_router
from app.api.v1.analytics_routes import router as analytics_router
from app.api.v1.alert_routes import router as alert_router
from app.api.v1.voice_routes import router as voice_router

api_v1_router = APIRouter()
api_v1_router.include_router(sync_router)
api_v1_router.include_router(analytics_router)
api_v1_router.include_router(alert_router)
api_v1_router.include_router(voice_router)
