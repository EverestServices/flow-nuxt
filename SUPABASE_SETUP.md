# Supabase Setup for Profile Settings

## Step 1: Run Database Migration

Go to your Supabase Dashboard → SQL Editor and run the following SQL:

```sql
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
```

## Step 2: Create Storage Bucket for Avatars

Go to Supabase Dashboard → Storage → Create a new bucket:

1. **Bucket Name**: `avatars`
2. **Public bucket**: ✅ Yes (checked)
3. **File size limit**: 5MB
4. **Allowed MIME types**: `image/jpeg, image/png, image/gif, image/webp`

## Step 3: Set Storage Policies

In the Storage bucket → Policies, add these policies:

### Policy 1: Allow authenticated users to upload their own avatars
```sql
CREATE POLICY "Users can upload their own avatar"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'avatars' AND
  (storage.foldername(name))[1] = auth.uid()::text
);
```

### Policy 2: Allow everyone to view avatars (public bucket)
```sql
CREATE POLICY "Anyone can view avatars"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'avatars');
```

### Policy 3: Allow users to update their own avatars
```sql
CREATE POLICY "Users can update their own avatar"
ON storage.objects FOR UPDATE
TO authenticated
USING (
  bucket_id = 'avatars' AND
  (storage.foldername(name))[1] = auth.uid()::text
);
```

### Policy 4: Allow users to delete their own avatars
```sql
CREATE POLICY "Users can delete their own avatar"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'avatars' AND
  (storage.foldername(name))[1] = auth.uid()::text
);
```

## Step 4: Deploy Edge Functions (Optional)

If you want to use the edge functions for enhanced security:

```bash
cd /Users/james/Documents/Development/Everest/Flow/public

# Deploy update-profile function
supabase functions deploy update-profile

# Deploy upload-avatar function
supabase functions deploy upload-avatar
```

## Step 5: Test the Setup

1. Navigate to `/settings` in your application
2. Try uploading an avatar
3. Update your profile information
4. Save preferences and notification settings

## Features Implemented

### Profile Settings Page (`/settings`)
- ✅ Personal information management
- ✅ Avatar upload with image preview
- ✅ Preferences (timezone, language, date/time format, theme)
- ✅ Social media links (LinkedIn, Twitter, GitHub)
- ✅ Notification preferences (Email, Push, SMS)
- ✅ Privacy settings (Show email, phone, online status)
- ✅ Full dark mode support
- ✅ Loading states for all save operations
- ✅ Toast notifications for success/error feedback

### Database Schema
- Enhanced `user_profiles` table with 15+ new fields
- Proper indexes for performance
- Row Level Security policies
- Automatic `updated_at` trigger

### Storage
- `avatars` bucket for profile pictures
- 5MB file size limit
- Support for JPEG, PNG, GIF, WebP
- Secure upload with user-specific folders

### Edge Functions
- `update-profile`: Secure profile update endpoint
- `upload-avatar`: Secure avatar upload with validation

## Security Features
- Row Level Security (RLS) enabled
- Users can only update their own profile
- Avatar uploads restricted to authenticated users
- File type and size validation
- Secure storage with proper policies

## Troubleshooting

### If avatars don't upload:
1. Check that the `avatars` bucket exists and is public
2. Verify storage policies are correctly set
3. Check browser console for errors
4. Ensure user is authenticated

### If profile updates don't save:
1. Check user is authenticated
2. Verify RLS policies on `user_profiles` table
3. Check browser console for errors
4. Ensure database columns exist (run migration)

## Next Steps

You can now:
- Access the profile settings page at `/settings`
- Customize the UI colors and styling
- Add more profile fields as needed
- Implement password change functionality
- Add email verification
- Implement 2FA settings
