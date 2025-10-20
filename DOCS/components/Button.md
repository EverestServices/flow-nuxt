# Button

A simple glassmorphic button component with backdrop blur effects for interactive actions.

## Overview

The Button component provides a clean, glassmorphic-styled button perfect for user interactions. Currently implements a single default style with a semi-transparent white background, border, and backdrop blur effect. It follows the Everest Flow design language with rounded pill shape and subtle transparency.

**Note**: This is the basic button component. For more variants (primary, secondary, outline, etc.), see the enhanced Button component coming in future updates.

## Import

```vue
<script setup lang="ts">
import UIButton from '~/components/UI/Button.vue'
</script>
```

## Basic Usage

```vue
<template>
  <UIButton>
    Click Me
  </UIButton>
</template>
```

## Props

Currently, this component does not accept props. It uses a fixed styling approach.

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| - | - | - | No props currently defined |

**Future Enhancement**: Props for variant, size, disabled state, and loading state will be added in upcoming versions.

## Default Styling

The button has the following built-in classes:
- `px-4 py-2` - Padding
- `rounded-full` - Pill-shaped borders
- `border backdrop-blur-md` - Border with backdrop blur
- `bg-white/50` - Semi-transparent white background
- `border-white` - White border

## Events

The button forwards all native button events to the parent component.

| Event | Payload | Description |
|-------|---------|-------------|
| @click | MouseEvent | Emitted when button is clicked |
| @mouseenter | MouseEvent | Emitted when mouse enters button |
| @mouseleave | MouseEvent | Emitted when mouse leaves button |
| @focus | FocusEvent | Emitted when button receives focus |
| @blur | FocusEvent | Emitted when button loses focus |

All standard HTML button events are supported.

## Slots

| Slot | Description |
|------|-------------|
| default | Main content slot for button text or icons |

## Accessibility

- **Native Button**: Uses semantic `<button>` element
- **Keyboard Navigation**: Fully keyboard accessible with Tab key
- **Activation**: Activated with Enter or Space keys
- **Focus Visible**: Browser default focus outline applies

**Recommended**: Add `aria-label` for icon-only buttons:

```vue
<UIButton aria-label="Close dialog">
  <IconClose />
</UIButton>
```

## Examples

### Example 1: Text Button

```vue
<script setup lang="ts">
import UIButton from '~/components/UI/Button.vue'
</script>

<template>
  <UIButton>
    Submit Form
  </UIButton>
</template>
```

### Example 2: Button with Click Handler

```vue
<script setup lang="ts">
import UIButton from '~/components/UI/Button.vue'

const handleClick = () => {
  console.log('Button clicked!')
  // Your logic here
}
</script>

<template>
  <UIButton @click="handleClick">
    Click Me
  </UIButton>
</template>
```

### Example 3: Icon + Text Button

```vue
<script setup lang="ts">
import UIButton from '~/components/UI/Button.vue'
</script>

<template>
  <UIButton>
    <div class="flex items-center gap-2">
      <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
      </svg>
      <span>Add New</span>
    </div>
  </UIButton>
</template>
```

### Example 4: Icon-Only Button

```vue
<template>
  <UIButton aria-label="Settings">
    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z" />
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
    </svg>
  </UIButton>
</template>
```

### Example 5: Form Submission

```vue
<script setup lang="ts">
import UIButton from '~/components/UI/Button.vue'
import { ref } from 'vue'

const formData = ref({ name: '', email: '' })

const handleSubmit = async () => {
  // Validate form
  if (!formData.value.name || !formData.value.email) {
    alert('Please fill in all fields')
    return
  }

  // Submit form
  console.log('Submitting:', formData.value)
}
</script>

<template>
  <form @submit.prevent="handleSubmit">
    <input v-model="formData.name" placeholder="Name" class="block mb-2" />
    <input v-model="formData.email" placeholder="Email" class="block mb-4" />
    <UIButton type="submit">
      Submit
    </UIButton>
  </form>
</template>
```

### Example 6: Multiple Buttons in Group

```vue
<template>
  <div class="flex gap-3">
    <UIButton @click="handleCancel">
      Cancel
    </UIButton>
    <UIButton @click="handleSave">
      Save Changes
    </UIButton>
  </div>
</template>
```

### Example 7: Custom Styling via Classes

```vue
<template>
  <!-- Add custom classes for one-off styling -->
  <UIButton class="hover:bg-blue-500/50 hover:border-blue-500 transition-all">
    Custom Hover
  </UIButton>
</template>
```

## Best Practices

### When to Use

- Form submissions
- Triggering actions and events
- Navigation (though consider using NuxtLink for routes)
- Opening modals or dialogs
- Confirming or canceling operations

### Common Patterns

```vue
<!-- Standard action button -->
<UIButton @click="handleAction">
  Action
</UIButton>

<!-- Icon with text -->
<UIButton>
  <div class="flex items-center gap-2">
    <Icon />
    <span>Text</span>
  </div>
</UIButton>

<!-- Form submit -->
<UIButton type="submit">
  Submit
</UIButton>
```

### Things to Avoid

- ✓ **Do**: Use native button type attributes (`type="button"`, `type="submit"`)
- ✗ **Don't**: Use buttons for navigation (use NuxtLink instead)
- ✓ **Do**: Provide aria-label for icon-only buttons
- ✗ **Don't**: Put clickable elements inside buttons (no nested buttons)
- ✓ **Do**: Add event handlers via @click
- ✗ **Don't**: Disable buttons without explaining why to users
- ✓ **Do**: Use for actions that change application state
- ✗ **Don't**: Use for purely decorative elements

## Styling Customization

Since this component doesn't accept props, you can customize it by:

1. **Adding classes**:
```vue
<UIButton class="w-full text-lg">
  Full Width Button
</UIButton>
```

2. **Wrapping in a styled container**:
```vue
<div class="inline-block hover:scale-105 transition">
  <UIButton>Hover to Scale</UIButton>
</div>
```

3. **Using Tailwind's important modifier** (use sparingly):
```vue
<UIButton class="!bg-blue-500 !border-blue-600">
  Blue Button
</UIButton>
```

## Future Enhancements

The following features are planned for future versions:

- **Variants**: primary, secondary, outline, ghost, danger
- **Sizes**: xs, sm, md, lg, xl
- **States**: loading, disabled
- **Icons**: Built-in icon slots (left, right)
- **Block**: Full-width option
- **Customization**: Color and style props

For now, this basic button provides the glassmorphic foundation for the component library.

## Related Components

- [Box](./Box.md) - Container component with similar glassmorphic styling
- (Coming soon) Enhanced Button with variants and sizes

## Component File

Located at: `app/components/UI/Button.vue`

## Version History

### v1.0.0 (2025-10-20)
- Initial basic button implementation
- Glassmorphic design with fixed styling
- Supports all native button events
- Full keyboard accessibility
