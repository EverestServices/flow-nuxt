-- Migration: Create documents table
-- Description: Structure definition for documents
-- Dependencies: 419_create_surveys_table.sql, 405_create_document_categories_table.sql

CREATE TABLE IF NOT EXISTS "public"."documents" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "survey_id" "uuid" NOT NULL,
    "document_category_id" "uuid" NOT NULL,
    "name" "text",
    "location" "text" NOT NULL
);

-- Add constraints
ALTER TABLE ONLY public.documents
    ADD CONSTRAINT documents_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.documents
    ADD CONSTRAINT documents_document_category_id_fkey FOREIGN KEY (document_category_id) REFERENCES public.document_categories(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.documents
    ADD CONSTRAINT documents_survey_id_fkey FOREIGN KEY (survey_id) REFERENCES public.surveys(id) ON DELETE CASCADE;

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_documents_category_id ON public.documents USING btree (document_category_id);
CREATE INDEX IF NOT EXISTS idx_documents_survey_id ON public.documents USING btree (survey_id);

-- Set table owner
ALTER TABLE public.documents OWNER TO postgres;
