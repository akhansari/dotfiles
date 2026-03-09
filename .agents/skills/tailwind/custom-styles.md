# Custom Styles

## Arbitrary values

Use `[value]` notation to generate a one-off utility on the fly:

```html
<div class="top-[117px] bg-[#bada55] text-[22px]">...</div>
<!-- Works with modifiers too: -->
<div class="top-[117px] lg:top-[344px]">...</div>
```

### CSS variable shorthand

`fill-(--my-var)` is shorthand for `fill-[var(--my-var)]`:

```html
<div class="fill-(--brand-color) bg-(--surface-color)">...</div>
```

### Arbitrary properties

Any CSS property not covered by Tailwind:

```html
<div class="[mask-type:luminance] hover:[mask-type:alpha]">...</div>
<!-- CSS variables: -->
<div class="[--scroll-offset:56px] lg:[--scroll-offset:44px]">...</div>
```

### Handling whitespace

Use `_` in arbitrary values — Tailwind converts to spaces at build time:

```html
<div class="grid grid-cols-[1fr_500px_2fr]">...</div>
<!-- Exception: underscores in URLs are preserved -->
<div class="bg-[url('/what_a_rush.png')]">...</div>
<!-- Escape a literal underscore: -->
<div class="before:content-['hello\_world']">...</div>
```

### Resolving ambiguities

When a namespace could map to multiple CSS properties, Tailwind infers from the value:

```html
<!-- Inferred as font-size (length value) -->
<div class="text-[22px]">...</div>
<!-- Inferred as color (color value) -->
<div class="text-[#bada55]">...</div>
```

For CSS variables, hint the type explicitly:

```html
<div class="text-(length:--my-var)">...</div>
<!-- font-size -->
<div class="text-(color:--my-var)">...</div>
<!-- color -->
```

## @layer base

Global element defaults. Prefer adding classes directly to `html`/`body` for simple cases:

```html
<html class="bg-gray-100 font-serif text-gray-900"></html>
```

For element-level defaults:

```css
@layer base {
  h1 {
    font-size: var(--text-2xl);
  }
  h2 {
    font-size: var(--text-xl);
  }
}
```

## @layer components

Reusable component classes — useful when class reuse is impractical and component abstraction is overkill. Utility classes can still override them.

```css
@layer components {
  .card {
    background-color: var(--color-white);
    border-radius: var(--radius-lg);
    padding: --spacing(6);
    box-shadow: var(--shadow-xl);
  }
}
```

```html
<!-- Utility overrides the component class -->
<div class="card rounded-none">...</div>
```

Also use `@layer components` for third-party library style overrides.

## @utility

Add custom utilities that work with all variants (`hover:`, `lg:`, etc.):

### Simple

```css
@utility content-auto {
  content-visibility: auto;
}
```

```html
<div class="hover:content-auto">...</div>
```

### Complex (with nesting)

```css
@utility scrollbar-hidden {
  &::-webkit-scrollbar {
    display: none;
  }
}
```

### Functional (with `--value()`)

```css
@theme {
  --tab-size-2: 2;
  --tab-size-4: 4;
  --tab-size-github: 8;
}

@utility tab-* {
  /* Match theme values: tab-2, tab-4, tab-github */
  tab-size: --value(--tab-size-*);
  /* Match bare integers: tab-1, tab-76 */
  tab-size: --value(integer);
  /* Match arbitrary: tab-[3] */
  tab-size: --value([integer]);
}
```

Multiple `--value()` lines in one rule: declarations that fail to resolve are omitted. Or chain in one call:

```css
@utility tab-* {
  tab-size: --value(--tab-size-*, integer, [integer]);
}
```

### --value() bare value types

`number`, `integer`, `ratio`, `percentage`

### --value() arbitrary value types

`absolute-size`, `angle`, `bg-size`, `color`, `family-name`, `generic-name`, `image`, `integer`, `length`, `line-width`, `number`, `percentage`, `position`, `ratio`, `relative-size`, `url`, `vector`, `*`

### Literal values

```css
@utility tab-* {
  tab-size: --value("inherit", "initial", "unset");
}
/* Matches tab-inherit, tab-initial, tab-unset */
```

### Negative values

Register positive and negative utilities separately:

```css
@utility inset-* {
  inset: --spacing(--value(integer));
  inset: --value([percentage], [length]);
}
@utility -inset-* {
  inset: --spacing(--value(integer) * -1);
  inset: calc(--value([percentage], [length]) * -1);
}
```

### Modifiers with --modifier()

```css
@utility text-* {
  font-size: --value(--text-*, [length]);
  line-height: --modifier(--leading-*, [length], [*]);
}
/* Usage: text-xl/tight, text-xl/[1.4] */
```

### Fractions with ratio type

```css
@utility aspect-* {
  aspect-ratio: --value(--aspect-ratio-*, ratio, [ratio]);
}
/* Matches: aspect-square, aspect-3/4, aspect-[7/9] */
```

## @variant

Apply a Tailwind variant inside custom CSS:

```css
.my-element {
  background: white;
  @variant dark {
    background: black;
  }
}
/* Compiles to: @media (prefers-color-scheme: dark) { .my-element { background: black; } } */
```

Stack multiple variants with nesting:

```css
.my-element {
  @variant dark {
    @variant hover {
      background: black;
    }
  }
}
```

## @custom-variant

Define custom variants:

```css
/* Shorthand (no nesting needed): */
@custom-variant theme-midnight (&:where([data-theme="midnight"] *));

/* With nesting (multiple rules): */
@custom-variant any-hover {
  @media (any-hover: hover) {
    &:hover {
      @slot;
    }
  }
}
```

```html
<html data-theme="midnight">
  <button class="theme-midnight:bg-black">...</button>
</html>
```

## @reference

Use in Svelte/Vue `<style>` blocks to access `@apply` and `@variant` without duplicating CSS output:

```svelte
<style>
  @reference "../../app.css";

  h1 {
    @apply text-2xl font-bold text-red-500;
  }
</style>
```

If using default theme with no customizations:

```svelte
<style>
  @reference "tailwindcss";

  h1 {
    @apply text-2xl font-bold;
  }
</style>
```

## @apply (last resort)

Available but use only when component abstraction is impractical — for example, overriding third-party library styles:

```css
.select2-dropdown {
  @apply rounded-b-lg shadow-md;
}
```

## --alpha() function

Adjust opacity of a color:

```css
.my-element {
  color: --alpha(var(--color-lime-300) / 50%);
}
/* Compiles to: color: color-mix(in oklab, var(--color-lime-300) 50%, transparent); */
```

## --spacing() function

Generate spacing values (also usable in arbitrary values):

```css
.my-element {
  margin: --spacing(4);
  /* compiles to: margin: calc(var(--spacing) * 4); */
}
```

```html
<div class="py-[calc(--spacing(4)-1px)]">...</div>
```
