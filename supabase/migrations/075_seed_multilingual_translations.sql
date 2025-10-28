-- ============================================================================
-- Migration: Seed Multilingual Translations
-- Description: Populate multilingual columns with actual English translations
-- ============================================================================

-- ============================================================================
-- 1. UPDATE INVESTMENTS WITH TRANSLATIONS
-- ============================================================================

-- Update based on English names from 004 seed file
UPDATE public.investments SET name_translations = jsonb_build_object('hu', 'Napelem', 'en', 'Solar Panel') WHERE name = 'Solar Panel';
UPDATE public.investments SET name_translations = jsonb_build_object('hu', 'Napelem + Akkumulátor', 'en', 'Solar Panel + Battery') WHERE name = 'Solar Panel + Battery';
UPDATE public.investments SET name_translations = jsonb_build_object('hu', 'Hőszivattyú', 'en', 'Heat Pump') WHERE name = 'Heat Pump';
UPDATE public.investments SET name_translations = jsonb_build_object('hu', 'Homlokzati szigetelés', 'en', 'Facade Insulation') WHERE name = 'Facade Insulation';
UPDATE public.investments SET name_translations = jsonb_build_object('hu', 'Tető szigetelés', 'en', 'Roof Insulation') WHERE name = 'Roof Insulation';
UPDATE public.investments SET name_translations = jsonb_build_object('hu', 'Nyílászárók', 'en', 'Windows') WHERE name = 'Windows';
UPDATE public.investments SET name_translations = jsonb_build_object('hu', 'Klíma', 'en', 'Air Conditioner') WHERE name = 'Air Conditioner';
UPDATE public.investments SET name_translations = jsonb_build_object('hu', 'Akkumulátor', 'en', 'Battery') WHERE name = 'Battery';
UPDATE public.investments SET name_translations = jsonb_build_object('hu', 'Autótöltő', 'en', 'Car Charger') WHERE name = 'Car Charger';

-- ============================================================================
-- 2. UPDATE DOCUMENT CATEGORIES WITH ENGLISH TRANSLATIONS
-- ============================================================================

UPDATE public.document_categories
SET
  name_translations = jsonb_build_object(
    'hu', name,
    'en', CASE persist_name
      WHEN 'electrical_panel' THEN 'Electrical Panel'
      WHEN 'roof_structure' THEN 'Roof Structure'
      WHEN 'attic_space' THEN 'Attic Space'
      WHEN 'exterior_walls' THEN 'Exterior Walls'
      WHEN 'heating_system' THEN 'Heating System'
      WHEN 'water_heater' THEN 'Water Heater'
      WHEN 'windows_doors' THEN 'Windows & Doors'
      WHEN 'overall_property' THEN 'Overall Property'
      ELSE name
    END
  ),
  description_translations = jsonb_build_object(
    'hu', description,
    'en', CASE persist_name
      WHEN 'electrical_panel' THEN 'Photos of the main electrical panel and distribution board'
      WHEN 'roof_structure' THEN 'Photos of roof structure, tiles, and orientation'
      WHEN 'attic_space' THEN 'Photos of attic space and insulation'
      WHEN 'exterior_walls' THEN 'Photos of exterior walls and insulation'
      WHEN 'heating_system' THEN 'Photos of current heating system'
      WHEN 'water_heater' THEN 'Photos of water heating system'
      WHEN 'windows_doors' THEN 'Photos of windows and doors'
      WHEN 'overall_property' THEN 'General photos of the property'
      ELSE description
    END
  )
WHERE name_translations IS NULL OR name_translations->>'en' = name;

-- ============================================================================
-- 3. UPDATE SURVEY PAGES WITH TRANSLATIONS (from 004 seed file)
-- ============================================================================

