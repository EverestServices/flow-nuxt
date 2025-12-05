-- Migration: Add RLS Policies, Triggers, and Functions
-- Description: Row Level Security policies and automation for all tables
-- Dependencies: All structure migrations (400-433)

-- =============================================================================
-- ENABLE ROW LEVEL SECURITY
-- =============================================================================

ALTER TABLE public.clients ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.surveys ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.scenarios ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.contracts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.survey_answers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.survey_subsidies ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.scenario_main_components ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.contract_investments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.contract_main_components ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.contract_extra_costs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.contract_discounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.monthly_climate_data ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.discounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subsidies ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.survey_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.companies ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.external_sync_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.electric_cars ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.measure_walls ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.measure_wall_images ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.measure_polygons ENABLE ROW LEVEL SECURITY;

-- =============================================================================
-- FUNCTIONS
-- =============================================================================


-- =============================================================================
-- TRIGGERS
-- =============================================================================


-- =============================================================================
-- RLS POLICIES
-- =============================================================================

CREATE POLICY "Users can delete clients from their company" ON public.clients FOR DELETE USING ((company_id IN ( SELECT user_profiles.company_id
   FROM public.user_profiles
  WHERE (user_profiles.user_id = auth.uid()))));

CREATE POLICY "Users can insert clients for their company" ON public.clients FOR INSERT WITH CHECK ((company_id IN ( SELECT user_profiles.company_id
   FROM public.user_profiles
  WHERE (user_profiles.user_id = auth.uid()))));

CREATE POLICY "Users can update clients from their company" ON public.clients FOR UPDATE USING ((company_id IN ( SELECT user_profiles.company_id
   FROM public.user_profiles
  WHERE (user_profiles.user_id = auth.uid()))));

CREATE POLICY "Users can view clients from their company" ON public.clients FOR SELECT USING ((company_id IN ( SELECT user_profiles.company_id
   FROM public.user_profiles
  WHERE (user_profiles.user_id = auth.uid()))));

CREATE POLICY "Users can delete surveys from their company" ON public.surveys FOR DELETE USING ((company_id IN ( SELECT user_profiles.company_id
   FROM public.user_profiles
  WHERE (user_profiles.user_id = auth.uid()))));

CREATE POLICY "Users can insert surveys for their company" ON public.surveys FOR INSERT WITH CHECK ((company_id IN ( SELECT user_profiles.company_id
   FROM public.user_profiles
  WHERE (user_profiles.user_id = auth.uid()))));

CREATE POLICY "Users can update surveys from their company" ON public.surveys FOR UPDATE USING ((company_id IN ( SELECT user_profiles.company_id
   FROM public.user_profiles
  WHERE (user_profiles.user_id = auth.uid()))));

CREATE POLICY "Users can view surveys from their company" ON public.surveys FOR SELECT USING ((company_id IN ( SELECT user_profiles.company_id
   FROM public.user_profiles
  WHERE (user_profiles.user_id = auth.uid()))));

CREATE POLICY "Users can manage scenarios from their company surveys" ON public.scenarios USING ((survey_id IN ( SELECT surveys.id
   FROM public.surveys
  WHERE (surveys.company_id IN ( SELECT user_profiles.company_id
           FROM public.user_profiles
          WHERE (user_profiles.user_id = auth.uid()))))));

CREATE POLICY "Users can view scenarios from their company surveys" ON public.scenarios FOR SELECT USING ((survey_id IN ( SELECT surveys.id
   FROM public.surveys
  WHERE (surveys.company_id IN ( SELECT user_profiles.company_id
           FROM public.user_profiles
          WHERE (user_profiles.user_id = auth.uid()))))));

CREATE POLICY "Users can manage electric cars from their company surveys" ON public.electric_cars USING ((survey_id IN ( SELECT surveys.id
   FROM public.surveys
  WHERE (surveys.company_id IN ( SELECT user_profiles.company_id
           FROM public.user_profiles
          WHERE (user_profiles.user_id = auth.uid()))))));

CREATE POLICY "Users can view electric cars from their company surveys" ON public.electric_cars FOR SELECT USING ((survey_id IN ( SELECT surveys.id
   FROM public.surveys
  WHERE (surveys.company_id IN ( SELECT user_profiles.company_id
           FROM public.user_profiles
          WHERE (user_profiles.user_id = auth.uid()))))));

