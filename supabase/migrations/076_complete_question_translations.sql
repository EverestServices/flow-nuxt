-- ============================================================================
-- Migration: Complete Question Translations
-- Description: Comprehensive translations for ALL survey questions
-- ============================================================================

-- ============================================================================
-- SOLAR PANEL - General Data Questions
-- ============================================================================

UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Alapértelmezett tető típusa', 'en', 'Default Roof Type') WHERE name = 'default_roof_type';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Tájolás', 'en', 'Orientation') WHERE name = 'orientation';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Dőlésszög', 'en', 'Tilt Angle') WHERE name = 'tilt_angle';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Fogyasztás mértékegysége', 'en', 'Consumption Unit') WHERE name = 'consumption_unit_toggle';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Fogyasztás időszaka', 'en', 'Consumption Period') WHERE name = 'consumption_period_toggle';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Éves fogyasztás', 'en', 'Annual Consumption') WHERE name = 'annual_consumption';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Gépjárművel megközelíthető az épület?', 'en', 'Is the building accessible by vehicle?') WHERE name = 'vehicle_access';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Gépjárművel nehezen megközelíthető az épület?', 'en', 'Is the building difficult to access by vehicle?') WHERE name = 'difficult_access';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Az épület belső villamoshálózatának állapota', 'en', 'Condition of Building Internal Electrical Network') WHERE name = 'electrical_network_condition';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Rendelkezik külső hőszigeteléssel az épület', 'en', 'Does the building have external insulation') WHERE name = 'external_insulation';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Szigetelés vastagsága', 'en', 'Insulation Thickness') WHERE name = 'insulation_thickness';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Rendelkezésre álló teljesítmény (A)', 'en', 'Available Power (A)') WHERE name = 'available_power_title';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Hány fázis áll rendelkezésre?', 'en', 'How many phases are available?') WHERE name = 'phase_count';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', '1. fázis', 'en', 'Phase 1') WHERE name = 'phase_1';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', '2. fázis', 'en', 'Phase 2') WHERE name = 'phase_2';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', '3. fázis', 'en', 'Phase 3') WHERE name = 'phase_3';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Rendelkezik az ügyfél Fi relével', 'en', 'Does the client have an RCD') WHERE name = 'fi_relay';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Általános megjegyzések', 'en', 'General Comments') WHERE name = 'general_comments';

-- ============================================================================
-- SOLAR PANEL - Solar Panel Details Questions
-- ============================================================================

UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Telepítés helye', 'en', 'Installation Location') WHERE name = 'installation_location';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Rendelkezik már napelem rendszerrel?', 'en', 'Already have a solar panel system?') WHERE name = 'existing_solar_system';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Árnyékolás leírása', 'en', 'Shading Description') WHERE name = 'shading_factor';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Energia tanúsítvánnyal rendelkezik az épület?', 'en', 'Does the building have an energy certificate?') WHERE name = 'energy_certificate';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Épület szintjeinek száma padlástér nélkül', 'en', 'Number of building floors excluding attic') WHERE name = 'building_floors';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Eresz magassága', 'en', 'Eaves Height') WHERE name = 'eaves_height';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Tetőszerkezet műszaki állapota', 'en', 'Roof Structure Technical Condition') WHERE name = 'roof_condition';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Meglévő csatlakozó vezeték típusa', 'en', 'Existing Connection Cable Type') WHERE name = 'connection_cable_type';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Épület műemlékvédelem alatt áll', 'en', 'Building is under monument protection') WHERE name = 'monument_protection';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Villámhárító van az épületen', 'en', 'Lightning protection on building') WHERE name = 'lightning_protection';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Tetőfelújítás szükséges', 'en', 'Roof renovation needed') WHERE name = 'roof_renovation_needed';

-- ============================================================================
-- SOLAR PANEL - Inverter Questions
-- ============================================================================

UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Inverter elhelyezésének részletes leírása', 'en', 'Detailed description of inverter placement') WHERE name = 'inverter_location';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Van-e megfelelő jel az inverter tervezett helyén', 'en', 'Is there adequate signal at the planned inverter location') WHERE name = 'signal_availability';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Internet eléréssel rendelkezik?', 'en', 'Has Internet access?') WHERE name = 'internet_access';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Monitoring rendszert igényel?', 'en', 'Requires monitoring system?') WHERE name = 'monitoring_system';

-- ============================================================================
-- SOLAR PANEL - Roof Questions
-- ============================================================================

UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Tető típusa', 'en', 'Roof Type') WHERE name = 'roof_type';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Tető szélessége', 'en', 'Roof Width') WHERE name = 'roof_width';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Tető hossza', 'en', 'Roof Length') WHERE name = 'roof_length';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Tetőszerkezet anyaga', 'en', 'Roof Structure Material') WHERE name = 'roof_structure_material';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Tetőfedés típusa', 'en', 'Roof Covering Type') WHERE name = 'roof_covering_type';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Agyagcserép típusa', 'en', 'Clay Tile Type') WHERE name = 'clay_tile_type';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Lemez vastagsága', 'en', 'Sheet Thickness') WHERE name = 'sheet_thickness';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Szarufák távolsága', 'en', 'Rafter Spacing') WHERE name = 'rafter_spacing';

-- ============================================================================
-- FACADE INSULATION - General Questions
-- ============================================================================

UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Nedvesség okozta károk', 'en', 'Moisture Damage') WHERE name = 'moisture_damage';

-- ============================================================================
-- FACADE INSULATION - Wall Questions
-- ============================================================================

UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Fal típusa', 'en', 'Wall Type') WHERE name = 'wall_type';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Fal vastagsága', 'en', 'Wall Thickness') WHERE name = 'wall_thickness';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Fal szélessége', 'en', 'Wall Width') WHERE name = 'wall_width';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Fal magassága', 'en', 'Wall Height') WHERE name = 'wall_height';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Alapozás magassága', 'en', 'Foundation Height') WHERE name = 'foundation_height';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Fal szigetelése', 'en', 'Wall Insulation') WHERE name = 'wall_insulation';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Fal szigetelés vastagsága', 'en', 'Wall Insulation Thickness') WHERE name = 'wall_insulation_thickness';

