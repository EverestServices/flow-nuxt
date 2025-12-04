-- Migration: Seed companies data
-- Description: Production data for companies table
-- Dependencies: 001_create_user_profiles_table.sql (companies table created there)

INSERT INTO "public"."companies" ("id", "created_at", "name") VALUES
	('f35b7a0c-6b54-4d0e-bc6a-182a64b8cc44', '2025-09-09 13:59:45.611264+00', 'Everest');

