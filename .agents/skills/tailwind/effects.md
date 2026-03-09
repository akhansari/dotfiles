# Effects

## Box Shadow

Uses `--shadow-*` vars. Shadow color is set separately via `shadow-<color>`.

| Class         | Description        |
| ------------- | ------------------ |
| `shadow-2xs`  | Extra extra small  |
| `shadow-xs`   | Extra small        |
| `shadow-sm`   | Small              |
| `shadow`      | Default            |
| `shadow-md`   | Medium             |
| `shadow-lg`   | Large              |
| `shadow-xl`   | Extra large        |
| `shadow-2xl`  | Extra extra large  |
| `shadow-none` | `box-shadow: none` |

**Shadow color:** `shadow-<color>` sets `--tw-shadow-color`. Supports opacity modifier: `shadow-black/50`.

```html
<div class="shadow-lg shadow-blue-500/40">…</div>
```

**Inset shadows:**

| Class               | Description             |
| ------------------- | ----------------------- |
| `inset-shadow-2xs`  | Inset extra extra small |
| `inset-shadow-xs`   | Inset extra small       |
| `inset-shadow-sm`   | Inset small             |
| `inset-shadow`      | Inset default           |
| `inset-shadow-none` | Remove inset shadow     |

**Inset shadow color:** `inset-shadow-<color>`.

## Text Shadow

| Class              | Description                   |
| ------------------ | ----------------------------- |
| `text-shadow-2xs`  | Extra extra small text shadow |
| `text-shadow-xs`   | Extra small text shadow       |
| `text-shadow-sm`   | Small text shadow             |
| `text-shadow`      | Default text shadow           |
| `text-shadow-md`   | Medium text shadow            |
| `text-shadow-lg`   | Large text shadow             |
| `text-shadow-none` | `text-shadow: none`           |

**Text shadow color:** `text-shadow-<color>`.

## Opacity

`opacity-0`, `opacity-5`, `opacity-10`, `opacity-15`, `opacity-20`, `opacity-25`, `opacity-30`, `opacity-35`, `opacity-40`, `opacity-45`, `opacity-50`, `opacity-55`, `opacity-60`, `opacity-65`, `opacity-70`, `opacity-75`, `opacity-80`, `opacity-85`, `opacity-90`, `opacity-95`, `opacity-100`.

Arbitrary: `opacity-[.67]`.

> Prefer the opacity modifier syntax (`bg-black/50`, `text-blue-500/75`) over `opacity-*` when only the color's alpha should change.

## Mix Blend Mode

`mix-blend-normal`, `mix-blend-multiply`, `mix-blend-screen`, `mix-blend-overlay`, `mix-blend-darken`, `mix-blend-lighten`, `mix-blend-color-dodge`, `mix-blend-color-burn`, `mix-blend-hard-light`, `mix-blend-soft-light`, `mix-blend-difference`, `mix-blend-exclusion`, `mix-blend-hue`, `mix-blend-saturation`, `mix-blend-color`, `mix-blend-luminosity`, `mix-blend-plus-darker`, `mix-blend-plus-lighter`.

## Background Blend Mode

`bg-blend-*` — same values as `mix-blend-*` above.

## Mask

| Class                    | CSS                         |
| ------------------------ | --------------------------- |
| `mask-none`              | `mask-image: none`          |
| `mask-linear-to-t/r/b/l` | Linear gradient mask        |
| `mask-radial`            | Radial gradient mask        |
| `mask-<color>`           | `mask-image` color          |
| `mask-from-<pct>`        | Mask gradient from position |
| `mask-to-<pct>`          | Mask gradient to position   |

```html
<div class="mask-linear-to-b from-black to-transparent">…</div>
```
