# Filters

All filter utilities use CSS `filter` property. Backdrop variants use `backdrop-filter`.

## Blur

Uses `--blur-*` CSS vars.

| Class       | Value                      |
| ----------- | -------------------------- |
| `blur-none` | `0`                        |
| `blur-xs`   | `var(--blur-xs)` = `2px`   |
| `blur-sm`   | `var(--blur-sm)` = `4px`   |
| `blur`      | `var(--blur)` = `8px`      |
| `blur-md`   | `var(--blur-md)` = `12px`  |
| `blur-lg`   | `var(--blur-lg)` = `16px`  |
| `blur-xl`   | `var(--blur-xl)` = `24px`  |
| `blur-2xl`  | `var(--blur-2xl)` = `40px` |
| `blur-3xl`  | `var(--blur-3xl)` = `64px` |

Arbitrary: `blur-[2px]`.

## Brightness

`brightness-0`, `brightness-50`, `brightness-75`, `brightness-90`, `brightness-95`, `brightness-100`, `brightness-105`, `brightness-110`, `brightness-125`, `brightness-150`, `brightness-200`.

## Contrast

`contrast-0`, `contrast-50`, `contrast-75`, `contrast-100`, `contrast-125`, `contrast-150`, `contrast-200`.

## Drop Shadow

| Class              | Description       |
| ------------------ | ----------------- |
| `drop-shadow-none` | No drop shadow    |
| `drop-shadow-sm`   | Small             |
| `drop-shadow`      | Default           |
| `drop-shadow-md`   | Medium            |
| `drop-shadow-lg`   | Large             |
| `drop-shadow-xl`   | Extra large       |
| `drop-shadow-2xl`  | Extra extra large |

Drop shadow color: `drop-shadow-<color>`.

> Use `drop-shadow-*` instead of `shadow-*` on transparent PNGs/SVGs — it follows the alpha channel.

## Grayscale

`grayscale` (100%), `grayscale-0` (0%).

## Hue Rotate

`hue-rotate-0`, `hue-rotate-15`, `hue-rotate-30`, `hue-rotate-60`, `hue-rotate-90`, `hue-rotate-180`. Negative: `-hue-rotate-30` etc.

## Invert

`invert` (100%), `invert-0` (0%).

## Saturate

`saturate-0`, `saturate-50`, `saturate-100`, `saturate-150`, `saturate-200`.

## Sepia

`sepia` (100%), `sepia-0` (0%).

## Combined Example

```html
<img
  class="blur-sm brightness-110 contrast-125 grayscale hover:filter-none transition"
  src="…"
/>
```

`filter-none` removes all filters at once.

---

## Backdrop Filters

Identical set prefixed with `backdrop-`:

| Filter         | Backdrop equivalent     |
| -------------- | ----------------------- |
| `blur-*`       | `backdrop-blur-*`       |
| `brightness-*` | `backdrop-brightness-*` |
| `contrast-*`   | `backdrop-contrast-*`   |
| `grayscale`    | `backdrop-grayscale`    |
| `hue-rotate-*` | `backdrop-hue-rotate-*` |
| `invert`       | `backdrop-invert`       |
| `opacity-*`    | `backdrop-opacity-*`    |
| `saturate-*`   | `backdrop-saturate-*`   |
| `sepia`        | `backdrop-sepia-*`      |
| `filter-none`  | `backdrop-filter-none`  |

```html
<!-- Frosted glass effect -->
<div class="backdrop-blur-md backdrop-brightness-90 bg-white/30">…</div>
```
