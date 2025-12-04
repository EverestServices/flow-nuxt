-- Migration: Create main_component_category_investments table
-- Description: Structure definition for main_component_category_investments
-- Dependencies: 404_create_main_component_categories_table.sql, 412_create_investments_table.sql

CREATE TABLE IF NOT EXISTS "public"."main_component_category_investments" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "main_component_category_id" "uuid" NOT NULL,
    "investment_id" "uuid" NOT NULL,
    "sequence" integer NOT NULL
);

-- Add constraints
ALTER TABLE ONLY public.main_component_category_investments
    ADD CONSTRAINT main_component_category_inves_main_component_category_id_in_key UNIQUE (main_component_category_id, investment_id);

ALTER TABLE ONLY public.main_component_category_investments
    ADD CONSTRAINT main_component_category_investments_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.main_component_category_investments
    ADD CONSTRAINT main_component_category_investm_main_component_category_id_fkey FOREIGN KEY (main_component_category_id) REFERENCES public.main_component_categories(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.main_component_category_investments
    ADD CONSTRAINT main_component_category_investments_investment_id_fkey FOREIGN KEY (investment_id) REFERENCES public.investments(id) ON DELETE CASCADE;

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_mcc_investments_category_id ON public.main_component_category_investments USING btree (main_component_category_id);
CREATE INDEX IF NOT EXISTS idx_mcc_investments_investment_id ON public.main_component_category_investments USING btree (investment_id);
CREATE INDEX IF NOT EXISTS idx_mcc_investments_sequence ON public.main_component_category_investments USING btree (investment_id, sequence);

-- Set table owner
ALTER TABLE public.main_component_category_investments OWNER TO postgres;
