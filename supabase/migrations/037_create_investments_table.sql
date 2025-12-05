-- Migration: Create investments table
-- Description: Catalog of investment types/categories
-- Dependencies: None

CREATE TABLE IF NOT EXISTS public.investments (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    name character varying(255) NOT NULL,
    icon character varying(100),
    position jsonb,
    sequence integer NOT NULL,
    persist_name character varying(100),
    energy_efficiency_improvement numeric(5,4) DEFAULT 0,
    name_translations jsonb,
    is_default boolean DEFAULT false
);

-- Add primary key constraint
ALTER TABLE ONLY public.investments
    ADD CONSTRAINT investments_pkey PRIMARY KEY (id);

-- Add unique constraints
ALTER TABLE ONLY public.investments
    ADD CONSTRAINT investments_persist_name_key UNIQUE (persist_name);

ALTER TABLE ONLY public.investments
    ADD CONSTRAINT investments_sequence_unique UNIQUE (sequence);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_investments_persist_name ON public.investments USING btree (persist_name);
CREATE INDEX IF NOT EXISTS idx_investments_sequence ON public.investments USING btree (sequence);

-- Set table owner
ALTER TABLE public.investments OWNER TO postgres;
