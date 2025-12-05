-- Migration: Add RLS policies for scenario_extra_costs and scenario_discounts
-- Description: Row Level Security policies for scenario pivot tables
-- Dependencies: 086_create_scenario_extra_costs_table.sql, 087_create_scenario_discounts_table.sql, 080_add_rls_policies.sql

-- =============================================================================
-- ENABLE ROW LEVEL SECURITY
-- =============================================================================

ALTER TABLE public.scenario_extra_costs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.scenario_discounts ENABLE ROW LEVEL SECURITY;

-- =============================================================================
-- RLS POLICIES FOR SCENARIO_EXTRA_COSTS
-- =============================================================================

CREATE POLICY "Users can manage scenario extra costs from their company scenarios"
ON public.scenario_extra_costs
USING (
  scenario_id IN (
    SELECT s.id
    FROM public.scenarios s
    JOIN public.surveys su ON (su.id = s.survey_id)
    WHERE su.company_id IN (
      SELECT user_profiles.company_id
      FROM public.user_profiles
      WHERE user_profiles.user_id = auth.uid()
    )
  )
);

CREATE POLICY "Users can view scenario extra costs from their company scenarios"
ON public.scenario_extra_costs
FOR SELECT
USING (
  scenario_id IN (
    SELECT s.id
    FROM public.scenarios s
    JOIN public.surveys su ON (su.id = s.survey_id)
    WHERE su.company_id IN (
      SELECT user_profiles.company_id
      FROM public.user_profiles
      WHERE user_profiles.user_id = auth.uid()
    )
  )
);

-- =============================================================================
-- RLS POLICIES FOR SCENARIO_DISCOUNTS
-- =============================================================================

CREATE POLICY "Users can manage scenario discounts from their company scenarios"
ON public.scenario_discounts
USING (
  scenario_id IN (
    SELECT s.id
    FROM public.scenarios s
    JOIN public.surveys su ON (su.id = s.survey_id)
    WHERE su.company_id IN (
      SELECT user_profiles.company_id
      FROM public.user_profiles
      WHERE user_profiles.user_id = auth.uid()
    )
  )
);

CREATE POLICY "Users can view scenario discounts from their company scenarios"
ON public.scenario_discounts
FOR SELECT
USING (
  scenario_id IN (
    SELECT s.id
    FROM public.scenarios s
    JOIN public.surveys su ON (su.id = s.survey_id)
    WHERE su.company_id IN (
      SELECT user_profiles.company_id
      FROM public.user_profiles
      WHERE user_profiles.user_id = auth.uid()
    )
  )
);
