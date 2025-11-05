-- ============================================================================
-- Migration: Add Template Variables Support
-- Description: Adds template_variables column to survey_questions table
--              and updates electric_storage_heater_warning to use dynamic templates
-- ============================================================================

-- ========================================================================
-- 1. Add template_variables column
-- ========================================================================

ALTER TABLE public.survey_questions
ADD COLUMN IF NOT EXISTS template_variables JSONB;

COMMENT ON COLUMN public.survey_questions.template_variables IS 'Template variable definitions for dynamic text replacement. Example: {"selectedHeatingMethods": {"type": "matched_conditional_values", "field": "heating_methods"}}. Supported types: matched_conditional_values (values that match display_conditions), field_value (direct field value), conditional_count (count of matched conditions)';

-- ========================================================================
-- 2. Update electric_storage_heater_warning question
-- ========================================================================

DO $$
DECLARE
    question_id UUID;
BEGIN
    -- Get the electric_storage_heater_warning question ID
    SELECT id INTO question_id
    FROM public.survey_questions
    WHERE name = 'electric_storage_heater_warning';

    IF question_id IS NULL THEN
        RAISE EXCEPTION 'electric_storage_heater_warning question not found';
    END IF;

    -- Update name_translations to use template variable
    UPDATE public.survey_questions
    SET name_translations = jsonb_build_object(
        'hu', '💡 Az alábbi kérdések a kiválasztott fűtési módok miatt jelennek meg: {selectedHeatingMethods}',
        'en', '💡 The following questions appear due to the selected heating methods: {selectedHeatingMethods}'
    )
    WHERE id = question_id;

    -- Set template_variables definition
    UPDATE public.survey_questions
    SET template_variables = jsonb_build_object(
        'selectedHeatingMethods', jsonb_build_object(
            'type', 'matched_conditional_values',
            'field', 'heating_methods'
        )
    )
    WHERE id = question_id;

    RAISE NOTICE 'Successfully updated electric_storage_heater_warning with template variables';

END $$;
