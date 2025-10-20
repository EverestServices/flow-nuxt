# Typography Components

Heading components styled with the Outfit font family for consistent typography across the application.

## Overview

The Typography components provide semantic HTML headings (h1, h2, h3) with predefined Outfit font styling. These components ensure consistent heading styles throughout the Everest Flow application while maintaining proper semantic HTML structure for accessibility and SEO.

## Available Components

- **Title** (H1) - Main page titles and primary headings
- **H2** - Section headings and secondary titles
- **H3** - Subsection headings and tertiary titles

## Import

```vue
<script setup lang="ts">
import UITitle from '~/components/UI/Title.vue'
import UIH2 from '~/components/UI/H2.vue'
import UIH3 from '~/components/UI/H3.vue'
</script>
```

---

## Title Component (H1)

Main page title component with extra-bold weight and large size.

### Basic Usage

```vue
<template>
  <UITitle>Welcome to Everest Flow</UITitle>
</template>
```

### Styling

- **Tag**: `<h1>`
- **Font Family**: Outfit
- **Font Weight**: 900 (black)
- **Font Size**: text-4xl (2.25rem / 36px)
- **Classes**: `outfit font-black text-4xl`

### Example

```vue
<script setup lang="ts">
import UITitle from '~/components/UI/Title.vue'
</script>

<template>
  <div class="mb-8">
    <UITitle>Dashboard Overview</UITitle>
    <p class="text-gray-600 mt-2">Manage your clients, events, and team</p>
  </div>
</template>
```

---

## H2 Component

Section heading component with thin weight and medium-large size.

### Basic Usage

```vue
<template>
  <UIH2>Recent Activity</UIH2>
</template>
```

### Styling

- **Tag**: `<h2>`
- **Font Family**: Outfit
- **Font Weight**: 100 (thin)
- **Font Size**: text-2xl (1.5rem / 24px)
- **Classes**: `outfit font-thin text-2xl`

### Example

```vue
<script setup lang="ts">
import UIH2 from '~/components/UI/H2.vue'
import UIBox from '~/components/UI/Box.vue'
</script>

<template>
  <UIBox padding="p-6">
    <UIH2>Statistics</UIH2>
    <div class="mt-4 grid grid-cols-3 gap-4">
      <!-- Stats content -->
    </div>
  </UIBox>
</template>
```

---

## H3 Component

Subsection heading component with medium weight and standard size.

### Basic Usage

```vue
<template>
  <UIH3>Quick Actions</UIH3>
</template>
```

### Styling

- **Tag**: `<h3>`
- **Font Family**: Outfit
- **Font Weight**: 500 (medium)
- **Font Size**: text-md (1rem / 16px)
- **Classes**: `outfit font-medium text-md`

### Example

```vue
<script setup lang="ts">
import UIH3 from '~/components/UI/H3.vue'
</script>

<template>
  <div class="space-y-4">
    <UIH3>Team Members</UIH3>
    <ul>
      <li>John Doe</li>
      <li>Jane Smith</li>
    </ul>
  </div>
</template>
```

---

## Props

All typography components currently do not accept props. They have fixed styling.

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| - | - | - | No props currently defined |

---

## Slots

| Slot | Description |
|------|-------------|
| default | Main content slot for heading text |

---

## Typography Hierarchy Example

```vue
<script setup lang="ts">
import UITitle from '~/components/UI/Title.vue'
import UIH2 from '~/components/UI/H2.vue'
import UIH3 from '~/components/UI/H3.vue'
</script>

<template>
  <div>
    <!-- Main page title -->
    <UITitle>Everest Flow Platform</UITitle>

    <!-- Major section -->
    <UIH2>Getting Started</UIH2>
    <p>Welcome to the platform...</p>

    <!-- Subsection -->
    <UIH3>Setting Up Your Profile</UIH3>
    <p>Follow these steps...</p>

    <!-- Another subsection -->
    <UIH3>Inviting Team Members</UIH3>
    <p>You can invite colleagues...</p>

    <!-- Another major section -->
    <UIH2>Features</UIH2>

    <UIH3>Calendar Management</UIH3>
    <p>Organize your events...</p>

    <UIH3>Client Tracking</UIH3>
    <p>Keep track of leads...</p>
  </div>
</template>
```

## Accessibility

- **Semantic HTML**: Uses proper h1, h2, h3 heading tags
- **Heading Hierarchy**: Maintains logical document structure
- **Screen Readers**: Automatically announced as headings with proper level
- **Navigation**: Users can navigate by headings using screen reader shortcuts

### Best Practices for Accessibility

1. **Don't skip heading levels**: Go from h1 → h2 → h3, not h1 → h3
2. **Only one h1 per page**: Use UITitle once for the main page heading
3. **Logical structure**: Use headings to create a content outline
4. **Descriptive text**: Headings should describe the content that follows

