-- Migration: Create monthly_climate_data table
-- Description: Reference table for monthly climate data by region
-- Dependencies: None

CREATE TABLE IF NOT EXISTS public.monthly_climate_data (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    month integer NOT NULL,
    region character varying(100) DEFAULT 'hungary'::character varying,
    solar_irradiance numeric(10,2) NOT NULL,
    heating_degree_days numeric(10,2) NOT NULL,
    CONSTRAINT monthly_climate_data_month_check CHECK ((month >= 1) AND (month <= 12))
);

-- Add primary key constraint
ALTER TABLE ONLY public.monthly_climate_data
    ADD CONSTRAINT monthly_climate_data_pkey PRIMARY KEY (id);

-- Add unique constraint
ALTER TABLE ONLY public.monthly_climate_data
    ADD CONSTRAINT monthly_climate_data_month_region_key UNIQUE (month, region);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_monthly_climate_data_region_month ON public.monthly_climate_data USING btree (region, month);

-- Set table owner
ALTER TABLE public.monthly_climate_data OWNER TO postgres;
