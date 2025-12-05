-- Migration: Create survey_heavy_consumers table
-- Description: Structure definition for survey_heavy_consumers
-- Dependencies: 419_create_surveys_table.sql, 400_create_heavy_consumers_table.sql

CREATE TABLE IF NOT EXISTS "public"."survey_heavy_consumers" (
    "survey_id" "uuid" NOT NULL,
    "heavy_consumer_id" "uuid" NOT NULL,
    "status" "public"."heavy_consumer_status" NOT NULL
);

-- Add constraints
ALTER TABLE ONLY public.survey_heavy_consumers
    ADD CONSTRAINT survey_heavy_consumers_pkey PRIMARY KEY (survey_id, heavy_consumer_id);

ALTER TABLE ONLY public.survey_heavy_consumers
    ADD CONSTRAINT survey_heavy_consumers_heavy_consumer_id_fkey FOREIGN KEY (heavy_consumer_id) REFERENCES public.heavy_consumers(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.survey_heavy_consumers
    ADD CONSTRAINT survey_heavy_consumers_survey_id_fkey FOREIGN KEY (survey_id) REFERENCES public.surveys(id) ON DELETE CASCADE;

-- Set table owner
ALTER TABLE public.survey_heavy_consumers OWNER TO postgres;
