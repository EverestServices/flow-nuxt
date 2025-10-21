-- ============================================================================
-- Migration: Change survey 'at' column from DATE to TIMESTAMPTZ
-- Description: Updates the survey 'at' column to store date and time
-- ============================================================================

-- ============================================================================
-- 1. ALTER COLUMN TYPE
-- ============================================================================

-- Change the 'at' column from DATE to TIMESTAMPTZ
-- PostgreSQL will automatically convert existing DATE values to TIMESTAMPTZ
-- by adding 00:00:00 time component
ALTER TABLE public.surveys
ALTER COLUMN at TYPE TIMESTAMPTZ
USING at::TIMESTAMPTZ;

-- Add a comment to document the change
COMMENT ON COLUMN public.surveys.at IS 'Survey date and time';
