# Styling

Svelte provides scoped CSS out of the box, with tools for global escapes, dynamic classes, inline styles, and CSS custom property passing.

## Scoped Styles

CSS inside a `<style>` block is automatically scoped to the component. Svelte adds a unique attribute (e.g., `svelte-xyz`) to elements and rewrites selectors to match only elements in the current component.

```svelte
<p>This paragraph has red text.</p>

<style>
  p {
    /* Only affects <p> elements in THIS component */
    color: red;
  }
</style>
```

Scoping applies to all descendant elements that the component renders directly. Child component root elements are **not** scoped by the parent's styles (use `:global` to reach them if necessary).

---

## :global()

Escapes scoping to write styles that apply globally or to child component internals.

```svelte
<style>
  /* Applies globally to ALL <p> elements */
  :global(p) {
    color: red;
  }

  /* Scoped wrapper, but globally reaching .content inside any child */
  .wrapper :global(.content) {
    font-size: 1.2rem;
  }

  /* Global keyframe */
  @keyframes :global(spin) {
    from { transform: rotate(0deg); }
    to   { transform: rotate(360deg); }
  }
</style>
```

---

## Nested \<style\> Elements

You can add `<style>` blocks inside markup using `<svelte:element>` or directly. They are not processed by Svelte — they are passed through as-is to the DOM.

```svelte
<svelte:head>
  <style>
    body { margin: 0; }
  </style>
</svelte:head>
```

---

## class Directive

Dynamically applies or removes a class based on a condition.

```svelte
<!-- Longhand -->
<button class={isActive ? 'active' : ''}>Toggle</button>

<!-- Shorthand directive (class name matches variable name) -->
<div class:active={isActive}>Content</div>

<!-- Multiple classes -->
<div class:active={isActive} class:error={hasError}>Content</div>

<!-- Shorthand when variable and class name match -->
<div class:active>Content</div>
```

### class with Expressions

```svelte
<!-- Template literal for dynamic class strings -->
<div class="base {isActive ? 'active' : ''} {size}">...</div>

<!-- Object map (Svelte-style) -->
<div class={{ active: isActive, large: size === 'lg', 'text-red': hasError }}>...</div>
```

---

## style: Directive

Applies inline styles dynamically. More ergonomic than string interpolation.

```svelte
<div style:color="red">...</div>
<div style:font-size="{size}px">...</div>
<div style:background-color={primaryColor}>...</div>

<!-- Shorthand when variable and property match -->
<div style:color>...</div>
<!-- equivalent to: <div style:color={color}>...</div> -->

<!-- Important modifier -->
<div style:color|important="red">...</div>
```

Multiple `style:` directives can be combined with a `style` attribute:

```svelte
<div style="font-weight: bold;" style:color="red">...</div>
```

---

## CSS Custom Properties

Pass CSS custom properties to child components for theming without exposing implementation details.

```svelte
<!-- Parent passes custom properties to Child -->
<Component --primary-color="#ff3e00" --font-size="1.2rem" />
```

```svelte
<!-- Component.svelte uses the custom properties -->
<style>
  .wrapper {
    color: var(--primary-color, #333);
    font-size: var(--font-size, 1rem);
  }
</style>

<div class="wrapper">content</div>
```

Svelte wraps the component in a `<div style="...">` with the custom properties when this syntax is used. Only use this when the component has a single root element or uses `<svelte:options css="injected">`.

---

## Combining Classes

Recommended patterns for combining static, conditional, and dynamic classes:

```svelte
<!-- Static + conditional -->
<button class="btn {variant}" class:active={isActive} class:disabled={!enabled}>
  Click
</button>

<!-- With a helper (e.g., clsx/classnames) -->
<script lang="ts">
  import clsx from 'clsx';
  let className = clsx('btn', variant, { active: isActive, disabled: !enabled });
</script>
<button class={className}>Click</button>
```

---

## Unused CSS Warning

Svelte warns about CSS selectors that don't match any elements in the component. Use `/* svelte-ignore css_unused_selector */` to suppress:

```svelte
<style>
  /* svelte-ignore css_unused_selector */
  .dynamic-class {
    color: red;
  }
</style>
```
