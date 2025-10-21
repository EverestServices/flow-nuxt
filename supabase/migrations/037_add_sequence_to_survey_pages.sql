-- ============================================================================
-- Migration: Add sequence values to survey_pages
-- Description: Sets sequence values for survey pages based on FlowFrontend fixtures
-- ============================================================================

-- ============================================================================
-- Solar Panel
-- ============================================================================
UPDATE public.survey_pages
SET sequence = 1
WHERE type = 'general' AND investment_id = (SELECT id FROM public.investments WHERE name = 'Solar Panel');

UPDATE public.survey_pages
SET sequence = 2
WHERE type = 'solar_panel' AND investment_id = (SELECT id FROM public.investments WHERE name = 'Solar Panel');

UPDATE public.survey_pages
SET sequence = 3
WHERE type = 'inverter' AND investment_id = (SELECT id FROM public.investments WHERE name = 'Solar Panel');

UPDATE public.survey_pages
SET sequence = 4
WHERE type = 'roof' AND investment_id = (SELECT id FROM public.investments WHERE name = 'Solar Panel');

-- ============================================================================
-- Solar Panel + Battery
-- ============================================================================
UPDATE public.survey_pages
SET sequence = 1
WHERE type = 'general' AND investment_id = (SELECT id FROM public.investments WHERE name = 'Solar Panel + Battery');

UPDATE public.survey_pages
SET sequence = 2
WHERE type = 'solar_panel' AND investment_id = (SELECT id FROM public.investments WHERE name = 'Solar Panel + Battery');

UPDATE public.survey_pages
SET sequence = 3
WHERE type = 'inverter' AND investment_id = (SELECT id FROM public.investments WHERE name = 'Solar Panel + Battery');

UPDATE public.survey_pages
SET sequence = 4
WHERE type = 'battery' AND investment_id = (SELECT id FROM public.investments WHERE name = 'Solar Panel + Battery');

UPDATE public.survey_pages
SET sequence = 5
WHERE type = 'roof' AND investment_id = (SELECT id FROM public.investments WHERE name = 'Solar Panel + Battery');

-- ============================================================================
-- Heat Pump
-- ============================================================================
UPDATE public.survey_pages
SET sequence = 1
WHERE type = 'general' AND investment_id = (SELECT id FROM public.investments WHERE name = 'Heat Pump');

UPDATE public.survey_pages
SET sequence = 2
WHERE type = 'rooms' AND investment_id = (SELECT id FROM public.investments WHERE name = 'Heat Pump');

UPDATE public.survey_pages
SET sequence = 3
WHERE type = 'windows' AND investment_id = (SELECT id FROM public.investments WHERE name = 'Heat Pump');

UPDATE public.survey_pages
SET sequence = 4
WHERE type = 'heating_basics' AND investment_id = (SELECT id FROM public.investments WHERE name = 'Heat Pump');

UPDATE public.survey_pages
SET sequence = 5
WHERE type = 'radiators' AND investment_id = (SELECT id FROM public.investments WHERE name = 'Heat Pump');

UPDATE public.survey_pages
SET sequence = 6
WHERE type = 'desired_construction' AND investment_id = (SELECT id FROM public.investments WHERE name = 'Heat Pump');

UPDATE public.survey_pages
SET sequence = 7
WHERE type = 'other_data' AND investment_id = (SELECT id FROM public.investments WHERE name = 'Heat Pump');

-- ============================================================================
-- Facade Insulation
-- ============================================================================
UPDATE public.survey_pages
SET sequence = 1
WHERE type = 'general' AND investment_id = (SELECT id FROM public.investments WHERE name = 'Facade Insulation');

UPDATE public.survey_pages
SET sequence = 2
WHERE type = 'walls' AND investment_id = (SELECT id FROM public.investments WHERE name = 'Facade Insulation');

UPDATE public.survey_pages
SET sequence = 3
WHERE type = 'roof' AND investment_id = (SELECT id FROM public.investments WHERE name = 'Facade Insulation');

-- ============================================================================
-- Battery
-- ============================================================================
UPDATE public.survey_pages
SET sequence = 1
WHERE type = 'battery' AND investment_id = (SELECT id FROM public.investments WHERE name = 'Battery');

-- ============================================================================
-- Car Charger
-- ============================================================================
UPDATE public.survey_pages
SET sequence = 1
WHERE type = 'ev_data' AND investment_id = (SELECT id FROM public.investments WHERE name = 'Car Charger');

UPDATE public.survey_pages
SET sequence = 2
WHERE type = 'location' AND investment_id = (SELECT id FROM public.investments WHERE name = 'Car Charger');

UPDATE public.survey_pages
SET sequence = 3
WHERE type = 'power_upgrade' AND investment_id = (SELECT id FROM public.investments WHERE name = 'Car Charger');

-- ============================================================================
-- Air Conditioner
-- ============================================================================
UPDATE public.survey_pages
SET sequence = 1
WHERE type = 'general' AND investment_id = (SELECT id FROM public.investments WHERE name = 'Air Conditioner');

UPDATE public.survey_pages
SET sequence = 2
WHERE type = 'solar_panel' AND investment_id = (SELECT id FROM public.investments WHERE name = 'Air Conditioner');

UPDATE public.survey_pages
SET sequence = 3
WHERE type = 'inverter' AND investment_id = (SELECT id FROM public.investments WHERE name = 'Air Conditioner');

UPDATE public.survey_pages
SET sequence = 4
WHERE type = 'roof' AND investment_id = (SELECT id FROM public.investments WHERE name = 'Air Conditioner');

-- ============================================================================
-- Roof Insulation
-- ============================================================================
UPDATE public.survey_pages
SET sequence = 1
WHERE type = 'general' AND investment_id = (SELECT id FROM public.investments WHERE name = 'Roof Insulation');

UPDATE public.survey_pages
SET sequence = 2
WHERE type = 'walls' AND investment_id = (SELECT id FROM public.investments WHERE name = 'Roof Insulation');

UPDATE public.survey_pages
SET sequence = 3
WHERE type = 'roof' AND investment_id = (SELECT id FROM public.investments WHERE name = 'Roof Insulation');

UPDATE public.survey_pages
SET sequence = 4
WHERE type = 'windows' AND investment_id = (SELECT id FROM public.investments WHERE name = 'Roof Insulation');

-- ============================================================================
-- Windows
-- ============================================================================
UPDATE public.survey_pages
SET sequence = 1
WHERE type = 'general' AND investment_id = (SELECT id FROM public.investments WHERE name = 'Windows');

UPDATE public.survey_pages
SET sequence = 2
WHERE type = 'walls' AND investment_id = (SELECT id FROM public.investments WHERE name = 'Windows');

UPDATE public.survey_pages
SET sequence = 3
WHERE type = 'roof' AND investment_id = (SELECT id FROM public.investments WHERE name = 'Windows');

UPDATE public.survey_pages
SET sequence = 4
WHERE type = 'windows' AND investment_id = (SELECT id FROM public.investments WHERE name = 'Windows');
