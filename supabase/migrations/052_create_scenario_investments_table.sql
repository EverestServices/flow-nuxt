-- Migration: Create scenario_investments table
-- Description: Structure definition for scenario_investments
-- Dependencies: 421_create_scenarios_table.sql, 412_create_investments_table.sql

CREATE TABLE IF NOT EXISTS "public"."scenario_investments" (
    "scenario_id" "uuid" NOT NULL,
    "investment_id" "uuid" NOT NULL
);

-- Add constraints
ALTER TABLE ONLY public.scenario_investments
    ADD CONSTRAINT scenario_investments_pkey PRIMARY KEY (scenario_id, investment_id);

ALTER TABLE ONLY public.scenario_investments
    ADD CONSTRAINT scenario_investments_investment_id_fkey FOREIGN KEY (investment_id) REFERENCES public.investments(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.scenario_investments
    ADD CONSTRAINT scenario_investments_scenario_id_fkey FOREIGN KEY (scenario_id) REFERENCES public.scenarios(id) ON DELETE CASCADE;

-- Set table owner
ALTER TABLE public.scenario_investments OWNER TO postgres;
