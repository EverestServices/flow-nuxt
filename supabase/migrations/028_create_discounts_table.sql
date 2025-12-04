-- Migration: Create discounts table
-- Description: Catalog table for discounts (fixed, percentage, calculated)
-- Dependencies: None

CREATE TABLE IF NOT EXISTS public.discounts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    persist_name character varying(100) NOT NULL,
    name text NOT NULL,
    description text,
    discount_type character varying(50) NOT NULL,
    value numeric(12,2) DEFAULT 0,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT discounts_discount_type_check CHECK ((discount_type = ANY (ARRAY['fixed'::character varying, 'percentage'::character varying, 'calculated'::character varying]::text[])))
);

-- Add primary key constraint
ALTER TABLE ONLY public.discounts
    ADD CONSTRAINT discounts_pkey PRIMARY KEY (id);

-- Add unique constraint
ALTER TABLE ONLY public.discounts
    ADD CONSTRAINT discounts_persist_name_key UNIQUE (persist_name);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_discounts_persist_name ON public.discounts USING btree (persist_name);
CREATE INDEX IF NOT EXISTS idx_discounts_type ON public.discounts USING btree (discount_type);

-- Set table owner
ALTER TABLE public.discounts OWNER TO postgres;
