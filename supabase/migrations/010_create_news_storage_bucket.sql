-- Drop existing storage policies and bucket if they exist
DROP POLICY IF EXISTS "Global admins can manage all news images" ON storage.objects;
DROP POLICY IF EXISTS "Editors can manage company news images" ON storage.objects;
DROP POLICY IF EXISTS "Users can manage company news images" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete their own news images" ON storage.objects;
DROP POLICY IF EXISTS "Users can update their own news images" ON storage.objects;
DROP POLICY IF EXISTS "Public read access for news images" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can upload news images" ON storage.objects;

DELETE FROM storage.buckets WHERE id = 'news-images';

-- Create storage bucket for news images
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'news-images',
    'news-images',
    true,
    10485760, -- 10MB limit
    ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif']::text[]
);

-- Create storage policies for news images
-- Allow authenticated users to upload images
CREATE POLICY "Authenticated users can upload news images"
ON storage.objects FOR INSERT
WITH CHECK (
    bucket_id = 'news-images'
    AND auth.uid() IS NOT NULL
    AND (storage.foldername(name))[1] = auth.uid()::text -- Users can only upload to their own folder
);

-- Allow public read access to news images
CREATE POLICY "Public read access for news images"
ON storage.objects FOR SELECT
USING (bucket_id = 'news-images');

-- Allow authors to update their own images
CREATE POLICY "Users can update their own news images"
ON storage.objects FOR UPDATE
USING (
    bucket_id = 'news-images'
    AND (storage.foldername(name))[1] = auth.uid()::text
);

-- Allow authors to delete their own images
CREATE POLICY "Users can delete their own news images"
ON storage.objects FOR DELETE
USING (
    bucket_id = 'news-images'
    AND (storage.foldername(name))[1] = auth.uid()::text
);

-- Allow users to manage images in their company's folder
CREATE POLICY "Users can manage company news images"
ON storage.objects FOR ALL
USING (
    bucket_id = 'news-images'
    AND EXISTS (
        SELECT 1 FROM public.user_profiles
        WHERE user_id = auth.uid()
        AND company_id::text = (storage.foldername(name))[1]
    )
);