-- Migration: Create survey_settings table
-- Description: Global settings for survey system
-- Dependencies: None

CREATE TABLE IF NOT EXISTS public.survey_settings (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    persist_name character varying(100) NOT NULL,
    value text NOT NULL,
    description text
);

-- Add primary key constraint
ALTER TABLE ONLY public.survey_settings
    ADD CONSTRAINT survey_settings_pkey PRIMARY KEY (id);

-- Add unique constraint
ALTER TABLE ONLY public.survey_settings
    ADD CONSTRAINT survey_settings_persist_name_key UNIQUE (persist_name);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_survey_settings_persist_name ON public.survey_settings USING btree (persist_name);

-- Set table owner
ALTER TABLE public.survey_settings OWNER TO postgres;
