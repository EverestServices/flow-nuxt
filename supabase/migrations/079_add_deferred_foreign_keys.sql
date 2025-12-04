-- Migration: Add deferred foreign keys
-- Description: Add foreign keys that were deferred due to circular dependencies
-- Dependencies: All data migrations

-- survey_pages.investment_id to investments
ALTER TABLE ONLY public.survey_pages
    ADD CONSTRAINT survey_pages_investment_id_fkey FOREIGN KEY (investment_id) REFERENCES public.investments(id) ON DELETE CASCADE;
