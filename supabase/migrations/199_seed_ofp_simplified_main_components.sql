-- Migration: Add simplified MainComponents for OFP integration
-- Description: Creates m²-based MainComponents for OFP calculations
-- Date: 2025-11-19

-- ============================================================================
-- 1. CREATE NEW CATEGORY FOR OFP SYSTEMS
-- ============================================================================

INSERT INTO public.main_component_categories (persist_name, name_translations)
VALUES
    ('facade_system', '{"en": "Facade System", "hu": "Homlokzati rendszer"}'),
    ('roof_system', '{"en": "Roof System", "hu": "Tetőszigetelő rendszer"}')
ON CONFLICT (persist_name) DO NOTHING;

-- ============================================================================
-- 2. LINK NEW CATEGORIES TO INVESTMENTS
-- ============================================================================

-- Facade System -> Facade Insulation
INSERT INTO public.main_component_category_investments (main_component_category_id, investment_id, sequence)
SELECT
    (SELECT id FROM public.main_component_categories WHERE persist_name = 'facade_system'),
    (SELECT id FROM public.investments WHERE name = 'Facade Insulation'),
    0  -- First position (before detailed components)
ON CONFLICT (main_component_category_id, investment_id) DO NOTHING;

-- Roof System -> Attic Insulation
INSERT INTO public.main_component_category_investments (main_component_category_id, investment_id, sequence)
SELECT
    (SELECT id FROM public.main_component_categories WHERE persist_name = 'roof_system'),
    (SELECT id FROM public.investments WHERE name = 'Attic Insulation'),
    0  -- First position
ON CONFLICT (main_component_category_id, investment_id) DO NOTHING;

-- ============================================================================
-- 3. CREATE SIMPLIFIED MAINCOMPONENTS - FACADE INSULATION
-- ============================================================================

INSERT INTO public.main_components (
    name,
    persist_name,
    unit,
    price,
    main_component_category_id,
    manufacturer,
    details,
    thickness,
    sequence
) VALUES
    (
        'Homlokzati szigetelés rendszer',
        'default-facade-insulation',
        'm2',
        0,
        (SELECT id FROM public.main_component_categories WHERE persist_name = 'facade_system'),
        'Mapei',
        'Komplett homlokzati szigetelő rendszer szigeteléssel, ragasztóval és vakolattal',
        0,
        1
    )
ON CONFLICT (persist_name) DO NOTHING;

-- ============================================================================
-- 4. CREATE SIMPLIFIED MAINCOMPONENTS - ROOF INSULATION
-- ============================================================================

INSERT INTO public.main_components (
    name,
    persist_name,
    unit,
    price,
    main_component_category_id,
    manufacturer,
    details,
    thickness,
    sequence
) VALUES
    (
        'Födémszigetelés rendszer',
        'default-roof-insulation',
        'm2',
        0,
        (SELECT id FROM public.main_component_categories WHERE persist_name = 'roof_system'),
        NULL,
        'Komplett fődémszigetelés',
        0,
        1
    )
ON CONFLICT (persist_name) DO NOTHING;

-- ============================================================================
-- 5. CREATE SIMPLIFIED MAINCOMPONENTS - WINDOWS
-- ============================================================================

INSERT INTO public.main_components (
    name,
    persist_name,
    unit,
    price,
    main_component_category_id,
    manufacturer,
    details,
    u_value,
    sequence
) VALUES
    (
        'Összes nyílászáró felület',
        'window-surface-area',
        'm2',
        0,
        (SELECT id FROM public.main_component_categories WHERE persist_name = 'window'),
        NULL,
        '',
        0,
        1
    )
ON CONFLICT (persist_name) DO NOTHING;

-- ============================================================================
-- 6. CREATE SIMPLIFIED MAINCOMPONENTS - HEAT PUMP
-- ============================================================================

INSERT INTO public.main_components (
    name,
    persist_name,
    unit,
    price,
    main_component_category_id,
    manufacturer,
    details,
    power,
    cop,
    sequence
) VALUES
    (
        'R290 2x10 kW',
        'heatpump-air-water-10kw',
        'db',
        0,
        (SELECT id FROM public.main_component_categories WHERE persist_name = 'heatpump'),
        'R290',
        '2x10 kW split levegő-víz hőszivattyú R290 hűtőközeggel',
        20000,
        0,
        1
    ),
    (
        'R290 12 kW',
        'heatpump-air-water-12kw',
        'db',
        0,
        (SELECT id FROM public.main_component_categories WHERE persist_name = 'heatpump'),
        'R290',
        '12 kW monoblokk levegő-víz hőszivattyú R290 hűtőközeggel',
        12000,
        0,
        2
    ),
    (
        'R290 16 kW',
        'heatpump-air-water-16kw',
        'db',
        0,
        (SELECT id FROM public.main_component_categories WHERE persist_name = 'heatpump'),
        'R290',
        '16 kW monoblokk levegő-víz hőszivattyú R290 hűtőközeggel',
        16000,
        0,
        3
    )
ON CONFLICT (persist_name) DO NOTHING;

-- ============================================================================
-- END OF MIGRATION
-- ============================================================================
