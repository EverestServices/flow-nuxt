-- ============================================================================
-- Migration: Add OFP-specific Heat Pump Extra Costs
-- Description: Adds metadata column to extra_costs table and creates
--              OFP-specific extra costs for Heat Pump investment
-- ============================================================================

-- ============================================================================
-- STEP 1: Add metadata column to extra_costs table
-- ============================================================================

ALTER TABLE public.extra_costs
ADD COLUMN IF NOT EXISTS metadata JSONB;

COMMENT ON COLUMN public.extra_costs.metadata IS 'Additional metadata for extra cost stored as JSONB: {"is_ofp_specific": true, "mutually_exclusive_group": "hmw_tank", "ofp_api_key": "HMW 200L"}';

-- ============================================================================
-- STEP 2: Create OFP-specific Heat Pump Extra Costs
-- ============================================================================

DO $$
DECLARE
    inv_heat_pump_id UUID;
    next_sequence INT;
BEGIN
    -- Get Heat Pump Investment ID
    SELECT id INTO inv_heat_pump_id FROM public.investments WHERE persist_name = 'heatPump';

    IF inv_heat_pump_id IS NOT NULL THEN
        RAISE NOTICE 'Creating OFP-specific extra costs for Heat Pump (ID: %)', inv_heat_pump_id;

        -- Get next sequence number
        SELECT COALESCE(MAX(sequence), 0) + 1 INTO next_sequence
        FROM public.extra_costs
        WHERE investment_id = inv_heat_pump_id;

        -- HMW tartály 200L (mutually exclusive group: hmw_tank)
        INSERT INTO public.extra_costs (
            investment_id,
            name,
            name_translations,
            persist_name,
            price,
            is_quantity_based,
            category,
            sequence,
            metadata
        ) VALUES (
            inv_heat_pump_id,
            'HMW tartály 200L',
            jsonb_build_object('hu', 'HMW tartály 200L', 'en', 'HMW tank 200L'),
            'hmw_200',
            444500, -- Bruttó ár (350,000 * 1.27)
            false,
            'ofp',
            next_sequence,
            jsonb_build_object(
                'is_ofp_specific', true,
                'mutually_exclusive_group', 'hmw_tank',
                'ofp_api_key', 'HMW 200L'
            )
        );

        -- HMW tartály 300L (mutually exclusive group: hmw_tank)
        INSERT INTO public.extra_costs (
            investment_id,
            name,
            name_translations,
            persist_name,
            price,
            is_quantity_based,
            category,
            sequence,
            metadata
        ) VALUES (
            inv_heat_pump_id,
            'HMW tartály 300L',
            jsonb_build_object('hu', 'HMW tartály 300L', 'en', 'HMW tank 300L'),
            'hmw_300',
            527050, -- Bruttó ár (415,000 * 1.27)
            false,
            'ofp',
            next_sequence + 1,
            jsonb_build_object(
                'is_ofp_specific', true,
                'mutually_exclusive_group', 'hmw_tank',
                'ofp_api_key', 'HMW 300L'
            )
        );

        -- Hibrid bekötés
        INSERT INTO public.extra_costs (
            investment_id,
            name,
            name_translations,
            persist_name,
            price,
            is_quantity_based,
            category,
            sequence,
            metadata
        ) VALUES (
            inv_heat_pump_id,
            'Hibrid bekötés',
            jsonb_build_object('hu', 'Hibrid bekötés', 'en', 'Hybrid connection'),
            'hibrid_bekotas',
            150000, -- Bruttó ár (118,110 * 1.27 ≈ 150,000)
            false,
            'ofp',
            next_sequence + 2,
            jsonb_build_object(
                'is_ofp_specific', true,
                'ofp_api_key', 'Hibrid bekötés'
            )
        );

        RAISE NOTICE 'Created 3 OFP-specific extra costs for Heat Pump';
    ELSE
        RAISE WARNING 'Heat Pump investment not found (persist_name: heatPump)';
    END IF;

    -- ========================================================================
    -- Summary
    -- ========================================================================

    RAISE NOTICE '========================================';
    RAISE NOTICE 'Successfully created OFP extra costs for:';
    RAISE NOTICE '  - Heat Pump: 3 items';
    RAISE NOTICE '    * HMW tartály 200L: 444,500 Ft';
    RAISE NOTICE '    * HMW tartály 300L: 527,050 Ft';
    RAISE NOTICE '    * Hibrid bekötés: 150,000 Ft';
    RAISE NOTICE '========================================';

END $$;
