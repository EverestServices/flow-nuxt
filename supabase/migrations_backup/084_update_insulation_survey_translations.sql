-- ============================================================================
-- Migration: Update Survey Translations for Insulation Investments
-- Description: Update translations and sequences for Homlokzati szigetelés,
--              Tetőszigetelés, and Nyílászáró csere investments
-- ============================================================================

-- ============================================================================
-- ÁLTALÁNOS ADATOK (general) - All 3 investments
-- ============================================================================

-- Homlokzati szigetelés (Facade Insulation)
DO $$
DECLARE
    page_id UUID;
BEGIN
    SELECT sp.id INTO page_id
    FROM public.survey_pages sp
    JOIN public.investments i ON sp.investment_id = i.id
    WHERE i.persist_name = 'facadeInsulation' AND sp.type = 'general';

    IF page_id IS NOT NULL THEN
        UPDATE public.survey_questions SET sequence = 1 WHERE survey_page_id = page_id AND name = 'property_type';
        UPDATE public.survey_questions SET sequence = 2, name_translations = jsonb_build_object('hu', 'A lakás/ház építési éve', 'en', 'Construction Year of Apartment/House') WHERE survey_page_id = page_id AND name = 'construction_year';
        UPDATE public.survey_questions SET sequence = 3, name_translations = jsonb_build_object('hu', 'Lakás téli belső hőmérséklete', 'en', 'Indoor Winter Temperature') WHERE survey_page_id = page_id AND name = 'winter_temperature';
        UPDATE public.survey_questions SET sequence = 4, name_translations = jsonb_build_object('hu', 'Az ingatlan fő életterének tájolása', 'en', 'Main Orientation of Living Space') WHERE survey_page_id = page_id AND name = 'main_orientation';
        UPDATE public.survey_questions SET sequence = 5, name_translations = jsonb_build_object('hu', 'Pincével rendelkezik?', 'en', 'Has Basement?') WHERE survey_page_id = page_id AND name = 'has_basement';
        UPDATE public.survey_questions SET sequence = 6, name_translations = jsonb_build_object('hu', 'Beépített tetőtérrel rendelkezik?', 'en', 'Has Built-in Attic?') WHERE survey_page_id = page_id AND name = 'has_attic';
        UPDATE public.survey_questions SET sequence = 7, name_translations = jsonb_build_object('hu', 'Megjegyzés', 'en', 'Note') WHERE survey_page_id = page_id AND name = 'general_comments';
        -- Egyéb kérdés
        UPDATE public.survey_questions SET sequence = 8, name_translations = jsonb_build_object('hu', 'Vizesedés', 'en', 'Moisture') WHERE survey_page_id = page_id AND name = 'moisture_damage';
    END IF;
END $$;

-- Tetőszigetelés (Roof Insulation)
DO $$
DECLARE
    page_id UUID;
BEGIN
    SELECT sp.id INTO page_id
    FROM public.survey_pages sp
    JOIN public.investments i ON sp.investment_id = i.id
    WHERE i.persist_name = 'roofInsulation' AND sp.type = 'general';

    IF page_id IS NOT NULL THEN
        UPDATE public.survey_questions SET sequence = 1 WHERE survey_page_id = page_id AND name = 'property_type';
        UPDATE public.survey_questions SET sequence = 2, name_translations = jsonb_build_object('hu', 'A lakás/ház építési éve', 'en', 'Construction Year of Apartment/House') WHERE survey_page_id = page_id AND name = 'construction_year';
        UPDATE public.survey_questions SET sequence = 3, name_translations = jsonb_build_object('hu', 'Lakás téli belső hőmérséklete', 'en', 'Indoor Winter Temperature') WHERE survey_page_id = page_id AND name = 'winter_temperature';
        UPDATE public.survey_questions SET sequence = 4, name_translations = jsonb_build_object('hu', 'Az ingatlan fő életterének tájolása', 'en', 'Main Orientation of Living Space') WHERE survey_page_id = page_id AND name = 'main_orientation';
        UPDATE public.survey_questions SET sequence = 5, name_translations = jsonb_build_object('hu', 'Pincével rendelkezik?', 'en', 'Has Basement?') WHERE survey_page_id = page_id AND name = 'has_basement';
        UPDATE public.survey_questions SET sequence = 6, name_translations = jsonb_build_object('hu', 'Beépített tetőtérrel rendelkezik?', 'en', 'Has Built-in Attic?') WHERE survey_page_id = page_id AND name = 'has_attic';
        UPDATE public.survey_questions SET sequence = 7, name_translations = jsonb_build_object('hu', 'Megjegyzés', 'en', 'Note') WHERE survey_page_id = page_id AND name = 'general_comments';
        -- Egyéb kérdés
        UPDATE public.survey_questions SET sequence = 8, name_translations = jsonb_build_object('hu', 'Vizesedés', 'en', 'Moisture') WHERE survey_page_id = page_id AND name = 'moisture_damage';
    END IF;
