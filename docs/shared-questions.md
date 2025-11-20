# Shared Questions Feature

## Overview

The Shared Questions feature allows the same question to appear on multiple survey pages while maintaining a single source of truth for the answer. This prevents data duplication and ensures consistency across the survey.

## Architecture

### Database Schema

Two new columns have been added to the `survey_questions` table:

- **`shared_question_id`** (UUID, nullable): References the master question if this is a shared instance. NULL if this is a master question or regular question.
- **`is_shared_instance`** (BOOLEAN, default false): TRUE if this is a shared instance (alias) of another question. FALSE if this is a master question or regular question.

### Master/Instance Pattern

The feature uses a master/instance architecture:

1. **Master Question**: The original question where answers are stored
   - `shared_question_id = NULL`
   - `is_shared_instance = false`
   - Answers are saved to the `survey_answers` table with this question's ID

2. **Instance Question**: A reference/alias to the master question that appears on another page
   - `shared_question_id = <master_question_id>`
   - `is_shared_instance = true`
   - Answers are NOT saved for this question; they're saved for the master instead

## How It Works

### Saving Answers

When a user answers a shared question (either master or instance):

1. Frontend calls `saveResponse(questionName, value)` or `saveInstanceResponse(...)`
2. Store finds the question and checks `is_shared_instance` flag
3. If `is_shared_instance = true`, resolves to the master question ID via `shared_question_id`
4. Answer is saved to database using the **master question ID**
5. Local state is updated using the question **name** (same for both master and instance)

**Example:**
```typescript
// User fills out "wall_thickness" on Falak page (instance)
await store.saveResponse('wall_thickness', '30')

// Behind the scenes:
// 1. Find question: { id: 'instance-123', name: 'wall_thickness', is_shared_instance: true, shared_question_id: 'master-456' }
// 2. Resolve to master: actualQuestionId = 'master-456'
// 3. Save to DB: INSERT INTO survey_answers (survey_question_id, answer) VALUES ('master-456', '30')
// 4. Update local: investmentResponses[investmentId]['wall_thickness'] = '30'
```

### Loading Answers

When loading existing survey data:

1. Answers are loaded from database with their question IDs
2. Each answer is looked up in the question map
3. Answer is stored in local state using the question **name**
4. Since master and instance share the same name, both will display the same value

**Example:**
```typescript
// Database has: { survey_question_id: 'master-456', answer: '30' }
// Master question: { id: 'master-456', name: 'wall_thickness', ... }
// Instance question: { id: 'instance-123', name: 'wall_thickness', shared_question_id: 'master-456', ... }

// Loading: investmentResponses[investmentId]['wall_thickness'] = '30'
// Both pages see the same value when calling getResponse('wall_thickness')
```

### Getting Answers

When displaying a question (master or instance):

1. Frontend calls `getResponse(questionName)`
2. Returns `investmentResponses[activeInvestmentId][questionName]`
3. Since both master and instance use the same name, the same value is returned

## Database Constraints

The following constraints ensure data integrity:

1. **Shared instance must have a master**:
   ```sql
   CHECK (
     (is_shared_instance = false) OR
     (is_shared_instance = true AND shared_question_id IS NOT NULL)
   )
   ```

2. **No self-reference**:
   ```sql
   CHECK (
     shared_question_id IS NULL OR
     shared_question_id != id
   )
   ```

3. **Cascading deletion**: If a master question is deleted, all instances are automatically deleted:
   ```sql
   FOREIGN KEY (shared_question_id) REFERENCES survey_questions(id) ON DELETE CASCADE
   ```

## Code Implementation

### Store Methods Updated

The following methods in `surveyInvestments.ts` have been updated to handle shared questions:

1. **`findQuestionAndResolveShared(questionName)`**: Helper method to resolve instance to master
2. **`saveResponse(questionName, value)`**: Saves regular question answers
3. **`saveInstanceResponse(pageId, instanceIndex, questionName, value)`**: Saves answers for allow_multiple pages
4. **`saveSubPageInstanceResponse(...)`**: Saves answers for hierarchical subpages

All three save methods follow the same pattern:
- Find the question by name
- Check if `is_shared_instance = true`
- If yes, use `shared_question_id` for database operations
- If no, use the question's own ID

### Key Code Snippet

