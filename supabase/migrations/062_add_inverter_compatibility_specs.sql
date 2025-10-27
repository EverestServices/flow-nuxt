-- ============================================================================
-- Migration: Add compatibility specifications to inverters
-- Description: Populates specifications JSONB field with compatibility data
-- ============================================================================

-- Update Solax X1 Hybrid 6.0-D (6kW inverter)
UPDATE public.main_components
SET specifications = jsonb_build_object(
    'compatibility', jsonb_build_object(
        'min_panels', 6,
        'max_panels', 20,
        'mppt_inputs', 2
    )
)
WHERE persist_name = 'sp-inverter-001';

-- Update Huawei SUN2000-8KTL-M1 (8kW inverter)
UPDATE public.main_components
SET specifications = jsonb_build_object(
    'compatibility', jsonb_build_object(
        'min_panels', 8,
        'max_panels', 26,
        'mppt_inputs', 2
    )
)
WHERE persist_name = 'sp-inverter-002';

-- Update Fronius Symo 10.0-3-M (10kW inverter)
UPDATE public.main_components
SET specifications = jsonb_build_object(
    'compatibility', jsonb_build_object(
        'min_panels', 10,
        'max_panels', 31,
        'mppt_inputs', 2
    )
)
WHERE persist_name = 'sp-inverter-003';

-- Update Solax X3 Hybrid 10.0-D (10kW inverter)
UPDATE public.main_components
SET specifications = jsonb_build_object(
    'compatibility', jsonb_build_object(
        'min_panels', 10,
        'max_panels', 31,
        'mppt_inputs', 2
    )
)
WHERE persist_name = 'sp-inverter-004';

-- Update Huawei SUN2000-6KTL-L1 (6kW inverter)
UPDATE public.main_components
SET specifications = jsonb_build_object(
    'compatibility', jsonb_build_object(
        'min_panels', 6,
        'max_panels', 20,
        'mppt_inputs', 2
    )
)
WHERE persist_name = 'sp-inverter-005';

-- ============================================================================
-- END OF MIGRATION
-- ============================================================================
