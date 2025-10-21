-- ============================================================================
-- Migration: Add consultation view mode to surveys table
-- Description: Adds column to track the view mode (scenarios/independent) in Consultation tab
-- ============================================================================

-- Add consultation view mode column to surveys table
ALTER TABLE public.surveys
ADD COLUMN IF NOT EXISTS consultation_view_mode VARCHAR(20) DEFAULT 'scenarios';

-- Add comment to column
COMMENT ON COLUMN public.surveys.consultation_view_mode IS 'View mode in Consultation tab: scenarios or independent';

-- Add check constraint to ensure valid values
ALTER TABLE public.surveys
ADD CONSTRAINT check_consultation_view_mode CHECK (consultation_view_mode IN ('scenarios', 'independent'));
