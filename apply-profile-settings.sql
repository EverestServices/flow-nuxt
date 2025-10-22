-- This script can be run directly in Supabase SQL Editor
-- Copy and paste this entire file into: Dashboard → SQL Editor → New Query

-- Enhance user_profiles table with additional settings fields
DO $$
BEGIN
    -- Add new columns for comprehensive profile settings
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='user_profiles' AND column_name='bio') THEN
        ALTER TABLE user_profiles ADD COLUMN bio TEXT;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='user_profiles' AND column_name='timezone') THEN
        ALTER TABLE user_profiles ADD COLUMN timezone VARCHAR(100) DEFAULT 'UTC';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='user_profiles' AND column_name='language') THEN
        ALTER TABLE user_profiles ADD COLUMN language VARCHAR(10) DEFAULT 'en';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='user_profiles' AND column_name='date_format') THEN
        ALTER TABLE user_profiles ADD COLUMN date_format VARCHAR(20) DEFAULT 'MM/DD/YYYY';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='user_profiles' AND column_name='time_format') THEN
        ALTER TABLE user_profiles ADD COLUMN time_format VARCHAR(10) DEFAULT '12h';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='user_profiles' AND column_name='theme') THEN
        ALTER TABLE user_profiles ADD COLUMN theme VARCHAR(20) DEFAULT 'system';
    END IF;

    -- Notification preferences
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='user_profiles' AND column_name='notification_email') THEN
        ALTER TABLE user_profiles ADD COLUMN notification_email BOOLEAN DEFAULT true;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='user_profiles' AND column_name='notification_push') THEN
        ALTER TABLE user_profiles ADD COLUMN notification_push BOOLEAN DEFAULT true;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='user_profiles' AND column_name='notification_sms') THEN
        ALTER TABLE user_profiles ADD COLUMN notification_sms BOOLEAN DEFAULT false;
    END IF;

    -- Privacy settings
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='user_profiles' AND column_name='privacy_show_email') THEN
        ALTER TABLE user_profiles ADD COLUMN privacy_show_email BOOLEAN DEFAULT false;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='user_profiles' AND column_name='privacy_show_phone') THEN
        ALTER TABLE user_profiles ADD COLUMN privacy_show_phone BOOLEAN DEFAULT false;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='user_profiles' AND column_name='privacy_show_online_status') THEN
        ALTER TABLE user_profiles ADD COLUMN privacy_show_online_status BOOLEAN DEFAULT true;
    END IF;

    -- Social media links
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='user_profiles' AND column_name='linkedin_url') THEN
        ALTER TABLE user_profiles ADD COLUMN linkedin_url VARCHAR(500);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='user_profiles' AND column_name='twitter_url') THEN
        ALTER TABLE user_profiles ADD COLUMN twitter_url VARCHAR(500);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='user_profiles' AND column_name='github_url') THEN
        ALTER TABLE user_profiles ADD COLUMN github_url VARCHAR(500);
    END IF;

    -- Additional profile info
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='user_profiles' AND column_name='location') THEN
        ALTER TABLE user_profiles ADD COLUMN location VARCHAR(200);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='user_profiles' AND column_name='last_activity') THEN
        ALTER TABLE user_profiles ADD COLUMN last_activity TIMESTAMP WITH TIME ZONE DEFAULT NOW();
    END IF;
END $$;

-- Create index for last_activity for performance
CREATE INDEX IF NOT EXISTS idx_user_profiles_last_activity ON user_profiles(last_activity);

-- Function to update user profile
CREATE OR REPLACE FUNCTION update_user_profile(
    p_first_name VARCHAR(100) DEFAULT NULL,
    p_last_name VARCHAR(100) DEFAULT NULL,
    p_phone VARCHAR(20) DEFAULT NULL,
    p_job_title VARCHAR(100) DEFAULT NULL,
    p_department VARCHAR(100) DEFAULT NULL,
    p_bio TEXT DEFAULT NULL,
    p_location VARCHAR(200) DEFAULT NULL,
    p_timezone VARCHAR(100) DEFAULT NULL,
    p_language VARCHAR(10) DEFAULT NULL,
    p_date_format VARCHAR(20) DEFAULT NULL,
    p_time_format VARCHAR(10) DEFAULT NULL,
    p_theme VARCHAR(20) DEFAULT NULL,
    p_linkedin_url VARCHAR(500) DEFAULT NULL,
    p_twitter_url VARCHAR(500) DEFAULT NULL,
    p_github_url VARCHAR(500) DEFAULT NULL
)
RETURNS JSON AS $$
DECLARE
    v_result JSON;
