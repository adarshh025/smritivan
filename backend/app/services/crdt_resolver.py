# Copyright (c) 2026 Team laccha paratha (Adarsh A, Twinkle B, Kashish, Utkarsh, Pratibha, Akash).
# All rights reserved.
# SMRITIVAN (स्मृतिवन) - SIH 2026 Problem Statement ID: 26003
# Cognitive Gaming & Memory Assistance Platform for Dementia Patients in NER.

import json
import time
import uuid
from typing import Dict, Any, Tuple
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.config import settings
from app.models.user import User
from app.models.game_session import GameSession
from app.models.reminder import Reminder
from app.models.caregiver_alert import CaregiverAlert
from app.models.crdt_delta import CRDTDeltaLog
from app.schemas.sync import DeltaItem, SyncResponseItem

class CRDTHybridClock:
    def __init__(self, node_id: str):
        self.node_id = node_id
        self.millis = int(time.time() * 1000)
        self.counter = 0

    def generate(self) -> str:
        now_millis = int(time.time() * 1000)
        if now_millis > self.millis:
            self.millis = now_millis
            self.counter = 0
        else:
            self.counter += 1
        return f"{self.millis}:{str(self.counter).zfill(4)}:{self.node_id}"

    @staticmethod
    def compare(hlc1: str, hlc2: str) -> int:
        """Returns 1 if hlc1 > hlc2, -1 if hlc1 < hlc2, 0 if equal"""
        p1 = hlc1.split(":")
        p2 = hlc2.split(":")
        
        m1, c1, n1 = int(p1[0]), int(p1[1]), p1[2] if len(p1) > 2 else ""
        m2, c2, n2 = int(p2[0]), int(p2[1]), p2[2] if len(p2) > 2 else ""
        
        if m1 != m2:
            return 1 if m1 > m2 else -1
        if c1 != c2:
            return 1 if c1 > c2 else -1
        if n1 != n2:
            return 1 if n1 > n2 else -1
        return 0

server_clock = CRDTHybridClock(settings.SERVER_NODE_ID)

