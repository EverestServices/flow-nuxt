-- ============================================================================
-- Migration: Add placeholder template support
-- Description: Adds apply_template_to_placeholder column to enable dynamic
--              placeholder generation using template variables
-- ============================================================================

-- Add column to enable placeholder templating
ALTER TABLE public.survey_questions
ADD COLUMN IF NOT EXISTS apply_template_to_placeholder BOOLEAN DEFAULT false;

-- Add comment for documentation
COMMENT ON COLUMN public.survey_questions.apply_template_to_placeholder IS
'When true, template_variables will be processed in placeholder_translations/placeholder_value to create dynamic placeholders based on other field values.';
