-- ============================================================================
-- Migration: Seed Products Catalog
-- Description: Populates the products table with comprehensive product data
-- ============================================================================

-- ============================================================================
-- 1. SOLAR PANEL PRODUCTS
-- ============================================================================

-- Category: panel (Solar Panels)
INSERT INTO public.products (persist_name, name, unit, price, investment_type, category, manufacturer, details, power) VALUES
    ('sp-panel-001', 'Longi LR5-54HPH 425W', 'pcs', 70000, 'solarPanel', 'panel', 'Longi', 'High efficiency monocrystalline solar panel', 425),
    ('sp-panel-002', 'JA Solar JAM54S31 410W', 'pcs', 68000, 'solarPanel', 'panel', 'JA Solar', 'Monocrystalline PERC solar panel', 410),
    ('sp-panel-003', 'Trina Solar TSM-430DE09.08', 'pcs', 72000, 'solarPanel', 'panel', 'Trina Solar', 'High power monocrystalline module', 430),
    ('sp-panel-004', 'Longi LR5-72HPH 540W', 'pcs', 85000, 'solarPanel', 'panel', 'Longi', 'High power commercial grade panel', 540),
    ('sp-panel-005', 'JA Solar JAM72S20 450W', 'pcs', 75000, 'solarPanel', 'panel', 'JA Solar', 'Large format monocrystalline panel', 450)
ON CONFLICT (persist_name) DO NOTHING;

-- Category: inverter (Inverters)
INSERT INTO public.products (persist_name, name, unit, price, investment_type, category, manufacturer, details, power) VALUES
    ('sp-inverter-001', 'Solax X1 Hybrid 6.0-D', 'pcs', 680000, 'solarPanel', 'inverter', 'Solax', 'Hybrid inverter with battery ready', 6000),
    ('sp-inverter-002', 'Huawei SUN2000-8KTL-M1', 'pcs', 750000, 'solarPanel', 'inverter', 'Huawei', 'String inverter with smart monitoring', 8000),
    ('sp-inverter-003', 'Fronius Symo 10.0-3-M', 'pcs', 920000, 'solarPanel', 'inverter', 'Fronius', 'Three-phase string inverter', 10000),
    ('sp-inverter-004', 'Solax X3 Hybrid 10.0-D', 'pcs', 850000, 'solarPanel', 'inverter', 'Solax', 'Three-phase hybrid inverter', 10000),
    ('sp-inverter-005', 'Huawei SUN2000-6KTL-L1', 'pcs', 720000, 'solarPanel', 'inverter', 'Huawei', 'Compact string inverter', 6000)
ON CONFLICT (persist_name) DO NOTHING;

-- Category: mounting (Mounting Systems)
INSERT INTO public.products (persist_name, name, unit, price, investment_type, category, manufacturer, details) VALUES
    ('sp-mounting-001', 'K2 Systems SingleRail', 'sets', 250000, 'solarPanel', 'mounting', 'K2 Systems', 'Complete mounting system for pitched roof'),
    ('sp-mounting-002', 'K2 Systems CrossRail', 'sets', 280000, 'solarPanel', 'mounting', 'K2 Systems', 'Cross-rail mounting for tile roofs'),
    ('sp-mounting-003', 'K2 Systems FlatRoof', 'sets', 320000, 'solarPanel', 'mounting', 'K2 Systems', 'Ballast system for flat roofs')
ON CONFLICT (persist_name) DO NOTHING;

-- Category: regulator (Power Regulators)
INSERT INTO public.products (persist_name, name, unit, price, investment_type, category, manufacturer, details) VALUES
    ('sp-regulator-001', 'NORD Power Regulator', 'pcs', 180000, 'solarPanel', 'regulator', 'NORD', 'Dynamic power limiter')
ON CONFLICT (persist_name) DO NOTHING;

-- Category: ac_surge_protector (AC Surge Protection)
INSERT INTO public.products (persist_name, name, unit, price, investment_type, category, manufacturer, details) VALUES
    ('sp-ac-surge-001', 'Hager SPD Type 1+2', 'pcs', 45000, 'solarPanel', 'ac_surge_protector', 'Hager', 'Combined surge protection device'),
    ('sp-ac-surge-002', 'Hager SPD Type 2', 'pcs', 35000, 'solarPanel', 'ac_surge_protector', 'Hager', 'Standard surge protection')