-- ============================================================================
-- FACADE INSULATION - Roof Questions
-- ============================================================================

UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Tető területe', 'en', 'Roof Area') WHERE name = 'roof_area';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Tető anyaga', 'en', 'Roof Material') WHERE name = 'roof_material';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Beépített tető', 'en', 'Built-in Roof') WHERE name = 'roof_built_in';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Tető szigetelése', 'en', 'Roof Insulation') WHERE name = 'roof_insulation';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Tető szigetelés vastagsága', 'en', 'Roof Insulation Thickness') WHERE name = 'roof_insulation_thickness';

-- ============================================================================
-- HEAT PUMP - General Questions
-- ============================================================================

UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Ingatlan típusa (egyéb)', 'en', 'Property Type (Other)') WHERE name = 'property_type_other';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Beépített padlás', 'en', 'Built-in Attic') WHERE name = 'attic_built_in';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Padlás szigetelése', 'en', 'Attic Insulation') WHERE name = 'attic_insulation';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Padlás szigetelés mérete', 'en', 'Attic Insulation Size') WHERE name = 'attic_insulation_size';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Belmagasság', 'en', 'Ceiling Height') WHERE name = 'ceiling_height';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Vizesblokkok száma', 'en', 'Number of Wet Rooms') WHERE name = 'wet_rooms_count';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Fal típusa és vastagsága', 'en', 'Wall Type and Thickness') WHERE name = 'wall_type_thickness';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Hőszigetelés', 'en', 'Thermal Insulation') WHERE name = 'thermal_insulation';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Hőszigetelés vastagsága', 'en', 'Thermal Insulation Thickness') WHERE name = 'thermal_insulation_thickness';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Födém szigetelése', 'en', 'Ceiling Insulation') WHERE name = 'ceiling_insulation';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Födém szigetelés vastagsága', 'en', 'Ceiling Insulation Thickness') WHERE name = 'ceiling_insulation_thickness';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Homlokzati szigetelés', 'en', 'Facade Insulation') WHERE name = 'facade_insulation';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Homlokzati szigetelés vastagsága', 'en', 'Facade Insulation Thickness') WHERE name = 'facade_insulation_thickness';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Ablak és ajtó típusa', 'en', 'Window and Door Type') WHERE name = 'window_door_type';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Ablak árnyékolása', 'en', 'Window Shading') WHERE name = 'window_shading';

-- ============================================================================
-- HEAT PUMP - Rooms Questions
-- ============================================================================

UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Helyiség neve', 'en', 'Room Name') WHERE name = 'room_name';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Helyiség mérete', 'en', 'Room Size') WHERE name = 'room_size';

-- ============================================================================
-- HEAT PUMP - Windows Questions
-- ============================================================================

UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Nyílászáró típusa', 'en', 'Window Type') WHERE name = 'window_type';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Nyílászáró anyaga', 'en', 'Window Material') WHERE name = 'window_material';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Üvegezés típusa', 'en', 'Glazing Type') WHERE name = 'window_glazing';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Nyílászárók száma', 'en', 'Window Quantity') WHERE name = 'window_quantity';

-- ============================================================================
-- HEAT PUMP - Heating Basics Questions
-- ============================================================================

UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Jelenlegi fűtési megoldás', 'en', 'Current Heating Solution') WHERE name = 'current_heating_solution';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Jelenlegi fűtési megoldás (egyéb)', 'en', 'Current Heating Solution (Other)') WHERE name = 'current_heating_solution_other';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Jelenlegi hőleadó kör', 'en', 'Current Heat Distribution') WHERE name = 'current_heat_distribution';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Jelenlegi hőleadó kör (egyéb)', 'en', 'Current Heat Distribution (Other)') WHERE name = 'current_heat_distribution_other';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Jelenlegi melegvíz ellátás', 'en', 'Current Hot Water Supply') WHERE name = 'current_hot_water';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Melegvíz tároló mérete', 'en', 'Hot Water Tank Size') WHERE name = 'current_hot_water_size';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Napkollektor támogatás', 'en', 'Solar Collector Support') WHERE name = 'solar_collector_support';

-- ============================================================================
-- HEAT PUMP - Radiators Questions
-- ============================================================================

UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Radiátor mérete', 'en', 'Radiator Size') WHERE name = 'radiator_size';

-- ============================================================================
-- HEAT PUMP - Desired Construction Questions
-- ============================================================================

UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Cél', 'en', 'Goal') WHERE name = 'goal';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Támogatás', 'en', 'Subsidy') WHERE name = 'subsidy';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Hőszivattyú használata', 'en', 'Heat Pump Usage') WHERE name = 'heat_pump_usage';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Melegvíz megoldás', 'en', 'Hot Water Solution') WHERE name = 'hot_water_solution';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Külső tároló', 'en', 'External Storage') WHERE name = 'external_storage';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Hőleadás', 'en', 'Heat Distribution') WHERE name = 'heat_distribution';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'H-tarifa', 'en', 'H-Tariff') WHERE name = 'h_tariff';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Tároló kapacitása', 'en', 'Tank Capacity') WHERE name = 'tank_capacity';

-- ============================================================================
-- HEAT PUMP - Other Data Questions
-- ============================================================================

UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Éves gázfogyasztás', 'en', 'Annual Gas Consumption') WHERE name = 'annual_gas_consumption';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Számított hőigény', 'en', 'Calculated Heat Demand') WHERE name = 'calculated_heat_demand';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Számítás forrása', 'en', 'Calculation Source') WHERE name = 'calculation_source';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Számított téli hőveszteség', 'en', 'Calculated Winter Heat Loss') WHERE name = 'calculated_winter_heat_loss';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Nyári hőterhelés', 'en', 'Summer Heat Load') WHERE name = 'summer_heat_load';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Beltéri egység elfér', 'en', 'Indoor Unit Fits') WHERE name = 'indoor_unit_fits';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Beltéri-kültéri távolság', 'en', 'Indoor-Outdoor Distance') WHERE name = 'indoor_outdoor_distance';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Kültéri egység telepíthető', 'en', 'Outdoor Unit Installable') WHERE name = 'outdoor_unit_installable';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Kondenzátum elvezetés', 'en', 'Condensate Drainage') WHERE name = 'condensate_drainage';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Elvezetés távolsága', 'en', 'Drainage Distance') WHERE name = 'drainage_distance';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Melegvíz felhasználók száma', 'en', 'Hot Water Users Count') WHERE name = 'hot_water_users_count';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Melegvíz felhasználók növekedése', 'en', 'Hot Water Users Increase') WHERE name = 'hot_water_users_increase';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Kád vagy zuhany', 'en', 'Bath or Shower') WHERE name = 'bath_or_shower';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Medence fűtés', 'en', 'Pool Heating') WHERE name = 'pool_heating';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Speciális követelmények', 'en', 'Special Requirements') WHERE name = 'special_requirements';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Kivitelezési megjegyzések', 'en', 'Installation Comments') WHERE name = 'installation_comments';

-- ============================================================================
-- UPDATE PLACEHOLDER TRANSLATIONS
-- ============================================================================

UPDATE public.survey_questions SET placeholder_translations = jsonb_build_object('hu', 'Tető típusa', 'en', 'Roof Type') WHERE placeholder_value = 'Tető típusa';
UPDATE public.survey_questions SET placeholder_translations = jsonb_build_object('hu', 'Tájolás', 'en', 'Orientation') WHERE placeholder_value = 'Tájolás';
UPDATE public.survey_questions SET placeholder_translations = jsonb_build_object('hu', 'Mértékegység', 'en', 'Unit') WHERE placeholder_value = 'Mértékegység';
UPDATE public.survey_questions SET placeholder_translations = jsonb_build_object('hu', 'Időszak', 'en', 'Period') WHERE placeholder_value = 'Időszak';
UPDATE public.survey_questions SET placeholder_translations = jsonb_build_object('hu', 'Érték', 'en', 'Value') WHERE placeholder_value = 'Érték';
UPDATE public.survey_questions SET placeholder_translations = jsonb_build_object('hu', 'Vastagság cm-ben', 'en', 'Thickness in cm') WHERE placeholder_value = 'Vastagság cm-ben';
UPDATE public.survey_questions SET placeholder_translations = jsonb_build_object('hu', 'Amper', 'en', 'Ampere') WHERE placeholder_value = 'Amper';
UPDATE public.survey_questions SET placeholder_translations = jsonb_build_object('hu', 'Itt írhat megjegyzéseket az általános adatokhoz...', 'en', 'You can write notes about general data here...') WHERE placeholder_value = 'Itt írhat megjegyzéseket az általános adatokhoz...';
UPDATE public.survey_questions SET placeholder_translations = jsonb_build_object('hu', 'Telepítés helye', 'en', 'Installation Location') WHERE placeholder_value = 'Telepítés helye';
UPDATE public.survey_questions SET placeholder_translations = jsonb_build_object('hu', 'Árnyékolás leírása', 'en', 'Shading Description') WHERE placeholder_value = 'Árnyékolás leírása';
UPDATE public.survey_questions SET placeholder_translations = jsonb_build_object('hu', 'méter', 'en', 'meter') WHERE placeholder_value = 'méter';
UPDATE public.survey_questions SET placeholder_translations = jsonb_build_object('hu', 'Inverter elhelyezésének részletes leírása...', 'en', 'Detailed description of inverter placement...') WHERE placeholder_value = 'Inverter elhelyezésének részletes leírása...';
UPDATE public.survey_questions SET placeholder_translations = jsonb_build_object('hu', 'cm', 'en', 'cm') WHERE placeholder_value = 'cm';
UPDATE public.survey_questions SET placeholder_translations = jsonb_build_object('hu', 'mm', 'en', 'mm') WHERE placeholder_value = 'mm';
UPDATE public.survey_questions SET placeholder_translations = jsonb_build_object('hu', 'Építési év', 'en', 'Construction Year') WHERE placeholder_value = 'Építési év';
UPDATE public.survey_questions SET placeholder_translations = jsonb_build_object('hu', 'Adja meg az ingatlan típusát', 'en', 'Specify property type') WHERE placeholder_value = 'Adja meg az ingatlan típusát';
UPDATE public.survey_questions SET placeholder_translations = jsonb_build_object('hu', 'db', 'en', 'pcs') WHERE placeholder_value = 'db';
UPDATE public.survey_questions SET placeholder_translations = jsonb_build_object('hu', 'Adja meg a fűtési megoldás típusát', 'en', 'Specify heating solution type') WHERE placeholder_value = 'Adja meg a fűtési megoldás típusát';
UPDATE public.survey_questions SET placeholder_translations = jsonb_build_object('hu', 'Adja meg a hőleadó kör típusát', 'en', 'Specify heat distribution type') WHERE placeholder_value = 'Adja meg a hőleadó kör típusát';
UPDATE public.survey_questions SET placeholder_translations = jsonb_build_object('hu', 'kW', 'en', 'kW') WHERE placeholder_value = 'kW';
UPDATE public.survey_questions SET placeholder_translations = jsonb_build_object('hu', 'Szakember neve, cég', 'en', 'Professional name, company') WHERE placeholder_value = 'Szakember neve, cég';
UPDATE public.survey_questions SET placeholder_translations = jsonb_build_object('hu', 'További megjegyzések a kivitelezéshez...', 'en', 'Additional comments for installation...') WHERE placeholder_value = 'További megjegyzések a kivitelezéshez...';

