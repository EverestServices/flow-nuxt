-- ============================================================================
-- Migration: Add Hierarchical Survey Pages Support
-- Description: Enables SurveyPages to have subpages in a hierarchical structure
--              Example: Falak (Walls) -> Nyílászárók (Openings)
--              Each wall instance can have multiple opening instances
-- ============================================================================

-- ========================================================================
-- STEP 1: Add parent_page_id to survey_pages table
-- ========================================================================

ALTER TABLE public.survey_pages
ADD COLUMN parent_page_id UUID REFERENCES public.survey_pages(id) ON DELETE CASCADE;

COMMENT ON COLUMN public.survey_pages.parent_page_id IS
'Reference to parent page if this page is a subpage. NULL for root-level pages.';


-- ========================================================================
-- STEP 2: Add parent_item_group to survey_answers table
-- ========================================================================

ALTER TABLE public.survey_answers
ADD COLUMN parent_item_group INTEGER;

COMMENT ON COLUMN public.survey_answers.parent_item_group IS
'Instance number of the parent page item. Used for hierarchical pages.
Example: For "1. fal -> 2. nyílászáró", parent_item_group=0, item_group=1';


-- ========================================================================
-- STEP 3: Drop old unique constraint and create new unique index
-- ========================================================================

-- Drop the existing unique constraint
ALTER TABLE public.survey_answers
DROP CONSTRAINT IF EXISTS survey_answers_survey_id_survey_question_id_item_group_key;

-- Drop the old unique index if it exists
DROP INDEX IF EXISTS idx_survey_answers_unique;

-- Create new unique index that includes parent_item_group
-- Using COALESCE to handle NULL values properly
CREATE UNIQUE INDEX idx_survey_answers_unique_with_parent
ON public.survey_answers (
    survey_id,
    survey_question_id,
    COALESCE(item_group, -1),
    COALESCE(parent_item_group, -1)
);

COMMENT ON INDEX idx_survey_answers_unique_with_parent IS
'Ensures each answer is unique per survey, question, item instance, and parent item instance';


-- ========================================================================
-- STEP 4: Create index for efficient parent-child lookups
-- ========================================================================

CREATE INDEX idx_survey_pages_parent_page_id
ON public.survey_pages(parent_page_id)
WHERE parent_page_id IS NOT NULL;

CREATE INDEX idx_survey_answers_parent_item_group
ON public.survey_answers(parent_item_group)
WHERE parent_item_group IS NOT NULL;


-- ========================================================================
-- STEP 5: Update the trigger function to handle parent_item_group
-- ========================================================================

-- Drop the existing trigger
DROP TRIGGER IF EXISTS sync_default_value_inheritance ON public.survey_answers;

-- Update the trigger function
CREATE OR REPLACE FUNCTION sync_default_value_inheritance()
RETURNS TRIGGER AS $$
DECLARE
    source_question_id UUID;
    source_answer_record RECORD;
    dependent_questions RECORD;
BEGIN
    -- When an answer is inserted or updated, check if this question is a source for others

    -- Find all questions that inherit from this question
    FOR dependent_questions IN
        SELECT sq.id as question_id, sq.name
        FROM public.survey_questions sq
        WHERE sq.default_value_source_question_id = (
            SELECT id FROM public.survey_questions WHERE id = NEW.survey_question_id
        )
    LOOP
        -- Insert or update the dependent answer with the same value
        -- Use the same item_group and parent_item_group for inheritance
        INSERT INTO public.survey_answers (
            survey_id,
            survey_question_id,
            answer,
            item_group,
            parent_item_group
        ) VALUES (
            NEW.survey_id,
            dependent_questions.question_id,
            NEW.answer,
            NEW.item_group,
            NEW.parent_item_group
        )
        ON CONFLICT (survey_id, survey_question_id, COALESCE(item_group, -1), COALESCE(parent_item_group, -1))
        DO UPDATE SET
            answer = NEW.answer,
            updated_at = NOW();
    END LOOP;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Recreate the trigger
CREATE TRIGGER sync_default_value_inheritance
AFTER INSERT OR UPDATE ON public.survey_answers
FOR EACH ROW
EXECUTE FUNCTION sync_default_value_inheritance();

COMMENT ON FUNCTION sync_default_value_inheritance() IS
'Automatically syncs inherited values from source questions to dependent questions.
Now handles hierarchical pages with parent_item_group.';
