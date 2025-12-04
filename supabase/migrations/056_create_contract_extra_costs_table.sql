-- Migration: Create contract_extra_costs table
-- Description: Structure definition for contract_extra_costs
-- Dependencies: 427_create_contracts_table.sql, 413_create_extra_costs_table.sql

CREATE TABLE IF NOT EXISTS "public"."contract_extra_costs" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "contract_id" "uuid" NOT NULL,
    "extra_cost_id" "uuid" NOT NULL,
    "snapshot_price" numeric(12,2) NOT NULL,
    "quantity" numeric(10,2),
    "comment" "text"
);

-- Add constraints
ALTER TABLE ONLY public.contract_extra_costs
    ADD CONSTRAINT contract_extra_costs_contract_id_extra_cost_id_key UNIQUE (contract_id, extra_cost_id);

ALTER TABLE ONLY public.contract_extra_costs
    ADD CONSTRAINT contract_extra_costs_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.contract_extra_costs
    ADD CONSTRAINT contract_extra_costs_contract_id_fkey FOREIGN KEY (contract_id) REFERENCES public.contracts(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.contract_extra_costs
    ADD CONSTRAINT contract_extra_costs_extra_cost_id_fkey FOREIGN KEY (extra_cost_id) REFERENCES public.extra_costs(id) ON DELETE CASCADE;

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_contract_extra_costs_contract_id ON public.contract_extra_costs USING btree (contract_id);
CREATE INDEX IF NOT EXISTS idx_contract_extra_costs_extra_cost_id ON public.contract_extra_costs USING btree (extra_cost_id);

-- Set table owner
ALTER TABLE public.contract_extra_costs OWNER TO postgres;
