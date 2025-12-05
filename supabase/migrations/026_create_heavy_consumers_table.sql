-- Migration: Create heavy_consumers table
-- Description: Reference table for heavy consumer appliances
-- Dependencies: None

CREATE TABLE IF NOT EXISTS public.heavy_consumers (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    name character varying(255) NOT NULL,
    icon character varying(50),
    sequence integer,
    name_translations jsonb
);

-- Add primary key constraint
ALTER TABLE ONLY public.heavy_consumers
    ADD CONSTRAINT heavy_consumers_pkey PRIMARY KEY (id);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_heavy_consumers_sequence ON public.heavy_consumers USING btree (sequence);

-- Set table owner
ALTER TABLE public.heavy_consumers OWNER TO postgres;
