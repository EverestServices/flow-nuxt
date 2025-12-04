-- Add avatar_url field to user_profiles table for profile images

-- Add the avatar_url column if it doesn't exist
ALTER TABLE user_profiles ADD COLUMN IF NOT EXISTS avatar_url TEXT;

-- Update the handle_new_user function to also try to get avatar from user metadata
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
    email,
    avatar_url,
    company_id,
    is_online,
    last_seen,
    last_activity
  )
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'first_name', 'New'),
    COALESCE(NEW.raw_user_meta_data->>'last_name', 'User'),
    NEW.email,
    NEW.raw_user_meta_data->>'avatar_url',
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

-- Update existing user profiles with avatar URLs from auth.users if available
-- This function will attempt to get avatar URLs from the auth metadata
CREATE OR REPLACE FUNCTION update_user_profiles_with_avatars()
RETURNS TEXT AS $$
DECLARE
  updated_count INTEGER := 0;
  user_record RECORD;
BEGIN
  -- Loop through user_profiles that don't have avatar_url set
  FOR user_record IN
    SELECT up.user_id
    FROM user_profiles up
    WHERE up.avatar_url IS NULL
  LOOP
    -- Try to update with avatar from auth.users metadata
    UPDATE user_profiles
    SET avatar_url = (
      SELECT au.raw_user_meta_data->>'avatar_url'
      FROM auth.users au
      WHERE au.id = user_record.user_id
      AND au.raw_user_meta_data->>'avatar_url' IS NOT NULL
    )
    WHERE user_id = user_record.user_id
    AND avatar_url IS NULL;

    IF FOUND THEN
      updated_count := updated_count + 1;
    END IF;
  END LOOP;

  RETURN 'Updated ' || updated_count || ' user profiles with avatar URLs';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Run the function to update existing profiles
SELECT update_user_profiles_with_avatars();

-- Grant execute permission
GRANT EXECUTE ON FUNCTION update_user_profiles_with_avatars() TO authenticated;