ON CONFLICT (persist_name) DO NOTHING;

-- Category: dc_surge_protector (DC Surge Protection)
INSERT INTO public.products (persist_name, name, unit, price, investment_type, category, manufacturer, details) VALUES
    ('sp-dc-surge-001', 'Phoenix Contact Type 2 DC', 'pcs', 55000, 'solarPanel', 'dc_surge_protector', 'Phoenix Contact', 'DC surge protection for solar arrays'),
    ('sp-dc-surge-002', 'Phoenix Contact Type 1+2 DC', 'pcs', 72000, 'solarPanel', 'dc_surge_protector', 'Phoenix Contact', 'Combined DC surge protection')
ON CONFLICT (persist_name) DO NOTHING;

-- Category: optimizer (Power Optimizers)
INSERT INTO public.products (persist_name, name, unit, price, investment_type, category, manufacturer, details, power) VALUES
    ('sp-optimizer-001', 'TIGO TS4-A-O', 'pcs', 28000, 'solarPanel', 'optimizer', 'TIGO', 'Module-level power optimizer', 700),
    ('sp-optimizer-002', 'TIGO TS4-A-2F', 'pcs', 32000, 'solarPanel', 'optimizer', 'TIGO', 'Optimizer with rapid shutdown', 700)
ON CONFLICT (persist_name) DO NOTHING;

-- Category: rapid_shutdown (Rapid Shutdown Devices)
INSERT INTO public.products (persist_name, name, unit, price, investment_type, category, manufacturer, details) VALUES
    ('sp-rapid-001', 'TIGO TS4-A-S', 'pcs', 25000, 'solarPanel', 'rapid_shutdown', 'TIGO', 'Rapid shutdown device for safety')
ON CONFLICT (persist_name) DO NOTHING;

-- ============================================================================
-- 2. BATTERY PRODUCTS
-- ============================================================================

INSERT INTO public.products (persist_name, name, unit, price, investment_type, category, manufacturer, details, capacity) VALUES
    ('battery-001', 'BYD Battery-Box Premium HVS 10.2', 'pcs', 2800000, 'battery', 'battery', 'BYD', 'High voltage lithium battery system', 10.2),
    ('battery-002', 'LG RESU 10H', 'pcs', 2950000, 'battery', 'battery', 'LG', 'High voltage residential battery', 9.6),
    ('battery-003', 'Huawei LUNA2000 10kWh', 'pcs', 3100000, 'battery', 'battery', 'Huawei', 'Smart energy storage system', 10),
    ('battery-004', 'BYD Battery-Box Premium HVS 7.7', 'pcs', 2400000, 'battery', 'battery', 'BYD', 'Compact high voltage battery', 7.7),
    ('battery-005', 'LG RESU 6.5H', 'pcs', 2200000, 'battery', 'battery', 'LG', 'Compact residential battery', 6.5)
ON CONFLICT (persist_name) DO NOTHING;

-- ============================================================================
-- 3. HEAT PUMP PRODUCTS
-- ============================================================================

-- Category: heatpump (Heat Pump Units)
INSERT INTO public.products (persist_name, name, unit, price, investment_type, category, manufacturer, details, power, cop) VALUES
    ('hp-unit-001', 'Daikin Altherma 3 H HT 14kW', 'pcs', 2450000, 'heatPump', 'heatpump', 'Daikin', 'High temperature air-to-water heat pump', 14000, 4.5),
    ('hp-unit-002', 'Mitsubishi Ecodan PUHZ-SHW112YHA', 'pcs', 2280000, 'heatPump', 'heatpump', 'Mitsubishi', 'Split air-to-water heat pump', 11200, 4.3),
    ('hp-unit-003', 'Viessmann Vitocal 200-S 8.5kW', 'pcs', 1950000, 'heatPump', 'heatpump', 'Viessmann', 'Compact heat pump for heating and cooling', 8500, 4.2),
    ('hp-unit-004', 'Daikin Altherma 3 R 16kW', 'pcs', 2680000, 'heatPump', 'heatpump', 'Daikin', 'High capacity heat pump', 16000, 4.6),
    ('hp-unit-005', 'Mitsubishi Ecodan PUHZ-W50VHA', 'pcs', 1850000, 'heatPump', 'heatpump', 'Mitsubishi', 'Energy efficient compact model', 5000, 4.1)
