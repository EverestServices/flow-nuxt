-- Update solar panel efficiency values
-- Solar panels typically have 18-22% efficiency depending on technology and manufacturer

UPDATE public.main_components
SET efficiency = 20.5
WHERE persist_name = 'sp-panel-001'; -- Longi LR5-54HPH 425W (high efficiency monocrystalline)

UPDATE public.main_components
SET efficiency = 20.0
WHERE persist_name = 'sp-panel-002'; -- JA Solar JAM54S31 410W (PERC monocrystalline)

UPDATE public.main_components
SET efficiency = 21.0
WHERE persist_name = 'sp-panel-003'; -- Trina Solar TSM-430DE09.08 (high power monocrystalline)

UPDATE public.main_components
SET efficiency = 21.2
WHERE persist_name = 'sp-panel-004'; -- Longi LR5-72HPH 540W (commercial grade, high efficiency)

UPDATE public.main_components
SET efficiency = 19.8
WHERE persist_name = 'sp-panel-005'; -- JA Solar JAM72S20 450W (large format monocrystalline)
