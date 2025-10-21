# Development Workflow

This document outlines the workflow for developing UI components and maintaining documentation in the Everest Flow project.

## The Golden Rule

**ALWAYS UPDATE DOCUMENTATION WHEN YOU CHANGE CODE**

Every component change must be accompanied by a documentation update in the same commit. No exceptions.

## Component Development Workflow

### 1. Planning Phase

Before creating a new component:

- [ ] Check if a similar component already exists
- [ ] Review the [Component Template](./COMPONENT_TEMPLATE.md)
- [ ] Plan the props and variants you'll need
- [ ] Sketch out the API (what props, events, slots)

### 2. Component Creation

```bash
# Create component file
touch app/components/UI/[ComponentName].vue

# Create documentation file
touch DOCS/components/[ComponentName].md
```

### 3. Implementation

1. **Set up the component structure**:
   ```vue
   <script setup lang="ts">
   // Define props interface
   interface Props {
     variant?: 'primary' | 'secondary'
     size?: 'sm' | 'md' | 'lg'
   }

   // Define props with defaults
   const props = withDefaults(defineProps<Props>(), {
     variant: 'primary',
     size: 'md'
   })

   // Define emits
   const emit = defineEmits<{
     click: [event: MouseEvent]
   }>()
   </script>

   <template>
     <div :class="computedClasses">
       <slot />
     </div>
   </template>
   ```

2. **Follow design patterns**:
   - Use glassmorphism styling (`backdrop-blur-xl`, `bg-white/30`)
   - Use Tailwind CSS utility classes
   - Make it configurable with props
   - Use Outfit font family
   - Follow existing component patterns

3. **Add TypeScript types**:
   - Define proper interfaces
   - Use union types for variants
   - Export types if needed by other components

4. **Implement accessibility**:
   - Add ARIA labels where appropriate
   - Support keyboard navigation
   - Ensure proper focus management
   - Test with screen readers

### 4. Documentation (CRITICAL STEP)

As soon as your component is functional, write documentation:

1. **Copy the template**: Start from [COMPONENT_TEMPLATE.md](./COMPONENT_TEMPLATE.md)
2. **Fill in all sections**: Don't leave any sections empty
3. **Add real examples**: Use realistic use cases
4. **Document all props**: Include types and defaults
5. **Show all variants**: Visual examples of each variant
6. **Add accessibility notes**: Document ARIA and keyboard support

### 5. Testing

Test your component:

- [ ] Works with all prop combinations
- [ ] Responsive on different screen sizes
- [ ] Keyboard navigation works
- [ ] Screen reader announces correctly
- [ ] Follows glassmorphism design
- [ ] Looks good in light/dark mode

### 6. Integration

Add your component to the main documentation index:

```markdown
# In DOCS/README.md

### [Category Name]
- [ComponentName](./components/ComponentName.md) - Brief description
```

### 7. Commit

Commit both the component and documentation together:

```bash
git add app/components/UI/[ComponentName].vue
git add DOCS/components/[ComponentName].md
git add DOCS/README.md
git commit -m "feat: add [ComponentName] component with documentation"
```

## Updating Existing Components

### When to Update Docs

Update documentation whenever you:
- Add a new prop
- Add a new variant
- Change default behavior
- Add or modify events
- Add or modify slots
- Fix a bug that affects usage
- Change accessibility features

### Update Workflow

1. **Make code changes** in `app/components/UI/[ComponentName].vue`

2. **Update documentation** in `DOCS/components/[ComponentName].md`:
   - Update Props table
   - Add new examples
   - Update Best Practices
   - Add to Version History (if significant)

3. **Test changes**:
   - Verify examples still work
   - Check that descriptions are accurate
   - Ensure links aren't broken

4. **Commit together**:
   ```bash
   git add app/components/UI/[ComponentName].vue
   git add DOCS/components/[ComponentName].md
   git commit -m "feat: add [feature] to [ComponentName] component"
   ```

## Documentation Review Checklist

Before committing, verify:

- [ ] All props are documented with types and defaults
- [ ] All variants have visual examples
- [ ] Events are documented with payload types
- [ ] Slots are documented
- [ ] Accessibility information is complete
- [ ] At least 2-3 realistic examples are provided
- [ ] Related components are linked
- [ ] Best practices section has useful tips
- [ ] Code examples are valid and tested
- [ ] The component is added to main README.md

## Refactoring Workflow

When refactoring components:

1. **Document the old behavior** first (if not already documented)
2. **Make your changes**
3. **Update documentation** to reflect new behavior
4. **Add migration notes** if the API changed
5. **Update all examples** that might be affected

Example migration note:

```markdown
## Migration from v1.0

The `type` prop has been renamed to `variant` for consistency.

**Before:**
\`\`\`vue
<UIButton type="primary">Click</UIButton>
\`\`\`

**After:**
\`\`\`vue
<UIButton variant="primary">Click</UIButton>
\`\`\`
```

## Common Mistakes to Avoid

1. **Don't commit code without docs**: Always update docs in the same commit
2. **Don't use vague descriptions**: Be specific about what props do
3. **Don't skip examples**: Examples are crucial for understanding
4. **Don't forget accessibility**: Always document ARIA and keyboard support
5. **Don't leave broken links**: Check that component links work
6. **Don't copy without updating**: When using templates, fill in all sections

## Tips for Good Documentation

1. **Think like a user**: What would someone need to know to use this?
2. **Show, don't just tell**: Examples are better than descriptions
3. **Be consistent**: Follow the same format as other docs
4. **Update regularly**: Don't let docs fall out of sync
5. **Link everything**: Connect related components and concepts

## File Organization

```
/app/components/UI/
  ├── Button.vue           # Component implementation
  ├── Input.vue
  └── [Other components]

/DOCS/
  ├── README.md            # Main documentation index
  ├── components/
  │   ├── Button.md        # Component documentation
  │   ├── Input.md
  │   └── [Other docs]
  ├── guidelines/
  │   ├── DOCUMENTATION_STANDARD.md
  │   ├── DEVELOPMENT_WORKFLOW.md  # This file
  │   └── COMPONENT_TEMPLATE.md
  └── examples/
      └── [Full page examples]
```

## Quick Reference

### New Component
```bash
# 1. Create component
touch app/components/UI/[Name].vue

# 2. Create docs
touch DOCS/components/[Name].md

# 3. Implement component (with TypeScript)

# 4. Write documentation (use template)

# 5. Add to DOCS/README.md

# 6. Commit together
git add app/components/UI/[Name].vue DOCS/components/[Name].md DOCS/README.md
git commit -m "feat: add [Name] component"
```

### Update Component
```bash
# 1. Modify component

# 2. Update docs

# 3. Test

# 4. Commit together
git add app/components/UI/[Name].vue DOCS/components/[Name].md
git commit -m "feat: update [Name] component"
```

## Questions or Issues?

If you're unsure about the workflow:
1. Review this document
2. Look at existing component examples
3. Ask the team for guidance

---

**Remember**: Documentation is not optional. It's a critical part of every component!
