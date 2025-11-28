/**
 * OFP → Flow Integration Mappings
 *
 * This file contains all the mapping configurations needed for syncing
 * data between OFP (Otthon Felújítási Program) and Flow systems.
 */

/**
 * Investment persist_name mapping (for prefillData)
 *
 * Maps OFP prefillData keys to Flow investment persist_names.
 * Used when processing survey answer prefill data.
 */
export const INVESTMENT_MAPPING: Record<string, string> = {
  'basicData': 'basicData',
  'facadeInsulation': 'facadeInsulation',
  'heatPump': 'heatPump',
  'roofInsulation': 'roofInsulation',
  'windows': 'windows',
}

/**
 * OFP planned investment names → Flow investment persist_name mapping
 *
 * Maps OFP planned investment display names to Flow investment persist_names.
 * Used when setting up which investments are planned for a survey.
 */
export const PLANNED_INVESTMENT_MAPPING: Record<string, string> = {
  'Wall insulation': 'facadeInsulation',
  'Roof insulation': 'roofInsulation',
  'Window replacement': 'windows',
  'Heat pump': 'heatPump',
}

/**
 * Debug mode configuration
 * Set to true to enable detailed logging for floor_area fields
 */
export const DEBUG_FLOOR_AREA = true

/**
 * Floor area question IDs for debugging
 * These UUIDs identify the specific questions in the Flow database
 */
export const FLOOR_AREA_QUESTION_IDS = {
  building_useful_floor_area: 'c401e3cb-8565-4bbf-9376-fec32cbd742e',
  heated_floor_area: 'f923a636-7c4d-4769-b744-cd4623bf97f2',
}
