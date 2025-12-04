-- Seed survey_settings with default configuration values for energy calculations

-- Solar panel calculation settings
INSERT INTO public.survey_settings (persist_name, value, description) VALUES
('solar_irradiance_annual', '1200', 'Annual solar irradiance in Hungary (kWh/m²/year)'),
('solar_performance_ratio', '0.80', 'System performance ratio accounting for losses (inverter, cables, temperature, soiling) - typically 75-85%');

-- Energy conversion factors
INSERT INTO public.survey_settings (persist_name, value, description) VALUES
('gas_energy_conversion', '10.55', 'Energy content of natural gas (kWh thermal energy per m³)');

-- Heating calculation settings
INSERT INTO public.survey_settings (persist_name, value, description) VALUES
('heating_degree_days', '3200', 'Annual heating degree days for Hungary (typical value for Central Europe)');

-- Heating system efficiency values
INSERT INTO public.survey_settings (persist_name, value, description) VALUES
('heating_efficiency_open_flue', '0.85', 'Efficiency of open flue boiler (Nyílt égésterű kazán)'),
('heating_efficiency_condensing', '0.95', 'Efficiency of condensing boiler (Kondenzációs kazán)'),
('heating_efficiency_convector', '1.00', 'Efficiency of electric convector heating (Konvektor)'),
('heating_efficiency_mixed_fuel', '0.85', 'Efficiency of mixed fuel boiler (Vegyestüzelésű kazán)'),
('heating_efficiency_default', '0.90', 'Default heating efficiency when type is unknown or other');

-- Emission factors
INSERT INTO public.survey_settings (persist_name, value, description) VALUES
('emission_factor_electricity', '0.27', 'CO₂ emission factor for Hungarian electricity grid (kg CO₂/kWh)'),
('emission_factor_gas_m3', '1.98', 'CO₂ emission factor for natural gas (kg CO₂/m³)'),
('emission_factor_gas_kwh', '0.202', 'CO₂ emission factor for natural gas (kg CO₂/kWh)');

-- Wall U-values (uninsulated state) - mapped to wall_type survey question options
INSERT INTO public.survey_settings (persist_name, value, description) VALUES
('u_value_wall_small_brick', '1.7', 'U-value for small solid brick wall (Kis méretű tömör tégla) - W/m²K'),
('u_value_wall_lime_sand', '1.6', 'U-value for lime-sand brick wall (Mészhomok tégla) - W/m²K'),
('u_value_wall_b30', '1.4', 'U-value for B30 brick wall - W/m²K'),
('u_value_wall_poroton', '0.8', 'U-value for Poroton brick wall - W/m²K'),
('u_value_wall_gas_silicate', '0.6', 'U-value for gas silicate wall (Gázsilikát) - W/m²K'),
('u_value_wall_bautherm', '0.7', 'U-value for Bautherm brick wall - W/m²K'),
('u_value_wall_porotherm', '0.5', 'U-value for Porotherm N+F brick wall - W/m²K'),
('u_value_wall_ytong', '0.6', 'U-value for Ytong brick wall - W/m²K'),
('u_value_wall_concrete_panel', '1.8', 'U-value for reinforced concrete panel (Vasbeton panel) - W/m²K'),
('u_value_wall_wattle', '1.5', 'U-value for wattle and daub wall (Vályog) - W/m²K'),
('u_value_wall_lightweight', '0.9', 'U-value for lightweight structure wall (Könnyűszerkezetes) - W/m²K');

-- Roof U-values (uninsulated state)
INSERT INTO public.survey_settings (persist_name, value, description) VALUES
('u_value_roof_uninsulated_hipped', '1.5', 'U-value for uninsulated hipped roof (Sátortető) - W/m²K'),
('u_value_roof_uninsulated_flat', '1.8', 'U-value for uninsulated flat roof (Lapostető) - W/m²K');

-- Window U-values by material and glazing type
-- Wood windows
INSERT INTO public.survey_settings (persist_name, value, description) VALUES
('u_value_window_wood_single', '5.0', 'U-value for wood window with single-pane glazing - W/m²K'),
('u_value_window_wood_double', '2.8', 'U-value for wood window with double-pane glazing - W/m²K'),
('u_value_window_wood_triple', '1.8', 'U-value for wood window with triple-pane glazing - W/m²K');

-- Plastic (PVC) windows
INSERT INTO public.survey_settings (persist_name, value, description) VALUES
('u_value_window_plastic_single', '4.8', 'U-value for plastic window with single-pane glazing - W/m²K'),
('u_value_window_plastic_double', '2.0', 'U-value for plastic window with double-pane glazing - W/m²K'),
('u_value_window_plastic_triple', '1.3', 'U-value for plastic window with triple-pane glazing - W/m²K');

-- Metal windows
INSERT INTO public.survey_settings (persist_name, value, description) VALUES
('u_value_window_metal_single', '5.8', 'U-value for metal window with single-pane glazing - W/m²K'),
('u_value_window_metal_double', '3.0', 'U-value for metal window with double-pane glazing - W/m²K'),
('u_value_window_metal_triple', '2.0', 'U-value for metal window with triple-pane glazing - W/m²K');
