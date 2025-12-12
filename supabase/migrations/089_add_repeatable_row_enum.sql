-- ============================================================================
-- Migration: Add repeatable_row to survey_question_type enum
-- Description: Adds the repeatable_row value to the enum type
-- ============================================================================

-- Add repeatable_row to the survey_question_type enum
ALTER TYPE survey_question_type ADD VALUE IF NOT EXISTS 'repeatable_row';

-- ============================================================================
-- END OF MIGRATION
-- ============================================================================
