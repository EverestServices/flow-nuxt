-- Migration: Recreate Heat Pump Investment Pages
-- Description: Deletes all existing Heat Pump pages and questions, then creates a new page "Hőszivattyú adatok" with updated questions

DO $$
DECLARE
    inv_heat_pump_id UUID;
    page_heat_pump_data_id UUID;
BEGIN
    -- Get the Heat Pump investment ID
    SELECT id INTO inv_heat_pump_id
    FROM public.investments
    WHERE persist_name = 'heatPump';

    IF inv_heat_pump_id IS NULL THEN
        RAISE EXCEPTION 'Heat Pump investment not found';
    END IF;

    -- ========================================================================
    -- STEP 1: Delete all existing survey questions for Heat Pump pages
    -- ========================================================================

    DELETE FROM public.survey_questions
    WHERE survey_page_id IN (
        SELECT id FROM public.survey_pages
        WHERE investment_id = inv_heat_pump_id
    );

    RAISE NOTICE 'Deleted all survey questions for Heat Pump pages';

    -- ========================================================================
    -- STEP 2: Delete all existing survey pages for Heat Pump
    -- ========================================================================

    DELETE FROM public.survey_pages
    WHERE investment_id = inv_heat_pump_id;

    RAISE NOTICE 'Deleted all survey pages for Heat Pump';

    -- ========================================================================
    -- STEP 3: Create new "Hőszivattyú adatok" page
    -- ========================================================================

    INSERT INTO public.survey_pages (
        investment_id,
        name,
        name_translations,
        type,
        position,
        allow_multiple,
        allow_delete_first,
        sequence
    ) VALUES (
        inv_heat_pump_id,
        'Hőszivattyú adatok',
        jsonb_build_object(
            'hu', 'Hőszivattyú adatok',
            'en', 'Heat Pump Data'
        ),
        'heat_pump_data',
        '{"top": 100, "right": 100}'::jsonb,
        false,
        false,
        1
    )
    RETURNING id INTO page_heat_pump_data_id;

    RAISE NOTICE 'Created new "Hőszivattyú adatok" page with ID: %', page_heat_pump_data_id;

    -- ========================================================================
    -- STEP 4: Add survey questions
    -- ========================================================================

    -- 1. Jövőben tervez szigetelni?
    INSERT INTO public.survey_questions (
        survey_page_id,
        name,
        name_translations,
        type,
        is_required,
        sequence
    ) VALUES (
        page_heat_pump_data_id,
        'planning_insulation',
        jsonb_build_object(
            'hu', 'Jövőben tervez szigetelni?',
            'en', 'Planning to insulate in the future?'
        ),
        'switch',
        false,
        1
    );

    -- 2. Ha igen, akkor mit és milyen vastagsággal? (title)
    INSERT INTO public.survey_questions (
        survey_page_id,
        name,
        name_translations,
        type,
        is_required,
        sequence
    ) VALUES (
        page_heat_pump_data_id,
        'insulation_details_title',
        jsonb_build_object(
            'hu', 'Ha igen, akkor mit és milyen vastagsággal?',
            'en', 'If yes, what and with what thickness?'
        ),
        'title',
        false,
        2
    );

    -- 3. Födém (switch with 2/3 width)
    INSERT INTO public.survey_questions (
        survey_page_id,
        name,
        name_translations,
        type,
        is_required,
        display_settings,
        sequence
    ) VALUES (
        page_heat_pump_data_id,
        'ceiling_insulation',
        jsonb_build_object(
            'hu', 'Födém',
            'en', 'Ceiling'
        ),
        'switch',
        false,
        jsonb_build_object('width', '2/3'),
        3
    );

    -- 4. Födémszigetelés vastagsága (cm)
    INSERT INTO public.survey_questions (
        survey_page_id,
        name,
        name_translations,
        type,
        is_required,
        unit,
        unit_translations,
        display_settings,
        display_conditions,
        sequence
    ) VALUES (
        page_heat_pump_data_id,
        'ceiling_insulation_thickness',
        jsonb_build_object(
            'hu', 'Födémszigetelés vastagsága (cm)',
            'en', 'Ceiling Insulation Thickness (cm)'
        ),
        'number',
        false,
        'cm',
        jsonb_build_object('hu', 'cm', 'en', 'cm'),
        jsonb_build_object('width', '1/3'),
        jsonb_build_object(
            'field', 'ceiling_insulation',
            'operator', 'equals',
            'value', true
        ),
        4
    );

    -- 5. Homlokzat (switch with 2/3 width)
    INSERT INTO public.survey_questions (
        survey_page_id,
        name,
        name_translations,
        type,
        is_required,
        display_settings,
        sequence
    ) VALUES (
        page_heat_pump_data_id,
        'facade_insulation',
        jsonb_build_object(
            'hu', 'Homlokzat',
            'en', 'Facade'
        ),
        'switch',
        false,
        jsonb_build_object('width', '2/3'),
        5
    );

    -- 6. Homlokzati szigetelés vastagsága (cm)
    INSERT INTO public.survey_questions (
        survey_page_id,
        name,
        name_translations,
        type,
        is_required,
        unit,
        unit_translations,
        display_settings,
        display_conditions,
        sequence
    ) VALUES (
        page_heat_pump_data_id,
        'facade_insulation_thickness',
        jsonb_build_object(
            'hu', 'Homlokzati szigetelés vastagsága (cm)',
            'en', 'Facade Insulation Thickness (cm)'
        ),
        'number',
        false,
        'cm',
        jsonb_build_object('hu', 'cm', 'en', 'cm'),
        jsonb_build_object('width', '1/3'),
        jsonb_build_object(
            'field', 'facade_insulation',
            'operator', 'equals',
            'value', true
        ),
        6
    );

    -- 7. Jelenlegi hőleadó körök (multiselect)
    INSERT INTO public.survey_questions (
        survey_page_id,
        name,
        name_translations,
        type,
        is_required,
        options_translations,
        sequence
    ) VALUES (
        page_heat_pump_data_id,
        'current_heat_emitter_circuits',
        jsonb_build_object(
            'hu', 'Jelenlegi hőleadó körök',
            'en', 'Current Heat Emitter Circuits'
        ),
        'multiselect',
        false,
        jsonb_build_array(
            jsonb_build_object('value', 'radiator', 'label', jsonb_build_object('hu', 'Radiátor', 'en', 'Radiator')),
            jsonb_build_object('value', 'floor_heating', 'label', jsonb_build_object('hu', 'Padlófűtés', 'en', 'Floor Heating')),
            jsonb_build_object('value', 'ceiling_heating', 'label', jsonb_build_object('hu', 'Mennyezetfűtés', 'en', 'Ceiling Heating')),
            jsonb_build_object('value', 'wall_heating', 'label', jsonb_build_object('hu', 'Falfűtés', 'en', 'Wall Heating')),
            jsonb_build_object('value', 'fancoil', 'label', jsonb_build_object('hu', 'Fancoil', 'en', 'Fancoil')),
            jsonb_build_object('value', 'other', 'label', jsonb_build_object('hu', 'Egyéb', 'en', 'Other'))
        ),
        7
    );

    -- 8. Jelenlegi hőleadó kör pontos típusa (text, conditional)
    INSERT INTO public.survey_questions (
        survey_page_id,
        name,
        name_translations,
        type,
        is_required,
        display_conditions,
        sequence
    ) VALUES (
        page_heat_pump_data_id,
        'heat_emitter_circuit_other_type',
        jsonb_build_object(
            'hu', 'Jelenlegi hőleadó kör pontos típusa',
            'en', 'Exact Type of Current Heat Emitter Circuit'
        ),
        'text',
        false,
        jsonb_build_object(
            'field', 'current_heat_emitter_circuits',
            'operator', 'contains',
            'value', 'other'
        ),
        8
    );

    -- Note: Questions 9-N for heat emitter distribution will be handled by a new component type
    -- This will be implemented separately as a special "multiselect_with_distribution" type

    -- 9. Beruházás célja (dropdown)
    INSERT INTO public.survey_questions (
        survey_page_id,
        name,
        name_translations,
        type,
        is_required,
        options_translations,
        sequence
    ) VALUES (
        page_heat_pump_data_id,
        'investment_goal',
        jsonb_build_object(
            'hu', 'Beruházás célja',
            'en', 'Investment Goal'
        ),
        'dropdown',
        false,
        jsonb_build_array(
            jsonb_build_object('value', 'partial_replacement', 'label', jsonb_build_object('hu', 'Meglévő rendszer részleges kiváltása (hibrid kialakítás)', 'en', 'Partial Replacement of Existing System (Hybrid Configuration)')),
            jsonb_build_object('value', 'full_replacement', 'label', jsonb_build_object('hu', 'Meglévő rendszer teljes kiváltása', 'en', 'Full Replacement of Existing System')),
            jsonb_build_object('value', 'new_investment', 'label', jsonb_build_object('hu', 'Új beruházás', 'en', 'New Investment'))
        ),
        9
    );

    -- 10. A két rendszer közötti átkapcsolás (dropdown, conditional)
    INSERT INTO public.survey_questions (
        survey_page_id,
        name,
        name_translations,
        type,
        is_required,
        options_translations,
        display_conditions,
        sequence
    ) VALUES (
        page_heat_pump_data_id,
        'system_switching',
        jsonb_build_object(
            'hu', 'A két rendszer közötti átkapcsolás',
            'en', 'Switching Between Two Systems'
        ),
        'dropdown',
        false,
        jsonb_build_array(
            jsonb_build_object('value', 'manual', 'label', jsonb_build_object('hu', 'Manuális kétállású kapcsolóval', 'en', 'Manual Two-Position Switch')),
            jsonb_build_object('value', 'automatic', 'label', jsonb_build_object('hu', 'Automatikus vezérléssel', 'en', 'Automatic Control'))
        ),
        jsonb_build_object(
            'field', 'investment_goal',
            'operator', 'equals',
            'value', 'partial_replacement'
        ),
        10
    );

    -- 11. Mire szeretné használni a hőszivattyút? (dropdown)
    INSERT INTO public.survey_questions (
        survey_page_id,
        name,
        name_translations,
        type,
        is_required,
        options_translations,
        sequence
    ) VALUES (
        page_heat_pump_data_id,
        'heat_pump_usage',
        jsonb_build_object(
            'hu', 'Mire szeretné használni a hőszivattyút?',
            'en', 'What do you want to use the heat pump for?'
        ),
        'dropdown',
        false,
        jsonb_build_array(
            jsonb_build_object('value', 'heating', 'label', jsonb_build_object('hu', 'Fűtésre', 'en', 'For Heating')),
            jsonb_build_object('value', 'heating_cooling', 'label', jsonb_build_object('hu', 'Fűtésre és hűtésre', 'en', 'For Heating and Cooling'))
        ),
        11
    );

    -- 12. Mivel tervezi előállítani a melegvizet? (dropdown)
    INSERT INTO public.survey_questions (
        survey_page_id,
        name,
        name_translations,
        type,
        is_required,
        options_translations,
        sequence
    ) VALUES (
        page_heat_pump_data_id,
        'hot_water_production',
        jsonb_build_object(
            'hu', 'Mivel tervezi előállítani a melegvizet?',
            'en', 'How do you plan to produce hot water?'
        ),
        'dropdown',
        false,
        jsonb_build_array(
            jsonb_build_object('value', 'current_remains', 'label', jsonb_build_object('hu', 'Jelenlegi marad', 'en', 'Current Remains')),
            jsonb_build_object('value', 'new_boiler', 'label', jsonb_build_object('hu', 'Új bojler', 'en', 'New Boiler')),
            jsonb_build_object('value', 'heat_pump', 'label', jsonb_build_object('hu', 'Hőszivattyúval', 'en', 'With Heat Pump'))
        ),
        12
    );

    -- 13. Rendelkezik a ház olyan (minimum 2m x 2m) helyiséggel...
    INSERT INTO public.survey_questions (
        survey_page_id,
        name,
        name_translations,
        type,
        is_required,
        sequence
    ) VALUES (
        page_heat_pump_data_id,
        'has_suitable_room',
        jsonb_build_object(
            'hu', 'Rendelkezik a ház olyan (minimum 2m x 2m) helyiséggel, ahova a hőközpont kiépíthető és a hőszivattyú bevezethető?',
            'en', 'Does the house have a room (minimum 2m x 2m) where the heat center can be built and the heat pump can be introduced?'
        ),
        'switch',
        false,
        13
    );

    -- 14. Hőszivattyú kültéri egysége és a puffertartály közötti nyomvonal hossza (m)
    INSERT INTO public.survey_questions (
        survey_page_id,
        name,
        name_translations,
        type,
        is_required,
        unit,
        unit_translations,
        sequence
    ) VALUES (
        page_heat_pump_data_id,
        'outdoor_unit_to_buffer_distance',
        jsonb_build_object(
            'hu', 'Hőszivattyú kültéri egysége és a puffertartály közötti nyomvonal hossza (m)',
            'en', 'Distance between outdoor unit and buffer tank (m)'
        ),
        'number',
        false,
        'm',
        jsonb_build_object('hu', 'm', 'en', 'm'),
        14
    );

    -- 15. Puffertartály és az osztó-gyűjtő közötti nyomvonal hossza (m)
    INSERT INTO public.survey_questions (
        survey_page_id,
        name,
        name_translations,
        type,
        is_required,
        unit,
        unit_translations,
        sequence
    ) VALUES (
        page_heat_pump_data_id,
        'buffer_to_manifold_distance',
        jsonb_build_object(
            'hu', 'Puffertartály és az osztó-gyűjtő, hibrid bekötés esetén a puffertartály és gázkazán közötti fűtő/hűtőköri csövezés nyomvonalának hossza (m)',
            'en', 'Distance of heating/cooling circuit piping between buffer tank and manifold, or in case of hybrid connection between buffer tank and gas boiler (m)'
        ),
        'number',
        false,
        'm',
        jsonb_build_object('hu', 'm', 'en', 'm'),
        15
    );

    -- 16. Jelenleg van lehetőség az elektromos rákötésre...
    INSERT INTO public.survey_questions (
        survey_page_id,
        name,
        name_translations,
        type,
        is_required,
        options_translations,
        sequence
    ) VALUES (
        page_heat_pump_data_id,
        'electrical_connection_available',
        jsonb_build_object(
            'hu', 'Jelenleg van lehetőség az elektromos rákötésre a kültéri egységnél vagy a puffertartálynál?',
            'en', 'Is there currently a possibility for electrical connection at the outdoor unit or buffer tank?'
        ),
        'dropdown',
        false,
        jsonb_build_array(
            jsonb_build_object('value', 'yes', 'label', jsonb_build_object('hu', 'Igen', 'en', 'Yes')),
            jsonb_build_object('value', 'no_client_installs', 'label', jsonb_build_object('hu', 'Nem, viszont az Ügyfél vállalja ennek kiépítését', 'en', 'No, but the Client will install it'))
        ),
        16
    );

    -- 17. A kültéri egységtől vagy a puffertartálytól milyen hosszú nyomvonallal lehet eljutni az elektromos betápláláshoz...
    INSERT INTO public.survey_questions (
        survey_page_id,
        name,
        name_translations,
        type,
        is_required,
        unit,
        unit_translations,
        sequence
    ) VALUES (
        page_heat_pump_data_id,
        'electrical_feed_distance',
        jsonb_build_object(
            'hu', 'A kültéri egységtől vagy a puffertartálytól milyen hosszú nyomvonallal lehet eljutni az elektromos betápláláshoz (amennyiben nincsen még kiépítve, a tervezett helyéhez)? (m)',
            'en', 'How long is the route from the outdoor unit or buffer tank to the electrical feed (if not yet built, to the planned location)? (m)'
        ),
        'number',
        false,
        'm',
        jsonb_build_object('hu', 'm', 'en', 'm'),
        17
    );

    -- 18. Osztón túli átalakításokra szükség van?
    INSERT INTO public.survey_questions (
        survey_page_id,
        name,
        name_translations,
        type,
        is_required,
        options_translations,
        sequence
    ) VALUES (
        page_heat_pump_data_id,
        'manifold_modifications_needed',
        jsonb_build_object(
            'hu', 'Osztón túli átalakításokra szükség van?',
            'en', 'Are modifications beyond the manifold needed?'
        ),
        'dropdown',
        false,
        jsonb_build_array(
            jsonb_build_object('value', 'no', 'label', jsonb_build_object('hu', 'Nem', 'en', 'No')),
            jsonb_build_object('value', 'yes_client_installs', 'label', jsonb_build_object('hu', 'Igen, az Ügyfél vállalja ennek kiépítését', 'en', 'Yes, the Client will install it'))
        ),
        18
    );

    -- 19. H tarifa kiépítésre kerül?
    INSERT INTO public.survey_questions (
        survey_page_id,
        name,
        name_translations,
        type,
        is_required,
        sequence
    ) VALUES (
        page_heat_pump_data_id,
        'h_tariff_installed',
        jsonb_build_object(
            'hu', 'H tarifa kiépítésre kerül?',
            'en', 'Will H tariff be installed?'
        ),
        'switch',
        false,
        19
    );

    -- 20. Faláttörések (title)
    INSERT INTO public.survey_questions (
        survey_page_id,
        name,
        name_translations,
        type,
        is_required,
        sequence
    ) VALUES (
        page_heat_pump_data_id,
        'wall_breakthroughs_title',
        jsonb_build_object(
            'hu', 'Faláttörések',
            'en', 'Wall Breakthroughs'
        ),
        'title',
        false,
        20
    );

    -- Note: Wall breakthroughs repeatable field will be implemented as a new question type
    -- This will be a "repeatable_field" or "dynamic_list" type

    -- 21. Földmunka szükséges a puffertartály és kültéri egység közötti nyomvonalon
    INSERT INTO public.survey_questions (
        survey_page_id,
        name,
        name_translations,
        type,
        is_required,
        options_translations,
        sequence
    ) VALUES (
        page_heat_pump_data_id,
        'groundwork_needed',
        jsonb_build_object(
            'hu', 'Földmunka szükséges a puffertartály és kültéri egység közötti nyomvonalon',
            'en', 'Groundwork needed on the route between buffer tank and outdoor unit'
        ),
        'dropdown',
        false,
        jsonb_build_array(
            jsonb_build_object('value', 'no', 'label', jsonb_build_object('hu', 'Nem', 'en', 'No')),
            jsonb_build_object('value', 'yes_client_digs', 'label', jsonb_build_object('hu', 'Igen, az Ügyfél vállalja a nyomvonal kiásását', 'en', 'Yes, the Client will dig the route'))
        ),
        21
    );

    -- 22. Betonalapzat, szikkasztó ágy vagy csepegtető tálca kivitelezése szükséges
    INSERT INTO public.survey_questions (
        survey_page_id,
        name,
        name_translations,
        type,
        is_required,
        options_translations,
        sequence
    ) VALUES (
        page_heat_pump_data_id,
        'foundation_construction_needed',
        jsonb_build_object(
            'hu', 'Betonalapzat, szikkasztó ágy vagy csepegtető tálca kivitelezése szükséges',
            'en', 'Concrete foundation, drainage bed or drip tray construction needed'
        ),
        'dropdown',
        false,
        jsonb_build_array(
            jsonb_build_object('value', 'no', 'label', jsonb_build_object('hu', 'Nem', 'en', 'No')),
            jsonb_build_object('value', 'yes_client_constructs', 'label', jsonb_build_object('hu', 'Igen, az Ügyfél vállalja a kivitelezését', 'en', 'Yes, the Client will construct it'))
        ),
        22
    );

    -- Note: Drawing area will be implemented as a new "drawing_area" type
    -- This will be added in a separate migration

    RAISE NOTICE '========================================';
    RAISE NOTICE 'Heat Pump pages recreated successfully!';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'Created page: Hőszivattyú adatok (ID: %)', page_heat_pump_data_id;
    RAISE NOTICE 'Added 22 basic questions (special types to be added separately)';

END $$;
