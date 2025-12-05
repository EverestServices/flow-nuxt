-- Migration: Add special questions for Heat Pump
-- Description: Creates questions using repeatable_field, multiselect_with_distribution, and drawing_area types

DO $$
DECLARE
    page_heat_pump_data_id UUID;
BEGIN
    -- Get the Heat Pump Data page ID
    SELECT sp.id INTO page_heat_pump_data_id
    FROM public.survey_pages sp
    JOIN public.investments i ON sp.investment_id = i.id
    WHERE i.persist_name = 'heatPump'
      AND sp.type = 'heat_pump_data';

    IF page_heat_pump_data_id IS NULL THEN
        RAISE EXCEPTION 'Heat Pump Data page not found';
    END IF;

    -- ========================================================================
    -- Add wall breakthroughs question (repeatable_field)
    -- ========================================================================

    -- This will be rendered as a card with "+ Fal hozzáadása" button
    -- Each item will have "Fal szélessége (cm)" number input
    INSERT INTO public.survey_questions (
        survey_page_id,
        name,
        name_translations,
        type,
        is_required,
        options,
        sequence
    ) VALUES (
        page_heat_pump_data_id,
        'wall_breakthroughs',
        jsonb_build_object(
            'hu', 'Faláttörések',
            'en', 'Wall Breakthroughs'
        ),
        'repeatable_field',
        false,
        jsonb_build_object(
            'add_button_text', jsonb_build_object(
                'hu', 'Fal hozzáadása',
                'en', 'Add Wall'
            ),
            'item_field', jsonb_build_object(
                'name', 'wall_width',
                'label', jsonb_build_object(
                    'hu', 'Fal szélessége (cm)',
                    'en', 'Wall Width (cm)'
                ),
                'type', 'number',
                'unit', jsonb_build_object('hu', 'cm', 'en', 'cm')
            )
        ),
        21  -- After "Faláttörések" title
    );

    -- ========================================================================
    -- Add heat emitter distribution question (multiselect_with_distribution)
    -- ========================================================================

    -- This question will show a row for each selected option from "current_heat_emitter_circuits"
    -- Each row will have:
    -- - Label (the option label)
    -- - Slider (0-100%)
    -- - "Előremenő hőmérséklet (C°)" number field
    -- The sum of all sliders cannot exceed 100%

    INSERT INTO public.survey_questions (
        survey_page_id,
        name,
        name_translations,
        type,
        is_required,
        options,
        display_conditions,
        sequence
    ) VALUES (
        page_heat_pump_data_id,
        'heat_emitter_distribution',
        jsonb_build_object(
            'hu', 'Hőleadó körök megoszlása és hőmérséklete',
            'en', 'Heat Emitter Circuits Distribution and Temperature'
        ),
        'multiselect_with_distribution',
        false,
        jsonb_build_object(
            'source_field', 'current_heat_emitter_circuits',
            'fields', jsonb_build_array(
                -- Distribution/percentage field
                jsonb_build_object(
                    'name', 'distribution',
                    'label', jsonb_build_object(
                        'hu', 'Megoszlás',
                        'en', 'Distribution'
                    ),
                    'type', 'slider',
                    'min', 0,
                    'max', 100,
                    'step', 1,
                    'unit', jsonb_build_object('hu', '%', 'en', '%'),
                    'grid_width', '1fr'
                ),
                -- Temperature field
                jsonb_build_object(
                    'name', 'forward_temperature',
                    'label', jsonb_build_object(
                        'hu', 'Előremenő hőmérséklet',
                        'en', 'Forward Temperature'
                    ),
                    'type', 'number',
                    'min', 0,
                    'max', 100,
                    'unit', jsonb_build_object('hu', 'C°', 'en', 'C°'),
                    'grid_width', '150px'
                )
            ),
            'label_grid_width', '150px',
            'max_total_percentage', 100,
            'validation_message', jsonb_build_object(
                'hu', 'A megoszlások összege nem haladhatja meg a 100%-ot (jelenleg: {total}%)',
                'en', 'The sum of distributions cannot exceed 100% (currently: {total}%)'
            ),
            'empty_message', jsonb_build_object(
                'hu', 'Először válassz ki hőleadó köröket',
                'en', 'Please select heat emitter circuits first'
            )
        ),
        jsonb_build_object(
            'field', 'current_heat_emitter_circuits',
            'operator', 'not_equals',
            'value', null
        ),
        8  -- After "Jelenlegi hőleadó kör pontos típusa"
    );

    -- ========================================================================
    -- Add drawing area question
    -- ========================================================================

    INSERT INTO public.survey_questions (
        survey_page_id,
        name,
        name_translations,
        type,
        is_required,
        options,
        sequence
    ) VALUES (
        page_heat_pump_data_id,
        'site_plan_drawing',
        jsonb_build_object(
            'hu', 'Felülnézeti helyszínrajz',
            'en', 'Top View Site Plan'
        ),
        'drawing_area',
        false,
        jsonb_build_object(
            'button_text', jsonb_build_object(
                'hu', 'Rajzolás megnyitása',
                'en', 'Open Drawing'
            ),
            'canvas_width', 800,
            'canvas_height', 600,
            'tools', jsonb_build_array('pen', 'line', 'rectangle', 'circle', 'text', 'eraser')
        ),
        23  -- Last question
    );

    RAISE NOTICE '========================================';
    RAISE NOTICE 'Added special question types for Heat Pump';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'Added repeatable_field for wall breakthroughs';
    RAISE NOTICE 'Added multiselect_with_distribution for heat emitter circuits';
    RAISE NOTICE 'Added drawing_area for site plan';

END $$;