ON CONFLICT (persist_name) DO NOTHING;

-- Category: accessory (Heat Pump Accessories)
INSERT INTO public.products (persist_name, name, unit, price, investment_type, category, manufacturer, details, capacity) VALUES
    ('hp-acc-001', 'Buffer Tank 200L', 'pcs', 320000, 'heatPump', 'accessory', 'Generic', 'Thermal buffer tank for heat pumps', 200),
    ('hp-acc-002', 'Buffer Tank 500L', 'pcs', 520000, 'heatPump', 'accessory', 'Generic', 'Large thermal buffer tank', 500)
ON CONFLICT (persist_name) DO NOTHING;

-- ============================================================================
-- 4. FACADE INSULATION PRODUCTS
-- ============================================================================

-- Category: insulation (Insulation Boards)
INSERT INTO public.products (persist_name, name, unit, price, investment_type, category, manufacturer, details, thickness) VALUES
    ('fi-insul-001', 'Rockwool Frontrock Max E 15cm', 'm²', 8500, 'facadeInsulation', 'insulation', 'Rockwool', 'Stone wool facade insulation board', 15),
    ('fi-insul-002', 'Austrotherm EPS F 16cm', 'm²', 7200, 'facadeInsulation', 'insulation', 'Austrotherm', 'Expanded polystyrene insulation', 16),
    ('fi-insul-003', 'Rockwool Frontrock Max E 20cm', 'm²', 12000, 'facadeInsulation', 'insulation', 'Rockwool', 'Thick stone wool facade board', 20),
    ('fi-insul-004', 'Austrotherm EPS F 12cm', 'm²', 5800, 'facadeInsulation', 'insulation', 'Austrotherm', 'Standard polystyrene insulation', 12)
ON CONFLICT (persist_name) DO NOTHING;

-- Category: adhesive (Adhesive Products)
INSERT INTO public.products (persist_name, name, unit, price, investment_type, category, manufacturer, details) VALUES
    ('fi-adhesive-001', 'Baumit ProContact 25kg', 'pcs', 4500, 'facadeInsulation', 'adhesive', 'Baumit', 'Adhesive mortar for insulation boards'),
    ('fi-adhesive-002', 'Baumit openContact 25kg', 'pcs', 5200, 'facadeInsulation', 'adhesive', 'Baumit', 'Universal adhesive for ETICS')
ON CONFLICT (persist_name) DO NOTHING;

-- Category: plaster (Render Materials)
INSERT INTO public.products (persist_name, name, unit, price, investment_type, category, manufacturer, details) VALUES
    ('fi-plaster-001', 'Baumit SilikonTop 25kg', 'pcs', 28000, 'facadeInsulation', 'plaster', 'Baumit', 'Silicone thin coat render'),
    ('fi-plaster-002', 'Baumit NanoporTop 25kg', 'pcs', 32000, 'facadeInsulation', 'plaster', 'Baumit', 'Premium nano-technology render')
ON CONFLICT (persist_name) DO NOTHING;

-- ============================================================================
-- 5. ROOF INSULATION PRODUCTS
-- ============================================================================

-- Category: insulation (Insulation Rolls)
INSERT INTO public.products (persist_name, name, unit, price, investment_type, category, manufacturer, details, thickness) VALUES
    ('ri-insul-001', 'URSA TERRA 18cm', 'm²', 6200, 'roofInsulation', 'insulation', 'URSA', 'Mineral wool insulation roll', 18),
    ('ri-insul-002', 'Knauf Insulation TP 115 20cm', 'm²', 7800, 'roofInsulation', 'insulation', 'Knauf', 'Thermal insulation for pitched roofs', 20),
    ('ri-insul-003', 'URSA TERRA 15cm', 'm²', 5400, 'roofInsulation', 'insulation', 'URSA', 'Standard mineral wool roll', 15)
