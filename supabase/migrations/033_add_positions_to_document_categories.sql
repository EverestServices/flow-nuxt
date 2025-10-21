-- Add position field to document_categories table
-- Positions are stored as JSONB with {top: number, right: number} structure

-- Update positions for all document categories based on FlowFrontend HouseVisualization component

-- Roof-related categories - positioned on roof area
UPDATE document_categories SET position = '{"top": 120, "right": 350}'::jsonb WHERE persist_name = 'roof-condition';
UPDATE document_categories SET position = '{"top": 140, "right": 380}'::jsonb WHERE persist_name = 'roof-structure';
UPDATE document_categories SET position = '{"top": 160, "right": 320}'::jsonb WHERE persist_name = 'roof-access';
UPDATE document_categories SET position = '{"top": 180, "right": 360}'::jsonb WHERE persist_name = 'attic-condition';

-- Electrical categories - positioned near electrical areas (lower right side)
UPDATE document_categories SET position = '{"top": 420, "right": 300}'::jsonb WHERE persist_name = 'electrical-meter';
UPDATE document_categories SET position = '{"top": 450, "right": 330}'::jsonb WHERE persist_name = 'electrical-system';
UPDATE document_categories SET position = '{"top": 480, "right": 300}'::jsonb WHERE persist_name = 'meter-box-interior';

-- Indoor equipment - positioned inside house structure
UPDATE document_categories SET position = '{"top": 320, "right": 420}'::jsonb WHERE persist_name = 'inverter-room';
UPDATE document_categories SET position = '{"top": 350, "right": 450}'::jsonb WHERE persist_name = 'battery-placement';
UPDATE document_categories SET position = '{"top": 280, "right": 400}'::jsonb WHERE persist_name = 'indoor-unit';
UPDATE document_categories SET position = '{"top": 310, "right": 380}'::jsonb WHERE persist_name = 'heating-system';
UPDATE document_categories SET position = '{"top": 340, "right": 410}'::jsonb WHERE persist_name = 'ac-indoor-unit';

-- Outdoor equipment - positioned in outdoor/garden area
UPDATE document_categories SET position = '{"top": 480, "right": 580}'::jsonb WHERE persist_name = 'outdoor-unit';
UPDATE document_categories SET position = '{"top": 510, "right": 600}'::jsonb WHERE persist_name = 'ac-outdoor-unit';

-- Wall-related categories - positioned on wall areas
UPDATE document_categories SET position = '{"top": 250, "right": 520}'::jsonb WHERE persist_name = 'wall-insulation-area';
UPDATE document_categories SET position = '{"top": 280, "right": 550}'::jsonb WHERE persist_name = 'wall-condition';

-- Window categories - positioned near window areas
UPDATE document_categories SET position = '{"top": 220, "right": 480}'::jsonb WHERE persist_name = 'window-condition';
UPDATE document_categories SET position = '{"top": 240, "right": 500}'::jsonb WHERE persist_name = 'window-frame';

-- Piping routes - positioned along potential pipe routes
UPDATE document_categories SET position = '{"top": 380, "right": 480}'::jsonb WHERE persist_name = 'piping-route';
UPDATE document_categories SET position = '{"top": 410, "right": 510}'::jsonb WHERE persist_name = 'ac-piping-route';

-- Car charger categories - positioned in driveway/parking area (bottom area)
UPDATE document_categories SET position = '{"top": 580, "right": 400}'::jsonb WHERE persist_name = 'car-charger-placement';
UPDATE document_categories SET position = '{"top": 600, "right": 450}'::jsonb WHERE persist_name = 'parking-area';

-- Solar Panel Battery categories - positioned logically around the house
UPDATE document_categories SET position = '{"top": 100, "right": 380}'::jsonb WHERE persist_name = 'site-survey-photos';
UPDATE document_categories SET position = '{"top": 440, "right": 280}'::jsonb WHERE persist_name = 'meter-location-photos';
UPDATE document_categories SET position = '{"top": 470, "right": 250}'::jsonb WHERE persist_name = 'connection-point';
UPDATE document_categories SET position = '{"top": 410, "right": 260}'::jsonb WHERE persist_name = 'electricity-meter-number';
