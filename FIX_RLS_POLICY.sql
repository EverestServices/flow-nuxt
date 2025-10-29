-- IMPORTANT: Run this SQL in your Supabase Dashboard → SQL Editor
-- This fixes the Row Level Security policies for user_profiles table
-- to allow upsert operations (which require both INSERT and UPDATE permissions)

-- Drop existing conflicting policies
DROP POLICY IF EXISTS "Users can update own profile" ON user_profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON user_profiles;
DROP POLICY IF EXISTS "Users can manage own profile" ON user_profiles;

-- Create a comprehensive policy that allows ALL operations on own profile
CREATE POLICY "Users can manage own profile" ON user_profiles
    FOR ALL
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Verify the policy was created
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check
FROM pg_policies
WHERE tablename = 'user_profiles'
ORDER BY policyname;
