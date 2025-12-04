-- ============================================================================
-- Migration: Update sequences in main components seed data
-- Description: Sets sequence values for main_component_categories and main_components
-- ============================================================================

-- ============================================================================
-- 1. UPDATE MAIN_COMPONENT_CATEGORIES SEQUENCES
-- ============================================================================

UPDATE public.main_component_categories SET sequence = 1 WHERE persist_name = 'panel';
UPDATE public.main_component_categories SET sequence = 2 WHERE persist_name = 'inverter';
UPDATE public.main_component_categories SET sequence = 3 WHERE persist_name = 'battery';
UPDATE public.main_component_categories SET sequence = 4 WHERE persist_name = 'mounting';
UPDATE public.main_component_categories SET sequence = 5 WHERE persist_name = 'regulator';
UPDATE public.main_component_categories SET sequence = 6 WHERE persist_name = 'ac_surge_protector';
UPDATE public.main_component_categories SET sequence = 7 WHERE persist_name = 'dc_surge_protector';
UPDATE public.main_component_categories SET sequence = 8 WHERE persist_name = 'optimizer';
UPDATE public.main_component_categories SET sequence = 9 WHERE persist_name = 'rapid_shutdown';
UPDATE public.main_component_categories SET sequence = 10 WHERE persist_name = 'heatpump';
UPDATE public.main_component_categories SET sequence = 11 WHERE persist_name = 'accessory';
UPDATE public.main_component_categories SET sequence = 12 WHERE persist_name = 'insulation';
UPDATE public.main_component_categories SET sequence = 13 WHERE persist_name = 'adhesive';
UPDATE public.main_component_categories SET sequence = 14 WHERE persist_name = 'plaster';
UPDATE public.main_component_categories SET sequence = 15 WHERE persist_name = 'vapor_barrier';
UPDATE public.main_component_categories SET sequence = 16 WHERE persist_name = 'window';
UPDATE public.main_component_categories SET sequence = 17 WHERE persist_name = 'airconditioner';
UPDATE public.main_component_categories SET sequence = 18 WHERE persist_name = 'charger';

-- ============================================================================
-- 2. UPDATE MAIN_COMPONENTS SEQUENCES
-- ============================================================================

-- Solar Panels (by power descending for premium first ordering)
UPDATE public.main_components SET sequence = 1 WHERE persist_name = 'sp-panel-004'; -- 540W
UPDATE public.main_components SET sequence = 2 WHERE persist_name = 'sp-panel-005'; -- 450W
UPDATE public.main_components SET sequence = 3 WHERE persist_name = 'sp-panel-003'; -- 430W
UPDATE public.main_components SET sequence = 4 WHERE persist_name = 'sp-panel-001'; -- 425W
UPDATE public.main_components SET sequence = 5 WHERE persist_name = 'sp-panel-002'; -- 410W

-- Inverters (by power descending)
UPDATE public.main_components SET sequence = 1 WHERE persist_name = 'sp-inverter-003'; -- 10kW
UPDATE public.main_components SET sequence = 2 WHERE persist_name = 'sp-inverter-004'; -- 10kW
UPDATE public.main_components SET sequence = 3 WHERE persist_name = 'sp-inverter-002'; -- 8kW
UPDATE public.main_components SET sequence = 4 WHERE persist_name = 'sp-inverter-001'; -- 6kW
UPDATE public.main_components SET sequence = 5 WHERE persist_name = 'sp-inverter-005'; -- 6kW

-- Mounting Systems
UPDATE public.main_components SET sequence = 1 WHERE persist_name = 'sp-mounting-003'; -- FlatRoof
UPDATE public.main_components SET sequence = 2 WHERE persist_name = 'sp-mounting-002'; -- CrossRail
UPDATE public.main_components SET sequence = 3 WHERE persist_name = 'sp-mounting-001'; -- SingleRail

-- Regulators
UPDATE public.main_components SET sequence = 1 WHERE persist_name = 'sp-regulator-001';

-- AC Surge Protectors
UPDATE public.main_components SET sequence = 1 WHERE persist_name = 'sp-ac-surge-001'; -- Type 1+2
UPDATE public.main_components SET sequence = 2 WHERE persist_name = 'sp-ac-surge-002'; -- Type 2

-- DC Surge Protectors
UPDATE public.main_components SET sequence = 1 WHERE persist_name = 'sp-dc-surge-002'; -- Type 1+2
UPDATE public.main_components SET sequence = 2 WHERE persist_name = 'sp-dc-surge-001'; -- Type 2

-- Optimizers
UPDATE public.main_components SET sequence = 1 WHERE persist_name = 'sp-optimizer-002'; -- TS4-A-2F
UPDATE public.main_components SET sequence = 2 WHERE persist_name = 'sp-optimizer-001'; -- TS4-A-O

