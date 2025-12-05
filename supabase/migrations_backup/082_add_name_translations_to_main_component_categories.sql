-- ============================================================================
-- Migration: Add name_translations to main_component_categories
-- Description: Adds JSONB column for multilingual category names
-- ============================================================================

-- Add name_translations column to main_component_categories table
ALTER TABLE public.main_component_categories
ADD COLUMN name_translations JSONB DEFAULT '{}'::jsonb;

-- Create index for faster JSONB queries
CREATE INDEX idx_main_component_categories_name_translations
ON public.main_component_categories USING GIN (name_translations);

-- ============================================================================
-- END OF MIGRATION
-- ============================================================================
