-- Migration: Extend value copy rules to support simple (non-instance) fields
-- Description: Modifies the sync_conditional_value_copy trigger to handle copying
--              between simple fields on the same page (not just allow_multiple pages)

CREATE OR REPLACE FUNCTION sync_conditional_value_copy()
RETURNS TRIGGER AS $$
DECLARE
    copy_rule RECORD;
    condition_met BOOLEAN;
    condition_answer TEXT;
    source_answer TEXT;
    target_survey_page_id UUID;
    target_instance_record RECORD;
    existing_answer_id UUID;
    target_page_allow_multiple BOOLEAN;
BEGIN
    -- Check if this question is involved in any copy rules (as condition or source)
    FOR copy_rule IN
        SELECT
            r.id,
            r.condition_question_id,
            r.condition_value,
            r.source_question_id,
            r.target_question_id
        FROM public.survey_value_copy_rules r
        WHERE r.condition_question_id = NEW.survey_question_id
           OR r.source_question_id = NEW.survey_question_id
    LOOP
        -- Get the condition value
        IF copy_rule.condition_question_id = NEW.survey_question_id THEN
            condition_answer := NEW.answer;
        ELSE
            SELECT answer INTO condition_answer
            FROM public.survey_answers
            WHERE survey_id = NEW.survey_id
              AND survey_question_id = copy_rule.condition_question_id
              AND item_group IS NULL
            LIMIT 1;
        END IF;

        -- Check if condition is met
        condition_met := (condition_answer = copy_rule.condition_value);

        -- If condition is met, copy the source value to target
        IF condition_met THEN
            -- Get the source value
            IF copy_rule.source_question_id = NEW.survey_question_id THEN
                source_answer := NEW.answer;
            ELSE
                SELECT answer INTO source_answer
                FROM public.survey_answers
                WHERE survey_id = NEW.survey_id
                  AND survey_question_id = copy_rule.source_question_id
                  AND item_group IS NULL
                LIMIT 1;
            END IF;

            -- Only proceed if we have a source value
            IF source_answer IS NOT NULL THEN
                -- Get the survey page and its allow_multiple setting for the target question
                SELECT
                    sq.survey_page_id,
                    sp.allow_multiple
                INTO
                    target_survey_page_id,
                    target_page_allow_multiple
                FROM public.survey_questions sq
                JOIN public.survey_pages sp ON sq.survey_page_id = sp.id
                WHERE sq.id = copy_rule.target_question_id;

                -- Check if the target page allows multiple instances
                IF target_page_allow_multiple THEN
                    -- Original behavior: copy to all instances
                    FOR target_instance_record IN
                        SELECT DISTINCT item_group
                        FROM public.survey_answers
                        WHERE survey_id = NEW.survey_id
                          AND survey_question_id IN (
                              SELECT id FROM public.survey_questions
                              WHERE survey_page_id = target_survey_page_id
                          )
                          AND item_group IS NOT NULL
                        ORDER BY item_group
                    LOOP
                        -- Check if an answer already exists for this target question and instance
                        SELECT id INTO existing_answer_id
                        FROM public.survey_answers
                        WHERE survey_id = NEW.survey_id
                          AND survey_question_id = copy_rule.target_question_id
                          AND item_group = target_instance_record.item_group;

                        IF existing_answer_id IS NOT NULL THEN
                            -- Update existing answer
                            UPDATE public.survey_answers
                            SET answer = source_answer,
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
                                copy_rule.target_question_id,
                                source_answer,
                                target_instance_record.item_group
                            );
                        END IF;
                    END LOOP;
                ELSE
                    -- New behavior: copy to simple field (no item_group)
                    -- Check if an answer already exists for this target question
                    SELECT id INTO existing_answer_id
                    FROM public.survey_answers
                    WHERE survey_id = NEW.survey_id
                      AND survey_question_id = copy_rule.target_question_id
                      AND item_group IS NULL;

                    IF existing_answer_id IS NOT NULL THEN
                        -- Update existing answer
                        UPDATE public.survey_answers
                        SET answer = source_answer,
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
                            copy_rule.target_question_id,
                            source_answer,
                            NULL
                        );
                    END IF;
                END IF;
            END IF;
        ELSE
            -- Condition NOT met - clear the target field if it was previously copied
            -- This allows the user to manually enter a value when the switch is off

            -- Get the survey page and its allow_multiple setting for the target question
            SELECT
                sq.survey_page_id,
                sp.allow_multiple
            INTO
                target_survey_page_id,
                target_page_allow_multiple
            FROM public.survey_questions sq
            JOIN public.survey_pages sp ON sq.survey_page_id = sp.id
            WHERE sq.id = copy_rule.target_question_id;

            -- Only clear for simple fields, not for allow_multiple pages
            IF NOT target_page_allow_multiple THEN
                -- Delete the answer for the target question when condition is not met
                DELETE FROM public.survey_answers
                WHERE survey_id = NEW.survey_id
                  AND survey_question_id = copy_rule.target_question_id
                  AND item_group IS NULL;
            END IF;
        END IF;
    END LOOP;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION sync_conditional_value_copy() IS
'Trigger function that conditionally copies values between questions based on rules.
Supports both allow_multiple pages (copies to all instances) and simple fields (single value).
When condition is not met for simple fields, clears the target field to allow manual entry.
Uses check-then-insert/update pattern to avoid ON CONFLICT constraint issues.';
