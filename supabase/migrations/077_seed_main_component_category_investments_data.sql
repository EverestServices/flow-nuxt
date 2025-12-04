-- Migration: Seed main_component_category_investments data
-- Description: Links main component categories to investments (copied from production)
-- Dependencies: 073_seed_investments_data.sql, 067_seed_main_component_categories_data.sql
-- Source: Remote production database (green-flow)

-- ============================================================================
-- MAIN COMPONENT CATEGORY INVESTMENTS
-- This table links investments with their main component categories
-- Data extracted from production on 2025-11-25
-- Total: 31 links
-- ============================================================================

-- Helper function to insert with explicit sequence ordering
CREATE OR REPLACE FUNCTION insert_category_investments(
    p_investment_name TEXT,
    p_categories_with_seq JSONB
) RETURNS void AS $$
DECLARE
    v_investment_id UUID;
    v_category_id UUID;
    v_item JSONB;
    v_persist_name TEXT;
    v_sequence INT;
BEGIN
    -- Get investment ID
    SELECT id INTO v_investment_id FROM public.investments WHERE name = p_investment_name;

    IF v_investment_id IS NULL THEN
        RAISE NOTICE 'Investment "%" not found, skipping', p_investment_name;
        RETURN;
    END IF;

    -- Insert each category with its sequence
    FOR v_item IN SELECT * FROM jsonb_array_elements(p_categories_with_seq)
    LOOP
        v_persist_name := v_item->>'persist_name';
        v_sequence := (v_item->>'sequence')::INT;

        SELECT id INTO v_category_id FROM public.main_component_categories WHERE persist_name = v_persist_name;

        IF v_category_id IS NOT NULL THEN
            INSERT INTO public.main_component_category_investments (
                main_component_category_id,
                investment_id,
                sequence
            )
            VALUES (v_category_id, v_investment_id, v_sequence)
            ON CONFLICT (main_component_category_id, investment_id) DO NOTHING;
        ELSE
            RAISE NOTICE 'Main component category "%" not found for investment "%"', v_persist_name, p_investment_name;
        END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Air Conditioner (1 category)
SELECT insert_category_investments('Air Conditioner', '[
    {"persist_name": "airconditioner", "sequence": 1}
]'::jsonb);

-- Attic Insulation (3 categories)
SELECT insert_category_investments('Attic Insulation', '[
    {"persist_name": "roof_system", "sequence": 0},
    {"persist_name": "insulation", "sequence": 1},
    {"persist_name": "vapor_barrier", "sequence": 2}
]'::jsonb);

-- Battery (2 categories)
SELECT insert_category_investments('Battery', '[
    {"persist_name": "battery", "sequence": 1},
    {"persist_name": "inverter", "sequence": 2}
]'::jsonb);

-- Car Charger (1 category)
SELECT insert_category_investments('Car Charger', '[
    {"persist_name": "charger", "sequence": 1}
]'::jsonb);

-- Facade Insulation (4 categories)
SELECT insert_category_investments('Facade Insulation', '[
    {"persist_name": "facade_system", "sequence": 0},
    {"persist_name": "insulation", "sequence": 1},
    {"persist_name": "adhesive", "sequence": 2},
    {"persist_name": "plaster", "sequence": 3}
]'::jsonb);

-- Heat Pump (2 categories)
SELECT insert_category_investments('Heat Pump', '[
    {"persist_name": "heatpump", "sequence": 1},
    {"persist_name": "accessory", "sequence": 2}
]'::jsonb);

-- Solar Panel (8 categories)
SELECT insert_category_investments('Solar Panel', '[
    {"persist_name": "panel", "sequence": 1},
    {"persist_name": "inverter", "sequence": 2},
    {"persist_name": "mounting", "sequence": 3},
    {"persist_name": "regulator", "sequence": 4},
    {"persist_name": "ac_surge_protector", "sequence": 5},
    {"persist_name": "dc_surge_protector", "sequence": 6},
    {"persist_name": "optimizer", "sequence": 7},
    {"persist_name": "rapid_shutdown", "sequence": 8}
]'::jsonb);

-- Solar Panel + Battery (9 categories)
SELECT insert_category_investments('Solar Panel + Battery', '[
    {"persist_name": "panel", "sequence": 1},
    {"persist_name": "inverter", "sequence": 2},
    {"persist_name": "battery", "sequence": 3},
    {"persist_name": "mounting", "sequence": 4},
    {"persist_name": "regulator", "sequence": 5},
    {"persist_name": "ac_surge_protector", "sequence": 6},
    {"persist_name": "dc_surge_protector", "sequence": 7},
    {"persist_name": "optimizer", "sequence": 8},
    {"persist_name": "rapid_shutdown", "sequence": 9}
]'::jsonb);

-- Windows (1 category)
SELECT insert_category_investments('Windows', '[
    {"persist_name": "window", "sequence": 1}
]'::jsonb);

-- Drop the helper function
DROP FUNCTION insert_category_investments(TEXT, JSONB);
