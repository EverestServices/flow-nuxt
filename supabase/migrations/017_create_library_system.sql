-- Create library_items table for file and folder management
CREATE TABLE public.library_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    company_id UUID NOT NULL, -- Multi-tenant support
    created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL NOT NULL,
    name VARCHAR(255) NOT NULL,
    type VARCHAR(20) NOT NULL CHECK (type IN ('file', 'folder')),
    path TEXT NOT NULL,
    parent_id UUID REFERENCES public.library_items(id) ON DELETE CASCADE,
    file_type VARCHAR(10), -- File extension (pdf, docx, etc.)
    mime_type VARCHAR(100), -- MIME type
    size BIGINT, -- File size in bytes
    url TEXT, -- URL to the actual file
    category VARCHAR(50), -- documents, images, videos, presentations, etc.
    tags TEXT[], -- Array of tags
    is_public BOOLEAN DEFAULT FALSE,
    is_favorite BOOLEAN DEFAULT FALSE,

    -- Add constraints
    CONSTRAINT valid_file_fields CHECK (
        (type = 'file' AND url IS NOT NULL AND size IS NOT NULL) OR
        (type = 'folder' AND url IS NULL AND size IS NULL)
    )
);

-- Create indexes for performance
CREATE INDEX idx_library_items_company_id ON public.library_items(company_id);
CREATE INDEX idx_library_items_parent_id ON public.library_items(parent_id);
CREATE INDEX idx_library_items_type ON public.library_items(type);
CREATE INDEX idx_library_items_category ON public.library_items(category);
CREATE INDEX idx_library_items_created_by ON public.library_items(created_by);
CREATE INDEX idx_library_items_is_favorite ON public.library_items(is_favorite);
CREATE INDEX idx_library_items_is_public ON public.library_items(is_public);
CREATE INDEX idx_library_items_path ON public.library_items(path);
CREATE INDEX idx_library_items_name ON public.library_items(name);

-- Enable full-text search on name using GIN index for arrays
CREATE INDEX idx_library_items_name_gin ON public.library_items USING gin(
    string_to_array(lower(name), ' ')
);

-- Enable full-text search on tags
CREATE INDEX idx_library_items_tags_gin ON public.library_items USING gin(tags);

-- Add updated_at trigger
CREATE TRIGGER update_library_items_updated_at
    BEFORE UPDATE ON public.library_items
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Enable Row Level Security
ALTER TABLE public.library_items ENABLE ROW LEVEL SECURITY;

-- RLS Policies for library_items
CREATE POLICY "Users can view library items from their company"
    ON public.library_items FOR SELECT
    USING (
        company_id IN (
            SELECT company_id
            FROM public.user_profiles
            WHERE user_id = auth.uid()
        )
        OR is_public = TRUE
    );

CREATE POLICY "Users can insert library items for their company"
    ON public.library_items FOR INSERT
    WITH CHECK (
        company_id IN (
            SELECT company_id
            FROM public.user_profiles
            WHERE user_id = auth.uid()
        )
        AND created_by = auth.uid()
    );

CREATE POLICY "Users can update library items from their company"
    ON public.library_items FOR UPDATE
    USING (
        company_id IN (
            SELECT company_id
            FROM public.user_profiles
            WHERE user_id = auth.uid()
        )
    )
    WITH CHECK (
        company_id IN (
            SELECT company_id
            FROM public.user_profiles
            WHERE user_id = auth.uid()
        )
    );

CREATE POLICY "Users can delete library items from their company"
    ON public.library_items FOR DELETE
    USING (
        company_id IN (
            SELECT company_id
            FROM public.user_profiles
            WHERE user_id = auth.uid()
        )
        AND created_by = auth.uid()
    );

-- Grant permissions
GRANT ALL ON public.library_items TO authenticated;

-- Create storage bucket for library files
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'library-files',
    'library-files',
    true,
    52428800, -- 50MB limit
    ARRAY[
        'image/jpeg', 'image/png', 'image/gif', 'image/webp', 'image/svg+xml',
        'application/pdf',
        'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
        'application/vnd.ms-excel', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        'application/vnd.ms-powerpoint', 'application/vnd.openxmlformats-officedocument.presentationml.presentation',
        'text/plain', 'text/csv',
        'video/mp4', 'video/avi', 'video/quicktime',
        'audio/mpeg', 'audio/wav', 'audio/ogg'
    ]
);

-- Storage policies for library-files bucket
CREATE POLICY "Users can upload files to their company folder"
    ON storage.objects FOR INSERT
    WITH CHECK (
        bucket_id = 'library-files'
        AND auth.uid()::text = (storage.foldername(name))[1]
    );

