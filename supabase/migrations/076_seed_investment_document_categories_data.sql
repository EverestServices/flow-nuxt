-- Migration: Seed investment_document_categories data
-- Description: Links document categories to investments (copied from production)
-- Dependencies: 073_seed_investments_data.sql, 068_seed_document_categories_data.sql
-- Source: Remote production database (green-flow)

-- ============================================================================
-- INVESTMENT DOCUMENT CATEGORIES
-- This table links investments with their required document categories
-- Data extracted from production on 2025-11-25
-- ============================================================================

-- Helper function to insert with explicit position ordering
CREATE OR REPLACE FUNCTION insert_investment_docs(
    p_investment_name TEXT,
    p_persist_names TEXT[]
) RETURNS void AS $$
DECLARE
    v_investment_id UUID;
    v_doc_id UUID;
    v_position INT := 1;
    v_persist_name TEXT;
BEGIN
    -- Get investment ID
    SELECT id INTO v_investment_id FROM public.investments WHERE name = p_investment_name;

    IF v_investment_id IS NULL THEN
        RAISE NOTICE 'Investment "%" not found, skipping', p_investment_name;
        RETURN;
    END IF;

    -- Insert each document category with explicit position
    FOREACH v_persist_name IN ARRAY p_persist_names
    LOOP
        SELECT id INTO v_doc_id FROM public.document_categories WHERE persist_name = v_persist_name;

        IF v_doc_id IS NOT NULL THEN
            INSERT INTO public.investment_document_categories (investment_id, document_category_id, position)
            VALUES (v_investment_id, v_doc_id, v_position)
            ON CONFLICT DO NOTHING;

            v_position := v_position + 1;
        ELSE
            RAISE NOTICE 'Document category "%" not found for investment "%"', v_persist_name, p_investment_name;
        END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Air Conditioner (4 categories)
SELECT insert_investment_docs('Air Conditioner', ARRAY[
    'ac-indoor-unit',
    'ac-outdoor-unit',
    'ac-piping-route',
    'electrical-meter'
]);

-- Attic Insulation (3 categories)
SELECT insert_investment_docs('Attic Insulation', ARRAY[
    'attic-condition',
    'roof-condition',
    'roof-structure'
]);

-- Battery (4 categories)
SELECT insert_investment_docs('Battery', ARRAY[
    'battery-placement',
    'electrical-meter',
    'electrical-system',
    'meter-box-interior'
]);

-- Car Charger (3 categories)
SELECT insert_investment_docs('Car Charger', ARRAY[
    'car-charger-placement',
    'electrical-meter',
    'parking-area'
]);

-- Facade Insulation (2 categories)
SELECT insert_investment_docs('Facade Insulation', ARRAY[
    'wall-condition',
    'wall-insulation-area'
]);

-- Heat Pump (12 categories)
SELECT insert_investment_docs('Heat Pump', ARRAY[
    'propertyExterior',
    'typicalWindows',
    'outdoor-unit',
    'heatingCenterLocation',
    'existingHeatingDeviceAndDataPlate',
    'existingHeatingDeviceWaterConnections',
    'manifold',
    'meterLocation',
    'connection-point',
    'existingHeatEmitters',
    'plannedPipingOutdoorToBuffer',
    'plannedPipingBufferToConnections'
]);

-- Solar Panel (5 categories)
SELECT insert_investment_docs('Solar Panel', ARRAY[
    'electrical-meter',
    'roof-structure',
    'roof-condition',
    'inverter-room',
    'roof-access'
]);

-- Solar Panel + Battery (4 categories)
SELECT insert_investment_docs('Solar Panel + Battery', ARRAY[
    'connection-point',
    'electricity-meter-number',
    'meter-location-photos',
    'site-survey-photos'
]);

-- Windows (2 categories)
SELECT insert_investment_docs('Windows', ARRAY[
    'window-condition',
    'window-frame'
]);

-- Drop the helper function
DROP FUNCTION insert_investment_docs(TEXT, TEXT[]);
