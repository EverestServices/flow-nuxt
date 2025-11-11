-- ============================================================================
-- Migration: Add Planning and Color Questions to Facade Basic Data
-- Description: Reorganizes Homlokzati szigetelés alapadatok page:
--              - Moves "Homlokzat hőszigetelése" and "Lábazat hőszigetelése"
--                from top of page to before "Színezés"
--              - Adds "Tervezett beruházás" title before them
--              - Adds "Színkód" and "Lábazati vakolat színkód" after "Struktúra"
-- ============================================================================

DO $$
DECLARE
    inv_facade_id UUID;
    page_facade_basic_data_id UUID;
    q_facade_insulation_id UUID;
    q_foundation_insulation_id UUID;
BEGIN
    -- Get Facade Insulation investment ID
    SELECT id INTO inv_facade_id
    FROM public.investments
    WHERE persist_name = 'facadeInsulation';

    IF inv_facade_id IS NULL THEN
        RAISE EXCEPTION 'Facade Insulation investment not found';
    END IF;

    -- Get facade_basic_data page ID
    SELECT id INTO page_facade_basic_data_id
    FROM public.survey_pages
    WHERE investment_id = inv_facade_id AND type = 'facade_basic_data';

    IF page_facade_basic_data_id IS NULL THEN
        RAISE EXCEPTION 'Facade Basic Data page not found';
    END IF;

    -- Get question IDs for facade_insulation and foundation_insulation
    SELECT id INTO q_facade_insulation_id
    FROM public.survey_questions
    WHERE survey_page_id = page_facade_basic_data_id AND name = 'facade_insulation';

    SELECT id INTO q_foundation_insulation_id
    FROM public.survey_questions
    WHERE survey_page_id = page_facade_basic_data_id AND name = 'foundation_insulation';

    -- Check if questions exist, if not we'll create them instead of moving them
    IF q_facade_insulation_id IS NULL THEN
        RAISE NOTICE 'facade_insulation question not found, will create it at sequence 13';
    END IF;

    IF q_foundation_insulation_id IS NULL THEN
        RAISE NOTICE 'foundation_insulation question not found, will create it at sequence 14';
    END IF;

    -- ========================================================================
    -- STEP 1: Move facade_insulation and foundation_insulation to temporary positions
    --         (only if they exist)
    -- ========================================================================

    IF q_facade_insulation_id IS NOT NULL THEN
        UPDATE public.survey_questions
        SET sequence = 1000
        WHERE id = q_facade_insulation_id;
        RAISE NOTICE 'Moved facade_insulation to temporary position';
    END IF;

    IF q_foundation_insulation_id IS NOT NULL THEN
        UPDATE public.survey_questions
        SET sequence = 1001
        WHERE id = q_foundation_insulation_id;
        RAISE NOTICE 'Moved foundation_insulation to temporary position';
    END IF;

    -- ========================================================================
    -- STEP 2: Shift questions down to fill the gap (only if questions exist)
    -- ========================================================================

    -- If both questions exist (at sequences 1-2), shift questions 3-15 down by 2
    -- If questions don't exist, no need to shift
    IF q_facade_insulation_id IS NOT NULL AND q_foundation_insulation_id IS NOT NULL THEN
        UPDATE public.survey_questions
        SET sequence = sequence - 2
        WHERE survey_page_id = page_facade_basic_data_id
          AND sequence >= 3 AND sequence <= 15;

        RAISE NOTICE 'Shifted questions 3-15 down by 2 to fill gap from moved questions';
    ELSE
        RAISE NOTICE 'Skipped shifting - questions do not exist at sequences 1-2';
    END IF;

    -- ========================================================================
    -- STEP 3: Shift questions 16-19 (accordion) to temporary high positions
    -- ========================================================================

    UPDATE public.survey_questions
    SET sequence = sequence + 1000
    WHERE survey_page_id = page_facade_basic_data_id
      AND sequence >= 16 AND sequence <= 19;

    RAISE NOTICE 'Moved accordion questions (16-19) to temporary positions (1016-1019)';

    -- ========================================================================
    -- STEP 4: Insert "Tervezett beruházás" title at sequence 12
    -- ========================================================================

    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence
    ) VALUES (
        page_facade_basic_data_id,
        'planned_investment_title',
        jsonb_build_object('hu', 'Tervezett beruházás', 'en', 'Planned Investment'),
        'title',
        false,
        12
    );

    RAISE NOTICE 'Inserted "Tervezett beruházás" title at sequence 12';

    -- ========================================================================
    -- STEP 5: Move or create facade_insulation and foundation_insulation
    -- ========================================================================

    -- If questions exist, move them to new positions
    IF q_facade_insulation_id IS NOT NULL THEN
        UPDATE public.survey_questions
        SET sequence = 13
        WHERE id = q_facade_insulation_id;
        RAISE NOTICE 'Moved existing facade_insulation to sequence 13';
    ELSE
        -- Create the question if it doesn't exist
        INSERT INTO public.survey_questions (
            survey_page_id, name, name_translations, type, is_required, sequence,
            default_value
        ) VALUES (
            page_facade_basic_data_id,
            'facade_insulation',
            jsonb_build_object('hu', 'Homlokzat hőszigetelése', 'en', 'Facade Insulation'),
            'switch',
            false,
            13,
            'false'
        );
        RAISE NOTICE 'Created facade_insulation question at sequence 13';
    END IF;

    IF q_foundation_insulation_id IS NOT NULL THEN
        UPDATE public.survey_questions
        SET sequence = 14
        WHERE id = q_foundation_insulation_id;
        RAISE NOTICE 'Moved existing foundation_insulation to sequence 14';
    ELSE
        -- Create the question if it doesn't exist
        INSERT INTO public.survey_questions (
            survey_page_id, name, name_translations, type, is_required, sequence,
            default_value
        ) VALUES (
            page_facade_basic_data_id,
            'foundation_insulation',
            jsonb_build_object('hu', 'Lábazat hőszigetelése', 'en', 'Foundation Insulation'),
            'switch',
            false,
            14,
            'false'
        );
        RAISE NOTICE 'Created foundation_insulation question at sequence 14';
    END IF;

    -- ========================================================================
    -- STEP 6: Update coloring and structure names if needed
    -- ========================================================================

    -- coloring is now at sequence 12 (was 14, shifted down by 2)
    -- structure is now at sequence 13 (was 15, shifted down by 2)
    -- We need to move them to 15 and 16

    UPDATE public.survey_questions
    SET sequence = 15
    WHERE survey_page_id = page_facade_basic_data_id AND name = 'coloring';

    UPDATE public.survey_questions
    SET sequence = 16
    WHERE survey_page_id = page_facade_basic_data_id AND name = 'structure';

    RAISE NOTICE 'Moved coloring to sequence 15, structure to sequence 16';

    -- ========================================================================
    -- STEP 7: Insert color code questions after structure
    -- ========================================================================

    -- 17. Színkód (text)
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence,
        placeholder_value, placeholder_translations
    ) VALUES (
        page_facade_basic_data_id,
        'color_code',
        jsonb_build_object('hu', 'Színkód', 'en', 'Color Code'),
        'text',
        false,
        17,
        'Pl.: RAL 9001',
        jsonb_build_object('hu', 'Pl.: RAL 9001', 'en', 'E.g.: RAL 9001')
    );

    -- 18. Lábazati vakolat színkód (text with display condition)
    INSERT INTO public.survey_questions (
        survey_page_id, name, name_translations, type, is_required, sequence,
        placeholder_value, placeholder_translations, display_conditions
    ) VALUES (
        page_facade_basic_data_id,
        'foundation_plaster_color_code',
        jsonb_build_object('hu', 'Lábazati vakolat színkód', 'en', 'Foundation Plaster Color Code'),
        'text',
        false,
        18,
        'Pl.: RAL 7016',
        jsonb_build_object('hu', 'Pl.: RAL 7016', 'en', 'E.g.: RAL 7016'),
        jsonb_build_object(
            'field', 'foundation_insulation',
            'operator', 'equals',
            'value', 'true'
        )
    );

    RAISE NOTICE 'Inserted color code questions at sequences 17-18';

    -- ========================================================================
    -- STEP 8: Move accordion questions to final positions
    -- ========================================================================

    -- Move from temporary positions (1016-1019) to final positions (19-22)
    UPDATE public.survey_questions
    SET sequence = 19
    WHERE survey_page_id = page_facade_basic_data_id AND name = 'defects_title';

    UPDATE public.survey_questions
    SET sequence = 20
    WHERE survey_page_id = page_facade_basic_data_id AND name = 'structural_damage_visible';

    UPDATE public.survey_questions
    SET sequence = 21
    WHERE survey_page_id = page_facade_basic_data_id AND name = 'moisture_damage_visible';

    UPDATE public.survey_questions
    SET sequence = 22
    WHERE survey_page_id = page_facade_basic_data_id AND name = 'water_damage_visible';

    RAISE NOTICE 'Moved accordion questions to sequences 19-22';

    -- ========================================================================
    -- Summary
    -- ========================================================================

    RAISE NOTICE '';
    RAISE NOTICE '✅ Successfully reorganized Homlokzati szigetelés alapadatok page:';
    RAISE NOTICE '   Sequences 1-11: Site conditions and technical questions';
    RAISE NOTICE '   Sequence 12: Tervezett beruházás (title) - NEW';
    RAISE NOTICE '   Sequence 13: Homlokzat hőszigetelése (switch) - moved or created';
    RAISE NOTICE '   Sequence 14: Lábazat hőszigetelése (switch) - moved or created';
    RAISE NOTICE '   Sequence 15: Színezés (coloring)';
    RAISE NOTICE '   Sequence 16: Struktúra (structure)';
    RAISE NOTICE '   Sequence 17: Színkód (text) - NEW';
    RAISE NOTICE '   Sequence 18: Lábazati vakolat színkód (text, conditional) - NEW';
    RAISE NOTICE '   Sequences 19-22: Defects accordion';
    RAISE NOTICE '';
    RAISE NOTICE 'Display condition: "Lábazati vakolat színkód" shows only when "Lábazat hőszigetelése" is checked';
    RAISE NOTICE '';
    RAISE NOTICE 'Note: If facade_insulation or foundation_insulation questions did not exist,';
    RAISE NOTICE '      they were created. If they existed, they were moved to new positions.';

END $$;
