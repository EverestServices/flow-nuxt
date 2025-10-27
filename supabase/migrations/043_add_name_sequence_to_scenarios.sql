-- ============================================================================
-- Migration: Add name and sequence to scenarios table
-- Description: Adds name, sequence, and description columns to scenarios
-- ============================================================================

-- Add columns to scenarios table
ALTER TABLE public.scenarios
ADD COLUMN IF NOT EXISTS name VARCHAR(255),
ADD COLUMN IF NOT EXISTS sequence INTEGER,
ADD COLUMN IF NOT EXISTS description TEXT;

-- Create index for sequence ordering
CREATE INDEX IF NOT EXISTS idx_scenarios_survey_sequence ON public.scenarios(survey_id, sequence);

-- ============================================================================
-- END OF MIGRATION
-- ============================================================================
