# Component Catalog

Complete reference of all UI components in the Everest Flow library.

## Component Summary

| Component | File | Status | Description |
|-----------|------|--------|-------------|
| **Foundation** ||||
| Box | `UI/Box.vue` | ✅ Stable | Glassmorphic container with full customization |
| Button (Basic) | `UI/Button.vue` | ✅ Stable | Simple glassmorphic button |
| ButtonEnhanced | `UI/ButtonEnhanced.vue` | ✅ Stable | Full-featured button with 7 variants, sizes, loading states |
| Title (H1) | `UI/Title.vue` | ✅ Stable | Main page heading (Outfit, font-black, text-4xl) |
| H2 | `UI/H2.vue` | ✅ Stable | Section heading (Outfit, font-thin, text-2xl) |
| H3 | `UI/H3.vue` | ✅ Stable | Subsection heading (Outfit, font-medium, text-md) |
| **Forms** ||||
| Input | `UI/Input.vue` | ✅ Stable | Text input with label, error, prefix/suffix slots |
| Textarea | `UI/Textarea.vue` | ✅ Stable | Multi-line text input with character count |
| Select | `UI/Select.vue` | ✅ Stable | Dropdown select with object/string options |
| Checkbox | `UI/Checkbox.vue` | ✅ Stable | Checkbox input with label |
| Radio | `UI/Radio.vue` | ✅ Stable | Radio button input |
| Switch | `UI/Switch.vue` | ✅ Stable | Toggle switch |
| **Data Display** ||||
| Card | `UI/Card.vue` | ✅ Stable | Content card with header, body, footer slots |
| Badge | `UI/Badge.vue` | ✅ Stable | Status badge with 7 variants |
| Avatar | `UI/Avatar.vue` | ✅ Stable | User avatar with initials, image, status indicator |
| Tabs | `UI/Tabs.vue` | ✅ Stable | Tabbed navigation with 3 variants |
| **Feedback** ||||
| Alert | `UI/Alert.vue` | ✅ Stable | Alert messages with 4 variants (info, success, warning, danger) |
| Modal | `UI/Modal.vue` | ✅ Stable | Modal dialog with backdrop, sizes, glass variant |

## Quick Import Reference

### Foundation Components

```vue
<script setup lang="ts">
import UIBox from '~/components/UI/Box.vue'
import UIButton from '~/components/UI/Button.vue'
import UIButtonEnhanced from '~/components/UI/ButtonEnhanced.vue'
import UITitle from '~/components/UI/Title.vue'
import UIH2 from '~/components/UI/H2.vue'
import UIH3 from '~/components/UI/H3.vue'
</script>
```

### Form Components

```vue
<script setup lang="ts">
import UIInput from '~/components/UI/Input.vue'
import UITextarea from '~/components/UI/Textarea.vue'
import UISelect from '~/components/UI/Select.vue'
import UICheckbox from '~/components/UI/Checkbox.vue'
import UIRadio from '~/components/UI/Radio.vue'
import UISwitch from '~/components/UI/Switch.vue'
</script>
```

### Data Display Components

```vue
<script setup lang="ts">
import UICard from '~/components/UI/Card.vue'
import UIBadge from '~/components/UI/Badge.vue'
import UIAvatar from '~/components/UI/Avatar.vue'
import UITabs from '~/components/UI/Tabs.vue'
</script>
```

### Feedback Components

```vue
<script setup lang="ts">
import UIAlert from '~/components/UI/Alert.vue'
import UIModal from '~/components/UI/Modal.vue'
</script>
```

## Component Categories

### Foundation (6 components)

Essential building blocks for layout and typography.

- **Box** - Versatile glassmorphic container
- **Button** - Simple button (legacy)
- **ButtonEnhanced** - Full-featured button
- **Title** - H1 heading
- **H2** - Secondary heading
- **H3** - Tertiary heading

### Forms (6 components)

Form inputs and controls with validation support.

- **Input** - Text, email, password, number, etc.
- **Textarea** - Multi-line text input
- **Select** - Dropdown selection
- **Checkbox** - Checkbox input
- **Radio** - Radio button
- **Switch** - Toggle switch

### Data Display (4 components)

Components for displaying organized content.

- **Card** - Container with header/body/footer
- **Badge** - Status and label badges
- **Avatar** - User avatar with status
- **Tabs** - Tabbed content navigation

### Feedback (2 components)

User feedback and notification components.

- **Alert** - Inline alert messages
- **Modal** - Dialog overlays

## Feature Matrix

| Component | Variants | Sizes | States | Slots | Glass Style |
|-----------|----------|-------|--------|-------|-------------|
| Box | - | - | - | 1 | ✅ Default |
| Button | - | - | - | 1 | ✅ |
| ButtonEnhanced | 7 | 5 | loading, disabled | 2 | ✅ (variant) |
| Input | 2 | 3 | error, disabled, readonly | 3 | ✅ (variant) |
| Textarea | 2 | 3 | error, disabled, readonly | 0 | ✅ (variant) |
| Select | 2 | 3 | error, disabled | 0 | ✅ (variant) |
| Checkbox | - | 3 | disabled | 1 | - |
| Radio | - | 3 | disabled | 1 | - |
| Switch | - | 3 | disabled | 1 | - |
| Card | 4 | - | hoverable, clickable | 3 | ✅ (variant) |
| Badge | 7 | 4 | outline | 1 | - |
| Avatar | - | 6 | 4 status | 0 | - |
| Tabs | 3 | - | active | 1 | - |
| Alert | 4 | - | dismissible | 1 | - |
| Modal | - | 5 | closeable | 3 | ✅ (option) |

## Common Patterns

### Form with Validation

