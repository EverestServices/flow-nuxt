-- ============================================================================
-- Migration: Add Conditional Value Copy Rules
-- Description: Creates a flexible system for copying values between questions
--              based on conditional rules (e.g., "if checkbox is checked, copy value")
-- ============================================================================

-- ========================================================================
-- STEP 1: Create the survey_value_copy_rules table
-- ========================================================================

CREATE TABLE IF NOT EXISTS public.survey_value_copy_rules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- The condition question (e.g., "Falak mindenhol megegyező típusúak")
    condition_question_id UUID NOT NULL REFERENCES public.survey_questions(id) ON DELETE CASCADE,
    
    -- The expected value for the condition to be true (e.g., "true" for switches)
    condition_value TEXT NOT NULL,
    
    -- The source question to copy from (e.g., "Fal típusa")
    source_question_id UUID NOT NULL REFERENCES public.survey_questions(id) ON DELETE CASCADE,
    
    -- The target question to copy to (e.g., "Fal szerkezete" in Falak instances)
    target_question_id UUID NOT NULL REFERENCES public.survey_questions(id) ON DELETE CASCADE,
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE public.survey_value_copy_rules IS
'Defines conditional rules for copying values between survey questions.
When condition_question has the specified value, the value from source_question
is copied to all instances of target_question.';

COMMENT ON COLUMN public.survey_value_copy_rules.condition_question_id IS
'The question whose value determines if the copy should happen (e.g., a switch/checkbox)';

COMMENT ON COLUMN public.survey_value_copy_rules.condition_value IS
'The value that condition_question must have for the copy to occur (e.g., "true")';

COMMENT ON COLUMN public.survey_value_copy_rules.source_question_id IS
'The question from which to copy the value';

COMMENT ON COLUMN public.survey_value_copy_rules.target_question_id IS
'The question to which the value should be copied';

-- Add indexes
CREATE INDEX idx_copy_rules_condition ON public.survey_value_copy_rules(condition_question_id);
CREATE INDEX idx_copy_rules_source ON public.survey_value_copy_rules(source_question_id);
CREATE INDEX idx_copy_rules_target ON public.survey_value_copy_rules(target_question_id);

-- Add updated_at trigger
CREATE TRIGGER update_survey_value_copy_rules_updated_at
    BEFORE UPDATE ON public.survey_value_copy_rules
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ========================================================================
-- STEP 2: Create trigger function for conditional value copying
-- ========================================================================

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

        -- If condition is met, copy the source value to all target instances
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
                -- Get the survey page for the target question
                SELECT survey_page_id INTO target_survey_page_id
                FROM public.survey_questions
                WHERE id = copy_rule.target_question_id;

                -- Find all existing instances of the target page and update them
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
            END IF;
        END IF;
    END LOOP;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION sync_conditional_value_copy() IS
'Trigger function that conditionally copies values between questions based on rules.
Uses check-then-insert/update pattern to avoid ON CONFLICT constraint issues.';

-- Create trigger
CREATE TRIGGER trigger_sync_conditional_value_copy
    AFTER INSERT OR UPDATE OF answer ON public.survey_answers
    FOR EACH ROW
    EXECUTE FUNCTION sync_conditional_value_copy();

-- ========================================================================
-- STEP 3: Insert copy rules
-- ========================================================================

DO $$
DECLARE
    -- Alapadatok Investment
    inv_basic_data_id UUID;
    q_walls_uniform_type_id UUID;
    q_exterior_wall_structure_id UUID;
    
    -- Homlokzati szigetelés Investment
    inv_facade_id UUID;
    page_facade_basic_data_id UUID;
    page_facade_walls_id UUID;
    
    q_wall_thickness_uniform_id UUID;
    q_wall_thickness_avg_id UUID;
    q_wall_thickness_instance_id UUID;
    
    q_foundation_type_uniform_id UUID;
    q_foundation_type_avg_id UUID;
    q_foundation_type_instance_id UUID;
    
    q_wall_structure_instance_id UUID;
