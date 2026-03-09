# Flexbox & Grid

## Flexbox

### Direction & Wrap

| Class               | CSS                              |
| ------------------- | -------------------------------- |
| `flex-row`          | `flex-direction: row`            |
| `flex-row-reverse`  | `flex-direction: row-reverse`    |
| `flex-col`          | `flex-direction: column`         |
| `flex-col-reverse`  | `flex-direction: column-reverse` |
| `flex-wrap`         | `flex-wrap: wrap`                |
| `flex-wrap-reverse` | `flex-wrap: wrap-reverse`        |
| `flex-nowrap`       | `flex-wrap: nowrap`              |

### Grow, Shrink & Basis

| Class                      | CSS                                      |
| -------------------------- | ---------------------------------------- |
| `grow` / `grow-0`          | `flex-grow: 1` / `0`                     |
| `shrink` / `shrink-0`      | `flex-shrink: 1` / `0`                   |
| `basis-auto`               | `flex-basis: auto`                       |
| `basis-<n>`                | `flex-basis: calc(var(--spacing) * <n>)` |
| `basis-1/2` … `basis-full` | `flex-basis: 50%` … `100%`               |

### Flex Shorthand

`flex-1` (`1 1 0%`), `flex-auto` (`1 1 auto`), `flex-none` (`0 0 auto`), `flex-initial` (`0 1 auto`).

### Order

`order-first`, `order-last`, `order-none`, `order-1` … `order-12`. Arbitrary: `order-[13]`.

## Grid

### Template Columns & Rows

| Class                          | CSS                                                  |
| ------------------------------ | ---------------------------------------------------- |
| `grid-cols-1` … `grid-cols-12` | `grid-template-columns: repeat(<n>, minmax(0, 1fr))` |
| `grid-cols-none`               | `grid-template-columns: none`                        |
| `grid-cols-subgrid`            | `grid-template-columns: subgrid`                     |
| `grid-rows-1` … `grid-rows-12` | `grid-template-rows: repeat(<n>, minmax(0, 1fr))`    |
| `grid-rows-none`               | `grid-template-rows: none`                           |
| `grid-rows-subgrid`            | `grid-template-rows: subgrid`                        |

Arbitrary: `grid-cols-[200px_1fr_200px]`.

### Column & Row Span / Start / End

| Class                                    | CSS                                |
| ---------------------------------------- | ---------------------------------- |
| `col-span-1` … `col-span-12`             | `grid-column: span <n> / span <n>` |
| `col-span-full`                          | `grid-column: 1 / -1`              |
| `col-start-1` … `col-start-13`           | `grid-column-start: <n>`           |
| `col-end-1` … `col-end-13`               | `grid-column-end: <n>`             |
| `row-span-*`, `row-start-*`, `row-end-*` | same pattern for rows              |

### Auto Flow, Auto Cols & Rows

| Class                 | CSS                                 |
| --------------------- | ----------------------------------- |
| `grid-flow-row`       | `grid-auto-flow: row`               |
| `grid-flow-col`       | `grid-auto-flow: column`            |
| `grid-flow-dense`     | `grid-auto-flow: dense`             |
| `grid-flow-row-dense` | `grid-auto-flow: row dense`         |
| `auto-cols-auto`      | `grid-auto-columns: auto`           |
| `auto-cols-min`       | `grid-auto-columns: min-content`    |
| `auto-cols-max`       | `grid-auto-columns: max-content`    |
| `auto-cols-fr`        | `grid-auto-columns: minmax(0, 1fr)` |
| `auto-rows-auto`      | `grid-auto-rows: auto`              |
| `auto-rows-min`       | `grid-auto-rows: min-content`       |
| `auto-rows-max`       | `grid-auto-rows: max-content`       |
| `auto-rows-fr`        | `grid-auto-rows: minmax(0, 1fr)`    |

## Gap

`gap-<n>`, `gap-x-<n>`, `gap-y-<n>` — all driven by `calc(var(--spacing) * <n>)`.

```html
<div class="grid grid-cols-3 gap-4">…</div>
<div class="flex flex-row gap-x-2 gap-y-4">…</div>
```

## Justify & Align

### Justify Content (main axis)

| Class             | CSS                              |
| ----------------- | -------------------------------- |
| `justify-start`   | `justify-content: flex-start`    |
| `justify-end`     | `justify-content: flex-end`      |
| `justify-center`  | `justify-content: center`        |
| `justify-between` | `justify-content: space-between` |
| `justify-around`  | `justify-content: space-around`  |
| `justify-evenly`  | `justify-content: space-evenly`  |
| `justify-stretch` | `justify-content: stretch`       |

### Justify Items & Self (grid)

`justify-items-start/end/center/stretch`, `justify-self-start/end/center/stretch/auto`.

### Align Content

`content-start`, `content-end`, `content-center`, `content-between`, `content-around`, `content-evenly`, `content-stretch`, `content-baseline`.

### Align Items

`items-start`, `items-end`, `items-center`, `items-stretch`, `items-baseline`.

### Align Self

`self-auto`, `self-start`, `self-end`, `self-center`, `self-stretch`, `self-baseline`.

### Place Utilities (shorthand)

`place-content-*`, `place-items-*`, `place-self-*` — combine justify + align in one.

```html
<div class="flex items-center justify-between">…</div>
<div class="grid grid-cols-2 place-items-center gap-6">…</div>
```
