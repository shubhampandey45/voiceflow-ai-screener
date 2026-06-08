from pydantic import BaseModel, Field
from typing import List, Optional
from datetime import datetime

class CandidateStructuredData(BaseModel):
    name: Optional[str] = Field(None, description="Name of the candidate. Return null or empty if not mentioned.")
    skills: List[str] = Field(default_factory=list, description="List of technical or professional skills extracted.")
    years_of_experience: int = Field(0, description="Parsed years of experience. Default to 0 if not specified.")
    priority: str = Field("Medium", description="Calculated profile evaluation priority. Must be: Low, Medium, or High.")

class ProfileResponse(BaseModel):
    id: int
    created_at: datetime
    candidate_name: Optional[str]
    raw_transcript: str
    skills: List[str]
    experience_years: int
    priority_score: str

    class Config:
        from_attributes = True
