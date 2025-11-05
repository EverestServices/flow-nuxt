-- Add multiselect type to survey_question_type enum
ALTER TYPE survey_question_type ADD VALUE IF NOT EXISTS 'multiselect';

-- Update comment to include multiselect
COMMENT ON TYPE survey_question_type IS 'Survey question types: text, textarea, switch, dropdown, multiselect, title, phase_toggle, dual_toggle, slider, range, number, orientation_selector, warning, calculated';
