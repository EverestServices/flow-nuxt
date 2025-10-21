-- ============================================================================
-- Migration: Products System
-- Description: Creates products and survey_products tables for technical data
-- ============================================================================

-- ============================================================================
-- 1. CREATE PRODUCTS TABLE
-- ============================================================================

CREATE TABLE public.products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,

    -- Basic information
    name VARCHAR(255) NOT NULL,
    persist_name VARCHAR(255) UNIQUE, -- Unique identifier for product (e.g., "sp-001")
    unit VARCHAR(50) NOT NULL, -- Unit of measurement (pcs, m², sets, etc.)
    price DECIMAL(10, 2) NOT NULL, -- Price in HUF

    -- Categorization
    investment_type VARCHAR(100) NOT NULL, -- solarPanel, heatPump, battery, etc.
    category VARCHAR(100) NOT NULL, -- panel, inverter, battery, insulation, etc.

    -- Product details
    manufacturer VARCHAR(255), -- Brand name (Longi, Daikin, BYD, etc.)
    details TEXT, -- Product description

    -- Technical specifications (all optional)
    power DECIMAL(10, 2), -- Power in watts (panels, inverters, AC units)
    capacity DECIMAL(10, 2), -- Capacity in kWh (batteries)
    efficiency DECIMAL(5, 2), -- Efficiency percentage
    u_value DECIMAL(5, 2), -- U-value for windows/insulation
    thickness DECIMAL(5, 2), -- Thickness in cm (insulation)
    cop DECIMAL(5, 2), -- COP value (heat pumps)
    energy_class VARCHAR(10), -- Energy class (air conditioners)

    -- Additional metadata (JSONB for flexible specifications)
    specifications JSONB
);

-- ============================================================================
-- 2. CREATE SURVEY_PRODUCTS JUNCTION TABLE
-- ============================================================================

CREATE TABLE public.survey_products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,

    -- Foreign keys
    survey_id UUID NOT NULL REFERENCES public.surveys(id) ON DELETE CASCADE,
    investment_id UUID REFERENCES public.investments(id) ON DELETE SET NULL, -- Optional: which investment this product belongs to
    product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,

    -- Quantity and pricing
    quantity DECIMAL(10, 2) NOT NULL DEFAULT 1, -- Support decimal quantities for area-based products
    custom_price DECIMAL(10, 2), -- Override price if needed

    -- Package grouping (for multiple technical data packages)
    package_id VARCHAR(100), -- Groups products into packages

    -- Metadata
    notes TEXT
);

-- ============================================================================
-- 3. CREATE UPDATED_AT TRIGGERS
-- ============================================================================

CREATE TRIGGER update_products_updated_at
    BEFORE UPDATE ON public.products
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_survey_products_updated_at
    BEFORE UPDATE ON public.survey_products
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- 4. CREATE INDEXES FOR PERFORMANCE
-- ============================================================================

-- Products indexes
CREATE INDEX idx_products_investment_type ON public.products(investment_type);
CREATE INDEX idx_products_category ON public.products(category);
CREATE INDEX idx_products_persist_name ON public.products(persist_name);

-- Survey Products indexes
CREATE INDEX idx_survey_products_survey_id ON public.survey_products(survey_id);
CREATE INDEX idx_survey_products_product_id ON public.survey_products(product_id);
CREATE INDEX idx_survey_products_investment_id ON public.survey_products(investment_id);
CREATE INDEX idx_survey_products_package_id ON public.survey_products(package_id);

-- ============================================================================
-- 5. ENABLE ROW LEVEL SECURITY
-- ============================================================================

ALTER TABLE public.survey_products ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- 6. CREATE RLS POLICIES
-- ============================================================================

-- Products are public readable (no RLS needed for read)
-- Survey products inherit from survey
CREATE POLICY "Users can view survey products from their company surveys"
    ON public.survey_products FOR SELECT
    USING (
        survey_id IN (
            SELECT id FROM public.surveys
            WHERE company_id IN (
                SELECT company_id FROM public.user_profiles WHERE user_id = auth.uid()
            )
        )
    );

CREATE POLICY "Users can manage survey products from their company surveys"
    ON public.survey_products FOR ALL
    USING (
        survey_id IN (
            SELECT id FROM public.surveys
            WHERE company_id IN (
                SELECT company_id FROM public.user_profiles WHERE user_id = auth.uid()
            )
        )
    );

-- ============================================================================
-- 7. GRANT PERMISSIONS
-- ============================================================================

GRANT ALL ON public.products TO authenticated;
GRANT ALL ON public.survey_products TO authenticated;

-- ============================================================================
-- END OF MIGRATION
-- ============================================================================
