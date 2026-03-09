# Theme Variables

## What are theme variables?

Theme variables are CSS variables defined via `@theme` that **generate utility classes**. Defining `--color-mint-500` creates `bg-mint-500`, `text-mint-500`, `fill-mint-500`, etc.

```css
@import "tailwindcss";
@theme {
  --color-mint-500: oklch(0.72 0.11 178);
}
```

```html
<div class="bg-mint-500">...</div>
<!-- or in inline styles: -->
<div style="background-color: var(--color-mint-500)">...</div>
```

## @theme vs :root

| Use      | When                                                  |
| -------- | ----------------------------------------------------- |
| `@theme` | Value should generate a utility class                 |
| `:root`  | CSS variable that should NOT generate a utility class |

`@theme` variables must be **top-level** (not nested under selectors or media queries).

## Theme variable namespaces

| Namespace          | Utility classes generated                                                      |
| ------------------ | ------------------------------------------------------------------------------ |
| `--color-*`        | `bg-*`, `text-*`, `border-*`, `fill-*`, `stroke-*`, `ring-*`, `shadow-*`, etc. |
| `--font-*`         | `font-*` (font-family)                                                         |
| `--text-*`         | `text-*` (font-size)                                                           |
| `--font-weight-*`  | `font-*` (font-weight)                                                         |
| `--tracking-*`     | `tracking-*` (letter-spacing)                                                  |
| `--leading-*`      | `leading-*` (line-height)                                                      |
| `--breakpoint-*`   | Responsive variants `sm:*`, `md:*`, etc.                                       |
| `--container-*`    | Container query variants `@sm:*`, `@md:*`, etc. and `max-w-*`                  |
| `--spacing-*`      | `p-*`, `m-*`, `w-*`, `h-*`, `gap-*`, `inset-*`, and many more                  |
| `--radius-*`       | `rounded-*`                                                                    |
| `--shadow-*`       | `shadow-*`                                                                     |
| `--inset-shadow-*` | `inset-shadow-*`                                                               |
| `--drop-shadow-*`  | `drop-shadow-*`                                                                |
| `--blur-*`         | `blur-*`                                                                       |
| `--perspective-*`  | `perspective-*`                                                                |
| `--aspect-*`       | `aspect-*`                                                                     |
| `--ease-*`         | `ease-*`                                                                       |
| `--animate-*`      | `animate-*`                                                                    |

## Extending the default theme

Add new values — existing defaults remain:

```css
@theme {
  --font-poppins: Poppins, sans-serif;
  --color-brand: oklch(0.72 0.11 178);
  --breakpoint-3xl: 120rem;
}
```

```html
<h1 class="font-poppins text-brand">...</h1>
```

## Overriding a default value

Redefine the same variable:

```css
@theme {
  --breakpoint-sm: 30rem; /* was 40rem */
}
```

## Replacing an entire namespace

Set namespace to `initial`, then define new values — all defaults in that namespace are removed:

```css
@theme {
  --color-*: initial;
  --color-white: #fff;
  --color-midnight: #121063;
  --color-tahiti: #3ab7bf;
}
```

## Full custom theme (disable all defaults)

```css
@theme {
  --*: initial;
  --spacing: 4px;
  --font-body: Inter, sans-serif;
  --color-lagoon: oklch(0.72 0.11 221.19);
  --color-coral: oklch(0.74 0.17 40.24);
}
```

## Keyframes inside @theme

Define `@keyframes` inside `@theme` for `--animate-*` variables:

```css
@theme {
  --animate-fade-in-scale: fade-in-scale 0.3s ease-out;

  @keyframes fade-in-scale {
    0% {
      opacity: 0;
      transform: scale(0.95);
    }
    100% {
      opacity: 1;
      transform: scale(1);
    }
  }
}
```

If you want keyframes to always be included regardless of `--animate-*` variables, define them outside `@theme`.

## @theme inline

Use when a theme variable references another CSS variable. Prevents unexpected fallback resolution:

```css
@theme inline {
  --font-sans: var(--font-inter);
}
```

Without `inline`, `var(--font-inter)` resolves where `--font-sans` is defined, not where `--font-inter` is defined — which can produce wrong values in deeply nested DOM trees.

**Result:**

```css
/* With inline: */
.font-sans {
  font-family: var(--font-inter);
}

/* Without inline: */
.font-sans {
  font-family: var(--font-sans);
}
/* which resolves at :root, potentially missing --font-inter defined deeper */
```

## @theme static

Always generate all CSS variables even if not used in HTML:

```css
@theme static {
  --color-primary: var(--color-red-500);
  --color-secondary: var(--color-blue-500);
}
```

## Sharing across projects

Put theme variables in a shared CSS file and `@import` it:

```css
/* packages/brand/theme.css */
@theme {
  --*: initial;
  --color-brand: oklch(0.72 0.11 178);
}
```

```css
/* app.css */
@import "tailwindcss";
@import "../brand/theme.css";
```

## Using theme variables in custom CSS

All `@theme` variables compile to regular CSS variables on `:root`:

```css
@layer components {
  .typography {
    p {
      font-size: var(--text-base);
      color: var(--color-gray-700);
    }
    h1 {
      font-size: var(--text-2xl);
      font-weight: var(--font-weight-semibold);
    }
  }
}
```

In arbitrary values:

```html
<div class="rounded-[calc(var(--radius-xl)-1px)]">...</div>
```

## Referencing in JavaScript

```js
let styles = getComputedStyle(document.documentElement);
let shadow = styles.getPropertyValue("--shadow-xl");
```

Or use CSS variables directly in animation libraries:

```jsx
<motion.div animate={{ backgroundColor: "var(--color-blue-500)" }} />
```

## --spacing() function

Generate a spacing value from the theme scale:

```css
.my-element {
  margin: --spacing(4);
  /* compiles to: margin: calc(var(--spacing) * 4); */
}
```

Also usable in arbitrary values:

```html
<div class="py-[calc(--spacing(4)-1px)]">...</div>
```

## Default theme values (key values)

```
--spacing: 0.25rem           (base spacing unit, multiply by n)
--breakpoint-sm: 40rem
--breakpoint-md: 48rem
--breakpoint-lg: 64rem
--breakpoint-xl: 80rem
--breakpoint-2xl: 96rem
--font-sans: ui-sans-serif, system-ui, sans-serif, …
--font-serif: ui-serif, Georgia, Cambria, …
--font-mono: ui-monospace, SFMono-Regular, Menlo, …
--text-xs: 0.75rem    --text-sm: 0.875rem   --text-base: 1rem
--text-lg: 1.125rem   --text-xl: 1.25rem    --text-2xl: 1.5rem
--text-3xl: 1.875rem  --text-4xl: 2.25rem   --text-5xl: 3rem
--radius-xs: 0.125rem  --radius-sm: 0.25rem  --radius-md: 0.375rem
--radius-lg: 0.5rem    --radius-xl: 0.75rem  --radius-2xl: 1rem
--shadow-xs / --shadow-sm / --shadow-md / --shadow-lg / --shadow-xl / --shadow-2xl
--animate-spin / --animate-ping / --animate-pulse / --animate-bounce
```
