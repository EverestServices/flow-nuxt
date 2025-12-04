-- Add conditional visibility field to survey_questions table
ALTER TABLE public.survey_questions
ADD COLUMN IF NOT EXISTS display_conditions JSONB;

COMMENT ON COLUMN public.survey_questions.display_conditions IS 'Conditional display rules for this question. Example: {"field": "current_heating_solution", "operator": "equals", "value": "Egyéb"}. Supported operators: equals, not_equals, greater_than, less_than, greater_or_equal, less_or_equal, contains, contains_any (for multiselect fields)';

-- Set conditional visibility for "Jelenlegi fűtési megoldás (egyéb)"
-- Should only be visible when "current_heating_solution" has value "Egyéb"
UPDATE public.survey_questions
SET display_conditions = jsonb_build_object(
    'field', 'current_heating_solution',
    'operator', 'equals',
    'value', 'Egyéb'
)
WHERE name = 'current_heating_solution_other';

-- Set conditional visibility for "Jelenlegi hőleadó kör (egyéb)"
-- Should only be visible when "current_heat_distribution" has value "Egyéb"
UPDATE public.survey_questions
SET display_conditions = jsonb_build_object(
    'field', 'current_heat_distribution',
    'operator', 'equals',
    'value', 'Egyéb'
)
WHERE name = 'current_heat_distribution_other';
