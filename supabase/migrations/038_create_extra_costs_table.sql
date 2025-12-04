-- Migration: Create extra_costs table
-- Description: Catalog of extra costs/fees
-- Dependencies: 412_create_investments_table.sql

CREATE TABLE IF NOT EXISTS public.extra_costs (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    name character varying(255) NOT NULL,
    price numeric(10,2),
    persist_name character varying(255),
    description text,
    is_quantity_based boolean DEFAULT false,
    category character varying(100),
    name_translations jsonb,
    investment_id uuid,
    info_message_translations jsonb,
    is_default_selected boolean DEFAULT false,
    sequence integer,
    metadata jsonb
);

-- Add primary key constraint
ALTER TABLE ONLY public.extra_costs
    ADD CONSTRAINT extra_costs_pkey PRIMARY KEY (id);

-- Add unique constraint
ALTER TABLE ONLY public.extra_costs
    ADD CONSTRAINT extra_costs_persist_name_key UNIQUE (persist_name);

-- Add foreign key constraints
ALTER TABLE ONLY public.extra_costs
    ADD CONSTRAINT extra_costs_investment_id_fkey FOREIGN KEY (investment_id) REFERENCES public.investments(id) ON DELETE CASCADE;

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_extra_costs_category ON public.extra_costs USING btree (category);
CREATE INDEX IF NOT EXISTS idx_extra_costs_investment_id ON public.extra_costs USING btree (investment_id);
CREATE INDEX IF NOT EXISTS idx_extra_costs_persist_name ON public.extra_costs USING btree (persist_name);
CREATE INDEX IF NOT EXISTS idx_extra_costs_sequence ON public.extra_costs USING btree (sequence);

-- Set table owner
ALTER TABLE public.extra_costs OWNER TO postgres;