BEGIN
    RAISE NOTICE '========================================';
    RAISE NOTICE 'Inserting Conditional Value Copy Rules';
    RAISE NOTICE '========================================';

    -- Get Alapadatok investment
    SELECT id INTO inv_basic_data_id
    FROM public.investments
    WHERE name = 'Alapadatok';

    -- Get Homlokzati szigetelés investment
    SELECT id INTO inv_facade_id
    FROM public.investments
    WHERE persist_name = 'facadeInsulation';

    IF inv_basic_data_id IS NULL OR inv_facade_id IS NULL THEN
        RAISE EXCEPTION 'Required investments not found';
    END IF;

    -- Get Homlokzati szigetelés pages
    SELECT id INTO page_facade_basic_data_id
    FROM public.survey_pages
    WHERE investment_id = inv_facade_id AND type = 'facade_basic_data';

    SELECT id INTO page_facade_walls_id
    FROM public.survey_pages
    WHERE investment_id = inv_facade_id AND type = 'walls';

    -- ========================================================================
    -- Rule 1: Falak mindenhol megegyező típusúak
    -- ========================================================================
    
    -- Get question IDs from Alapadatok
    SELECT sq.id INTO q_walls_uniform_type_id
    FROM public.survey_questions sq
    JOIN public.survey_pages sp ON sq.survey_page_id = sp.id
    WHERE sp.investment_id = inv_basic_data_id
      AND sp.type = 'basic_data'
      AND sq.name = 'walls_uniform_type';

    SELECT sq.id INTO q_exterior_wall_structure_id
    FROM public.survey_questions sq
    JOIN public.survey_pages sp ON sq.survey_page_id = sp.id
    WHERE sp.investment_id = inv_basic_data_id
      AND sp.type = 'basic_data'
      AND sq.name = 'exterior_wall_structure';

    -- Get target question from Homlokzati szigetelés - Falak
    SELECT id INTO q_wall_structure_instance_id
    FROM public.survey_questions
    WHERE survey_page_id = page_facade_walls_id
      AND name = 'wall_structure';

    IF q_walls_uniform_type_id IS NOT NULL 
       AND q_exterior_wall_structure_id IS NOT NULL 
       AND q_wall_structure_instance_id IS NOT NULL THEN
        
        INSERT INTO public.survey_value_copy_rules (
            condition_question_id,
            condition_value,
            source_question_id,
            target_question_id
        ) VALUES (
            q_walls_uniform_type_id,
            'true',
            q_exterior_wall_structure_id,
            q_wall_structure_instance_id
        );
        
        RAISE NOTICE 'Added rule: Falak mindenhol megegyező típusúak';
    END IF;

    -- ========================================================================
    -- Rule 2: Fal vastagsága mindenhol megegyezik
    -- ========================================================================
    
    SELECT id INTO q_wall_thickness_uniform_id
    FROM public.survey_questions
    WHERE survey_page_id = page_facade_basic_data_id
      AND name = 'wall_thickness_uniform';

    SELECT id INTO q_wall_thickness_avg_id
    FROM public.survey_questions
    WHERE survey_page_id = page_facade_basic_data_id
      AND name = 'wall_thickness_avg';

    SELECT id INTO q_wall_thickness_instance_id
    FROM public.survey_questions
    WHERE survey_page_id = page_facade_walls_id
      AND name = 'wall_thickness';

    IF q_wall_thickness_uniform_id IS NOT NULL 
       AND q_wall_thickness_avg_id IS NOT NULL 
       AND q_wall_thickness_instance_id IS NOT NULL THEN
        
        INSERT INTO public.survey_value_copy_rules (
            condition_question_id,
            condition_value,
            source_question_id,
            target_question_id
        ) VALUES (
            q_wall_thickness_uniform_id,
            'true',
            q_wall_thickness_avg_id,
            q_wall_thickness_instance_id
        );
        
        RAISE NOTICE 'Added rule: Fal vastagsága mindenhol megegyezik';
    END IF;

    -- ========================================================================
    -- Rule 3: Lábazat típusa mindenhol megegyezik
    -- ========================================================================
    
    SELECT id INTO q_foundation_type_uniform_id
    FROM public.survey_questions
    WHERE survey_page_id = page_facade_basic_data_id
      AND name = 'foundation_type_uniform';

    SELECT id INTO q_foundation_type_avg_id
    FROM public.survey_questions
    WHERE survey_page_id = page_facade_basic_data_id
      AND name = 'foundation_type_avg';

    SELECT id INTO q_foundation_type_instance_id
    FROM public.survey_questions
    WHERE survey_page_id = page_facade_walls_id
      AND name = 'foundation_type';

    IF q_foundation_type_uniform_id IS NOT NULL 
       AND q_foundation_type_avg_id IS NOT NULL 
       AND q_foundation_type_instance_id IS NOT NULL THEN
        
        INSERT INTO public.survey_value_copy_rules (
            condition_question_id,
            condition_value,
            source_question_id,
            target_question_id
        ) VALUES (
            q_foundation_type_uniform_id,
            'true',
            q_foundation_type_avg_id,
            q_foundation_type_instance_id
        );
        
        RAISE NOTICE 'Added rule: Lábazat típusa mindenhol megegyezik';
    END IF;

    RAISE NOTICE '========================================';
    RAISE NOTICE 'Conditional Value Copy Rules Created!';
    RAISE NOTICE '========================================';
END $$;