-- Common page names
UPDATE public.survey_pages SET name_translations = jsonb_build_object('hu', 'Általános adatok', 'en', 'General Information') WHERE name = 'Általános adatok';
UPDATE public.survey_pages SET name_translations = jsonb_build_object('hu', 'Napelem', 'en', 'Solar Panel') WHERE name = 'Napelem';
UPDATE public.survey_pages SET name_translations = jsonb_build_object('hu', 'Inverter', 'en', 'Inverter') WHERE name = 'Inverter';
UPDATE public.survey_pages SET name_translations = jsonb_build_object('hu', 'Tető', 'en', 'Roof') WHERE name = 'Tető';
UPDATE public.survey_pages SET name_translations = jsonb_build_object('hu', 'Akkumulátor', 'en', 'Battery') WHERE name = 'Akkumulátor';
UPDATE public.survey_pages SET name_translations = jsonb_build_object('hu', 'Falak', 'en', 'Walls') WHERE name = 'Falak';
UPDATE public.survey_pages SET name_translations = jsonb_build_object('hu', 'Nyílászárók', 'en', 'Windows') WHERE name = 'Nyílászárók';
UPDATE public.survey_pages SET name_translations = jsonb_build_object('hu', 'Elektromos autó adatok', 'en', 'Electric Vehicle Data') WHERE name = 'Elektromos autó adatok';
UPDATE public.survey_pages SET name_translations = jsonb_build_object('hu', 'Helyszín adatok', 'en', 'Location Data') WHERE name = 'Helyszín adatok';
UPDATE public.survey_pages SET name_translations = jsonb_build_object('hu', 'Teljesítménybővítés', 'en', 'Power Upgrade') WHERE name = 'Teljesítménybővítés';

-- Update item name templates
UPDATE public.survey_pages SET item_name_template_translations = jsonb_build_object('hu', '{index}. tető', 'en', 'Roof {index}') WHERE item_name_template = '{index}. tető';
UPDATE public.survey_pages SET item_name_template_translations = jsonb_build_object('hu', '{index}. falfelület', 'en', 'Wall {index}') WHERE item_name_template = '{index}. falfelület';
UPDATE public.survey_pages SET item_name_template_translations = jsonb_build_object('hu', '{index}. nyílászáró', 'en', 'Window {index}') WHERE item_name_template = '{index}. nyílászáró';

-- ============================================================================
-- 4. UPDATE SURVEY QUESTIONS WITH ENGLISH TRANSLATIONS
-- ============================================================================

-- General questions
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Ingatlan típusa', 'en', 'Property Type') WHERE name = 'property_type';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Építési év', 'en', 'Construction Year') WHERE name = 'construction_year';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Téli hőmérséklet', 'en', 'Winter Temperature') WHERE name = 'winter_temperature';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Fő tájolás', 'en', 'Main Orientation') WHERE name = 'main_orientation';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Van pince?', 'en', 'Has Basement?') WHERE name = 'has_basement';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Van padlás?', 'en', 'Has Attic?') WHERE name = 'has_attic';

-- Roof questions
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Tető típusa', 'en', 'Roof Type') WHERE name = 'roof_type';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Tető tájolása', 'en', 'Roof Orientation') WHERE name = 'roof_orientation';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Tető dőlésszöge', 'en', 'Roof Tilt Angle') WHERE name = 'roof_tilt_angle';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Tető területe', 'en', 'Roof Area') WHERE name = 'roof_area';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Tető anyaga', 'en', 'Roof Material') WHERE name = 'roof_material';

-- Heating questions
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Fűtés típusa', 'en', 'Heating Type') WHERE name = 'heating_type';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Fűtés teljesítménye', 'en', 'Heating Power') WHERE name = 'heating_power';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Éves fűtési költség', 'en', 'Annual Heating Cost') WHERE name = 'annual_heating_cost';

-- Electrical questions
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Áramfázis', 'en', 'Electrical Phase') WHERE name = 'electrical_phase';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Éves villanyszámla', 'en', 'Annual Electricity Bill') WHERE name = 'annual_electricity_bill';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Nappali fogyasztás', 'en', 'Daytime Consumption') WHERE name = 'daytime_consumption';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Éjszakai fogyasztás', 'en', 'Nighttime Consumption') WHERE name = 'nighttime_consumption';

