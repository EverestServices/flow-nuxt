-- Migration: Seed survey_value_copy_rules data
-- Description: Insert catalog/reference data for survey_value_copy_rules
-- Dependencies: 414_create_survey_value_copy_rules_table.sql

INSERT INTO "public"."survey_value_copy_rules" ("id", "condition_question_id", "condition_value", "source_question_id", "target_question_id", "created_at", "updated_at") VALUES
	('738a573c-d4f6-462f-87a5-38f649d037c3', '7a2488db-0164-4d7c-8a2a-b3f39f473bca', 'true', 'c401e3cb-8565-4bbf-9376-fec32cbd742e', 'f923a636-7c4d-4769-b744-cd4623bf97f2', '2025-11-14 15:42:47.658936+00', '2025-11-14 15:42:47.658936+00');
