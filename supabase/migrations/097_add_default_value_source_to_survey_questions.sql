-- ============================================================================
-- Migration: Add Default Value Source to Survey Questions
-- Description: Adds the ability to automatically copy answer values from one
--              SurveyQuestion to another as a default/readonly value
-- ============================================================================

-- ============================================================================
-- STEP 1: Add new column to survey_questions
-- ============================================================================

ALTER TABLE public.survey_questions
ADD COLUMN IF NOT EXISTS default_value_source_question_id UUID DEFAULT NULL;

-- Add foreign key constraint
ALTER TABLE public.survey_questions
ADD CONSTRAINT fk_survey_questions_default_source
    FOREIGN KEY (default_value_source_question_id)
    REFERENCES public.survey_questions(id)
    ON DELETE SET NULL;

-- Add comment
COMMENT ON COLUMN public.survey_questions.default_value_source_question_id IS
'Reference to another survey_question whose answer should be used as the default value for this question.
When set, the answer from the source question will be automatically copied to this question as a readonly default value.
For allow_multiple: true pages, the value will be copied to all item groups.';

-- ============================================================================
-- STEP 2: Add index for better query performance
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_survey_questions_default_source
ON public.survey_questions(default_value_source_question_id)
WHERE default_value_source_question_id IS NOT NULL;

-- ============================================================================
-- STEP 3: Create a helper function to get the source answer value
-- ============================================================================

CREATE OR REPLACE FUNCTION get_default_value_from_source(
    p_survey_id UUID,
    p_source_question_id UUID
) RETURNS TEXT AS $$
DECLARE
    v_answer TEXT;
BEGIN
    -- Get the answer value from the source question for the given survey
    SELECT answer INTO v_answer
    FROM public.survey_answers
    WHERE survey_id = p_survey_id
      AND survey_question_id = p_source_question_id
    LIMIT 1;

    RETURN v_answer;
END;
$$ LANGUAGE plpgsql STABLE;

COMMENT ON FUNCTION get_default_value_from_source(UUID, UUID) IS
'Helper function to retrieve the answer value from a source survey question for a given survey.
Used to populate default values in questions that reference other questions as their data source.';

-- ============================================================================
-- STEP 4: Create trigger to auto-update dependent question answers
-- ============================================================================

CREATE OR REPLACE FUNCTION sync_dependent_question_answers()
RETURNS TRIGGER AS $$
DECLARE
    v_dependent_question RECORD;
    v_survey_page_id UUID;
    v_is_multiple BOOLEAN;
    v_item_group INTEGER;
BEGIN
    -- Find all questions that use this question as their default source
    FOR v_dependent_question IN
        SELECT sq.id, sq.survey_page_id, sq.is_readonly
        FROM public.survey_questions sq
        WHERE sq.default_value_source_question_id = NEW.survey_question_id
    LOOP
        -- Get the survey page info
        SELECT sp.allow_multiple, sp.id INTO v_is_multiple, v_survey_page_id
        FROM public.survey_pages sp
        WHERE sp.id = v_dependent_question.survey_page_id;

        IF v_is_multiple THEN
            -- For allow_multiple pages, update/insert for all existing item groups
            FOR v_item_group IN
                SELECT DISTINCT item_group
                FROM public.survey_answers
                WHERE survey_id = NEW.survey_id
                  AND survey_question_id IN (
                    SELECT id FROM public.survey_questions
                    WHERE survey_page_id = v_survey_page_id
                  )
                  AND item_group IS NOT NULL
            LOOP
                -- Insert or update the answer for this item group
                INSERT INTO public.survey_answers (
                    survey_id,
                    survey_question_id,
                    answer,
                    item_group
                ) VALUES (
                    NEW.survey_id,
                    v_dependent_question.id,
                    NEW.answer,
                    v_item_group
                )
                ON CONFLICT (survey_id, survey_question_id, COALESCE(item_group, -1))
                DO UPDATE SET
                    answer = EXCLUDED.answer,
                    updated_at = NOW();
            END LOOP;
        ELSE
            -- For non-multiple pages, simple insert or update
            INSERT INTO public.survey_answers (
                survey_id,
                survey_question_id,
                answer
            ) VALUES (
                NEW.survey_id,
                v_dependent_question.id,
                NEW.answer
            )
            ON CONFLICT (survey_id, survey_question_id, COALESCE(item_group, -1))
            DO UPDATE SET
                answer = EXCLUDED.answer,
                updated_at = NOW();
        END IF;
    END LOOP;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger on survey_answers
DROP TRIGGER IF EXISTS trigger_sync_dependent_answers ON public.survey_answers;
CREATE TRIGGER trigger_sync_dependent_answers
    AFTER INSERT OR UPDATE OF answer ON public.survey_answers
    FOR EACH ROW
    EXECUTE FUNCTION sync_dependent_question_answers();

COMMENT ON FUNCTION sync_dependent_question_answers() IS
'Trigger function that automatically updates answers for questions that reference
the updated question as their default_value_source. This ensures dependent question
values stay in sync when the source value changes.';

-- ============================================================================
-- Log completion
-- ============================================================================

DO $$
BEGIN
    RAISE NOTICE 'Successfully added default_value_source_question_id column, helper function, and sync trigger';
END $$;