CREATE POLICY "Users can manage contracts" ON public.contracts USING (((survey_id IN ( SELECT surveys.id
   FROM public.surveys
  WHERE (surveys.company_id IN ( SELECT user_profiles.company_id
           FROM public.user_profiles
          WHERE (user_profiles.user_id = auth.uid()))))) OR (survey_id IS NULL)));

CREATE POLICY "Users can view contracts from their company surveys" ON public.contracts FOR SELECT USING (((survey_id IN ( SELECT surveys.id
   FROM public.surveys
  WHERE (surveys.company_id IN ( SELECT user_profiles.company_id
           FROM public.user_profiles
          WHERE (user_profiles.user_id = auth.uid()))))) OR (survey_id IS NULL)));

CREATE POLICY "Users can manage documents from their company surveys" ON public.documents USING ((survey_id IN ( SELECT surveys.id
   FROM public.surveys
  WHERE (surveys.company_id IN ( SELECT user_profiles.company_id
           FROM public.user_profiles
          WHERE (user_profiles.user_id = auth.uid()))))));

CREATE POLICY "Users can view documents from their company surveys" ON public.documents FOR SELECT USING ((survey_id IN ( SELECT surveys.id
   FROM public.surveys
  WHERE (surveys.company_id IN ( SELECT user_profiles.company_id
           FROM public.user_profiles
          WHERE (user_profiles.user_id = auth.uid()))))));

CREATE POLICY "Users can manage survey answers from their company surveys" ON public.survey_answers USING ((survey_id IN ( SELECT surveys.id
   FROM public.surveys
  WHERE (surveys.company_id IN ( SELECT user_profiles.company_id
           FROM public.user_profiles
          WHERE (user_profiles.user_id = auth.uid()))))));

CREATE POLICY "Users can view survey answers from their company surveys" ON public.survey_answers FOR SELECT USING ((survey_id IN ( SELECT surveys.id
   FROM public.surveys
  WHERE (surveys.company_id IN ( SELECT user_profiles.company_id
           FROM public.user_profiles
          WHERE (user_profiles.user_id = auth.uid()))))));

CREATE POLICY "Users can delete survey subsidies for their company's surveys" ON public.survey_subsidies FOR DELETE TO authenticated USING ((survey_id IN ( SELECT surveys.id
   FROM public.surveys
  WHERE (surveys.company_id IN ( SELECT user_profiles.company_id
           FROM public.user_profiles
          WHERE (user_profiles.user_id = auth.uid()))))));

CREATE POLICY "Users can insert survey subsidies for their company's surveys" ON public.survey_subsidies FOR INSERT TO authenticated WITH CHECK ((survey_id IN ( SELECT surveys.id
   FROM public.surveys
  WHERE (surveys.company_id IN ( SELECT user_profiles.company_id
           FROM public.user_profiles
          WHERE (user_profiles.user_id = auth.uid()))))));

CREATE POLICY "Users can update survey subsidies for their company's surveys" ON public.survey_subsidies FOR UPDATE TO authenticated USING ((survey_id IN ( SELECT surveys.id
   FROM public.surveys
  WHERE (surveys.company_id IN ( SELECT user_profiles.company_id
           FROM public.user_profiles
          WHERE (user_profiles.user_id = auth.uid())))))) WITH CHECK ((survey_id IN ( SELECT surveys.id
   FROM public.surveys
  WHERE (surveys.company_id IN ( SELECT user_profiles.company_id
           FROM public.user_profiles
          WHERE (user_profiles.user_id = auth.uid()))))));

CREATE POLICY "Users can view survey subsidies from their company" ON public.survey_subsidies FOR SELECT TO authenticated USING ((survey_id IN ( SELECT surveys.id
   FROM public.surveys
  WHERE (surveys.company_id IN ( SELECT user_profiles.company_id
           FROM public.user_profiles
          WHERE (user_profiles.user_id = auth.uid()))))));

CREATE POLICY "Users can manage scenario components from their company scenari" ON public.scenario_main_components USING ((scenario_id IN ( SELECT s.id
   FROM (public.scenarios s
     JOIN public.surveys su ON ((su.id = s.survey_id)))
  WHERE (su.company_id IN ( SELECT user_profiles.company_id
           FROM public.user_profiles
          WHERE (user_profiles.user_id = auth.uid()))))));

