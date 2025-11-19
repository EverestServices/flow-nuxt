-- ============================================================================
-- Migration: Add Supplementary Tasks to Walls Page
-- Description: Adds supplementary tasks questions to the Walls page
--              of Facade Insulation investment, starting at sequence 50
-- ============================================================================

DO $$
DECLARE
    inv_facade_id UUID;
    page_walls_id UUID;
BEGIN
    -- Get Facade Insulation investment ID
    SELECT id INTO inv_facade_id
    FROM public.investments
    WHERE persist_name = 'facadeInsulation';

    IF inv_facade_id IS NULL THEN
        RAISE EXCEPTION 'Facade Insulation investment not found';
    END IF;

    -- Get Walls page ID
    SELECT id INTO page_walls_id
    FROM public.survey_pages
    WHERE investment_id = inv_facade_id AND type = 'walls';

    IF page_walls_id IS NULL THEN
        RAISE EXCEPTION 'Walls page not found';
    END IF;

    -- ========================================================================
    -- PART 1: Kiegészítő feladatok section
    -- ========================================================================

    -- 50. Kiegészítő feladatok (title)
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence
    ) VALUES (
        page_walls_id,
        'supplementary_tasks_title',
        jsonb_build_object('hu', 'Kiegészítő feladatok', 'en', 'Supplementary Tasks'),
        'title',
        false,
        50
    );

    -- 51. Antenna leszerelése
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence,
        default_value
    ) VALUES (
        page_walls_id,
        'antenna_removal',
        jsonb_build_object('hu', 'Antenna leszerelése', 'en', 'Antenna Removal'),
        'switch',
        false,
        51,
        'false'
    );

    -- 52. Ereszdobozolás bontása
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence,
        default_value
    ) VALUES (
        page_walls_id,
        'soffit_removal',
        jsonb_build_object('hu', 'Ereszdobozolás bontása', 'en', 'Soffit Removal'),
        'switch',
        false,
        52,
        'false'
    );

    -- 53. Lefolyócső leszerelése
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence,
        default_value
    ) VALUES (
        page_walls_id,
        'downpipe_removal',
        jsonb_build_object('hu', 'Lefolyócső leszerelése', 'en', 'Downpipe Removal'),
        'switch',
        false,
        53,
        'false'
    );

    -- 54. Lefolyócső visszaszerelése
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence,
        default_value
    ) VALUES (
        page_walls_id,
        'downpipe_reinstallation',
        jsonb_build_object('hu', 'Lefolyócső visszaszerelése', 'en', 'Downpipe Reinstallation'),
        'switch',
        false,
        54,
        'false'
    );

    -- 55. Futónövényzet eltávolítása
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence,
        default_value
    ) VALUES (
        page_walls_id,
        'climbing_plant_removal',
        jsonb_build_object('hu', 'Futónövényzet eltávolítása', 'en', 'Climbing Plant Removal'),
        'switch',
        false,
        55,
        'false'
    );

    -- 56. Előtető bontása
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence,
        default_value
    ) VALUES (
        page_walls_id,
        'canopy_removal',
        jsonb_build_object('hu', 'Előtető bontása', 'en', 'Canopy Removal'),
        'switch',
        false,
        56,
        'false'
    );

    -- 57. Légtechnikai kivezetés toldása
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence,
        default_value
    ) VALUES (
        page_walls_id,
        'ventilation_extension',
        jsonb_build_object('hu', 'Légtechnikai kivezetés toldása', 'en', 'Ventilation Extension'),
        'switch',
        false,
        57,
        'false'
    );

    -- 58. Lámpák le- és felszerelése
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence,
        default_value
    ) VALUES (
        page_walls_id,
        'lamp_removal_installation',
        jsonb_build_object('hu', 'Lámpák le- és felszerelése', 'en', 'Lamp Removal and Installation'),
        'switch',
        false,
        58,
        'false'
    );

    -- 59. Redőny roncsolásmentes bontása
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence,
        default_value
    ) VALUES (
        page_walls_id,
        'shutter_non_destructive_removal',
        jsonb_build_object('hu', 'Redőny roncsolásmentes bontása', 'en', 'Non-Destructive Shutter Removal'),
        'switch',
        false,
        59,
        'false'
    );

    -- 60. Ablakrács leszerelése
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence,
        default_value
    ) VALUES (
        page_walls_id,
        'window_grille_removal',
        jsonb_build_object('hu', 'Ablakrács leszerelése', 'en', 'Window Grille Removal'),
        'switch',
        false,
        60,
        'false'
    );

    -- 61. Kő/beton párkány levésése
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence,
        default_value
    ) VALUES (
        page_walls_id,
        'stone_concrete_sill_chiseling',
        jsonb_build_object('hu', 'Kő/beton párkány levésése', 'en', 'Stone/Concrete Sill Chiseling'),
        'switch',
        false,
        61,
        'false'
    );

    -- 62. Parapet kémények toldása
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence,
        default_value
    ) VALUES (
        page_walls_id,
        'parapet_chimney_extension',
        jsonb_build_object('hu', 'Parapet kémények toldása', 'en', 'Parapet Chimney Extension'),
        'switch',
        false,
        62,
        'false'
    );

    -- 63. Homlokzati kémény található (with info message)
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence,
        default_value, info_message_translations
    ) VALUES (
        page_walls_id,
        'facade_chimney_present',
        jsonb_build_object('hu', 'Homlokzati kémény található', 'en', 'Facade Chimney Present'),
        'switch',
        false,
        63,
        'false',
        jsonb_build_object(
            'hu', 'Kőzetgyapot szigetelő sáv kell',
            'en', 'Rock wool insulation strip required'
        )
    );

    -- 64. Gázcső eldobozolása
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence,
        default_value
    ) VALUES (
        page_walls_id,
        'gas_pipe_boxing',
        jsonb_build_object('hu', 'Gázcső eldobozolása', 'en', 'Gas Pipe Boxing'),
        'switch',
        false,
        64,
        'false'
    );

    -- 65. Korlát roncsolásmentes bontása
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence,
        default_value
    ) VALUES (
        page_walls_id,
        'railing_non_destructive_removal',
        jsonb_build_object('hu', 'Korlát roncsolásmentes bontása', 'en', 'Non-Destructive Railing Removal'),
        'switch',
        false,
        65,
        'false'
    );

    -- 66. Durva struktúrájú lábazat kiegyenlítése
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence,
        default_value
    ) VALUES (
        page_walls_id,
        'rough_foundation_leveling',
        jsonb_build_object('hu', 'Durva struktúrájú lábazat kiegyenlítése', 'en', 'Rough Foundation Leveling'),
        'switch',
        false,
        66,
        'false'
    );

    -- ========================================================================
    -- PART 2: Ügyfél által intézendő kiegészítő feladatok section
    -- ========================================================================

    -- 67. Ügyfél által intézendő kiegészítő feladatok (title with info message)
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence,
        info_message_translations
    ) VALUES (
        page_walls_id,
        'client_managed_tasks_title',
        jsonb_build_object(
            'hu', 'Ügyfél által intézendő kiegészítő feladatok',
            'en', 'Client-Managed Supplementary Tasks'
        ),
        'title',
        false,
        67,
        jsonb_build_object(
            'hu', 'Nem tudjuk vállalni, az ügyfélnek saját hatáskörben kell intézkednie ezeknél az ügyeknél.',
            'en', 'We cannot undertake these tasks; the client must handle these matters independently.'
        )
    );

    -- 68. Antenna felszerelése
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence,
        default_value
    ) VALUES (
        page_walls_id,
        'antenna_installation',
        jsonb_build_object('hu', 'Antenna felszerelése', 'en', 'Antenna Installation'),
        'switch',
        false,
        68,
        'false'
    );

    -- 69. Ereszcsatorna roncsolásmentes leszerelése
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence,
        default_value
    ) VALUES (
        page_walls_id,
        'gutter_non_destructive_removal',
        jsonb_build_object('hu', 'Ereszcsatorna roncsolásmentes leszerelése', 'en', 'Non-Destructive Gutter Removal'),
        'switch',
        false,
        69,
        'false'
    );

    -- 70. Ereszcsatorna felszerelése
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence,
        default_value
    ) VALUES (
        page_walls_id,
        'gutter_installation',
        jsonb_build_object('hu', 'Ereszcsatorna felszerelése', 'en', 'Gutter Installation'),
        'switch',
        false,
        70,
        'false'
    );

    -- 71. Előtető visszaépítése
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence,
        default_value
    ) VALUES (
        page_walls_id,
        'canopy_reinstallation',
        jsonb_build_object('hu', 'Előtető visszaépítése', 'en', 'Canopy Reinstallation'),
        'switch',
        false,
        71,
        'false'
    );

    -- 72. Kamera / riasztó végpontok le-, és felszerelése
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence,
        default_value
    ) VALUES (
        page_walls_id,
        'camera_alarm_removal_installation',
        jsonb_build_object('hu', 'Kamera / riasztó végpontok le-, és felszerelése', 'en', 'Camera/Alarm Endpoint Removal and Installation'),
        'switch',
        false,
        72,
        'false'
    );

    -- 73. Redőny visszaépítése
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence,
        default_value
    ) VALUES (
        page_walls_id,
        'shutter_reinstallation',
        jsonb_build_object('hu', 'Redőny visszaépítése', 'en', 'Shutter Reinstallation'),
        'switch',
        false,
        73,
        'false'
    );

    -- 74. Ablakrács visszaszerelése
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence,
        default_value
    ) VALUES (
        page_walls_id,
        'window_grille_reinstallation',
        jsonb_build_object('hu', 'Ablakrács visszaszerelése', 'en', 'Window Grille Reinstallation'),
        'switch',
        false,
        74,
        'false'
    );

    -- 75. Klíma/hőszivattyú kültéri le-, és felszerelése
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence,
        default_value
    ) VALUES (
        page_walls_id,
        'hvac_outdoor_removal_installation',
        jsonb_build_object('hu', 'Klíma/hőszivattyú kültéri le-, és felszerelése', 'en', 'HVAC/Heat Pump Outdoor Unit Removal and Installation'),
        'switch',
        false,
        75,
        'false'
    );

    -- 76. Gázcső kiemelése
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence,
        default_value
    ) VALUES (
        page_walls_id,
        'gas_pipe_extraction',
        jsonb_build_object('hu', 'Gázcső kiemelése', 'en', 'Gas Pipe Extraction'),
        'switch',
        false,
        76,
        'false'
    );

    -- 77. Gázóra le-, és felszerelése
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence,
        default_value
    ) VALUES (
        page_walls_id,
        'gas_meter_removal_installation',
        jsonb_build_object('hu', 'Gázóra le-, és felszerelése', 'en', 'Gas Meter Removal and Installation'),
        'switch',
        false,
        77,
        'false'
    );

    -- 78. Villanyóra le-, és felszerelése
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence,
        default_value
    ) VALUES (
        page_walls_id,
        'electricity_meter_removal_installation',
        jsonb_build_object('hu', 'Villanyóra le-, és felszerelése', 'en', 'Electricity Meter Removal and Installation'),
        'switch',
        false,
        78,
        'false'
    );

    -- 79. Korlát visszaépítése
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence,
        default_value
    ) VALUES (
        page_walls_id,
        'railing_reinstallation',
        jsonb_build_object('hu', 'Korlát visszaépítése', 'en', 'Railing Reinstallation'),
        'switch',
        false,
        79,
        'false'
    );

    -- ========================================================================
    -- Summary
    -- ========================================================================

    RAISE NOTICE '';
    RAISE NOTICE '✅ Successfully added supplementary tasks to Walls page:';
    RAISE NOTICE '   Sequences 50-66: Kiegészítő feladatok section (17 items)';
    RAISE NOTICE '   Sequences 67-79: Ügyfél által intézendő kiegészítő feladatok section (13 items)';
    RAISE NOTICE '   Total: 30 new questions added';
    RAISE NOTICE '';
    RAISE NOTICE 'Special notes:';
    RAISE NOTICE '   - Question 63 (Homlokzati kémény található) has info message';
    RAISE NOTICE '   - Question 67 (Ügyfél által intézendő...) title has info message';

END $$;
