-- Migration: Create survey_value_copy_rules table
-- Description: Rules for copying values between survey questions
-- Dependencies: 408_create_survey_question_type_enum_and_survey_questions_table.sql

CREATE TABLE IF NOT EXISTS public.survey_value_copy_rules (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    condition_question_id uuid NOT NULL,
    condition_value text NOT NULL,
    source_question_id uuid NOT NULL,
    target_question_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);

-- Add primary key constraint
ALTER TABLE ONLY public.survey_value_copy_rules
    ADD CONSTRAINT survey_value_copy_rules_pkey PRIMARY KEY (id);

-- Add foreign key constraints
ALTER TABLE ONLY public.survey_value_copy_rules
    ADD CONSTRAINT survey_value_copy_rules_condition_question_id_fkey FOREIGN KEY (condition_question_id) REFERENCES public.survey_questions(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.survey_value_copy_rules
    ADD CONSTRAINT survey_value_copy_rules_source_question_id_fkey FOREIGN KEY (source_question_id) REFERENCES public.survey_questions(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.survey_value_copy_rules
    ADD CONSTRAINT survey_value_copy_rules_target_question_id_fkey FOREIGN KEY (target_question_id) REFERENCES public.survey_questions(id) ON DELETE CASCADE;

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_copy_rules_condition ON public.survey_value_copy_rules USING btree (condition_question_id);
CREATE INDEX IF NOT EXISTS idx_copy_rules_source ON public.survey_value_copy_rules USING btree (source_question_id);
CREATE INDEX IF NOT EXISTS idx_copy_rules_target ON public.survey_value_copy_rules USING btree (target_question_id);

-- Set table owner
ALTER TABLE public.survey_value_copy_rules OWNER TO postgres;
