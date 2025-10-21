# ButtonEnhanced

A comprehensive button component with multiple variants, sizes, states, and full customization options.

## Overview

ButtonEnhanced is the fully-featured button component for the Everest Flow UI library. It provides seven different visual variants, five size options, loading states, icon support, and follows the glassmorphism design language. Use this component for all interactive button needs across your application.

## Import

```vue
<script setup lang="ts">
import UIButtonEnhanced from '~/components/UI/ButtonEnhanced.vue'
</script>
```

## Basic Usage

```vue
<template>
  <UIButtonEnhanced>
    Click Me
  </UIButtonEnhanced>
</template>
```

## Props

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| variant | 'primary' \| 'secondary' \| 'outline' \| 'ghost' \| 'danger' \| 'success' \| 'glass' | 'primary' | Visual style variant |
| size | 'xs' \| 'sm' \| 'md' \| 'lg' \| 'xl' | 'md' | Button size |
| type | 'button' \| 'submit' \| 'reset' | 'button' | HTML button type attribute |
| disabled | boolean | false | Disables the button |
| loading | boolean | false | Shows loading spinner and disables button |
| block | boolean | false | Makes button full width |
| iconPosition | 'left' \| 'right' | 'left' | Position of icon slot |

## Variants

### Primary
```vue
<UIButtonEnhanced variant="primary">
  Primary Button
</UIButtonEnhanced>
```
Blue background with white text. Use for primary actions.

### Secondary
```vue
<UIButtonEnhanced variant="secondary">
  Secondary Button
</UIButtonEnhanced>
```
Gray background with white text. Use for secondary actions.

### Outline
```vue
<UIButtonEnhanced variant="outline">
  Outline Button
</UIButtonEnhanced>
```
Transparent background with blue border. Use for less emphasized actions.

### Ghost
```vue
<UIButtonEnhanced variant="ghost">
  Ghost Button
</UIButtonEnhanced>
```
Transparent with no border, shows background on hover. Use for subtle actions.

### Danger
```vue
<UIButtonEnhanced variant="danger">
  Delete
</UIButtonEnhanced>
```
Red background with white text. Use for destructive actions.

### Success
```vue
<UIButtonEnhanced variant="success">
  Confirm
</UIButtonEnhanced>
```
Green background with white text. Use for positive confirmations.

### Glass
```vue
<UIButtonEnhanced variant="glass">
  Glass Button
</UIButtonEnhanced>
```
Glassmorphic style matching the app's design language. Use for floating actions.

## Sizes

### Extra Small (xs)
```vue
<UIButtonEnhanced size="xs">Extra Small</UIButtonEnhanced>
```

### Small (sm)
```vue
<UIButtonEnhanced size="sm">Small</UIButtonEnhanced>
```

### Medium (md) - Default
```vue
<UIButtonEnhanced size="md">Medium</UIButtonEnhanced>
```

### Large (lg)
```vue
<UIButtonEnhanced size="lg">Large</UIButtonEnhanced>
```

### Extra Large (xl)
```vue
<UIButtonEnhanced size="xl">Extra Large</UIButtonEnhanced>
```

## States

### Default
```vue
<UIButtonEnhanced>Default State</UIButtonEnhanced>
```

### Disabled
```vue
<UIButtonEnhanced disabled>Disabled Button</UIButtonEnhanced>
```

### Loading
```vue
<UIButtonEnhanced loading>Loading...</UIButtonEnhanced>
```

### Block (Full Width)
```vue
<UIButtonEnhanced block>Full Width Button</UIButtonEnhanced>
```

## Events

| Event | Payload | Description |
|-------|---------|-------------|
| @click | MouseEvent | Emitted when button is clicked (not emitted when disabled or loading) |

## Slots

| Slot | Description |
|------|-------------|
| default | Main content slot for button text |
| icon | Icon slot - position controlled by iconPosition prop |

## With Icons

### Icon on Left (Default)
```vue
<UIButtonEnhanced>
  <template #icon>
    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
    </svg>
  </template>
  Add New
</UIButtonEnhanced>
```