END $$;

-- Nyílászáró csere (Windows)
DO $$
DECLARE
    page_id UUID;
BEGIN
    SELECT sp.id INTO page_id
    FROM public.survey_pages sp
    JOIN public.investments i ON sp.investment_id = i.id
    WHERE i.persist_name = 'windows' AND sp.type = 'general';

    IF page_id IS NOT NULL THEN
        UPDATE public.survey_questions SET sequence = 1 WHERE survey_page_id = page_id AND name = 'property_type';
        UPDATE public.survey_questions SET sequence = 2, name_translations = jsonb_build_object('hu', 'A lakás/ház építési éve', 'en', 'Construction Year of Apartment/House') WHERE survey_page_id = page_id AND name = 'construction_year';
        UPDATE public.survey_questions SET sequence = 3, name_translations = jsonb_build_object('hu', 'Lakás téli belső hőmérséklete', 'en', 'Indoor Winter Temperature') WHERE survey_page_id = page_id AND name = 'winter_temperature';
        UPDATE public.survey_questions SET sequence = 4, name_translations = jsonb_build_object('hu', 'Az ingatlan fő életterének tájolása', 'en', 'Main Orientation of Living Space') WHERE survey_page_id = page_id AND name = 'main_orientation';
        UPDATE public.survey_questions SET sequence = 5, name_translations = jsonb_build_object('hu', 'Pincével rendelkezik?', 'en', 'Has Basement?') WHERE survey_page_id = page_id AND name = 'has_basement';
        UPDATE public.survey_questions SET sequence = 6, name_translations = jsonb_build_object('hu', 'Beépített tetőtérrel rendelkezik?', 'en', 'Has Built-in Attic?') WHERE survey_page_id = page_id AND name = 'has_attic';
        UPDATE public.survey_questions SET sequence = 7, name_translations = jsonb_build_object('hu', 'Megjegyzés', 'en', 'Note') WHERE survey_page_id = page_id AND name = 'general_comments';
    END IF;
END $$;

-- ============================================================================
-- FALAK (walls) - Homlokzati szigetelés, Tetőszigetelés
-- ============================================================================

-- Homlokzati szigetelés (Facade Insulation)
DO $$
DECLARE
    page_id UUID;
