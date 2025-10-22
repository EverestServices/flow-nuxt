-- Create subsidies catalog table
CREATE TABLE IF NOT EXISTS public.subsidies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,

    -- Basic information
    name TEXT NOT NULL,
    description TEXT,
    target_group TEXT NOT NULL,

    -- Discount configuration
    discount_type TEXT NOT NULL CHECK (discount_type IN ('percentage', 'fixed')),
    discount_value NUMERIC NOT NULL CHECK (discount_value >= 0),

    -- Display order
    sequence INTEGER DEFAULT 0 NOT NULL
);

-- Create survey_subsidies junction table
CREATE TABLE IF NOT EXISTS public.survey_subsidies (
    survey_id UUID NOT NULL REFERENCES public.surveys(id) ON DELETE CASCADE,
    subsidy_id UUID NOT NULL REFERENCES public.subsidies(id) ON DELETE CASCADE,
    is_enabled BOOLEAN DEFAULT false NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,

    PRIMARY KEY (survey_id, subsidy_id)
);

-- Add indexes
CREATE INDEX IF NOT EXISTS idx_subsidies_sequence ON public.subsidies(sequence);
CREATE INDEX IF NOT EXISTS idx_survey_subsidies_survey_id ON public.survey_subsidies(survey_id);
CREATE INDEX IF NOT EXISTS idx_survey_subsidies_enabled ON public.survey_subsidies(survey_id, is_enabled);

-- Add updated_at trigger for subsidies
CREATE TRIGGER set_subsidies_updated_at
    BEFORE UPDATE ON public.subsidies
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

-- Add updated_at trigger for survey_subsidies
CREATE TRIGGER set_survey_subsidies_updated_at
    BEFORE UPDATE ON public.survey_subsidies
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

-- Add RLS policies
ALTER TABLE public.subsidies ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.survey_subsidies ENABLE ROW LEVEL SECURITY;

-- Subsidies catalog is readable by all authenticated users
CREATE POLICY "Subsidies are viewable by all authenticated users"
    ON public.subsidies FOR SELECT
    TO authenticated
    USING (true);

-- Survey subsidies policies (company-scoped through survey)
CREATE POLICY "Users can view survey subsidies from their company"
    ON public.survey_subsidies FOR SELECT
    TO authenticated
    USING (
        survey_id IN (
            SELECT id FROM public.surveys
            WHERE company_id IN (
                SELECT company_id
                FROM public.user_profiles
                WHERE user_id = auth.uid()
            )
        )
    );

CREATE POLICY "Users can insert survey subsidies for their company's surveys"
    ON public.survey_subsidies FOR INSERT
    TO authenticated
    WITH CHECK (
        survey_id IN (
            SELECT id FROM public.surveys
            WHERE company_id IN (
                SELECT company_id
                FROM public.user_profiles
                WHERE user_id = auth.uid()
            )
        )
    );

CREATE POLICY "Users can update survey subsidies for their company's surveys"
    ON public.survey_subsidies FOR UPDATE
    TO authenticated
    USING (
        survey_id IN (
            SELECT id FROM public.surveys
            WHERE company_id IN (
                SELECT company_id
                FROM public.user_profiles
                WHERE user_id = auth.uid()
            )
        )
    )
    WITH CHECK (
        survey_id IN (
            SELECT id FROM public.surveys
            WHERE company_id IN (
                SELECT company_id
                FROM public.user_profiles
                WHERE user_id = auth.uid()
            )
        )
    );

CREATE POLICY "Users can delete survey subsidies for their company's surveys"
    ON public.survey_subsidies FOR DELETE
    TO authenticated
    USING (
        survey_id IN (
            SELECT id FROM public.surveys
            WHERE company_id IN (
                SELECT company_id
                FROM public.user_profiles
                WHERE user_id = auth.uid()
            )
        )
    );

-- Add comments
COMMENT ON TABLE public.subsidies IS 'Catalog of available subsidy programs';
COMMENT ON TABLE public.survey_subsidies IS 'Junction table linking surveys to enabled subsidy programs';
COMMENT ON COLUMN public.subsidies.discount_type IS 'Type of discount: percentage (e.g., 50%) or fixed amount (e.g., 2,800,000 HUF)';
COMMENT ON COLUMN public.subsidies.discount_value IS 'Discount value - either percentage (0-100) or fixed amount in HUF';
COMMENT ON COLUMN public.subsidies.target_group IS 'Target group description (e.g., "Families with children")';