-- Update room-related placeholders
UPDATE public.survey_questions SET placeholder_translations = jsonb_build_object('hu', 'pl. Nappali, Hálószoba', 'en', 'e.g. Living Room, Bedroom') WHERE placeholder_value = 'pl. Nappali, Hálószoba';
UPDATE public.survey_questions SET placeholder_translations = jsonb_build_object('hu', 'pl. 20 m²', 'en', 'e.g. 20 m²') WHERE placeholder_value = 'pl. 20 m²';
UPDATE public.survey_questions SET placeholder_translations = jsonb_build_object('hu', 'pl. 60x120 cm', 'en', 'e.g. 60x120 cm') WHERE placeholder_value = 'pl. 60x120 cm';
UPDATE public.survey_questions SET placeholder_translations = jsonb_build_object('hu', 'pl. 100 m²', 'en', 'e.g. 100 m²') WHERE placeholder_value = 'pl. 100 m²';
UPDATE public.survey_questions SET placeholder_translations = jsonb_build_object('hu', 'pl. Porotherm 30 cm', 'en', 'e.g. Porotherm 30 cm') WHERE placeholder_value = 'pl. Porotherm 30 cm';
UPDATE public.survey_questions SET placeholder_translations = jsonb_build_object('hu', 'pl. Műanyag, 2 rétegű üvegezés', 'en', 'e.g. Plastic, 2-layer glazing') WHERE placeholder_value = 'pl. Műanyag, 2 rétegű üvegezés';
UPDATE public.survey_questions SET placeholder_translations = jsonb_build_object('hu', 'pl. Redőny, napellenző', 'en', 'e.g. Shutters, awnings') WHERE placeholder_value = 'pl. Redőny, napellenző';
UPDATE public.survey_questions SET placeholder_translations = jsonb_build_object('hu', 'pl. 2 zuhanyzó, 1 kád', 'en', 'e.g. 2 showers, 1 bath') WHERE placeholder_value = 'pl. 2 zuhanyzó, 1 kád';
UPDATE public.survey_questions SET placeholder_translations = jsonb_build_object('hu', 'pl. HMKE kiépítése, ingatlan szigetelése stb.', 'en', 'e.g. HMKE installation, property insulation, etc.') WHERE placeholder_value = 'pl. HMKE kiépítése, ingatlan szigetelése stb.';

-- ============================================================================
-- BATTERY - Questions
-- ============================================================================

UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Rendelkezésre álló hely', 'en', 'Available Space') WHERE name = 'available_space';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Hőmérséklet 0°C felett', 'en', 'Temperature Above 0°C') WHERE name = 'temperature_above_zero';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Inverter-akkumulátor távolság', 'en', 'Inverter-Battery Distance') WHERE name = 'inverter_battery_distance';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Tűzvédelmi leválasztó', 'en', 'Fire Disconnect') WHERE name = 'fire_disconnect';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Fő elosztóig vezethető', 'en', 'Routing to Main Distributor') WHERE name = 'main_distributor_routing';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Smart mérőóra számára van hely', 'en', 'Space for Smart Meter') WHERE name = 'smart_meter_space';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Smart mérőóra távolsága', 'en', 'Smart Meter Distance') WHERE name = 'smart_meter_distance';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Nyomvonal részletes leírása', 'en', 'Detailed Routing Description') WHERE name = 'routing_description';

UPDATE public.survey_questions SET placeholder_translations = jsonb_build_object('hu', 'm²', 'en', 'm²') WHERE placeholder_value = 'm²';
UPDATE public.survey_questions SET placeholder_translations = jsonb_build_object('hu', 'Részletes nyomvonal leírása...', 'en', 'Detailed routing description...') WHERE placeholder_value = 'Részletes nyomvonal leírása...';

-- ============================================================================
-- CAR CHARGER - EV Data Questions
-- ============================================================================

UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Elektromos autó márkája', 'en', 'Electric Vehicle Brand') WHERE name = 'ev_brand_select';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Egyéb márka megadása', 'en', 'Other Brand') WHERE name = 'ev_brand_other';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Autó típusa', 'en', 'Vehicle Model') WHERE name = 'ev_model';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Csatlakozó típusa', 'en', 'Connector Type') WHERE name = 'ev_connector_type';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Akkumulátor kapacitása', 'en', 'Battery Capacity') WHERE name = 'ev_battery_capacity';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Fedélzeti töltő', 'en', 'Onboard Charger') WHERE name = 'onboard_charger_title';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Fedélzeti töltő teljesítménye', 'en', 'Onboard Charger Power') WHERE name = 'onboard_charger_power';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Fedélzeti töltő fázisszáma', 'en', 'Onboard Charger Phase') WHERE name = 'onboard_charger_phase';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Fedélzeti töltő amperértéke', 'en', 'Onboard Charger Ampere') WHERE name = 'onboard_charger_ampere';

UPDATE public.survey_questions SET placeholder_translations = jsonb_build_object('hu', 'Adja meg a márkát', 'en', 'Enter the brand') WHERE placeholder_value = 'Adja meg a márkát';
UPDATE public.survey_questions SET placeholder_translations = jsonb_build_object('hu', 'pl. Model 3, Ioniq 5, ID.4', 'en', 'e.g. Model 3, Ioniq 5, ID.4') WHERE placeholder_value = 'pl. Model 3, Ioniq 5, ID.4';
UPDATE public.survey_questions SET placeholder_translations = jsonb_build_object('hu', 'pl. 60', 'en', 'e.g. 60') WHERE placeholder_value = 'pl. 60';
UPDATE public.survey_questions SET placeholder_translations = jsonb_build_object('hu', 'pl. 11', 'en', 'e.g. 11') WHERE placeholder_value = 'pl. 11';
UPDATE public.survey_questions SET placeholder_translations = jsonb_build_object('hu', 'pl. 16', 'en', 'e.g. 16') WHERE placeholder_value = 'pl. 16';

-- ============================================================================
-- CAR CHARGER - Location Questions
-- ============================================================================

UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Helyszín típusa', 'en', 'Installation Site Type') WHERE name = 'installation_site_type';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Tulajdonviszony', 'en', 'Ownership') WHERE name = 'ownership';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Hozzáférhetőség', 'en', 'Site Access') WHERE name = 'site_access';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Helyszín jellege', 'en', 'Site Nature') WHERE name = 'site_nature';

-- ============================================================================
-- CAR CHARGER - Power Upgrade Questions
-- ============================================================================

UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Belső hálózat bővítést tervez', 'en', 'Plans Internal Network Upgrade') WHERE name = 'plans_internal_upgrade';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Rendelkezik hálózati tervvel', 'en', 'Has Wiring Plan') WHERE name = 'has_wiring_plan';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Áramellátás megfelelő', 'en', 'Power Supply OK') WHERE name = 'power_supply_ok';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Helyszín előkészített', 'en', 'Site Prepared OK') WHERE name = 'site_prepared_ok';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Szerelési felület típusa', 'en', 'Mounting Surface Type') WHERE name = 'mounting_surface_type';

-- ============================================================================
-- AIR CONDITIONER - Additional Questions (Most are same as Solar Panel)
-- ============================================================================

UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Egyéb megjegyzések', 'en', 'Other Comments') WHERE name = 'other_comments';
UPDATE public.survey_questions SET placeholder_translations = jsonb_build_object('hu', 'További megjegyzések...', 'en', 'Additional comments...') WHERE placeholder_value = 'További megjegyzések...';

-- ============================================================================
-- WINDOWS/ROOF INSULATION - Window-specific Questions
-- ============================================================================

UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Nyílászáró szélessége', 'en', 'Window Width') WHERE name = 'window_width';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Nyílászáró magassága', 'en', 'Window Height') WHERE name = 'window_height';

-- ============================================================================
-- COMMON QUESTIONS - Shared across multiple investments
-- ============================================================================

UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Ingatlan típusa', 'en', 'Property Type') WHERE name = 'property_type';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Építési év', 'en', 'Construction Year') WHERE name = 'construction_year';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Téli hőmérséklet', 'en', 'Winter Temperature') WHERE name = 'winter_temperature';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Fő tájolás', 'en', 'Main Orientation') WHERE name = 'main_orientation';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Van pincéje', 'en', 'Has Basement') WHERE name = 'has_basement';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Van padlása', 'en', 'Has Attic') WHERE name = 'has_attic';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Ingatlan helyszíne', 'en', 'Property Location') WHERE name = 'property_location';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Hőszivattyú típusa', 'en', 'Heat Pump Type') WHERE name = 'heat_pump_type';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Épület területe', 'en', 'Building Area') WHERE name = 'building_area';
UPDATE public.survey_questions SET name_translations = jsonb_build_object('hu', 'Fűtött terület', 'en', 'Heated Area') WHERE name = 'heated_area';

UPDATE public.survey_questions SET placeholder_translations = jsonb_build_object('hu', 'Település, kerület', 'en', 'Settlement, district') WHERE placeholder_value = 'Település, kerület';

-- ============================================================================
-- UPDATE OPTIONS TRANSLATIONS FOR ALL DROPDOWNS
-- ============================================================================

-- Property Type Options (Családi ház, Ikerház, Sorház, Egyéb)
UPDATE public.survey_questions
SET options_translations = jsonb_build_array(
  jsonb_build_object('value', 'Családi ház', 'label', jsonb_build_object('hu', 'Családi ház', 'en', 'Family House')),
  jsonb_build_object('value', 'Ikerház', 'label', jsonb_build_object('hu', 'Ikerház', 'en', 'Semi-detached House')),
  jsonb_build_object('value', 'Sorház', 'label', jsonb_build_object('hu', 'Sorház', 'en', 'Terraced House')),
  jsonb_build_object('value', 'Egyéb', 'label', jsonb_build_object('hu', 'Egyéb', 'en', 'Other'))
)
WHERE name = 'property_type' AND options IS NOT NULL AND options::text LIKE '%Családi ház%';

-- Roof Type Options
UPDATE public.survey_questions
SET options_translations = jsonb_build_array(
  jsonb_build_object('value', 'Nyeregtető', 'label', jsonb_build_object('hu', 'Nyeregtető', 'en', 'Gable Roof')),
  jsonb_build_object('value', 'Sátortető', 'label', jsonb_build_object('hu', 'Sátortető', 'en', 'Hip Roof')),
  jsonb_build_object('value', 'Fél nyeregtető', 'label', jsonb_build_object('hu', 'Fél nyeregtető', 'en', 'Half Gable Roof')),
  jsonb_build_object('value', 'Lapostető', 'label', jsonb_build_object('hu', 'Lapostető', 'en', 'Flat Roof')),
  jsonb_build_object('value', 'Földre telepítés', 'label', jsonb_build_object('hu', 'Földre telepítés', 'en', 'Ground Installation')),
  jsonb_build_object('value', 'Egyéb', 'label', jsonb_build_object('hu', 'Egyéb', 'en', 'Other'))
)
WHERE name = 'default_roof_type' OR (name = 'roof_type' AND options::text LIKE '%Földre telepítés%');

-- Orientation Options
UPDATE public.survey_questions
SET options_translations = jsonb_build_array(
  jsonb_build_object('value', 'É', 'label', jsonb_build_object('hu', 'É', 'en', 'N')),
  jsonb_build_object('value', 'ÉK', 'label', jsonb_build_object('hu', 'ÉK', 'en', 'NE')),
  jsonb_build_object('value', 'K', 'label', jsonb_build_object('hu', 'K', 'en', 'E')),
  jsonb_build_object('value', 'DK', 'label', jsonb_build_object('hu', 'DK', 'en', 'SE')),
  jsonb_build_object('value', 'D', 'label', jsonb_build_object('hu', 'D', 'en', 'S')),
  jsonb_build_object('value', 'DNy', 'label', jsonb_build_object('hu', 'DNy', 'en', 'SW')),
  jsonb_build_object('value', 'Ny', 'label', jsonb_build_object('hu', 'Ny', 'en', 'W')),
  jsonb_build_object('value', 'ÉNy', 'label', jsonb_build_object('hu', 'ÉNy', 'en', 'NW'))
)
WHERE name = 'orientation' OR name = 'main_orientation';

