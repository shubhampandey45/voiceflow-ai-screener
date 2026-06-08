-- SQL Schema Initialization Script for VoiceFlow AI
-- Target Database: PostgreSQL (Supabase)

CREATE TABLE IF NOT EXISTS candidate_profiles (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    candidate_name TEXT,
    raw_transcript TEXT,
    skills TEXT[],
    experience_years INTEGER,
    priority_score VARCHAR(10)
);

-- Index on created_at for fast descending historical lookups (e.g. recent profiles list in Mobile UI)
CREATE INDEX IF NOT EXISTS idx_candidate_profiles_created_at 
ON candidate_profiles (created_at DESC);

-- Index on candidate_name for searching specific candidate profiles
CREATE INDEX IF NOT EXISTS idx_candidate_profiles_candidate_name 
ON candidate_profiles (candidate_name);

-- Index on priority_score for filtering candidates by Priority Level (High, Medium, Low)
CREATE INDEX IF NOT EXISTS idx_candidate_profiles_priority_score 
ON candidate_profiles (priority_score);
