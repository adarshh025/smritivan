# Copyright (c) 2026 Team laccha paratha (Adarsh A, Twinkle B, Kashish, Utkarsh, Pratibha, Akash).
# All rights reserved.
# SMRITIVAN (स्मृतिवन) - SIH 2026 Problem Statement ID: 26003
# Cognitive Gaming & Memory Assistance Platform for Dementia Patients in NER.

from typing import Dict, Any
from pydantic import BaseModel
from fastapi import APIRouter, status
from app.services.bhashini_service import BhashiniService

router = APIRouter(prefix="/voice", tags=["Bhashini Regional Voice Service"])

class TTSRequest(BaseModel):
    text: str
    source_language: str = "as" # 'as', 'mni', 'kha', 'brx', 'hi', 'en'

class STTRequest(BaseModel):
    audio_base64: str
    source_language: str = "as"

@router.post("/text-to-speech", status_code=status.HTTP_200_OK)
async def synthesize_text(req: TTSRequest) -> Dict[str, Any]:
    """Synthesizes text into regional North-Eastern spoken dialect audio"""
    return await BhashiniService.synthesize_speech(req.text, req.source_language)

@router.post("/speech-to-text", status_code=status.HTTP_200_OK)
async def transcribe_audio(req: STTRequest) -> Dict[str, Any]:
    """Transcribes regional elderly voice input to text"""
    return await BhashiniService.transcribe_speech(req.audio_base64, req.source_language)