-- Electrical Network Condition Options
UPDATE public.survey_questions
SET options_translations = jsonb_build_array(
  jsonb_build_object('value', 'Új', 'label', jsonb_build_object('hu', 'Új', 'en', 'New')),
  jsonb_build_object('value', 'Jó', 'label', jsonb_build_object('hu', 'Jó', 'en', 'Good')),
  jsonb_build_object('value', 'Átlagos', 'label', jsonb_build_object('hu', 'Átlagos', 'en', 'Average')),
  jsonb_build_object('value', 'Felújításra szorul', 'label', jsonb_build_object('hu', 'Felújításra szorul', 'en', 'Needs Renovation')),
  jsonb_build_object('value', 'Rossz', 'label', jsonb_build_object('hu', 'Rossz', 'en', 'Poor'))
)
WHERE name = 'electrical_network_condition' OR name = 'roof_condition';

-- FI Relay Options
UPDATE public.survey_questions
SET options_translations = jsonb_build_array(
  jsonb_build_object('value', 'Igen, az elosztó szekrényben', 'label', jsonb_build_object('hu', 'Igen, az elosztó szekrényben', 'en', 'Yes, in the distribution cabinet')),
  jsonb_build_object('value', 'Igen, a mérőóránál', 'label', jsonb_build_object('hu', 'Igen, a mérőóránál', 'en', 'Yes, at the meter')),
  jsonb_build_object('value', 'Nincs', 'label', jsonb_build_object('hu', 'Nincs', 'en', 'None'))
)
WHERE name = 'fi_relay';

-- Installation Location Options
UPDATE public.survey_questions
SET options_translations = jsonb_build_array(
  jsonb_build_object('value', 'Földfelszín', 'label', jsonb_build_object('hu', 'Földfelszín', 'en', 'Ground Level')),
  jsonb_build_object('value', 'Családi ház', 'label', jsonb_build_object('hu', 'Családi ház', 'en', 'Family House')),
  jsonb_build_object('value', 'Tömbház', 'label', jsonb_build_object('hu', 'Tömbház', 'en', 'Apartment Building')),
  jsonb_build_object('value', 'Üzemcsarnok', 'label', jsonb_build_object('hu', 'Üzemcsarnok', 'en', 'Industrial Hall')),
  jsonb_build_object('value', 'Egyéb', 'label', jsonb_build_object('hu', 'Egyéb', 'en', 'Other'))
)
WHERE name = 'installation_location';

-- Connection Cable Type Options
UPDATE public.survey_questions
SET options_translations = jsonb_build_array(
  jsonb_build_object('value', 'Földkábel', 'label', jsonb_build_object('hu', 'Földkábel', 'en', 'Underground Cable')),
  jsonb_build_object('value', 'Légvezeték', 'label', jsonb_build_object('hu', 'Légvezeték', 'en', 'Overhead Line'))
)
WHERE name = 'connection_cable_type';

-- Monitoring System Options
UPDATE public.survey_questions
SET options_translations = jsonb_build_array(
  jsonb_build_object('value', 'Wifi', 'label', jsonb_build_object('hu', 'Wifi', 'en', 'Wifi')),
  jsonb_build_object('value', 'UTP', 'label', jsonb_build_object('hu', 'UTP', 'en', 'UTP')),
  jsonb_build_object('value', 'Nincs', 'label', jsonb_build_object('hu', 'Nincs', 'en', 'None'))
)
WHERE name = 'monitoring_system';

-- Roof Structure Material Options
UPDATE public.survey_questions
SET options_translations = jsonb_build_array(
  jsonb_build_object('value', 'Fa', 'label', jsonb_build_object('hu', 'Fa', 'en', 'Wood')),
  jsonb_build_object('value', 'Fém', 'label', jsonb_build_object('hu', 'Fém', 'en', 'Metal')),
  jsonb_build_object('value', 'Beton', 'label', jsonb_build_object('hu', 'Beton', 'en', 'Concrete'))
)
WHERE name = 'roof_structure_material';

-- Roof Covering Type Options
UPDATE public.survey_questions
SET options_translations = jsonb_build_array(
  jsonb_build_object('value', 'Agyagcserép', 'label', jsonb_build_object('hu', 'Agyagcserép', 'en', 'Clay Tile')),
  jsonb_build_object('value', 'Betoncserép', 'label', jsonb_build_object('hu', 'Betoncserép', 'en', 'Concrete Tile')),
  jsonb_build_object('value', 'Cserepes lemez', 'label', jsonb_build_object('hu', 'Cserepes lemez', 'en', 'Tile Sheet')),
  jsonb_build_object('value', 'Trapéz lemez', 'label', jsonb_build_object('hu', 'Trapéz lemez', 'en', 'Trapezoidal Sheet')),
  jsonb_build_object('value', 'Zsindely', 'label', jsonb_build_object('hu', 'Zsindely', 'en', 'Shingles')),
  jsonb_build_object('value', 'Lemezpala', 'label', jsonb_build_object('hu', 'Lemezpala', 'en', 'Slate Sheet')),
  jsonb_build_object('value', 'Hullámpala', 'label', jsonb_build_object('hu', 'Hullámpala', 'en', 'Corrugated Slate')),
  jsonb_build_object('value', 'Szalma nád', 'label', jsonb_build_object('hu', 'Szalma nád', 'en', 'Straw Reed')),
  jsonb_build_object('value', 'Szendvicspanel', 'label', jsonb_build_object('hu', 'Szendvicspanel', 'en', 'Sandwich Panel')),
  jsonb_build_object('value', 'Hódfarkú cserép', 'label', jsonb_build_object('hu', 'Hódfarkú cserép', 'en', 'Beaver Tail Tile')),
  jsonb_build_object('value', 'Dupla hódfarkú cserép', 'label', jsonb_build_object('hu', 'Dupla hódfarkú cserép', 'en', 'Double Beaver Tail Tile')),
  jsonb_build_object('value', 'Egyéb', 'label', jsonb_build_object('hu', 'Egyéb', 'en', 'Other'))
)
WHERE name = 'roof_covering_type';

-- Clay Tile Type Options
UPDATE public.survey_questions
SET options_translations = jsonb_build_array(
  jsonb_build_object('value', 'Íves', 'label', jsonb_build_object('hu', 'Íves', 'en', 'Curved')),
  jsonb_build_object('value', 'Bramac', 'label', jsonb_build_object('hu', 'Bramac', 'en', 'Bramac')),
  jsonb_build_object('value', 'Egyenes', 'label', jsonb_build_object('hu', 'Egyenes', 'en', 'Straight')),
  jsonb_build_object('value', 'Egyéb', 'label', jsonb_build_object('hu', 'Egyéb', 'en', 'Other'))
)
WHERE name = 'clay_tile_type';

