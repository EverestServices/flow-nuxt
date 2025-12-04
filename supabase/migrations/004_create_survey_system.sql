-- ============================================================================
-- Migration: ENUMs for Survey System
-- Description: Creates required ENUMs for survey system tables
-- Note: electric_cars table moved to 434, heavy_consumer_status used by 424
--       Other tables from original migration moved to 400-496
-- ============================================================================

-- ============================================================================
-- CREATE ENUMS
-- ============================================================================

-- ENUM for electric_cars table (created in 434)
CREATE TYPE electric_car_status AS ENUM ('existing', 'planned');

-- ENUM for survey_heavy_consumers table (used by 424)
CREATE TYPE heavy_consumer_status AS ENUM ('existing', 'planned');

-- ENUM for measure_polygons table (used by 437)
CREATE TYPE measure_surface_type AS ENUM ('wallPlinth', 'facade', 'windowDoor');
