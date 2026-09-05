# Copyright (c) 2026 Team laccha paratha (Adarsh A, Twinkle B, Kashish, Utkarsh, Pratibha, Akash).
# All rights reserved.
# SMRITIVAN (स्मृतिवन) - SIH 2026 Problem Statement ID: 26003
# Cognitive Gaming & Memory Assistance Platform for Dementia Patients in NER.

from sqlalchemy import Column, String, Integer, Float, ForeignKey
from app.database import Base

class GameSession(Base):
    __tablename__ = "game_sessions"

    session_id = Column(String(64), primary_key=True, index=True)
    user_id = Column(String(64), ForeignKey("users.id"), nullable=False, index=True)
    game_type = Column(String(64), nullable=False) # 'visual_handloom', 'auditory_focus', 'routine_recall'
    duration_seconds = Column(Integer, nullable=False)
    difficulty_level = Column(Float, nullable=False) # 1.0 -> 5.0
    reaction_time_ms = Column(Integer, nullable=False) # Average touch latency
    error_rate = Column(Float, nullable=False) # 0.0 -> 1.0
    cvs_score = Column(Float, nullable=False) # 0.0 -> 100.0 (Cognitive Vitality Score)
    timestamp = Column(String(64), nullable=False, index=True)
    
    # CRDT Tracking
    sync_status = Column(String(32), nullable=False, default="synced")
    hlc_timestamp = Column(String(128), nullable=False, index=True)
    is_deleted = Column(Integer, nullable=False, default=0)