-- Solar panel questions
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Napelemek száma', 'en', 'Number of Solar Panels') WHERE name = 'solar_panel_count';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Napelem teljesítmény', 'en', 'Solar Panel Power') WHERE name = 'solar_panel_power';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Inverter teljesítmény', 'en', 'Inverter Power') WHERE name = 'inverter_power';

-- Update placeholders
UPDATE public.survey_questions SET placeholder_translations = jsonb_build_object('hu', 'pl. 60', 'en', 'e.g. 60') WHERE placeholder_value = 'pl. 60';
UPDATE public.survey_questions SET placeholder_translations = jsonb_build_object('hu', 'pl. 2000', 'en', 'e.g. 2000') WHERE placeholder_value = 'pl. 2000';
UPDATE public.survey_questions SET placeholder_translations = jsonb_build_object('hu', 'pl. 100', 'en', 'e.g. 100') WHERE placeholder_value = 'pl. 100';
UPDATE public.survey_questions SET placeholder_translations = jsonb_build_object('hu', 'Válassz', 'en', 'Select') WHERE placeholder_value = 'Válassz';

-- Update units
UPDATE public.survey_questions SET unit_translations = jsonb_build_object('hu', '°C', 'en', '°C') WHERE unit = '°C';
UPDATE public.survey_questions SET unit_translations = jsonb_build_object('hu', 'kWh', 'en', 'kWh') WHERE unit = 'kWh';
UPDATE public.survey_questions SET unit_translations = jsonb_build_object('hu', 'kW', 'en', 'kW') WHERE unit = 'kW';
UPDATE public.survey_questions SET unit_translations = jsonb_build_object('hu', 'm²', 'en', 'm²') WHERE unit = 'm²';
UPDATE public.survey_questions SET unit_translations = jsonb_build_object('hu', 'm2', 'en', 'm²') WHERE unit = 'm2';
UPDATE public.survey_questions SET unit_translations = jsonb_build_object('hu', 'fok', 'en', 'degrees') WHERE unit = 'fok';
UPDATE public.survey_questions SET unit_translations = jsonb_build_object('hu', 'Ft', 'en', 'HUF') WHERE unit = 'Ft';
UPDATE public.survey_questions SET unit_translations = jsonb_build_object('hu', 'db', 'en', 'pcs') WHERE unit = 'db';
UPDATE public.survey_questions SET unit_translations = jsonb_build_object('hu', 'darab', 'en', 'pieces') WHERE unit = 'darab';
UPDATE public.survey_questions SET unit_translations = jsonb_build_object('hu', 'év', 'en', 'years') WHERE unit = 'év';

-- ============================================================================
-- 5. UPDATE OPTIONS FOR COMMON QUESTIONS
-- ============================================================================

-- Property type options
UPDATE public.survey_questions
SET options_translations = jsonb_build_array(
  jsonb_build_object('value', 'csaladi_haz', 'label', jsonb_build_object('hu', 'Családi ház', 'en', 'Family House')),
  jsonb_build_object('value', 'tarsashaz', 'label', jsonb_build_object('hu', 'Társasház', 'en', 'Apartment Building')),
  jsonb_build_object('value', 'lakas', 'label', jsonb_build_object('hu', 'Lakás', 'en', 'Apartment'))
)
WHERE name = 'property_type'
  AND (options_translations IS NULL OR jsonb_array_length(options_translations) = 0);

-- Update phase toggle options (1 fázis, 3 fázis -> 1 phase, 3 phases)
UPDATE public.survey_questions
SET options_translations = jsonb_build_array(
  jsonb_build_object('value', '1', 'label', jsonb_build_object('hu', '1 fázis', 'en', '1 phase')),
  jsonb_build_object('value', '3', 'label', jsonb_build_object('hu', '3 fázis', 'en', '3 phases'))
)
WHERE type = 'phase_toggle'
  AND options = '["1", "3"]'::jsonb
  AND (options_translations IS NULL OR jsonb_array_length(options_translations) = 0);

