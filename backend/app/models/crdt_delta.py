# Copyright (c) 2026 Team laccha paratha (Adarsh A, Twinkle B, Kashish, Utkarsh, Pratibha, Akash).
# All rights reserved.
# SMRITIVAN (स्मृतिवन) - SIH 2026 Problem Statement ID: 26003
# Cognitive Gaming & Memory Assistance Platform for Dementia Patients in NER.

from sqlalchemy import Column, String, Text, DateTime
from datetime import datetime, timezone
from app.database import Base

class CRDTDeltaLog(Base):
    __tablename__ = "crdt_delta_logs"

    id = Column(String(64), primary_key=True, index=True)
    table_name = Column(String(64), nullable=False, index=True)
    row_id = Column(String(64), nullable=False, index=True)
    operation = Column(String(32), nullable=False) # 'UPSERT', 'DELETE'
    payload = Column(Text, nullable=False)
    client_hlc = Column(String(128), nullable=False, index=True)
    server_hlc = Column(String(128), nullable=False)
    processed_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))
