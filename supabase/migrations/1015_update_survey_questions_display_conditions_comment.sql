-- Migration: Update survey_questions display_conditions comment
-- Description: Extend display_conditions documentation to include visible_for_sources logic
-- Date: 2025-11-06

-- ============================================================================
-- UPDATE COMMENT FOR display_conditions COLUMN
-- ============================================================================

COMMENT ON COLUMN public.survey_questions.display_conditions IS
'Conditional display rules for this question. Structure (all fields optional):
{
  "field": "field_name",                       // Field to check (e.g., "current_heating_solution")
  "operator": "equals|not_equals|...",         // Comparison operator
  "value": "target_value",                     // Value to compare against
  "visible_for_sources": ["OFP", "EKR"]        // Show only for specific external sources
}

Supported operators:
- equals, not_equals
- greater_than, less_than, greater_or_equal, less_or_equal
- contains, contains_any (for multiselect fields)

Logic for visible_for_sources:
- If array is present and survey has ofp_survey_id → show only if "OFP" is in array
- If array is present and survey has ekr_survey_id → show only if "EKR" is in array
- If array is not present → show for all surveys (default behavior)
- If survey has no external IDs → question is visible (normal Flow survey)

Examples:
1. Field-based condition:
   {"field": "current_heating_solution", "operator": "equals", "value": "Egyéb"}

2. External source restriction:
   {"visible_for_sources": ["OFP"]}
   (Only show for OFP surveys)

3. Combined conditions:
   {"field": "heating_solution", "operator": "equals", "value": "heat_pump", "visible_for_sources": ["OFP", "EKR"]}
   (Show if heating_solution is heat_pump AND survey is from OFP or EKR)';
