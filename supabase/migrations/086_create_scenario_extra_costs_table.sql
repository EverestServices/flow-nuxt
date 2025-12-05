-- Migration: Create scenario_extra_costs table
-- Description: Structure definition for scenario_extra_costs (pivot table for scenarios and extra costs)
-- Dependencies: 045_create_scenarios_table.sql, 038_create_extra_costs_table.sql

CREATE TABLE IF NOT EXISTS "public"."scenario_extra_costs" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "scenario_id" "uuid" NOT NULL,
    "extra_cost_id" "uuid" NOT NULL,
    "quantity" numeric(10,2) DEFAULT 1,
    "notes" "text"
);

-- Add constraints
ALTER TABLE ONLY public.scenario_extra_costs
    ADD CONSTRAINT scenario_extra_costs_scenario_id_extra_cost_id_key UNIQUE (scenario_id, extra_cost_id);

ALTER TABLE ONLY public.scenario_extra_costs
    ADD CONSTRAINT scenario_extra_costs_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.scenario_extra_costs
    ADD CONSTRAINT scenario_extra_costs_scenario_id_fkey FOREIGN KEY (scenario_id) REFERENCES public.scenarios(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.scenario_extra_costs
    ADD CONSTRAINT scenario_extra_costs_extra_cost_id_fkey FOREIGN KEY (extra_cost_id) REFERENCES public.extra_costs(id) ON DELETE CASCADE;

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_scenario_extra_costs_scenario_id ON public.scenario_extra_costs USING btree (scenario_id);
CREATE INDEX IF NOT EXISTS idx_scenario_extra_costs_extra_cost_id ON public.scenario_extra_costs USING btree (extra_cost_id);

-- Set table owner
ALTER TABLE public.scenario_extra_costs OWNER TO postgres;
