-- Migration: Create measure_wall_images table
-- Description: Structure definition for measure_wall_images (Aruco measurement system)
-- Dependencies: 435_create_measure_walls_table.sql

CREATE TABLE IF NOT EXISTS public.measure_wall_images (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    wall_id uuid NOT NULL,
    original_url text,
    processed_url text,
    meter_per_pixel numeric,
    processed_image_width integer,
    processed_image_height integer,
    reference_start jsonb,
    reference_end jsonb,
    reference_length_cm numeric,
    original_blob bytea,
    original_mime text,
    original_name text,
    processed_blob bytea,
    processed_mime text,
    processed_name text
);

-- Add primary key constraint
ALTER TABLE ONLY public.measure_wall_images
    ADD CONSTRAINT measure_wall_images_pkey PRIMARY KEY (id);

-- Add foreign key constraint
ALTER TABLE ONLY public.measure_wall_images
    ADD CONSTRAINT measure_wall_images_wall_id_fkey FOREIGN KEY (wall_id) REFERENCES public.measure_walls(id) ON DELETE CASCADE;

-- Create index
CREATE INDEX IF NOT EXISTS idx_measure_images_wall_id ON public.measure_wall_images USING btree (wall_id);

-- Set table owner
ALTER TABLE public.measure_wall_images OWNER TO postgres;