```typescript
// Resolve to master question ID if this is a shared instance
const actualQuestionId = question.is_shared_instance && question.shared_question_id
  ? question.shared_question_id
  : question.id

// Use actualQuestionId for all database operations
await supabase
  .from('survey_answers')
  .insert({
    survey_id: this.currentSurveyId,
    survey_question_id: actualQuestionId,  // Always uses master ID
    answer: String(value)
  })
```

## Usage Guide

### Creating Shared Questions

To create a shared question setup:

1. **Create the master question** on its primary page:
   ```sql
   INSERT INTO survey_questions (
     survey_page_id,
     name,
     name_translations,
     type,
     is_shared_instance,
     shared_question_id
   ) VALUES (
     '<primary_page_id>',
     'wall_thickness',
     '{"hu": "Falvastagság", "en": "Wall Thickness"}',
     'number',
     false,        -- This is the master
     NULL          -- No reference
   );
   ```

2. **Create instance question(s)** on other pages:
   ```sql
   INSERT INTO survey_questions (
     survey_page_id,
     name,
     name_translations,
     type,
     is_shared_instance,
     shared_question_id
   ) VALUES (
     '<secondary_page_id>',
     'wall_thickness',     -- MUST be the same name
     '{"hu": "Falvastagság", "en": "Wall Thickness"}',  -- Same translations
     'number',             -- Same type
     true,                 -- This is an instance
     '<master_question_id>'  -- Reference to master
   );
   ```

### Important Rules

1. **Same Name Required**: Master and instance questions MUST have the same `name` field
2. **Same Type Recommended**: Should have the same `type` for consistency
3. **Same Translations**: Should have identical `name_translations`
4. **One Master, Multiple Instances**: One question is the master; all others are instances
5. **Within Same Investment**: Shared questions should belong to pages within the same investment

### Frontend Behavior

From the user's perspective:
- Questions appear on multiple pages as expected
- Filling out the question on ANY page updates ALL instances
- Navigating between pages shows the same value everywhere
- Only one answer is stored in the database (under the master)

## Use Cases

### Example 1: Wall Thickness

**Scenario**: "Wall Thickness" needs to appear on both "Basic Data" and "Walls" pages.

**Setup**:
- Master: "wall_thickness" on "Homlokzati szigetelés alapadatok" page
- Instance: "wall_thickness" on "Falak" page

**Behavior**:
- User enters "30 cm" on Basic Data page → saved to master
- User navigates to Walls page → sees "30 cm" pre-filled
- User changes to "35 cm" on Walls page → updates the master answer
- User returns to Basic Data page → sees "35 cm"

### Example 2: Foundation Type

**Scenario**: "Foundation Type" appears on facade insulation basic data and walls pages.

**Setup**:
- Master: "foundation_type_avg" on "Homlokzati szigetelés alapadatok" page
- Instance: "foundation_type" on "Falak" page (with `shared_question_id` pointing to master)

**Behavior**:
- Single source of truth for foundation type across pages
- Consistent data without duplication

## Benefits

1. **Data Consistency**: Single source of truth prevents conflicting answers
2. **Reduced Storage**: Only one answer is stored in the database
3. **Automatic Synchronization**: Changes on any page instantly reflect on all pages
4. **Simpler Data Model**: No complex sync logic or conflict resolution needed
5. **User-Friendly**: Natural UX where the same question shows the same answer

## Technical Considerations

### Dependency Tracking

When a master question's value changes, dependent questions that use it as `default_value_source_question_id` are automatically updated via the `syncDependentQuestionsInState` method, which uses the **master question ID** for lookups.

### Copy Rules

If the master question is referenced in `survey_value_copy_rules`, the rules work correctly because the actual answer is stored with the master question ID.

### Migration Path

To convert existing questions to shared questions:

1. Identify the questions that should be shared
2. Choose which page has the "primary" instance (becomes master)
3. Update other instances:
   ```sql
   UPDATE survey_questions
   SET is_shared_instance = true,
       shared_question_id = '<master_question_id>'
   WHERE id = '<instance_question_id>';
   ```
4. Existing answers for instances are preserved but won't be used
5. Consider cleaning up orphaned answers if needed

## Limitations & Notes

- Shared questions must have the same `name` field
- Best used within the same investment
- Not recommended for questions on `allow_multiple` pages (complex instance tracking)
- Circular references are prevented by database constraints
- Frontend assumes question names are unique within a survey page

## Future Enhancements

Potential future improvements:
- UI indicator showing which questions are shared
- Admin tool to convert existing questions to shared
- Validation in frontend to prevent name conflicts
- Bulk operations for managing shared question groups
