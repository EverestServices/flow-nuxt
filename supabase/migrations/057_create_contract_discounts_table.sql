-- Migration: Create contract_discounts table
-- Description: Structure definition for contract_discounts
-- Dependencies: 427_create_contracts_table.sql, 402_create_discounts_table.sql

CREATE TABLE IF NOT EXISTS "public"."contract_discounts" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "contract_id" "uuid" NOT NULL,
    "discount_id" "uuid" NOT NULL,
    "discount_snapshot" numeric(12,2) NOT NULL
);

-- Add constraints
ALTER TABLE ONLY public.contract_discounts
    ADD CONSTRAINT contract_discounts_contract_id_discount_id_key UNIQUE (contract_id, discount_id);

ALTER TABLE ONLY public.contract_discounts
    ADD CONSTRAINT contract_discounts_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.contract_discounts
    ADD CONSTRAINT contract_discounts_contract_id_fkey FOREIGN KEY (contract_id) REFERENCES public.contracts(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.contract_discounts
    ADD CONSTRAINT contract_discounts_discount_id_fkey FOREIGN KEY (discount_id) REFERENCES public.discounts(id) ON DELETE CASCADE;

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_contract_discounts_contract_id ON public.contract_discounts USING btree (contract_id);
CREATE INDEX IF NOT EXISTS idx_contract_discounts_discount_id ON public.contract_discounts USING btree (discount_id);

-- Set table owner
ALTER TABLE public.contract_discounts OWNER TO postgres;
