# Typography

## Font Family

| Class        | CSS                 |
| ------------ | ------------------- |
| `font-sans`  | `var(--font-sans)`  |
| `font-serif` | `var(--font-serif)` |
| `font-mono`  | `var(--font-mono)`  |

Override in `@theme`: `--font-sans: "Inter", sans-serif;`

## Font Size

Font size utilities set both `font-size` and `line-height` via `--text-*` vars.

| Class       | Size       | Line Height |
| ----------- | ---------- | ----------- |
| `text-xs`   | `0.75rem`  | `1rem`      |
| `text-sm`   | `0.875rem` | `1.25rem`   |
| `text-base` | `1rem`     | `1.5rem`    |
| `text-lg`   | `1.125rem` | `1.75rem`   |
| `text-xl`   | `1.25rem`  | `1.75rem`   |
| `text-2xl`  | `1.5rem`   | `2rem`      |
| `text-3xl`  | `1.875rem` | `2.25rem`   |
| `text-4xl`  | `2.25rem`  | `2.5rem`    |
| `text-5xl`  | `3rem`     | `1`         |
| `text-6xl`  | `3.75rem`  | `1`         |
| `text-7xl`  | `4.5rem`   | `1`         |
| `text-8xl`  | `6rem`     | `1`         |
| `text-9xl`  | `8rem`     | `1`         |

**Override line-height inline** with the `/<lh>` shorthand:

```html
<p class="text-sm/6">14px font, 24px line-height</p>
<p class="text-lg/7">18px font, 28px line-height</p>
```

## Font Weight

`font-thin` (100), `font-extralight` (200), `font-light` (300), `font-normal` (400), `font-medium` (500), `font-semibold` (600), `font-bold` (700), `font-extrabold` (800), `font-black` (900).

## Font Style

`italic`, `not-italic`.

## Font Smoothing

`antialiased` (`-webkit-font-smoothing: antialiased`), `subpixel-antialiased`.

## Font Stretch

`font-stretch-condensed`, `font-stretch-normal`, `font-stretch-expanded` etc.

## Letter Spacing (Tracking)

| Class              | CSS        |
| ------------------ | ---------- |
| `tracking-tighter` | `-0.05em`  |
| `tracking-tight`   | `-0.025em` |
| `tracking-normal`  | `0`        |
| `tracking-wide`    | `0.025em`  |
| `tracking-wider`   | `0.05em`   |
| `tracking-widest`  | `0.1em`    |

## Line Height (Leading)

`leading-none` (1), `leading-tight` (1.25), `leading-snug` (1.375), `leading-normal` (1.5), `leading-relaxed` (1.625), `leading-loose` (2). Numeric: `leading-3` … `leading-10`. Prefer `text-sm/6` shorthand over separate `leading-*`.

## Line Clamp

```html
<p class="line-clamp-3">Truncates to 3 lines with ellipsis.</p>
<p class="line-clamp-none">Removes clamping.</p>
```

## Text Alignment

`text-left`, `text-center`, `text-right`, `text-justify`, `text-start`, `text-end`.

## Text Color

`text-<color>-<shade>` — e.g. `text-slate-700`, `text-white`, `text-transparent`.

**Opacity modifier:** `text-blue-600/75` sets color at 75% opacity.

## Text Decoration

| Class                                        | CSS                                  |
| -------------------------------------------- | ------------------------------------ |
| `underline`                                  | `text-decoration-line: underline`    |
| `overline`                                   | `text-decoration-line: overline`     |
| `line-through`                               | `text-decoration-line: line-through` |
| `no-underline`                               | `text-decoration-line: none`         |
| `decoration-<color>`                         | `text-decoration-color`              |
| `decoration-solid/dashed/dotted/double/wavy` | `text-decoration-style`              |
| `decoration-0` … `decoration-8`              | `text-decoration-thickness`          |
| `underline-offset-<n>`                       | `text-underline-offset`              |

## Text Transform

`uppercase`, `lowercase`, `capitalize`, `normal-case`.

## Text Overflow

| Class           | CSS                                                              |
| --------------- | ---------------------------------------------------------------- |
| `truncate`      | `overflow: hidden; text-overflow: ellipsis; white-space: nowrap` |
| `text-ellipsis` | `text-overflow: ellipsis`                                        |
| `text-clip`     | `text-overflow: clip`                                            |

## Text Wrap

`text-wrap`, `text-nowrap`, `text-balance`, `text-pretty`.

## Text Indent

`indent-<n>` — driven by `--spacing`.

## Whitespace

`whitespace-normal`, `whitespace-nowrap`, `whitespace-pre`, `whitespace-pre-line`, `whitespace-pre-wrap`, `whitespace-break-spaces`.

## Word Break

`break-normal`, `break-words`, `break-all`, `break-keep`.

## Vertical Align

`align-baseline`, `align-top`, `align-middle`, `align-bottom`, `align-text-top`, `align-text-bottom`, `align-sub`, `align-super`.

## List Style

`list-none`, `list-disc`, `list-decimal`. `list-inside`, `list-outside`. `list-image-none`.
