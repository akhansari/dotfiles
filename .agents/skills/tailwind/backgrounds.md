# Backgrounds

## Background Color

`bg-<color>-<shade>` — e.g. `bg-slate-100`, `bg-white`, `bg-transparent`, `bg-black`.

**Opacity modifier:** `bg-blue-500/50` sets background at 50% opacity. No need for separate `bg-opacity-*`.

In v4, colors use OKLCH color space internally.

## Background Image & Gradients

```html
<!-- Linear gradient -->
<div class="bg-linear-to-r from-cyan-500 to-blue-500">…</div>
<div class="bg-linear-to-br from-indigo-500 via-purple-500 to-pink-500">…</div>

<!-- Gradient stop colors with opacity -->
<div class="bg-linear-to-r from-sky-500/50 to-indigo-500/50">…</div>
```

| Class                              | CSS                                                    |
| ---------------------------------- | ------------------------------------------------------ |
| `bg-linear-to-t/tr/r/br/b/bl/l/tl` | `background-image: linear-gradient(to <direction>, …)` |
| `bg-radial`                        | `background-image: radial-gradient(…)`                 |
| `bg-conic`                         | `background-image: conic-gradient(…)`                  |
| `from-<color>`                     | `--tw-gradient-from`                                   |
| `via-<color>`                      | `--tw-gradient-via`                                    |
| `to-<color>`                       | `--tw-gradient-to`                                     |
| `from-<pct>`                       | `--tw-gradient-from-position` (e.g. `from-10%`)        |
| `via-<pct>`                        | `--tw-gradient-via-position`                           |
| `to-<pct>`                         | `--tw-gradient-to-position`                            |
| `bg-none`                          | `background-image: none`                               |

Arbitrary gradient: `bg-[linear-gradient(45deg,red,blue)]`.

## Background Clip

| Class             | CSS                            |
| ----------------- | ------------------------------ |
| `bg-clip-border`  | `background-clip: border-box`  |
| `bg-clip-padding` | `background-clip: padding-box` |
| `bg-clip-content` | `background-clip: content-box` |
| `bg-clip-text`    | `background-clip: text`        |

```html
<span
  class="bg-clip-text text-transparent bg-linear-to-r from-pink-500 to-violet-500"
>
  Gradient text
</span>
```

## Background Size

| Class        | CSS                        |
| ------------ | -------------------------- |
| `bg-auto`    | `background-size: auto`    |
| `bg-cover`   | `background-size: cover`   |
| `bg-contain` | `background-size: contain` |

Arbitrary: `bg-[length:200px_100px]`.

## Background Position

`bg-center`, `bg-top`, `bg-bottom`, `bg-left`, `bg-right`, `bg-left-top`, `bg-left-bottom`, `bg-right-top`, `bg-right-bottom`.

Arbitrary: `bg-[position:25%_75%]`.

## Background Repeat

| Class             | CSS                            |
| ----------------- | ------------------------------ |
| `bg-repeat`       | `background-repeat: repeat`    |
| `bg-no-repeat`    | `background-repeat: no-repeat` |
| `bg-repeat-x`     | `background-repeat: repeat-x`  |
| `bg-repeat-y`     | `background-repeat: repeat-y`  |
| `bg-repeat-round` | `background-repeat: round`     |
| `bg-repeat-space` | `background-repeat: space`     |

## Background Attachment

`bg-fixed`, `bg-local`, `bg-scroll`.

## Background Origin

`bg-origin-border`, `bg-origin-padding`, `bg-origin-content`.
