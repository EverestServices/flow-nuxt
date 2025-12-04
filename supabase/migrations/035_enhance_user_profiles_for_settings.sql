-- Enhance user_profiles table with additional settings fields

-- Add new columns for comprehensive profile settings
ALTER TABLE user_profiles ADD COLUMN IF NOT EXISTS bio TEXT;
ALTER TABLE user_profiles ADD COLUMN IF NOT EXISTS timezone VARCHAR(100) DEFAULT 'UTC';
ALTER TABLE user_profiles ADD COLUMN IF NOT EXISTS language VARCHAR(10) DEFAULT 'en';
ALTER TABLE user_profiles ADD COLUMN IF NOT EXISTS date_format VARCHAR(20) DEFAULT 'MM/DD/YYYY';
ALTER TABLE user_profiles ADD COLUMN IF NOT EXISTS time_format VARCHAR(10) DEFAULT '12h';
ALTER TABLE user_profiles ADD COLUMN IF NOT EXISTS theme VARCHAR(20) DEFAULT 'system';

-- Notification preferences
ALTER TABLE user_profiles ADD COLUMN IF NOT EXISTS notification_email BOOLEAN DEFAULT true;
ALTER TABLE user_profiles ADD COLUMN IF NOT EXISTS notification_push BOOLEAN DEFAULT true;
ALTER TABLE user_profiles ADD COLUMN IF NOT EXISTS notification_sms BOOLEAN DEFAULT false;

-- Privacy settings
ALTER TABLE user_profiles ADD COLUMN IF NOT EXISTS privacy_show_email BOOLEAN DEFAULT false;
ALTER TABLE user_profiles ADD COLUMN IF NOT EXISTS privacy_show_phone BOOLEAN DEFAULT false;
ALTER TABLE user_profiles ADD COLUMN IF NOT EXISTS privacy_show_online_status BOOLEAN DEFAULT true;

-- Social media links
ALTER TABLE user_profiles ADD COLUMN IF NOT EXISTS linkedin_url VARCHAR(500);
ALTER TABLE user_profiles ADD COLUMN IF NOT EXISTS twitter_url VARCHAR(500);
ALTER TABLE user_profiles ADD COLUMN IF NOT EXISTS github_url VARCHAR(500);

-- Additional profile info
ALTER TABLE user_profiles ADD COLUMN IF NOT EXISTS location VARCHAR(200);
ALTER TABLE user_profiles ADD COLUMN IF NOT EXISTS last_activity TIMESTAMP WITH TIME ZONE DEFAULT NOW();

-- Create index for last_activity for performance
CREATE INDEX IF NOT EXISTS idx_user_profiles_last_activity ON user_profiles(last_activity);

-- Function to update user profile
CREATE OR REPLACE FUNCTION update_user_profile(
    p_first_name VARCHAR(100),
    p_last_name VARCHAR(100),
    p_phone VARCHAR(20),
    p_job_title VARCHAR(100),
    p_department VARCHAR(100),
    p_bio TEXT,
    p_location VARCHAR(200),
    p_timezone VARCHAR(100),
    p_language VARCHAR(10),
    p_date_format VARCHAR(20),
    p_time_format VARCHAR(10),
    p_theme VARCHAR(20),
    p_linkedin_url VARCHAR(500),
    p_twitter_url VARCHAR(500),
    p_github_url VARCHAR(500)
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
    p_email BOOLEAN,
    p_push BOOLEAN,
    p_sms BOOLEAN
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
    p_show_email BOOLEAN,
    p_show_phone BOOLEAN,
    p_show_online_status BOOLEAN
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
