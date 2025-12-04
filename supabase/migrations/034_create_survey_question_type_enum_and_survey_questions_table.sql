-- Migration: Create survey_question_type ENUM and survey_questions table
-- Description: Survey question templates/definitions
-- Dependencies: survey_pages

-- Create ENUM type
CREATE TYPE public.survey_question_type AS ENUM (
    'text',
    'textarea',
    'switch',
    'dropdown',
    'title',
    'phase_toggle',
    'dual_toggle',
    'slider',
    'range',
    'number',
    'orientation_selector',
    'warning',
    'calculated',
    'multiselect',
    'icon_selector',
    'color_picker',
    'repeatable_field',
    'multiselect_with_distribution',
    'drawing_area'
);

ALTER TYPE public.survey_question_type OWNER TO postgres;

-- Create survey_questions table
CREATE TABLE IF NOT EXISTS public.survey_questions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    survey_page_id uuid NOT NULL,
    name character varying(255) NOT NULL,
    type public.survey_question_type NOT NULL,
    default_value text,
    placeholder_value character varying(500),
    options jsonb,
    is_required boolean DEFAULT false,
    is_special boolean DEFAULT false,
    info_message character varying(1000),
    min numeric(10,2),
    max numeric(10,2),
    step numeric(10,2),
    unit character varying(50),
    width integer,
    name_translations jsonb,
    placeholder_translations jsonb,
    unit_translations jsonb,
    info_message_translations jsonb,
    options_translations jsonb,
    display_conditions jsonb,
    default_value_source_question_id uuid,
    is_readonly boolean DEFAULT false,
    sequence integer,
    template_variables jsonb,
    shared_question_id uuid,
    is_shared_instance boolean DEFAULT false,
    display_settings jsonb,
    apply_template_to_placeholder boolean DEFAULT false,
    dynamic_range_rules jsonb,
    conditional_info_messages jsonb,
    CONSTRAINT chk_shared_instance_has_master CHECK (((is_shared_instance = false) OR ((is_shared_instance = true) AND (shared_question_id IS NOT NULL)))),
    CONSTRAINT chk_shared_question_not_self_reference CHECK (((shared_question_id IS NULL) OR (shared_question_id <> id)))
);

-- Add primary key constraint
ALTER TABLE ONLY public.survey_questions
    ADD CONSTRAINT survey_questions_pkey PRIMARY KEY (id);

-- Add foreign key constraints
ALTER TABLE ONLY public.survey_questions
    ADD CONSTRAINT survey_questions_survey_page_id_fkey FOREIGN KEY (survey_page_id) REFERENCES public.survey_pages(id) ON DELETE CASCADE;

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_survey_questions_page_id ON public.survey_questions USING btree (survey_page_id);
CREATE INDEX IF NOT EXISTS idx_survey_questions_default_source ON public.survey_questions USING btree (default_value_source_question_id) WHERE (default_value_source_question_id IS NOT NULL);
CREATE INDEX IF NOT EXISTS idx_survey_questions_shared_question_id ON public.survey_questions USING btree (shared_question_id) WHERE (shared_question_id IS NOT NULL);
CREATE INDEX IF NOT EXISTS idx_survey_questions_display_settings ON public.survey_questions USING gin (display_settings);

-- Set table owner
ALTER TABLE public.survey_questions OWNER TO postgres;

-- Note: Foreign keys for default_value_source_question_id and shared_question_id (self-references) will be added after all rows are inserted
