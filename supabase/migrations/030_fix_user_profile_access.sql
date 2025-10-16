-- Fix user profile access issues
-- Run this to check and fix the user profile for the current user

-- First, let's check if the user profile exists
DO $$
DECLARE
    user_exists BOOLEAN;
    current_user_id UUID := '4fffb938-176e-45a0-8b9d-bd9419a071f6';
    company_uuid UUID := 'f35b7a0c-6b54-4d0e-bc6a-182a64b8cc44';
BEGIN
    -- Check if user profile exists
    SELECT EXISTS(
        SELECT 1 FROM public.user_profiles
        WHERE user_id = current_user_id
    ) INTO user_exists;

    IF user_exists THEN
        RAISE NOTICE 'User profile exists for user: %', current_user_id;
    ELSE
        RAISE NOTICE 'User profile does NOT exist for user: %', current_user_id;

        -- Create the user profile
        INSERT INTO public.user_profiles (
            user_id,
            company_id,
            first_name,
            last_name,
            email,
            is_online,
            last_activity,
            last_seen
        ) VALUES (
            current_user_id,
            company_uuid,
            'James',
            'Admin',
            'james@example.com',
            false,
            NOW(),
            NOW()
        );

        RAISE NOTICE 'Created user profile for user: %', current_user_id;
    END IF;
END $$;

-- Ensure RLS policies are working correctly by testing them
-- Check current RLS policies on user_profiles
SELECT
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual,
    with_check
FROM pg_policies
WHERE tablename = 'user_profiles';

-- Also ensure the table has RLS enabled
SELECT schemaname, tablename, rowsecurity
FROM pg_tables
WHERE tablename = 'user_profiles';

-- Grant necessary permissions to authenticated users
GRANT ALL ON public.user_profiles TO authenticated;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO authenticated;

-- Ensure RLS is enabled
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;