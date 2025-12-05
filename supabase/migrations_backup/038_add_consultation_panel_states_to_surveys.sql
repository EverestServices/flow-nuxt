-- ============================================================================
-- Migration: Add consultation panel states to surveys table
-- Description: Adds columns to track the open/closed state of consultation panels
-- ============================================================================

-- Add consultation panel state columns to surveys table
ALTER TABLE public.surveys
ADD COLUMN IF NOT EXISTS consultation_system_design_open BOOLEAN DEFAULT true,
ADD COLUMN IF NOT EXISTS consultation_panel_open BOOLEAN DEFAULT false;

-- Add comment to columns
COMMENT ON COLUMN public.surveys.consultation_system_design_open IS 'Indicates if the System Design panel is open in Consultation tab';
COMMENT ON COLUMN public.surveys.consultation_panel_open IS 'Indicates if the Consultation panel is open in Consultation tab';
