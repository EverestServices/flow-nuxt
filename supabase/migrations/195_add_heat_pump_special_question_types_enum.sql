-- Migration: Add special question types enum values
-- Description: Adds repeatable_field, multiselect_with_distribution, and drawing_area types to enum
--              These must be added in a separate transaction before being used

ALTER TYPE survey_question_type ADD VALUE IF NOT EXISTS 'repeatable_field';
ALTER TYPE survey_question_type ADD VALUE IF NOT EXISTS 'multiselect_with_distribution';
ALTER TYPE survey_question_type ADD VALUE IF NOT EXISTS 'drawing_area';
