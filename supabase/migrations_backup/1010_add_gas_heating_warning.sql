-- ============================================================================
-- Migration: Add Gas Heating Methods Warning
-- Description: Adds a warning question that appears when gas-based heating methods are selected
-- ============================================================================

DO $$
DECLARE
    page_basic_data_id UUID;
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
    -- Add Gas Heating Methods Warning
    -- ========================================================================

    INSERT INTO public.survey_questions (
        survey_page_id,
        name,
        name_translations,
        type,
        is_required,
        sequence,
        display_conditions,
        template_variables
    ) VALUES (
        page_basic_data_id,
        'gas_heating_methods_warning',
        jsonb_build_object(
            'hu', '💡 Az alábbi kérdések a kiválasztott fűtési módok miatt jelennek meg: {selectedGasHeatingMethods}',
            'en', '💡 The following questions appear due to the selected heating methods: {selectedGasHeatingMethods}'
        ),
        'warning',
        false,
        17,
        jsonb_build_object(
            'field', 'heating_methods',
            'operator', 'contains_any',
            'value', jsonb_build_array(
                'Állandó hőmérsékletű kazán (hagyományos gázkazán radiátoros fűtéshez, általában pincében vagy fürdőszobában elhelyezve)',
                'Alacsony hőmérsékletű kazán (modern gázkazán padlófűtéshez optimalizálva, alacsonyabb hőmérsékleten üzemel)',
                'Kondenzációs kazán (legkorszerűbb, energiatakarékos gázkazán kondenzációs technológiával)',
                'Hagyományos gázkonvektor (falra szerelt, egyedi szobafűtés gázzal működtetve)',
                'Nyílt égésterű gravitációs gázkonvektor (régebbi típusú fali gázfűtés, kéménybe kötött, természetes légáramlással)',
                'Külsőfali gázkonvektor (falra szerelt, külső falon át levegőt vevő egyedi fűtés)'
            )
        ),
        jsonb_build_object(
            'selectedGasHeatingMethods', jsonb_build_object(
                'type', 'matched_conditional_values',
                'field', 'heating_methods'
            )
        )
    );

    RAISE NOTICE 'Successfully added gas_heating_methods_warning question';

END $$;
