-- Migration: Create scenarios table
-- Description: Structure definition for scenarios
-- Dependencies: 419_create_surveys_table.sql

CREATE TABLE IF NOT EXISTS "public"."scenarios" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "survey_id" "uuid" NOT NULL,
    "name" character varying(255),
    "sequence" integer,
    "description" "text",
    "commission_rate" numeric(5,4) DEFAULT 0.12,
    "ofp_calculation" "jsonb"
);

-- Add constraints
ALTER TABLE ONLY public.scenarios
    ADD CONSTRAINT scenarios_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.scenarios
    ADD CONSTRAINT scenarios_survey_id_fkey FOREIGN KEY (survey_id) REFERENCES public.surveys(id) ON DELETE CASCADE;

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_scenarios_ofp_calculation ON public.scenarios USING gin (ofp_calculation) WHERE (ofp_calculation IS NOT NULL);
CREATE INDEX IF NOT EXISTS idx_scenarios_survey_id ON public.scenarios USING btree (survey_id);
CREATE INDEX IF NOT EXISTS idx_scenarios_survey_sequence ON public.scenarios USING btree (survey_id, sequence);

-- Set table owner
ALTER TABLE public.scenarios OWNER TO postgres;
