from sqlalchemy import Column, Integer, String, Float, DateTime, ForeignKey
from sqlalchemy.ext.declarative import declarative_base
from datetime import datetime

Base = declarative_base()

class User(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True)
    native_language = Column(String, default="en")
    region = Column(String, nullable=True)
    user_type = Column(String)
    created_at = Column(DateTime, default=datetime.utcnow)

class GameSession(Base):
    __tablename__ = "game_sessions"
    session_id = Column(String, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    game_type = Column(String)
    duration_seconds = Column(Integer)
    difficulty_level = Column(Float)
    reaction_time_ms = Column(Integer)
    success_rate = Column(Float)
    cvs = Column(Float)
    timestamp = Column(DateTime)
    synced_at = Column(DateTime, default=datetime.utcnow)
