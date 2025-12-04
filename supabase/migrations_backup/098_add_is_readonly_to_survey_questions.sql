-- ============================================================================
-- Migration: Add is_readonly Flag to Survey Questions
-- Description: Adds a flag to mark survey questions as readonly, typically
--              used in combination with default_value_source_question_id
-- ============================================================================

-- ============================================================================
-- STEP 1: Add is_readonly column
-- ============================================================================

ALTER TABLE public.survey_questions
ADD COLUMN IF NOT EXISTS is_readonly BOOLEAN DEFAULT FALSE;

-- Add comment
COMMENT ON COLUMN public.survey_questions.is_readonly IS
'Indicates whether this question field should be displayed as readonly in the UI.
Typically used when default_value_source_question_id is set, to show the value
from another question without allowing direct editing.';

-- ============================================================================
-- Log completion
-- ============================================================================

DO $$
BEGIN
    RAISE NOTICE 'Successfully added is_readonly column to survey_questions';
END $$;
