# Copyright (c) 2026 Team laccha paratha (Adarsh A, Twinkle B, Kashish, Utkarsh, Pratibha, Akash).
# All rights reserved.
# SMRITIVAN (स्मृतिवन) - SIH 2026 Problem Statement ID: 26003
# Cognitive Gaming & Memory Assistance Platform for Dementia Patients in NER.

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.schemas.analytics import LongitudinalAnalyticsResponse
from app.services.analytics_service import AnalyticsService

router = APIRouter(prefix="/patients", tags=["Clinical Analytics & Telemetry"])

@router.get("/{user_id}/analytics", response_model=LongitudinalAnalyticsResponse)
async def get_patient_analytics(
    user_id: str,
    db: AsyncSession = Depends(get_db),
):
    """
    Returns longitudinal MMSE / Cognitive Vitality Score (CVS) telemetry,
    reaction latency trends, error rates, and clinical trajectory risk assessments.
    """
    data = await AnalyticsService.get_patient_longitudinal_data(db, user_id)
    if not data:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Patient with ID {user_id} not found."
        )
    return data
