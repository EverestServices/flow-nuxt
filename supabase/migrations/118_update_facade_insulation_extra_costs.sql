-- ============================================================================
-- Migration: Update Facade Insulation Extra Costs
-- Description: Adds is_default_selected column and recreates extra costs
--              for Facade Insulation with updated list
-- ============================================================================

-- ============================================================================
-- STEP 1: Add is_default_selected column to extra_costs table
-- ============================================================================

ALTER TABLE public.extra_costs
ADD COLUMN IF NOT EXISTS is_default_selected BOOLEAN DEFAULT FALSE;

COMMENT ON COLUMN public.extra_costs.is_default_selected IS 'Whether this extra cost should be selected by default';

-- ============================================================================
-- STEP 2: Delete existing Facade Insulation extra costs
-- ============================================================================

DO $$
DECLARE
    inv_facade_insulation_id UUID;
BEGIN
    -- Get Facade Insulation investment ID
    SELECT id INTO inv_facade_insulation_id
    FROM public.investments
    WHERE persist_name = 'facadeInsulation';

    IF inv_facade_insulation_id IS NOT NULL THEN
        -- Delete existing extra costs for Facade Insulation
        DELETE FROM public.extra_costs
        WHERE investment_id = inv_facade_insulation_id;

        RAISE NOTICE 'Deleted existing extra costs for Facade Insulation';

        -- ========================================================================
        -- STEP 3: Create new extra costs in specified order
        -- ========================================================================

        -- 1. Állványozás
        INSERT INTO public.extra_costs (investment_id, name, name_translations, persist_name, price, is_quantity_based, category, is_default_selected) VALUES
        (inv_facade_insulation_id, 'Állványozás',
            jsonb_build_object('hu', 'Állványozás', 'en', 'Scaffolding'),
            'scaffolding_standard', 0, false, 'general', false);

        -- 2. Állványozás (Az ereszalj és a járda közötti távolság 3,5 métert meghaladja a falfelület valamelyik pontján)
        INSERT INTO public.extra_costs (investment_id, name, name_translations, persist_name, price, is_quantity_based, category, is_default_selected) VALUES
        (inv_facade_insulation_id, 'Állványozás (Az ereszalj és a járda közötti távolság 3,5 métert meghaladja a falfelület valamelyik pontján)',
            jsonb_build_object('hu', 'Állványozás (Az ereszalj és a járda közötti távolság 3,5 métert meghaladja a falfelület valamelyik pontján)', 'en', 'Scaffolding (distance between eaves and pavement exceeds 3.5 meters at any point)'),
            'scaffolding_extended', 0, false, 'general', false);

        -- 3. Antenna leszerelése
        INSERT INTO public.extra_costs (investment_id, name, name_translations, persist_name, price, is_quantity_based, category, is_default_selected) VALUES
        (inv_facade_insulation_id, 'Antenna leszerelése',
            jsonb_build_object('hu', 'Antenna leszerelése', 'en', 'Antenna dismantling'),
            'antenna_dismantling', 0, false, 'general', false);

        -- 4. Antenna felszerelése
        INSERT INTO public.extra_costs (investment_id, name, name_translations, persist_name, price, is_quantity_based, category, is_default_selected) VALUES
        (inv_facade_insulation_id, 'Antenna felszerelése',
            jsonb_build_object('hu', 'Antenna felszerelése', 'en', 'Antenna installation'),
            'antenna_installation', 0, false, 'general', false);

        -- 5. Ereszcsatorna roncsolásmentes bontása (default selected)
        INSERT INTO public.extra_costs (investment_id, name, name_translations, persist_name, price, is_quantity_based, category, is_default_selected) VALUES
        (inv_facade_insulation_id, 'Ereszcsatorna roncsolásmentes bontása',
            jsonb_build_object('hu', 'Ereszcsatorna roncsolásmentes bontása', 'en', 'Non-destructive gutter removal'),
            'gutter_removal', 0, false, 'general', true);

        -- 6. Ereszcsatorna visszaépítése
        INSERT INTO public.extra_costs (investment_id, name, name_translations, persist_name, price, is_quantity_based, category, is_default_selected) VALUES
        (inv_facade_insulation_id, 'Ereszcsatorna visszaépítése',
            jsonb_build_object('hu', 'Ereszcsatorna visszaépítése', 'en', 'Gutter reinstallation'),
            'gutter_reinstallation', 0, false, 'general', false);

        -- 7. Lefolyócső leszerelése
        INSERT INTO public.extra_costs (investment_id, name, name_translations, persist_name, price, is_quantity_based, category, is_default_selected) VALUES
        (inv_facade_insulation_id, 'Lefolyócső leszerelése',
            jsonb_build_object('hu', 'Lefolyócső leszerelése', 'en', 'Downpipe removal'),
            'downpipe_removal', 0, false, 'general', false);

        -- 8. Lefolyócső visszaszerelése
        INSERT INTO public.extra_costs (investment_id, name, name_translations, persist_name, price, is_quantity_based, category, is_default_selected) VALUES
        (inv_facade_insulation_id, 'Lefolyócső visszaszerelése',
            jsonb_build_object('hu', 'Lefolyócső visszaszerelése', 'en', 'Downpipe reinstallation'),
            'downpipe_reinstallation', 0, false, 'general', false);

        -- 9. Futónövényzet eltávolítása
        INSERT INTO public.extra_costs (investment_id, name, name_translations, persist_name, price, is_quantity_based, category, is_default_selected) VALUES
        (inv_facade_insulation_id, 'Futónövényzet eltávolítása',
            jsonb_build_object('hu', 'Futónövényzet eltávolítása', 'en', 'Climbing vegetation removal'),
            'vegetation_removal', 0, false, 'general', false);

        -- 10. Előtető bontása
        INSERT INTO public.extra_costs (investment_id, name, name_translations, persist_name, price, is_quantity_based, category, is_default_selected) VALUES
        (inv_facade_insulation_id, 'Előtető bontása',
            jsonb_build_object('hu', 'Előtető bontása', 'en', 'Canopy demolition'),
            'canopy_demolition', 0, false, 'general', false);

        -- 11. Előtető visszaépítése
        INSERT INTO public.extra_costs (investment_id, name, name_translations, persist_name, price, is_quantity_based, category, is_default_selected) VALUES
        (inv_facade_insulation_id, 'Előtető visszaépítése',
            jsonb_build_object('hu', 'Előtető visszaépítése', 'en', 'Canopy reconstruction'),
            'canopy_reconstruction', 0, false, 'general', false);

        -- 12. Légtechnikai kivezetés toldása
        INSERT INTO public.extra_costs (investment_id, name, name_translations, persist_name, price, is_quantity_based, category, is_default_selected) VALUES
        (inv_facade_insulation_id, 'Légtechnikai kivezetés toldása',
            jsonb_build_object('hu', 'Légtechnikai kivezetés toldása', 'en', 'Ventilation outlet extension'),
            'ventilation_extension', 0, false, 'general', false);

        -- 13. Lámpák le-, és felszerelése
        INSERT INTO public.extra_costs (investment_id, name, name_translations, persist_name, price, is_quantity_based, category, is_default_selected) VALUES
        (inv_facade_insulation_id, 'Lámpák le-, és felszerelése',
            jsonb_build_object('hu', 'Lámpák le-, és felszerelése', 'en', 'Lamp removal and installation'),
            'lamp_work', 0, false, 'general', false);

        -- 14. Kamera/riasztó végpontok le-, és felszerelése
        INSERT INTO public.extra_costs (investment_id, name, name_translations, persist_name, price, is_quantity_based, category, is_default_selected) VALUES
        (inv_facade_insulation_id, 'Kamera/riasztó végpontok le-, és felszerelése',
            jsonb_build_object('hu', 'Kamera/riasztó végpontok le-, és felszerelése', 'en', 'Camera/alarm endpoint work'),
            'security_work', 0, false, 'general', false);

        -- 15. Redőny roncsolásmentes bontása
        INSERT INTO public.extra_costs (investment_id, name, name_translations, persist_name, price, is_quantity_based, category, is_default_selected) VALUES
        (inv_facade_insulation_id, 'Redőny roncsolásmentes bontása',
            jsonb_build_object('hu', 'Redőny roncsolásmentes bontása', 'en', 'Non-destructive shutter removal'),
            'shutter_removal', 0, false, 'general', false);

        -- 16. Redőny visszaépítése
        INSERT INTO public.extra_costs (investment_id, name, name_translations, persist_name, price, is_quantity_based, category, is_default_selected) VALUES
        (inv_facade_insulation_id, 'Redőny visszaépítése',
            jsonb_build_object('hu', 'Redőny visszaépítése', 'en', 'Shutter reinstallation'),
            'shutter_reinstallation', 0, false, 'general', false);

        -- 17. Ablakrács leszerelése
        INSERT INTO public.extra_costs (investment_id, name, name_translations, persist_name, price, is_quantity_based, category, is_default_selected) VALUES
        (inv_facade_insulation_id, 'Ablakrács leszerelése',
            jsonb_build_object('hu', 'Ablakrács leszerelése', 'en', 'Window grill removal'),
            'window_grill_removal', 0, false, 'general', false);

        -- 18. Ablakrács visszaszerelése
        INSERT INTO public.extra_costs (investment_id, name, name_translations, persist_name, price, is_quantity_based, category, is_default_selected) VALUES
        (inv_facade_insulation_id, 'Ablakrács visszaszerelése',
            jsonb_build_object('hu', 'Ablakrács visszaszerelése', 'en', 'Window grill reinstallation'),
            'window_grill_reinstallation', 0, false, 'general', false);

        -- 19. Kő/beton párkány levésése
        INSERT INTO public.extra_costs (investment_id, name, name_translations, persist_name, price, is_quantity_based, category, is_default_selected) VALUES
        (inv_facade_insulation_id, 'Kő/beton párkány levésése',
            jsonb_build_object('hu', 'Kő/beton párkány levésése', 'en', 'Stone/concrete sill cutting'),
            'sill_cutting', 0, false, 'general', false);

        -- 20. Parapet kémények toldása
        INSERT INTO public.extra_costs (investment_id, name, name_translations, persist_name, price, is_quantity_based, category, is_default_selected) VALUES
        (inv_facade_insulation_id, 'Parapet kémények toldása',
            jsonb_build_object('hu', 'Parapet kémények toldása', 'en', 'Parapet chimney extension'),
            'chimney_extension', 0, false, 'general', false);

        -- 21. Klíma/hőszivattyú kültéri le-, és felszerelése
        INSERT INTO public.extra_costs (investment_id, name, name_translations, persist_name, price, is_quantity_based, category, is_default_selected) VALUES
        (inv_facade_insulation_id, 'Klíma/hőszivattyú kültéri le-, és felszerelése',
            jsonb_build_object('hu', 'Klíma/hőszivattyú kültéri le-, és felszerelése', 'en', 'AC/heat pump outdoor unit work'),
            'ac_unit_work', 0, false, 'general', false);

        -- 22. Gázcső eldobozolása
        INSERT INTO public.extra_costs (investment_id, name, name_translations, persist_name, price, is_quantity_based, category, is_default_selected) VALUES
        (inv_facade_insulation_id, 'Gázcső eldobozolása',
            jsonb_build_object('hu', 'Gázcső eldobozolása', 'en', 'Gas pipe boxing'),
            'gas_pipe_boxing', 0, false, 'general', false);

        -- 23. Gázcső kiemelése
        INSERT INTO public.extra_costs (investment_id, name, name_translations, persist_name, price, is_quantity_based, category, is_default_selected) VALUES
        (inv_facade_insulation_id, 'Gázcső kiemelése',
            jsonb_build_object('hu', 'Gázcső kiemelése', 'en', 'Gas pipe lifting'),
            'gas_pipe_lifting', 0, false, 'general', false);

        -- 24. Gázóra le-, és felszerelése
        INSERT INTO public.extra_costs (investment_id, name, name_translations, persist_name, price, is_quantity_based, category, is_default_selected) VALUES
        (inv_facade_insulation_id, 'Gázóra le-, és felszerelése',
            jsonb_build_object('hu', 'Gázóra le-, és felszerelése', 'en', 'Gas meter work'),
            'gas_meter_work', 0, false, 'general', false);

        -- 25. Villanyóra le-, és felszerelése
        INSERT INTO public.extra_costs (investment_id, name, name_translations, persist_name, price, is_quantity_based, category, is_default_selected) VALUES
        (inv_facade_insulation_id, 'Villanyóra le-, és felszerelése',
            jsonb_build_object('hu', 'Villanyóra le-, és felszerelése', 'en', 'Electric meter work'),
            'electric_meter_work', 0, false, 'general', false);

        -- 26. Korlát roncsolásmentes bontása
        INSERT INTO public.extra_costs (investment_id, name, name_translations, persist_name, price, is_quantity_based, category, is_default_selected) VALUES
        (inv_facade_insulation_id, 'Korlát roncsolásmentes bontása',
            jsonb_build_object('hu', 'Korlát roncsolásmentes bontása', 'en', 'Non-destructive railing removal'),
            'railing_removal', 0, false, 'general', false);

        -- 27. Korlát visszaépítése
        INSERT INTO public.extra_costs (investment_id, name, name_translations, persist_name, price, is_quantity_based, category, is_default_selected) VALUES
        (inv_facade_insulation_id, 'Korlát visszaépítése',
            jsonb_build_object('hu', 'Korlát visszaépítése', 'en', 'Railing reinstallation'),
            'railing_reinstallation', 0, false, 'general', false);

        -- 28. Durva struktúrájú lábazat kiegyenlítése
        INSERT INTO public.extra_costs (investment_id, name, name_translations, persist_name, price, is_quantity_based, category, is_default_selected) VALUES
        (inv_facade_insulation_id, 'Durva struktúrájú lábazat kiegyenlítése',
            jsonb_build_object('hu', 'Durva struktúrájú lábazat kiegyenlítése', 'en', 'Rough plinth leveling'),
            'plinth_leveling', 0, false, 'general', false);

        RAISE NOTICE 'Successfully created 28 new extra costs for Facade Insulation';
        RAISE NOTICE 'Note: "Ereszcsatorna roncsolásmentes bontása" is set as default selected';
    ELSE
        RAISE WARNING 'Facade Insulation investment not found (persist_name: facadeInsulation)';
    END IF;

END $$;