## Customization

While these components have fixed styling, you can add additional classes:

```vue
<!-- Add custom colors -->
<UITitle class="text-blue-600">Custom Color Title</UITitle>

<!-- Add margin -->
<UIH2 class="mb-4">Section Heading</UIH2>

<!-- Center align -->
<UIH3 class="text-center">Centered Heading</UIH3>

<!-- Truncate long text -->
<UITitle class="truncate">Very Long Title That Might Overflow</UITitle>
```

## Font Weights Reference

The Outfit font family supports the following weights (available globally):

- **thin** (100) - Used in H2
- **light** (300)
- **normal** (400)
- **medium** (500) - Used in H3
- **semibold** (600)
- **bold** (700)
- **extrabold** (800)
- **black** (900) - Used in Title

## Complete Example: Dashboard Page

```vue
<script setup lang="ts">
import UITitle from '~/components/UI/Title.vue'
import UIH2 from '~/components/UI/H2.vue'
import UIH3 from '~/components/UI/H3.vue'
import UIBox from '~/components/UI/Box.vue'
</script>

<template>
  <div class="p-8">
    <!-- Main page title -->
    <UITitle>Dashboard</UITitle>
    <p class="mt-2 text-gray-600">Welcome back! Here's what's happening today.</p>

    <!-- Statistics section -->
    <div class="mt-8">
      <UIH2 class="mb-4">Today's Overview</UIH2>

      <div class="grid grid-cols-3 gap-4">
        <UIBox padding="p-6">
          <UIH3 class="mb-2">Active Events</UIH3>
          <p class="text-3xl font-bold">12</p>
        </UIBox>

        <UIBox padding="p-6">
          <UIH3 class="mb-2">New Clients</UIH3>
          <p class="text-3xl font-bold">5</p>
        </UIBox>

        <UIBox padding="p-6">
          <UIH3 class="mb-2">Pending Tasks</UIH3>
          <p class="text-3xl font-bold">8</p>
        </UIBox>
      </div>
    </div>

    <!-- Activity section -->
    <div class="mt-12">
      <UIH2 class="mb-4">Recent Activity</UIH2>

      <UIBox padding="p-6">
        <UIH3 class="mb-3">Latest Updates</UIH3>
        <ul class="space-y-2">
          <li class="flex items-center gap-2">
            <span class="w-2 h-2 bg-green-500 rounded-full"></span>
            <span>Client meeting scheduled</span>
          </li>
          <li class="flex items-center gap-2">
            <span class="w-2 h-2 bg-blue-500 rounded-full"></span>
            <span>New event created</span>
          </li>
        </ul>
      </UIBox>
    </div>
  </div>
</template>
```

## Best Practices

### When to Use

- **UITitle (H1)**: Main page heading (once per page)
- **UIH2**: Major section headings
- **UIH3**: Subsection headings within major sections

### Common Patterns

```vue
<!-- Page structure -->
<UITitle>Page Name</UITitle>
<UIH2>Section Name</UIH2>
<UIH3>Subsection Name</UIH3>

<!-- With spacing -->
<UITitle class="mb-6">Title</UITitle>
<UIH2 class="mb-4 mt-8">Section</UIH2>
<UIH3 class="mb-3 mt-6">Subsection</UIH3>

<!-- In cards -->
<UIBox padding="p-6">
  <UIH3 class="mb-4">Card Title</UIH3>
  <p>Card content</p>
</UIBox>
```

### Things to Avoid

- ✓ **Do**: Use heading levels in sequential order (h1 → h2 → h3)
- ✗ **Don't**: Skip heading levels (h1 → h3)
- ✓ **Do**: Use one h1 (UITitle) per page
- ✗ **Don't**: Use multiple h1 tags on the same page
- ✓ **Do**: Make headings descriptive of the content
- ✗ **Don't**: Use headings just for styling (use styled spans instead)
- ✓ **Do**: Maintain a logical document outline
- ✗ **Don't**: Use headings out of order for visual effect

## Future Enhancements

Planned improvements for typography components:

- **Size variants**: Allow customization of font sizes via props
- **Weight variants**: Allow different font weights
- **Color props**: Built-in color variants (primary, secondary, muted)
- **Utility props**: margin, truncate, align props
- **Additional heading levels**: H4, H5, H6 components
- **Text components**: Body text, caption, label components

## Related Components

- [Box](./Box.md) - Often used together with headings for card titles
- (Coming soon) Text component for body copy
- (Coming soon) Label component for form labels

## Component Files

Located at:
- `app/components/UI/Title.vue` (H1)
- `app/components/UI/H2.vue`
- `app/components/UI/H3.vue`

## Version History

### v1.0.0 (2025-10-20)
- Initial implementation of Title (H1), H2, and H3 components
- Outfit font styling with predefined weights and sizes
- Semantic HTML structure for accessibility
