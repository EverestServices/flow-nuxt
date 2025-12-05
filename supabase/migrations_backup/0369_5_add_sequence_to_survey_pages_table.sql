-- ============================================================================
-- Migration: Add sequence column to survey_pages table
-- Description: Adds sequence column to survey_pages for ordering pages within investments
-- ============================================================================

-- Add sequence column to survey_pages table
ALTER TABLE public.survey_pages
ADD COLUMN IF NOT EXISTS sequence INTEGER;
