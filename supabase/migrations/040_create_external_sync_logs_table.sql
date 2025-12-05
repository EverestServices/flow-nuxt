-- Migration: Create external_sync_logs table with ENUM types
-- Description: Audit log for external system synchronization
-- Dependencies: None

-- Create ENUM types
CREATE TYPE public.sync_direction AS ENUM (
    'incoming',
    'outgoing'
);

ALTER TYPE public.sync_direction OWNER TO postgres;

CREATE TYPE public.sync_status AS ENUM (
    'pending',
    'success',
    'failed',
    'partial'
);

ALTER TYPE public.sync_status OWNER TO postgres;

-- Create external_sync_logs table
CREATE TABLE IF NOT EXISTS public.external_sync_logs (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    external_system character varying(20) NOT NULL,
    direction public.sync_direction NOT NULL,
    status public.sync_status NOT NULL,
    entity_type character varying(50) NOT NULL,
    entity_id uuid,
    request_payload jsonb,
    response_payload jsonb,
    error_message text,
    http_status_code integer,
    duration_ms integer,
    user_id uuid,
    CONSTRAINT external_sync_logs_external_system_check CHECK ((external_system = ANY (ARRAY['OFP'::character varying, 'EKR'::character varying]::text[])))
);

-- Add primary key constraint
ALTER TABLE ONLY public.external_sync_logs
    ADD CONSTRAINT external_sync_logs_pkey PRIMARY KEY (id);

-- Add foreign key constraints
ALTER TABLE ONLY public.external_sync_logs
    ADD CONSTRAINT external_sync_logs_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE SET NULL;

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_sync_logs_created_at ON public.external_sync_logs USING btree (created_at DESC);
CREATE INDEX IF NOT EXISTS idx_sync_logs_direction ON public.external_sync_logs USING btree (direction);
CREATE INDEX IF NOT EXISTS idx_sync_logs_entity ON public.external_sync_logs USING btree (entity_type, entity_id);
CREATE INDEX IF NOT EXISTS idx_sync_logs_status ON public.external_sync_logs USING btree (status);
CREATE INDEX IF NOT EXISTS idx_sync_logs_system ON public.external_sync_logs USING btree (external_system);
CREATE INDEX IF NOT EXISTS idx_sync_logs_system_status_created ON public.external_sync_logs USING btree (external_system, status, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_sync_logs_user_id ON public.external_sync_logs USING btree (user_id);

-- Set table owner
ALTER TABLE public.external_sync_logs OWNER TO postgres;