CREATE POLICY "Users can view scenario components from their company scenarios" ON public.scenario_main_components FOR SELECT USING ((scenario_id IN ( SELECT s.id
   FROM (public.scenarios s
     JOIN public.surveys su ON ((su.id = s.survey_id)))
  WHERE (su.company_id IN ( SELECT user_profiles.company_id
           FROM public.user_profiles
          WHERE (user_profiles.user_id = auth.uid()))))));

CREATE POLICY "Users can manage contract investments from their company contra" ON public.contract_investments USING ((contract_id IN ( SELECT c.id
   FROM public.contracts c
  WHERE (c.survey_id IN ( SELECT su.id
           FROM public.surveys su
          WHERE (su.company_id IN ( SELECT user_profiles.company_id
                   FROM public.user_profiles
                  WHERE (user_profiles.user_id = auth.uid()))))))));

CREATE POLICY "Users can view contract investments from their company contract" ON public.contract_investments FOR SELECT USING ((contract_id IN ( SELECT c.id
   FROM public.contracts c
  WHERE (c.survey_id IN ( SELECT su.id
           FROM public.surveys su
          WHERE (su.company_id IN ( SELECT user_profiles.company_id
                   FROM public.user_profiles
                  WHERE (user_profiles.user_id = auth.uid()))))))));

CREATE POLICY "Users can manage contract components from their company contrac" ON public.contract_main_components USING ((contract_id IN ( SELECT c.id
   FROM (public.contracts c
     JOIN public.surveys su ON ((su.id = c.survey_id)))
  WHERE (su.company_id IN ( SELECT user_profiles.company_id
           FROM public.user_profiles
          WHERE (user_profiles.user_id = auth.uid()))))));

CREATE POLICY "Users can view contract components from their company contracts" ON public.contract_main_components FOR SELECT USING ((contract_id IN ( SELECT c.id
   FROM (public.contracts c
     JOIN public.surveys su ON ((su.id = c.survey_id)))
  WHERE (su.company_id IN ( SELECT user_profiles.company_id
           FROM public.user_profiles
          WHERE (user_profiles.user_id = auth.uid()))))));

CREATE POLICY "Users can manage contract extra costs from their company contra" ON public.contract_extra_costs USING ((contract_id IN ( SELECT c.id
   FROM public.contracts c
  WHERE (c.survey_id IN ( SELECT su.id
           FROM public.surveys su
          WHERE (su.company_id IN ( SELECT user_profiles.company_id
                   FROM public.user_profiles
                  WHERE (user_profiles.user_id = auth.uid()))))))));

CREATE POLICY "Users can view contract extra costs from their company contract" ON public.contract_extra_costs FOR SELECT USING ((contract_id IN ( SELECT c.id
   FROM public.contracts c
  WHERE (c.survey_id IN ( SELECT su.id
           FROM public.surveys su
          WHERE (su.company_id IN ( SELECT user_profiles.company_id
                   FROM public.user_profiles
                  WHERE (user_profiles.user_id = auth.uid()))))))));

CREATE POLICY "Users can manage contract discounts from their company contract" ON public.contract_discounts USING ((contract_id IN ( SELECT c.id
   FROM public.contracts c
  WHERE (c.survey_id IN ( SELECT su.id
           FROM public.surveys su
          WHERE (su.company_id IN ( SELECT user_profiles.company_id
                   FROM public.user_profiles
                  WHERE (user_profiles.user_id = auth.uid()))))))));

CREATE POLICY "Users can view contract discounts from their company contracts" ON public.contract_discounts FOR SELECT USING ((contract_id IN ( SELECT c.id
   FROM public.contracts c
  WHERE (c.survey_id IN ( SELECT su.id
           FROM public.surveys su
          WHERE (su.company_id IN ( SELECT user_profiles.company_id
                   FROM public.user_profiles
                  WHERE (user_profiles.user_id = auth.uid()))))))));

CREATE POLICY "Allow read access to all authenticated users" ON public.monthly_climate_data FOR SELECT TO authenticated USING (true);

CREATE POLICY "Allow authenticated users to read discounts" ON public.discounts FOR SELECT TO authenticated USING (true);

CREATE POLICY "Subsidies are viewable by all authenticated users" ON public.subsidies FOR SELECT TO authenticated USING (true);

