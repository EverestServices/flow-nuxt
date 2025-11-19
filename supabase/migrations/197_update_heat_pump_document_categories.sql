-- Update document categories for Heat Pump investment
-- Remove old associations and add new ones

DO $$
DECLARE
    v_heat_pump_id uuid;
    v_category_id uuid;
    v_position integer := 1;
BEGIN
    -- Get Heat Pump investment ID
    SELECT id INTO v_heat_pump_id FROM investments WHERE persist_name = 'heatPump';

    -- Delete existing associations for Heat Pump
    DELETE FROM investment_document_categories WHERE investment_id = v_heat_pump_id;

    -- Create new document categories and associate them with Heat Pump

    -- 1. Ingatlan kívülről
    INSERT INTO document_categories (name, description, min_photos, persist_name)
    VALUES ('Ingatlan kívülről', NULL, 1, 'propertyExterior')
    ON CONFLICT (persist_name) DO UPDATE SET name = EXCLUDED.name
    RETURNING id INTO v_category_id;
    INSERT INTO investment_document_categories (investment_id, document_category_id, position)
    VALUES (v_heat_pump_id, v_category_id, v_position);
    v_position := v_position + 1;

    -- 2. Legjellemzőbb nyílászáró(k)
    INSERT INTO document_categories (name, description, min_photos, persist_name)
    VALUES ('Legjellemzőbb nyílászáró(k)', NULL, 1, 'typicalWindows')
    ON CONFLICT (persist_name) DO UPDATE SET name = EXCLUDED.name
    RETURNING id INTO v_category_id;
    INSERT INTO investment_document_categories (investment_id, document_category_id, position)
    VALUES (v_heat_pump_id, v_category_id, v_position);
    v_position := v_position + 1;

    -- 3. Kültéri egység helye (use existing)
    SELECT id INTO v_category_id FROM document_categories WHERE name = 'Kültéri egység helye';
    INSERT INTO investment_document_categories (investment_id, document_category_id, position)
    VALUES (v_heat_pump_id, v_category_id, v_position);
    v_position := v_position + 1;

    -- 4. Hőközpont helye
    INSERT INTO document_categories (name, description, min_photos, persist_name)
    VALUES ('Hőközpont helye', NULL, 1, 'heatingCenterLocation')
    ON CONFLICT (persist_name) DO UPDATE SET name = EXCLUDED.name
    RETURNING id INTO v_category_id;
    INSERT INTO investment_document_categories (investment_id, document_category_id, position)
    VALUES (v_heat_pump_id, v_category_id, v_position);
    v_position := v_position + 1;

    -- 5. Meglévő fűtőkészülék és adattáblája
    INSERT INTO document_categories (name, description, min_photos, persist_name)
    VALUES ('Meglévő fűtőkészülék és adattáblája', NULL, 1, 'existingHeatingDeviceAndDataPlate')
    ON CONFLICT (persist_name) DO UPDATE SET name = EXCLUDED.name
    RETURNING id INTO v_category_id;
    INSERT INTO investment_document_categories (investment_id, document_category_id, position)
    VALUES (v_heat_pump_id, v_category_id, v_position);
    v_position := v_position + 1;

    -- 6. Meglévő fűtőkészülék vízcsatlakozásai
    INSERT INTO document_categories (name, description, min_photos, persist_name)
    VALUES ('Meglévő fűtőkészülék vízcsatlakozásai', NULL, 1, 'existingHeatingDeviceWaterConnections')
    ON CONFLICT (persist_name) DO UPDATE SET name = EXCLUDED.name
    RETURNING id INTO v_category_id;
    INSERT INTO investment_document_categories (investment_id, document_category_id, position)
    VALUES (v_heat_pump_id, v_category_id, v_position);
    v_position := v_position + 1;

    -- 7. Osztó-gyűjtő
    INSERT INTO document_categories (name, description, min_photos, persist_name)
    VALUES ('Osztó-gyűjtő', NULL, 1, 'manifold')
    ON CONFLICT (persist_name) DO UPDATE SET name = EXCLUDED.name
    RETURNING id INTO v_category_id;
    INSERT INTO investment_document_categories (investment_id, document_category_id, position)
    VALUES (v_heat_pump_id, v_category_id, v_position);
    v_position := v_position + 1;

    -- 8. Mérőhely
    INSERT INTO document_categories (name, description, min_photos, persist_name)
    VALUES ('Mérőhely', NULL, 1, 'meterLocation')
    ON CONFLICT (persist_name) DO UPDATE SET name = EXCLUDED.name
    RETURNING id INTO v_category_id;
    INSERT INTO investment_document_categories (investment_id, document_category_id, position)
    VALUES (v_heat_pump_id, v_category_id, v_position);
    v_position := v_position + 1;

    -- 9. Csatlakozási pont (use existing)
    SELECT id INTO v_category_id FROM document_categories WHERE name = 'Csatlakozási pont';
    INSERT INTO investment_document_categories (investment_id, document_category_id, position)
    VALUES (v_heat_pump_id, v_category_id, v_position);
    v_position := v_position + 1;

    -- 10. Meglévő hőleadók
    INSERT INTO document_categories (name, description, min_photos, persist_name)
    VALUES ('Meglévő hőleadók', NULL, 1, 'existingHeatEmitters')
    ON CONFLICT (persist_name) DO UPDATE SET name = EXCLUDED.name
    RETURNING id INTO v_category_id;
    INSERT INTO investment_document_categories (investment_id, document_category_id, position)
    VALUES (v_heat_pump_id, v_category_id, v_position);
    v_position := v_position + 1;

    -- 11. Tervezett csövezés nyomvonala a kültéri egységtől a puffertartályig
    INSERT INTO document_categories (name, description, min_photos, persist_name)
    VALUES ('Tervezett csövezés nyomvonala a kültéri egységtől a puffertartályig', NULL, 1, 'plannedPipingOutdoorToBuffer')
    ON CONFLICT (persist_name) DO UPDATE SET name = EXCLUDED.name
    RETURNING id INTO v_category_id;
    INSERT INTO investment_document_categories (investment_id, document_category_id, position)
    VALUES (v_heat_pump_id, v_category_id, v_position);
    v_position := v_position + 1;

    -- 12. Tervezett csövezés nyomvonala a puffertartálytól a rákötési pontokig
    INSERT INTO document_categories (name, description, min_photos, persist_name)
    VALUES ('Tervezett csövezés nyomvonala a puffertartálytól a rákötési pontokig', NULL, 1, 'plannedPipingBufferToConnections')
    ON CONFLICT (persist_name) DO UPDATE SET name = EXCLUDED.name
    RETURNING id INTO v_category_id;
    INSERT INTO investment_document_categories (investment_id, document_category_id, position)
    VALUES (v_heat_pump_id, v_category_id, v_position);

    -- Delete unused document categories that are not associated with any investment
    DELETE FROM document_categories
    WHERE id NOT IN (
        SELECT DISTINCT document_category_id
        FROM investment_document_categories
    );

END $$;
