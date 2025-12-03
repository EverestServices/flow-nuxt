-- ============================================================================
-- Migration: Rename Survey Questions
-- Description: Updates Hungarian labels for 5 survey questions
-- ============================================================================

DO $$
BEGIN
    -- ========================================================================
    -- Update birth_date: Születési dátum -> Születési idő
    -- ========================================================================
    UPDATE public.survey_questions
    SET name_translations = jsonb_build_object(
        'hu', 'Születési idő',
        'en', 'Birth Date'
    )
    WHERE name = 'birth_date';

    -- ========================================================================
    -- Update is_residential_building: Lakóépület -> Lakóépület?
    -- ========================================================================
    UPDATE public.survey_questions
    SET name_translations = jsonb_build_object(
        'hu', 'Lakóépület?',
        'en', 'Residential Building'
    )
    WHERE name = 'is_residential_building';

    -- ========================================================================
    -- Update add_subsidy: Támogatás hozzáadása -> Támogatást igénybe vesz?
    -- ========================================================================
    UPDATE public.survey_questions
    SET name_translations = jsonb_build_object(
        'hu', 'Támogatást igénybe vesz?',
        'en', 'Add Subsidy'
    )
    WHERE name = 'add_subsidy';

    -- ========================================================================
    -- Update average_monthly_gross_income
    -- ========================================================================
    UPDATE public.survey_questions
    SET name_translations = jsonb_build_object(
        'hu', 'Kölcsönigénylő és Adóstársa együttes havi nettó jövedelme forintban',
        'en', 'Average Monthly Gross Income'
    )
    WHERE name = 'average_monthly_gross_income';

    -- ========================================================================
    -- Update number_residents
    -- ========================================================================
    UPDATE public.survey_questions
    SET name_translations = jsonb_build_object(
        'hu', 'Kölcsönigénylő és Adóstársa és a velük egy háztartásban élő gyermekek száma',
        'en', 'Number of Residents'
    )
    WHERE name = 'number_residents';

    RAISE NOTICE 'Updated 5 survey question labels';

END $$;

-- ============================================================================
-- END OF MIGRATION
-- ============================================================================
