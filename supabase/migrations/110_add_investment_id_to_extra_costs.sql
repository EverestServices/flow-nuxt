-- ============================================================================
-- Migration: Add investment_id column to extra_costs table
-- Description: Links extra costs to specific investments
-- ============================================================================

-- Add investment_id column to extra_costs table
ALTER TABLE public.extra_costs
ADD COLUMN IF NOT EXISTS investment_id UUID REFERENCES public.investments(id) ON DELETE CASCADE;

COMMENT ON COLUMN public.extra_costs.investment_id IS 'References the investment this extra cost belongs to. NULL means it is a general extra cost.';

-- Create index for better query performance
CREATE INDEX IF NOT EXISTS idx_extra_costs_investment_id ON public.extra_costs(investment_id);
