-- Fix Storage Policies for avatars bucket
-- Run this in Supabase Dashboard → SQL Editor

-- First, check if the avatars bucket exists
-- If you see an error about bucket not existing, create it in Storage UI first

-- Drop existing storage policies
DROP POLICY IF EXISTS "Users can upload their own avatar" ON storage.objects;
DROP POLICY IF EXISTS "Anyone can view avatars" ON storage.objects;
DROP POLICY IF EXISTS "Users can update their own avatar" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete their own avatar" ON storage.objects;

-- Policy 1: Allow authenticated users to upload to their own folder
CREATE POLICY "Allow authenticated uploads to own folder"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
    bucket_id = 'avatars' AND
    (storage.foldername(name))[1] = auth.uid()::text
);

-- Policy 2: Allow everyone to view avatars (public bucket)
CREATE POLICY "Allow public to view avatars"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'avatars');

-- Policy 3: Allow users to update their own avatars
CREATE POLICY "Allow authenticated to update own avatars"
ON storage.objects FOR UPDATE
TO authenticated
USING (
    bucket_id = 'avatars' AND
    (storage.foldername(name))[1] = auth.uid()::text
)
WITH CHECK (
    bucket_id = 'avatars' AND
    (storage.foldername(name))[1] = auth.uid()::text
);

-- Policy 4: Allow users to delete their own avatars
CREATE POLICY "Allow authenticated to delete own avatars"
ON storage.objects FOR DELETE
TO authenticated
USING (
    bucket_id = 'avatars' AND
    (storage.foldername(name))[1] = auth.uid()::text
);

-- Verify storage policies
SELECT schemaname, tablename, policyname, permissive, roles, cmd
FROM pg_policies
WHERE tablename = 'objects' AND schemaname = 'storage'
ORDER BY cmd, policyname;
