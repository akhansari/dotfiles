# Spacing

All spacing utilities are driven by the `--spacing` CSS variable (default `0.25rem = 4px`).
Values compile to `calc(var(--spacing) * <n>)`.

## Padding

| Prefix    | Property                         |
| --------- | -------------------------------- |
| `p-<n>`   | `padding` (all sides)            |
| `px-<n>`  | `padding-inline`                 |
| `py-<n>`  | `padding-block`                  |
| `pt-<n>`  | `padding-top`                    |
| `pr-<n>`  | `padding-right`                  |
| `pb-<n>`  | `padding-bottom`                 |
| `pl-<n>`  | `padding-left`                   |
| `ps-<n>`  | `padding-inline-start` (logical) |
| `pe-<n>`  | `padding-inline-end` (logical)   |
| `pbs-<n>` | `padding-block-start` (logical)  |
| `pbe-<n>` | `padding-block-end` (logical)    |

Common values: `0`, `0.5`, `1`, `1.5`, `2`, `2.5`, `3`, `3.5`, `4`, `5`, `6`, `7`, `8`, `9`, `10`, `11`, `12`, `14`, `16`, `20`, `24`, `28`, `32`, `36`, `40`, `44`, `48`, `52`, `56`, `60`, `64`, `72`, `80`, `96`. Arbitrary: `p-[13px]`.

## Margin

Same set of suffixes as padding: `m-*`, `mx-*`, `my-*`, `mt-*`, `mr-*`, `mb-*`, `ml-*`, `ms-*`, `me-*`.

**Auto margin:** `m-auto`, `mx-auto`, `mt-auto` etc. — useful for centering.

**Negative margin:** prefix with `-`: `-mt-4`, `-mx-2`.

```html
<div class="px-4 py-2">padded</div>
<div class="mx-auto max-w-xl">centered</div>
<div class="-mt-px">overlap 1px</div>
```

## Space Between (child spacing)

Adds margin between children without modifying the children themselves.

| Class             | Effect                                       |
| ----------------- | -------------------------------------------- |
| `space-x-<n>`     | `margin-inline-start` on all but first child |
| `space-y-<n>`     | `margin-block-start` on all but first child  |
| `space-x-reverse` | flip direction for RTL / reversed flex       |
| `space-y-reverse` | flip direction for reversed flex-col         |

```html
<div class="flex space-x-4">
  <div>A</div>
  <div>B</div>
  <div>C</div>
</div>
```

> Prefer `gap-*` on flex/grid containers when possible — `space-*` uses a CSS selector hack that can conflict with some layouts.
