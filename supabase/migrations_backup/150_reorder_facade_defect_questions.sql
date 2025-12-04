-- ============================================================================
-- Migration: Reorder facade defect questions
-- Description: Moves defect-related questions to appear after material storage question
--
-- Original order (seq 11-19):
--   11. Hibák hozzáadása
--   12. Tartószerkezeti kárkép látható-e
--   13. Felszívódó nedvesség okozta kárkép látható-e
--   14. Ázás kárkép látható-e
--   15. Munkaterület adottságai
--   16. Homlokzatok állványozhatók
--   17. Konténer elhelyezése
--   18. Ingatlan teherautóval megközelíthető
--   19. Építőanyag tárolás portán belül megoldható
--
-- New order (seq 11-23):
--   11. Munkaterület adottságai
--   12. Homlokzatok állványozhatók
--   13. Konténer elhelyezése
--   14. Ingatlan teherautóval megközelíthető
--   15. Építőanyag tárolás portán belül megoldható
--   16. Hibák hozzáadása
--   17. Tartószerkezeti kárkép látható-e
--   18. Felszívódó nedvesség okozta kárkép látható-e
--   19. Ázás kárkép látható-e
-- ============================================================================

DO $$
DECLARE
    facade_page_id UUID;
    affected_rows INTEGER := 0;
BEGIN
    -- Get the facade insulation basic data page ID
    SELECT id INTO facade_page_id
    FROM public.survey_pages
    WHERE name = 'Homlokzati szigetelés alapadatok'
    LIMIT 1;

    IF facade_page_id IS NULL THEN
        RAISE EXCEPTION 'Homlokzati szigetelés alapadatok page not found';
    END IF;

    RAISE NOTICE 'Found page ID: %', facade_page_id;

    -- Step 1: Temporarily move defect questions to high sequence numbers (to avoid conflicts)
    UPDATE public.survey_questions
    SET sequence = 100 + sequence
    WHERE survey_page_id = facade_page_id
      AND sequence BETWEEN 11 AND 14;

    GET DIAGNOSTICS affected_rows = ROW_COUNT;
    RAISE NOTICE 'Step 1: Temporarily moved % defect questions to 111-114', affected_rows;

    -- Step 2: Move site conditions questions down from 15-19 to 11-15
    UPDATE public.survey_questions
    SET sequence = sequence - 4
    WHERE survey_page_id = facade_page_id
      AND sequence BETWEEN 15 AND 19;

    GET DIAGNOSTICS affected_rows = ROW_COUNT;
    RAISE NOTICE 'Step 2: Moved % site condition questions down to 11-15', affected_rows;

    -- Step 3: Move defect questions from temp positions (111-114) to final positions (16-19)
    UPDATE public.survey_questions
    SET sequence = sequence - 100 + 5
    WHERE survey_page_id = facade_page_id
      AND sequence BETWEEN 111 AND 114;

    GET DIAGNOSTICS affected_rows = ROW_COUNT;
    RAISE NOTICE 'Step 3: Moved % defect questions to final positions 16-19', affected_rows;

    -- Verification
    RAISE NOTICE '';
    RAISE NOTICE '✅ Successfully reordered facade questions';
    RAISE NOTICE '';
    RAISE NOTICE 'New order:';
    RAISE NOTICE '  11. Munkaterület adottságai (site_conditions_title)';
    RAISE NOTICE '  12. Homlokzatok állványozhatók (facades_scaffoldable)';
    RAISE NOTICE '  13. Konténer elhelyezése (container_placement)';
    RAISE NOTICE '  14. Ingatlan teherautóval megközelíthető (truck_accessible)';
    RAISE NOTICE '  15. Építőanyag tárolás portán belül megoldható (material_storage_on_site)';
    RAISE NOTICE '  16. Hibák hozzáadása (defects_title)';
    RAISE NOTICE '  17. Tartószerkezeti kárkép látható-e (structural_damage_visible)';
    RAISE NOTICE '  18. Felszívódó nedvesség okozta kárkép látható-e (moisture_damage_visible)';
    RAISE NOTICE '  19. Ázás kárkép látható-e (water_damage_visible)';

END $$;
