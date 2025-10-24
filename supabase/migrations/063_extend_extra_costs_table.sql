-- ============================================================================
-- Migration: Extend extra_costs table for solar extra costs
-- Description: Adds description, persist_name, is_quantity_based, category
-- ============================================================================

-- Add new columns to extra_costs table
ALTER TABLE public.extra_costs
ADD COLUMN IF NOT EXISTS persist_name VARCHAR(100) UNIQUE,
ADD COLUMN IF NOT EXISTS description TEXT,
ADD COLUMN IF NOT EXISTS is_quantity_based BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS category VARCHAR(100);

-- Create index for persist_name
CREATE INDEX IF NOT EXISTS idx_extra_costs_persist_name ON public.extra_costs(persist_name);

-- Create index for category
CREATE INDEX IF NOT EXISTS idx_extra_costs_category ON public.extra_costs(category);

-- Add comment
COMMENT ON COLUMN public.extra_costs.persist_name IS 'Unique identifier for extra cost used in code';
COMMENT ON COLUMN public.extra_costs.description IS 'Detailed description of the extra cost';
COMMENT ON COLUMN public.extra_costs.is_quantity_based IS 'Whether this cost has a quantity input (true) or just a switch (false)';
COMMENT ON COLUMN public.extra_costs.category IS 'Category grouping for the extra cost (general, connections, etc.)';

-- Update existing extra costs with persist_name from name (convert to snake_case)
UPDATE public.extra_costs
SET persist_name = lower(replace(replace(name, 'ő', 'o'), ' ', '-'))
WHERE persist_name IS NULL;

-- ============================================================================
-- END OF MIGRATION
-- ============================================================================