### Icon on Right
```vue
<UIButtonEnhanced icon-position="right">
  Next
  <template #icon>
    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
    </svg>
  </template>
</UIButtonEnhanced>
```

### Icon Only
```vue
<UIButtonEnhanced aria-label="Settings">
  <template #icon>
    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0..." />
    </svg>
  </template>
</UIButtonEnhanced>
```

## Accessibility

- **Native Button**: Uses semantic `<button>` element
- **Type Attribute**: Supports all HTML button types (button, submit, reset)
- **ARIA**: Automatically handles disabled state
- **Keyboard Navigation**: Fully keyboard accessible with Tab key
- **Focus Ring**: Visible focus ring with proper offset
- **Activation**: Activated with Enter or Space keys
- **Loading State**: Prevents interaction when loading
- **Icon Labels**: Remember to add aria-label for icon-only buttons

## Examples

### Example 1: Form Submission

```vue
<script setup lang="ts">
import UIButtonEnhanced from '~/components/UI/ButtonEnhanced.vue'
import { ref } from 'vue'

const isSubmitting = ref(false)

const handleSubmit = async () => {
  isSubmitting.value = true
  try {
    // Submit form logic
    await new Promise(resolve => setTimeout(resolve, 2000))
    console.log('Form submitted!')
  } finally {
    isSubmitting.value = false
  }
}
</script>

<template>
  <form @submit.prevent="handleSubmit">
    <UIButtonEnhanced
      type="submit"
      :loading="isSubmitting"
      block
    >
      {{ isSubmitting ? 'Submitting...' : 'Submit Form' }}
    </UIButtonEnhanced>
  </form>
</template>
```

### Example 2: Button Group

```vue
<template>
  <div class="flex gap-3">
    <UIButtonEnhanced variant="outline" @click="handleCancel">
      Cancel
    </UIButtonEnhanced>
    <UIButtonEnhanced variant="primary" @click="handleSave">
      Save Changes
    </UIButtonEnhanced>
  </div>
</template>
```

### Example 3: Destructive Action with Confirmation

```vue
<script setup lang="ts">
import UIButtonEnhanced from '~/components/UI/ButtonEnhanced.vue'
import { ref } from 'vue'

const showConfirm = ref(false)
const isDeleting = ref(false)

const handleDelete = async () => {
  isDeleting.value = true
  try {
    // Delete logic
    await new Promise(resolve => setTimeout(resolve, 1500))
    console.log('Deleted!')
    showConfirm.value = false
  } finally {
    isDeleting.value = false
  }
}
</script>

<template>
  <div>
    <UIButtonEnhanced variant="danger" size="sm" @click="showConfirm = true">
      <template #icon>
        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
        </svg>
      </template>
      Delete
    </UIButtonEnhanced>

    <!-- Confirmation Modal (simplified) -->
    <div v-if="showConfirm" class="fixed inset-0 bg-black/50 flex items-center justify-center">
      <div class="bg-white rounded-2xl p-6 max-w-md">
        <h3 class="outfit font-bold text-xl mb-4">Confirm Deletion</h3>
        <p class="mb-6">Are you sure you want to delete this item? This action cannot be undone.</p>
        <div class="flex gap-3 justify-end">
          <UIButtonEnhanced variant="ghost" @click="showConfirm = false" :disabled="isDeleting">
            Cancel
          </UIButtonEnhanced>
          <UIButtonEnhanced variant="danger" @click="handleDelete" :loading="isDeleting">
            Delete
          </UIButtonEnhanced>
        </div>
      </div>
    </div>
  </div>
</template>
```

### Example 4: All Variants Showcase

```vue
<template>
  <div class="space-y-3">
    <UIButtonEnhanced variant="primary">Primary</UIButtonEnhanced>
    <UIButtonEnhanced variant="secondary">Secondary</UIButtonEnhanced>
    <UIButtonEnhanced variant="outline">Outline</UIButtonEnhanced>
    <UIButtonEnhanced variant="ghost">Ghost</UIButtonEnhanced>
    <UIButtonEnhanced variant="danger">Danger</UIButtonEnhanced>
    <UIButtonEnhanced variant="success">Success</UIButtonEnhanced>
    <UIButtonEnhanced variant="glass">Glass</UIButtonEnhanced>
  </div>
</template>
```

