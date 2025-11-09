-- ============================================================================
-- Migration: Add Shared Question Support
-- Description: Adds support for shared questions that can appear on multiple
--              survey pages while maintaining a single source of truth for answers.
--
-- Use Case: When the same question needs to appear on multiple pages
--           (e.g., "Wall Thickness" on both Basic Data and Walls pages)
--
-- How it works:
--   1. Create one "master" question (shared_question_id = NULL, is_shared_instance = false)
--   2. Create "instance" questions on other pages (shared_question_id = master_id, is_shared_instance = true)
--   3. Answers are ONLY stored for the master question
--   4. Frontend displays instances but saves/loads from master
-- ============================================================================

-- Add new columns to survey_questions table
ALTER TABLE public.survey_questions
ADD COLUMN IF NOT EXISTS shared_question_id UUID REFERENCES public.survey_questions(id) ON DELETE CASCADE,
ADD COLUMN IF NOT EXISTS is_shared_instance BOOLEAN DEFAULT false;

-- Create index for faster lookups
CREATE INDEX IF NOT EXISTS idx_survey_questions_shared_question_id
ON public.survey_questions(shared_question_id)
WHERE shared_question_id IS NOT NULL;

-- Add comments for documentation
COMMENT ON COLUMN public.survey_questions.shared_question_id IS
'References the master question if this is a shared instance. NULL if this is a master question or regular question.';

COMMENT ON COLUMN public.survey_questions.is_shared_instance IS
'TRUE if this is a shared instance (alias) of another question. FALSE if this is a master question or regular question.';

-- Validation: A shared instance must have a shared_question_id
ALTER TABLE public.survey_questions
ADD CONSTRAINT chk_shared_instance_has_master
CHECK (
    (is_shared_instance = false) OR
    (is_shared_instance = true AND shared_question_id IS NOT NULL)
);

-- Validation: A master question cannot reference itself
ALTER TABLE public.survey_questions
ADD CONSTRAINT chk_shared_question_not_self_reference
CHECK (
    shared_question_id IS NULL OR
    shared_question_id != id
);