```vue
<script setup lang="ts">
import UIInput from '~/components/UI/Input.vue'
import UITextarea from '~/components/UI/Textarea.vue'
import UIButtonEnhanced from '~/components/UI/ButtonEnhanced.vue'

const form = ref({
  name: '',
  email: '',
  message: ''
})

const errors = ref({
  name: '',
  email: '',
  message: ''
})

const handleSubmit = () => {
  // Validation logic
}
</script>

<template>
  <form @submit.prevent="handleSubmit">
    <UIInput
      v-model="form.name"
      label="Name"
      :error="errors.name"
      required
    />

    <UIInput
      v-model="form.email"
      type="email"
      label="Email"
      :error="errors.email"
      required
    />

    <UITextarea
      v-model="form.message"
      label="Message"
      :error="errors.message"
      rows="4"
    />

    <UIButtonEnhanced type="submit" variant="primary" block>
      Submit
    </UIButtonEnhanced>
  </form>
</template>
```

### Dashboard Card

```vue
<script setup lang="ts">
import UICard from '~/components/UI/Card.vue'
import UIH3 from '~/components/UI/H3.vue'
import UIBadge from '~/components/UI/Badge.vue'
</script>

<template>
  <UICard variant="glass" hoverable>
    <template #header>
      <div class="flex items-center justify-between">
        <UIH3>Statistics</UIH3>
        <UIBadge variant="success">Live</UIBadge>
      </div>
    </template>

    <div class="space-y-4">
      <!-- Stats content -->
    </div>

    <template #footer>
      <a href="#" class="text-sm text-blue-500">View Details →</a>
    </template>
  </UICard>
</template>
```

### User Profile

```vue
<script setup lang="ts">
import UIAvatar from '~/components/UI/Avatar.vue'
import UIBadge from '~/components/UI/Badge.vue'
</script>

<template>
  <div class="flex items-center gap-3">
    <UIAvatar
      src="/avatar.jpg"
      name="John Doe"
      size="lg"
      status="online"
    />
    <div>
      <h4 class="outfit font-bold">John Doe</h4>
      <UIBadge variant="success" size="sm">Active</UIBadge>
    </div>
  </div>
</template>
```

### Modal Confirmation

```vue
<script setup lang="ts">
import UIModal from '~/components/UI/Modal.vue'
import UIButtonEnhanced from '~/components/UI/ButtonEnhanced.vue'
import UIAlert from '~/components/UI/Alert.vue'

const showModal = ref(false)

const handleConfirm = () => {
  // Confirmation logic
  showModal.value = false
}
</script>

<template>
  <UIButtonEnhanced @click="showModal = true">
    Delete Item
  </UIButtonEnhanced>

  <UIModal v-model="showModal" title="Confirm Deletion" size="sm">
    <UIAlert variant="danger" title="Warning">
      This action cannot be undone. Are you sure you want to delete this item?
    </UIAlert>

    <template #footer>
      <UIButtonEnhanced variant="ghost" @click="showModal = false">
        Cancel
      </UIButtonEnhanced>
      <UIButtonEnhanced variant="danger" @click="handleConfirm">
        Delete
      </UIButtonEnhanced>
    </template>
  </UIModal>
</template>
```

## Accessibility Summary

All components follow WCAG 2.1 AA standards:

- ✅ **Semantic HTML** - Proper element usage (button, input, etc.)
- ✅ **Keyboard Navigation** - Tab, Enter, Space, Escape support
- ✅ **ARIA Attributes** - Roles, labels, states
- ✅ **Focus Management** - Visible focus indicators
- ✅ **Screen Reader** - Proper announcements

## TypeScript Support

All components are built with TypeScript and export proper types:

```typescript
// Example: ButtonEnhanced types
type ButtonVariant = 'primary' | 'secondary' | 'outline' | 'ghost' | 'danger' | 'success' | 'glass'
type ButtonSize = 'xs' | 'sm' | 'md' | 'lg' | 'xl'

// Example: Input types
type InputType = 'text' | 'email' | 'password' | 'number' | 'tel' | 'url' | 'search'
type InputSize = 'sm' | 'md' | 'lg'

// Example: Avatar types
type AvatarSize = 'xs' | 'sm' | 'md' | 'lg' | 'xl' | '2xl'
type AvatarStatus = 'online' | 'offline' | 'away' | 'busy'
```

## Browser Support

- ✅ Chrome/Edge 90+
- ✅ Firefox 88+
- ✅ Safari 14+

## Performance Notes

- **Lazy Loading**: Use dynamic imports for large components
- **Glassmorphism**: Limit backdrop-blur usage (performance impact)
- **Teleport**: Modal uses Vue's Teleport for proper layering
- **Transitions**: CSS-based transitions for smooth animations

## Future Roadmap

### Planned Components

- [ ] Dropdown - Dropdown menu component
- [ ] Table - Data table with sorting/pagination
- [ ] Pagination - Pagination controls
- [ ] Breadcrumb - Navigation breadcrumbs
- [ ] Toast - Toast notification system
- [ ] Tooltip - Hover tooltips
- [ ] Skeleton - Loading skeletons
- [ ] Progress - Progress bars
- [ ] Slider - Range slider
- [ ] DatePicker - Date selection
- [ ] FileUpload - File upload component

### Planned Improvements

- [ ] Dark mode support for all components
- [ ] Animation presets
- [ ] Form validation composable
- [ ] Accessibility audit
- [ ] Performance optimization
- [ ] Storybook integration

## Need Help?

- **Documentation**: See individual component docs in `/DOCS/components/`
- **Guidelines**: Check `/DOCS/guidelines/` for standards
- **Examples**: Review `/DOCS/examples/` for full page examples
- **Issues**: Report bugs or request features

---

**Last Updated**: 2025-10-20
**Total Components**: 18
**Library Version**: 1.0.0