ON CONFLICT (persist_name) DO NOTHING;

-- Category: vapor_barrier (Vapor Barrier)
INSERT INTO public.products (persist_name, name, unit, price, investment_type, category, manufacturer, details) VALUES
    ('ri-vapor-001', 'Masterplast Vapor Control', 'm²', 850, 'roofInsulation', 'vapor_barrier', 'Masterplast', 'Vapor control membrane'),
    ('ri-vapor-002', 'Masterplast Diffunorm', 'm²', 950, 'roofInsulation', 'vapor_barrier', 'Masterplast', 'Breathable underlayment')
ON CONFLICT (persist_name) DO NOTHING;

-- ============================================================================
-- 6. WINDOWS PRODUCTS
-- ============================================================================

INSERT INTO public.products (persist_name, name, unit, price, investment_type, category, manufacturer, details, u_value) VALUES
    ('window-001', 'Rehau Geneo 5 Chamber', 'm²', 95000, 'windows', 'window', 'Rehau', 'Premium PVC window system', 0.72),
    ('window-002', 'Schüco LivIng', 'm²', 108000, 'windows', 'window', 'Schüco', 'High-end PVC window', 0.78),
    ('window-003', 'Internorm KF 500', 'm²', 120000, 'windows', 'window', 'Internorm', 'PVC-alu hybrid window', 0.74),
    ('window-004', 'Rehau Synego 6 Chamber', 'm²', 85000, 'windows', 'window', 'Rehau', 'Energy efficient window', 0.94)
ON CONFLICT (persist_name) DO NOTHING;

-- ============================================================================
-- 7. AIR CONDITIONER PRODUCTS
-- ============================================================================

INSERT INTO public.products (persist_name, name, unit, price, investment_type, category, manufacturer, details, power, energy_class) VALUES
    ('ac-001', 'Daikin Sensira FTXF25C 2.5kW', 'pcs', 290000, 'airConditioner', 'airconditioner', 'Daikin', 'Split air conditioner with R32', 2500, 'A++'),
    ('ac-002', 'Mitsubishi MSZ-HR35VF 3.5kW', 'pcs', 340000, 'airConditioner', 'airconditioner', 'Mitsubishi', 'Inverter wall mounted unit', 3500, 'A++'),
    ('ac-003', 'Gree Amber Standard 5.2kW', 'pcs', 380000, 'airConditioner', 'airconditioner', 'Gree', 'High capacity split AC', 5200, 'A++'),
    ('ac-004', 'Daikin Emura FTXJ25MW 2.5kW', 'pcs', 420000, 'airConditioner', 'airconditioner', 'Daikin', 'Premium design split unit', 2500, 'A+++')
ON CONFLICT (persist_name) DO NOTHING;

-- ============================================================================
-- 8. CAR CHARGER PRODUCTS
-- ============================================================================

INSERT INTO public.products (persist_name, name, unit, price, investment_type, category, manufacturer, details, power) VALUES
    ('cc-001', 'Wallbox Pulsar Plus 7.4kW', 'pcs', 350000, 'carCharger', 'charger', 'Wallbox', 'Smart EV charger with WiFi', 7400),
    ('cc-002', 'ABB Terra AC 11kW', 'pcs', 420000, 'carCharger', 'charger', 'ABB', 'Three-phase wall charger', 11000),
    ('cc-003', 'Schneider Electric EVlink 22kW', 'pcs', 520000, 'carCharger', 'charger', 'Schneider Electric', 'High power wall charger', 22000),
    ('cc-004', 'Wallbox Commander 2 22kW', 'pcs', 480000, 'carCharger', 'charger', 'Wallbox', 'Commercial grade smart charger', 22000)
ON CONFLICT (persist_name) DO NOTHING;

-- ============================================================================
-- 9. PRODUCTS FOR SOLAR PANEL + BATTERY (uses same products as above)
-- ============================================================================
-- Solar Panel + Battery investment uses products from both 'solarPanel' and 'battery' types
-- No need to duplicate products - just reference by investment_type

-- ============================================================================
-- END OF SEED DATA
-- ============================================================================
