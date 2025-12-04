-- Migration: Add Functions and Triggers
-- Description: Database functions required for RLS policies and automation
-- Dependencies: 400-433 (structure), 495 (RLS policies)

-- =============================================================================
-- HELPER FUNCTIONS FOR RLS POLICIES
-- =============================================================================

CREATE OR REPLACE FUNCTION public.get_user_company_id(user_uuid uuid) RETURNS uuid
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    company_uuid UUID;
BEGIN
    SELECT company_id INTO company_uuid
    FROM public.user_profiles
    WHERE user_id = user_uuid;

    RETURN company_uuid;
END;
$$;

CREATE OR REPLACE FUNCTION public.get_current_user_company_id() RETURNS uuid
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    AS $$
DECLARE
  user_company_id UUID;
BEGIN
  SELECT company_id INTO user_company_id
  FROM user_profiles
  WHERE user_id = auth.uid()
  LIMIT 1;

  RETURN user_company_id;
END;
$$;

CREATE OR REPLACE FUNCTION public.get_default_value_from_source(p_survey_id uuid, p_source_question_id uuid) RETURNS text
    LANGUAGE plpgsql STABLE
    AS $$
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
$$;

CREATE OR REPLACE FUNCTION public.get_last_sync_for_entity(p_entity_type character varying, p_entity_id uuid, p_external_system character varying DEFAULT NULL::character varying) RETURNS TABLE(id uuid, created_at timestamp with time zone, external_system character varying, direction public.sync_direction, status public.sync_status, error_message text, http_status_code integer, duration_ms integer)
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        l.id,
        l.created_at,
        l.external_system,
        l.direction,
        l.status,
        l.error_message,
        l.http_status_code,
        l.duration_ms
    FROM public.external_sync_logs l
    WHERE l.entity_type = p_entity_type
        AND l.entity_id = p_entity_id
        AND (p_external_system IS NULL OR l.external_system = p_external_system)
    ORDER BY l.created_at DESC
    LIMIT 1;
END;
$$;

CREATE OR REPLACE FUNCTION public.handle_new_user() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
  default_company_id UUID := 'f35b7a0c-6b54-4d0e-bc6a-182a64b8cc44'; -- Your existing company ID
BEGIN
  -- Insert a new user profile when a user is created
  INSERT INTO public.user_profiles (
    user_id,
    first_name,
    last_name,
    email,
    avatar_url,
    company_id,
    is_online,
    last_seen,
    last_activity
  )
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'first_name', 'New'),
    COALESCE(NEW.raw_user_meta_data->>'last_name', 'User'),
    NEW.email,
    NEW.raw_user_meta_data->>'avatar_url',
    default_company_id,
    FALSE,
    NOW(),
    NOW()
  );

  RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN
    -- Log the error but don't prevent user creation
    RAISE NOTICE 'Error creating user profile for user %: %', NEW.id, SQLERRM;
    RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.set_ticket_number() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.ticket_number IS NULL THEN
        NEW.ticket_number := generate_ticket_number();
    END IF;
    RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.sync_conditional_value_copy() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
$$;

CREATE OR REPLACE FUNCTION public.sync_default_value_inheritance() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
$$;

CREATE OR REPLACE FUNCTION public.sync_dependent_question_answers() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
$$;

-- =============================================================================
-- TRIGGERS
-- =============================================================================

CREATE TRIGGER update_companies_updated_at
    BEFORE UPDATE ON companies
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_clients_updated_at
    BEFORE UPDATE ON clients
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_investments_updated_at
    BEFORE UPDATE ON investments
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_surveys_updated_at
    BEFORE UPDATE ON surveys
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_heavy_consumers_updated_at
    BEFORE UPDATE ON heavy_consumers
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_scenarios_updated_at
    BEFORE UPDATE ON scenarios
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_electric_cars_updated_at
    BEFORE UPDATE ON electric_cars
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_contracts_updated_at
    BEFORE UPDATE ON contracts
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_extra_costs_updated_at
    BEFORE UPDATE ON extra_costs
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_survey_pages_updated_at
    BEFORE UPDATE ON survey_pages
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_survey_questions_updated_at
    BEFORE UPDATE ON survey_questions
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_survey_answers_updated_at
    BEFORE UPDATE ON survey_answers
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_document_categories_updated_at
    BEFORE UPDATE ON document_categories
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_documents_updated_at
    BEFORE UPDATE ON documents
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_main_component_categories_updated_at
    BEFORE UPDATE ON main_component_categories
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_main_components_updated_at
    BEFORE UPDATE ON main_components
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_main_component_category_investments_updated_at
    BEFORE UPDATE ON main_component_category_investments
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_scenario_main_components_updated_at
    BEFORE UPDATE ON scenario_main_components
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_contract_main_components_updated_at
    BEFORE UPDATE ON contract_main_components
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_survey_settings_updated_at
    BEFORE UPDATE ON survey_settings
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_monthly_climate_data_updated_at
    BEFORE UPDATE ON monthly_climate_data
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_subsidies_updated_at
    BEFORE UPDATE ON subsidies
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_survey_subsidies_updated_at
    BEFORE UPDATE ON survey_subsidies
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_measure_walls_updated_at
    BEFORE UPDATE ON measure_walls
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_measure_wall_images_updated_at
    BEFORE UPDATE ON measure_wall_images
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_measure_polygons_updated_at
    BEFORE UPDATE ON measure_polygons
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_contract_investments_updated_at
    BEFORE UPDATE ON contract_investments
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_contract_extra_costs_updated_at
    BEFORE UPDATE ON contract_extra_costs
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_contract_discounts_updated_at
    BEFORE UPDATE ON contract_discounts
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER sync_default_value_inheritance
AFTER INSERT OR UPDATE ON survey_answers
FOR EACH ROW
EXECUTE FUNCTION sync_default_value_inheritance();

CREATE TRIGGER trigger_sync_dependent_answers
    AFTER INSERT OR UPDATE OF answer ON survey_answers
    FOR EACH ROW
    EXECUTE FUNCTION sync_dependent_question_answers();

CREATE TRIGGER update_survey_value_copy_rules_updated_at
    BEFORE UPDATE ON survey_value_copy_rules
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_sync_conditional_value_copy
    AFTER INSERT OR UPDATE OF answer ON survey_answers
    FOR EACH ROW
    EXECUTE FUNCTION sync_conditional_value_copy();

