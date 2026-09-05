from fastapi import FastAPI
from app.api.v1 import sync_routes
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(
    title="SMRITIVAN API",
    description="Backend for the SMRITIVAN Cognitive Assistance Platform",
    version="1.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(sync_routes.router, prefix="/api/v1/sync", tags=["Synchronization"])

@app.get("/")
async def root():
    return {"message": "SMRITIVAN Backend is running."}
