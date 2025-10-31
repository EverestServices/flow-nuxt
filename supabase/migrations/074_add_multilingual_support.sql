-- ============================================================================
-- Migration: Add Multilingual Support to Survey System
-- Description: Converts text fields to JSONB for multilingual support
-- ============================================================================

-- ============================================================================
-- 1. ADD MULTILINGUAL COLUMNS
-- ============================================================================

-- Investments table
ALTER TABLE public.investments
  ADD COLUMN name_translations JSONB;

-- Survey Pages table
ALTER TABLE public.survey_pages
  ADD COLUMN name_translations JSONB,
  ADD COLUMN item_name_template_translations JSONB;

-- Survey Questions table
ALTER TABLE public.survey_questions
  ADD COLUMN name_translations JSONB,
  ADD COLUMN placeholder_translations JSONB,
  ADD COLUMN unit_translations JSONB,
  ADD COLUMN info_message_translations JSONB,
  ADD COLUMN options_translations JSONB;

-- Document Categories table
ALTER TABLE public.document_categories
  ADD COLUMN name_translations JSONB,
  ADD COLUMN description_translations JSONB;

-- Heavy Consumers table
ALTER TABLE public.heavy_consumers
  ADD COLUMN name_translations JSONB;

-- Extra Costs table
ALTER TABLE public.extra_costs
  ADD COLUMN name_translations JSONB;

-- ============================================================================
-- 2. MIGRATE EXISTING DATA TO MULTILINGUAL FORMAT
-- ============================================================================

-- Investments: Convert existing name to Hungarian translation
UPDATE public.investments
SET name_translations = jsonb_build_object('hu', name, 'en', name)
WHERE name IS NOT NULL;

-- Survey Pages: Convert existing name and item_name_template to Hungarian
UPDATE public.survey_pages
SET
  name_translations = jsonb_build_object('hu', name, 'en', name),
  item_name_template_translations = CASE
    WHEN item_name_template IS NOT NULL
    THEN jsonb_build_object('hu', item_name_template, 'en', item_name_template)
    ELSE NULL
  END
WHERE name IS NOT NULL;

-- Survey Questions: Convert all text fields
UPDATE public.survey_questions
SET
  name_translations = jsonb_build_object('hu', name, 'en', name),
  placeholder_translations = CASE
    WHEN placeholder_value IS NOT NULL
    THEN jsonb_build_object('hu', placeholder_value, 'en', placeholder_value)
    ELSE NULL
  END,
  unit_translations = CASE
    WHEN unit IS NOT NULL
    THEN jsonb_build_object('hu', unit, 'en', unit)
    ELSE NULL
  END,
  info_message_translations = CASE
    WHEN info_message IS NOT NULL
    THEN jsonb_build_object('hu', info_message, 'en', info_message)
    ELSE NULL
  END,
  options_translations = CASE
    WHEN options IS NOT NULL AND jsonb_typeof(options) = 'array'
    THEN (
      SELECT jsonb_agg(
        jsonb_build_object(
          'value', elem::text,
          'label', jsonb_build_object('hu', elem::text, 'en', elem::text)
        )
      )
      FROM jsonb_array_elements_text(options) AS elem
    )
    ELSE NULL
  END
WHERE name IS NOT NULL;

-- Document Categories: Convert name and description
UPDATE public.document_categories
SET
  name_translations = jsonb_build_object('hu', name, 'en', name),
  description_translations = CASE
    WHEN description IS NOT NULL
    THEN jsonb_build_object('hu', description, 'en', description)
    ELSE NULL
  END
WHERE name IS NOT NULL;

-- Heavy Consumers: Convert name
UPDATE public.heavy_consumers
SET name_translations = jsonb_build_object('hu', name, 'en', name)
WHERE name IS NOT NULL;

-- Extra Costs: Convert name
UPDATE public.extra_costs
SET name_translations = jsonb_build_object('hu', name, 'en', name)
WHERE name IS NOT NULL;

-- ============================================================================
-- 3. COMMENTS FOR DOCUMENTATION
-- ============================================================================

COMMENT ON COLUMN public.investments.name_translations IS 'Multilingual name stored as JSONB: {"en": "Solar Panel", "hu": "Napelem"}';
COMMENT ON COLUMN public.survey_pages.name_translations IS 'Multilingual page name stored as JSONB: {"en": "General", "hu": "Általános"}';
COMMENT ON COLUMN public.survey_pages.item_name_template_translations IS 'Multilingual item name template stored as JSONB';
COMMENT ON COLUMN public.survey_questions.name_translations IS 'Multilingual question label stored as JSONB';
COMMENT ON COLUMN public.survey_questions.placeholder_translations IS 'Multilingual placeholder text stored as JSONB';
COMMENT ON COLUMN public.survey_questions.unit_translations IS 'Multilingual unit text stored as JSONB: {"en": "kWh", "hu": "kWh"}';
COMMENT ON COLUMN public.survey_questions.info_message_translations IS 'Multilingual info/help message stored as JSONB';
COMMENT ON COLUMN public.survey_questions.options_translations IS 'Multilingual options stored as JSONB array: [{"value": "yes", "label": {"en": "Yes", "hu": "Igen"}}]';
COMMENT ON COLUMN public.document_categories.name_translations IS 'Multilingual category name stored as JSONB';
COMMENT ON COLUMN public.document_categories.description_translations IS 'Multilingual category description stored as JSONB';
COMMENT ON COLUMN public.heavy_consumers.name_translations IS 'Multilingual consumer name stored as JSONB';
COMMENT ON COLUMN public.extra_costs.name_translations IS 'Multilingual cost name stored as JSONB';