-- Update Yes/No options (Igen/Nem -> Yes/No)
UPDATE public.survey_questions
SET options_translations = jsonb_build_array(
  jsonb_build_object('value', 'igen', 'label', jsonb_build_object('hu', 'Igen', 'en', 'Yes')),
  jsonb_build_object('value', 'nem', 'label', jsonb_build_object('hu', 'Nem', 'en', 'No'))
)
WHERE type IN ('dropdown', 'dual_toggle')
  AND options @> '["igen", "nem"]'::jsonb
  AND (options_translations IS NULL OR jsonb_array_length(options_translations) = 0);

-- Update orientation options (É, ÉK, K, DK, D, DNy, Ny, ÉNy -> N, NE, E, SE, S, SW, W, NW)
UPDATE public.survey_questions
SET options_translations = jsonb_build_array(
  jsonb_build_object('value', 'É', 'label', jsonb_build_object('hu', 'É', 'en', 'N')),
  jsonb_build_object('value', 'ÉK', 'label', jsonb_build_object('hu', 'ÉK', 'en', 'NE')),
  jsonb_build_object('value', 'K', 'label', jsonb_build_object('hu', 'K', 'en', 'E')),
  jsonb_build_object('value', 'DK', 'label', jsonb_build_object('hu', 'DK', 'en', 'SE')),
  jsonb_build_object('value', 'D', 'label', jsonb_build_object('hu', 'D', 'en', 'S')),
  jsonb_build_object('value', 'DNy', 'label', jsonb_build_object('hu', 'DNy', 'en', 'SW')),
  jsonb_build_object('value', 'Ny', 'label', jsonb_build_object('hu', 'Ny', 'en', 'W')),
  jsonb_build_object('value', 'ÉNy', 'label', jsonb_build_object('hu', 'ÉNy', 'en', 'NW'))
)
WHERE type = 'orientation_selector'
  AND (options_translations IS NULL OR jsonb_array_length(options_translations) = 0);

-- ============================================================================
-- 6. UPDATE HEAVY CONSUMERS
-- ============================================================================

UPDATE public.heavy_consumers
SET name_translations = jsonb_build_object(
  'hu', name,
  'en', CASE
    WHEN name ILIKE '%medence%' THEN 'Pool'
    WHEN name ILIKE '%szauna%' THEN 'Sauna'
    WHEN name ILIKE '%jakuzzi%' THEN 'Jacuzzi'
    WHEN name ILIKE '%klíma%' OR name ILIKE '%klima%' THEN 'Air Conditioning'
    WHEN name ILIKE '%mosógép%' OR name ILIKE '%mosogep%' THEN 'Washing Machine'
    WHEN name ILIKE '%szárító%' OR name ILIKE '%szarito%' THEN 'Dryer'
    ELSE name
  END
)
WHERE name_translations IS NULL OR name_translations->>'en' = name;

-- ============================================================================
-- 7. UPDATE EXTRA COSTS
-- ============================================================================

UPDATE public.extra_costs
SET name_translations = jsonb_build_object(
  'hu', name,
  'en', CASE
    WHEN name ILIKE '%villanyóra%' OR name ILIKE '%villanyora%' THEN 'Electric Meter'
    WHEN name ILIKE '%villámvédelem%' OR name ILIKE '%villamvedelem%' THEN 'Lightning Protection'
    WHEN name ILIKE '%csatlakozás%' OR name ILIKE '%csatlakozes%' THEN 'Connection'
    WHEN name ILIKE '%kábel%' OR name ILIKE '%kabel%' THEN 'Cable'
    WHEN name ILIKE '%internet%' THEN 'Internet'
    WHEN name ILIKE '%backup%' THEN 'Backup'
    ELSE name
  END
)
WHERE name_translations IS NULL OR name_translations->>'en' = name;

-- ============================================================================
-- Log completion
-- ============================================================================

DO $$
BEGIN
  RAISE NOTICE 'Multilingual translations seeded successfully';
END $$;
