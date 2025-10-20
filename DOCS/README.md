# Everest Flow UI Component Library Documentation

Welcome to the Everest Flow UI Component Library documentation. This library provides a comprehensive set of reusable, configurable, and accessible UI components built with Vue 3, TypeScript, and Tailwind CSS.

## Design Philosophy

Our UI components follow these core principles:

1. **Glassmorphism Design** - Semi-transparent backgrounds with backdrop blur effects
2. **Configurability** - All components accept props for customization
3. **Accessibility** - ARIA labels and keyboard navigation support
4. **TypeScript First** - Full type safety with proper interfaces
5. **Tailwind CSS** - Utility-first styling approach
6. **Consistent Typography** - Outfit font family throughout

## Quick Start

```vue
<script setup lang="ts">
import UIButtonEnhanced from '~/components/UI/ButtonEnhanced.vue'
</script>

<template>
  <UIButtonEnhanced variant="primary" size="md">
    Click Me
  </UIButtonEnhanced>
</template>
```

## Component Categories

**Total Components: 18** | [View Complete Catalog](./COMPONENT_CATALOG.md)

### Foundation Components (6)
- [Box](./components/Box.md) - Glassmorphic container component
- [Button](./components/Button.md) - Simple glass button (legacy)
- [ButtonEnhanced](./components/ButtonEnhanced.md) - Full-featured button with 7 variants and sizes
- [Typography](./components/Typography.md) - Headings (Title/H1, H2, H3) with Outfit font

### Form Components (6)
- [Input](./components/Input.md) - Text input with label, error states, prefix/suffix
- [Textarea](./components/Textarea.md) - Multi-line text input with character count
- [Select](./components/Select.md) - Dropdown select with object/string options
- [Checkbox](./components/Checkbox.md) - Checkbox input with label
- [Radio](./components/Radio.md) - Radio button with label
- [Switch](./components/Switch.md) - Toggle switch

### Data Display (4)
- [Card](./components/Card.md) - Content card with header, body, footer slots
- [Badge](./components/Badge.md) - Status badges with 7 variants
- [Avatar](./components/Avatar.md) - User avatar with initials, images, status indicators
- [Tabs](./components/Tabs.md) - Tabbed navigation with 3 variants

### Feedback (2)
- [Alert](./components/Alert.md) - Alert messages (info, success, warning, danger)
- [Modal](./components/Modal.md) - Modal dialog with backdrop and sizes

## Design Tokens

### Colors
- **Primary**: `#2050e3` (Blue)
- **Success**: `green-500`, `green-800`
- **Background**: `#e7eae9`
- **Accent**: `#FAE696` (Yellow)

### Typography
- **Font Family**: 'Outfit', sans-serif
- **Weights**: thin (100), normal (400), medium (500), bold (700), black (900)
- **Sizes**: xs, sm, md, 2xl, 4xl, 5xl

### Spacing
Follows Tailwind's standard scale: 0, 0.5, 1, 2, 3, 4, 5, 6, 8, 10, 12, 14, 16, 20, 24, etc.

### Glassmorphism Pattern
```css
backdrop-blur-md      /* Light blur */
backdrop-blur-xl      /* Medium blur */
backdrop-blur-2xl     /* Heavy blur */
bg-white/30           /* 30% white transparency */
bg-black/30           /* 30% black transparency */
border border-white   /* White border */
shadow-lg             /* Large shadow for depth */
```

## Documentation & Resources

- [**Component Catalog**](./COMPONENT_CATALOG.md) - Complete component reference with feature matrix
- [Documentation Standard](./guidelines/DOCUMENTATION_STANDARD.md) - How to write component documentation
- [Development Workflow](./guidelines/DEVELOPMENT_WORKFLOW.md) - How to update docs when developing
- [Component Template](./guidelines/COMPONENT_TEMPLATE.md) - Template for new components

## Quick Links

- **Browse by Category**: See component categories above
- **View All Components**: [Component Catalog](./COMPONENT_CATALOG.md)
- **Component Files**: Located in `app/components/UI/`
- **Documentation Files**: Located in `DOCS/components/`

## Contributing

When creating or updating components:

1. **Follow the existing patterns** - Use glassmorphism and Tailwind CSS
2. **Make it configurable** - Accept props for variants, sizes, and styles
3. **Write TypeScript** - Define proper interfaces for props
4. **Document thoroughly** - Update this documentation immediately
5. **Test accessibility** - Ensure keyboard navigation and screen reader support

## Browser Support

- Chrome/Edge (latest)
- Firefox (latest)
- Safari (latest)

## License

Internal use only - Everest Flow Project
