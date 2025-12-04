-- Migration: Create investment_document_categories table
-- Description: Structure definition for investment_document_categories
-- Dependencies: 412_create_investments_table.sql, 405_create_document_categories_table.sql

CREATE TABLE IF NOT EXISTS "public"."investment_document_categories" (
    "investment_id" "uuid" NOT NULL,
    "document_category_id" "uuid" NOT NULL,
    "position" integer NOT NULL
);

-- Add constraints
ALTER TABLE ONLY public.investment_document_categories
    ADD CONSTRAINT investment_document_categories_pkey PRIMARY KEY (investment_id, document_category_id);

ALTER TABLE ONLY public.investment_document_categories
    ADD CONSTRAINT investment_document_categories_document_category_id_fkey FOREIGN KEY (document_category_id) REFERENCES public.document_categories(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.investment_document_categories
    ADD CONSTRAINT investment_document_categories_investment_id_fkey FOREIGN KEY (investment_id) REFERENCES public.investments(id) ON DELETE CASCADE;

-- Set table owner
ALTER TABLE public.investment_document_categories OWNER TO postgres;