BEGIN
    SELECT sp.id INTO page_id
    FROM public.survey_pages sp
    JOIN public.investments i ON sp.investment_id = i.id
    WHERE i.persist_name = 'facadeInsulation' AND sp.type = 'walls';

    IF page_id IS NOT NULL THEN
        UPDATE public.survey_questions SET sequence = 1 WHERE survey_page_id = page_id AND name = 'wall_type';
        UPDATE public.survey_questions SET sequence = 2 WHERE survey_page_id = page_id AND name = 'wall_thickness';
        UPDATE public.survey_questions SET sequence = 3, name_translations = jsonb_build_object('hu', 'Szélesség (m)', 'en', 'Width (m)') WHERE survey_page_id = page_id AND name = 'wall_width';
        UPDATE public.survey_questions SET sequence = 4, name_translations = jsonb_build_object('hu', 'Magasság (m)', 'en', 'Height (m)') WHERE survey_page_id = page_id AND name = 'wall_height';
        UPDATE public.survey_questions SET sequence = 5, name_translations = jsonb_build_object('hu', 'Lábazat magassága (m)', 'en', 'Foundation Height (m)') WHERE survey_page_id = page_id AND name = 'foundation_height';
        UPDATE public.survey_questions SET sequence = 6, name_translations = jsonb_build_object('hu', 'Hőszigetelés', 'en', 'Thermal Insulation') WHERE survey_page_id = page_id AND name = 'wall_insulation';
        UPDATE public.survey_questions SET sequence = 7, name_translations = jsonb_build_object('hu', 'Hőszigetelés vastagsága (cm)', 'en', 'Thermal Insulation Thickness (cm)') WHERE survey_page_id = page_id AND name = 'wall_insulation_thickness';
    END IF;
END $$;

-- Tetőszigetelés (Roof Insulation)
DO $$
DECLARE
    page_id UUID;
BEGIN
    SELECT sp.id INTO page_id
    FROM public.survey_pages sp
    JOIN public.investments i ON sp.investment_id = i.id
    WHERE i.persist_name = 'roofInsulation' AND sp.type = 'walls';

    IF page_id IS NOT NULL THEN
        UPDATE public.survey_questions SET sequence = 1 WHERE survey_page_id = page_id AND name = 'wall_type';
        UPDATE public.survey_questions SET sequence = 2 WHERE survey_page_id = page_id AND name = 'wall_thickness';
        UPDATE public.survey_questions SET sequence = 3, name_translations = jsonb_build_object('hu', 'Szélesség (m)', 'en', 'Width (m)') WHERE survey_page_id = page_id AND name = 'wall_width';
        UPDATE public.survey_questions SET sequence = 4, name_translations = jsonb_build_object('hu', 'Magasság (m)', 'en', 'Height (m)') WHERE survey_page_id = page_id AND name = 'wall_height';
        UPDATE public.survey_questions SET sequence = 5, name_translations = jsonb_build_object('hu', 'Lábazat magassága (m)', 'en', 'Foundation Height (m)') WHERE survey_page_id = page_id AND name = 'foundation_height';
        UPDATE public.survey_questions SET sequence = 6, name_translations = jsonb_build_object('hu', 'Hőszigetelés', 'en', 'Thermal Insulation') WHERE survey_page_id = page_id AND name = 'wall_insulation';
        UPDATE public.survey_questions SET sequence = 7, name_translations = jsonb_build_object('hu', 'Hőszigetelés vastagsága (cm)', 'en', 'Thermal Insulation Thickness (cm)') WHERE survey_page_id = page_id AND name = 'wall_insulation_thickness';
    END IF;
END $$;

-- ============================================================================
-- TETŐ (roof) - All 3 investments
-- ============================================================================

-- Homlokzati szigetelés (Facade Insulation)
DO $$
DECLARE
    page_id UUID;
BEGIN
    SELECT sp.id INTO page_id
    FROM public.survey_pages sp
    JOIN public.investments i ON sp.investment_id = i.id
    WHERE i.persist_name = 'facadeInsulation' AND sp.type = 'roof';

    IF page_id IS NOT NULL THEN
        UPDATE public.survey_questions SET sequence = 1, name_translations = jsonb_build_object('hu', 'Zárófödém típusa', 'en', 'Ceiling Type') WHERE survey_page_id = page_id AND name = 'roof_type';
        UPDATE public.survey_questions SET sequence = 2, name_translations = jsonb_build_object('hu', 'Tető alapterülete', 'en', 'Roof Floor Area') WHERE survey_page_id = page_id AND name = 'roof_area';
        UPDATE public.survey_questions SET sequence = 3, name_translations = jsonb_build_object('hu', 'Tető típusa', 'en', 'Roof Type') WHERE survey_page_id = page_id AND name = 'roof_material';
        UPDATE public.survey_questions SET sequence = 4, name_translations = jsonb_build_object('hu', 'Beépített?', 'en', 'Built-in?') WHERE survey_page_id = page_id AND name = 'roof_built_in';
        UPDATE public.survey_questions SET sequence = 5, name_translations = jsonb_build_object('hu', 'Hőszigetelés', 'en', 'Thermal Insulation') WHERE survey_page_id = page_id AND name = 'roof_insulation';
        UPDATE public.survey_questions SET sequence = 6, name_translations = jsonb_build_object('hu', 'Hőszigetelés vastagsága (cm)', 'en', 'Thermal Insulation Thickness (cm)') WHERE survey_page_id = page_id AND name = 'roof_insulation_thickness';
    END IF;
