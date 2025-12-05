-- Clean up existing news system objects if they exist
DO $$
BEGIN
    -- Drop policies only if tables exist
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'news_views') THEN
        DROP POLICY IF EXISTS "Users can view their own view records" ON public.news_views;
        DROP POLICY IF EXISTS "Users can create views" ON public.news_views;
    END IF;

    IF EXISTS (SELECT FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'news_articles') THEN
        DROP POLICY IF EXISTS "Authors can delete their own articles" ON public.news_articles;
        DROP POLICY IF EXISTS "Authors can update their own articles" ON public.news_articles;
        DROP POLICY IF EXISTS "Authors can create articles" ON public.news_articles;
        DROP POLICY IF EXISTS "Editors can view all articles in their company" ON public.news_articles;
        DROP POLICY IF EXISTS "Authors can view their own articles" ON public.news_articles;
        DROP POLICY IF EXISTS "Users can view published articles" ON public.news_articles;
    END IF;

    IF EXISTS (SELECT FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'news_categories') THEN
        DROP POLICY IF EXISTS "Authenticated users can manage categories" ON public.news_categories;
        DROP POLICY IF EXISTS "Everyone can view active categories" ON public.news_categories;
    END IF;
END $$;

-- Drop triggers only if tables exist
DO $$
BEGIN
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'news_views') THEN
        DROP TRIGGER IF EXISTS update_article_view_count ON public.news_views;
    END IF;

    IF EXISTS (SELECT FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'news_articles') THEN
        DROP TRIGGER IF EXISTS set_article_slug_trigger ON public.news_articles;
        DROP TRIGGER IF EXISTS update_news_articles_updated_at ON public.news_articles;
    END IF;

    IF EXISTS (SELECT FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'news_categories') THEN
        DROP TRIGGER IF EXISTS update_news_categories_updated_at ON public.news_categories;
    END IF;
END $$;

-- Drop indexes
DROP INDEX IF EXISTS idx_news_views_unique_daily;
DROP INDEX IF EXISTS idx_news_views_unique_user_article;
DROP INDEX IF EXISTS idx_news_views_company;
DROP INDEX IF EXISTS idx_news_views_article;
DROP INDEX IF EXISTS idx_news_articles_search;
DROP INDEX IF EXISTS idx_news_articles_tags;
DROP INDEX IF EXISTS idx_news_articles_slug;
DROP INDEX IF EXISTS idx_news_articles_author;
DROP INDEX IF EXISTS idx_news_articles_category;
DROP INDEX IF EXISTS idx_news_articles_company;
DROP INDEX IF EXISTS idx_news_articles_global;
DROP INDEX IF EXISTS idx_news_articles_featured;
DROP INDEX IF EXISTS idx_news_articles_published;
DROP INDEX IF EXISTS idx_news_categories_sort_order;
DROP INDEX IF EXISTS idx_news_categories_active;

-- Drop functions
DROP FUNCTION IF EXISTS increment_article_views();
DROP FUNCTION IF EXISTS generate_unique_slug(TEXT, TEXT);
DROP FUNCTION IF EXISTS set_article_slug();

-- Drop tables (in dependency order)
DROP TABLE IF EXISTS public.news_views;
DROP TABLE IF EXISTS public.news_articles;
DROP TABLE IF EXISTS public.news_categories;

-- Create news_categories table
CREATE TABLE public.news_categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    name VARCHAR(100) NOT NULL UNIQUE,
    slug VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    color VARCHAR(7) DEFAULT '#3B82F6', -- Hex color code
    is_active BOOLEAN DEFAULT TRUE,
    sort_order INTEGER DEFAULT 0
);

-- Create news_articles table
CREATE TABLE public.news_articles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    published_at TIMESTAMPTZ,

    -- Content fields
    title VARCHAR(500) NOT NULL,
    slug VARCHAR(500) NOT NULL,
    excerpt TEXT,
    content TEXT NOT NULL,

    -- Media fields
    featured_image_url TEXT,
    featured_image_alt VARCHAR(255),

    -- Categorization
    category_id UUID REFERENCES public.news_categories(id) ON DELETE SET NULL,
    tags TEXT[], -- Array of tags

    -- Visibility and targeting
    company_id UUID, -- NULL = global news, UUID = company-specific news
    is_global BOOLEAN DEFAULT FALSE, -- Global news visible to all companies
    is_featured BOOLEAN DEFAULT FALSE, -- Featured on homepage/top of news
    is_published BOOLEAN DEFAULT FALSE, -- Published or draft

    -- Author and management
    author_id UUID REFERENCES auth.users(id) ON DELETE SET NULL NOT NULL,
    editor_id UUID REFERENCES auth.users(id) ON DELETE SET NULL, -- Who last edited

    -- SEO
    meta_title VARCHAR(60),
    meta_description VARCHAR(160),

    -- Analytics
    view_count INTEGER DEFAULT 0,

    -- Constraints
    CONSTRAINT valid_slug_format CHECK (slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$'),
    CONSTRAINT title_not_empty CHECK (LENGTH(TRIM(title)) > 0),
    CONSTRAINT content_not_empty CHECK (LENGTH(TRIM(content)) > 0),
    CONSTRAINT valid_visibility CHECK (
        (is_global = TRUE AND company_id IS NULL) OR
        (is_global = FALSE AND company_id IS NOT NULL)
    )
);

