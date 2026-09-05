# Copyright (c) 2026 Team laccha paratha (Adarsh A, Twinkle B, Kashish, Utkarsh, Pratibha, Akash).
# All rights reserved.
# SMRITIVAN (स्मृतिवन) - SIH 2026 Problem Statement ID: 26003
# Cognitive Gaming & Memory Assistance Platform for Dementia Patients in NER.

from sqlalchemy import Column, String, Integer, DateTime
from app.database import Base

class User(Base):
    __tablename__ = "users"

    id = Column(String(64), primary_key=True, index=True)
    name = Column(String(255), nullable=False)
    native_language = Column(String(16), nullable=False, default="as") # 'as', 'mni', 'kha', 'brx', 'hi', 'en'
    dementia_stage = Column(String(128), nullable=False, default="Early-Stage MCI")
    caregiver_id = Column(String(64), nullable=True)
    created_at = Column(String(64), nullable=False)
    updated_at = Column(String(64), nullable=False)
    
    # CRDT Total Causal Ordering Columns
    hlc_timestamp = Column(String(128), nullable=False, index=True)
    is_deleted = Column(Integer, nullable=False, default=0)
    sync_status = Column(String(32), nullable=False, default="synced")