BEGIN
    -- Update the user profile
    UPDATE user_profiles
    SET
        first_name = COALESCE(p_first_name, first_name),
        last_name = COALESCE(p_last_name, last_name),
        phone = COALESCE(p_phone, phone),
        job_title = COALESCE(p_job_title, job_title),
        department = COALESCE(p_department, department),
        bio = COALESCE(p_bio, bio),
        location = COALESCE(p_location, location),
        timezone = COALESCE(p_timezone, timezone),
        language = COALESCE(p_language, language),
        date_format = COALESCE(p_date_format, date_format),
        time_format = COALESCE(p_time_format, time_format),
        theme = COALESCE(p_theme, theme),
        linkedin_url = COALESCE(p_linkedin_url, linkedin_url),
        twitter_url = COALESCE(p_twitter_url, twitter_url),
        github_url = COALESCE(p_github_url, github_url),
        updated_at = NOW()
    WHERE user_id = auth.uid();

    -- Return the updated profile
    SELECT json_build_object(
        'success', true,
        'message', 'Profile updated successfully'
    ) INTO v_result;

    RETURN v_result;
EXCEPTION
    WHEN OTHERS THEN
        RETURN json_build_object(
            'success', false,
            'message', SQLERRM
        );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to update notification preferences
CREATE OR REPLACE FUNCTION update_notification_preferences(
    p_email BOOLEAN DEFAULT NULL,
    p_push BOOLEAN DEFAULT NULL,
    p_sms BOOLEAN DEFAULT NULL
)
RETURNS JSON AS $$
DECLARE
    v_result JSON;
BEGIN
    UPDATE user_profiles
    SET
        notification_email = COALESCE(p_email, notification_email),
        notification_push = COALESCE(p_push, notification_push),
        notification_sms = COALESCE(p_sms, notification_sms),
        updated_at = NOW()
    WHERE user_id = auth.uid();

    SELECT json_build_object(
        'success', true,
        'message', 'Notification preferences updated successfully'
    ) INTO v_result;

    RETURN v_result;
EXCEPTION
    WHEN OTHERS THEN
        RETURN json_build_object(
            'success', false,
            'message', SQLERRM
        );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to update privacy settings
CREATE OR REPLACE FUNCTION update_privacy_settings(
    p_show_email BOOLEAN DEFAULT NULL,
    p_show_phone BOOLEAN DEFAULT NULL,
    p_show_online_status BOOLEAN DEFAULT NULL
)
RETURNS JSON AS $$
DECLARE
    v_result JSON;
BEGIN
    UPDATE user_profiles
    SET
        privacy_show_email = COALESCE(p_show_email, privacy_show_email),
        privacy_show_phone = COALESCE(p_show_phone, privacy_show_phone),
        privacy_show_online_status = COALESCE(p_show_online_status, privacy_show_online_status),
        updated_at = NOW()
    WHERE user_id = auth.uid();

    SELECT json_build_object(
        'success', true,
        'message', 'Privacy settings updated successfully'
    ) INTO v_result;

    RETURN v_result;
EXCEPTION
    WHEN OTHERS THEN
        RETURN json_build_object(
            'success', false,
            'message', SQLERRM
        );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permissions
GRANT EXECUTE ON FUNCTION update_user_profile TO authenticated;
GRANT EXECUTE ON FUNCTION update_notification_preferences TO authenticated;
GRANT EXECUTE ON FUNCTION update_privacy_settings TO authenticated;

-- Success message
DO $$
BEGIN
    RAISE NOTICE '✅ Profile settings migration completed successfully!';
    RAISE NOTICE 'Next steps:';
    RAISE NOTICE '1. Create avatars storage bucket (if not exists)';
    RAISE NOTICE '2. Set up storage policies';
    RAISE NOTICE '3. Navigate to /settings to test';
END $$;
