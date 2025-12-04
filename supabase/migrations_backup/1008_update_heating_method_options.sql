-- ============================================================================
-- Migration: Update Heating Method Options
-- Description: Updates the heating_methods question options to the new 19-item list
--              and updates heating_device_other_use_gas display conditions
-- ============================================================================

DO $$
DECLARE
    question_heating_methods_id UUID;
    question_heating_device_other_use_gas_id UUID;
    question_heating_device_location_id UUID;
BEGIN
    -- ========================================================================
    -- 1. Update heating_methods question options
    -- ========================================================================

    -- Get the heating_methods question ID
    SELECT id INTO question_heating_methods_id
    FROM public.survey_questions
    WHERE name = 'heating_methods';

    IF question_heating_methods_id IS NULL THEN
        RAISE EXCEPTION 'heating_methods question not found';
    END IF;

    -- Update the options array with the new 19 items
    UPDATE public.survey_questions
    SET options = jsonb_build_array(
        'Állandó hőmérsékletű kazán (hagyományos gázkazán radiátoros fűtéshez, általában pincében vagy fürdőszobában elhelyezve)',
        'Alacsony hőmérsékletű kazán (modern gázkazán padlófűtéshez optimalizálva, alacsonyabb hőmérsékleten üzemel)',
        'Kondenzációs kazán (legkorszerűbb, energiatakarékos gázkazán kondenzációs technológiával)',
        'Hagyományos gázkonvektor (falra szerelt, egyedi szobafűtés gázzal működtetve)',
        'Nyílt égésterű gravitációs gázkonvektor (régebbi típusú fali gázfűtés, kéménybe kötött, természetes légáramlással)',
        'Külsőfali gázkonvektor (falra szerelt, külső falon át levegőt vevő egyedi fűtés)',
        'Elektromos hősugárzó / fűtőfólia (infrapanel, fűtőfilm vagy elektromos radiátor, falra vagy mennyezetre szerelt)',
        'Elektromos kazán (központi fűtőrendszer elektromos energiával működő kazánnal)',
        'Vezérelt/Éjszakai elektromos hőtárolós kályha (éjszakai kedvezményes árammal töltődő, hőtároló kályha)',
        'Nappali elektromos hőtárolós kályha (folyamatosan használható elektromos hőtároló rendszer)',
        'Fatüzelésű cserépkályha (hagyományos, tégla vagy cserép burkolatú, fával fűtött kályha)',
        'Kandalló zárt égésterű (modern kandallóbetét üvegajtóval, hatékony fatüzelés)',
        'Egyedi fűtés kályhával (szabadon álló kályha különböző tüzelőanyagokkal)',
        'Kandalló nyitott égésterű (hagyományos, nyílt tüzű kandalló, díszítési céllal is)',
        'Vegyes tüzelésű kazán (többféle szilárd tüzelőanyaggal üzemeltethető kazán)',
        'Tűzifa (hasábfa) kazán (kizárólag hasábfával fűtött kazán)',
        'Pellettüzelésű kazán (fa pellettel automatikusan adagolt kazán)',
        'Faelgázosító kazán (korszerű, hatékony fatüzelésű kazán gázosító technológiával)',
        'Távhő / Származtatott hő (központi kazánházból szolgáltatott hő, mérőórával mért fogyasztás)'
    )
    WHERE id = question_heating_methods_id;

    RAISE NOTICE 'Updated heating_methods options to 19 items';

    -- ========================================================================
    -- 2. Update heating_device_other_use_gas display conditions
    -- ========================================================================

    -- Get the heating_device_other_use_gas question ID
    SELECT id INTO question_heating_device_other_use_gas_id
    FROM public.survey_questions
    WHERE name = 'heating_device_other_use_gas';

    IF question_heating_device_other_use_gas_id IS NULL THEN
        RAISE EXCEPTION 'heating_device_other_use_gas question not found';
    END IF;

    -- Update display conditions with the new gas-based heating methods
    UPDATE public.survey_questions
    SET display_conditions = jsonb_build_object(
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
    )
    WHERE id = question_heating_device_other_use_gas_id;

    RAISE NOTICE 'Updated heating_device_other_use_gas display conditions';

    -- ========================================================================
    -- 3. Update heating_device_location display conditions (same gas-based list)
    -- ========================================================================

    -- Get the heating_device_location question ID
    SELECT id INTO question_heating_device_location_id
    FROM public.survey_questions
    WHERE name = 'heating_device_location';

    IF question_heating_device_location_id IS NULL THEN
        RAISE EXCEPTION 'heating_device_location question not found';
    END IF;

    -- Update display conditions with the new gas-based heating methods
    UPDATE public.survey_questions
    SET display_conditions = jsonb_build_object(
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
    )
    WHERE id = question_heating_device_location_id;

    RAISE NOTICE 'Updated heating_device_location display conditions';

    -- ========================================================================
    -- 4. Update wood fuel related questions display conditions
    -- ========================================================================

    -- Update all wood/solid fuel questions with the updated list
    UPDATE public.survey_questions
    SET display_conditions = jsonb_build_object(
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
    WHERE name IN ('wood_fuel_consumption_period', 'wood_fuel_consumption_unit', 'wood_fuel_consumption_amount');

    RAISE NOTICE 'Updated wood fuel questions display conditions';

    RAISE NOTICE 'Successfully updated all heating method related questions';

END $$;
