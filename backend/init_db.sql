-- SQL Script to set up database schema on Supabase (PostgreSQL)

CREATE TABLE IF NOT EXISTS candidate_profiles (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    candidate_name TEXT,
    raw_transcript TEXT,
    skills TEXT[],
    experience_years INTEGER,
    priority_score VARCHAR(10)
);

-- Indexing for lookup speed optimizations (e.g. searching or sorting by created_at)
CREATE INDEX IF NOT EXISTS idx_candidate_profiles_created_at ON candidate_profiles (created_at DESC);
