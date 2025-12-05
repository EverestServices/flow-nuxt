-- ============================================================================
-- Migration: Create Contract Pivot Tables
-- Description: Creates pivot tables for contract relationships
-- ============================================================================

-- ============================================================================
-- 1. CONTRACT INVESTMENTS TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.contract_investments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,

    -- Foreign keys
    contract_id UUID NOT NULL REFERENCES public.contracts(id) ON DELETE CASCADE,
    investment_id UUID NOT NULL REFERENCES public.investments(id) ON DELETE CASCADE,

    -- Unique constraint: one investment can appear only once per contract
    UNIQUE(contract_id, investment_id)
);

-- ============================================================================
-- 2. CONTRACT EXTRA COSTS TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.contract_extra_costs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,

    -- Foreign keys
    contract_id UUID NOT NULL REFERENCES public.contracts(id) ON DELETE CASCADE,
    extra_cost_id UUID NOT NULL REFERENCES public.extra_costs(id) ON DELETE CASCADE,

    -- Snapshot data (store the price at the time of contract creation)
    snapshot_price DECIMAL(12, 2) NOT NULL,

    -- Optional fields
    quantity DECIMAL(10, 2), -- For quantity-based extra costs
    comment TEXT, -- For custom notes

    -- Unique constraint: one extra cost can appear only once per contract
    UNIQUE(contract_id, extra_cost_id)
);

-- ============================================================================
-- 3. CONTRACT DISCOUNTS TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.contract_discounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,

    -- Foreign keys
    contract_id UUID NOT NULL REFERENCES public.contracts(id) ON DELETE CASCADE,
    discount_id UUID NOT NULL REFERENCES public.discounts(id) ON DELETE CASCADE,

    -- Snapshot data (store the discount value at the time of contract creation)
    discount_snapshot DECIMAL(12, 2) NOT NULL,

    -- Unique constraint: one discount can appear only once per contract
    UNIQUE(contract_id, discount_id)
);

-- ============================================================================
-- 4. CREATE UPDATED_AT TRIGGERS
-- ============================================================================

CREATE TRIGGER update_contract_investments_updated_at
    BEFORE UPDATE ON public.contract_investments
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_contract_extra_costs_updated_at
    BEFORE UPDATE ON public.contract_extra_costs
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_contract_discounts_updated_at
    BEFORE UPDATE ON public.contract_discounts
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- 5. CREATE INDEXES FOR PERFORMANCE
-- ============================================================================

-- Contract Investments indexes
CREATE INDEX idx_contract_investments_contract_id ON public.contract_investments(contract_id);
CREATE INDEX idx_contract_investments_investment_id ON public.contract_investments(investment_id);

-- Contract Extra Costs indexes
CREATE INDEX idx_contract_extra_costs_contract_id ON public.contract_extra_costs(contract_id);
CREATE INDEX idx_contract_extra_costs_extra_cost_id ON public.contract_extra_costs(extra_cost_id);

-- Contract Discounts indexes
CREATE INDEX idx_contract_discounts_contract_id ON public.contract_discounts(contract_id);
CREATE INDEX idx_contract_discounts_discount_id ON public.contract_discounts(discount_id);

-- ============================================================================
-- 6. ENABLE ROW LEVEL SECURITY
-- ============================================================================

ALTER TABLE public.contract_investments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.contract_extra_costs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.contract_discounts ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- 7. CREATE RLS POLICIES
-- ============================================================================

-- Contract Investments inherit from contract
CREATE POLICY "Users can view contract investments from their company contracts"
    ON public.contract_investments FOR SELECT
    USING (
        contract_id IN (
            SELECT c.id FROM public.contracts c
            WHERE c.survey_id IN (
                SELECT su.id FROM public.surveys su
                WHERE su.company_id IN (
                    SELECT company_id FROM public.user_profiles WHERE user_id = auth.uid()
                )
            )
        )
    );

CREATE POLICY "Users can manage contract investments from their company contracts"
    ON public.contract_investments FOR ALL
    USING (
        contract_id IN (
            SELECT c.id FROM public.contracts c
            WHERE c.survey_id IN (
                SELECT su.id FROM public.surveys su
                WHERE su.company_id IN (
                    SELECT company_id FROM public.user_profiles WHERE user_id = auth.uid()
                )
            )
        )
    );

-- Contract Extra Costs inherit from contract
CREATE POLICY "Users can view contract extra costs from their company contracts"
    ON public.contract_extra_costs FOR SELECT
    USING (
        contract_id IN (
            SELECT c.id FROM public.contracts c
            WHERE c.survey_id IN (
                SELECT su.id FROM public.surveys su
                WHERE su.company_id IN (
                    SELECT company_id FROM public.user_profiles WHERE user_id = auth.uid()
                )
            )
        )
    );

CREATE POLICY "Users can manage contract extra costs from their company contracts"
    ON public.contract_extra_costs FOR ALL
    USING (
        contract_id IN (
            SELECT c.id FROM public.contracts c
            WHERE c.survey_id IN (
                SELECT su.id FROM public.surveys su
                WHERE su.company_id IN (
                    SELECT company_id FROM public.user_profiles WHERE user_id = auth.uid()
                )
            )
        )
    );

-- Contract Discounts inherit from contract
CREATE POLICY "Users can view contract discounts from their company contracts"
    ON public.contract_discounts FOR SELECT
    USING (
        contract_id IN (
            SELECT c.id FROM public.contracts c
            WHERE c.survey_id IN (
                SELECT su.id FROM public.surveys su
                WHERE su.company_id IN (
                    SELECT company_id FROM public.user_profiles WHERE user_id = auth.uid()
                )
            )
        )
    );

CREATE POLICY "Users can manage contract discounts from their company contracts"
    ON public.contract_discounts FOR ALL
    USING (
        contract_id IN (
            SELECT c.id FROM public.contracts c
            WHERE c.survey_id IN (
                SELECT su.id FROM public.surveys su
                WHERE su.company_id IN (
                    SELECT company_id FROM public.user_profiles WHERE user_id = auth.uid()
                )
            )
        )
    );

-- ============================================================================
-- 8. GRANT PERMISSIONS
-- ============================================================================

GRANT ALL ON public.contract_investments TO authenticated;
GRANT ALL ON public.contract_extra_costs TO authenticated;
GRANT ALL ON public.contract_discounts TO authenticated;

-- ============================================================================
-- END OF MIGRATION
-- ============================================================================
