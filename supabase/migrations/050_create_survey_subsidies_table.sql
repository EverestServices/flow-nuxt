-- Migration: Create survey_subsidies table
-- Description: Structure definition for survey_subsidies
-- Dependencies: 419_create_surveys_table.sql, 403_create_subsidies_table.sql

CREATE TABLE IF NOT EXISTS "public"."survey_subsidies" (
    "survey_id" "uuid" NOT NULL,
    "subsidy_id" "uuid" NOT NULL,
    "is_enabled" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);

-- Add constraints
ALTER TABLE ONLY public.survey_subsidies
    ADD CONSTRAINT survey_subsidies_pkey PRIMARY KEY (survey_id, subsidy_id);

ALTER TABLE ONLY public.survey_subsidies
    ADD CONSTRAINT survey_subsidies_subsidy_id_fkey FOREIGN KEY (subsidy_id) REFERENCES public.subsidies(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.survey_subsidies
    ADD CONSTRAINT survey_subsidies_survey_id_fkey FOREIGN KEY (survey_id) REFERENCES public.surveys(id) ON DELETE CASCADE;

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_survey_subsidies_enabled ON public.survey_subsidies USING btree (survey_id, is_enabled);
CREATE INDEX IF NOT EXISTS idx_survey_subsidies_survey_id ON public.survey_subsidies USING btree (survey_id);

-- Set table owner
ALTER TABLE public.survey_subsidies OWNER TO postgres;
