from sqlalchemy import Column, BigInteger, Text, Integer, String, DateTime, Identity, func
from app.database import Base, TextArray, db_url

class CandidateProfile(Base):
    __tablename__ = "candidate_profiles"

    # SQLite compatible auto-increment (for local tests) and PostgreSQL Identity (for production)
    if db_url.startswith("sqlite"):
        id = Column(Integer, primary_key=True)
    else:
        id = Column(BigInteger, Identity(always=True), primary_key=True)

    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    candidate_name = Column(Text, nullable=True)
    raw_transcript = Column(Text, nullable=True)
    skills = Column(TextArray, nullable=True)
    experience_years = Column(Integer, nullable=True)
    priority_score = Column(String(10), nullable=True)