END $$;

-- Tetőszigetelés (Roof Insulation)
DO $$
DECLARE
    page_id UUID;
BEGIN
    SELECT sp.id INTO page_id
    FROM public.survey_pages sp
    JOIN public.investments i ON sp.investment_id = i.id
    WHERE i.persist_name = 'roofInsulation' AND sp.type = 'roof';

    IF page_id IS NOT NULL THEN
        UPDATE public.survey_questions SET sequence = 1, name_translations = jsonb_build_object('hu', 'Zárófödém típusa', 'en', 'Ceiling Type') WHERE survey_page_id = page_id AND name = 'roof_type';
        UPDATE public.survey_questions SET sequence = 2, name_translations = jsonb_build_object('hu', 'Tető alapterülete', 'en', 'Roof Floor Area') WHERE survey_page_id = page_id AND name = 'roof_area';
        UPDATE public.survey_questions SET sequence = 3, name_translations = jsonb_build_object('hu', 'Tető típusa', 'en', 'Roof Type') WHERE survey_page_id = page_id AND name = 'roof_material';
        UPDATE public.survey_questions SET sequence = 4, name_translations = jsonb_build_object('hu', 'Beépített?', 'en', 'Built-in?') WHERE survey_page_id = page_id AND name = 'roof_built_in';
        UPDATE public.survey_questions SET sequence = 5, name_translations = jsonb_build_object('hu', 'Hőszigetelés', 'en', 'Thermal Insulation') WHERE survey_page_id = page_id AND name = 'roof_insulation';
        UPDATE public.survey_questions SET sequence = 6, name_translations = jsonb_build_object('hu', 'Hőszigetelés vastagsága (cm)', 'en', 'Thermal Insulation Thickness (cm)') WHERE survey_page_id = page_id AND name = 'roof_insulation_thickness';
    END IF;
END $$;

-- Nyílászáró csere (Windows)
DO $$
DECLARE
    page_id UUID;
BEGIN
    SELECT sp.id INTO page_id
    FROM public.survey_pages sp
    JOIN public.investments i ON sp.investment_id = i.id
    WHERE i.persist_name = 'windows' AND sp.type = 'roof';

    IF page_id IS NOT NULL THEN
        UPDATE public.survey_questions SET sequence = 1, name_translations = jsonb_build_object('hu', 'Zárófödém típusa', 'en', 'Ceiling Type') WHERE survey_page_id = page_id AND name = 'roof_type';
        UPDATE public.survey_questions SET sequence = 2, name_translations = jsonb_build_object('hu', 'Tető alapterülete', 'en', 'Roof Floor Area') WHERE survey_page_id = page_id AND name = 'roof_area';
        UPDATE public.survey_questions SET sequence = 3, name_translations = jsonb_build_object('hu', 'Tető típusa', 'en', 'Roof Type') WHERE survey_page_id = page_id AND name = 'roof_material';
        UPDATE public.survey_questions SET sequence = 4, name_translations = jsonb_build_object('hu', 'Beépített?', 'en', 'Built-in?') WHERE survey_page_id = page_id AND name = 'roof_built_in';
        UPDATE public.survey_questions SET sequence = 5, name_translations = jsonb_build_object('hu', 'Hőszigetelés', 'en', 'Thermal Insulation') WHERE survey_page_id = page_id AND name = 'roof_insulation';
        UPDATE public.survey_questions SET sequence = 6, name_translations = jsonb_build_object('hu', 'Hőszigetelés vastagsága (cm)', 'en', 'Thermal Insulation Thickness (cm)') WHERE survey_page_id = page_id AND name = 'roof_insulation_thickness';
    END IF;
