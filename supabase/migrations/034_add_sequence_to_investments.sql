-- ============================================================================
-- Migration: Add sequence column to investments table
-- Description: Adds a sequence column to maintain the display order of investments
-- ============================================================================

-- Add sequence column to investments table
ALTER TABLE public.investments
ADD COLUMN sequence INTEGER;

-- Update sequence based on the order in seed data (004_seed_survey_base_data.sql)
UPDATE public.investments
SET sequence = CASE name
    WHEN 'Solar Panel' THEN 1
    WHEN 'Solar Panel + Battery' THEN 2
    WHEN 'Heat Pump' THEN 3
    WHEN 'Facade Insulation' THEN 4
    WHEN 'Roof Insulation' THEN 5
    WHEN 'Windows' THEN 6
    WHEN 'Air Conditioner' THEN 7
    WHEN 'Battery' THEN 8
    WHEN 'Car Charger' THEN 9
    ELSE 999 -- Default for any unknown investments
END;

-- Add NOT NULL constraint after setting values
ALTER TABLE public.investments
ALTER COLUMN sequence SET NOT NULL;

-- Add a unique constraint to ensure no duplicate sequences
ALTER TABLE public.investments
ADD CONSTRAINT investments_sequence_unique UNIQUE (sequence);

-- Create index for better query performance
CREATE INDEX idx_investments_sequence ON public.investments(sequence);
