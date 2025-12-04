-- Migration: Create main_component_categories table
-- Description: Catalog table for main component categories
-- Dependencies: None

CREATE TABLE IF NOT EXISTS public.main_component_categories (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    persist_name character varying(100) NOT NULL,
    sequence integer,
    name_translations jsonb DEFAULT '{}'::jsonb,
    visibility jsonb
);

-- Add primary key constraint
ALTER TABLE ONLY public.main_component_categories
    ADD CONSTRAINT main_component_categories_pkey PRIMARY KEY (id);

-- Add unique constraint
ALTER TABLE ONLY public.main_component_categories
    ADD CONSTRAINT main_component_categories_persist_name_key UNIQUE (persist_name);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_main_component_categories_persist_name ON public.main_component_categories USING btree (persist_name);
CREATE INDEX IF NOT EXISTS idx_main_component_categories_sequence ON public.main_component_categories USING btree (sequence);
CREATE INDEX IF NOT EXISTS idx_main_component_categories_name_translations ON public.main_component_categories USING gin (name_translations);

-- Set table owner
ALTER TABLE public.main_component_categories OWNER TO postgres;
