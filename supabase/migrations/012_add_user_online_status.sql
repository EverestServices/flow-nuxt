DROP FUNCTION IF EXISTS update_user_activity(uuid);
DROP FUNCTION IF EXISTS set_user_offline(uuid);

-- Add online status tracking to user_profiles
ALTER TABLE user_profiles
ADD COLUMN IF NOT EXISTS is_online BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS last_seen TIMESTAMPTZ DEFAULT NOW(),
ADD COLUMN IF NOT EXISTS last_activity TIMESTAMPTZ DEFAULT NOW();

-- Create index for efficient online user queries
CREATE INDEX IF NOT EXISTS idx_user_profiles_online_status ON user_profiles(is_online, last_activity);
CREATE INDEX IF NOT EXISTS idx_user_profiles_last_seen ON user_profiles(last_seen);

-- Create function to update user activity
CREATE OR REPLACE FUNCTION update_user_activity(p_user_id UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE user_profiles
  SET
    is_online = TRUE,
    last_activity = NOW(),
    last_seen = NOW()
  WHERE user_id = p_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create function to set user offline
CREATE OR REPLACE FUNCTION set_user_offline(p_user_id UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE user_profiles
  SET
    is_online = FALSE,
    last_seen = NOW()
  WHERE user_id = p_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create function to automatically set users offline after 5 minutes of inactivity
CREATE OR REPLACE FUNCTION cleanup_inactive_users()
RETURNS VOID AS $$
BEGIN
  UPDATE user_profiles
  SET is_online = FALSE
  WHERE is_online = TRUE
    AND last_activity < NOW() - INTERVAL '5 minutes';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create a scheduled job to run cleanup every minute (if pg_cron is available)
-- Note: This requires the pg_cron extension to be enabled
-- SELECT cron.schedule('cleanup-inactive-users', '* * * * *', 'SELECT cleanup_inactive_users();');

-- Create function to safely get user's company_id to avoid infinite recursion
CREATE OR REPLACE FUNCTION get_current_user_company_id()
RETURNS UUID AS $$
DECLARE
  user_company_id UUID;
BEGIN
  SELECT company_id INTO user_company_id
  FROM user_profiles
  WHERE user_id = auth.uid()
  LIMIT 1;

  RETURN user_company_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

-- Grant necessary permissions
GRANT EXECUTE ON FUNCTION update_user_activity(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION set_user_offline(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION cleanup_inactive_users() TO authenticated;
GRANT EXECUTE ON FUNCTION get_current_user_company_id() TO authenticated;

-- Add RLS policies for online status
-- Drop existing policies if they exist to avoid conflicts
DROP POLICY IF EXISTS "Users can view online status" ON user_profiles;
DROP POLICY IF EXISTS "Users can update their own online status" ON user_profiles;

-- Allow users to view online status of users in their company
CREATE POLICY "Users can view online status" ON user_profiles
  FOR SELECT USING (
    -- Allow users to see their own profile
    user_id = auth.uid()
    OR
    -- Allow users to see profiles in their company using the safe function
    company_id = get_current_user_company_id()
  );

CREATE POLICY "Users can update their own online status" ON user_profiles
  FOR UPDATE USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());