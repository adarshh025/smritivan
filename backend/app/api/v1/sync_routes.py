from fastapi import APIRouter, Depends, HTTPException
from typing import List
from pydantic import BaseModel
from datetime import datetime

router = APIRouter()

class GameSessionSyncModel(BaseModel):
    session_id: str
    user_id: int
    game_type: str
    duration_seconds: int
    difficulty_level: float
    reaction_time_ms: int
    success_rate: float
    cvs: float
    timestamp: datetime

class SyncPayload(BaseModel):
    sessions: List[GameSessionSyncModel]

@router.post("/batch")
async def sync_batch(payload: SyncPayload):
    # In a real implementation, this would use an async SQLAlchemy Session
    # to merge/upsert the records.
    # Conflict Resolution: If session_id exists, we update only if the incoming 
    # timestamp is strictly greater, acting as a CRDT-inspired LWW pattern.
    
    saved_count = 0
    for session in payload.sessions:
        # Mocking the upsert logic
        saved_count += 1
        
    return {
        "status": "success",
        "message": f"Successfully synchronized {saved_count} game sessions.",
        "synced_at": datetime.utcnow()
    }
