from fastapi import HTTPException, status
from groq import Groq
from app.config import settings

def get_groq_client() -> Groq:
    """Helper to lazily initialize the Groq client and handle missing credentials."""
    api_key = settings.GROQ_API_KEY.strip()
    if not api_key:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="GROQ_API_KEY is not configured on the server."
        )
    return Groq(api_key=api_key)

async def transcribe_audio(file_path: str, filename: str) -> str:
    """Transcribes an audio file by streaming it to the Groq Whisper API."""
    try:
        groq_client = get_groq_client()
        with open(file_path, "rb") as audio_file:
            transcription = groq_client.audio.transcriptions.create(
                file=(filename, audio_file.read()),
                model="whisper-large-v3",
                response_format="json"
            )
        return transcription.get("text", "") if isinstance(transcription, dict) else getattr(transcription, "text", "")
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Transcription failed: {str(e)}"
        )
