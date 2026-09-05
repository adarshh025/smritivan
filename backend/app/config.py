# Copyright (c) 2026 Team laccha paratha (Adarsh A, Twinkle B, Kashish, Utkarsh, Pratibha, Akash).
# All rights reserved.
# SMRITIVAN (स्मृतिवन) - SIH 2026 Problem Statement ID: 26003
# Cognitive Gaming & Memory Assistance Platform for Dementia Patients in NER.

import os

try:
    from pydantic_settings import BaseSettings
    class _SettingsBase(BaseSettings):
        pass
except ImportError:
    class _SettingsBase:
        pass

class Settings(_SettingsBase):
    PROJECT_NAME: str = "SMRITIVAN Cloud Sync & Cognitive Analytics Engine"
    API_V1_STR: str = "/api/v1"
    TEAM_NAME: str = "Team laccha paratha"
    HACKATHON_PS_ID: str = "SIH 2026 PS ID: 26003"
    
    # Database Settings (Async PostgreSQL with SQLite fallback)
    DATABASE_URL: str = os.getenv(
        "DATABASE_URL", 
        "sqlite+aiosqlite:///./smritivan_server.db"
    )
    
    # Server Node ID for CRDT Hybrid Logical Clock
    SERVER_NODE_ID: str = "cloud_ner_master_01"
    
    # Regional Bhashini API Mock / Integration credentials
    BHASHINI_API_KEY: str = os.getenv("BHASHINI_API_KEY", "bhashini_ner_clinical_token_2026")
    BHASHINI_USER_ID: str = os.getenv("BHASHINI_USER_ID", "smritivan_sih_user")
    
    # Security
    SECRET_KEY: str = os.getenv("SECRET_KEY", "smritivan_super_secure_abha_key_2026_laccha_paratha")

settings = Settings()
