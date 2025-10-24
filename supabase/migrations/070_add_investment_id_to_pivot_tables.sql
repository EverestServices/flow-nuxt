-- ============================================================================
-- Migration: Add investment_id to pivot tables
-- Description: Adds investment_id to scenario_main_components and contract_main_components
--              to allow the same component for multiple investments in the same scenario/contract
-- ============================================================================

-- ============================================================================
-- 1. ADD investment_id TO scenario_main_components
-- ============================================================================

-- Drop the old unique constraint
ALTER TABLE public.scenario_main_components
    DROP CONSTRAINT IF EXISTS scenario_main_components_scenario_id_main_component_id_key;

-- Add investment_id column
ALTER TABLE public.scenario_main_components
    ADD COLUMN investment_id UUID REFERENCES public.investments(id) ON DELETE CASCADE;

-- Create new unique constraint with investment_id
ALTER TABLE public.scenario_main_components
    ADD CONSTRAINT scenario_main_components_unique_key
    UNIQUE(scenario_id, main_component_id, investment_id);

-- Create index for performance
CREATE INDEX idx_scenario_main_components_investment_id
    ON public.scenario_main_components(investment_id);

-- ============================================================================
-- 2. ADD investment_id TO contract_main_components
-- ============================================================================

-- Drop the old unique constraint
ALTER TABLE public.contract_main_components
    DROP CONSTRAINT IF EXISTS contract_main_components_contract_id_main_component_id_key;

-- Add investment_id column
ALTER TABLE public.contract_main_components
    ADD COLUMN investment_id UUID REFERENCES public.investments(id) ON DELETE CASCADE;

-- Create new unique constraint with investment_id
ALTER TABLE public.contract_main_components
    ADD CONSTRAINT contract_main_components_unique_key
    UNIQUE(contract_id, main_component_id, investment_id);

-- Create index for performance
CREATE INDEX idx_contract_main_components_investment_id
    ON public.contract_main_components(investment_id);

-- ============================================================================
-- END OF MIGRATION
-- ============================================================================
