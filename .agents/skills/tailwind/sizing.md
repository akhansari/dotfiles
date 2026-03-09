# Sizing

All numeric values compile to `calc(var(--spacing) * <n>)` (e.g. `w-4` → `calc(var(--spacing) * 4)` = `1rem`).

## Width

| Class      | Value                        |
| ---------- | ---------------------------- |
| `w-<n>`    | `calc(var(--spacing) * <n>)` |
| `w-auto`   | `auto`                       |
| `w-full`   | `100%`                       |
| `w-screen` | `100vw`                      |
| `w-dvw`    | `100dvw`                     |
| `w-svw`    | `100svw`                     |
| `w-lvw`    | `100lvw`                     |
| `w-min`    | `min-content`                |
| `w-max`    | `max-content`                |
| `w-fit`    | `fit-content`                |

**Fractions:** `w-1/2`, `w-1/3`, `w-2/3`, `w-1/4`, `w-3/4`, `w-1/5` … `w-5/6`, `w-1/12` … `w-11/12`.

**Container scale** (uses `--container-*` vars):

| Class   | Value   |
| ------- | ------- |
| `w-3xs` | `16rem` |
| `w-2xs` | `18rem` |
| `w-xs`  | `20rem` |
| `w-sm`  | `24rem` |
| `w-md`  | `28rem` |
| `w-lg`  | `32rem` |
| `w-xl`  | `36rem` |
| `w-2xl` | `42rem` |
| `w-3xl` | `48rem` |
| `w-4xl` | `56rem` |
| `w-5xl` | `64rem` |
| `w-6xl` | `72rem` |
| `w-7xl` | `80rem` |

## Height

Same scale as width. Notable keywords:

| Class           | Value                 |
| --------------- | --------------------- |
| `h-screen`      | `100vh`               |
| `h-dvh`         | `100dvh`              |
| `h-svh`         | `100svh`              |
| `h-lvh`         | `100lvh`              |
| `h-full`        | `100%`                |
| `h-auto`        | `auto`                |
| `h-min/max/fit` | `min/max/fit-content` |

## Size (width + height simultaneously)

`size-<n>` sets both `width` and `height` in one utility.

```html
<div class="size-10">40px × 40px</div>
<div class="size-full">100% × 100%</div>
<div class="size-[48px]">48px × 48px</div>
```

## Min / Max Width & Height

| Prefix    | Values                                                     |
| --------- | ---------------------------------------------------------- |
| `min-w-*` | `0`, `full`, `min`, `max`, `fit`, `<n>`, container scale   |
| `max-w-*` | same + `none`                                              |
| `min-h-*` | `0`, `full`, `screen`, `dvh/svh/lvh`, `min/max/fit`, `<n>` |
| `max-h-*` | same + `none`                                              |

```html
<div class="w-full max-w-2xl mx-auto">capped width</div>
<div class="min-h-screen flex flex-col">full-height layout</div>
```

## Logical Sizing

| Class                 | CSS Property                      |
| --------------------- | --------------------------------- |
| `w-*` on inline axis  | use `size-*` or logical classes   |
| `min-w-*` / `max-w-*` | also map to `--container-*` scale |

Arbitrary values work for all sizing utilities: `w-[320px]`, `h-[calc(100vh-64px)]`, `size-[clamp(10rem,50vw,30rem)]`.
