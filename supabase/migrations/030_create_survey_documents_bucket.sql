-- Drop existing storage policies and bucket if they exist
DROP POLICY IF EXISTS "Authenticated users can upload survey documents" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can read their survey documents" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can update their survey documents" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can delete their survey documents" ON storage.objects;

-- Delete all objects in the bucket first
DELETE FROM storage.objects WHERE bucket_id = 'survey-documents';

-- Now delete the bucket
DELETE FROM storage.buckets WHERE id = 'survey-documents';

-- Create storage bucket for survey documents (photos)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'survey-documents',
    'survey-documents',
    true, -- Public bucket (képek közvetlenül elérhetők URL-ből)
    52428800, -- 50MB limit per file
    ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif', 'image/heic', 'image/heif']::text[]
);

-- Create storage policies for survey documents

-- Allow authenticated users to upload survey documents
-- Path structure: survey_id/category_id/timestamp.ext
CREATE POLICY "Authenticated users can upload survey documents"
ON storage.objects FOR INSERT
WITH CHECK (
    bucket_id = 'survey-documents'
    AND auth.uid() IS NOT NULL
);

-- Allow authenticated users to read survey documents
CREATE POLICY "Authenticated users can read their survey documents"
ON storage.objects FOR SELECT
USING (
    bucket_id = 'survey-documents'
    AND auth.uid() IS NOT NULL
);

-- Allow authenticated users to update survey documents
CREATE POLICY "Authenticated users can update their survey documents"
ON storage.objects FOR UPDATE
USING (
    bucket_id = 'survey-documents'
    AND auth.uid() IS NOT NULL
);

-- Allow authenticated users to delete survey documents
CREATE POLICY "Authenticated users can delete their survey documents"
ON storage.objects FOR DELETE
USING (
    bucket_id = 'survey-documents'
    AND auth.uid() IS NOT NULL
);
