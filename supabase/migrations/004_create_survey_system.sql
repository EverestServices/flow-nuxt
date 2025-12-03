-- ============================================================================
-- Migration: Survey System Data Structure
-- Description: Creates the complete survey system with all entities
-- ============================================================================

-- ============================================================================
-- 1. MODIFY CLIENTS TABLE
-- ============================================================================

-- Drop old address column and add new structured address fields
ALTER TABLE public.clients DROP COLUMN IF EXISTS address;
ALTER TABLE public.clients ADD COLUMN postal_code VARCHAR(20);
ALTER TABLE public.clients ADD COLUMN city VARCHAR(100);
ALTER TABLE public.clients ADD COLUMN street VARCHAR(255);
ALTER TABLE public.clients ADD COLUMN house_number VARCHAR(50);

-- ============================================================================
-- 2. CREATE ENUMS
-- ============================================================================

CREATE TYPE electric_car_status AS ENUM ('existing', 'planned');
CREATE TYPE heavy_consumer_status AS ENUM ('existing', 'planned');
CREATE TYPE survey_question_type AS ENUM (
    'text',
    'textarea',
    'switch',
    'dropdown',
    'title',
    'phase_toggle',
    'dual_toggle',
    'slider',
    'range',
    'number',
    'orientation_selector',
    'warning',
    'calculated'
);

-- ============================================================================
-- 3. CREATE CORE TABLES (NO FOREIGN KEYS YET)
-- ============================================================================

-- Investments table
CREATE TABLE public.investments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    name VARCHAR(255) NOT NULL,
    icon VARCHAR(100),
    position JSONB -- Array stored as JSON
);

-- Surveys table
CREATE TABLE public.surveys (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    client_id UUID NOT NULL REFERENCES public.clients(id) ON DELETE CASCADE,
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL, -- Who created this survey
    company_id UUID NOT NULL, -- Multi-tenant support
    at DATE -- Survey date
);

-- Survey-Investment ManyToMany
CREATE TABLE public.survey_investments (
    survey_id UUID NOT NULL REFERENCES public.surveys(id) ON DELETE CASCADE,
    investment_id UUID NOT NULL REFERENCES public.investments(id) ON DELETE CASCADE,
    PRIMARY KEY (survey_id, investment_id)
);

-- Electric Cars table
CREATE TABLE public.electric_cars (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    survey_id UUID NOT NULL REFERENCES public.surveys(id) ON DELETE CASCADE,
    annual_mileage INTEGER,
    status electric_car_status NOT NULL
);

-- Heavy Consumers table
CREATE TABLE public.heavy_consumers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    name VARCHAR(255) NOT NULL
);

-- Survey-HeavyConsumer ManyToMany with status
CREATE TABLE public.survey_heavy_consumers (
    survey_id UUID NOT NULL REFERENCES public.surveys(id) ON DELETE CASCADE,
    heavy_consumer_id UUID NOT NULL REFERENCES public.heavy_consumers(id) ON DELETE CASCADE,
    status heavy_consumer_status NOT NULL,
    PRIMARY KEY (survey_id, heavy_consumer_id)
);

-- Scenarios table
CREATE TABLE public.scenarios (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    survey_id UUID NOT NULL REFERENCES public.surveys(id) ON DELETE CASCADE
);

-- Scenario-Investment ManyToMany
CREATE TABLE public.scenario_investments (
    scenario_id UUID NOT NULL REFERENCES public.scenarios(id) ON DELETE CASCADE,
    investment_id UUID NOT NULL REFERENCES public.investments(id) ON DELETE CASCADE,
    PRIMARY KEY (scenario_id, investment_id)
);

-- Contracts table
CREATE TABLE public.contracts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    survey_id UUID REFERENCES public.surveys(id) ON DELETE SET NULL, -- Nullable
    client_name VARCHAR(255),
    client_address VARCHAR(500),
    client_phone VARCHAR(50),
    client_email VARCHAR(255),
    birth_place VARCHAR(255),
    date_of_birth DATE,
    id_card_number VARCHAR(50),
    tax_id VARCHAR(50),
    mother_birth_name VARCHAR(255),
    bank_account_number VARCHAR(100),
    citizenship VARCHAR(100),
    marital_status VARCHAR(50),
    residence_card_number VARCHAR(50),
    mailing_address VARCHAR(500)
);

