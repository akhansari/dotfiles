# Transitions & Animation

## Transition Property

| Class                  | Properties transitioned                                                                                                                                                                                                                                                                   |
| ---------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `transition`           | `color`, `background-color`, `border-color`, `text-decoration-color`, `fill`, `stroke`, `--tw-shadow`, `--tw-ring-color`, `opacity`, `box-shadow`, `transform`, `translate`, `scale`, `rotate`, `filter`, `backdrop-filter`, `display`, `content-visibility`, `overlay`, `pointer-events` |
| `transition-all`       | All properties                                                                                                                                                                                                                                                                            |
| `transition-colors`    | Color-related properties                                                                                                                                                                                                                                                                  |
| `transition-opacity`   | `opacity`                                                                                                                                                                                                                                                                                 |
| `transition-shadow`    | `box-shadow`                                                                                                                                                                                                                                                                              |
| `transition-transform` | `transform`, `translate`, `scale`, `rotate`                                                                                                                                                                                                                                               |
| `transition-none`      | Disables all transitions                                                                                                                                                                                                                                                                  |
| `transition-discrete`  | Enables `transition-behavior: allow-discrete` for discrete properties (`display`, `visibility`)                                                                                                                                                                                           |

> v4 `transition` now includes `display` and `content-visibility` so that `hidden`/`block` toggling can animate properly with `transition-discrete`.

## Duration

`duration-0`, `duration-75`, `duration-100`, `duration-150`, `duration-200`, `duration-300`, `duration-500`, `duration-700`, `duration-1000`.

Arbitrary: `duration-[400ms]`.

## Timing Function (Easing)

| Class          | CSS                                  |
| -------------- | ------------------------------------ |
| `ease-linear`  | `transition-timing-function: linear` |
| `ease-in`      | `cubic-bezier(0.4, 0, 1, 1)`         |
| `ease-out`     | `cubic-bezier(0, 0, 0.2, 1)`         |
| `ease-in-out`  | `cubic-bezier(0.4, 0, 0.2, 1)`       |
| `ease-initial` | `initial`                            |

Arbitrary: `ease-[cubic-bezier(0.25,0.1,0.25,1)]`.

## Delay

`delay-0`, `delay-75`, `delay-100`, `delay-150`, `delay-200`, `delay-300`, `delay-500`, `delay-700`, `delay-1000`.

Arbitrary: `delay-[250ms]`.

## Combined Example

```html
<button class="transition-colors duration-200 ease-in-out hover:bg-blue-600">
  Click me
</button>

<!-- Animate display toggle with discrete behavior -->
<div
  class="hidden data-[open]:block transition transition-discrete duration-300"
>
  Dropdown
</div>
```

## Animation

Built-in animations:

| Class            | Effect                                  |
| ---------------- | --------------------------------------- |
| `animate-spin`   | Continuous 360° rotation                |
| `animate-ping`   | Pulse + fade (notification dot)         |
| `animate-pulse`  | Gentle opacity pulse (skeleton loading) |
| `animate-bounce` | Vertical bounce                         |
| `animate-none`   | Removes animation                       |

```html
<!-- Loading spinner -->
<svg class="animate-spin size-5 text-white" fill="none" viewBox="0 0 24 24">
  …
</svg>

<!-- Notification dot -->
<span class="relative flex size-3">
  <span
    class="animate-ping absolute inline-flex h-full w-full rounded-full bg-sky-400 opacity-75"
  ></span>
  <span class="relative inline-flex rounded-full size-3 bg-sky-500"></span>
</span>

<!-- Skeleton -->
<div class="animate-pulse bg-gray-200 rounded h-4 w-full"></div>
```

Custom animations — define in `@theme`:

```css
@theme {
  --animate-wiggle: wiggle 1s ease-in-out infinite;
  @keyframes wiggle {
    0%,
    100% {
      rotate: -3deg;
    }
    50% {
      rotate: 3deg;
    }
  }
}
```

```html
<div class="animate-wiggle">…</div>
```

## Reduced Motion

Use `motion-safe:` and `motion-reduce:` variants for accessibility:

```html
<div class="motion-safe:animate-spin motion-reduce:animate-none">…</div>
<div class="transition duration-300 motion-reduce:transition-none">…</div>
```
