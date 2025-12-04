-- Migration: Add self-reference foreign keys
-- Description: Add foreign keys that reference the same table (must be added after data insertion)
-- Dependencies: All data migrations

-- survey_pages.parent_page_id self-reference
ALTER TABLE ONLY public.survey_pages
    ADD CONSTRAINT survey_pages_parent_page_id_fkey FOREIGN KEY (parent_page_id) REFERENCES public.survey_pages(id) ON DELETE CASCADE;

-- survey_questions self-references
ALTER TABLE ONLY public.survey_questions
    ADD CONSTRAINT fk_survey_questions_default_source FOREIGN KEY (default_value_source_question_id) REFERENCES public.survey_questions(id) ON DELETE SET NULL;

ALTER TABLE ONLY public.survey_questions
    ADD CONSTRAINT survey_questions_shared_question_id_fkey FOREIGN KEY (shared_question_id) REFERENCES public.survey_questions(id) ON DELETE CASCADE;
