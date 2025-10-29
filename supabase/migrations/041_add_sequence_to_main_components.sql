-- ============================================================================
-- Migration: Add sequence columns to main components system
-- Description: Adds sequence ordering to main_component_categories and main_components
-- ============================================================================

-- ============================================================================
-- 1. ADD SEQUENCE TO MAIN_COMPONENT_CATEGORIES
-- ============================================================================

ALTER TABLE public.main_component_categories
ADD COLUMN IF NOT EXISTS sequence INTEGER;

-- ============================================================================
-- 2. ADD SEQUENCE TO MAIN_COMPONENTS
-- ============================================================================

ALTER TABLE public.main_components
ADD COLUMN IF NOT EXISTS sequence INTEGER;

-- ============================================================================
-- 3. CREATE INDEXES FOR SEQUENCE ORDERING
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_main_component_categories_sequence ON public.main_component_categories(sequence);
CREATE INDEX IF NOT EXISTS idx_main_components_sequence ON public.main_components(main_component_category_id, sequence);

-- ============================================================================
-- END OF MIGRATION
-- ============================================================================
