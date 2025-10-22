-- ============================================================================
-- Migration: Seed Main Component Category - Investment Relationships
-- Description: Defines which component categories belong to which investments
-- ============================================================================

-- ============================================================================
-- SOLAR PANEL INVESTMENT
-- ============================================================================

INSERT INTO public.main_component_category_investments (main_component_category_id, investment_id, sequence) VALUES
    ((SELECT id FROM public.main_component_categories WHERE persist_name = 'panel'),
     (SELECT id FROM public.investments WHERE name = 'Solar Panel'), 1),
    ((SELECT id FROM public.main_component_categories WHERE persist_name = 'inverter'),
     (SELECT id FROM public.investments WHERE name = 'Solar Panel'), 2),
    ((SELECT id FROM public.main_component_categories WHERE persist_name = 'mounting'),
     (SELECT id FROM public.investments WHERE name = 'Solar Panel'), 3),
    ((SELECT id FROM public.main_component_categories WHERE persist_name = 'regulator'),
     (SELECT id FROM public.investments WHERE name = 'Solar Panel'), 4),
    ((SELECT id FROM public.main_component_categories WHERE persist_name = 'ac_surge_protector'),
     (SELECT id FROM public.investments WHERE name = 'Solar Panel'), 5),
    ((SELECT id FROM public.main_component_categories WHERE persist_name = 'dc_surge_protector'),
     (SELECT id FROM public.investments WHERE name = 'Solar Panel'), 6),
    ((SELECT id FROM public.main_component_categories WHERE persist_name = 'optimizer'),
     (SELECT id FROM public.investments WHERE name = 'Solar Panel'), 7),
    ((SELECT id FROM public.main_component_categories WHERE persist_name = 'rapid_shutdown'),
     (SELECT id FROM public.investments WHERE name = 'Solar Panel'), 8)
ON CONFLICT (main_component_category_id, investment_id) DO NOTHING;

-- ============================================================================
-- SOLAR PANEL + BATTERY INVESTMENT
-- ============================================================================

INSERT INTO public.main_component_category_investments (main_component_category_id, investment_id, sequence) VALUES
    ((SELECT id FROM public.main_component_categories WHERE persist_name = 'panel'),
     (SELECT id FROM public.investments WHERE name = 'Solar Panel + Battery'), 1),
    ((SELECT id FROM public.main_component_categories WHERE persist_name = 'inverter'),
     (SELECT id FROM public.investments WHERE name = 'Solar Panel + Battery'), 2),
    ((SELECT id FROM public.main_component_categories WHERE persist_name = 'battery'),
     (SELECT id FROM public.investments WHERE name = 'Solar Panel + Battery'), 3),
    ((SELECT id FROM public.main_component_categories WHERE persist_name = 'mounting'),
     (SELECT id FROM public.investments WHERE name = 'Solar Panel + Battery'), 4),
    ((SELECT id FROM public.main_component_categories WHERE persist_name = 'regulator'),
     (SELECT id FROM public.investments WHERE name = 'Solar Panel + Battery'), 5),
    ((SELECT id FROM public.main_component_categories WHERE persist_name = 'ac_surge_protector'),
     (SELECT id FROM public.investments WHERE name = 'Solar Panel + Battery'), 6),
    ((SELECT id FROM public.main_component_categories WHERE persist_name = 'dc_surge_protector'),
     (SELECT id FROM public.investments WHERE name = 'Solar Panel + Battery'), 7),
    ((SELECT id FROM public.main_component_categories WHERE persist_name = 'optimizer'),
     (SELECT id FROM public.investments WHERE name = 'Solar Panel + Battery'), 8),
    ((SELECT id FROM public.main_component_categories WHERE persist_name = 'rapid_shutdown'),
     (SELECT id FROM public.investments WHERE name = 'Solar Panel + Battery'), 9)
ON CONFLICT (main_component_category_id, investment_id) DO NOTHING;

-- ============================================================================
-- BATTERY INVESTMENT
-- ============================================================================

