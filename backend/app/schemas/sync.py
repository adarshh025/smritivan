# Copyright (c) 2026 Team laccha paratha (Adarsh A, Twinkle B, Kashish, Utkarsh, Pratibha, Akash).
# All rights reserved.
# SMRITIVAN (स्मृतिवन) - SIH 2026 Problem Statement ID: 26003
# Cognitive Gaming & Memory Assistance Platform for Dementia Patients in NER.

from typing import Dict, Any, List, Optional
from pydantic import BaseModel, Field

class DeltaItem(BaseModel):
    log_id: str
    table_name: str
    row_id: str
    operation: str # 'UPSERT', 'DELETE'
    payload: Dict[str, Any]
    hlc_timestamp: str

class SyncBatchRequest(BaseModel):
    client_node_id: str
    deltas: List[DeltaItem]
    client_hlc: str

class SyncResponseItem(BaseModel):
    log_id: str
    status: str # 'applied', 'rejected_lww', 'conflict_resolved'
    applied_hlc: str

class SyncBatchResponse(BaseModel):
    success: bool
    server_node_id: str
    server_hlc: str
    processed_count: int
    results: List[SyncResponseItem]
    server_deltas: Optional[List[DeltaItem]] = Field(default_factory=list)
