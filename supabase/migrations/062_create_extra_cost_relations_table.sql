-- Migration: Create extra_cost_relations table
-- Description: Structure definition for extra_cost_relations
-- Dependencies: 413_create_extra_costs_table.sql, 421_create_scenarios_table.sql, 427_create_contracts_table.sql

CREATE TABLE IF NOT EXISTS "public"."extra_cost_relations" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "extra_cost_id" "uuid" NOT NULL,
    "scenario_id" "uuid",
    "contract_id" "uuid",
    "snapshot_price" numeric(10,2),
    "quantity" integer,
    "comment" "text",
    CONSTRAINT "check_only_one_relation" CHECK (((("scenario_id" IS NOT NULL) AND ("contract_id" IS NULL)) OR (("scenario_id" IS NULL) AND ("contract_id" IS NOT NULL))))
);

-- Add constraints
ALTER TABLE ONLY public.extra_cost_relations
    ADD CONSTRAINT extra_cost_relations_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.extra_cost_relations
    ADD CONSTRAINT extra_cost_relations_contract_id_fkey FOREIGN KEY (contract_id) REFERENCES public.contracts(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.extra_cost_relations
    ADD CONSTRAINT extra_cost_relations_extra_cost_id_fkey FOREIGN KEY (extra_cost_id) REFERENCES public.extra_costs(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.extra_cost_relations
    ADD CONSTRAINT extra_cost_relations_scenario_id_fkey FOREIGN KEY (scenario_id) REFERENCES public.scenarios(id) ON DELETE CASCADE;

-- Set table owner
ALTER TABLE public.extra_cost_relations OWNER TO postgres;