-- Wall Type Options
UPDATE public.survey_questions
SET options_translations = jsonb_build_array(
  jsonb_build_object('value', 'Kérjük, válasszon', 'label', jsonb_build_object('hu', 'Kérjük, válasszon', 'en', 'Please select')),
  jsonb_build_object('value', 'Kis méretű tömör tégla', 'label', jsonb_build_object('hu', 'Kis méretű tömör tégla', 'en', 'Small Solid Brick')),
  jsonb_build_object('value', 'Mészhomok tégla', 'label', jsonb_build_object('hu', 'Mészhomok tégla', 'en', 'Lime Sand Brick')),
  jsonb_build_object('value', 'B30 tégla', 'label', jsonb_build_object('hu', 'B30 tégla', 'en', 'B30 Brick')),
  jsonb_build_object('value', 'Poroton', 'label', jsonb_build_object('hu', 'Poroton', 'en', 'Poroton')),
  jsonb_build_object('value', 'Gázsilikát', 'label', jsonb_build_object('hu', 'Gázsilikát', 'en', 'Aerated Concrete')),
  jsonb_build_object('value', 'Bautherm', 'label', jsonb_build_object('hu', 'Bautherm', 'en', 'Bautherm')),
  jsonb_build_object('value', 'Porotherm N+F', 'label', jsonb_build_object('hu', 'Porotherm N+F', 'en', 'Porotherm N+F')),
  jsonb_build_object('value', 'Ytong', 'label', jsonb_build_object('hu', 'Ytong', 'en', 'Ytong')),
  jsonb_build_object('value', 'Vasbeton panel', 'label', jsonb_build_object('hu', 'Vasbeton panel', 'en', 'Reinforced Concrete Panel')),
  jsonb_build_object('value', 'Vályog', 'label', jsonb_build_object('hu', 'Vályog', 'en', 'Adobe')),
  jsonb_build_object('value', 'Könnyűszerkezetes', 'label', jsonb_build_object('hu', 'Könnyűszerkezetes', 'en', 'Lightweight Construction'))
)
WHERE name = 'wall_type';

-- Roof Material Options (for Facade/Roof Insulation)
UPDATE public.survey_questions
SET options_translations = jsonb_build_array(
  jsonb_build_object('value', 'Cserép', 'label', jsonb_build_object('hu', 'Cserép', 'en', 'Tile')),
  jsonb_build_object('value', 'Pala', 'label', jsonb_build_object('hu', 'Pala', 'en', 'Slate')),
  jsonb_build_object('value', 'Lemezelt', 'label', jsonb_build_object('hu', 'Lemezelt', 'en', 'Sheet Metal'))
)
WHERE name = 'roof_material';

-- Simple Roof Type Options (for Facade/Roof Insulation)
UPDATE public.survey_questions
SET options_translations = jsonb_build_array(
  jsonb_build_object('value', 'Sátortető', 'label', jsonb_build_object('hu', 'Sátortető', 'en', 'Hip Roof')),
  jsonb_build_object('value', 'Lapostető', 'label', jsonb_build_object('hu', 'Lapostető', 'en', 'Flat Roof'))
)
WHERE name = 'roof_type' AND options::text LIKE '%Sátortető%' AND options::text NOT LIKE '%Nyeregtető%';

-- Window Type Options
UPDATE public.survey_questions
SET options_translations = jsonb_build_array(
  jsonb_build_object('value', 'Ablak', 'label', jsonb_build_object('hu', 'Ablak', 'en', 'Window')),
  jsonb_build_object('value', 'Bejárati ajtó', 'label', jsonb_build_object('hu', 'Bejárati ajtó', 'en', 'Entrance Door')),
  jsonb_build_object('value', 'Terasz/erkélyajtó (üvegezett)', 'label', jsonb_build_object('hu', 'Terasz/erkélyajtó (üvegezett)', 'en', 'Terrace/Balcony Door (Glazed)'))
)
WHERE name = 'window_type';

-- Window Material Options
UPDATE public.survey_questions
SET options_translations = jsonb_build_array(
  jsonb_build_object('value', 'Fa', 'label', jsonb_build_object('hu', 'Fa', 'en', 'Wood')),
  jsonb_build_object('value', 'Műanyag', 'label', jsonb_build_object('hu', 'Műanyag', 'en', 'Plastic')),
  jsonb_build_object('value', 'Fém', 'label', jsonb_build_object('hu', 'Fém', 'en', 'Metal'))
)
WHERE name = 'window_material';

-- Window Glazing Options
UPDATE public.survey_questions
SET options_translations = jsonb_build_array(
  jsonb_build_object('value', '1 rétegű üvegezésű', 'label', jsonb_build_object('hu', '1 rétegű üvegezésű', 'en', '1-layer Glazing')),
  jsonb_build_object('value', '2 rétegű üvegezésű', 'label', jsonb_build_object('hu', '2 rétegű üvegezésű', 'en', '2-layer Glazing')),
  jsonb_build_object('value', '3 rétegű üvegezésű', 'label', jsonb_build_object('hu', '3 rétegű üvegezésű', 'en', '3-layer Glazing')),
  jsonb_build_object('value', '2 rétegű csavaros teschauer', 'label', jsonb_build_object('hu', '2 rétegű csavaros teschauer', 'en', '2-layer Screw Teschauer')),
  jsonb_build_object('value', '2 rétegű kapcsolt gerébtokos', 'label', jsonb_build_object('hu', '2 rétegű kapcsolt gerébtokos', 'en', '2-layer Coupled Frame')),
  jsonb_build_object('value', 'Nem üvegezett bejárati', 'label', jsonb_build_object('hu', 'Nem üvegezett bejárati', 'en', 'Non-glazed Entrance'))
)
WHERE name = 'window_glazing';

