-- Add display conditions for phase_2 and phase_3 questions
-- They should only be visible when phase_count = '3'

-- Update phase_2 questions
UPDATE public.survey_questions
SET display_conditions = jsonb_build_object(
  'field', 'phase_count',
  'operator', 'equals',
  'value', '3'
)
WHERE name = 'phase_2';

-- Update phase_3 questions
UPDATE public.survey_questions
SET display_conditions = jsonb_build_object(
  'field', 'phase_count',
  'operator', 'equals',
  'value', '3'
)
WHERE name = 'phase_3';
