-- ============================================================================
-- Migration: Add Energy Consumption Dynamic Table
-- Description: Replaces individual consumption questions with a dynamic table
--              that shows columns based on selected energy carriers
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
    -- Step 1: Delete old individual consumption questions (sequences 10-16)
    -- ========================================================================
    DELETE FROM public.survey_questions
    WHERE survey_page_id = page_id
    AND name IN (
        'energy_consumption_electricity',
        'energy_consumption_natural_gas',
        'energy_consumption_district_heating',
        'energy_consumption_firewood',
        'energy_consumption_coal',
        'energy_consumption_solar_collector',
        'energy_consumption_lpg'
    );

    RAISE NOTICE 'Deleted old consumption questions';

    -- ========================================================================
    -- Step 2: Add dynamic_table question for energy consumption
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
        'energy_consumption_table',
        jsonb_build_object(
            'hu', 'Energiafelhasználás részletezése',
            'en', 'Energy Consumption Details'
        ),
        'dynamic_table',
        false,
        jsonb_build_object(
            'source_field', 'energy_consumption_select',
            'cell_type', 'single',
            'show_category_headers', true,
            'empty_message', jsonb_build_object(
                'hu', 'Kérjük, válassza ki az energiahordozó típusokat fent',
                'en', 'Please select energy carrier types above'
            ),
            'column_units', jsonb_build_object(
                'Villamos energia', 'kWh/év',
                'Földgáz', 'm³/év',
                'PB gáz', 'kg/év',
                'Tűzifa, vegyes tüzelő', 'kg/év',
                'Szén', 'kg/év',
                'Napkollektorok éves hőtermelése', 'kWh/év'
            ),
            'row_groups', jsonb_build_array(
                -- Category 1: Fűtési energiafelhasználások (beige/amber)
                jsonb_build_object(
                    'category', jsonb_build_object(
                        'hu', 'Fűtési energiafelhasználások',
                        'en', 'Heating Energy Consumption'
                    ),
                    'background_color', 'beige',
                    'rows', jsonb_build_array(
                        jsonb_build_object(
                            'key', 'heating_central',
                            'label', jsonb_build_object(
                                'hu', 'Központi fűtés',
                                'en', 'Central heating'
                            ),
                            'unit', '%'
                        ),
                        jsonb_build_object(
                            'key', 'heating_individual',
                            'label', jsonb_build_object(
                                'hu', 'Egyedi fűtés',
                                'en', 'Individual heating'
                            ),
                            'columns', jsonb_build_array('Villamos energia', 'Földgáz', 'PB gáz', 'Tűzifa, vegyes tüzelő', 'Szén'),
                            'unit', '%'
                        )
                    )
                ),
                -- Category 2: Melegvíz előállítás energiafelhasználások (pink)
                jsonb_build_object(
                    'category', jsonb_build_object(
                        'hu', 'Melegvíz előállítás energiafelhasználások',
                        'en', 'Hot Water Production Energy Consumption'
                    ),
                    'background_color', 'pink',
                    'rows', jsonb_build_array(
                        jsonb_build_object(
                            'key', 'hot_water_storage',
                            'label', jsonb_build_object(
                                'hu', 'Tárolós melegvíz',
                                'en', 'Storage water heater'
                            ),
                            'columns', jsonb_build_array('Villamos energia', 'Földgáz', 'PB gáz', 'Tűzifa, vegyes tüzelő', 'Napkollektorok éves hőtermelése'),
                            'unit', '%'
                        ),
                        jsonb_build_object(
                            'key', 'hot_water_instant',
                            'label', jsonb_build_object(
                                'hu', 'Átfolyós melegvíz',
                                'en', 'Instant water heater'
                            ),
                            'columns', jsonb_build_array('Villamos energia', 'Földgáz', 'PB gáz', 'Tűzifa, vegyes tüzelő'),
                            'unit', '%'
                        )
                    )
                ),
                -- Category 3: Főzés-sütés energiafelhasználások (beige/amber)
                jsonb_build_object(
                    'category', jsonb_build_object(
                        'hu', 'Főzés-sütés energiafelhasználások',
                        'en', 'Cooking Energy Consumption'
                    ),
                    'background_color', 'beige',
                    'rows', jsonb_build_array(
                        jsonb_build_object(
                            'key', 'cooking',
                            'label', jsonb_build_object(
                                'hu', 'Főzés',
                                'en', 'Cooking'
                            ),
                            'columns', jsonb_build_array('Villamos energia', 'Földgáz', 'PB gáz', 'Tűzifa, vegyes tüzelő'),
                            'unit', '%'
                        ),
                        jsonb_build_object(
                            'key', 'baking',
                            'label', jsonb_build_object(
                                'hu', 'Sütés',
                                'en', 'Baking'
                            ),
                            'columns', jsonb_build_array('Villamos energia', 'Földgáz', 'PB gáz', 'Tűzifa, vegyes tüzelő'),
                            'unit', '%'
                        )
                    )
                ),
                -- Category 4: Hűtési energiafelhasználások (lightblue/cyan)
                jsonb_build_object(
                    'category', jsonb_build_object(
                        'hu', 'Hűtési energiafelhasználások',
                        'en', 'Cooling Energy Consumption'
                    ),
                    'background_color', 'lightblue',
                    'rows', jsonb_build_array(
                        jsonb_build_object(
                            'key', 'cooling_central',
                            'label', jsonb_build_object(
                                'hu', 'Központi klíma',
                                'en', 'Central AC'
                            ),
                            'columns', jsonb_build_array('Villamos energia'),
                            'unit', '%'
                        ),
                        jsonb_build_object(
                            'key', 'cooling_individual',
                            'label', jsonb_build_object(
                                'hu', 'Egyedi klíma',
                                'en', 'Individual AC'
                            ),
                            'columns', jsonb_build_array('Villamos energia'),
                            'unit', '%'
                        )
                    )
                ),
                -- Category 5: Egyéb (lightgreen/emerald)
                jsonb_build_object(
                    'category', jsonb_build_object(
                        'hu', 'Egyéb',
                        'en', 'Other'
                    ),
                    'background_color', 'lightgreen',
                    'rows', jsonb_build_array(
                        jsonb_build_object(
                            'key', 'other',
                            'label', jsonb_build_object(
                                'hu', 'Egyéb',
                                'en', 'Other'
                            ),
                            'columns', jsonb_build_array('Villamos energia', 'Földgáz', 'Napkollektorok éves hőtermelése'),
                            'unit', '%'
                        )
                    )
                ),
                -- Category 6: Háztartási készülékek energiafelhasználásai (lavender/purple)
                jsonb_build_object(
                    'category', jsonb_build_object(
                        'hu', 'Háztartási készülékek energiafelhasználásai',
                        'en', 'Household Appliances Energy Consumption'
                    ),
                    'background_color', 'lavender',
                    'rows', jsonb_build_array(
                        jsonb_build_object(
                            'key', 'appliances_total',
                            'label', jsonb_build_object(
                                'hu', 'Összesen',
                                'en', 'Total'
                            ),
                            'columns', jsonb_build_array('Villamos energia', 'Földgáz', 'PB gáz', 'Tűzifa, vegyes tüzelő', 'Szén'),
                            'unit', '%'
                        )
                    )
                )
            )
        ),
        10,
        jsonb_build_object('width', 'full')
    );

    RAISE NOTICE 'Added energy_consumption_table dynamic table at sequence 10';
    RAISE NOTICE 'Table has 6 categories with single-cell inputs (percentage only)';
    RAISE NOTICE 'Columns are dynamically shown based on energy_consumption_select field';
    RAISE NOTICE 'Összesen row excluded from Napkollektorok column';

END $$;

-- ============================================================================
-- END OF MIGRATION
-- ============================================================================
