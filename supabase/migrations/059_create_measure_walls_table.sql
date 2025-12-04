-- Migration: Create measure_walls table
-- Description: Structure definition for measure_walls (Aruco measurement system)
-- Dependencies: 419_create_surveys_table.sql

CREATE TABLE IF NOT EXISTS public.measure_walls (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    survey_id uuid NOT NULL,
    name text,
    orientation text
);

-- Add primary key constraint
ALTER TABLE ONLY public.measure_walls
    ADD CONSTRAINT measure_walls_pkey PRIMARY KEY (id);

-- Add foreign key constraint
ALTER TABLE ONLY public.measure_walls
    ADD CONSTRAINT measure_walls_survey_id_fkey FOREIGN KEY (survey_id) REFERENCES public.surveys(id) ON DELETE CASCADE;

-- Create index
CREATE INDEX IF NOT EXISTS idx_measure_walls_survey_id ON public.measure_walls USING btree (survey_id);

-- Set table owner
ALTER TABLE public.measure_walls OWNER TO postgres;
