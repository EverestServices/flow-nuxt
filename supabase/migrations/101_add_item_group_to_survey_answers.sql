-- ============================================================================
-- Migration: Add item_group to Survey Answers
-- Description: Adds item_group column to survey_answers table to support
--              allow_multiple survey pages (e.g., multiple wall surfaces)
-- ============================================================================

-- ============================================================================
-- STEP 1: Add item_group column
-- ============================================================================

ALTER TABLE public.survey_answers
ADD COLUMN IF NOT EXISTS item_group INTEGER DEFAULT NULL;

COMMENT ON COLUMN public.survey_answers.item_group IS
'Identifies which group/item this answer belongs to for allow_multiple survey pages.
For example, if a survey has 3 wall surfaces, each surface would have a different item_group number.
NULL for survey pages where allow_multiple is false.';

-- ============================================================================
-- STEP 2: Create unique constraint
-- ============================================================================

-- Drop existing constraint if exists (to avoid conflicts)
DO $$
BEGIN
    -- Check if there's an existing unique constraint on survey_answers
    IF EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'survey_answers_survey_id_question_id_key'
          AND conrelid = 'public.survey_answers'::regclass
    ) THEN
        ALTER TABLE public.survey_answers
        DROP CONSTRAINT survey_answers_survey_id_question_id_key;
    END IF;
END $$;

-- Create new unique constraint including item_group
-- Using COALESCE to handle NULL values consistently
CREATE UNIQUE INDEX IF NOT EXISTS idx_survey_answers_unique
ON public.survey_answers (survey_id, survey_question_id, COALESCE(item_group, -1));

COMMENT ON INDEX idx_survey_answers_unique IS
'Ensures each question in a survey can only have one answer per item_group.
Uses COALESCE(item_group, -1) to handle NULL values for non-multiple pages.';

-- ============================================================================
-- Log completion
-- ============================================================================

DO $$
BEGIN
    RAISE NOTICE 'Successfully added item_group column and unique constraint to survey_answers';
END $$;