-- EV Brand Options
UPDATE public.survey_questions
SET options_translations = jsonb_build_array(
  jsonb_build_object('value', 'Audi', 'label', jsonb_build_object('hu', 'Audi', 'en', 'Audi')),
  jsonb_build_object('value', 'BMW', 'label', jsonb_build_object('hu', 'BMW', 'en', 'BMW')),
  jsonb_build_object('value', 'Hyundai', 'label', jsonb_build_object('hu', 'Hyundai', 'en', 'Hyundai')),
  jsonb_build_object('value', 'Kia', 'label', jsonb_build_object('hu', 'Kia', 'en', 'Kia')),
  jsonb_build_object('value', 'Mercedes-Benz', 'label', jsonb_build_object('hu', 'Mercedes-Benz', 'en', 'Mercedes-Benz')),
  jsonb_build_object('value', 'Nissan', 'label', jsonb_build_object('hu', 'Nissan', 'en', 'Nissan')),
  jsonb_build_object('value', 'Renault', 'label', jsonb_build_object('hu', 'Renault', 'en', 'Renault')),
  jsonb_build_object('value', 'Skoda', 'label', jsonb_build_object('hu', 'Skoda', 'en', 'Skoda')),
  jsonb_build_object('value', 'Tesla', 'label', jsonb_build_object('hu', 'Tesla', 'en', 'Tesla')),
  jsonb_build_object('value', 'Volkswagen', 'label', jsonb_build_object('hu', 'Volkswagen', 'en', 'Volkswagen')),
  jsonb_build_object('value', 'Egyéb', 'label', jsonb_build_object('hu', 'Egyéb', 'en', 'Other'))
)
WHERE name = 'ev_brand_select';

-- EV Connector Type Options
UPDATE public.survey_questions
SET options_translations = jsonb_build_array(
  jsonb_build_object('value', 'Type2', 'label', jsonb_build_object('hu', 'Type2', 'en', 'Type2')),
  jsonb_build_object('value', 'Type1', 'label', jsonb_build_object('hu', 'Type1', 'en', 'Type1'))
)
WHERE name = 'ev_connector_type';

-- Installation Site Type Options (Car Charger)
UPDATE public.survey_questions
SET options_translations = jsonb_build_array(
  jsonb_build_object('value', 'Családi ház', 'label', jsonb_build_object('hu', 'Családi ház', 'en', 'Family House')),
  jsonb_build_object('value', 'Ikerház', 'label', jsonb_build_object('hu', 'Ikerház', 'en', 'Semi-detached House')),
  jsonb_build_object('value', 'Sorház', 'label', jsonb_build_object('hu', 'Sorház', 'en', 'Terraced House')),
  jsonb_build_object('value', 'Társasház', 'label', jsonb_build_object('hu', 'Társasház', 'en', 'Condominium'))
)
WHERE name = 'installation_site_type';

-- Ownership Options
UPDATE public.survey_questions
SET options_translations = jsonb_build_array(
  jsonb_build_object('value', 'Ügyfél saját tulajdona', 'label', jsonb_build_object('hu', 'Ügyfél saját tulajdona', 'en', 'Client Own Property')),
  jsonb_build_object('value', 'Több tulajdonos', 'label', jsonb_build_object('hu', 'Több tulajdonos', 'en', 'Multiple Owners')),
  jsonb_build_object('value', 'Bérelt', 'label', jsonb_build_object('hu', 'Bérelt', 'en', 'Rented'))
)
WHERE name = 'ownership';

-- Site Access Options
UPDATE public.survey_questions
SET options_translations = jsonb_build_array(
  jsonb_build_object('value', 'Privát, zárt', 'label', jsonb_build_object('hu', 'Privát, zárt', 'en', 'Private, Closed')),
  jsonb_build_object('value', 'Zárt, de osztott használatú', 'label', jsonb_build_object('hu', 'Zárt, de osztott használatú', 'en', 'Closed, Shared Use')),
  jsonb_build_object('value', 'Utcai beálló', 'label', jsonb_build_object('hu', 'Utcai beálló', 'en', 'Street Parking'))
)
WHERE name = 'site_access';

-- Site Nature Options
UPDATE public.survey_questions
SET options_translations = jsonb_build_array(
  jsonb_build_object('value', 'Garázs', 'label', jsonb_build_object('hu', 'Garázs', 'en', 'Garage')),
  jsonb_build_object('value', 'Mélygarázs', 'label', jsonb_build_object('hu', 'Mélygarázs', 'en', 'Underground Garage')),
  jsonb_build_object('value', 'Fedett kerti kocsibeálló', 'label', jsonb_build_object('hu', 'Fedett kerti kocsibeálló', 'en', 'Covered Garden Parking')),
  jsonb_build_object('value', 'Nem fedett kerti kocsibeálló', 'label', jsonb_build_object('hu', 'Nem fedett kerti kocsibeálló', 'en', 'Uncovered Garden Parking'))
)
WHERE name = 'site_nature';

-- Mounting Surface Type Options
UPDATE public.survey_questions
SET options_translations = jsonb_build_array(
  jsonb_build_object('value', 'Falfelület', 'label', jsonb_build_object('hu', 'Falfelület', 'en', 'Wall Surface')),
  jsonb_build_object('value', 'Beton alapzat', 'label', jsonb_build_object('hu', 'Beton alapzat', 'en', 'Concrete Base'))
)
WHERE name = 'mounting_surface_type';

-- Heat Pump Type Options
UPDATE public.survey_questions
SET options_translations = jsonb_build_array(
  jsonb_build_object('value', 'Egyszerűsített', 'label', jsonb_build_object('hu', 'Egyszerűsített', 'en', 'Simplified')),
  jsonb_build_object('value', 'FÉG', 'label', jsonb_build_object('hu', 'FÉG', 'en', 'FÉG'))
)
WHERE name = 'heat_pump_type';

-- ============================================================================
-- Log completion
-- ============================================================================

DO $$
BEGIN
  RAISE NOTICE 'Complete question translations seeded successfully - ALL investments covered';
END $$;
