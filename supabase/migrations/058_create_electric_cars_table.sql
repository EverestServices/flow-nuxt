-- Migration: Create electric_cars table
-- Description: Structure definition for electric_cars
-- Dependencies: 419_create_surveys_table.sql, 004_create_survey_system.sql (electric_car_status ENUM)

CREATE TABLE IF NOT EXISTS public.electric_cars (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    survey_id uuid NOT NULL,
    annual_mileage integer,
    status public.electric_car_status NOT NULL
);

-- Add primary key constraint
ALTER TABLE ONLY public.electric_cars
    ADD CONSTRAINT electric_cars_pkey PRIMARY KEY (id);

-- Add foreign key constraint
ALTER TABLE ONLY public.electric_cars
    ADD CONSTRAINT electric_cars_survey_id_fkey FOREIGN KEY (survey_id) REFERENCES public.surveys(id) ON DELETE CASCADE;

-- Create index
CREATE INDEX IF NOT EXISTS idx_electric_cars_survey_id ON public.electric_cars USING btree (survey_id);

-- Set table owner
ALTER TABLE public.electric_cars OWNER TO postgres;
