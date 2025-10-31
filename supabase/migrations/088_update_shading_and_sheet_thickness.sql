-- Update question translations and sequences for shading_factor and sheet_thickness

-- ============================================================================
-- Update shading_factor translation for Napelem, Napelem + Akkumulátor, Klíma
-- ============================================================================

-- Napelem + Akkumulátor
DO $$
DECLARE
    page_id UUID;
BEGIN
    SELECT sp.id INTO page_id
    FROM public.survey_pages sp
    JOIN public.investments i ON sp.investment_id = i.id
    WHERE i.persist_name = 'solarPanelBattery' AND sp.type = 'solar_panel';

    IF page_id IS NOT NULL THEN
        UPDATE public.survey_questions
        SET name_translations = jsonb_build_object(
            'hu', 'Kiterjedt árnyékoló tényező a telepítés tervezett helyén - ha van',
            'en', 'Extended Shading Factor at Planned Installation Location - if any'
        )
        WHERE survey_page_id = page_id AND name = 'shading_factor';
    END IF;
END $$;

-- Napelem
DO $$
DECLARE
    page_id UUID;
BEGIN
    SELECT sp.id INTO page_id
    FROM public.survey_pages sp
    JOIN public.investments i ON sp.investment_id = i.id
    WHERE i.persist_name = 'solarPanel' AND sp.type = 'solar_panel';

    IF page_id IS NOT NULL THEN
        UPDATE public.survey_questions
        SET name_translations = jsonb_build_object(
            'hu', 'Kiterjedt árnyékoló tényező a telepítés tervezett helyén - ha van',
            'en', 'Extended Shading Factor at Planned Installation Location - if any'
        )
        WHERE survey_page_id = page_id AND name = 'shading_factor';
    END IF;
END $$;

-- Klíma
DO $$
DECLARE
    page_id UUID;
BEGIN
    SELECT sp.id INTO page_id
    FROM public.survey_pages sp
    JOIN public.investments i ON sp.investment_id = i.id
    WHERE i.persist_name = 'airConditioner' AND sp.type = 'solar_panel';

    IF page_id IS NOT NULL THEN
        UPDATE public.survey_questions
        SET name_translations = jsonb_build_object(
            'hu', 'Kiterjedt árnyékoló tényező a telepítés tervezett helyén - ha van',
            'en', 'Extended Shading Factor at Planned Installation Location - if any'
        )
        WHERE survey_page_id = page_id AND name = 'shading_factor';
    END IF;
END $$;

-- ============================================================================
-- Update sheet_thickness translation and sequence for roof pages
-- ============================================================================

-- Napelem + Akkumulátor
DO $$
DECLARE
    page_id UUID;
BEGIN
    SELECT sp.id INTO page_id
    FROM public.survey_pages sp
    JOIN public.investments i ON sp.investment_id = i.id
    WHERE i.persist_name = 'solarPanelBattery' AND sp.type = 'roof';

    IF page_id IS NOT NULL THEN
        -- First, shift rafter_spacing from 9 to 10
        UPDATE public.survey_questions
        SET sequence = 10
        WHERE survey_page_id = page_id AND name = 'rafter_spacing';

        -- Then set sheet_thickness to sequence 9 (right after clay_tile_type which is at 8)
        UPDATE public.survey_questions
        SET
            sequence = 9,
            name_translations = jsonb_build_object(
                'hu', 'Trapézlemez és cserepes lemez, szendvicspanel választása esetén lemezvastagság (mm)',
                'en', 'Sheet Thickness for Trapezoidal Sheet, Tile Sheet, or Sandwich Panel (mm)'
            )
        WHERE survey_page_id = page_id AND name = 'sheet_thickness';
    END IF;
END $$;

-- Napelem
DO $$
DECLARE
    page_id UUID;
BEGIN
    SELECT sp.id INTO page_id
    FROM public.survey_pages sp
    JOIN public.investments i ON sp.investment_id = i.id
    WHERE i.persist_name = 'solarPanel' AND sp.type = 'roof';

    IF page_id IS NOT NULL THEN
        -- First, shift rafter_spacing from 9 to 10
        UPDATE public.survey_questions
        SET sequence = 10
        WHERE survey_page_id = page_id AND name = 'rafter_spacing';

        -- Then set sheet_thickness to sequence 9 (right after clay_tile_type which is at 8)
        UPDATE public.survey_questions
        SET
            sequence = 9,
            name_translations = jsonb_build_object(
                'hu', 'Trapézlemez és cserepes lemez, szendvicspanel választása esetén lemezvastagság (mm)',
                'en', 'Sheet Thickness for Trapezoidal Sheet, Tile Sheet, or Sandwich Panel (mm)'
            )
        WHERE survey_page_id = page_id AND name = 'sheet_thickness';
    END IF;
END $$;

-- Klíma
DO $$
DECLARE
    page_id UUID;
BEGIN
    SELECT sp.id INTO page_id
    FROM public.survey_pages sp
    JOIN public.investments i ON sp.investment_id = i.id
    WHERE i.persist_name = 'airConditioner' AND sp.type = 'roof';

    IF page_id IS NOT NULL THEN
        -- First, shift rafter_spacing from 9 to 10
        UPDATE public.survey_questions
        SET sequence = 10
        WHERE survey_page_id = page_id AND name = 'rafter_spacing';

        -- Then set sheet_thickness to sequence 9 (right after clay_tile_type which is at 8)
        UPDATE public.survey_questions
        SET
            sequence = 9,
            name_translations = jsonb_build_object(
                'hu', 'Trapézlemez és cserepes lemez, szendvicspanel választása esetén lemezvastagság (mm)',
                'en', 'Sheet Thickness for Trapezoidal Sheet, Tile Sheet, or Sandwich Panel (mm)'
            )
        WHERE survey_page_id = page_id AND name = 'sheet_thickness';
    END IF;
END $$;
