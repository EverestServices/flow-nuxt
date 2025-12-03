-- Migration: Add OFP calculation field to scenarios
-- Description: Stores OFP (Otthon Felujitasi Program) calculation results from Sherpa
-- Date: 2025-11-19

-- ============================================================================
-- 1. ADD OFP CALCULATION COLUMN TO SCENARIOS
-- ============================================================================

ALTER TABLE public.scenarios
ADD COLUMN IF NOT EXISTS ofp_calculation JSONB;

-- ============================================================================
-- 2. ADD COMMENT
-- ============================================================================

COMMENT ON COLUMN public.scenarios.ofp_calculation IS 'OFP calculation results from Sherpa. Contains: calculations (per investment), totals, percentage, calculated_at';

-- ============================================================================
-- 3. CREATE INDEX FOR QUERYING
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_scenarios_ofp_calculation
ON public.scenarios USING GIN (ofp_calculation)
WHERE ofp_calculation IS NOT NULL;
