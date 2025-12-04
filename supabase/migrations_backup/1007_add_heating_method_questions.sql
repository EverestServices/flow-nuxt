-- ============================================================================
-- Migration: Add Heating Method Questions to Basic Data
-- Description: Adds multiselect heating method question with conditional follow-ups
-- ============================================================================

DO $$
DECLARE
    page_basic_data_id UUID;
    question_heating_method_id UUID;
BEGIN
    -- Get Basic Data page ID
    SELECT sp.id INTO page_basic_data_id
    FROM public.survey_pages sp
    JOIN public.investments i ON sp.investment_id = i.id
    WHERE i.persist_name = 'basicData'
    AND sp.type = 'basic_data';

    IF page_basic_data_id IS NULL THEN
        RAISE EXCEPTION 'Basic Data page not found';
    END IF;

    -- ========================================================================
    -- Add Heating Method Questions
    -- ========================================================================

    -- 1. Warning Message
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence
    ) VALUES (
        page_basic_data_id,
        'heating_method_warning',
        jsonb_build_object(
            'hu', 'A továbbiakban a meglévő fűtési rendszerre vonatkozó kérdések következnek.',
            'en', 'The following questions relate to the existing heating system.'
        ),
        'warning',
        false,
        26
    );

    -- 2. Main Question: Mivel fűt? (multiselect)
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        options, sequence
    ) VALUES (
        page_basic_data_id,
        'heating_methods',
        jsonb_build_object(
            'hu', 'Mivel fűt? (többet is kiválaszthat) *',
            'en', 'What do you heat with? (you can select multiple) *'
        ),
        'multiselect',
        true,
        jsonb_build_array(
            'Nyílt égésterű gázkazán',
            'Zárt égésterű állandó hőmérsékletű gázkazán',
            'Kondenzációs gázkazán',
            'Vegyes tüzelésű kazán (többféle szilárd tüzelőanyaggal üzemeltethető kazán)',
            'Fatüzelésű cserépkályha (hagyományos, tégla vagy cserép burkolatú, fával fűtött kályha)',
            'Kandalló zárt égésterű (modern kandallóbetét üvegajtóval, hatékony fatüzelés)',
            'Kandalló nyitott égésterű (hagyományos, nyílt tüzű kandalló, díszítési céllal is)',
            'Elektromos kazán',
            'Gázkonvektor',
            'Klíma',
            'Hőszivattyú',
            'Elektromos fűtőpanel',
            'Villanybojler',
            'Gázbojler',
            'Kombi gázkazán (átfolyós)',
            'Indirekt tároló',
            'Elektromos átfolyós vízmelegítő',
            'Napkollektor',
            'Tűzifa (hasábfa) kazán (kizárólag hasábfával fűtött kazán)',
            'Pellettüzelésű kazán (fa pellettel automatikusan adagolt kazán)',
            'Faelgázosító kazán (korszerű, hatékony fatüzelésű kazán gázosító technológiával)',
            'Vezérelt/Éjszakai elektromos hőtárolós kályha (éjszakai kedvezményes árammal töltődő, hőtároló kályha)',
            'Távhő / Származtatott hő (központi kazánházból szolgáltatott hő, mérőórával mért fogyasztás)',
            'Egyéb'
        ),
        27
    )
    RETURNING id INTO question_heating_method_id;

    -- 3. Conditional Question: Hol van ez a fűtőeszköz? (dropdown)
    -- Appears when any gas-based heating method is selected
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        options, sequence, display_conditions
    ) VALUES (
        page_basic_data_id,
        'heating_device_location',
        jsonb_build_object(
            'hu', 'Hol van ez a fűtőeszköz? *',
            'en', 'Where is this heating device located? *'
        ),
        'dropdown',
        true,
        jsonb_build_array(
            'Lakótérben',
            'Nem lakótérben'
        ),
        28,
        jsonb_build_object(
            'field', 'heating_methods',
            'operator', 'contains_any',
            'value', jsonb_build_array(
                'Nyílt égésterű gázkazán',
                'Zárt égésterű állandó hőmérsékletű gázkazán',
                'Kondenzációs gázkazán',
                'Gázkonvektor',
                'Gázbojler',
                'Kombi gázkazán (átfolyós)'
            )
        )
    );

    -- 4. Conditional Question: Másra használja-e ezt a fűtőeszközt? (melegvíz, főzés/sütés) (switch)
    -- Appears when any gas-based heating method is selected
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        default_value, sequence, display_conditions
    ) VALUES (
        page_basic_data_id,
        'heating_device_other_use_gas',
        jsonb_build_object(
            'hu', 'Másra használja-e ezt a fűtőeszközt? (melegvíz, főzés/sütés)',
            'en', 'Do you use this heating device for other purposes? (hot water, cooking/baking)'
        ),
        'switch',
        false,
        'false',
        29,
        jsonb_build_object(
            'field', 'heating_methods',
            'operator', 'contains_any',
            'value', jsonb_build_array(
                'Nyílt égésterű gázkazán',
                'Zárt égésterű állandó hőmérsékletű gázkazán',
                'Kondenzációs gázkazán',
                'Gázkonvektor',
                'Gázbojler',
                'Kombi gázkazán (átfolyós)'
            )
        )
    );

    -- 5. Warning for electric storage heater
    -- Appears when electric storage heater is selected
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        sequence, display_conditions
    ) VALUES (
        page_basic_data_id,
        'electric_storage_heater_warning',
        jsonb_build_object(
            'hu', '💡 Az alábbi kérdések a kiválasztott fűtési módok miatt jelennek meg: Vezérelt/Éjszakai elektromos hőtárolós kályha',
            'en', '💡 The following questions appear due to the selected heating methods: Controlled/Night electric storage heater'
        ),
        'warning',
        false,
        30,
        jsonb_build_object(
            'field', 'heating_methods',
            'operator', 'contains_any',
            'value', jsonb_build_array(
                'Vezérelt/Éjszakai elektromos hőtárolós kályha (éjszakai kedvezményes árammal töltődő, hőtároló kályha)'
            )
        )
    );

    -- 6. Conditional Question: Másra használja-e ezt a fűtőeszközt? (melegvíz/bojler) (switch)
    -- Appears when electric storage heater is selected
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        default_value, sequence, display_conditions
    ) VALUES (
        page_basic_data_id,
        'heating_device_other_use_electric',
        jsonb_build_object(
            'hu', 'Másra használja-e ezt a fűtőeszközt? (melegvíz/bojler)',
            'en', 'Do you use this heating device for other purposes? (hot water/boiler)'
        ),
        'switch',
        false,
        'false',
        31,
        jsonb_build_object(
            'field', 'heating_methods',
            'operator', 'contains_any',
            'value', jsonb_build_array(
                'Vezérelt/Éjszakai elektromos hőtárolós kályha (éjszakai kedvezményes árammal töltődő, hőtároló kályha)'
            )
        )
    );

    -- 7. Conditional Question: Időszak (dual_toggle)
    -- Appears when any wood/solid fuel heating method is selected
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        options_translations, default_value, sequence, display_conditions
    ) VALUES (
        page_basic_data_id,
        'wood_fuel_consumption_period',
        jsonb_build_object(
            'hu', 'Időszak',
            'en', 'Period'
        ),
        'dual_toggle',
        true,
        jsonb_build_array(
            jsonb_build_object('value', 'hónap', 'label', jsonb_build_object('hu', 'hónap', 'en', 'month')),
            jsonb_build_object('value', 'év', 'label', jsonb_build_object('hu', 'év', 'en', 'year'))
        ),
        'hónap',
        32,
        jsonb_build_object(
            'field', 'heating_methods',
            'operator', 'contains_any',
            'value', jsonb_build_array(
                'Fatüzelésű cserépkályha (hagyományos, tégla vagy cserép burkolatú, fával fűtött kályha)',
                'Kandalló zárt égésterű (modern kandallóbetét üvegajtóval, hatékony fatüzelés)',
                'Kandalló nyitott égésterű (hagyományos, nyílt tüzű kandalló, díszítési céllal is)',
                'Vegyes tüzelésű kazán (többféle szilárd tüzelőanyaggal üzemeltethető kazán)',
                'Tűzifa (hasábfa) kazán (kizárólag hasábfával fűtött kazán)',
                'Pellettüzelésű kazán (fa pellettel automatikusan adagolt kazán)',
                'Faelgázosító kazán (korszerű, hatékony fatüzelésű kazán gázosító technológiával)'
            )
        )
    );

    -- 8. Conditional Question: Mértékegység (dual_toggle)
    -- Appears when any wood/solid fuel heating method is selected
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        options_translations, default_value, sequence, display_conditions
    ) VALUES (
        page_basic_data_id,
        'wood_fuel_consumption_unit',
        jsonb_build_object(
            'hu', 'Mértékegység',
            'en', 'Unit'
        ),
        'dual_toggle',
        true,
        jsonb_build_array(
            jsonb_build_object('value', 'kg', 'label', jsonb_build_object('hu', 'kg', 'en', 'kg')),
            jsonb_build_object('value', 'm³', 'label', jsonb_build_object('hu', 'm³', 'en', 'm³'))
        ),
        'kg',
        33,
        jsonb_build_object(
            'field', 'heating_methods',
            'operator', 'contains_any',
            'value', jsonb_build_array(
                'Fatüzelésű cserépkályha (hagyományos, tégla vagy cserép burkolatú, fával fűtött kályha)',
                'Kandalló zárt égésterű (modern kandallóbetét üvegajtóval, hatékony fatüzelés)',
                'Kandalló nyitott égésterű (hagyományos, nyílt tüzű kandalló, díszítési céllal is)',
                'Vegyes tüzelésű kazán (többféle szilárd tüzelőanyaggal üzemeltethető kazán)',
                'Tűzifa (hasábfa) kazán (kizárólag hasábfával fűtött kazán)',
                'Pellettüzelésű kazán (fa pellettel automatikusan adagolt kazán)',
                'Faelgázosító kazán (korszerű, hatékony fatüzelésű kazán gázosító technológiával)'
            )
        )
    );

    -- 9. Conditional Question: Fogyasztás (number)
    -- Appears when any wood/solid fuel heating method is selected
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        sequence, display_conditions
    ) VALUES (
        page_basic_data_id,
        'wood_fuel_consumption_amount',
        jsonb_build_object(
            'hu', 'Fogyasztás',
            'en', 'Consumption'
        ),
        'number',
        true,
        34,
        jsonb_build_object(
            'field', 'heating_methods',
            'operator', 'contains_any',
            'value', jsonb_build_array(
                'Fatüzelésű cserépkályha (hagyományos, tégla vagy cserép burkolatú, fával fűtött kályha)',
                'Kandalló zárt égésterű (modern kandallóbetét üvegajtóval, hatékony fatüzelés)',
                'Kandalló nyitott égésterű (hagyományos, nyílt tüzű kandalló, díszítési céllal is)',
                'Vegyes tüzelésű kazán (többféle szilárd tüzelőanyaggal üzemeltethető kazán)',
                'Tűzifa (hasábfa) kazán (kizárólag hasábfával fűtött kazán)',
                'Pellettüzelésű kazán (fa pellettel automatikusan adagolt kazán)',
                'Faelgázosító kazán (korszerű, hatékony fatüzelésű kazán gázosító technológiával)'
            )
        )
    );

    -- 10. Conditional Question: Időszak (dual_toggle) - District heating
    -- Appears when district heating is selected
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        options_translations, default_value, sequence, display_conditions
    ) VALUES (
        page_basic_data_id,
        'district_heating_consumption_period',
        jsonb_build_object(
            'hu', 'Időszak',
            'en', 'Period'
        ),
        'dual_toggle',
        true,
        jsonb_build_array(
            jsonb_build_object('value', 'hónap', 'label', jsonb_build_object('hu', 'hónap', 'en', 'month')),
            jsonb_build_object('value', 'év', 'label', jsonb_build_object('hu', 'év', 'en', 'year'))
        ),
        'hónap',
        35,
        jsonb_build_object(
            'field', 'heating_methods',
            'operator', 'contains_any',
            'value', jsonb_build_array(
                'Távhő / Származtatott hő (központi kazánházból szolgáltatott hő, mérőórával mért fogyasztás)'
            )
        )
    );

    -- 11. Conditional Question: Mértékegység (dual_toggle) - District heating
    -- Appears when district heating is selected
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        options_translations, default_value, sequence, display_conditions
    ) VALUES (
        page_basic_data_id,
        'district_heating_consumption_unit',
        jsonb_build_object(
            'hu', 'Mértékegység',
            'en', 'Unit'
        ),
        'dual_toggle',
        true,
        jsonb_build_array(
            jsonb_build_object('value', 'kWh', 'label', jsonb_build_object('hu', 'kWh', 'en', 'kWh')),
            jsonb_build_object('value', 'GJ', 'label', jsonb_build_object('hu', 'GJ', 'en', 'GJ')),
            jsonb_build_object('value', 'MJ', 'label', jsonb_build_object('hu', 'MJ', 'en', 'MJ'))
        ),
        'kWh',
        36,
        jsonb_build_object(
            'field', 'heating_methods',
            'operator', 'contains_any',
            'value', jsonb_build_array(
                'Távhő / Származtatott hő (központi kazánházból szolgáltatott hő, mérőórával mért fogyasztás)'
            )
        )
    );

    -- 12. Conditional Question: Fogyasztás (number) - District heating
    -- Appears when district heating is selected
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        sequence, display_conditions
    ) VALUES (
        page_basic_data_id,
        'district_heating_consumption_amount',
        jsonb_build_object(
            'hu', 'Fogyasztás',
            'en', 'Consumption'
        ),
        'number',
        true,
        37,
        jsonb_build_object(
            'field', 'heating_methods',
            'operator', 'contains_any',
            'value', jsonb_build_array(
                'Távhő / Származtatott hő (központi kazánházból szolgáltatott hő, mérőórával mért fogyasztás)'
            )
        )
    );

    RAISE NOTICE 'Successfully added heating method questions to Basic Data page';

END $$;
