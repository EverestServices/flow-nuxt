-- Simple cleanup function that doesn't require RPC calls from client
-- This will be called manually or via cron if needed

CREATE OR REPLACE FUNCTION cleanup_inactive_users()
RETURNS VOID AS $$
BEGIN
  UPDATE user_profiles
  SET is_online = FALSE
  WHERE is_online = TRUE
    AND last_activity < NOW() - INTERVAL '5 minutes';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant permission to call cleanup function
GRANT EXECUTE ON FUNCTION cleanup_inactive_users() TO authenticated;

-- Optional: Set up automatic cleanup via cron (commented out by default)
-- Uncomment the line below if you have pg_cron extension enabled
-- SELECT cron.schedule('cleanup-inactive-users', '*/5 * * * *', 'SELECT cleanup_inactive_users();');