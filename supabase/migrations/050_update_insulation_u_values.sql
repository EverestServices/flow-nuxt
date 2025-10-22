-- Update insulation materials with U-values
-- U-value is calculated as: thermal conductivity (λ) / thickness (meters)
-- Typical λ values: Rockwool 0.038 W/mK, EPS 0.037 W/mK, Mineral wool 0.036-0.037 W/mK

-- Facade Insulation
UPDATE public.main_components
SET u_value = 0.25
WHERE persist_name = 'fi-insul-001'; -- Rockwool 15cm: 0.038/0.15 = 0.25 W/m²K

UPDATE public.main_components
SET u_value = 0.23
WHERE persist_name = 'fi-insul-002'; -- EPS 16cm: 0.037/0.16 = 0.23 W/m²K

UPDATE public.main_components
SET u_value = 0.19
WHERE persist_name = 'fi-insul-003'; -- Rockwool 20cm: 0.038/0.20 = 0.19 W/m²K

UPDATE public.main_components
SET u_value = 0.31
WHERE persist_name = 'fi-insul-004'; -- EPS 12cm: 0.037/0.12 = 0.31 W/m²K

-- Roof Insulation
UPDATE public.main_components
SET u_value = 0.21
WHERE persist_name = 'ri-insul-001'; -- URSA 18cm: 0.037/0.18 = 0.21 W/m²K

UPDATE public.main_components
SET u_value = 0.18
WHERE persist_name = 'ri-insul-002'; -- Knauf 20cm: 0.036/0.20 = 0.18 W/m²K

UPDATE public.main_components
SET u_value = 0.25
WHERE persist_name = 'ri-insul-003'; -- URSA 15cm: 0.037/0.15 = 0.25 W/m²K