END $$;

-- ============================================================================
-- NYÍLÁSZÁRÓK (windows) - Only for Tetőszigetelés and Nyílászáró csere
-- ============================================================================

-- Tetőszigetelés (Roof Insulation)
DO $$
DECLARE
    page_id UUID;
BEGIN
    SELECT sp.id INTO page_id
    FROM public.survey_pages sp
    JOIN public.investments i ON sp.investment_id = i.id
    WHERE i.persist_name = 'roofInsulation' AND sp.type = 'windows';

    IF page_id IS NOT NULL THEN
        UPDATE public.survey_questions SET sequence = 1, name_translations = jsonb_build_object('hu', 'Típus', 'en', 'Type') WHERE survey_page_id = page_id AND name = 'window_type';
        UPDATE public.survey_questions SET sequence = 2, name_translations = jsonb_build_object('hu', 'Szélesség', 'en', 'Width') WHERE survey_page_id = page_id AND name = 'window_width';
        UPDATE public.survey_questions SET sequence = 3, name_translations = jsonb_build_object('hu', 'Magasság', 'en', 'Height') WHERE survey_page_id = page_id AND name = 'window_height';
        UPDATE public.survey_questions SET sequence = 4, name_translations = jsonb_build_object('hu', 'Mennyiség', 'en', 'Quantity') WHERE survey_page_id = page_id AND name = 'window_quantity';
        -- Egyéb kérdések
        UPDATE public.survey_questions SET sequence = 5, name_translations = jsonb_build_object('hu', 'Anyag', 'en', 'Material') WHERE survey_page_id = page_id AND name = 'window_material';
        UPDATE public.survey_questions SET sequence = 6, name_translations = jsonb_build_object('hu', 'Üvegezés', 'en', 'Glazing') WHERE survey_page_id = page_id AND name = 'window_glazing';
    END IF;
END $$;

-- Nyílászáró csere (Windows)
DO $$
DECLARE
    page_id UUID;
BEGIN
    SELECT sp.id INTO page_id
    FROM public.survey_pages sp
    JOIN public.investments i ON sp.investment_id = i.id
    WHERE i.persist_name = 'windows' AND sp.type = 'windows';

    IF page_id IS NOT NULL THEN
        UPDATE public.survey_questions SET sequence = 1, name_translations = jsonb_build_object('hu', 'Típus', 'en', 'Type') WHERE survey_page_id = page_id AND name = 'window_type';
        UPDATE public.survey_questions SET sequence = 2, name_translations = jsonb_build_object('hu', 'Szélesség', 'en', 'Width') WHERE survey_page_id = page_id AND name = 'window_width';
        UPDATE public.survey_questions SET sequence = 3, name_translations = jsonb_build_object('hu', 'Magasság', 'en', 'Height') WHERE survey_page_id = page_id AND name = 'window_height';
        UPDATE public.survey_questions SET sequence = 4, name_translations = jsonb_build_object('hu', 'Mennyiség', 'en', 'Quantity') WHERE survey_page_id = page_id AND name = 'window_quantity';
        -- Egyéb kérdések
        UPDATE public.survey_questions SET sequence = 5, name_translations = jsonb_build_object('hu', 'Anyag', 'en', 'Material') WHERE survey_page_id = page_id AND name = 'window_material';
        UPDATE public.survey_questions SET sequence = 6, name_translations = jsonb_build_object('hu', 'Üvegezés', 'en', 'Glazing') WHERE survey_page_id = page_id AND name = 'window_glazing';
    END IF;
END $$;

-- ============================================================================
-- Log completion
-- ============================================================================

DO $$
BEGIN
  RAISE NOTICE 'Insulation investments survey translations and sequences updated successfully';
END $$;
