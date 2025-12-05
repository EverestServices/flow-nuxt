-- ============================================================================
-- Migration: Add Sequence to Extra Costs
-- Description: Adds sequence column to extra_costs table and sets sequence
--              for Facade Insulation extra costs based on the order in 118
-- ============================================================================

-- ============================================================================
-- STEP 1: Add sequence column to extra_costs table
-- ============================================================================

ALTER TABLE public.extra_costs
ADD COLUMN IF NOT EXISTS sequence INTEGER;

COMMENT ON COLUMN public.extra_costs.sequence IS 'Display order of extra costs within an investment';

CREATE INDEX IF NOT EXISTS idx_extra_costs_sequence ON public.extra_costs(sequence);

-- ============================================================================
-- STEP 2: Set sequence values for Facade Insulation extra costs
-- ============================================================================

DO $$
DECLARE
    inv_facade_insulation_id UUID;
BEGIN
    -- Get Facade Insulation investment ID
    SELECT id INTO inv_facade_insulation_id
    FROM public.investments
    WHERE persist_name = 'facadeInsulation';

    IF inv_facade_insulation_id IS NOT NULL THEN
        -- Set sequences based on persist_name (which corresponds to the order in migration 118)

        UPDATE public.extra_costs SET sequence = 1 WHERE investment_id = inv_facade_insulation_id AND persist_name = 'scaffolding_standard';
        UPDATE public.extra_costs SET sequence = 2 WHERE investment_id = inv_facade_insulation_id AND persist_name = 'scaffolding_extended';
        UPDATE public.extra_costs SET sequence = 3 WHERE investment_id = inv_facade_insulation_id AND persist_name = 'antenna_dismantling';
        UPDATE public.extra_costs SET sequence = 4 WHERE investment_id = inv_facade_insulation_id AND persist_name = 'antenna_installation';
        UPDATE public.extra_costs SET sequence = 5 WHERE investment_id = inv_facade_insulation_id AND persist_name = 'gutter_removal';
        UPDATE public.extra_costs SET sequence = 6 WHERE investment_id = inv_facade_insulation_id AND persist_name = 'gutter_reinstallation';
        UPDATE public.extra_costs SET sequence = 7 WHERE investment_id = inv_facade_insulation_id AND persist_name = 'downpipe_removal';
        UPDATE public.extra_costs SET sequence = 8 WHERE investment_id = inv_facade_insulation_id AND persist_name = 'downpipe_reinstallation';
        UPDATE public.extra_costs SET sequence = 9 WHERE investment_id = inv_facade_insulation_id AND persist_name = 'vegetation_removal';
        UPDATE public.extra_costs SET sequence = 10 WHERE investment_id = inv_facade_insulation_id AND persist_name = 'canopy_demolition';
        UPDATE public.extra_costs SET sequence = 11 WHERE investment_id = inv_facade_insulation_id AND persist_name = 'canopy_reconstruction';
        UPDATE public.extra_costs SET sequence = 12 WHERE investment_id = inv_facade_insulation_id AND persist_name = 'ventilation_extension';
        UPDATE public.extra_costs SET sequence = 13 WHERE investment_id = inv_facade_insulation_id AND persist_name = 'lamp_work';
        UPDATE public.extra_costs SET sequence = 14 WHERE investment_id = inv_facade_insulation_id AND persist_name = 'security_work';
        UPDATE public.extra_costs SET sequence = 15 WHERE investment_id = inv_facade_insulation_id AND persist_name = 'shutter_removal';
        UPDATE public.extra_costs SET sequence = 16 WHERE investment_id = inv_facade_insulation_id AND persist_name = 'shutter_reinstallation';
        UPDATE public.extra_costs SET sequence = 17 WHERE investment_id = inv_facade_insulation_id AND persist_name = 'window_grill_removal';
        UPDATE public.extra_costs SET sequence = 18 WHERE investment_id = inv_facade_insulation_id AND persist_name = 'window_grill_reinstallation';
        UPDATE public.extra_costs SET sequence = 19 WHERE investment_id = inv_facade_insulation_id AND persist_name = 'sill_cutting';
        UPDATE public.extra_costs SET sequence = 20 WHERE investment_id = inv_facade_insulation_id AND persist_name = 'chimney_extension';
        UPDATE public.extra_costs SET sequence = 21 WHERE investment_id = inv_facade_insulation_id AND persist_name = 'ac_unit_work';
        UPDATE public.extra_costs SET sequence = 22 WHERE investment_id = inv_facade_insulation_id AND persist_name = 'gas_pipe_boxing';
        UPDATE public.extra_costs SET sequence = 23 WHERE investment_id = inv_facade_insulation_id AND persist_name = 'gas_pipe_lifting';
        UPDATE public.extra_costs SET sequence = 24 WHERE investment_id = inv_facade_insulation_id AND persist_name = 'gas_meter_work';
        UPDATE public.extra_costs SET sequence = 25 WHERE investment_id = inv_facade_insulation_id AND persist_name = 'electric_meter_work';
        UPDATE public.extra_costs SET sequence = 26 WHERE investment_id = inv_facade_insulation_id AND persist_name = 'railing_removal';
        UPDATE public.extra_costs SET sequence = 27 WHERE investment_id = inv_facade_insulation_id AND persist_name = 'railing_reinstallation';
        UPDATE public.extra_costs SET sequence = 28 WHERE investment_id = inv_facade_insulation_id AND persist_name = 'plinth_leveling';

        RAISE NOTICE 'Set sequence values for 28 Facade Insulation extra costs';
    ELSE
        RAISE WARNING 'Facade Insulation investment not found (persist_name: facadeInsulation)';
    END IF;

END $$;
