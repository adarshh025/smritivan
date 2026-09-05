# Copyright (c) 2026 Team laccha paratha (Adarsh A, Twinkle B, Kashish, Utkarsh, Pratibha, Akash).
# All rights reserved.
# SMRITIVAN (स्मृतिवन) - SIH 2026 Problem Statement ID: 26003
# Cognitive Gaming & Memory Assistance Platform for Dementia Patients in NER.

from typing import Optional
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.models.user import User
from app.models.game_session import GameSession
from app.schemas.analytics import LongitudinalAnalyticsResponse, SessionDataPoint

class AnalyticsService:
    @staticmethod
    async def get_patient_longitudinal_data(db: AsyncSession, user_id: str) -> Optional[LongitudinalAnalyticsResponse]:
        # 1. Fetch User Profile
        user_stmt = select(User).where(User.id == user_id, User.is_deleted == 0)
        user_res = await db.execute(user_stmt)
        user = user_res.scalar_one_or_none()

        patient_name = user.name if user else "Bhaben Bora"
        dementia_stage = user.dementia_stage if user else "Early-Stage MCI"

        # 2. Fetch Game Sessions
        sessions_stmt = select(GameSession).where(
            GameSession.user_id == user_id,
            GameSession.is_deleted == 0
        ).order_by(GameSession.timestamp.asc())

        sessions_res = await db.execute(sessions_stmt)
        sessions = sessions_res.scalars().all()

        if not sessions:
            return LongitudinalAnalyticsResponse(
                user_id=user_id,
                patient_name=patient_name,
                dementia_stage=dementia_stage,
                total_sessions_played=0,
                average_cvs_score=75.0,
                average_reaction_latency_ms=1400,
                average_error_rate=0.15,
                clinical_trajectory_status="STABLE",
                session_history=[]
            )

        # 3. Calculate Clinical Aggregates
        total_sessions = len(sessions)
        avg_cvs = sum(s.cvs_score for s in sessions) / total_sessions
        avg_latency = int(sum(s.reaction_time_ms for s in sessions) / total_sessions)
        avg_error = sum(s.error_rate for s in sessions) / total_sessions

        # 4. Trajectory Assessment
        status = "STABLE"
        if total_sessions >= 3:
            recent_3 = sessions[-3:]
            recent_avg_cvs = sum(s.cvs_score for s in recent_3) / 3
            earlier_avg_cvs = avg_cvs

            if recent_avg_cvs < earlier_avg_cvs - 20 or any(s.reaction_time_ms > 5500 for s in recent_3):
                status = "DELIRIUM_RISK"
            elif recent_avg_cvs < earlier_avg_cvs - 10:
                status = "ATTENTION_REQUIRED"
            elif recent_avg_cvs > earlier_avg_cvs + 5:
                status = "IMPROVING"

        session_points = [
            SessionDataPoint(
                session_id=s.session_id,
                game_type=s.game_type,
                difficulty_level=s.difficulty_level,
                reaction_time_ms=s.reaction_time_ms,
                error_rate=s.error_rate,
                cvs_score=s.cvs_score,
                timestamp=s.timestamp,
            )
            for s in sessions
        ]

        return LongitudinalAnalyticsResponse(
            user_id=user_id,
            patient_name=patient_name,
            dementia_stage=dementia_stage,
            total_sessions_played=total_sessions,
            average_cvs_score=round(avg_cvs, 1),
            average_reaction_latency_ms=avg_latency,
            average_error_rate=round(avg_error, 3),
            clinical_trajectory_status=status,
            session_history=session_points,
        )
