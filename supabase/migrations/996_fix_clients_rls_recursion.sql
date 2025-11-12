-- Fix infinite recursion in clients RLS policy
-- Drop existing policy
DROP POLICY IF EXISTS "Users can view clients from their company" ON public.clients;

-- Create a simpler policy that uses a direct lookup without subquery
CREATE POLICY "Users can view clients from their company"
    ON public.clients FOR SELECT
    USING (
        EXISTS (
            SELECT 1
            FROM public.user_profiles up
            WHERE up.user_id = auth.uid()
              AND up.company_id = clients.company_id
        )
    );
