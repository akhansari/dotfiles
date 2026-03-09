# Tables

## Border Collapse

| Class             | CSS                         |
| ----------------- | --------------------------- |
| `border-collapse` | `border-collapse: collapse` |
| `border-separate` | `border-collapse: separate` |

## Border Spacing

Used with `border-separate`. Driven by `--spacing` scale.

| Class                  | CSS                                          |
| ---------------------- | -------------------------------------------- |
| `border-spacing-<n>`   | `border-spacing: calc(var(--spacing) * <n>)` |
| `border-spacing-x-<n>` | `border-spacing: <n> 0`                      |
| `border-spacing-y-<n>` | `border-spacing: 0 <n>`                      |

## Table Layout

| Class         | CSS                   |
| ------------- | --------------------- |
| `table-auto`  | `table-layout: auto`  |
| `table-fixed` | `table-layout: fixed` |

`table-fixed` is useful for equal-width columns — column widths are set by the first row or explicit widths.

## Caption Side

| Class            | CSS                    |
| ---------------- | ---------------------- |
| `caption-top`    | `caption-side: top`    |
| `caption-bottom` | `caption-side: bottom` |

## Example

```html
<table class="w-full table-fixed border-collapse">
  <caption class="caption-bottom text-sm text-gray-500">
    Table 1: Summary
  </caption>
  <thead>
    <tr>
      <th class="border border-gray-300 px-4 py-2 text-left">Name</th>
      <th class="border border-gray-300 px-4 py-2 text-left">Role</th>
    </tr>
  </thead>
  <tbody class="divide-y divide-gray-200">
    <tr>
      <td class="border border-gray-300 px-4 py-2">Alice</td>
      <td class="border border-gray-300 px-4 py-2">Engineer</td>
    </tr>
  </tbody>
</table>
```

## Striped Rows

Use the `even:` / `odd:` variants for zebra striping:

```html
<tr class="even:bg-gray-50 odd:bg-white">
  …
</tr>
```
