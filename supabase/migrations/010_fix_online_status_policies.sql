-- Fix infinite recursion in RLS policies for online status
-- Drop the problematic policies first
DROP POLICY IF EXISTS "Users can view online status" ON user_profiles;
DROP POLICY IF EXISTS "Users can update their own online status" ON user_profiles;

-- Create a much simpler policy that doesn't cause infinite recursion
-- For now, allow all authenticated users to view all profiles (you can restrict this later)
CREATE POLICY "Users can view all profiles for online status" ON user_profiles
  FOR SELECT USING (
    auth.role() = 'authenticated'
  );

CREATE POLICY "Users can update their own profile status" ON user_profiles
  FOR UPDATE USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());