### Example 5: All Sizes Showcase

```vue
<template>
  <div class="flex items-center gap-3">
    <UIButtonEnhanced size="xs">XS</UIButtonEnhanced>
    <UIButtonEnhanced size="sm">Small</UIButtonEnhanced>
    <UIButtonEnhanced size="md">Medium</UIButtonEnhanced>
    <UIButtonEnhanced size="lg">Large</UIButtonEnhanced>
    <UIButtonEnhanced size="xl">XL</UIButtonEnhanced>
  </div>
</template>
```

### Example 6: Icon Buttons

```vue
<template>
  <div class="flex gap-3">
    <!-- Edit -->
    <UIButtonEnhanced variant="outline" size="sm" aria-label="Edit">
      <template #icon>
        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
        </svg>
      </template>
    </UIButtonEnhanced>

    <!-- Delete -->
    <UIButtonEnhanced variant="danger" size="sm" aria-label="Delete">
      <template #icon>
        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
        </svg>
      </template>
    </UIButtonEnhanced>

    <!-- Download -->
    <UIButtonEnhanced variant="success" size="sm" aria-label="Download">
      <template #icon>
        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4" />
        </svg>
      </template>
    </UIButtonEnhanced>
  </div>
</template>
```

## Best Practices

### When to Use

- **Primary**: Main call-to-action (one per section recommended)
- **Secondary**: Alternative actions
- **Outline**: Less important actions, filters, or toggles
- **Ghost**: Subtle actions, navigation items
- **Danger**: Destructive actions (delete, remove, cancel)
- **Success**: Positive confirmations (save, approve, confirm)
- **Glass**: Floating actions, overlays, special UI elements

### Common Patterns

```vue
<!-- Form actions -->
<div class="flex gap-3 justify-end">
  <UIButtonEnhanced variant="ghost">Cancel</UIButtonEnhanced>
  <UIButtonEnhanced variant="primary" type="submit">Save</UIButtonEnhanced>
</div>

<!-- Destructive action -->
<UIButtonEnhanced variant="danger" size="sm">
  <template #icon><TrashIcon /></template>
  Delete
</UIButtonEnhanced>

<!-- Loading state -->
<UIButtonEnhanced :loading="isLoading">
  {{ isLoading ? 'Processing...' : 'Submit' }}
</UIButtonEnhanced>
```

### Things to Avoid

- ✓ **Do**: Use one primary button per section
- ✗ **Don't**: Use multiple primary buttons in the same view
- ✓ **Do**: Provide feedback with loading state
- ✗ **Don't**: Leave users waiting without visual feedback
- ✓ **Do**: Use danger variant for destructive actions
- ✗ **Don't**: Use danger for non-destructive actions
- ✓ **Do**: Add aria-label to icon-only buttons
- ✗ **Don't**: Create icon-only buttons without labels
- ✓ **Do**: Disable buttons when action is unavailable
- ✗ **Don't**: Hide buttons entirely (unless conditional rendering makes sense)

## TypeScript Types

```typescript
type ButtonVariant = 'primary' | 'secondary' | 'outline' | 'ghost' | 'danger' | 'success' | 'glass'
type ButtonSize = 'xs' | 'sm' | 'md' | 'lg' | 'xl'
type ButtonType = 'button' | 'submit' | 'reset'
type IconPosition = 'left' | 'right'

interface Props {
  variant?: ButtonVariant
  size?: ButtonSize
  type?: ButtonType
  disabled?: boolean
  loading?: boolean
  block?: boolean
  iconPosition?: IconPosition
}
```

## Related Components

- [Button](./Button.md) - Basic button component
- [Box](./Box.md) - Container component

## Component File

Located at: `app/components/UI/ButtonEnhanced.vue`

## Version History

### v1.0.0 (2025-10-20)
- Initial release with 7 variants
- 5 size options
- Loading state with spinner
- Icon support with position control
- Block (full width) option
- Focus ring and accessibility features
- TypeScript support
