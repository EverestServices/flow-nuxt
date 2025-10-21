# Box

A flexible container component with glassmorphic styling, perfect for creating card-like elements with backdrop blur effects.

## Overview

The Box component is the foundation of the Everest Flow design system. It provides a highly configurable glassmorphic container with semi-transparent backgrounds, backdrop blur effects, and customizable styling. Use it to create cards, panels, modals, and any content container that requires the signature glass effect.

The component follows the glassmorphism design pattern with sensible defaults while allowing complete customization through props.

## Import

```vue
<script setup lang="ts">
import UIBox from '~/components/UI/Box.vue'
</script>
```

## Basic Usage

```vue
<template>
  <UIBox>
    Your content here
  </UIBox>
</template>
```

## Props

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| rounded | string | 'rounded-4xl' | Border radius using Tailwind classes (e.g., 'rounded-lg', 'rounded-full') |
| shadow | string | 'shadow-lg' | Shadow depth using Tailwind classes |
| background | string | 'bg-white/30' | Background color with opacity |
| textColor | string | '' | Text color using Tailwind classes |
| border | string | 'border border-white' | Border styling |
| hover | string | 'hover:bg-white/30' | Hover state styling |
| transition | boolean | true | Enable transition animations |
| blur | string | 'backdrop-blur-md' | Backdrop blur intensity |
| width | string | '' | Width classes |
| padding | string | '' | Padding classes |
| class | string | '' | Additional custom classes |

## Variants

### Default Glassmorphic
```vue
<template>
  <UIBox>
    Default glass container
  </UIBox>
</template>
```

### Dark Glass
```vue
<template>
  <UIBox background="bg-black/30" border="border border-black/50">
    Dark glass container
  </UIBox>
</template>
```

### Heavy Blur
```vue
<template>
  <UIBox blur="backdrop-blur-2xl">
    Heavy blur effect
  </UIBox>
</template>
```

### Card Style
```vue
<template>
  <UIBox padding="p-6" rounded="rounded-2xl">
    <h3 class="outfit font-bold text-xl mb-2">Card Title</h3>
    <p class="text-gray-700">Card content with custom padding</p>
  </UIBox>
</template>
```

### Full Width Panel
```vue
<template>
  <UIBox width="w-full" padding="p-8" rounded="rounded-xl">
    Full width panel content
  </UIBox>
</template>
```

## Blur Levels

### Light Blur (Default)
```vue
<UIBox blur="backdrop-blur-md">Light blur</UIBox>
```

### Medium Blur
```vue
<UIBox blur="backdrop-blur-xl">Medium blur</UIBox>
```

### Heavy Blur
```vue
<UIBox blur="backdrop-blur-2xl">Heavy blur</UIBox>
```

## Border Radius Options

### Small Radius
```vue
<UIBox rounded="rounded-lg">Small corners</UIBox>
```

### Medium Radius
```vue
<UIBox rounded="rounded-2xl">Medium corners</UIBox>
```

### Large Radius (Default)
```vue
<UIBox rounded="rounded-4xl">Large corners</UIBox>
```

### Full Rounded
```vue
<UIBox rounded="rounded-full">Circular/pill shape</UIBox>
```

## Shadow Options

### No Shadow
```vue
<UIBox shadow="">No shadow</UIBox>
```

### Small Shadow
```vue
<UIBox shadow="shadow-sm">Small shadow</UIBox>
```

### Large Shadow (Default)
```vue
<UIBox shadow="shadow-lg">Large shadow</UIBox>
```

### Extra Large Shadow
```vue
<UIBox shadow="shadow-2xl">Extra large shadow</UIBox>
```

## States

### Default
```vue
<UIBox>Default state</UIBox>
```

### Custom Hover Effect
```vue
<UIBox hover="hover:bg-blue-500/40 hover:scale-105">
  Custom hover with scale
</UIBox>
```

### No Transition
```vue
<UIBox :transition="false">
  No transition animations
</UIBox>
```

## Slots

| Slot | Description |
|------|-------------|
| default | Main content slot for any child elements |

## Accessibility

- **Semantic HTML**: Uses `<div>` element suitable for general containers
- **Custom Roles**: Add `role` attribute via class prop if needed for specific use cases
- **Content Structure**: Ensure child content maintains proper heading hierarchy and ARIA labels

The Box component itself is presentation-only. Ensure that interactive elements within the box have proper accessibility attributes.

## Examples

### Example 1: Information Card

```vue
<script setup lang="ts">
import UIBox from '~/components/UI/Box.vue'
</script>

<template>
  <UIBox padding="p-6" rounded="rounded-2xl" class="max-w-md">
    <h2 class="outfit font-bold text-2xl mb-4">Welcome to Everest</h2>
    <p class="outfit text-gray-700 mb-4">
      Your comprehensive platform for managing clients, events, and team collaboration.
    </p>
    <button class="px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600">
      Get Started
    </button>
  </UIBox>
</template>
```

