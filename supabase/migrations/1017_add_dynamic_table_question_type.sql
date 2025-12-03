-- ============================================================================
-- Migration: Add dynamic_table to survey_question_type enum
-- Description: Adds the 'dynamic_table' type to the survey_question_type enum
-- ============================================================================

-- Add 'dynamic_table' to the survey_question_type enum
ALTER TYPE survey_question_type ADD VALUE IF NOT EXISTS 'dynamic_table';

-- ============================================================================
-- END OF MIGRATION
-- ============================================================================
