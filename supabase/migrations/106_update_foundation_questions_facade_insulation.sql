-- Migration: Update foundation type questions on Facade Insulation Basic Data page
-- Date: 2025-12-18
-- Description:
--   1. Convert foundation_type to icon_selector with icons
--   2. Add "Nincsen" option to foundation_type
--   3. Add display condition to foundation_height (question already exists)
--   4. Add display conditions to hide foundation_height and protrusion_amount when foundation_type = "Nincsen"

-- Get the survey_page_id for 'Homlokzati szigetelés adatok' page
DO $$
DECLARE
  v_page_id uuid;
BEGIN
  -- Find page by investment persist_name and page type
  SELECT sp.id INTO v_page_id
  FROM survey_pages sp
  JOIN investments i ON i.id = sp.investment_id
  WHERE i.persist_name = 'facadeInsulation'
    AND sp.type = 'facade_basic_data';

  IF v_page_id IS NULL THEN
    RAISE EXCEPTION 'Survey page not found: facadeInsulation -> facade_basic_data';
  END IF;

  -- Step 1: Update foundation_type to icon_selector with all three options
  UPDATE survey_questions
  SET
    type = 'icon_selector',
    options_translations = '[
      {"icon": "i-lucide-arrow-up", "label": {"en": "Positive", "hu": "Pozitív"}, "value": "Pozitív"},
      {"icon": "i-lucide-arrow-down", "label": {"en": "Negative", "hu": "Negatív"}, "value": "Negatív"},
      {"icon": "i-lucide-x", "label": {"en": "None", "hu": "Nincsen"}, "value": "Nincsen"}
    ]'::jsonb,
    options = NULL,
    updated_at = now()
  WHERE name = 'foundation_type'
    AND survey_page_id = v_page_id;

  -- Step 2: Add display condition to foundation_height
  UPDATE survey_questions
  SET
    display_conditions = '{"field": "foundation_type", "operator": "not_equals", "value": "Nincsen"}',
    updated_at = now()
  WHERE name = 'foundation_height'
    AND survey_page_id = v_page_id;

  -- Step 3: Add display condition to protrusion_amount
  UPDATE survey_questions
  SET
    display_conditions = '{"field": "foundation_type", "operator": "not_equals", "value": "Nincsen"}',
    updated_at = now()
  WHERE name = 'protrusion_amount'
    AND survey_page_id = v_page_id;

  RAISE NOTICE 'Updated foundation questions on page: %', v_page_id;
END $$;
