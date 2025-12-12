-- Add "Total Annual Consumption" row to the top of energy_consumption_table

UPDATE survey_questions
SET options = jsonb_set(
  options,
  '{row_groups}',
  jsonb_build_array(
    -- NEW: Total annual consumption row (at the top)
    jsonb_build_object(
      'category', jsonb_build_object(
        'hu', 'Teljes éves energiafelhasználás',
        'en', 'Total Annual Energy Consumption'
      ),
      'background_color', 'bg-emerald-50',
      'rows', jsonb_build_array(
        jsonb_build_object(
          'key', 'total_annual_consumption',
          'label', jsonb_build_object(
            'hu', 'Éves fogyasztás',
            'en', 'Annual Consumption'
          )
          -- No 'unit' here, units are per column in column_units
          -- No 'columns' restriction - shows in all columns
        )
      )
    )
  ) || (options->'row_groups') -- Append existing row_groups after the new one
)
WHERE name = 'energy_consumption_table'
AND survey_page_id = (
  SELECT id FROM survey_pages
  WHERE name = 'Energiafelhasználási adatok'
  AND investment_id = (SELECT id FROM investments WHERE persist_name = 'consultantMode')
);
