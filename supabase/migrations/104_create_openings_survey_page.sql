-- ============================================================================
-- Migration: Create Openings (Nyílászárók) Survey Page
-- Description: Creates a new hierarchical survey page for Openings as a
--              subpage of Walls (Falak) in Facade Insulation investment
-- ============================================================================

DO $$
DECLARE
    inv_facade_id UUID;
    page_walls_id UUID;
    page_openings_id UUID;

    -- Basic Data source question ID
    source_reveal_depth_id UUID;
BEGIN
    -- Get the Facade Insulation investment ID
    SELECT id INTO inv_facade_id
    FROM public.investments
    WHERE persist_name = 'facadeInsulation';

    IF inv_facade_id IS NULL THEN
        RAISE EXCEPTION 'Facade Insulation investment not found';
    END IF;

    -- Get the Walls page ID (this will be the parent page)
    SELECT id INTO page_walls_id
    FROM public.survey_pages
    WHERE investment_id = inv_facade_id
      AND name = 'Falak';

    IF page_walls_id IS NULL THEN
        RAISE EXCEPTION 'Walls page not found in Facade Insulation investment';
    END IF;

    -- Get Basic Data source question ID for reveal depth
    SELECT sq.id INTO source_reveal_depth_id
    FROM public.survey_questions sq
    JOIN public.survey_pages sp ON sp.id = sq.survey_page_id
    JOIN public.investments i ON i.id = sp.investment_id
    WHERE i.persist_name = 'basicData' AND sq.name = 'reveal_depth_uniform';

    -- ========================================================================
    -- STEP 1: Create Openings Survey Page (subpage of Walls)
    -- ========================================================================

    INSERT INTO public.survey_pages (
        investment_id,
        parent_page_id,
        name,
        name_translations,
        type,
        position,
        allow_multiple,
        allow_delete_first,
        sequence,
        item_name_template,
        item_name_template_translations
    ) VALUES (
        inv_facade_id,
        page_walls_id,  -- This makes it a subpage of Walls
        'Nyílászárók',
        jsonb_build_object('hu', 'Nyílászárók', 'en', 'Openings'),
        'openings',
        '{"top": 100, "right": 200}'::jsonb,
        true,  -- Allow multiple openings per wall
        true,  -- Allow deleting first instance
        1,     -- First subpage of Walls
        '{index}. nyílászáró',
        jsonb_build_object('hu', '{index}. nyílászáró', 'en', 'Opening {index}')
    )
    RETURNING id INTO page_openings_id;

    -- ========================================================================
    -- STEP 2: Create Survey Questions for Openings Page
    -- ========================================================================

    -- 1. Nyílászáró típusa
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        options, sequence
    ) VALUES (
        page_openings_id,
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
        page_openings_id,
        'opening_width',
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
        page_openings_id,
        'opening_height',
        jsonb_build_object('hu', 'Magassága (cm)', 'en', 'Height (cm)'),
        'number',
        true,
        'cm',
        jsonb_build_object('hu', 'cm', 'en', 'cm'),
        3
    );

    -- 4. Mennyisége (db)
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        unit, unit_translations, sequence
    ) VALUES (
        page_openings_id,
        'opening_quantity',
        jsonb_build_object('hu', 'Mennyisége (db)', 'en', 'Quantity (pcs)'),
        'number',
        true,
        'db',
        jsonb_build_object('hu', 'db', 'en', 'pcs'),
        4
    );

    -- 5. Külső árnyékoló típusa
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        options, sequence, info_message_translations
    ) VALUES (
        page_openings_id,
        'external_shading_type',
        jsonb_build_object(
            'hu', 'Külső árnyékoló típusa',
            'en', 'External Shading Type'
        ),
        'dropdown',
        true,
        jsonb_build_array('Nincs', 'Redőny', 'Zsalugáter', 'Zsalúzia', 'Textil roló'),
        5,
        jsonb_build_object(
            'hu', 'Zsalugáter: tömör fa, vagy fém szerkezetű nyíló vagy toló árnyékoló szerkezet.\nZsalúzia: fém lamellás, a tokjába visszahúzható árnyékoló.',
            'en', 'Shutter (Zsalugáter): solid wood or metal hinged or sliding shading structure.\nBlind (Zsalúzia): metal louvered, retractable shading device.'
        )
    );

    -- 6. Káva mélység (cm)
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required,
        unit, unit_translations, sequence, info_message_translations,
        default_value_source_question_id, is_readonly
    ) VALUES (
        page_openings_id,
        'reveal_depth',
        jsonb_build_object('hu', 'Káva mélység (cm)', 'en', 'Reveal Depth (cm)'),
        'number',
        true,
        'cm',
        jsonb_build_object('hu', 'cm', 'en', 'cm'),
        6,
        jsonb_build_object(
            'hu', 'A homlokzati sík, és a meglévő ablaktok vízszintesen mért távolsága, jellemzően 10-20 cm közötti érték. Más szóval az ablakpárkány mélysége, a falon túlnyúló cseppentő levonásával.',
            'en', 'The horizontal distance between the facade plane and existing windows, typically 10-20 cm. In other words, the depth of the window sill, minus any protruding drip edge.'
        ),
        source_reveal_depth_id,
        true
    );

    RAISE NOTICE 'Successfully created Openings survey page and questions';

END $$;