CREATE POLICY "Users can view files from their company folder"
    ON storage.objects FOR SELECT
    USING (
        bucket_id = 'library-files'
        AND (
            auth.uid()::text = (storage.foldername(name))[1]
            OR EXISTS (
                SELECT 1 FROM public.library_items li
                JOIN public.user_profiles up ON li.company_id = up.company_id
                WHERE li.url LIKE '%' || name || '%'
                AND up.user_id = auth.uid()
                AND li.is_public = true
            )
        )
    );

CREATE POLICY "Users can update files from their company folder"
    ON storage.objects FOR UPDATE
    USING (
        bucket_id = 'library-files'
        AND auth.uid()::text = (storage.foldername(name))[1]
    );

CREATE POLICY "Users can delete files from their company folder"
    ON storage.objects FOR DELETE
    USING (
        bucket_id = 'library-files'
        AND auth.uid()::text = (storage.foldername(name))[1]
    );

-- Function to get library item statistics
CREATE OR REPLACE FUNCTION get_library_stats(company_uuid UUID)
RETURNS JSON AS $$
DECLARE
    stats JSON;
BEGIN
    SELECT json_build_object(
        'total_items', COUNT(*),
        'total_files', COUNT(*) FILTER (WHERE type = 'file'),
        'total_folders', COUNT(*) FILTER (WHERE type = 'folder'),
        'total_size', COALESCE(SUM(size), 0),
        'categories', (
            SELECT json_object_agg(category, count)
            FROM (
                SELECT
                    COALESCE(category, 'uncategorized') as category,
                    COUNT(*) as count
                FROM public.library_items
                WHERE company_id = company_uuid AND type = 'file'
                GROUP BY category
            ) cat_stats
        ),
        'file_types', (
            SELECT json_object_agg(file_type, count)
            FROM (
                SELECT
                    COALESCE(file_type, 'unknown') as file_type,
                    COUNT(*) as count
                FROM public.library_items
                WHERE company_id = company_uuid AND type = 'file'
                GROUP BY file_type
            ) type_stats
        )
    ) INTO stats
    FROM public.library_items
    WHERE company_id = company_uuid;

    RETURN stats;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission on the stats function
GRANT EXECUTE ON FUNCTION get_library_stats(UUID) TO authenticated;

-- Insert some sample library items for testing
DO $$
DECLARE
    sample_company_id UUID := 'f35b7a0c-6b54-4d0e-bc6a-182a64b8cc44';
    sample_user_id UUID;
    documents_folder_id UUID;
    images_folder_id UUID;
    training_folder_id UUID;
BEGIN
    -- Get first available user dynamically
    SELECT id INTO sample_user_id FROM auth.users ORDER BY created_at LIMIT 1;

    -- Skip if no users exist
    IF sample_user_id IS NULL THEN
        RAISE NOTICE 'No users found, skipping library sample data creation';
        RETURN;
    END IF;

    -- Create Documents folder
    INSERT INTO public.library_items (company_id, created_by, name, type, path, category)
    VALUES (sample_company_id, sample_user_id, 'Documents', 'folder', '/Documents', 'documents')
    RETURNING id INTO documents_folder_id;

    -- Create Images folder
    INSERT INTO public.library_items (company_id, created_by, name, type, path, category)
    VALUES (sample_company_id, sample_user_id, 'Images', 'folder', '/Images', 'images')
    RETURNING id INTO images_folder_id;

    -- Create Training Materials folder
    INSERT INTO public.library_items (company_id, created_by, name, type, path, category)
    VALUES (sample_company_id, sample_user_id, 'Training Materials', 'folder', '/Training Materials', 'documents')
    RETURNING id INTO training_folder_id;

    -- Create sample files
    INSERT INTO public.library_items (company_id, created_by, name, type, path, parent_id, file_type, mime_type, size, url, category)
    VALUES
        (sample_company_id, sample_user_id, 'Company Policy.pdf', 'file', '/Documents/Company Policy.pdf', documents_folder_id, 'pdf', 'application/pdf', 2048576, '/storage/v1/object/public/library-files/sample-policy.pdf', 'documents'),
        (sample_company_id, sample_user_id, 'Budget 2024.xlsx', 'file', '/Documents/Budget 2024.xlsx', documents_folder_id, 'xlsx', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', 1048576, '/storage/v1/object/public/library-files/budget-2024.xlsx', 'spreadsheets'),
        (sample_company_id, sample_user_id, 'Team Photo.jpg', 'file', '/Images/Team Photo.jpg', images_folder_id, 'jpg', 'image/jpeg', 3145728, '/storage/v1/object/public/library-files/team-photo.jpg', 'images'),
        (sample_company_id, sample_user_id, 'Onboarding Guide.pdf', 'file', '/Training Materials/Onboarding Guide.pdf', training_folder_id, 'pdf', 'application/pdf', 5242880, '/storage/v1/object/public/library-files/onboarding-guide.pdf', 'documents');
END $$;