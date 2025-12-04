-- Migration: Create survey_investments table
-- Description: Structure definition for survey_investments
-- Dependencies: 419_create_surveys_table.sql, 412_create_investments_table.sql

CREATE TABLE IF NOT EXISTS "public"."survey_investments" (
    "survey_id" "uuid" NOT NULL,
    "investment_id" "uuid" NOT NULL
);

-- Add constraints
ALTER TABLE ONLY public.survey_investments
    ADD CONSTRAINT survey_investments_pkey PRIMARY KEY (survey_id, investment_id);

ALTER TABLE ONLY public.survey_investments
    ADD CONSTRAINT survey_investments_investment_id_fkey FOREIGN KEY (investment_id) REFERENCES public.investments(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.survey_investments
    ADD CONSTRAINT survey_investments_survey_id_fkey FOREIGN KEY (survey_id) REFERENCES public.surveys(id) ON DELETE CASCADE;

-- Set table owner
ALTER TABLE public.survey_investments OWNER TO postgres;
