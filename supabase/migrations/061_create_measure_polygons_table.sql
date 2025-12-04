-- Migration: Create measure_polygons table
-- Description: Structure definition for measure_polygons (Aruco measurement system)
-- Dependencies: 435_create_measure_walls_table.sql, 004_create_survey_system.sql (measure_surface_type ENUM)

CREATE TABLE IF NOT EXISTS public.measure_polygons (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    wall_id uuid NOT NULL,
    type public.measure_surface_type,
    sub_type text,
    external_shading text,
    name text,
    visible boolean DEFAULT true,
    closed boolean DEFAULT true,
    points jsonb NOT NULL
);

-- Add primary key constraint
ALTER TABLE ONLY public.measure_polygons
    ADD CONSTRAINT measure_polygons_pkey PRIMARY KEY (id);

-- Add foreign key constraint
ALTER TABLE ONLY public.measure_polygons
    ADD CONSTRAINT measure_polygons_wall_id_fkey FOREIGN KEY (wall_id) REFERENCES public.measure_walls(id) ON DELETE CASCADE;

-- Create index
CREATE INDEX IF NOT EXISTS idx_measure_polygons_wall_id ON public.measure_polygons USING btree (wall_id);

-- Set table owner
ALTER TABLE public.measure_polygons OWNER TO postgres;