CREATE POLICY "Allow admin users to modify settings" ON public.survey_settings TO authenticated USING (((auth.jwt() ->> 'role'::text) = 'admin'::text)) WITH CHECK (((auth.jwt() ->> 'role'::text) = 'admin'::text));

CREATE POLICY "Allow read access to all authenticated users" ON public.survey_settings FOR SELECT TO authenticated USING (true);

CREATE POLICY "System can insert sync logs" ON public.external_sync_logs FOR INSERT WITH CHECK (true);

CREATE POLICY "Users can view their own sync logs" ON public.external_sync_logs FOR SELECT USING ((user_id = auth.uid()));


-- Measure walls policies (company-scoped via surveys)
CREATE POLICY "Measure: select walls by company" ON public.measure_walls FOR SELECT USING ((survey_id IN ( SELECT surveys.id
   FROM public.surveys
  WHERE (surveys.company_id IN ( SELECT user_profiles.company_id
           FROM public.user_profiles
          WHERE (user_profiles.user_id = auth.uid()))))));

CREATE POLICY "Measure: manage walls by company" ON public.measure_walls USING ((survey_id IN ( SELECT surveys.id
   FROM public.surveys
  WHERE (surveys.company_id IN ( SELECT user_profiles.company_id
           FROM public.user_profiles
          WHERE (user_profiles.user_id = auth.uid())))))) WITH CHECK ((survey_id IN ( SELECT surveys.id
   FROM public.surveys
  WHERE (surveys.company_id IN ( SELECT user_profiles.company_id
           FROM public.user_profiles
          WHERE (user_profiles.user_id = auth.uid()))))));

-- Measure wall images policies (company-scoped via measure_walls -> surveys)
CREATE POLICY "Measure: select images by company" ON public.measure_wall_images FOR SELECT USING ((wall_id IN ( SELECT mw.id
   FROM (public.measure_walls mw
     JOIN public.surveys s ON ((s.id = mw.survey_id)))
  WHERE (s.company_id IN ( SELECT user_profiles.company_id
           FROM public.user_profiles
          WHERE (user_profiles.user_id = auth.uid()))))));

CREATE POLICY "Measure: manage images by company" ON public.measure_wall_images USING ((wall_id IN ( SELECT mw.id
   FROM (public.measure_walls mw
     JOIN public.surveys s ON ((s.id = mw.survey_id)))
  WHERE (s.company_id IN ( SELECT user_profiles.company_id
           FROM public.user_profiles
          WHERE (user_profiles.user_id = auth.uid())))))) WITH CHECK ((wall_id IN ( SELECT mw.id
   FROM (public.measure_walls mw
     JOIN public.surveys s ON ((s.id = mw.survey_id)))
  WHERE (s.company_id IN ( SELECT user_profiles.company_id
           FROM public.user_profiles
          WHERE (user_profiles.user_id = auth.uid()))))));

-- Measure polygons policies (company-scoped via measure_walls -> surveys)
CREATE POLICY "Measure: select polygons by company" ON public.measure_polygons FOR SELECT USING ((wall_id IN ( SELECT mw.id
   FROM (public.measure_walls mw
     JOIN public.surveys s ON ((s.id = mw.survey_id)))
  WHERE (s.company_id IN ( SELECT user_profiles.company_id
           FROM public.user_profiles
          WHERE (user_profiles.user_id = auth.uid()))))));

CREATE POLICY "Measure: manage polygons by company" ON public.measure_polygons USING ((wall_id IN ( SELECT mw.id
   FROM (public.measure_walls mw
     JOIN public.surveys s ON ((s.id = mw.survey_id)))
  WHERE (s.company_id IN ( SELECT user_profiles.company_id
           FROM public.user_profiles
          WHERE (user_profiles.user_id = auth.uid())))))) WITH CHECK ((wall_id IN ( SELECT mw.id
   FROM (public.measure_walls mw
     JOIN public.surveys s ON ((s.id = mw.survey_id)))
  WHERE (s.company_id IN ( SELECT user_profiles.company_id
           FROM public.user_profiles
          WHERE (user_profiles.user_id = auth.uid()))))));

-- Companies policies
CREATE POLICY "Users can view own company" ON public.companies FOR SELECT USING ((id IN ( SELECT user_profiles.company_id
   FROM public.user_profiles
  WHERE (user_profiles.user_id = auth.uid()))));
