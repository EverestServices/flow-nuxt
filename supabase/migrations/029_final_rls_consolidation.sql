-- Final RLS consolidation - clean up all previous attempts and create working policies
-- This migration consolidates all the RLS fixes from migrations 012-025

-- Clean up any existing problematic policies
DROP POLICY IF EXISTS "calendar_events_own_only" ON public.calendar_events;
DROP POLICY IF EXISTS "calendar_events_own_insert" ON public.calendar_events;
DROP POLICY IF EXISTS "calendar_events_own_update" ON public.calendar_events;
DROP POLICY IF EXISTS "calendar_events_own_delete" ON public.calendar_events;

DROP POLICY IF EXISTS "user_profiles_select_all" ON public.user_profiles;
DROP POLICY IF EXISTS "user_profiles_update_own" ON public.user_profiles;
DROP POLICY IF EXISTS "user_profiles_insert_own" ON public.user_profiles;
DROP POLICY IF EXISTS "allow_all_authenticated_select" ON public.user_profiles;
DROP POLICY IF EXISTS "allow_own_update" ON public.user_profiles;
DROP POLICY IF EXISTS "allow_own_insert" ON public.user_profiles;

-- Ensure RLS is enabled on key tables
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.calendar_events ENABLE ROW LEVEL SECURITY;

-- User Profiles - Simple and secure
CREATE POLICY "user_profiles_select" ON public.user_profiles
    FOR SELECT USING (true); -- Allow reading all user profiles (needed for team functionality)

CREATE POLICY "user_profiles_update" ON public.user_profiles
    FOR UPDATE USING (user_id = auth.uid());

CREATE POLICY "user_profiles_insert" ON public.user_profiles
    FOR INSERT WITH CHECK (user_id = auth.uid());

-- Calendar Events - Secure and functional
CREATE POLICY "calendar_events_select" ON public.calendar_events
    FOR SELECT USING (
        user_id = auth.uid() -- Own events
        OR
        (attendees IS NOT NULL AND EXISTS (
            SELECT 1 FROM auth.users
            WHERE auth.users.id = auth.uid()
            AND auth.users.email = ANY(attendees)
        )) -- Events where user is an attendee
    );

CREATE POLICY "calendar_events_insert" ON public.calendar_events
    FOR INSERT WITH CHECK (user_id = auth.uid());

CREATE POLICY "calendar_events_update" ON public.calendar_events
    FOR UPDATE USING (user_id = auth.uid());

CREATE POLICY "calendar_events_delete" ON public.calendar_events
    FOR DELETE USING (user_id = auth.uid());

-- Ensure proper grants
GRANT ALL ON public.user_profiles TO authenticated;
GRANT ALL ON public.calendar_events TO authenticated;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO authenticated;