-- Contract-Investment ManyToMany
CREATE TABLE public.contract_investments (
    contract_id UUID NOT NULL REFERENCES public.contracts(id) ON DELETE CASCADE,
    investment_id UUID NOT NULL REFERENCES public.investments(id) ON DELETE CASCADE,
    PRIMARY KEY (contract_id, investment_id)
);

-- Extra Costs table
CREATE TABLE public.extra_costs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    name VARCHAR(255) NOT NULL,
    price DECIMAL(10, 2)
);

-- ExtraCost relations (either scenario OR contract, not both)
CREATE TABLE public.extra_cost_relations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    extra_cost_id UUID NOT NULL REFERENCES public.extra_costs(id) ON DELETE CASCADE,
    scenario_id UUID REFERENCES public.scenarios(id) ON DELETE CASCADE,
    contract_id UUID REFERENCES public.contracts(id) ON DELETE CASCADE,
    snapshot_price DECIMAL(10, 2),
    quantity INTEGER,
    CONSTRAINT check_only_one_relation CHECK (
        (scenario_id IS NOT NULL AND contract_id IS NULL) OR
        (scenario_id IS NULL AND contract_id IS NOT NULL)
    )
);

-- Survey Pages table
CREATE TABLE public.survey_pages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    name VARCHAR(255) NOT NULL,
    position JSONB, -- Array stored as JSON
    type VARCHAR(100)
);

-- Survey-SurveyPage ManyToMany with position
CREATE TABLE public.survey_survey_pages (
    survey_id UUID NOT NULL REFERENCES public.surveys(id) ON DELETE CASCADE,
    survey_page_id UUID NOT NULL REFERENCES public.survey_pages(id) ON DELETE CASCADE,
    position INTEGER NOT NULL,
    PRIMARY KEY (survey_id, survey_page_id)
);

-- Survey Questions table
CREATE TABLE public.survey_questions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    survey_page_id UUID NOT NULL REFERENCES public.survey_pages(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    type survey_question_type NOT NULL,
    default_value TEXT,
    placeholder_value VARCHAR(500),
    options JSONB, -- Array stored as JSON
    is_required BOOLEAN DEFAULT FALSE,
    is_special BOOLEAN DEFAULT FALSE,
    info_message VARCHAR(1000),
    min DECIMAL(10, 2),
    max DECIMAL(10, 2),
    step DECIMAL(10, 2),
    unit VARCHAR(50),
    width INTEGER
);

-- Survey Answers table
CREATE TABLE public.survey_answers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    survey_id UUID NOT NULL REFERENCES public.surveys(id) ON DELETE CASCADE,
    survey_question_id UUID NOT NULL REFERENCES public.survey_questions(id) ON DELETE CASCADE,
    answer TEXT
);

-- Document Categories table
CREATE TABLE public.document_categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    name VARCHAR(255) NOT NULL,
    position JSONB, -- Array stored as JSON
    description TEXT,
    min_photos INTEGER
);

-- Investment-DocumentCategory ManyToMany with position
CREATE TABLE public.investment_document_categories (
    investment_id UUID NOT NULL REFERENCES public.investments(id) ON DELETE CASCADE,
    document_category_id UUID NOT NULL REFERENCES public.document_categories(id) ON DELETE CASCADE,
    position INTEGER NOT NULL,
    PRIMARY KEY (investment_id, document_category_id)
);

-- Documents table
CREATE TABLE public.documents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    survey_id UUID NOT NULL REFERENCES public.surveys(id) ON DELETE CASCADE,
    document_category_id UUID NOT NULL REFERENCES public.document_categories(id) ON DELETE CASCADE,
    name TEXT,
    location TEXT NOT NULL
);

-- ============================================================================
-- 4. CREATE UPDATED_AT TRIGGERS
-- ============================================================================

