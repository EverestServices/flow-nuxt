-- ============================================================================
-- Migration: Fix Trigger ON CONFLICT Issue
-- Description: Replaces ON CONFLICT with check-then-insert/update pattern
--              in BOTH sync_default_value_inheritance and sync_dependent_question_answers triggers
-- ============================================================================

-- ========================================================================
-- PART 1: Fix sync_default_value_inheritance trigger
-- ========================================================================

-- Drop the existing trigger
DROP TRIGGER IF EXISTS sync_default_value_inheritance ON public.survey_answers;

-- Update the trigger function to use check-then-insert/update pattern
CREATE OR REPLACE FUNCTION sync_default_value_inheritance()
RETURNS TRIGGER AS $$
DECLARE
    source_question_id UUID;
    source_answer_record RECORD;
    dependent_questions RECORD;
    existing_answer_id UUID;
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
        -- Check if an answer already exists for this dependent question
        SELECT id INTO existing_answer_id
        FROM public.survey_answers
        WHERE survey_id = NEW.survey_id
          AND survey_question_id = dependent_questions.question_id
          AND COALESCE(item_group, -1) = COALESCE(NEW.item_group, -1)
          AND COALESCE(parent_item_group, -1) = COALESCE(NEW.parent_item_group, -1);

        IF existing_answer_id IS NOT NULL THEN
            -- Update existing answer
            UPDATE public.survey_answers
            SET answer = NEW.answer,
                updated_at = NOW()
            WHERE id = existing_answer_id;
        ELSE
            -- Insert new answer
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
            );
        END IF;
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
Uses check-then-insert/update pattern instead of ON CONFLICT to avoid constraint issues.';

-- ========================================================================
-- PART 2: Fix sync_dependent_question_answers trigger
-- ========================================================================

-- Drop the existing trigger
DROP TRIGGER IF EXISTS trigger_sync_dependent_answers ON public.survey_answers;

-- Update the trigger function to use check-then-insert/update pattern
CREATE OR REPLACE FUNCTION sync_dependent_question_answers()
RETURNS TRIGGER AS $$
DECLARE
    v_dependent_question RECORD;
    v_survey_page_id UUID;
    v_is_multiple BOOLEAN;
    v_item_group INTEGER;
    existing_answer_id UUID;
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
                -- Check if answer already exists
                SELECT id INTO existing_answer_id
                FROM public.survey_answers
                WHERE survey_id = NEW.survey_id
                  AND survey_question_id = v_dependent_question.id
                  AND COALESCE(item_group, -1) = COALESCE(v_item_group, -1);

                IF existing_answer_id IS NOT NULL THEN
                    -- Update existing answer
                    UPDATE public.survey_answers
                    SET answer = NEW.answer,
                        updated_at = NOW()
                    WHERE id = existing_answer_id;
                ELSE
                    -- Insert new answer
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
                    );
                END IF;
            END LOOP;
        ELSE
            -- For non-multiple pages, check if answer exists
            SELECT id INTO existing_answer_id
            FROM public.survey_answers
            WHERE survey_id = NEW.survey_id
              AND survey_question_id = v_dependent_question.id
              AND COALESCE(item_group, -1) = -1;

            IF existing_answer_id IS NOT NULL THEN
                -- Update existing answer
                UPDATE public.survey_answers
                SET answer = NEW.answer,
                    updated_at = NOW()
                WHERE id = existing_answer_id;
            ELSE
                -- Insert new answer
                INSERT INTO public.survey_answers (
                    survey_id,
                    survey_question_id,
                    answer
                ) VALUES (
                    NEW.survey_id,
                    v_dependent_question.id,
                    NEW.answer
                );
            END IF;
        END IF;
    END LOOP;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Recreate the trigger
CREATE TRIGGER trigger_sync_dependent_answers
    AFTER INSERT OR UPDATE OF answer ON public.survey_answers
    FOR EACH ROW
    EXECUTE FUNCTION sync_dependent_question_answers();

COMMENT ON FUNCTION sync_dependent_question_answers() IS
'Trigger function that automatically updates answers for questions that reference
the updated question as their default_value_source. Uses check-then-insert/update
pattern instead of ON CONFLICT to avoid constraint issues.';
