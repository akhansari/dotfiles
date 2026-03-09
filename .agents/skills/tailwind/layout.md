# Layout

## Display

| Class          | CSS                     |
| -------------- | ----------------------- |
| `block`        | `display: block`        |
| `inline-block` | `display: inline-block` |
| `inline`       | `display: inline`       |
| `flex`         | `display: flex`         |
| `inline-flex`  | `display: inline-flex`  |
| `grid`         | `display: grid`         |
| `inline-grid`  | `display: inline-grid`  |
| `contents`     | `display: contents`     |
| `hidden`       | `display: none`         |
| `table`        | `display: table`        |
| `table-cell`   | `display: table-cell`   |
| `table-row`    | `display: table-row`    |
| `list-item`    | `display: list-item`    |

## Position

| Class      | CSS                  |
| ---------- | -------------------- |
| `static`   | `position: static`   |
| `relative` | `position: relative` |
| `absolute` | `position: absolute` |
| `fixed`    | `position: fixed`    |
| `sticky`   | `position: sticky`   |

**Inset utilities** — use `inset-*`, `inset-x-*`, `inset-y-*`, `top-*`, `right-*`, `bottom-*`, `left-*`:

```html
<div class="absolute inset-0">full bleed</div>
<div class="absolute top-4 right-4">top-right</div>
<div class="sticky top-0">sticky header</div>
```

Logical inset: `start-*` / `end-*` (maps to `inset-inline-start` / `inset-inline-end`).

## Overflow

| Class              | CSS                 |
| ------------------ | ------------------- |
| `overflow-auto`    | `overflow: auto`    |
| `overflow-hidden`  | `overflow: hidden`  |
| `overflow-clip`    | `overflow: clip`    |
| `overflow-visible` | `overflow: visible` |
| `overflow-scroll`  | `overflow: scroll`  |
| `overflow-x-auto`  | `overflow-x: auto`  |
| `overflow-y-auto`  | `overflow-y: auto`  |

## Z-Index

`z-0`, `z-10`, `z-20`, `z-30`, `z-40`, `z-50`, `z-auto`. Arbitrary: `z-[100]`.

## Float & Clear

| Class                        | CSS                   |
| ---------------------------- | --------------------- |
| `float-left`                 | `float: left`         |
| `float-right`                | `float: right`        |
| `float-none`                 | `float: none`         |
| `float-start`                | `float: inline-start` |
| `float-end`                  | `float: inline-end`   |
| `clear-left/right/both/none` | `clear: …`            |

## Box Sizing

| Class         | CSS                       |
| ------------- | ------------------------- |
| `box-border`  | `box-sizing: border-box`  |
| `box-content` | `box-sizing: content-box` |

## Aspect Ratio

| Class           | CSS                    |
| --------------- | ---------------------- |
| `aspect-auto`   | `aspect-ratio: auto`   |
| `aspect-square` | `aspect-ratio: 1 / 1`  |
| `aspect-video`  | `aspect-ratio: 16 / 9` |
| `aspect-[4/3]`  | `aspect-ratio: 4 / 3`  |

## Columns

`columns-1` … `columns-12`, `columns-auto`, `columns-3xs` … `columns-7xl`.

```html
<div class="columns-3 gap-4">
  <img class="mb-4 break-inside-avoid" ... />
</div>
```

`break-inside-avoid`, `break-before-*`, `break-after-*` control column breaks.

## Object Fit & Position

| Class               | CSS                       |
| ------------------- | ------------------------- |
| `object-contain`    | `object-fit: contain`     |
| `object-cover`      | `object-fit: cover`       |
| `object-fill`       | `object-fit: fill`        |
| `object-none`       | `object-fit: none`        |
| `object-scale-down` | `object-fit: scale-down`  |
| `object-center`     | `object-position: center` |
| `object-top`        | `object-position: top`    |
| `object-bottom`     | `object-position: bottom` |
| `object-left`       | `object-position: left`   |
| `object-right`      | `object-position: right`  |

## Visibility

| Class       | CSS                    |
| ----------- | ---------------------- |
| `visible`   | `visibility: visible`  |
| `invisible` | `visibility: hidden`   |
| `collapse`  | `visibility: collapse` |

## Accessibility — Screen Reader

| Class         | Effect                                      |
| ------------- | ------------------------------------------- |
| `sr-only`     | Visually hidden, readable by screen readers |
| `not-sr-only` | Reverses `sr-only`                          |

```html
<button>
  <Icon />
  <span class="sr-only">Close menu</span>
</button>
```

## Container

`container` sets `width: 100%` and applies max-width at each breakpoint. Combine with `mx-auto px-4` for centered layouts.

```html
<div class="container mx-auto px-4">…</div>
```
