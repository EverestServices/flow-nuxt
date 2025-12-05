-- Migration: Create document_categories table
-- Description: Catalog table for document categories
-- Dependencies: None

CREATE TABLE IF NOT EXISTS public.document_categories (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    name character varying(255) NOT NULL,
    position jsonb,
    description text,
    min_photos integer,
    persist_name character varying(255),
    name_translations jsonb,
    description_translations jsonb
);

-- Add primary key constraint
ALTER TABLE ONLY public.document_categories
    ADD CONSTRAINT document_categories_pkey PRIMARY KEY (id);

-- Add unique constraint
ALTER TABLE ONLY public.document_categories
    ADD CONSTRAINT document_categories_persist_name_key UNIQUE (persist_name);

-- Set table owner
ALTER TABLE public.document_categories OWNER TO postgres;
