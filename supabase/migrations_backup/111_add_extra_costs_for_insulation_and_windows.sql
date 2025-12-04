-- ============================================================================
-- Migration: Add Extra Costs for Insulation and Windows Investments
-- Description: Adds info_message_translations column and creates extra costs
--              for Facade Insulation, Attic Floor Insulation, and Windows investments
-- ============================================================================

-- ============================================================================
-- STEP 1: Add info_message_translations column to extra_costs table
-- ============================================================================

ALTER TABLE public.extra_costs
ADD COLUMN IF NOT EXISTS info_message_translations JSONB;

COMMENT ON COLUMN public.extra_costs.info_message_translations IS 'Multilingual info message for extra cost stored as JSONB: {"en": "Info text", "hu": "Információ szöveg"}';

-- ============================================================================
-- STEP 2: Create Extra Costs
-- ============================================================================

DO $$
DECLARE
    inv_facade_insulation_id UUID;
    inv_attic_floor_id UUID;
    inv_windows_id UUID;
BEGIN
    -- Get Investment IDs
    SELECT id INTO inv_facade_insulation_id FROM public.investments WHERE persist_name = 'facadeInsulation';
    SELECT id INTO inv_attic_floor_id FROM public.investments WHERE persist_name = 'roofInsulation';
    SELECT id INTO inv_windows_id FROM public.investments WHERE persist_name = 'windows';

    -- ========================================================================
    -- Extra Costs for Facade Insulation (Homlokzati szigetelés)
    -- ========================================================================

    IF inv_facade_insulation_id IS NOT NULL THEN
        RAISE NOTICE 'Creating extra costs for Facade Insulation (ID: %)', inv_facade_insulation_id;

        INSERT INTO public.extra_costs (investment_id, name, name_translations, persist_name, price, is_quantity_based, category) VALUES
        (inv_facade_insulation_id, 'Antenna leszerelése', jsonb_build_object('hu', 'Antenna leszerelése', 'en', 'Antenna dismantling'), 'antenna_dismantling', 0, false, 'general'),
        (inv_facade_insulation_id, 'Antenna felszerelése', jsonb_build_object('hu', 'Antenna felszerelése', 'en', 'Antenna installation'), 'antenna_installation', 0, false, 'general'),
        (inv_facade_insulation_id, 'Ereszcsatorna roncsolásmentes leszerelése', jsonb_build_object('hu', 'Ereszcsatorna roncsolásmentes leszerelése', 'en', 'Non-destructive gutter removal'), 'gutter_removal', 0, false, 'general'),
        (inv_facade_insulation_id, 'Ereszcsatorna felszerelése', jsonb_build_object('hu', 'Ereszcsatorna felszerelése', 'en', 'Gutter installation'), 'gutter_installation', 0, false, 'general'),
        (inv_facade_insulation_id, 'Ereszdobozolás bontása', jsonb_build_object('hu', 'Ereszdobozolás bontása', 'en', 'Eaves boxing removal'), 'eaves_boxing_removal', 0, false, 'general'),
        (inv_facade_insulation_id, 'Lefolyócső leszerelése', jsonb_build_object('hu', 'Lefolyócső leszerelése', 'en', 'Downpipe removal'), 'downpipe_removal', 0, false, 'general'),
        (inv_facade_insulation_id, 'Lefolyócső visszaszerelése', jsonb_build_object('hu', 'Lefolyócső visszaszerelése', 'en', 'Downpipe reinstallation'), 'downpipe_reinstallation', 0, false, 'general'),
        (inv_facade_insulation_id, 'Futónövényzet eltávolítása', jsonb_build_object('hu', 'Futónövényzet eltávolítása', 'en', 'Climbing vegetation removal'), 'vegetation_removal', 0, false, 'general'),
        (inv_facade_insulation_id, 'Előtető bontása', jsonb_build_object('hu', 'Előtető bontása', 'en', 'Canopy demolition'), 'canopy_demolition', 0, false, 'general'),
        (inv_facade_insulation_id, 'Előtető visszaépítése', jsonb_build_object('hu', 'Előtető visszaépítése', 'en', 'Canopy reconstruction'), 'canopy_reconstruction', 0, false, 'general'),
        (inv_facade_insulation_id, 'Légtechnikai kivezetés toldása', jsonb_build_object('hu', 'Légtechnikai kivezetés toldása', 'en', 'Ventilation outlet extension'), 'ventilation_extension', 0, false, 'general'),
        (inv_facade_insulation_id, 'Lámpák le-, és felszerelése', jsonb_build_object('hu', 'Lámpák le-, és felszerelése', 'en', 'Lamp removal and installation'), 'lamp_work', 0, false, 'general'),
        (inv_facade_insulation_id, 'Kamera/riasztó végpontok le-, és felszerelése', jsonb_build_object('hu', 'Kamera/riasztó végpontok le-, és felszerelése', 'en', 'Camera/alarm endpoint work'), 'security_work', 0, false, 'general'),
        (inv_facade_insulation_id, 'Redőny roncsolásmentes bontása', jsonb_build_object('hu', 'Redőny roncsolásmentes bontása', 'en', 'Non-destructive shutter removal'), 'shutter_removal', 0, false, 'general'),
        (inv_facade_insulation_id, 'Redőny visszaépítése', jsonb_build_object('hu', 'Redőny visszaépítése', 'en', 'Shutter reinstallation'), 'shutter_reinstallation', 0, false, 'general'),
        (inv_facade_insulation_id, 'Ablakrács leszerelése', jsonb_build_object('hu', 'Ablakrács leszerelése', 'en', 'Window grill removal'), 'window_grill_removal', 0, false, 'general'),
        (inv_facade_insulation_id, 'Ablakrács visszaszerelése', jsonb_build_object('hu', 'Ablakrács visszaszerelése', 'en', 'Window grill reinstallation'), 'window_grill_reinstallation', 0, false, 'general'),
        (inv_facade_insulation_id, 'Kő/beton párkány levésése', jsonb_build_object('hu', 'Kő/beton párkány levésése', 'en', 'Stone/concrete sill cutting'), 'sill_cutting', 0, false, 'general'),
        (inv_facade_insulation_id, 'Parapet kémények toldása', jsonb_build_object('hu', 'Parapet kémények toldása', 'en', 'Parapet chimney extension'), 'chimney_extension', 0, false, 'general'),
        (inv_facade_insulation_id, 'Homlokzati kémény található', jsonb_build_object('hu', 'Homlokzati kémény található', 'en', 'Facade chimney present'), 'facade_chimney', 0, false, 'general'),
        (inv_facade_insulation_id, 'Klíma/hőszivattyú kültéri le-, és felszerelése', jsonb_build_object('hu', 'Klíma/hőszivattyú kültéri le-, és felszerelése', 'en', 'AC/heat pump outdoor unit work'), 'ac_unit_work', 0, false, 'general'),
        (inv_facade_insulation_id, 'Gázcső eldobozolása', jsonb_build_object('hu', 'Gázcső eldobozolása', 'en', 'Gas pipe boxing'), 'gas_pipe_boxing', 0, false, 'general'),
        (inv_facade_insulation_id, 'Gázcső kiemelése', jsonb_build_object('hu', 'Gázcső kiemelése', 'en', 'Gas pipe lifting'), 'gas_pipe_lifting', 0, false, 'general'),
        (inv_facade_insulation_id, 'Gázóra le-, és felszerelése', jsonb_build_object('hu', 'Gázóra le-, és felszerelése', 'en', 'Gas meter work'), 'gas_meter_work', 0, false, 'general'),
        (inv_facade_insulation_id, 'Villanyóra le-, és felszerelése', jsonb_build_object('hu', 'Villanyóra le-, és felszerelése', 'en', 'Electric meter work'), 'electric_meter_work', 0, false, 'general'),
        (inv_facade_insulation_id, 'Korlát roncsolásmentes bontása', jsonb_build_object('hu', 'Korlát roncsolásmentes bontása', 'en', 'Non-destructive railing removal'), 'railing_removal', 0, false, 'general'),
        (inv_facade_insulation_id, 'Korlát visszaépítése', jsonb_build_object('hu', 'Korlát visszaépítése', 'en', 'Railing reinstallation'), 'railing_reinstallation', 0, false, 'general'),
        (inv_facade_insulation_id, 'Durva struktúrájú lábazat kiegyenlítése', jsonb_build_object('hu', 'Durva struktúrájú lábazat kiegyenlítése', 'en', 'Rough plinth leveling'), 'plinth_leveling', 0, false, 'general');

        RAISE NOTICE 'Created % extra costs for Facade Insulation', 28;
    ELSE
        RAISE WARNING 'Facade Insulation investment not found (persist_name: facadeInsulation)';
    END IF;

    -- ========================================================================
    -- Extra Costs for Attic Floor Insulation (Padlásfödém szigetelés)
    -- ========================================================================

    IF inv_attic_floor_id IS NOT NULL THEN
        RAISE NOTICE 'Creating extra costs for Attic Floor Insulation (ID: %)', inv_attic_floor_id;

        INSERT INTO public.extra_costs (investment_id, name, name_translations, persist_name, price, is_quantity_based, category, info_message_translations) VALUES
        (inv_attic_floor_id, 'Lomtalanítás', jsonb_build_object('hu', 'Lomtalanítás', 'en', 'Junk removal'), 'junk_removal', 0, false, 'general', NULL),
        (inv_attic_floor_id, 'Padláson tárolt dolgok le-, és felpakolása', jsonb_build_object('hu', 'Padláson tárolt dolgok le-, és felpakolása', 'en', 'Attic items packing and unpacking'), 'attic_items_packing', 0, false, 'general', NULL),
        (inv_attic_floor_id, 'Padlásfeljáró ajtó hőszigetelése', jsonb_build_object('hu', 'Padlásfeljáró ajtó hőszigetelése', 'en', 'Attic hatch insulation'), 'attic_hatch_insulation', 0, false, 'general', NULL),
        (inv_attic_floor_id, 'Párazáró fólia terítése', jsonb_build_object('hu', 'Párazáró fólia terítése', 'en', 'Vapor barrier installation'), 'vapor_barrier', 0, false, 'general',
            jsonb_build_object(
                'hu', 'Nem párazáró födémek esetén (minden födém kivéve > 20 cm vastag monolit vasbeton) párazáró fólia fektetése szükséges a hőszigetelés alá, hogy a szigetelés tetején nem csapódjon ki a nedvesség',
                'en', 'For non-vapor-resistant slabs (all slabs except > 20 cm thick monolithic reinforced concrete), a vapor barrier must be laid under the insulation to prevent moisture condensation on top of the insulation'
            )
        );

        RAISE NOTICE 'Created % extra costs for Attic Floor Insulation', 4;
    ELSE
        RAISE WARNING 'Attic Floor Insulation investment not found (persist_name: roofInsulation)';
    END IF;

    -- ========================================================================
    -- Extra Costs for Windows (Nyílászárók)
    -- ========================================================================

    IF inv_windows_id IS NOT NULL THEN
        RAISE NOTICE 'Creating extra costs for Windows (ID: %)', inv_windows_id;

        INSERT INTO public.extra_costs (investment_id, name, name_translations, persist_name, price, is_quantity_based, category) VALUES
        (inv_windows_id, 'Kiegészítő feladat hozzáadása', jsonb_build_object('hu', 'Kiegészítő feladat hozzáadása', 'en', 'Add supplementary task'), 'supplementary_task', 0, false, 'general'),
        (inv_windows_id, 'Biztonsági rács leszerelése', jsonb_build_object('hu', 'Biztonsági rács leszerelése', 'en', 'Security grill removal'), 'security_grill_removal', 0, false, 'general'),
        (inv_windows_id, 'Biztonsági rács visszaszerelése', jsonb_build_object('hu', 'Biztonsági rács visszaszerelése', 'en', 'Security grill reinstallation'), 'security_grill_reinstallation', 0, false, 'general'),
        (inv_windows_id, 'Meglévő redőny roncsolásmentes bontása, visszaépítése', jsonb_build_object('hu', 'Meglévő redőny roncsolásmentes bontása, visszaépítése', 'en', 'Existing shutter non-destructive removal and reinstallation'), 'existing_shutter_work', 0, false, 'general'),
        (inv_windows_id, 'Kávák levésése', jsonb_build_object('hu', 'Kávák levésése', 'en', 'Reveal cutting'), 'reveal_cutting', 0, false, 'general'),
        (inv_windows_id, 'Kő/beton párkány levésése', jsonb_build_object('hu', 'Kő/beton párkány levésése', 'en', 'Stone/concrete sill cutting'), 'sill_cutting_windows', 0, false, 'general'),
        (inv_windows_id, 'Utólagos áthidalás kialakítása', jsonb_build_object('hu', 'Utólagos áthidalás kialakítása', 'en', 'Post-installation lintel creation'), 'lintel_creation', 0, false, 'general'),
        (inv_windows_id, 'Kávák kőműves javítása', jsonb_build_object('hu', 'Kávák kőműves javítása', 'en', 'Reveal masonry repair'), 'reveal_masonry_repair', 0, false, 'general');

        RAISE NOTICE 'Created % extra costs for Windows', 8;
    ELSE
        RAISE WARNING 'Windows investment not found (persist_name: windows)';
    END IF;

    -- ========================================================================
    -- Summary
    -- ========================================================================

    RAISE NOTICE '========================================';
    RAISE NOTICE 'Successfully created extra costs for:';
    RAISE NOTICE '  - Facade Insulation: 28 items';
    RAISE NOTICE '  - Attic Floor Insulation: 4 items';
    RAISE NOTICE '  - Windows: 8 items';
    RAISE NOTICE 'Total: 40 new extra costs';
    RAISE NOTICE '========================================';

END $$;
