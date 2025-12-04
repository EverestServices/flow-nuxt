-- Migration: Create subsidies table
-- Description: Catalog table for subsidies/grants
-- Dependencies: None

CREATE TABLE IF NOT EXISTS public.subsidies (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    name text NOT NULL,
    description text,
    target_group text NOT NULL,
    discount_type text NOT NULL,
    discount_value numeric NOT NULL,
    sequence integer DEFAULT 0 NOT NULL,
    CONSTRAINT subsidies_discount_type_check CHECK ((discount_type = ANY (ARRAY['percentage'::text, 'fixed'::text]))),
    CONSTRAINT subsidies_discount_value_check CHECK ((discount_value >= 0::numeric))
);

-- Add primary key constraint
ALTER TABLE ONLY public.subsidies
    ADD CONSTRAINT subsidies_pkey PRIMARY KEY (id);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_subsidies_sequence ON public.subsidies USING btree (sequence);

-- Set table owner
ALTER TABLE public.subsidies OWNER TO postgres;
