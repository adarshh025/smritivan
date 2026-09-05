# Copyright (c) 2026 Team laccha paratha (Adarsh A, Twinkle B, Kashish, Utkarsh, Pratibha, Akash).
# All rights reserved.
# SMRITIVAN (स्मृतिवन) - SIH 2026 Problem Statement ID: 26003
# Cognitive Gaming & Memory Assistance Platform for Dementia Patients in NER.

from sqlalchemy import Column, String, Integer, ForeignKey
from app.database import Base

class Reminder(Base):
    __tablename__ = "reminders"

    id = Column(String(64), primary_key=True, index=True)
    user_id = Column(String(64), ForeignKey("users.id"), nullable=False, index=True)
    type = Column(String(64), nullable=False) # 'medicine', 'water', 'walk', 'custom'
    time = Column(String(64), nullable=False) # '08:30 AM'
    asset_url = Column(String(255), nullable=True) # Regional voice audio prompt
    status = Column(String(32), nullable=False, default="pending") # 'pending', 'acknowledged', 'missed'
    created_at = Column(String(64), nullable=False)
    updated_at = Column(String(64), nullable=False)
    
    # CRDT Tracking
    hlc_timestamp = Column(String(128), nullable=False, index=True)
    is_deleted = Column(Integer, nullable=False, default=0)
    sync_status = Column(String(32), nullable=False, default="synced")
