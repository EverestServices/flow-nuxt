-- ============================================================================
-- Migration: Add icon_selector to survey_question_type enum
-- Description: Adds the new icon_selector type to the enum
--              (Must be in separate migration from usage due to PostgreSQL constraints)
-- ============================================================================

-- Add icon_selector to the survey_question_type enum
ALTER TYPE survey_question_type ADD VALUE IF NOT EXISTS 'icon_selector';
