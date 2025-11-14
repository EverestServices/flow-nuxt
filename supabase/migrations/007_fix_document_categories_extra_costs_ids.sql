-- ============================================================================
-- Migration: Add persist_name and survey_pages columns
-- Description: Adds persist_name string identifiers and survey_pages features
-- ============================================================================

-- ============================================================================
-- 1. ADD PERSIST_NAME TO DOCUMENT_CATEGORIES
-- ============================================================================

-- Add persist_name column with UNIQUE constraint
ALTER TABLE public.document_categories
    ADD COLUMN persist_name VARCHAR(255) UNIQUE;

-- ============================================================================
-- 2. ADD PERSIST_NAME TO EXTRA_COSTS
-- ============================================================================

-- Add persist_name column with UNIQUE constraint
ALTER TABLE public.extra_costs
    ADD COLUMN persist_name VARCHAR(255) UNIQUE;

-- ============================================================================
-- 3. ADD ADDITIONAL COLUMNS TO SURVEY_PAGES
-- ============================================================================

-- Add investment_id foreign key column
ALTER TABLE public.survey_pages
    ADD COLUMN investment_id UUID REFERENCES public.investments(id) ON DELETE CASCADE;

-- Add columns for multiple items and item naming
ALTER TABLE public.survey_pages
    ADD COLUMN allow_multiple BOOLEAN DEFAULT FALSE,
    ADD COLUMN allow_delete_first BOOLEAN DEFAULT FALSE,
    ADD COLUMN item_name_template VARCHAR(255);

-- ============================================================================
-- END OF MIGRATION
-- ============================================================================
