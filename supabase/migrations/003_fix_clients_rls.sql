-- Temporarily disable RLS on clients table for testing
ALTER TABLE public.clients DISABLE ROW LEVEL SECURITY;

-- Update existing clients to have a default company_id for testing
UPDATE public.clients
SET company_id = '00000000-0000-0000-0000-000000000001'
WHERE company_id IS NULL OR company_id = '';

-- Also temporarily disable RLS on tickets for easier testing
ALTER TABLE public.tickets DISABLE ROW LEVEL SECURITY;

-- Create a simple user_profiles table if it doesn't exist
CREATE TABLE IF NOT EXISTS public.user_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE UNIQUE NOT NULL,
    company_id UUID NOT NULL DEFAULT '00000000-0000-0000-0000-000000000001',
    first_name VARCHAR(255),
    last_name VARCHAR(255),
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Enable RLS on user_profiles
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;

-- RLS policy for user_profiles
CREATE POLICY "Users can view and edit their own profile"
    ON public.user_profiles
    USING (user_id = auth.uid())
    WITH CHECK (user_id = auth.uid());

-- Grant permissions
GRANT ALL ON public.user_profiles TO authenticated;