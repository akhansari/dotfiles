# Interactivity

## Cursor

| Class                                    | CSS                        |
| ---------------------------------------- | -------------------------- |
| `cursor-auto`                            | `cursor: auto`             |
| `cursor-default`                         | `cursor: default`          |
| `cursor-pointer`                         | `cursor: pointer`          |
| `cursor-wait`                            | `cursor: wait`             |
| `cursor-text`                            | `cursor: text`             |
| `cursor-move`                            | `cursor: move`             |
| `cursor-help`                            | `cursor: help`             |
| `cursor-not-allowed`                     | `cursor: not-allowed`      |
| `cursor-none`                            | `cursor: none`             |
| `cursor-context-menu`                    | `cursor: context-menu`     |
| `cursor-progress`                        | `cursor: progress`         |
| `cursor-cell`                            | `cursor: cell`             |
| `cursor-crosshair`                       | `cursor: crosshair`        |
| `cursor-vertical-text`                   | `cursor: vertical-text`    |
| `cursor-alias`                           | `cursor: alias`            |
| `cursor-copy`                            | `cursor: copy`             |
| `cursor-no-drop`                         | `cursor: no-drop`          |
| `cursor-grab`                            | `cursor: grab`             |
| `cursor-grabbing`                        | `cursor: grabbing`         |
| `cursor-all-scroll`                      | `cursor: all-scroll`       |
| `cursor-col-resize`                      | `cursor: col-resize`       |
| `cursor-row-resize`                      | `cursor: row-resize`       |
| `cursor-n-resize` … `cursor-nwse-resize` | Directional resize cursors |
| `cursor-zoom-in`                         | `cursor: zoom-in`          |
| `cursor-zoom-out`                        | `cursor: zoom-out`         |

Arbitrary: `cursor-[url(hand.cur),pointer]`.

## Pointer Events

| Class                 | CSS                    |
| --------------------- | ---------------------- |
| `pointer-events-none` | `pointer-events: none` |
| `pointer-events-auto` | `pointer-events: auto` |

## User Select

| Class         | CSS                 |
| ------------- | ------------------- |
| `select-none` | `user-select: none` |
| `select-text` | `user-select: text` |
| `select-all`  | `user-select: all`  |
| `select-auto` | `user-select: auto` |

## Resize

| Class         | CSS                  |
| ------------- | -------------------- |
| `resize-none` | `resize: none`       |
| `resize`      | `resize: both`       |
| `resize-x`    | `resize: horizontal` |
| `resize-y`    | `resize: vertical`   |

## Scroll Behavior

`scroll-auto`, `scroll-smooth`.

## Scroll Snap

**Container:**

| Class            | CSS                                                       |
| ---------------- | --------------------------------------------------------- |
| `snap-x`         | `scroll-snap-type: x var(--tw-scroll-snap-strictness)`    |
| `snap-y`         | `scroll-snap-type: y var(--tw-scroll-snap-strictness)`    |
| `snap-both`      | `scroll-snap-type: both var(--tw-scroll-snap-strictness)` |
| `snap-none`      | `scroll-snap-type: none`                                  |
| `snap-mandatory` | `--tw-scroll-snap-strictness: mandatory`                  |
| `snap-proximity` | `--tw-scroll-snap-strictness: proximity`                  |

**Items:**

| Class             | CSS                         |
| ----------------- | --------------------------- |
| `snap-start`      | `scroll-snap-align: start`  |
| `snap-end`        | `scroll-snap-align: end`    |
| `snap-center`     | `scroll-snap-align: center` |
| `snap-align-none` | `scroll-snap-align: none`   |
| `snap-always`     | `scroll-snap-stop: always`  |
| `snap-normal`     | `scroll-snap-stop: normal`  |

## Scroll Margin & Padding

`scroll-m-<n>`, `scroll-mx-<n>`, `scroll-my-<n>`, `scroll-mt-<n>` etc. — same axis suffixes as margin.

`scroll-p-<n>`, `scroll-px-<n>` etc. — same as padding.

## Touch Action

`touch-auto`, `touch-none`, `touch-pan-x`, `touch-pan-left`, `touch-pan-right`, `touch-pan-y`, `touch-pan-up`, `touch-pan-down`, `touch-pinch-zoom`, `touch-manipulation`.

## Will Change

`will-change-auto`, `will-change-scroll`, `will-change-contents`, `will-change-transform`.

> Use sparingly — only for elements known to animate, as it consumes GPU memory.

## Appearance

`appearance-none` — removes browser default UI for form elements (useful for custom `<select>`, `<input>`).

`appearance-auto` — restores default.

## Accent Color

`accent-<color>-<shade>` — sets color for checkboxes, radio buttons, range inputs.

```html
<input type="checkbox" class="accent-violet-500" />
```

## Caret Color

`caret-<color>` — sets the text cursor color in `<input>`/`<textarea>`.

```html
<input class="caret-blue-500" />
```

## Color Scheme

`color-scheme-normal`, `color-scheme-light`, `color-scheme-dark`, `color-scheme-light-dark`.

## Field Sizing

`field-sizing-fixed`, `field-sizing-content` — auto-sizes `<textarea>` to its content.

```html
<textarea class="field-sizing-content">…</textarea>
```