class CRDTResolverService:
    @staticmethod
    async def process_delta(db: AsyncSession, delta: DeltaItem) -> SyncResponseItem:
        server_hlc = server_clock.generate()
        table_name = delta.table_name.lower()
        applied = False

        if table_name == "users":
            applied = await CRDTResolverService._resolve_user(db, delta)
        elif table_name == "game_sessions":
            applied = await CRDTResolverService._resolve_game_session(db, delta)
        elif table_name == "reminders":
            applied = await CRDTResolverService._resolve_reminder(db, delta)
        elif table_name == "caregiver_alerts":
            applied = await CRDTResolverService._resolve_alert(db, delta)
        else:
            applied = False

        # Log CRDT Delta in server audit log
        log_entry = CRDTDeltaLog(
            id=str(uuid.uuid4()),
            table_name=delta.table_name,
            row_id=delta.row_id,
            operation=delta.operation,
            payload=json.dumps(delta.payload),
            client_hlc=delta.hlc_timestamp,
            server_hlc=server_hlc,
        )
        db.add(log_entry)

        return SyncResponseItem(
            log_id=delta.log_id,
            status="applied" if applied else "rejected_lww",
            applied_hlc=server_hlc if applied else delta.hlc_timestamp,
        )

    @staticmethod
    async def _resolve_user(db: AsyncSession, delta: DeltaItem) -> bool:
        stmt = select(User).where(User.id == delta.row_id)
        res = await db.execute(stmt)
        existing = res.scalar_one_or_none()

        if existing:
            if CRDTHybridClock.compare(delta.hlc_timestamp, existing.hlc_timestamp) <= 0:
                return False # Existing server record is newer
            # Update
            for k, v in delta.payload.items():
                if hasattr(existing, k):
                    setattr(existing, k, v)
            existing.hlc_timestamp = delta.hlc_timestamp
            existing.sync_status = "synced"
        else:
            p = delta.payload
            user = User(
                id=delta.row_id,
                name=p.get("name", "Unknown Patient"),
                native_language=p.get("native_language", "as"),
                dementia_stage=p.get("dementia_stage", "Early-Stage MCI"),
                caregiver_id=p.get("caregiver_id"),
                created_at=p.get("created_at", ""),
                updated_at=p.get("updated_at", ""),
                hlc_timestamp=delta.hlc_timestamp,
                is_deleted=p.get("is_deleted", 0),
                sync_status="synced",
            )
            db.add(user)
        return True

    @staticmethod
    async def _resolve_game_session(db: AsyncSession, delta: DeltaItem) -> bool:
        stmt = select(GameSession).where(GameSession.session_id == delta.row_id)
        res = await db.execute(stmt)
        existing = res.scalar_one_or_none()

        if existing:
            if CRDTHybridClock.compare(delta.hlc_timestamp, existing.hlc_timestamp) <= 0:
                return False
            for k, v in delta.payload.items():
                if hasattr(existing, k):
                    setattr(existing, k, v)
            existing.hlc_timestamp = delta.hlc_timestamp
        else:
            p = delta.payload
            session = GameSession(
                session_id=delta.row_id,
                user_id=p.get("user_id", "patient_ner_001"),
                game_type=p.get("game_type", "visual_handloom"),
                duration_seconds=int(p.get("duration_seconds", 60)),
                difficulty_level=float(p.get("difficulty_level", 1.0)),
                reaction_time_ms=int(p.get("reaction_time_ms", 1500)),
                error_rate=float(p.get("error_rate", 0.0)),
                cvs_score=float(p.get("cvs_score", 75.0)),
                timestamp=p.get("timestamp", ""),
                sync_status="synced",
                hlc_timestamp=delta.hlc_timestamp,
                is_deleted=int(p.get("is_deleted", 0)),
            )
            db.add(session)
        return True

    @staticmethod
    async def _resolve_reminder(db: AsyncSession, delta: DeltaItem) -> bool:
        stmt = select(Reminder).where(Reminder.id == delta.row_id)
        res = await db.execute(stmt)
        existing = res.scalar_one_or_none()

        if existing:
            if CRDTHybridClock.compare(delta.hlc_timestamp, existing.hlc_timestamp) <= 0:
                return False
            for k, v in delta.payload.items():
                if hasattr(existing, k):
                    setattr(existing, k, v)
            existing.hlc_timestamp = delta.hlc_timestamp
        else:
            p = delta.payload
            rem = Reminder(
                id=delta.row_id,
                user_id=p.get("user_id", "patient_ner_001"),
                type=p.get("type", "medicine"),
                time=p.get("time", "08:00 AM"),
                asset_url=p.get("asset_url"),
                status=p.get("status", "pending"),
                created_at=p.get("created_at", ""),
                updated_at=p.get("updated_at", ""),
                hlc_timestamp=delta.hlc_timestamp,
                is_deleted=int(p.get("is_deleted", 0)),
                sync_status="synced",
            )
            db.add(rem)
        return True

    @staticmethod
    async def _resolve_alert(db: AsyncSession, delta: DeltaItem) -> bool:
        stmt = select(CaregiverAlert).where(CaregiverAlert.alert_id == delta.row_id)
        res = await db.execute(stmt)
        existing = res.scalar_one_or_none()

        if existing:
            if CRDTHybridClock.compare(delta.hlc_timestamp, existing.hlc_timestamp) <= 0:
                return False
            for k, v in delta.payload.items():
                if hasattr(existing, k):
                    setattr(existing, k, v)
            existing.hlc_timestamp = delta.hlc_timestamp
        else:
            p = delta.payload
            alert = CaregiverAlert(
                alert_id=delta.row_id,
                trigger_reason=p.get("trigger_reason", "Cognitive alert"),
                urgency=p.get("urgency", "MEDIUM"),
                timestamp=p.get("timestamp", ""),
                sync_status="synced",
                hlc_timestamp=delta.hlc_timestamp,
                is_deleted=int(p.get("is_deleted", 0)),
            )
            db.add(alert)
        return True
