-- ============================================================================
-- Migration: Set is_special flag for special questions
-- Description: Marks certain questions as special based on FlowFrontend fixtures
-- ============================================================================

-- Solar Panel - difficult_access
UPDATE public.survey_questions
SET is_special = true
WHERE name = 'difficult_access';

-- Facade Insulation - moisture_damage
UPDATE public.survey_questions
SET is_special = true
WHERE name = 'moisture_damage';

-- Facade Insulation - window_material (in nested windows)
UPDATE public.survey_questions
SET is_special = true
WHERE name = 'window_material';

-- Facade Insulation - window_glazing (in nested windows)
UPDATE public.survey_questions
SET is_special = true
WHERE name = 'window_glazing';
