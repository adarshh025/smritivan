# Copyright (c) 2026 Team laccha paratha (Adarsh A, Twinkle B, Kashish, Utkarsh, Pratibha, Akash).
# All rights reserved.
# SMRITIVAN (स्मृतिवन) - SIH 2026 Problem Statement ID: 26003
# Cognitive Gaming & Memory Assistance Platform for Dementia Patients in NER.

import uuid
from datetime import datetime, timezone
from typing import List
from fastapi import APIRouter, Depends, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.database import get_db
from app.models.caregiver_alert import CaregiverAlert
from app.schemas.analytics import CaregiverAlertCreate, CaregiverAlertResponse
from app.services.crdt_resolver import server_clock

router = APIRouter(prefix="/alerts", tags=["Caregiver Alerts & Clinical Triage"])

@router.get("", response_model=List[CaregiverAlertResponse])
async def get_recent_alerts(
    limit: int = 20,
    db: AsyncSession = Depends(get_db),
):
    """Retrieves chronological caregiver alerts and delirium warnings"""
    stmt = select(CaregiverAlert).where(
        CaregiverAlert.is_deleted == 0
    ).order_by(CaregiverAlert.timestamp.desc()).limit(limit)

    res = await db.execute(stmt)
    alerts = res.scalars().all()
    
    return [
        CaregiverAlertResponse(
            alert_id=a.alert_id,
            trigger_reason=a.trigger_reason,
            urgency=a.urgency,
            timestamp=a.timestamp,
            sync_status=a.sync_status,
        )
        for a in alerts
    ]

@router.post("", response_model=CaregiverAlertResponse, status_code=status.HTTP_201_CREATED)
async def create_alert(
    alert_in: CaregiverAlertCreate,
    db: AsyncSession = Depends(get_db),
):
    """Manually creates or syncs a clinical anomaly alert"""
    now_iso = alert_in.timestamp or datetime.now(timezone.utc).isoformat()
    hlc = server_clock.generate()
    alert_id = str(uuid.uuid4())

    new_alert = CaregiverAlert(
        alert_id=alert_id,
        trigger_reason=alert_in.trigger_reason,
        urgency=alert_in.urgency,
        timestamp=now_iso,
        sync_status="synced",
        hlc_timestamp=hlc,
        is_deleted=0,
    )
    db.add(new_alert)
    await db.commit()

    return CaregiverAlertResponse(
        alert_id=alert_id,
        trigger_reason=new_alert.trigger_reason,
        urgency=new_alert.urgency,
        timestamp=new_alert.timestamp,
        sync_status=new_alert.sync_status,
    )
