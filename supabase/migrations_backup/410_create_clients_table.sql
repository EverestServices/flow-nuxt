-- Migration: Create clients table
-- Description: Client/customer records (structure only, no data seeding)
-- Dependencies: 409_create_companies_table.sql

CREATE TABLE IF NOT EXISTS public.clients (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    company_id uuid NOT NULL,
    name character varying(255) NOT NULL,
    email character varying(255),
    phone character varying(50),
    contact_person character varying(255),
    notes text,
    status character varying(50) DEFAULT 'active'::character varying,
    user_id uuid,
    postal_code character varying(20),
    city character varying(100),
    street character varying(255),
    house_number character varying(50),
    ofp_client_id uuid,
    ekr_client_id uuid,
    CONSTRAINT clients_status_check CHECK ((status = ANY (ARRAY['active'::character varying, 'inactive'::character varying, 'archived'::character varying, 'prospect'::character varying]::text[])))
);

-- Add primary key constraint
ALTER TABLE ONLY public.clients
    ADD CONSTRAINT clients_pkey PRIMARY KEY (id);

-- Add foreign key constraints
ALTER TABLE ONLY public.clients
    ADD CONSTRAINT clients_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.companies(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.clients
    ADD CONSTRAINT clients_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE SET NULL;

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_clients_company_id ON public.clients USING btree (company_id);
CREATE INDEX IF NOT EXISTS idx_clients_ekr_client_id ON public.clients USING btree (ekr_client_id) WHERE (ekr_client_id IS NOT NULL);
CREATE UNIQUE INDEX IF NOT EXISTS idx_clients_ekr_unique ON public.clients USING btree (ekr_client_id) WHERE (ekr_client_id IS NOT NULL);
CREATE INDEX IF NOT EXISTS idx_clients_name ON public.clients USING btree (name);
CREATE INDEX IF NOT EXISTS idx_clients_ofp_client_id ON public.clients USING btree (ofp_client_id) WHERE (ofp_client_id IS NOT NULL);
CREATE UNIQUE INDEX IF NOT EXISTS idx_clients_ofp_unique ON public.clients USING btree (ofp_client_id) WHERE (ofp_client_id IS NOT NULL);
CREATE INDEX IF NOT EXISTS idx_clients_status ON public.clients USING btree (status);

-- Set table owner
ALTER TABLE public.clients OWNER TO postgres;
