# Transforms

In Tailwind CSS v4, scale/rotate/translate use **native CSS properties** (`scale`, `rotate`, `translate`), NOT the `transform` shorthand. This enables individual CSS transitions.

## Scale

Uses native CSS `scale` property.

| Class          | CSS                                              |
| -------------- | ------------------------------------------------ |
| `scale-<n>`    | `scale: <n>% <n>%` (e.g. `scale-75` → `75% 75%`) |
| `scale-x-<n>`  | `scale: <n>% 100%`                               |
| `scale-y-<n>`  | `scale: 100% <n>%`                               |
| `-scale-<n>`   | `scale: -<n>% -<n>%`                             |
| `-scale-x-<n>` | `scale: -<n>% 100%`                              |
| `-scale-y-<n>` | `scale: 100% -<n>%`                              |

Scale values: `0`, `50`, `75`, `90`, `95`, `100`, `105`, `110`, `125`, `150`. Arbitrary: `scale-[1.15]`.

**3D scale** — use `scale-3d` to enable `scale-z-*`:

```html
<div class="scale-3d scale-z-150 perspective-500">…</div>
```

## Rotate

Uses native CSS `rotate` property.

| Class          | CSS                                       |
| -------------- | ----------------------------------------- |
| `rotate-<n>`   | `rotate: <n>deg`                          |
| `-rotate-<n>`  | `rotate: -<n>deg`                         |
| `rotate-x-<n>` | `rotate: x <n>deg`                        |
| `rotate-y-<n>` | `rotate: y <n>deg`                        |
| `rotate-z-<n>` | `rotate: z <n>deg` (same as `rotate-<n>`) |
| `rotate-none`  | `rotate: none`                            |

Rotate values: `0`, `1`, `2`, `3`, `6`, `12`, `45`, `90`, `180`. Arbitrary: `rotate-[17deg]`.

## Translate

Uses native CSS `translate` property.

| Class                                  | CSS                                         |
| -------------------------------------- | ------------------------------------------- |
| `translate-x-<n>`                      | `translate: calc(var(--spacing) * <n>) 0`   |
| `translate-y-<n>`                      | `translate: 0 calc(var(--spacing) * <n>)`   |
| `translate-z-<n>`                      | `translate: 0 0 calc(var(--spacing) * <n>)` |
| `-translate-x-<n>`                     | Negative x translation                      |
| `-translate-y-<n>`                     | Negative y translation                      |
| `translate-x-1/2` … `translate-x-full` | Percentage-based                            |
| `translate-none`                       | `translate: none`                           |

Common pattern — center absolutely positioned element:

```html
<div class="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2">…</div>
```

## Skew

Uses `transform` property (combined with other transforms).

| Class         | CSS                   |
| ------------- | --------------------- |
| `skew-x-<n>`  | `--tw-skew-x: <n>deg` |
| `skew-y-<n>`  | `--tw-skew-y: <n>deg` |
| `-skew-x-<n>` | Negative skew-x       |
| `-skew-y-<n>` | Negative skew-y       |

Skew values: `0`, `1`, `2`, `3`, `6`, `12`. Arbitrary: `skew-x-[15deg]`.

## Transform Origin

`origin-center`, `origin-top`, `origin-top-right`, `origin-right`, `origin-bottom-right`, `origin-bottom`, `origin-bottom-left`, `origin-left`, `origin-top-left`.

## Transform Style (3D)

| Class            | CSS                            |
| ---------------- | ------------------------------ |
| `transform-3d`   | `transform-style: preserve-3d` |
| `transform-flat` | `transform-style: flat`        |

## Perspective

`perspective-<n>` — uses `--perspective-*` vars: `dramatic` (100px), `near` (300px), `normal` (500px), `midrange` (800px), `distant` (1200px), `none`.

Arbitrary: `perspective-[800px]`.

`perspective-origin-center`, `perspective-origin-top`, etc.

## Backface Visibility

| Class              | CSS                            |
| ------------------ | ------------------------------ |
| `backface-visible` | `backface-visibility: visible` |
| `backface-hidden`  | `backface-visibility: hidden`  |

## Example

```html
<!-- Hover scale with transition -->
<img class="transition-transform duration-200 hover:scale-105" />

<!-- Flip card -->
<div class="transform-3d perspective-normal">
  <div class="backface-hidden rotate-y-180">Back</div>
</div>
```
