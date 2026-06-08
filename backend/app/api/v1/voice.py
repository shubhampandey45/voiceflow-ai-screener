import os
import tempfile
import logging
from typing import List
from fastapi import APIRouter, UploadFile, File, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.database import get_db
from app.models.candidate_profile import CandidateProfile
from app.schemas.candidate_profile import ProfileResponse
from app.services.groq_whisper import transcribe_audio
from app.services.gemini_parser import parse_candidate_transcript

logger = logging.getLogger("voiceflow-backend")
router = APIRouter(prefix="/api/v1", tags=["Voice & Candidates"])

@router.post("/process-voice", response_model=ProfileResponse)
async def process_voice(
    file: UploadFile = File(...),
    db: Session = Depends(get_db)
):
    filename = file.filename or "audio.m4a"
    suffix = os.path.splitext(filename)[1].lower()
    if suffix not in [".m4a", ".aac", ".mp3", ".wav", ".webm", ".ogg"]:
        suffix = ".m4a"
        
    logger.info(f"Received audio processing request. Filename: {filename}, Suffix: {suffix}")

    # 1. Ingest audio: Catch stream and write to a temporary file
    with tempfile.NamedTemporaryFile(delete=False, suffix=suffix) as tmp:
        try:
            content = await file.read()
            tmp.write(content)
            tmp_path = tmp.name
        except Exception as e:
            logger.error(f"Failed to read file stream: {e}")
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Error reading file upload: {str(e)}"
            )

    try:
        # 2. Transcription Step: Stream audio file to Groq Whisper API
        raw_transcript = await transcribe_audio(tmp_path, filename)
        
        if not raw_transcript or not raw_transcript.strip():
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Groq Whisper succeeded but returned an empty transcript."
            )
        
        logger.info(f"Transcription complete. Length: {len(raw_transcript)} chars.")

        # 3. LLM Extraction Step: Pass transcript to Google Gemini API
        structured_data = await parse_candidate_transcript(raw_transcript)
        logger.info(f"Structured extraction completed for candidate: {structured_data.name}")

        # 4. Persistence Step: Insert structured fields into candidate_profiles table
        logger.info("Saving structured candidate profile to database...")
        db_profile = CandidateProfile(
            candidate_name=structured_data.name,
            raw_transcript=raw_transcript,
            skills=structured_data.skills,
            experience_years=structured_data.years_of_experience,
            priority_score=structured_data.priority
        )
        db.add(db_profile)
        db.commit()
        db.refresh(db_profile)

        # 5. Response Delivery: Return the database profile model representation
        return db_profile

    except HTTPException:
        # Re-raise HTTP exceptions to let FastAPI return them directly
        raise
    except Exception as e:
        logger.error(f"Error processing voice payload: {e}")
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Orchestration pipeline execution failed: {str(e)}"
        )
    finally:
        # Clean up temporary audio file safely
        if os.path.exists(tmp_path):
            try:
                os.remove(tmp_path)
            except Exception as rm_err:
                logger.error(f"Could not remove temp file {tmp_path}: {rm_err}")

@router.get("/profiles", response_model=List[ProfileResponse])
async def get_profiles(db: Session = Depends(get_db)):
    logger.info("Fetching all candidate profiles from database...")
    try:
        profiles = db.query(CandidateProfile).order_by(CandidateProfile.created_at.desc()).all()
        return profiles
    except Exception as e:
        logger.error(f"Failed fetching candidate profiles: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Database retrieval failed: {str(e)}"
        )
