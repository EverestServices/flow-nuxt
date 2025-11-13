-- ============================================================================
-- Migration: Add color_picker to survey_question_type enum
-- Description: Part 1 - Adds color_picker enum value
--              (Must be in separate migration from usage due to PostgreSQL restrictions)
-- ============================================================================

ALTER TYPE survey_question_type ADD VALUE IF NOT EXISTS 'color_picker';
