-- Migration: Create contract_investments table
-- Description: Structure definition for contract_investments
-- Dependencies: 427_create_contracts_table.sql, 412_create_investments_table.sql

CREATE TABLE IF NOT EXISTS "public"."contract_investments" (
    "contract_id" "uuid" NOT NULL,
    "investment_id" "uuid" NOT NULL
);

-- Add constraints
ALTER TABLE ONLY public.contract_investments
    ADD CONSTRAINT contract_investments_pkey PRIMARY KEY (contract_id, investment_id);

ALTER TABLE ONLY public.contract_investments
    ADD CONSTRAINT contract_investments_contract_id_fkey FOREIGN KEY (contract_id) REFERENCES public.contracts(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.contract_investments
    ADD CONSTRAINT contract_investments_investment_id_fkey FOREIGN KEY (investment_id) REFERENCES public.investments(id) ON DELETE CASCADE;

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_contract_investments_contract_id ON public.contract_investments USING btree (contract_id);
CREATE INDEX IF NOT EXISTS idx_contract_investments_investment_id ON public.contract_investments USING btree (investment_id);

-- Set table owner
ALTER TABLE public.contract_investments OWNER TO postgres;
