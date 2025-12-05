-- Migration: Create survey_pages table
-- Description: Survey page templates/definitions
-- Dependencies: None (investment_id and parent_page_id are nullable)

CREATE TABLE IF NOT EXISTS public.survey_pages (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    name character varying(255) NOT NULL,
    position jsonb,
    type character varying(100),
    investment_id uuid,
    allow_multiple boolean DEFAULT false,
    allow_delete_first boolean DEFAULT false,
    item_name_template character varying(255),
    sequence integer,
    name_translations jsonb,
    item_name_template_translations jsonb,
    parent_page_id uuid,
    add_button_translations jsonb
);

-- Add primary key constraint
ALTER TABLE ONLY public.survey_pages
    ADD CONSTRAINT survey_pages_pkey PRIMARY KEY (id);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_survey_pages_parent_page_id ON public.survey_pages USING btree (parent_page_id) WHERE (parent_page_id IS NOT NULL);

-- Set table owner
ALTER TABLE public.survey_pages OWNER TO postgres;

-- Note: Foreign key for parent_page_id (self-reference) will be added after all rows are inserted
-- Note: Foreign key for investment_id will be added in later migration when investments table exists
