-- Migration: Create surveys table
-- Description: Structure definition for surveys
-- Dependencies: 410_create_clients_table.sql

CREATE TABLE IF NOT EXISTS "public"."surveys" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "client_id" "uuid" NOT NULL,
    "user_id" "uuid",
    "company_id" "uuid" NOT NULL,
    "at" timestamp with time zone,
    "consultation_system_design_open" boolean DEFAULT true,
    "consultation_panel_open" boolean DEFAULT false,
    "household_data" "jsonb",
    "consumption_profiles" "text"[],
    "first_opened_at" timestamp with time zone,
    "ofp_survey_id" "uuid",
    "ekr_survey_id" "uuid"
);

-- Add constraints
ALTER TABLE ONLY public.surveys
    ADD CONSTRAINT surveys_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.surveys
    ADD CONSTRAINT surveys_client_id_fkey FOREIGN KEY (client_id) REFERENCES public.clients(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.surveys
    ADD CONSTRAINT surveys_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE SET NULL;

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_surveys_client_id ON public.surveys USING btree (client_id);
CREATE INDEX IF NOT EXISTS idx_surveys_company_id ON public.surveys USING btree (company_id);
CREATE INDEX IF NOT EXISTS idx_surveys_ekr_survey_id ON public.surveys USING btree (ekr_survey_id) WHERE (ekr_survey_id IS NOT NULL);
CREATE UNIQUE INDEX IF NOT EXISTS idx_surveys_ekr_unique ON public.surveys USING btree (ekr_survey_id) WHERE (ekr_survey_id IS NOT NULL);
CREATE INDEX IF NOT EXISTS idx_surveys_first_opened_at ON public.surveys USING btree (first_opened_at);
CREATE INDEX IF NOT EXISTS idx_surveys_ofp_survey_id ON public.surveys USING btree (ofp_survey_id) WHERE (ofp_survey_id IS NOT NULL);
CREATE UNIQUE INDEX IF NOT EXISTS idx_surveys_ofp_unique ON public.surveys USING btree (ofp_survey_id) WHERE (ofp_survey_id IS NOT NULL);
CREATE INDEX IF NOT EXISTS idx_surveys_user_id ON public.surveys USING btree (user_id);

-- Set table owner
ALTER TABLE public.surveys OWNER TO postgres;
