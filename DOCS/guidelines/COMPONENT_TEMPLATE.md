# Component Template

Use this template when documenting new components. Copy this file and fill in all sections.

---

# [ComponentName]

[One-line description of what this component does]

## Overview

[Detailed explanation of the component's purpose, use cases, and when to use it. Include information about the design philosophy and how it fits into the overall UI system.]

## Import

```vue
<script setup lang="ts">
import [ComponentName] from '~/components/UI/[ComponentName].vue'
</script>
```

## Basic Usage

```vue
<template>
  <[ComponentName]>
    [Basic example content]
  </[ComponentName]>
</template>
```

## Props

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| variant | 'primary' \| 'secondary' | 'primary' | Visual style variant |
| size | 'xs' \| 'sm' \| 'md' \| 'lg' | 'md' | Component size |
| disabled | boolean | false | Disables the component |

[Add all props with accurate types and descriptions]

## Variants

### [Variant Name 1]

[Description of this variant]

```vue
<template>
  <[ComponentName] variant="[variantName]">
    [Example]
  </[ComponentName]>
</template>
```

### [Variant Name 2]

[Description of this variant]

```vue
<template>
  <[ComponentName] variant="[variantName]">
    [Example]
  </[ComponentName]>
</template>
```

[Add all variants]

## Sizes

### Extra Small (xs)
```vue
<[ComponentName] size="xs">[Example]</[ComponentName]>
```

### Small (sm)
```vue
<[ComponentName] size="sm">[Example]</[ComponentName]>
```

### Medium (md) - Default
```vue
<[ComponentName] size="md">[Example]</[ComponentName]>
```

### Large (lg)
```vue
<[ComponentName] size="lg">[Example]</[ComponentName]>
```

[Add all applicable sizes]

## States

### Default
```vue
<[ComponentName]>[Example]</[ComponentName]>
```

### Disabled
```vue
<[ComponentName] disabled>[Example]</[ComponentName]>
```

[Add other states: loading, error, success, etc.]

## Events

| Event | Payload | Description |
|-------|---------|-------------|
| @click | MouseEvent | Emitted when component is clicked |
| @change | value: string | Emitted when value changes |

[Document all emitted events]

## Slots

| Slot | Description |
|------|-------------|
| default | Main content slot |
| icon | Icon slot (if applicable) |
| prefix | Content before main content |
| suffix | Content after main content |

[Document all available slots]

## Accessibility

[Document accessibility features:]

- **ARIA Attributes**: [List ARIA attributes used, e.g., aria-label, aria-disabled, role]
- **Keyboard Navigation**: [List keyboard shortcuts, e.g., Enter to activate, Escape to close]
- **Screen Reader**: [Describe how screen readers announce this component]
- **Focus Management**: [Describe focus behavior]

Example:
- Uses `role="button"` and `aria-label` for accessibility
- Keyboard navigable with Tab key
- Activated with Enter or Space keys
- Disabled state announced to screen readers

## Styling Customization

[If component allows custom styling, document how:]

### Custom Classes
```vue
<[ComponentName] class="custom-tailwind-classes">
  Content
</[ComponentName]>
```

### Custom Styles
```vue
<[ComponentName] :style="{ backgroundColor: '#custom' }">
  Content
</[ComponentName]>
```

## Examples

### Example 1: [Descriptive Title]

[Explain what this example demonstrates]

```vue
<script setup lang="ts">
import [ComponentName] from '~/components/UI/[ComponentName].vue'

// Any setup needed for the example
const handleClick = () => {
  console.log('Clicked!')
}
</script>

<template>
  <[ComponentName] @click="handleClick">
    Example Content
  </[ComponentName]>
</template>
```

### Example 2: [Descriptive Title]

[Explain what this example demonstrates]

```vue
<template>
  <div class="space-y-4">
    <[ComponentName] variant="primary">Primary</[ComponentName]>
    <[ComponentName] variant="secondary">Secondary</[ComponentName]>
  </div>
</template>
```

### Example 3: [Real-World Use Case]

[Show a realistic example from your application]

```vue
<script setup lang="ts">
// Realistic setup code
const handleSubmit = async () => {
  // Example logic
}
</script>

<template>
  <form @submit.prevent="handleSubmit">
    <!-- Realistic form example -->
  </form>
</template>
```

[Add at least 3-5 practical examples]

## Best Practices

### When to Use

- [List scenarios where this component is appropriate]
- [Provide guidance on proper usage]

### Common Patterns

```vue
<!-- Show common usage patterns -->
```

### Things to Avoid

- [List anti-patterns or incorrect usage]
- [Explain why to avoid them]

Example:
- ✓ **Do**: Use variant="primary" for main actions
- ✗ **Don't**: Use multiple primary buttons on the same page
- ✓ **Do**: Provide accessible labels
- ✗ **Don't**: Nest buttons inside buttons

## TypeScript Types

[If component exports types, document them:]

```typescript
export interface [ComponentName]Props {
  variant: 'primary' | 'secondary'
  size: 'xs' | 'sm' | 'md' | 'lg'
  disabled?: boolean
}

export type [ComponentName]Variant = 'primary' | 'secondary'
export type [ComponentName]Size = 'xs' | 'sm' | 'md' | 'lg'
```

## Related Components

- [[RelatedComponent1]](./[RelatedComponent1].md) - [Brief description]
- [[RelatedComponent2]](./[RelatedComponent2].md) - [Brief description]

## Component File

Located at: `app/components/UI/[ComponentName].vue`

## Version History

### v1.0.0 (YYYY-MM-DD)
- Initial release

[Add version history for significant changes]

---

## Notes for Documentation Writers

**Before finalizing this documentation:**

- [ ] All sections are filled in (no placeholders left)
- [ ] All props are documented with correct types
- [ ] All variants have visual examples
- [ ] All events are documented
- [ ] All slots are documented
- [ ] Accessibility section is complete
- [ ] At least 3 realistic examples are provided
- [ ] Best practices section has useful guidance
- [ ] Related components are linked
- [ ] Component file path is correct
- [ ] All code examples are tested and valid
- [ ] TypeScript types are documented
- [ ] No spelling or grammar errors

**Remember**: Remove this "Notes for Documentation Writers" section before committing!
