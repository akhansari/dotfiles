# Responsive Design

## Mobile-first

Unprefixed utilities apply at **all sizes**. Prefixed variants (`sm:`, `md:`, …) apply at that breakpoint **and above**.

```html
<!-- Wrong: sm: does NOT mean "small screens only" -->
<div class="sm:text-center"></div>

<!-- Correct: unprefixed = mobile, prefixed = override at breakpoint+ -->
<div class="text-center sm:text-left"></div>
```

## Default breakpoints

| Variant | Min width      | CSS                       |
| ------- | -------------- | ------------------------- |
| `sm`    | 40rem (640px)  | `@media (width >= 40rem)` |
| `md`    | 48rem (768px)  | `@media (width >= 48rem)` |
| `lg`    | 64rem (1024px) | `@media (width >= 64rem)` |
| `xl`    | 80rem (1280px) | `@media (width >= 80rem)` |
| `2xl`   | 96rem (1536px) | `@media (width >= 96rem)` |

```html
<img class="w-16 md:w-32 lg:w-48" src="..." />
```

## max-\* variants (upper bounds)

| Variant   | CSS                      |
| --------- | ------------------------ |
| `max-sm`  | `@media (width < 40rem)` |
| `max-md`  | `@media (width < 48rem)` |
| `max-lg`  | `@media (width < 64rem)` |
| `max-xl`  | `@media (width < 80rem)` |
| `max-2xl` | `@media (width < 96rem)` |

### Targeting a range

Stack a `min` + `max-*` variant to target a specific range:

```html
<!-- Only active between md and xl -->
<div class="md:max-xl:flex">...</div>

<!-- Only at md (between md and lg) -->
<div class="md:max-lg:flex">...</div>
```

## Custom breakpoints

Define in `@theme` using `--breakpoint-*`. Always use the **same unit** (rem) to avoid ordering issues:

```css
@import "tailwindcss";
@theme {
  --breakpoint-xs: 30rem;
  --breakpoint-2xl: 100rem; /* overrides default 96rem */
  --breakpoint-3xl: 120rem;
}
```

```html
<div class="grid xs:grid-cols-2 3xl:grid-cols-6">...</div>
```

### Removing a breakpoint

```css
@theme {
  --breakpoint-2xl: initial;
}
```

### Replacing all breakpoints

```css
@theme {
  --breakpoint-*: initial;
  --breakpoint-tablet: 40rem;
  --breakpoint-laptop: 64rem;
  --breakpoint-desktop: 80rem;
}
```

## Arbitrary breakpoints

One-off values without adding to theme:

```html
<div class="min-[320px]:text-center max-[600px]:bg-sky-300">...</div>
```

## Container queries

Style based on a **parent element's width** instead of the viewport.

### Basic usage

Mark a parent with `@container`, then use `@sm`, `@md`, etc. on children:

```html
<div class="@container">
  <div class="flex flex-col @md:flex-row">...</div>
</div>
```

Container queries are also **mobile-first** — variants apply at the container size and above.

### Max-width container queries

```html
<div class="@container">
  <div class="flex flex-row @max-md:flex-col">...</div>
</div>
```

### Container query ranges

```html
<div class="@container">
  <div class="@sm:@max-md:flex-col">...</div>
</div>
```

### Named containers

For nested containers, name them to target a specific one:

```html
<div class="@container/main">
  <div class="flex flex-row @sm/main:flex-col">...</div>
</div>
```

### Custom container sizes

```css
@theme {
  --container-8xl: 96rem;
}
```

```html
<div class="@container">
  <div class="flex flex-col @8xl:flex-row">...</div>
</div>
```

### Arbitrary container query values

```html
<div class="@container">
  <div class="@min-[475px]:flex-row @max-[960px]:flex-col">...</div>
</div>
```

### Container query units

Use `cqw` as an arbitrary value to reference the container size:

```html
<div class="@container">
  <div class="w-[50cqw]">...</div>
</div>
```

## Default container sizes reference

| Variant | Min width      |
| ------- | -------------- |
| `@3xs`  | 16rem (256px)  |
| `@2xs`  | 18rem (288px)  |
| `@xs`   | 20rem (320px)  |
| `@sm`   | 24rem (384px)  |
| `@md`   | 28rem (448px)  |
| `@lg`   | 32rem (512px)  |
| `@xl`   | 36rem (576px)  |
| `@2xl`  | 42rem (672px)  |
| `@3xl`  | 48rem (768px)  |
| `@4xl`  | 56rem (896px)  |
| `@5xl`  | 64rem (1024px) |
| `@6xl`  | 72rem (1152px) |
| `@7xl`  | 80rem (1280px) |
