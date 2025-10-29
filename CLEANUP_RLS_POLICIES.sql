-- Clean up all existing policies and create simple, working ones
-- Run this in Supabase Dashboard → SQL Editor

-- Drop ALL existing policies
DROP POLICY IF EXISTS "Users can manage own profile" ON user_profiles;
DROP POLICY IF EXISTS "Users can view and edit their own profile" ON user_profiles;
DROP POLICY IF EXISTS "Users can view own profile" ON user_profiles;
DROP POLICY IF EXISTS "user_profiles_insert_own" ON user_profiles;
DROP POLICY IF EXISTS "user_profiles_select_all" ON user_profiles;
DROP POLICY IF EXISTS "user_profiles_update_own" ON user_profiles;
DROP POLICY IF EXISTS "Users can view company profiles" ON user_profiles;

-- Create clean, simple policies that work with upsert
-- Policy 1: SELECT - users can view all profiles (needed for company features)
CREATE POLICY "Enable read access for all users" ON user_profiles
    FOR SELECT
    USING (true);

-- Policy 2: INSERT - users can insert their own profile
CREATE POLICY "Enable insert for users based on user_id" ON user_profiles
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Policy 3: UPDATE - users can update their own profile
CREATE POLICY "Enable update for users based on user_id" ON user_profiles
    FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Policy 4: DELETE - users can delete their own profile (optional)
CREATE POLICY "Enable delete for users based on user_id" ON user_profiles
    FOR DELETE
    USING (auth.uid() = user_id);

-- Verify the new policies
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check
FROM pg_policies
WHERE tablename = 'user_profiles'
ORDER BY cmd, policyname;
