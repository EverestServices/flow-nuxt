-- ============================================================================
-- Migration: Create discounts table
-- Description: Creates table for discount management with various types
-- ============================================================================

-- Create discounts table
CREATE TABLE IF NOT EXISTS public.discounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    persist_name VARCHAR(100) UNIQUE NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    discount_type VARCHAR(50) NOT NULL CHECK (discount_type IN ('fixed', 'percentage', 'calculated')),
    value NUMERIC(12, 2) DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create index for persist_name
CREATE INDEX IF NOT EXISTS idx_discounts_persist_name ON public.discounts(persist_name);

-- Create index for discount_type
CREATE INDEX IF NOT EXISTS idx_discounts_type ON public.discounts(discount_type);

-- Add comments
COMMENT ON TABLE public.discounts IS 'Stores discount options for contracts';
COMMENT ON COLUMN public.discounts.persist_name IS 'Unique identifier for discount used in code';
COMMENT ON COLUMN public.discounts.name IS 'Display name of the discount';
COMMENT ON COLUMN public.discounts.description IS 'Detailed description of the discount';
COMMENT ON COLUMN public.discounts.discount_type IS 'Type of discount: fixed (amount), percentage, or calculated (computed from data)';
COMMENT ON COLUMN public.discounts.value IS 'Fixed amount or percentage value (not used for calculated discounts)';

-- Enable RLS
ALTER TABLE public.discounts ENABLE ROW LEVEL SECURITY;

-- Create policy for authenticated users to read discounts
CREATE POLICY "Allow authenticated users to read discounts"
    ON public.discounts
    FOR SELECT
    TO authenticated
    USING (true);

-- ============================================================================
-- END OF MIGRATION
-- ============================================================================
