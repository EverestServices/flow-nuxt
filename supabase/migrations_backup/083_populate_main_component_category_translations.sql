-- ============================================================================
-- Migration: Populate main_component_category translations
-- Description: Populates name_translations for all existing categories
-- ============================================================================

-- Update name_translations for each category
UPDATE public.main_component_categories
SET name_translations = jsonb_build_object('hu', 'Napelem panelek', 'en', 'Solar Panels')
WHERE persist_name = 'panel';

UPDATE public.main_component_categories
SET name_translations = jsonb_build_object('hu', 'Inverter', 'en', 'Inverter')
WHERE persist_name = 'inverter';

UPDATE public.main_component_categories
SET name_translations = jsonb_build_object('hu', 'Tartószerkezet', 'en', 'Mounting System')
WHERE persist_name = 'mounting';

UPDATE public.main_component_categories
SET name_translations = jsonb_build_object('hu', 'Töltésszabályozó', 'en', 'Charge Regulator')
WHERE persist_name = 'regulator';

UPDATE public.main_component_categories
SET name_translations = jsonb_build_object('hu', 'AC túlfeszültségvédő', 'en', 'AC Surge Protector')
WHERE persist_name = 'ac_surge_protector';

UPDATE public.main_component_categories
SET name_translations = jsonb_build_object('hu', 'DC túlfeszültségvédő', 'en', 'DC Surge Protector')
WHERE persist_name = 'dc_surge_protector';

UPDATE public.main_component_categories
SET name_translations = jsonb_build_object('hu', 'Teljesítményoptimalizáló', 'en', 'Power Optimizer')
WHERE persist_name = 'optimizer';

UPDATE public.main_component_categories
SET name_translations = jsonb_build_object('hu', 'Gyorsleállító', 'en', 'Rapid Shutdown')
WHERE persist_name = 'rapid_shutdown';

UPDATE public.main_component_categories
SET name_translations = jsonb_build_object('hu', 'Akkumulátor', 'en', 'Battery')
WHERE persist_name = 'battery';

UPDATE public.main_component_categories
SET name_translations = jsonb_build_object('hu', 'Hőszivattyú', 'en', 'Heat Pump')
WHERE persist_name = 'heatpump';

UPDATE public.main_component_categories
SET name_translations = jsonb_build_object('hu', 'Kiegészítők', 'en', 'Accessories')
WHERE persist_name = 'accessory';

UPDATE public.main_component_categories
SET name_translations = jsonb_build_object('hu', 'Szigetelés', 'en', 'Insulation')
WHERE persist_name = 'insulation';

UPDATE public.main_component_categories
SET name_translations = jsonb_build_object('hu', 'Ragasztó', 'en', 'Adhesive')
WHERE persist_name = 'adhesive';

UPDATE public.main_component_categories
SET name_translations = jsonb_build_object('hu', 'Vakolat', 'en', 'Plaster')
WHERE persist_name = 'plaster';

UPDATE public.main_component_categories
SET name_translations = jsonb_build_object('hu', 'Párazáró', 'en', 'Vapor Barrier')
WHERE persist_name = 'vapor_barrier';

UPDATE public.main_component_categories
SET name_translations = jsonb_build_object('hu', 'Ablak', 'en', 'Windows')
WHERE persist_name = 'window';

UPDATE public.main_component_categories
SET name_translations = jsonb_build_object('hu', 'Légkondicionáló', 'en', 'Air Conditioner')
WHERE persist_name = 'airconditioner';

UPDATE public.main_component_categories
SET name_translations = jsonb_build_object('hu', 'Töltőállomás', 'en', 'EV Charger')
WHERE persist_name = 'charger';

-- ============================================================================
-- END OF MIGRATION
-- ============================================================================