-- Create news_views table for analytics
CREATE TABLE public.news_views (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    article_id UUID REFERENCES public.news_articles(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    company_id UUID, -- For tracking company-specific views
    ip_address INET,
    user_agent TEXT
);

-- Create indexes for performance
CREATE INDEX idx_news_categories_active ON public.news_categories(is_active);
CREATE INDEX idx_news_categories_sort_order ON public.news_categories(sort_order);

CREATE INDEX idx_news_articles_published ON public.news_articles(is_published, published_at DESC);
CREATE INDEX idx_news_articles_featured ON public.news_articles(is_featured, published_at DESC);
CREATE INDEX idx_news_articles_global ON public.news_articles(is_global, published_at DESC);
CREATE INDEX idx_news_articles_company ON public.news_articles(company_id, published_at DESC);
CREATE INDEX idx_news_articles_category ON public.news_articles(category_id, published_at DESC);
CREATE INDEX idx_news_articles_author ON public.news_articles(author_id);
CREATE INDEX idx_news_articles_slug ON public.news_articles(slug);
CREATE INDEX idx_news_articles_tags ON public.news_articles USING GIN(tags);
CREATE INDEX idx_news_articles_search ON public.news_articles USING GIN(to_tsvector('english', title || ' ' || excerpt || ' ' || content));

CREATE INDEX idx_news_views_article ON public.news_views(article_id, created_at DESC);
CREATE INDEX idx_news_views_company ON public.news_views(company_id, created_at DESC);

-- Create unique index to prevent duplicate views from same user per article
-- Note: This prevents multiple views per user per article entirely
-- If you want daily uniqueness, implement it in application logic
CREATE UNIQUE INDEX idx_news_views_unique_user_article
ON public.news_views(article_id, user_id)
WHERE user_id IS NOT NULL;

-- Create function to update article view count
CREATE OR REPLACE FUNCTION increment_article_views()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE public.news_articles
    SET view_count = view_count + 1
    WHERE id = NEW.article_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to update view count
CREATE TRIGGER update_article_view_count
    AFTER INSERT ON public.news_views
    FOR EACH ROW
    EXECUTE FUNCTION increment_article_views();

-- Create function to generate unique slugs
CREATE OR REPLACE FUNCTION generate_unique_slug(title_text TEXT, table_name TEXT DEFAULT 'news_articles')
RETURNS TEXT AS $$
DECLARE
    base_slug TEXT;
    final_slug TEXT;
    counter INTEGER := 0;
BEGIN
    -- Generate base slug from title
    base_slug := LOWER(
        REGEXP_REPLACE(
            REGEXP_REPLACE(
                REGEXP_REPLACE(title_text, '[^a-zA-Z0-9\s-]', '', 'g'),
                '\s+', '-', 'g'
            ),
            '-+', '-', 'g'
        )
    );

    -- Remove leading/trailing hyphens
    base_slug := TRIM(base_slug, '-');

    -- Ensure slug is not empty
    IF LENGTH(base_slug) = 0 THEN
        base_slug := 'article';
    END IF;

    final_slug := base_slug;

    -- Check for uniqueness and append counter if needed
    WHILE EXISTS (
        SELECT 1 FROM public.news_articles WHERE slug = final_slug
    ) LOOP
        counter := counter + 1;
        final_slug := base_slug || '-' || counter;
    END LOOP;

    RETURN final_slug;
END;
$$ LANGUAGE plpgsql;

-- Create function to auto-generate slug before insert/update
CREATE OR REPLACE FUNCTION set_article_slug()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.slug IS NULL OR NEW.slug = '' THEN
        NEW.slug := generate_unique_slug(NEW.title);
    END IF;

    -- Update editor and updated_at on updates
    IF TG_OP = 'UPDATE' THEN
        NEW.updated_at := NOW();
        IF NEW.title != OLD.title OR NEW.content != OLD.content OR NEW.excerpt != OLD.excerpt THEN
            NEW.editor_id := auth.uid();
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create triggers for articles
CREATE TRIGGER set_article_slug_trigger
    BEFORE INSERT OR UPDATE ON public.news_articles
    FOR EACH ROW
    EXECUTE FUNCTION set_article_slug();

CREATE TRIGGER update_news_articles_updated_at
    BEFORE UPDATE ON public.news_articles
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_news_categories_updated_at
    BEFORE UPDATE ON public.news_categories
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Enable Row Level Security
ALTER TABLE public.news_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.news_articles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.news_views ENABLE ROW LEVEL SECURITY;

-- RLS Policies for categories (everyone can read, authenticated users can manage)
CREATE POLICY "Everyone can view active categories"
    ON public.news_categories FOR SELECT
    USING (is_active = TRUE);

CREATE POLICY "Authenticated users can manage categories"
    ON public.news_categories FOR ALL
    USING (auth.uid() IS NOT NULL);

-- RLS Policies for articles
CREATE POLICY "Users can view published articles"
    ON public.news_articles FOR SELECT
    USING (
        is_published = TRUE
        AND published_at <= NOW()
        AND (
            -- Global articles visible to everyone
            is_global = TRUE
            OR
            -- Company-specific articles visible to company members
            (
                is_global = FALSE
                AND company_id IN (
                    SELECT company_id
                    FROM public.user_profiles
                    WHERE user_id = auth.uid()
                )
            )
        )
    );

CREATE POLICY "Authors can view their own articles"
    ON public.news_articles FOR SELECT
    USING (author_id = auth.uid());

CREATE POLICY "Users can create articles for their company"
    ON public.news_articles FOR INSERT
    WITH CHECK (
        author_id = auth.uid()
        AND (
            -- Global articles for authenticated users
            is_global = TRUE
            OR
            -- Company articles for users of that company
            (is_global = FALSE AND company_id IN (
                SELECT company_id FROM public.user_profiles
                WHERE user_id = auth.uid()
            ))
        )
    );

CREATE POLICY "Authors can update their own articles"
    ON public.news_articles FOR UPDATE
    USING (author_id = auth.uid());

CREATE POLICY "Authors can delete their own articles"
    ON public.news_articles FOR DELETE
    USING (author_id = auth.uid());

-- RLS Policies for views
CREATE POLICY "Users can create views"
    ON public.news_views FOR INSERT
    WITH CHECK (
        user_id = auth.uid()
        OR user_id IS NULL -- Allow anonymous views
    );

CREATE POLICY "Users can view their own view records"
    ON public.news_views FOR SELECT
    USING (user_id = auth.uid());

-- Grant permissions
GRANT ALL ON public.news_categories TO authenticated;
GRANT ALL ON public.news_articles TO authenticated;
GRANT ALL ON public.news_views TO authenticated;

-- Insert default categories
INSERT INTO public.news_categories (name, slug, description, color, sort_order) VALUES
    ('Company News', 'company-news', 'News and updates about our company', '#3B82F6', 1),
    ('Industry Updates', 'industry-updates', 'Latest industry news and trends', '#10B981', 2),
    ('Product Updates', 'product-updates', 'New features and product announcements', '#8B5CF6', 3),
    ('Training & Education', 'training-education', 'Training materials and educational content', '#F59E0B', 4),
    ('General', 'general', 'General news and announcements', '#6B7280', 5);

-- Sample article insert (commented out - needs valid author_id)
-- You can uncomment and modify this after creating your first user
/*
INSERT INTO public.news_articles (
    title,
    slug,
    excerpt,
    content,
    category_id,
    is_global,
    is_featured,
    is_published,
    published_at,
    author_id,
    tags
) VALUES
    (
        'Welcome to Flow News Portal',
        'welcome-to-flow-news-portal',
        'Introducing our new news portal for staying updated with company and industry news.',
        '<p>We are excited to introduce our new Flow News Portal! This platform will serve as your central hub for all company updates, industry news, and important announcements.</p><p>Stay tuned for regular updates and make sure to check the different categories for news that matters to you.</p>',
        (SELECT id FROM public.news_categories WHERE slug = 'company-news'),
        TRUE,
        TRUE,
        TRUE,
        NOW(),
        '00000000-0000-0000-0000-000000000001', -- Replace with actual user ID
        ARRAY['welcome', 'portal', 'announcement']
    );
*/