CREATE TRIGGER update_investments_updated_at
    BEFORE UPDATE ON public.investments
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_surveys_updated_at
    BEFORE UPDATE ON public.surveys
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_electric_cars_updated_at
    BEFORE UPDATE ON public.electric_cars
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_heavy_consumers_updated_at
    BEFORE UPDATE ON public.heavy_consumers
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_scenarios_updated_at
    BEFORE UPDATE ON public.scenarios
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_contracts_updated_at
    BEFORE UPDATE ON public.contracts
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_extra_costs_updated_at
    BEFORE UPDATE ON public.extra_costs
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_survey_pages_updated_at
    BEFORE UPDATE ON public.survey_pages
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_survey_questions_updated_at
    BEFORE UPDATE ON public.survey_questions
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_survey_answers_updated_at
    BEFORE UPDATE ON public.survey_answers
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_document_categories_updated_at
    BEFORE UPDATE ON public.document_categories
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_documents_updated_at
    BEFORE UPDATE ON public.documents
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- 5. CREATE INDEXES FOR PERFORMANCE
-- ============================================================================

-- Surveys indexes
CREATE INDEX idx_surveys_client_id ON public.surveys(client_id);
CREATE INDEX idx_surveys_company_id ON public.surveys(company_id);
CREATE INDEX idx_surveys_user_id ON public.surveys(user_id);

-- Electric Cars indexes
CREATE INDEX idx_electric_cars_survey_id ON public.electric_cars(survey_id);

-- Scenarios indexes
CREATE INDEX idx_scenarios_survey_id ON public.scenarios(survey_id);

-- Contracts indexes
CREATE INDEX idx_contracts_survey_id ON public.contracts(survey_id);

-- Survey Questions indexes
CREATE INDEX idx_survey_questions_page_id ON public.survey_questions(survey_page_id);

-- Survey Answers indexes
CREATE INDEX idx_survey_answers_survey_id ON public.survey_answers(survey_id);
CREATE INDEX idx_survey_answers_question_id ON public.survey_answers(survey_question_id);

-- Documents indexes
CREATE INDEX idx_documents_survey_id ON public.documents(survey_id);
CREATE INDEX idx_documents_category_id ON public.documents(document_category_id);

-- ============================================================================
-- 6. ENABLE ROW LEVEL SECURITY
-- ============================================================================

ALTER TABLE public.surveys ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.electric_cars ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.scenarios ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.contracts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.survey_answers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.documents ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- 7. CREATE RLS POLICIES
-- ============================================================================

-- Surveys policies
CREATE POLICY "Users can view surveys from their company"
    ON public.surveys FOR SELECT
    USING (
        company_id IN (
            SELECT company_id
            FROM public.user_profiles
            WHERE user_id = auth.uid()
        )
    );

CREATE POLICY "Users can insert surveys for their company"
    ON public.surveys FOR INSERT
    WITH CHECK (
        company_id IN (
            SELECT company_id
            FROM public.user_profiles
            WHERE user_id = auth.uid()
        )
    );

CREATE POLICY "Users can update surveys from their company"
    ON public.surveys FOR UPDATE
    USING (
        company_id IN (
            SELECT company_id
            FROM public.user_profiles
            WHERE user_id = auth.uid()
        )
    );

CREATE POLICY "Users can delete surveys from their company"
    ON public.surveys FOR DELETE
    USING (
        company_id IN (
            SELECT company_id
            FROM public.user_profiles
            WHERE user_id = auth.uid()
        )
    );

-- Electric Cars policies (inherit from survey)
CREATE POLICY "Users can view electric cars from their company surveys"
    ON public.electric_cars FOR SELECT
    USING (
        survey_id IN (
            SELECT id FROM public.surveys
            WHERE company_id IN (
                SELECT company_id FROM public.user_profiles WHERE user_id = auth.uid()
            )
        )
    );

CREATE POLICY "Users can manage electric cars from their company surveys"
    ON public.electric_cars FOR ALL
    USING (
        survey_id IN (
            SELECT id FROM public.surveys
            WHERE company_id IN (
                SELECT company_id FROM public.user_profiles WHERE user_id = auth.uid()
            )
        )
    );

