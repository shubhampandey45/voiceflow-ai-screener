import logging
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.config import settings
from app.database import engine, Base, db_url
from app.api.v1.voice import router as voice_router

# Setup logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("voiceflow-backend")

# Import models to ensure they are registered on Base metadata for tables creation
from app.models.candidate_profile import CandidateProfile

# Automatically create tables if they do not exist
Base.metadata.create_all(bind=engine)

app = FastAPI(title="VoiceFlow AI API", version="1.0.0")

# CORS setup for mobile and web client connectivity
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include Routers
app.include_router(voice_router)

@app.on_event("startup")
async def startup_event():
    logger.info("Initializing VoiceFlow AI API Server...")
    if db_url.startswith("sqlite"):
        logger.warning("No PostgreSQL database connection string is set. Defaulting to local SQLite.")
    else:
        logger.info("Successfully configured remote PostgreSQL database.")
    if not settings.GROQ_API_KEY:
        logger.warning("GROQ_API_KEY is not set. Audio processing endpoint will fail until set.")
    if not settings.GEMINI_API_KEY:
        logger.warning("GEMINI_API_KEY is not set. Information extraction endpoint will fail until set.")

@app.get("/health")
def health_check():
    return {
        "status": "healthy",
        "database": "sqlite" if db_url.startswith("sqlite") else "postgresql",
        "groq_configured": bool(settings.GROQ_API_KEY and settings.GROQ_API_KEY.strip()),
        "gemini_configured": bool(settings.GEMINI_API_KEY and settings.GEMINI_API_KEY.strip())
    }
