---
name: tailwind-css
description: Enforce Tailwind CSS best practices and conventions
---

# Tailwind CSS v4 Best Practices

## Rules

- **No `@apply` by default.** Use component abstractions first. Reserve `@apply` for overriding third-party library styles or when component extraction is truly impractical.
- **CSS-first config.** There is no `tailwind.config.js` in v4. All configuration is done in CSS via `@theme`, `@custom-variant`, `@utility`, and `@plugin`.
- **Use `@theme` for design tokens.** When a value should generate a utility class, define it in `@theme`. Use `:root` only for CSS variables that should NOT generate utility classes.
- **Use CSS variables directly.** Reference theme tokens with `var(--color-gray-700)` in custom CSS, not the deprecated `theme()` function.
- **`@theme inline` when referencing other CSS vars.** Prevents unexpected variable resolution fallbacks.
- **Use `@reference` in Svelte/Vue `<style>` blocks.** Import the main stylesheet for reference to use `@apply` or `@variant` without duplicating CSS output.
- **Mobile-first.** Unprefixed utilities apply at all sizes. Use `sm:`, `md:`, `lg:` etc. for larger breakpoints.
- **Stack variants freely.** `dark:md:hover:bg-indigo-600` — any combination is valid.

## Topic Files

- [core-concepts.md](./core-concepts.md) — Variants, pseudo-classes, pseudo-elements, media queries, attribute selectors, child selectors, stacking
- [responsive.md](./responsive.md) — Breakpoints, mobile-first, `max-*` ranges, custom breakpoints, container queries
- [theme.md](./theme.md) — `@theme` directive, namespaces, extending/overriding/replacing, `@theme inline`, `--spacing()`
- [custom-styles.md](./custom-styles.md) — Arbitrary values/properties, `@layer`, `@utility`, `@custom-variant`, `@variant`, `@reference`, `--alpha()`
- [layout.md](./layout.md) — Display, position, overflow, z-index, float, box-sizing, aspect-ratio, columns, object-fit/position, visibility, `sr-only`, container
- [flexbox-grid.md](./flexbox-grid.md) — Flex direction/wrap/grow/shrink/basis/order, grid template cols/rows, col/row span/start/end, auto flow, gap, justify/align/place utilities
- [spacing.md](./spacing.md) — Padding (`p/px/py/ps/pe/pbs/pbe/pt/pr/pb/pl`), margin (all axes), negative margins, `space-x/y` utilities
- [sizing.md](./sizing.md) — Width (numeric, fractions, container scale `w-3xs`…`w-7xl`, viewport), `size-*` (w+h), height, min/max-w/h
- [typography.md](./typography.md) — Font family/size/weight/style/smoothing, `text-<size>/<lh>` shorthand, tracking, leading, line-clamp, text alignment/color/decoration/transform/overflow/wrap/indent, whitespace, word-break, vertical-align
- [backgrounds.md](./backgrounds.md) — Background color (opacity modifier), gradients (`bg-linear-to-*`, from/via/to), bg-clip (incl. gradient text), bg-size, bg-position, bg-repeat, bg-attachment, bg-origin
- [borders.md](./borders.md) — Border radius (all sizes + per-side/corner/logical), border width/color/style, divide-x/y, outline, ring & inset-ring
- [effects.md](./effects.md) — Box shadow (`shadow-2xs`…`shadow-2xl`, `inset-shadow-*`, shadow color), text-shadow, opacity, mix-blend-mode, mask
- [filters.md](./filters.md) — `blur-xs`…`blur-3xl`, brightness, contrast, drop-shadow, grayscale, hue-rotate, invert, saturate, sepia + full `backdrop-*` equivalents
- [tables.md](./tables.md) — `border-collapse`/`border-separate`, `border-spacing-*`, `table-auto`/`table-fixed`, `caption-top`/`caption-bottom`, striped rows
- [transitions-animation.md](./transitions-animation.md) — Transition properties, duration, easing, delay, `transition-discrete`, built-in animations (spin/ping/pulse/bounce), custom keyframes, `motion-safe:`/`motion-reduce:`
- [transforms.md](./transforms.md) — Scale/rotate/translate (native CSS properties in v4), skew, transform-origin, transform-style, perspective, backface-visibility
- [interactivity.md](./interactivity.md) — Cursor (full list), pointer-events, user-select, resize, scroll behavior/snap, scroll margin/padding, touch-action, will-change, appearance, accent, caret, color-scheme, field-sizing
