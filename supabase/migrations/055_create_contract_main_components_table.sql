-- Migration: Create contract_main_components table
-- Description: Structure definition for contract_main_components
-- Dependencies: 427_create_contracts_table.sql, 411_create_main_components_table.sql

CREATE TABLE IF NOT EXISTS "public"."contract_main_components" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "contract_id" "uuid" NOT NULL,
    "main_component_id" "uuid" NOT NULL,
    "quantity" numeric(10,2) DEFAULT 1 NOT NULL,
    "price_snapshot" numeric(10,2) NOT NULL,
    "investment_id" "uuid"
);

-- Add constraints
ALTER TABLE ONLY public.contract_main_components
    ADD CONSTRAINT contract_main_components_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.contract_main_components
    ADD CONSTRAINT contract_main_components_unique_key UNIQUE (contract_id, main_component_id, investment_id);

ALTER TABLE ONLY public.contract_main_components
    ADD CONSTRAINT contract_main_components_contract_id_fkey FOREIGN KEY (contract_id) REFERENCES public.contracts(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.contract_main_components
    ADD CONSTRAINT contract_main_components_investment_id_fkey FOREIGN KEY (investment_id) REFERENCES public.investments(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.contract_main_components
    ADD CONSTRAINT contract_main_components_main_component_id_fkey FOREIGN KEY (main_component_id) REFERENCES public.main_components(id) ON DELETE CASCADE;

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_contract_main_components_component_id ON public.contract_main_components USING btree (main_component_id);
CREATE INDEX IF NOT EXISTS idx_contract_main_components_contract_id ON public.contract_main_components USING btree (contract_id);
CREATE INDEX IF NOT EXISTS idx_contract_main_components_investment_id ON public.contract_main_components USING btree (investment_id);

-- Set table owner
ALTER TABLE public.contract_main_components OWNER TO postgres;