INSERT INTO public.main_component_category_investments (main_component_category_id, investment_id, sequence) VALUES
    ((SELECT id FROM public.main_component_categories WHERE persist_name = 'battery'),
     (SELECT id FROM public.investments WHERE name = 'Battery'), 1),
    ((SELECT id FROM public.main_component_categories WHERE persist_name = 'inverter'),
     (SELECT id FROM public.investments WHERE name = 'Battery'), 2)
ON CONFLICT (main_component_category_id, investment_id) DO NOTHING;

-- ============================================================================
-- HEAT PUMP INVESTMENT
-- ============================================================================

INSERT INTO public.main_component_category_investments (main_component_category_id, investment_id, sequence) VALUES
    ((SELECT id FROM public.main_component_categories WHERE persist_name = 'heatpump'),
     (SELECT id FROM public.investments WHERE name = 'Heat Pump'), 1),
    ((SELECT id FROM public.main_component_categories WHERE persist_name = 'accessory'),
     (SELECT id FROM public.investments WHERE name = 'Heat Pump'), 2)
ON CONFLICT (main_component_category_id, investment_id) DO NOTHING;

-- ============================================================================
-- FACADE INSULATION INVESTMENT
-- ============================================================================

INSERT INTO public.main_component_category_investments (main_component_category_id, investment_id, sequence) VALUES
    ((SELECT id FROM public.main_component_categories WHERE persist_name = 'insulation'),
     (SELECT id FROM public.investments WHERE name = 'Facade Insulation'), 1),
    ((SELECT id FROM public.main_component_categories WHERE persist_name = 'adhesive'),
     (SELECT id FROM public.investments WHERE name = 'Facade Insulation'), 2),
    ((SELECT id FROM public.main_component_categories WHERE persist_name = 'plaster'),
     (SELECT id FROM public.investments WHERE name = 'Facade Insulation'), 3)
ON CONFLICT (main_component_category_id, investment_id) DO NOTHING;

-- ============================================================================
-- ROOF INSULATION INVESTMENT
-- ============================================================================

INSERT INTO public.main_component_category_investments (main_component_category_id, investment_id, sequence) VALUES
    ((SELECT id FROM public.main_component_categories WHERE persist_name = 'insulation'),
     (SELECT id FROM public.investments WHERE name = 'Roof Insulation'), 1),
    ((SELECT id FROM public.main_component_categories WHERE persist_name = 'vapor_barrier'),
     (SELECT id FROM public.investments WHERE name = 'Roof Insulation'), 2)
ON CONFLICT (main_component_category_id, investment_id) DO NOTHING;

-- ============================================================================
-- WINDOWS INVESTMENT
-- ============================================================================

INSERT INTO public.main_component_category_investments (main_component_category_id, investment_id, sequence) VALUES
    ((SELECT id FROM public.main_component_categories WHERE persist_name = 'window'),
     (SELECT id FROM public.investments WHERE name = 'Windows'), 1)
ON CONFLICT (main_component_category_id, investment_id) DO NOTHING;

-- ============================================================================
-- AIR CONDITIONER INVESTMENT
-- ============================================================================

INSERT INTO public.main_component_category_investments (main_component_category_id, investment_id, sequence) VALUES
    ((SELECT id FROM public.main_component_categories WHERE persist_name = 'airconditioner'),
     (SELECT id FROM public.investments WHERE name = 'Air Conditioner'), 1)
ON CONFLICT (main_component_category_id, investment_id) DO NOTHING;

-- ============================================================================
-- CAR CHARGER INVESTMENT
-- ============================================================================

INSERT INTO public.main_component_category_investments (main_component_category_id, investment_id, sequence) VALUES
    ((SELECT id FROM public.main_component_categories WHERE persist_name = 'charger'),
     (SELECT id FROM public.investments WHERE name = 'Car Charger'), 1)
ON CONFLICT (main_component_category_id, investment_id) DO NOTHING;

-- ============================================================================
-- END OF SEED DATA
-- ============================================================================
