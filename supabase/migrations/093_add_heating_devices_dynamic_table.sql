-- ============================================================================
-- Migration: Add Heating Devices Dynamic Table
-- Description: Adds a dynamic table for heating devices that shows columns
--              based on selected heating device types
-- ============================================================================

DO $$
DECLARE
    inv_id UUID;
    page_id UUID;
BEGIN
    -- Get consultant mode investment ID
    SELECT id INTO inv_id FROM public.investments WHERE persist_name = 'consultantMode';

    IF inv_id IS NULL THEN
        RAISE EXCEPTION 'Consultant mode investment not found';
    END IF;

    -- Get the energy consumption page ID
    SELECT id INTO page_id FROM public.survey_pages
    WHERE investment_id = inv_id AND name = 'Energiafelhasználási adatok';

    IF page_id IS NULL THEN
        RAISE EXCEPTION 'Energy consumption page not found';
    END IF;

    -- ========================================================================
    -- Step 1: Update heating_type_select multiselect options
    -- ========================================================================
    UPDATE public.survey_questions
    SET options = '["Villamos készülékek", "Földgáz készülékek", "PB gáz", "Tűzifa, vegyes tüzelő", "Szén"]'::jsonb
    WHERE survey_page_id = page_id
    AND name = 'heating_type_select';

    RAISE NOTICE 'Updated heating_type_select multiselect options';

    -- ========================================================================
    -- Step 2: Add dynamic_table question for heating devices
    -- ========================================================================
    INSERT INTO public.survey_questions (
        survey_page_id,
        name,
        name_translations,
        type,
        is_required,
        options,
        sequence,
        display_settings
    ) VALUES (
        page_id,
        'heating_devices_table',
        jsonb_build_object(
            'hu', 'Fűtő készülékek részletezése',
            'en', 'Heating Devices Details'
        ),
        'dynamic_table',
        false,
        jsonb_build_object(
            'source_field', 'heating_type_select',
            'cell_type', 'single',
            'show_category_headers', false,
            'background_color', 'lightblue',
            'empty_message', jsonb_build_object(
                'hu', 'Kérjük, válassza ki a fűtő készülékeket fent',
                'en', 'Please select heating devices above'
            ),
            'rows', jsonb_build_array(
                -- Nem kondenzációs fűtőkazán (all columns, kW)
                jsonb_build_object(
                    'key', 'non_condensing_boiler',
                    'label', jsonb_build_object(
                        'hu', 'Nem kondenzációs fűtőkazán',
                        'en', 'Non-condensing boiler'
                    ),
                    'unit', 'kW'
                ),
                -- Kondenzációs gázkazán (all columns, kW)
                jsonb_build_object(
                    'key', 'condensing_boiler',
                    'label', jsonb_build_object(
                        'hu', 'Kondenzációs gázkazán',
                        'en', 'Condensing gas boiler'
                    ),
                    'unit', 'kW'
                ),
                -- Kályha, cserépkályha (all columns, db)
                jsonb_build_object(
                    'key', 'stove',
                    'label', jsonb_build_object(
                        'hu', 'Kályha, cserépkályha',
                        'en', 'Stove, tile stove'
                    ),
                    'unit', 'db'
                ),
                -- Kandalló (all columns, db)
                jsonb_build_object(
                    'key', 'fireplace',
                    'label', jsonb_build_object(
                        'hu', 'Kandalló',
                        'en', 'Fireplace'
                    ),
                    'unit', 'db'
                ),
                -- Konvektor (Villamos, Földgáz, PB gáz only, db)
                jsonb_build_object(
                    'key', 'convector',
                    'label', jsonb_build_object(
                        'hu', 'Konvektor',
                        'en', 'Convector'
                    ),
                    'unit', 'db',
                    'columns', jsonb_build_array('Villamos készülékek', 'Földgáz készülékek', 'PB gáz')
                ),
                -- Hősugárzó (Villamos, Földgáz, PB gáz only, db)
                jsonb_build_object(
                    'key', 'radiant_heater',
                    'label', jsonb_build_object(
                        'hu', 'Hősugárzó',
                        'en', 'Radiant heater'
                    ),
                    'unit', 'db',
                    'columns', jsonb_build_array('Villamos készülékek', 'Földgáz készülékek', 'PB gáz')
                ),
                -- Fűtő split klíma (Villamos only, db)
                jsonb_build_object(
                    'key', 'heating_split_ac',
                    'label', jsonb_build_object(
                        'hu', 'Fűtő split klíma',
                        'en', 'Heating split AC'
                    ),
                    'unit', 'db',
                    'columns', jsonb_build_array('Villamos készülékek')
                ),
                -- Levegő-víz hőszivattyú (Villamos only, kW)
                jsonb_build_object(
                    'key', 'air_water_heat_pump',
                    'label', jsonb_build_object(
                        'hu', 'Levegő-víz hőszivattyú',
                        'en', 'Air-to-water heat pump'
                    ),
                    'unit', 'kW',
                    'columns', jsonb_build_array('Villamos készülékek')
                ),
                -- Infrapanel (Villamos only, kW)
                jsonb_build_object(
                    'key', 'infrapanel',
                    'label', jsonb_build_object(
                        'hu', 'Infrapanel',
                        'en', 'Infrared panel'
                    ),
                    'unit', 'kW',
                    'columns', jsonb_build_array('Villamos készülékek')
                )
            )
        ),
        21,
        jsonb_build_object('width', 'full')
    );

    RAISE NOTICE 'Updated heating_type_select multiselect options';
    RAISE NOTICE 'Added heating_devices_table dynamic table at sequence 21';
    RAISE NOTICE 'Table has 9 device types with row-specific units (kW or db)';
    RAISE NOTICE 'Columns are dynamically shown based on heating_type_select field';
    RAISE NOTICE 'Row-specific column visibility is configured';

END $$;

-- ============================================================================
-- END OF MIGRATION
-- ============================================================================
