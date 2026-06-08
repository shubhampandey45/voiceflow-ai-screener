from fastapi import HTTPException, status
from google import genai
from google.genai import types
from app.config import settings
from app.schemas.candidate_profile import CandidateStructuredData

def get_gemini_client() -> genai.Client:
    """Helper to lazily initialize the Google GenAI client and handle missing credentials."""
    api_key = settings.GEMINI_API_KEY.strip()
    if not api_key:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="GEMINI_API_KEY is not configured on the server."
        )
    return genai.Client(api_key=api_key)

async def parse_candidate_transcript(raw_transcript: str) -> CandidateStructuredData:
    """Invokes Google Gemini with structured schema output to parse candidate fields from transcripts."""
    try:
        gemini_client = get_gemini_client()
        response = gemini_client.models.generate_content(
            model="gemini-2.5-flash",
            contents=f"Extract candidate details from the following transcript:\n\n{raw_transcript}",
            config=types.GenerateContentConfig(
                system_instruction=(
                    "You are an expert HR recruitment assistant. Parse the candidate's transcript "
                    "to extract structured JSON matching the keys: name, skills, years_of_experience, and priority. "
                    "Determine priority (Low, Medium, High) based on seniority or specialized skills mentioned."
                ),
                response_mime_type="application/json",
                response_schema=CandidateStructuredData,
            )
        )
        response_text = response.text.strip()
        return CandidateStructuredData.model_validate_json(response_text)
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Gemini parsing failed: {str(e)}"
        )
