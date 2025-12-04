-- ============================================================================
-- Migration: Add first_opened_at to Surveys Table
-- Description: Adds a timestamp column to track when a survey was first opened
-- ============================================================================

-- Add first_opened_at column to surveys table
ALTER TABLE public.surveys
ADD COLUMN IF NOT EXISTS first_opened_at TIMESTAMPTZ;

-- Create index for performance
CREATE INDEX IF NOT EXISTS idx_surveys_first_opened_at ON public.surveys(first_opened_at);

-- ============================================================================
-- END OF MIGRATION
-- ============================================================================
