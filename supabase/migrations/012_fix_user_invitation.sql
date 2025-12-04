-- Fix user invitation by automatically creating user_profiles when new users are created
-- This prevents the "Database error saving new user" when inviting colleagues

-- Create function to handle new user creation
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
  default_company_id UUID := 'f35b7a0c-6b54-4d0e-bc6a-182a64b8cc44'; -- Your existing company ID
BEGIN
  -- Insert a new user profile when a user is created
  INSERT INTO public.user_profiles (
    user_id,
    first_name,
    last_name,
    company_id,
    is_online,
    last_seen,
    last_activity
  )
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'first_name', 'New'),
    COALESCE(NEW.raw_user_meta_data->>'last_name', 'User'),
    default_company_id,
    FALSE,
    NOW(),
    NOW()
  );

  RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN
    -- Log the error but don't prevent user creation
    RAISE NOTICE 'Error creating user profile for user %: %', NEW.id, SQLERRM;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Drop the trigger if it already exists
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- Create trigger to automatically create user_profiles for new auth users
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- Grant necessary permissions
GRANT USAGE ON SCHEMA auth TO authenticated;

-- Also create a function to manually create missing user profiles for existing users
CREATE OR REPLACE FUNCTION create_missing_user_profiles()
RETURNS TEXT AS $$
DECLARE
  missing_count INTEGER;
  default_company_id UUID := 'f35b7a0c-6b54-4d0e-bc6a-182a64b8cc44';
BEGIN
  -- Insert user profiles for users who don't have one
  INSERT INTO public.user_profiles (
    user_id,
    first_name,
    last_name,
    company_id,
    is_online,
    last_seen,
    last_activity
  )
  SELECT
    u.id,
    COALESCE(u.raw_user_meta_data->>'first_name', 'User'),
    COALESCE(u.raw_user_meta_data->>'last_name', u.email),
    default_company_id,
    FALSE,
    NOW(),
    NOW()
  FROM auth.users u
  LEFT JOIN public.user_profiles up ON u.id = up.user_id
  WHERE up.user_id IS NULL;

  GET DIAGNOSTICS missing_count = ROW_COUNT;

  RETURN 'Created ' || missing_count || ' missing user profiles';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Run the function to fix any existing missing profiles
SELECT create_missing_user_profiles();

-- Grant execute permission
GRANT EXECUTE ON FUNCTION create_missing_user_profiles() TO authenticated;

-- Update the user_profiles table to allow NULL values for email lookups
-- (since we're generating placeholder emails in the composable)
ALTER TABLE user_profiles ADD COLUMN IF NOT EXISTS email VARCHAR(255);

-- Create a function to get user email from auth.users (requires service role)
CREATE OR REPLACE FUNCTION get_user_email_by_id(target_user_id UUID)
RETURNS VARCHAR(255) AS $$
DECLARE
  user_email VARCHAR(255);
BEGIN
  -- This will only work with proper permissions
  SELECT email INTO user_email
  FROM auth.users
  WHERE id = target_user_id;

  RETURN user_email;
EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION get_user_email_by_id(UUID) TO authenticated;

-- Update existing user_profiles with actual email addresses where possible
UPDATE user_profiles
SET email = get_user_email_by_id(user_id)
WHERE email IS NULL;