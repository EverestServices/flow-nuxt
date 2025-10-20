# Documentation Standard

This document outlines how to write documentation for UI components in the Everest Flow project.

## File Location

All component documentation should be placed in `/DOCS/components/[ComponentName].md`

## Documentation Template

Every component documentation file must follow this structure:

```markdown
# ComponentName

Brief one-line description of what the component does.

## Overview

A more detailed explanation of the component's purpose, use cases, and when to use it.

## Import

\`\`\`vue
<script setup lang="ts">
import ComponentName from '~/components/UI/ComponentName.vue'
</script>
\`\`\`

## Basic Usage

\`\`\`vue
<template>
  <ComponentName>
    Basic example
  </ComponentName>
</template>
\`\`\`

## Props

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| variant | 'primary' \| 'secondary' \| 'outline' | 'primary' | Visual style variant |
| size | 'xs' \| 'sm' \| 'md' \| 'lg' \| 'xl' | 'md' | Component size |

## Variants

### Primary
\`\`\`vue
<ComponentName variant="primary">Primary</ComponentName>
\`\`\`

### Secondary
\`\`\`vue
<ComponentName variant="secondary">Secondary</ComponentName>
\`\`\`

## Sizes

Examples of all available sizes with code samples.

## Events

| Event | Payload | Description |
|-------|---------|-------------|
| @click | MouseEvent | Emitted when component is clicked |

## Slots

| Slot | Description |
|------|-------------|
| default | Main content slot |
| icon | Icon slot (if applicable) |

## Accessibility

- List ARIA attributes used
- Keyboard navigation support
- Screen reader considerations

## Examples

### Example 1: [Description]
\`\`\`vue
<template>
  <!-- Full example with context -->
</template>
\`\`\`

### Example 2: [Description]
\`\`\`vue
<template>
  <!-- Another example -->
</template>
\`\`\`

## Best Practices

- When to use this component
- Common patterns
- Things to avoid

## Related Components

- [RelatedComponent1](./RelatedComponent1.md)
- [RelatedComponent2](./RelatedComponent2.md)

## Component File

Located at: `app/components/UI/ComponentName.vue`
```

## Writing Guidelines

### 1. Be Clear and Concise
- Start with a single sentence describing what the component does
- Use simple language
- Avoid jargon unless necessary

### 2. Provide Complete Examples
- All code examples must be valid Vue 3 syntax
- Include `<script setup>` when needed
- Show realistic use cases, not just isolated examples

### 3. Document All Props
- Include type information
- Specify default values
- Describe what the prop does and how it affects the component

### 4. Show Visual Variants
- Document all available variants
- Show size options
- Include state examples (hover, active, disabled)

### 5. Include Accessibility Information
- Document ARIA attributes
- Explain keyboard interactions
- Note screen reader behavior

### 6. Add Related Components
- Link to similar components
- Suggest complementary components
- Help users discover related functionality

## Code Block Formatting

### Vue Components
\`\`\`vue
<script setup lang="ts">
// TypeScript code here
</script>

<template>
  <!-- Template code here -->
</template>
\`\`\`

### TypeScript/JavaScript
\`\`\`typescript
interface Props {
  variant: 'primary' | 'secondary'
}
\`\`\`

### CSS/Tailwind
\`\`\`css
.custom-class {
  @apply bg-white/30 backdrop-blur-xl;
}
\`\`\`

## Updating Documentation

**CRITICAL RULE**: Every time you modify a component, you MUST update its documentation in the same commit.

When updating docs:
1. Update the Props table if you added/changed props
2. Add new examples if you added features
3. Update the Variants section if you added new variants
4. Modify the Best Practices if usage patterns changed
5. Update the file modification date in git

## Tables

Use markdown tables for structured data:

```markdown
| Column 1 | Column 2 | Column 3 |
|----------|----------|----------|
| Data 1   | Data 2   | Data 3   |
```

## Links

- Internal links to other docs: `[Button Component](./Button.md)`
- External links: `[Vue 3 Documentation](https://vuejs.org/)`
- File paths: Use backticks for file paths: `` `app/components/UI/Button.vue` ``

## Version History

If a component has significant changes, add a version history section:

```markdown
## Version History

### v1.1.0 (2025-10-20)
- Added `disabled` prop
- Fixed accessibility issues with keyboard navigation

### v1.0.0 (2025-10-15)
- Initial release
```

## Examples Section Best Practices

1. **Start Simple**: Begin with the most basic usage
2. **Build Complexity**: Progress to more advanced examples
3. **Show Real Use Cases**: Use realistic data and scenarios
4. **Include Edge Cases**: Show how to handle special situations

## DO's and DON'Ts

### DO:
✓ Update docs immediately when changing components
✓ Provide multiple examples
✓ Explain "why" not just "what"
✓ Link to related components
✓ Document edge cases
✓ Include TypeScript types

### DON'T:
✗ Leave documentation outdated
✗ Use vague descriptions
✗ Skip accessibility information
✗ Forget to document props
✗ Use incomplete code examples
✗ Copy-paste without updating

## Questions?

If you're unsure how to document something:
1. Look at existing component documentation for patterns
2. Ask the team for clarification
3. Err on the side of more detail rather than less

---

**Remember**: Good documentation is as important as good code!