-- Rapid Shutdown
UPDATE public.main_components SET sequence = 1 WHERE persist_name = 'sp-rapid-001';

-- Batteries (by capacity descending)
UPDATE public.main_components SET sequence = 1 WHERE persist_name = 'battery-001'; -- 10.2kWh
UPDATE public.main_components SET sequence = 2 WHERE persist_name = 'battery-003'; -- 10kWh
UPDATE public.main_components SET sequence = 3 WHERE persist_name = 'battery-002'; -- 9.6kWh
UPDATE public.main_components SET sequence = 4 WHERE persist_name = 'battery-004'; -- 7.7kWh
UPDATE public.main_components SET sequence = 5 WHERE persist_name = 'battery-005'; -- 6.5kWh

-- Heat Pumps (by power descending)
UPDATE public.main_components SET sequence = 1 WHERE persist_name = 'hp-unit-004'; -- 16kW
UPDATE public.main_components SET sequence = 2 WHERE persist_name = 'hp-unit-001'; -- 14kW
UPDATE public.main_components SET sequence = 3 WHERE persist_name = 'hp-unit-002'; -- 11.2kW
UPDATE public.main_components SET sequence = 4 WHERE persist_name = 'hp-unit-003'; -- 8.5kW
UPDATE public.main_components SET sequence = 5 WHERE persist_name = 'hp-unit-005'; -- 5kW

-- Heat Pump Accessories
UPDATE public.main_components SET sequence = 1 WHERE persist_name = 'hp-acc-002'; -- 500L
UPDATE public.main_components SET sequence = 2 WHERE persist_name = 'hp-acc-001'; -- 200L

-- Facade Insulation (by thickness descending)
UPDATE public.main_components SET sequence = 1 WHERE persist_name = 'fi-insul-003'; -- 20cm
UPDATE public.main_components SET sequence = 2 WHERE persist_name = 'fi-insul-002'; -- 16cm
UPDATE public.main_components SET sequence = 3 WHERE persist_name = 'fi-insul-001'; -- 15cm
UPDATE public.main_components SET sequence = 4 WHERE persist_name = 'fi-insul-004'; -- 12cm

-- Adhesive
UPDATE public.main_components SET sequence = 1 WHERE persist_name = 'fi-adhesive-002'; -- openContact
UPDATE public.main_components SET sequence = 2 WHERE persist_name = 'fi-adhesive-001'; -- ProContact

-- Plaster
UPDATE public.main_components SET sequence = 1 WHERE persist_name = 'fi-plaster-002'; -- NanoporTop
UPDATE public.main_components SET sequence = 2 WHERE persist_name = 'fi-plaster-001'; -- SilikonTop

-- Roof Insulation (by thickness descending)
UPDATE public.main_components SET sequence = 1 WHERE persist_name = 'ri-insul-002'; -- 20cm
UPDATE public.main_components SET sequence = 2 WHERE persist_name = 'ri-insul-001'; -- 18cm
UPDATE public.main_components SET sequence = 3 WHERE persist_name = 'ri-insul-003'; -- 15cm

-- Vapor Barrier
UPDATE public.main_components SET sequence = 1 WHERE persist_name = 'ri-vapor-002'; -- Diffunorm
UPDATE public.main_components SET sequence = 2 WHERE persist_name = 'ri-vapor-001'; -- Vapor Control

-- Windows (by U-value ascending - lower is better)
UPDATE public.main_components SET sequence = 1 WHERE persist_name = 'window-001'; -- 0.72
UPDATE public.main_components SET sequence = 2 WHERE persist_name = 'window-003'; -- 0.74
UPDATE public.main_components SET sequence = 3 WHERE persist_name = 'window-002'; -- 0.78
UPDATE public.main_components SET sequence = 4 WHERE persist_name = 'window-004'; -- 0.94

-- Air Conditioners (by energy class and power)
UPDATE public.main_components SET sequence = 1 WHERE persist_name = 'ac-004'; -- A+++, 2.5kW
UPDATE public.main_components SET sequence = 2 WHERE persist_name = 'ac-002'; -- A++, 3.5kW
UPDATE public.main_components SET sequence = 3 WHERE persist_name = 'ac-003'; -- A++, 5.2kW
UPDATE public.main_components SET sequence = 4 WHERE persist_name = 'ac-001'; -- A++, 2.5kW

-- Car Chargers (by power descending)
UPDATE public.main_components SET sequence = 1 WHERE persist_name = 'cc-003'; -- 22kW
UPDATE public.main_components SET sequence = 2 WHERE persist_name = 'cc-004'; -- 22kW
UPDATE public.main_components SET sequence = 3 WHERE persist_name = 'cc-002'; -- 11kW
UPDATE public.main_components SET sequence = 4 WHERE persist_name = 'cc-001'; -- 7.4kW

-- ============================================================================
-- END OF MIGRATION
-- ============================================================================