### Example 2: Dashboard Widget

```vue
<template>
  <UIBox padding="p-6" width="w-full" background="bg-white/40" blur="backdrop-blur-xl">
    <div class="flex items-center justify-between mb-4">
      <h3 class="outfit font-bold text-lg">Recent Activity</h3>
      <span class="text-sm text-gray-500">Last 24 hours</span>
    </div>
    <div class="space-y-3">
      <div class="flex items-center gap-3">
        <div class="w-2 h-2 bg-green-500 rounded-full"></div>
        <span>New client added</span>
      </div>
      <div class="flex items-center gap-3">
        <div class="w-2 h-2 bg-blue-500 rounded-full"></div>
        <span>Event scheduled</span>
      </div>
    </div>
  </UIBox>
</template>
```

### Example 3: Sidebar Menu Item

```vue
<template>
  <UIBox
    padding="p-4"
    rounded="rounded-xl"
    hover="hover:bg-white/50 hover:shadow-xl cursor-pointer"
    class="flex items-center gap-3"
  >
    <div class="w-8 h-8 bg-blue-500 rounded-lg flex items-center justify-center">
      <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6" />
      </svg>
    </div>
    <span class="outfit font-medium">Dashboard</span>
  </UIBox>
</template>
```

### Example 4: Modal Container

```vue
<template>
  <div class="fixed inset-0 bg-black/50 backdrop-blur-sm flex items-center justify-center">
    <UIBox
      padding="p-8"
      rounded="rounded-3xl"
      blur="backdrop-blur-2xl"
      background="bg-white/90"
      class="max-w-lg w-full"
    >
      <h2 class="outfit font-bold text-2xl mb-4">Confirm Action</h2>
      <p class="mb-6 text-gray-700">Are you sure you want to proceed with this action?</p>
      <div class="flex gap-3 justify-end">
        <button class="px-4 py-2 rounded-lg border border-gray-300">Cancel</button>
        <button class="px-4 py-2 rounded-lg bg-blue-500 text-white">Confirm</button>
      </div>
    </UIBox>
  </div>
</template>
```

### Example 5: Stat Card

```vue
<template>
  <UIBox padding="p-6" rounded="rounded-2xl" background="bg-gradient-to-br from-blue-500/30 to-purple-500/30">
    <div class="flex items-center justify-between">
      <div>
        <p class="outfit text-sm text-gray-600">Total Users</p>
        <h3 class="outfit font-black text-4xl mt-1">1,234</h3>
        <p class="outfit text-sm text-green-600 mt-2">↑ 12% from last month</p>
      </div>
      <div class="w-16 h-16 bg-blue-500/50 rounded-2xl flex items-center justify-center">
        <svg class="w-8 h-8 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z" />
        </svg>
      </div>
    </div>
  </UIBox>
</template>
```

## Best Practices

### When to Use

- Creating card layouts for content sections
- Building dashboard widgets and panels
- Designing modal dialogs and overlays
- Constructing navigation elements
- Any container requiring glassmorphic styling

### Common Patterns

```vue
<!-- Information card with padding -->
<UIBox padding="p-6" rounded="rounded-2xl">
  Content
</UIBox>

<!-- Full-width panel -->
<UIBox width="w-full" padding="p-8">
  Panel content
</UIBox>

<!-- Clickable card -->
<UIBox
  padding="p-4"
  hover="hover:bg-white/50 hover:scale-102 cursor-pointer"
  class="transition-all"
>
  Clickable content
</UIBox>
```

### Things to Avoid

- ✓ **Do**: Use Box for containers and layout elements
- ✗ **Don't**: Use Box for every single element (use regular divs where glassmorphism isn't needed)
- ✓ **Do**: Combine with padding prop for inner spacing
- ✗ **Don't**: Add padding directly to child elements unnecessarily
- ✓ **Do**: Customize blur and background for different effects
- ✗ **Don't**: Use too many heavily blurred boxes overlapping (performance impact)
- ✓ **Do**: Use semantic HTML within Box for better accessibility
- ✗ **Don't**: Nest too many Box components (can create excessive blur)

## TypeScript Types

```typescript
interface Props {
  rounded?: string        // Border radius classes
  shadow?: string         // Shadow classes
  background?: string     // Background color classes
  textColor?: string      // Text color classes
  border?: string         // Border classes
  hover?: string          // Hover state classes
  transition?: boolean    // Enable transitions
  blur?: string           // Backdrop blur classes
  width?: string          // Width classes
  padding?: string        // Padding classes
  class?: string          // Additional custom classes
}
```

## Related Components

- [Button](./Button.md) - For interactive button elements
- [Card](./Card.md) - Pre-styled card component built on Box
- [Modal](./Modal.md) - Modal dialog component using Box

## Component File

Located at: `app/components/UI/Box.vue`

## Version History

### v1.0.0 (2025-10-20)
- Initial implementation
- Glassmorphic design with full prop customization
- Computed classes for dynamic styling
- Transition support
