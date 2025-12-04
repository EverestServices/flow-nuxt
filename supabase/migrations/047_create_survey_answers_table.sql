-- Migration: Create survey_answers table
-- Description: Structure definition for survey_answers
-- Dependencies: 419_create_surveys_table.sql, 408_create_survey_question_type_enum_and_survey_questions_table.sql

CREATE TABLE IF NOT EXISTS "public"."survey_answers" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "survey_id" "uuid" NOT NULL,
    "survey_question_id" "uuid" NOT NULL,
    "answer" "text",
    "item_group" integer,
    "parent_item_group" integer
);

-- Add constraints
ALTER TABLE ONLY public.survey_answers
    ADD CONSTRAINT survey_answers_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.survey_answers
    ADD CONSTRAINT survey_answers_survey_id_fkey FOREIGN KEY (survey_id) REFERENCES public.surveys(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.survey_answers
    ADD CONSTRAINT survey_answers_survey_question_id_fkey FOREIGN KEY (survey_question_id) REFERENCES public.survey_questions(id) ON DELETE CASCADE;

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_survey_answers_parent_item_group ON public.survey_answers USING btree (parent_item_group) WHERE (parent_item_group IS NOT NULL);
CREATE INDEX IF NOT EXISTS idx_survey_answers_question_id ON public.survey_answers USING btree (survey_question_id);
CREATE INDEX IF NOT EXISTS idx_survey_answers_survey_id ON public.survey_answers USING btree (survey_id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_survey_answers_unique_with_parent ON public.survey_answers USING btree (survey_id, survey_question_id, COALESCE(item_group, '-1'::integer), COALESCE(parent_item_group, '-1'::integer));

-- Set table owner
ALTER TABLE public.survey_answers OWNER TO postgres;
