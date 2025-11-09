-- ============================================================================
-- Migration: Add display_settings column to survey_questions
-- Description: Adds a JSONB column to store display-related settings like width
--
-- Structure:
--   display_settings: {
--     "width": "full" | "1/2" | "1/3" | "1/4"
--   }
--
-- Default: NULL (displays as full width like before)
-- ============================================================================

-- Add display_settings column
ALTER TABLE public.survey_questions
ADD COLUMN IF NOT EXISTS display_settings JSONB DEFAULT NULL;

-- Add index for faster queries on display_settings
CREATE INDEX IF NOT EXISTS idx_survey_questions_display_settings
ON public.survey_questions USING GIN (display_settings);

-- Add comment for documentation
COMMENT ON COLUMN public.survey_questions.display_settings IS
'JSONB object storing display-related settings. Example: {"width": "1/2"} for half-width display. Supported widths: "full", "1/2", "1/3", "1/4". NULL means full width (default).';
