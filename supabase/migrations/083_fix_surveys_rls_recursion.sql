-- Fix infinite recursion in surveys RLS policy
DROP POLICY IF EXISTS "Users can view surveys from their company" ON public.surveys;

CREATE POLICY "Users can view surveys from their company"
    ON public.surveys FOR SELECT
    USING (
        EXISTS (
            SELECT 1
            FROM public.user_profiles up
            WHERE up.user_id = auth.uid()
              AND up.company_id = surveys.company_id
        )
    );
