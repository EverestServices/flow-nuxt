-- ============================================================================
-- Migration: Create Windows Survey Pages and Questions
-- Description: Creates survey pages and questions for Nyílászárók
--              (Windows) investment
-- ============================================================================

DO $$
DECLARE
    inv_windows_id UUID;
    page_current_windows_id UUID;
BEGIN
    -- ========================================================================
    -- STEP 1: Get the Windows investment ID
    -- ========================================================================

    SELECT id INTO inv_windows_id
    FROM public.investments
    WHERE persist_name = 'windows';

    IF inv_windows_id IS NULL THEN
        RAISE EXCEPTION 'Windows investment not found (persist_name: windows)';
    END IF;

    RAISE NOTICE 'Found Windows investment with ID: %', inv_windows_id;

    -- ========================================================================
    -- STEP 2: Create Survey Page - Jelenlegi nyílászárók (Current Windows)
    -- ========================================================================

    INSERT INTO public.survey_pages (
        investment_id,
        name,
        name_translations,
        type,
        position,
        allow_multiple,
        allow_delete_first,
        item_name_template,
        item_name_template_translations,
        sequence
    ) VALUES (
        inv_windows_id,
        'Jelenlegi nyílászárók',
        jsonb_build_object('hu', 'Jelenlegi nyílászárók', 'en', 'Current Windows'),
        'current_windows',
        '{"top": 100, "right": 100}'::jsonb,
        true,
        true,
        '{index}. nyílászáró',
        jsonb_build_object('hu', '{index}. nyílászáró', 'en', 'Window {index}'),
        1
    )
    RETURNING id INTO page_current_windows_id;

    RAISE NOTICE 'Created survey page: Jelenlegi nyílászárók (ID: %)', page_current_windows_id;

    -- ========================================================================
    -- STEP 3: Create Questions for Jelenlegi nyílászárók
    -- ========================================================================

    -- 1. Nyílászáró típusa
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        options, sequence
    ) VALUES (
        page_current_windows_id,
        'opening_type',
        jsonb_build_object('hu', 'Nyílászáró típusa', 'en', 'Opening Type'),
        'dropdown',
        true,
        jsonb_build_array('Ablak', 'Ajtó', 'Erkélyajtó'),
        1
    );

    -- 2. Szélessége (cm)
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        unit, unit_translations, sequence
    ) VALUES (
        page_current_windows_id,
        'width',
        jsonb_build_object('hu', 'Szélessége (cm)', 'en', 'Width (cm)'),
        'number',
        true,
        'cm',
        jsonb_build_object('hu', 'cm', 'en', 'cm'),
        2
    );

    -- 3. Magassága (cm)
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        unit, unit_translations, sequence
    ) VALUES (
        page_current_windows_id,
        'height',
        jsonb_build_object('hu', 'Magassága (cm)', 'en', 'Height (cm)'),
        'number',
        true,
        'cm',
        jsonb_build_object('hu', 'cm', 'en', 'cm'),
        3
    );

    -- 4. Mennyisége (Title)
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        info_message_translations, sequence
    ) VALUES (
        page_current_windows_id,
        'quantity_title',
        jsonb_build_object('hu', 'Mennyisége', 'en', 'Quantity'),
        'title',
        false,
        jsonb_build_object(
            'hu', 'Azon az oldalon állva, amerre a szárny nyílik, attól jobbos vagy balos, hogy a zsanért melyik oldalra szerelték.',
            'en', 'Standing on the side where the wing opens, it is right-handed or left-handed depending on which side the hinge is mounted.'
        ),
        4
    );

    -- 5. Jobbos (db)
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        unit, unit_translations, sequence
    ) VALUES (
        page_current_windows_id,
        'right_handed_count',
        jsonb_build_object('hu', 'Jobbos (db)', 'en', 'Right-handed (pcs)'),
        'number',
        true,
        'db',
        jsonb_build_object('hu', 'db', 'en', 'pcs'),
        5
    );

    -- 6. Balos (db)
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        unit, unit_translations, sequence
    ) VALUES (
        page_current_windows_id,
        'left_handed_count',
        jsonb_build_object('hu', 'Balos (db)', 'en', 'Left-handed (pcs)'),
        'number',
        true,
        'db',
        jsonb_build_object('hu', 'db', 'en', 'pcs'),
        6
    );

    -- 7. Külső árnyékoló típusa
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        options, sequence
    ) VALUES (
        page_current_windows_id,
        'external_shading_type',
        jsonb_build_object('hu', 'Külső árnyékoló típusa', 'en', 'External Shading Type'),
        'dropdown',
        true,
        jsonb_build_array('Nincs', 'Redőny', 'Zsalugáter', 'Zsalúzia', 'Textil roló'),
        7
    );

    -- 8. Tájolása
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        options, sequence
    ) VALUES (
        page_current_windows_id,
        'orientation',
        jsonb_build_object('hu', 'Tájolása', 'en', 'Orientation'),
        'orientation_selector',
        true,
        jsonb_build_array('É', 'ÉK', 'K', 'DK', 'D', 'DNy', 'Ny', 'ÉNy'),
        8
    );

    -- 9. Új nyílászáró jellemzői (Title)
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        sequence
    ) VALUES (
        page_current_windows_id,
        'new_window_characteristics_title',
        jsonb_build_object('hu', 'Új nyílászáró jellemzői', 'en', 'New Window Characteristics'),
        'title',
        false,
        9
    );

    -- 10. Ablak típusa (only visible when opening_type = 'Ablak')
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        options, sequence, display_conditions
    ) VALUES (
        page_current_windows_id,
        'window_type',
        jsonb_build_object('hu', 'Ablak típusa', 'en', 'Window Type'),
        'dropdown',
        true,
        jsonb_build_array('Fix ablak', 'Egyszárnyú ablak', 'Kétszárnyú ablak', 'Háromszárnyú ablak'),
        10,
        jsonb_build_object(
            'field', 'opening_type',
            'operator', 'equals',
            'value', 'Ablak'
        )
    );

    -- 11. Nyitásmód (only visible when window_type = 'Egyszárnyú ablak')
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        options, sequence, display_conditions
    ) VALUES (
        page_current_windows_id,
        'opening_mode',
        jsonb_build_object('hu', 'Nyitásmód', 'en', 'Opening Mode'),
        'dropdown',
        true,
        jsonb_build_array('Bukó', 'Nyíló', 'Bukó-nyíló'),
        11,
        jsonb_build_object(
            'field', 'window_type',
            'operator', 'equals',
            'value', 'Egyszárnyú ablak'
        )
    );

    -- 12. Kétszárnyú ablak fajtája (only visible when window_type = 'Kétszárnyú ablak')
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        options, sequence, display_conditions
    ) VALUES (
        page_current_windows_id,
        'double_wing_window_type',
        jsonb_build_object('hu', 'Kétszárnyú ablak fajtája', 'en', 'Double Wing Window Type'),
        'dropdown',
        true,
        jsonb_build_array('Tokosztott (mindkettő bukó-nyíló)', 'Váltószárnyas (főszárny: bukó-nyíló, másodszárny: nyíló)'),
        12,
        jsonb_build_object(
            'field', 'window_type',
            'operator', 'equals',
            'value', 'Kétszárnyú ablak'
        )
    );

    -- 13. Háromszárnyú ablak fajtája (only visible when window_type = 'Háromszárnyú ablak')
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        options, sequence, display_conditions
    ) VALUES (
        page_current_windows_id,
        'triple_wing_window_type',
        jsonb_build_object('hu', 'Háromszárnyú ablak fajtája', 'en', 'Triple Wing Window Type'),
        'dropdown',
        true,
        jsonb_build_array('Tokosztott (minden szárny bukó-nyíló)', 'Váltószárnyas (fősz.: b-ny, 2. szárny: ny, 3. szárny: fix)'),
        13,
        jsonb_build_object(
            'field', 'window_type',
            'operator', 'equals',
            'value', 'Háromszárnyú ablak'
        )
    );

    -- 14. Ajtó típusa (only visible when opening_type = 'Ajtó')
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        options, sequence, display_conditions
    ) VALUES (
        page_current_windows_id,
        'door_type',
        jsonb_build_object('hu', 'Ajtó típusa', 'en', 'Door Type'),
        'dropdown',
        true,
        jsonb_build_array('Egyszárnyú', 'Kétszárnyú'),
        14,
        jsonb_build_object(
            'field', 'opening_type',
            'operator', 'equals',
            'value', 'Ajtó'
        )
    );

    -- 15. Oldalvilágító (only visible when opening_type = 'Ajtó')
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        default_value, sequence, display_conditions
    ) VALUES (
        page_current_windows_id,
        'side_light',
        jsonb_build_object('hu', 'Oldalvilágító', 'en', 'Side Light'),
        'switch',
        true,
        'false',
        15,
        jsonb_build_object(
            'field', 'opening_type',
            'operator', 'equals',
            'value', 'Ajtó'
        )
    );

    -- 16. felülvilágító (only visible when opening_type = 'Ajtó')
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        default_value, sequence, display_conditions
    ) VALUES (
        page_current_windows_id,
        'top_light',
        jsonb_build_object('hu', 'felülvilágító', 'en', 'Top Light'),
        'switch',
        true,
        'false',
        16,
        jsonb_build_object(
            'field', 'opening_type',
            'operator', 'equals',
            'value', 'Ajtó'
        )
    );

    -- 17. Üvegezett szárny(ak) (only visible when opening_type = 'Ajtó')
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        default_value, sequence, display_conditions
    ) VALUES (
        page_current_windows_id,
        'glazed_wings',
        jsonb_build_object('hu', 'Üvegezett szárny(ak)', 'en', 'Glazed Wing(s)'),
        'switch',
        true,
        'false',
        17,
        jsonb_build_object(
            'field', 'opening_type',
            'operator', 'equals',
            'value', 'Ajtó'
        )
    );

    -- 18. Erkélyajtó típusa (only visible when opening_type = 'Erkélyajtó')
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        options, sequence, display_conditions
    ) VALUES (
        page_current_windows_id,
        'balcony_door_type',
        jsonb_build_object('hu', 'Erkélyajtó típusa', 'en', 'Balcony Door Type'),
        'dropdown',
        true,
        jsonb_build_array('Egyszárnyú', 'Kétszárnyú'),
        18,
        jsonb_build_object(
            'field', 'opening_type',
            'operator', 'equals',
            'value', 'Erkélyajtó'
        )
    );

    -- 19. Kiegészítők (Title)
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        sequence
    ) VALUES (
        page_current_windows_id,
        'accessories_title',
        jsonb_build_object('hu', 'Kiegészítők', 'en', 'Accessories'),
        'title',
        false,
        19
    );

    -- 20. Műanyag profil színe
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        options, sequence
    ) VALUES (
        page_current_windows_id,
        'plastic_profile_color',
        jsonb_build_object('hu', 'Műanyag profil színe', 'en', 'Plastic Profile Color'),
        'dropdown',
        true,
        jsonb_build_array('Fehér', 'Kívül színes, belül fehér', 'Mindkét oldalt színes'),
        20
    );

    -- 21. Párkány
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        options, sequence
    ) VALUES (
        page_current_windows_id,
        'windowsill',
        jsonb_build_object('hu', 'Párkány', 'en', 'Windowsill'),
        'dropdown',
        true,
        jsonb_build_array('Nem kér', 'Fehér műanyag', 'Alumínium'),
        21
    );

    -- 22. Könyöklő
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        options, sequence
    ) VALUES (
        page_current_windows_id,
        'apron',
        jsonb_build_object('hu', 'Könyöklő', 'en', 'Apron'),
        'dropdown',
        true,
        jsonb_build_array('Nem kér', 'Fehér műanyag'),
        22
    );

    -- 23. Rovarháló
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        options, sequence
    ) VALUES (
        page_current_windows_id,
        'insect_screen',
        jsonb_build_object('hu', 'Rovarháló', 'en', 'Insect Screen'),
        'dropdown',
        true,
        jsonb_build_array('Nem kér', 'Fix alumínium', 'Felső tokos rolós', 'Oldalsó tokos rolós', 'Oldalsó tokos pliszés', 'Árnyékolóba integrált rolós'),
        23
    );

    -- 24. Árnyékoló
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        options, sequence
    ) VALUES (
        page_current_windows_id,
        'shading',
        jsonb_build_object('hu', 'Árnyékoló', 'en', 'Shading'),
        'dropdown',
        true,
        jsonb_build_array('Nem kér', 'Világos műanyag lamellás redőny', 'Alumínium redőny', 'Zsalúzia'),
        24
    );

    -- 25. Résszellőző
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        default_value, sequence
    ) VALUES (
        page_current_windows_id,
        'trickle_vent',
        jsonb_build_object('hu', 'Résszellőző', 'en', 'Trickle Vent'),
        'switch',
        true,
        'false',
        25
    );

    -- ========================================================================
    -- STEP 4: Summary
    -- ========================================================================

    RAISE NOTICE '========================================';
    RAISE NOTICE 'Successfully created Windows survey structure';
    RAISE NOTICE 'Created 1 survey page:';
    RAISE NOTICE '  1. Jelenlegi nyílászárók (25 questions)';
    RAISE NOTICE 'Total: 25 questions';
    RAISE NOTICE '========================================';

END $$;
