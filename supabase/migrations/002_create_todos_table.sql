-- Create todos table with multi-tenant support
CREATE TABLE public.todos (
    id BIGSERIAL PRIMARY KEY,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    company_id UUID NOT NULL, -- References your properties table
    title VARCHAR(255) NOT NULL,
    description TEXT,
    completed BOOLEAN DEFAULT FALSE NOT NULL,
    priority VARCHAR(20) DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high', 'urgent')),
    due_date TIMESTAMPTZ,
    category VARCHAR(100),
    tags TEXT[], -- Array of tags for categorization
    entity_type VARCHAR(100), -- For linking to other entities
    source_entity_id UUID, -- For linking to specific records
    assigned_to UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    order_index INTEGER DEFAULT 0 -- For custom ordering
);

-- Add updated_at trigger
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_todos_updated_at
    BEFORE UPDATE ON public.todos
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Create indexes for performance
CREATE INDEX idx_todos_user_id ON public.todos(user_id);
CREATE INDEX idx_todos_company_id ON public.todos(company_id);
CREATE INDEX idx_todos_completed ON public.todos(completed);
CREATE INDEX idx_todos_due_date ON public.todos(due_date);
CREATE INDEX idx_todos_priority ON public.todos(priority);
CREATE INDEX idx_todos_entity_type ON public.todos(entity_type);
CREATE INDEX idx_todos_source_entity_id ON public.todos(source_entity_id);

-- Enable Row Level Security
ALTER TABLE public.todos ENABLE ROW LEVEL SECURITY;

-- RLS Policies for multi-tenant access
-- Users can only access todos from their company
CREATE POLICY "Users can view todos from their company"
    ON public.todos FOR SELECT
    USING (
        company_id IN (
            SELECT company_id
            FROM public.user_profiles
            WHERE user_id = auth.uid()
        )
    );

CREATE POLICY "Users can insert todos for their company"
    ON public.todos FOR INSERT
    WITH CHECK (
        company_id IN (
            SELECT company_id
            FROM public.user_profiles
            WHERE user_id = auth.uid()
        )
        AND user_id = auth.uid()
    );

CREATE POLICY "Users can update todos from their company"
    ON public.todos FOR UPDATE
    USING (
        company_id IN (
            SELECT company_id
            FROM public.user_profiles
            WHERE user_id = auth.uid()
        )
    );

CREATE POLICY "Users can delete their own todos"
    ON public.todos FOR DELETE
    USING (user_id = auth.uid());

-- Grant permissions
GRANT ALL ON public.todos TO authenticated;
GRANT USAGE ON SEQUENCE public.todos_id_seq TO authenticated;