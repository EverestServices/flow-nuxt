-- Migration: Create scenario_discounts table
-- Description: Structure definition for scenario_discounts (pivot table for scenarios and discounts)
-- Dependencies: 045_create_scenarios_table.sql, 028_create_discounts_table.sql

CREATE TABLE IF NOT EXISTS "public"."scenario_discounts" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "scenario_id" "uuid" NOT NULL,
    "discount_id" "uuid" NOT NULL,
    "is_enabled" boolean DEFAULT true
);

-- Add constraints
ALTER TABLE ONLY public.scenario_discounts
    ADD CONSTRAINT scenario_discounts_scenario_id_discount_id_key UNIQUE (scenario_id, discount_id);

ALTER TABLE ONLY public.scenario_discounts
    ADD CONSTRAINT scenario_discounts_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.scenario_discounts
    ADD CONSTRAINT scenario_discounts_scenario_id_fkey FOREIGN KEY (scenario_id) REFERENCES public.scenarios(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.scenario_discounts
    ADD CONSTRAINT scenario_discounts_discount_id_fkey FOREIGN KEY (discount_id) REFERENCES public.discounts(id) ON DELETE CASCADE;

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_scenario_discounts_scenario_id ON public.scenario_discounts USING btree (scenario_id);
CREATE INDEX IF NOT EXISTS idx_scenario_discounts_discount_id ON public.scenario_discounts USING btree (discount_id);

-- Set table owner
ALTER TABLE public.scenario_discounts OWNER TO postgres;
