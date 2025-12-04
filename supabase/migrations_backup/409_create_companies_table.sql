-- Migration: Create companies table
-- Description: Base table for companies/organizations
-- Dependencies: None

CREATE TABLE IF NOT EXISTS public.companies (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    name text
);

-- Add primary key constraint
ALTER TABLE ONLY public.companies
    ADD CONSTRAINT companies_pkey PRIMARY KEY (id);

-- Set table owner
ALTER TABLE public.companies OWNER TO postgres;
