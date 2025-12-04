-- Migration: Create survey_survey_pages table
-- Description: Structure definition for survey_survey_pages
-- Dependencies: 419_create_surveys_table.sql, 407_create_survey_pages_table.sql

CREATE TABLE IF NOT EXISTS "public"."survey_survey_pages" (
    "survey_id" "uuid" NOT NULL,
    "survey_page_id" "uuid" NOT NULL,
    "position" integer NOT NULL
);

-- Add constraints
ALTER TABLE ONLY public.survey_survey_pages
    ADD CONSTRAINT survey_survey_pages_pkey PRIMARY KEY (survey_id, survey_page_id);

ALTER TABLE ONLY public.survey_survey_pages
    ADD CONSTRAINT survey_survey_pages_survey_id_fkey FOREIGN KEY (survey_id) REFERENCES public.surveys(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.survey_survey_pages
    ADD CONSTRAINT survey_survey_pages_survey_page_id_fkey FOREIGN KEY (survey_page_id) REFERENCES public.survey_pages(id) ON DELETE CASCADE;

-- Set table owner
ALTER TABLE public.survey_survey_pages OWNER TO postgres;
