-- Migration: Create main_components table
-- Description: Catalog of main components (products/materials)
-- Dependencies: 404_create_main_component_categories_table.sql

CREATE TABLE IF NOT EXISTS public.main_components (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    name character varying(255) NOT NULL,
    persist_name character varying(255),
    unit character varying(50) NOT NULL,
    price numeric(10,2) NOT NULL,
    main_component_category_id uuid NOT NULL,
    manufacturer character varying(255),
    details text,
    power numeric(10,2),
    capacity numeric(10,2),
    efficiency numeric(5,2),
    u_value numeric(5,2),
    thickness numeric(5,2),
    cop numeric(5,2),
    energy_class character varying(10),
    specifications jsonb,
    sequence integer,
    visibility jsonb
);

-- Add primary key constraint
ALTER TABLE ONLY public.main_components
    ADD CONSTRAINT main_components_pkey PRIMARY KEY (id);

-- Add unique constraint
ALTER TABLE ONLY public.main_components
    ADD CONSTRAINT main_components_persist_name_key UNIQUE (persist_name);

-- Add foreign key constraints
ALTER TABLE ONLY public.main_components
    ADD CONSTRAINT main_components_main_component_category_id_fkey FOREIGN KEY (main_component_category_id) REFERENCES public.main_component_categories(id) ON DELETE RESTRICT;

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_main_components_category_id ON public.main_components USING btree (main_component_category_id);
CREATE INDEX IF NOT EXISTS idx_main_components_persist_name ON public.main_components USING btree (persist_name);
CREATE INDEX IF NOT EXISTS idx_main_components_sequence ON public.main_components USING btree (main_component_category_id, sequence);

-- Set table owner
ALTER TABLE public.main_components OWNER TO postgres;
