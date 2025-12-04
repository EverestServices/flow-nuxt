-- ============================================================================
-- Migration: Main Components System
-- Description: Creates main_components, main_component_categories and related pivot tables
-- ============================================================================

-- ============================================================================
-- 1. CREATE MAIN COMPONENT CATEGORIES TABLE
-- ============================================================================

CREATE TABLE public.main_component_categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,

    -- Category identifier
    persist_name VARCHAR(100) UNIQUE NOT NULL -- e.g., inverter, panel, mounting, regulator, battery, etc.
);

-- ============================================================================
-- 2. CREATE MAIN COMPONENTS TABLE
-- ============================================================================

CREATE TABLE public.main_components (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,

    -- Basic information
    name VARCHAR(255) NOT NULL,
    persist_name VARCHAR(255) UNIQUE, -- Unique identifier for component (e.g., "sp-001")
    unit VARCHAR(50) NOT NULL, -- Unit of measurement (pcs, m², sets, etc.)
    price DECIMAL(10, 2) NOT NULL, -- Price in HUF

    -- Category relationship
    main_component_category_id UUID NOT NULL REFERENCES public.main_component_categories(id) ON DELETE RESTRICT,

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
-- 3. CREATE MAIN COMPONENT CATEGORY - INVESTMENT PIVOT TABLE
-- ============================================================================

CREATE TABLE public.main_component_category_investments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,

    -- Foreign keys
    main_component_category_id UUID NOT NULL REFERENCES public.main_component_categories(id) ON DELETE CASCADE,
    investment_id UUID NOT NULL REFERENCES public.investments(id) ON DELETE CASCADE,

    -- Ordering
    sequence INTEGER NOT NULL,

    -- Unique constraint: one category can appear only once per investment
    UNIQUE(main_component_category_id, investment_id)
);

-- ============================================================================
-- 4. CREATE SCENARIO - MAIN COMPONENT PIVOT TABLE
-- ============================================================================

CREATE TABLE public.scenario_main_components (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,

    -- Foreign keys
    scenario_id UUID NOT NULL REFERENCES public.scenarios(id) ON DELETE CASCADE,
    main_component_id UUID NOT NULL REFERENCES public.main_components(id) ON DELETE CASCADE,

    -- Quantity and pricing
    quantity DECIMAL(10, 2) NOT NULL DEFAULT 1, -- Support decimal quantities for area-based components
    price_snapshot DECIMAL(10, 2) NOT NULL, -- Price snapshot at the time of scenario creation

    -- Unique constraint: one component can appear only once per scenario
    UNIQUE(scenario_id, main_component_id)
);

-- ============================================================================
-- 5. CREATE CONTRACT - MAIN COMPONENT PIVOT TABLE
-- ============================================================================

CREATE TABLE public.contract_main_components (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,

    -- Foreign keys
    contract_id UUID NOT NULL REFERENCES public.contracts(id) ON DELETE CASCADE,
    main_component_id UUID NOT NULL REFERENCES public.main_components(id) ON DELETE CASCADE,

    -- Quantity and pricing
    quantity DECIMAL(10, 2) NOT NULL DEFAULT 1, -- Support decimal quantities for area-based components
    price_snapshot DECIMAL(10, 2) NOT NULL, -- Price snapshot at the time of contract creation

    -- Unique constraint: one component can appear only once per contract
    UNIQUE(contract_id, main_component_id)
);

-- ============================================================================
-- 6. CREATE UPDATED_AT TRIGGERS
-- ============================================================================

CREATE TRIGGER update_main_component_categories_updated_at
    BEFORE UPDATE ON public.main_component_categories
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_main_components_updated_at
    BEFORE UPDATE ON public.main_components
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_main_component_category_investments_updated_at
    BEFORE UPDATE ON public.main_component_category_investments
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_scenario_main_components_updated_at
    BEFORE UPDATE ON public.scenario_main_components
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_contract_main_components_updated_at
    BEFORE UPDATE ON public.contract_main_components
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- 7. CREATE INDEXES FOR PERFORMANCE
-- ============================================================================

-- Main Component Categories indexes
CREATE INDEX idx_main_component_categories_persist_name ON public.main_component_categories(persist_name);

-- Main Components indexes
CREATE INDEX idx_main_components_category_id ON public.main_components(main_component_category_id);
CREATE INDEX idx_main_components_persist_name ON public.main_components(persist_name);

-- Main Component Category Investments indexes
CREATE INDEX idx_mcc_investments_category_id ON public.main_component_category_investments(main_component_category_id);
CREATE INDEX idx_mcc_investments_investment_id ON public.main_component_category_investments(investment_id);
CREATE INDEX idx_mcc_investments_sequence ON public.main_component_category_investments(investment_id, sequence);

-- Scenario Main Components indexes
CREATE INDEX idx_scenario_main_components_scenario_id ON public.scenario_main_components(scenario_id);
CREATE INDEX idx_scenario_main_components_component_id ON public.scenario_main_components(main_component_id);

-- Contract Main Components indexes
CREATE INDEX idx_contract_main_components_contract_id ON public.contract_main_components(contract_id);
CREATE INDEX idx_contract_main_components_component_id ON public.contract_main_components(main_component_id);

-- ============================================================================
-- 8. ENABLE ROW LEVEL SECURITY
-- ============================================================================

ALTER TABLE public.scenario_main_components ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.contract_main_components ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- 9. CREATE RLS POLICIES
-- ============================================================================

-- Main Component Categories and Main Components are public readable (no RLS needed for read)

-- Scenario main components inherit from scenario
CREATE POLICY "Users can view scenario components from their company scenarios"
    ON public.scenario_main_components FOR SELECT
    USING (
        scenario_id IN (
            SELECT s.id FROM public.scenarios s
            JOIN public.surveys su ON su.id = s.survey_id
            WHERE su.company_id IN (
                SELECT company_id FROM public.user_profiles WHERE user_id = auth.uid()
            )
        )
    );

CREATE POLICY "Users can manage scenario components from their company scenarios"
    ON public.scenario_main_components FOR ALL
    USING (
        scenario_id IN (
            SELECT s.id FROM public.scenarios s
            JOIN public.surveys su ON su.id = s.survey_id
            WHERE su.company_id IN (
                SELECT company_id FROM public.user_profiles WHERE user_id = auth.uid()
            )
        )
    );

-- Contract main components inherit from contract
CREATE POLICY "Users can view contract components from their company contracts"
    ON public.contract_main_components FOR SELECT
    USING (
        contract_id IN (
            SELECT c.id FROM public.contracts c
            JOIN public.surveys su ON su.id = c.survey_id
            WHERE su.company_id IN (
                SELECT company_id FROM public.user_profiles WHERE user_id = auth.uid()
            )
        )
    );

CREATE POLICY "Users can manage contract components from their company contracts"
    ON public.contract_main_components FOR ALL
    USING (
        contract_id IN (
            SELECT c.id FROM public.contracts c
            JOIN public.surveys su ON su.id = c.survey_id
            WHERE su.company_id IN (
                SELECT company_id FROM public.user_profiles WHERE user_id = auth.uid()
            )
        )
    );

-- ============================================================================
-- 10. GRANT PERMISSIONS
-- ============================================================================

GRANT ALL ON public.main_component_categories TO authenticated;
GRANT ALL ON public.main_components TO authenticated;
GRANT ALL ON public.main_component_category_investments TO authenticated;
GRANT ALL ON public.scenario_main_components TO authenticated;
GRANT ALL ON public.contract_main_components TO authenticated;

-- ============================================================================
-- END OF MIGRATION
-- ============================================================================
