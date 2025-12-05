-- Migration: Create scenario_main_components table
-- Description: Structure definition for scenario_main_components
-- Dependencies: 421_create_scenarios_table.sql, 411_create_main_components_table.sql

CREATE TABLE IF NOT EXISTS "public"."scenario_main_components" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "scenario_id" "uuid" NOT NULL,
    "main_component_id" "uuid" NOT NULL,
    "quantity" numeric(10,2) DEFAULT 1 NOT NULL,
    "price_snapshot" numeric(10,2) NOT NULL,
    "investment_id" "uuid"
);

-- Add constraints
ALTER TABLE ONLY public.scenario_main_components
    ADD CONSTRAINT scenario_main_components_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.scenario_main_components
    ADD CONSTRAINT scenario_main_components_unique_key UNIQUE (scenario_id, main_component_id, investment_id);

ALTER TABLE ONLY public.scenario_main_components
    ADD CONSTRAINT scenario_main_components_investment_id_fkey FOREIGN KEY (investment_id) REFERENCES public.investments(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.scenario_main_components
    ADD CONSTRAINT scenario_main_components_main_component_id_fkey FOREIGN KEY (main_component_id) REFERENCES public.main_components(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.scenario_main_components
    ADD CONSTRAINT scenario_main_components_scenario_id_fkey FOREIGN KEY (scenario_id) REFERENCES public.scenarios(id) ON DELETE CASCADE;

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_scenario_main_components_component_id ON public.scenario_main_components USING btree (main_component_id);
CREATE INDEX IF NOT EXISTS idx_scenario_main_components_investment_id ON public.scenario_main_components USING btree (investment_id);
CREATE INDEX IF NOT EXISTS idx_scenario_main_components_scenario_id ON public.scenario_main_components USING btree (scenario_id);

-- Set table owner
ALTER TABLE public.scenario_main_components OWNER TO postgres;
