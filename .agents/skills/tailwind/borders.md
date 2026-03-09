# Borders

## Border Radius

Uses `--radius-*` CSS vars. `rounded-full` = `calc(infinity * 1px)`.

| Class          | Value                           |
| -------------- | ------------------------------- |
| `rounded-none` | `0`                             |
| `rounded-xs`   | `var(--radius-xs)` = `0.125rem` |
| `rounded-sm`   | `var(--radius-sm)` = `0.25rem`  |
| `rounded`      | `var(--radius)` = `0.25rem`     |
| `rounded-md`   | `var(--radius-md)` = `0.375rem` |
| `rounded-lg`   | `var(--radius-lg)` = `0.5rem`   |
| `rounded-xl`   | `var(--radius-xl)` = `0.75rem`  |
| `rounded-2xl`  | `var(--radius-2xl)` = `1rem`    |
| `rounded-3xl`  | `var(--radius-3xl)` = `1.5rem`  |
| `rounded-4xl`  | `var(--radius-4xl)` = `2rem`    |
| `rounded-full` | `calc(infinity * 1px)`          |

**Per-side:** `rounded-t-*`, `rounded-r-*`, `rounded-b-*`, `rounded-l-*`

**Per-corner:** `rounded-tl-*`, `rounded-tr-*`, `rounded-br-*`, `rounded-bl-*`

**Logical:** `rounded-s-*` (start), `rounded-e-*` (end), `rounded-ss-*`, `rounded-se-*`, `rounded-es-*`, `rounded-ee-*`

## Border Width

`border` (1px), `border-0`, `border-2`, `border-4`, `border-8`.

Per-side: `border-t-*`, `border-r-*`, `border-b-*`, `border-l-*`.
Logical: `border-s-*`, `border-e-*`.
Inline/block: `border-x-*`, `border-y-*`.

## Border Color

`border-<color>-<shade>` — e.g. `border-slate-200`, `border-transparent`.

Opacity modifier: `border-blue-500/50`.

Per-side: `border-t-<color>`, `border-r-<color>` etc.

## Border Style

`border-solid`, `border-dashed`, `border-dotted`, `border-double`, `border-hidden`, `border-none`.

## Divide (between children)

Adds borders between child elements:

| Class                        | Effect                                     |
| ---------------------------- | ------------------------------------------ |
| `divide-x-<n>`               | `border-left-width` on all but first child |
| `divide-y-<n>`               | `border-top-width` on all but first child  |
| `divide-x-reverse`           | For reversed flex-row                      |
| `divide-y-reverse`           | For reversed flex-col                      |
| `divide-<color>`             | Sets divide border color                   |
| `divide-solid/dashed/dotted` | Sets divide border style                   |

```html
<ul class="divide-y divide-gray-200">
  <li class="py-3">Item 1</li>
  <li class="py-3">Item 2</li>
</ul>
```

## Outline

| Class                                | CSS                                                   |
| ------------------------------------ | ----------------------------------------------------- |
| `outline`                            | `outline-style: solid` + `outline-width: 1px`         |
| `outline-none`                       | `outline: 2px solid transparent; outline-offset: 2px` |
| `outline-0`                          | `outline-width: 0`                                    |
| `outline-<n>`                        | `outline-width: <n>px` (1,2,4,8)                      |
| `outline-<color>`                    | `outline-color`                                       |
| `outline-solid/dashed/dotted/double` | `outline-style`                                       |
| `outline-offset-<n>`                 | `outline-offset` (0,1,2,4,8)                          |

```html
<button class="focus:outline-none focus:ring-2 focus:ring-blue-500">…</button>
```

## Ring

Ring utilities add a box-shadow that simulates a border — commonly used for focus states.

| Class                 | CSS                                            |
| --------------------- | ---------------------------------------------- |
| `ring`                | `box-shadow: 0 0 0 3px var(--tw-ring-color)`   |
| `ring-<n>`            | `box-shadow: 0 0 0 <n>px var(--tw-ring-color)` |
| `ring-<color>`        | Sets `--tw-ring-color`                         |
| `ring-offset-<n>`     | `--tw-ring-offset-width`                       |
| `ring-offset-<color>` | `--tw-ring-offset-color`                       |
| `inset-ring`          | Inset ring variant                             |
| `inset-ring-<n>`      | Inset ring width                               |
| `inset-ring-<color>`  | Inset ring color                               |