-- Scenarios policies (inherit from survey)
CREATE POLICY "Users can view scenarios from their company surveys"
    ON public.scenarios FOR SELECT
    USING (
        survey_id IN (
            SELECT id FROM public.surveys
            WHERE company_id IN (
                SELECT company_id FROM public.user_profiles WHERE user_id = auth.uid()
            )
        )
    );

CREATE POLICY "Users can manage scenarios from their company surveys"
    ON public.scenarios FOR ALL
    USING (
        survey_id IN (
            SELECT id FROM public.surveys
            WHERE company_id IN (
                SELECT company_id FROM public.user_profiles WHERE user_id = auth.uid()
            )
        )
    );

-- Contracts policies (inherit from survey)
CREATE POLICY "Users can view contracts from their company surveys"
    ON public.contracts FOR SELECT
    USING (
        survey_id IN (
            SELECT id FROM public.surveys
            WHERE company_id IN (
                SELECT company_id FROM public.user_profiles WHERE user_id = auth.uid()
            )
        )
        OR survey_id IS NULL -- Allow viewing contracts not linked to surveys
    );

CREATE POLICY "Users can manage contracts"
    ON public.contracts FOR ALL
    USING (
        survey_id IN (
            SELECT id FROM public.surveys
            WHERE company_id IN (
                SELECT company_id FROM public.user_profiles WHERE user_id = auth.uid()
            )
        )
        OR survey_id IS NULL
    );

-- Survey Answers policies (inherit from survey)
CREATE POLICY "Users can view survey answers from their company surveys"
    ON public.survey_answers FOR SELECT
    USING (
        survey_id IN (
            SELECT id FROM public.surveys
            WHERE company_id IN (
                SELECT company_id FROM public.user_profiles WHERE user_id = auth.uid()
            )
        )
    );

CREATE POLICY "Users can manage survey answers from their company surveys"
    ON public.survey_answers FOR ALL
    USING (
        survey_id IN (
            SELECT id FROM public.surveys
            WHERE company_id IN (
                SELECT company_id FROM public.user_profiles WHERE user_id = auth.uid()
            )
        )
    );

-- Documents policies (inherit from survey)
CREATE POLICY "Users can view documents from their company surveys"
    ON public.documents FOR SELECT
    USING (
        survey_id IN (
            SELECT id FROM public.surveys
            WHERE company_id IN (
                SELECT company_id FROM public.user_profiles WHERE user_id = auth.uid()
            )
        )
    );

CREATE POLICY "Users can manage documents from their company surveys"
    ON public.documents FOR ALL
    USING (
        survey_id IN (
            SELECT id FROM public.surveys
            WHERE company_id IN (
                SELECT company_id FROM public.user_profiles WHERE user_id = auth.uid()
            )
        )
    );

-- ============================================================================
-- 8. GRANT PERMISSIONS
-- ============================================================================

GRANT ALL ON public.investments TO authenticated;
GRANT ALL ON public.surveys TO authenticated;
GRANT ALL ON public.survey_investments TO authenticated;
GRANT ALL ON public.electric_cars TO authenticated;
GRANT ALL ON public.heavy_consumers TO authenticated;
GRANT ALL ON public.survey_heavy_consumers TO authenticated;
GRANT ALL ON public.scenarios TO authenticated;
GRANT ALL ON public.scenario_investments TO authenticated;
GRANT ALL ON public.contracts TO authenticated;
GRANT ALL ON public.contract_investments TO authenticated;
GRANT ALL ON public.extra_costs TO authenticated;
GRANT ALL ON public.extra_cost_relations TO authenticated;
GRANT ALL ON public.survey_pages TO authenticated;
GRANT ALL ON public.survey_survey_pages TO authenticated;
GRANT ALL ON public.survey_questions TO authenticated;
GRANT ALL ON public.survey_answers TO authenticated;
GRANT ALL ON public.document_categories TO authenticated;
GRANT ALL ON public.investment_document_categories TO authenticated;
GRANT ALL ON public.documents TO authenticated;
