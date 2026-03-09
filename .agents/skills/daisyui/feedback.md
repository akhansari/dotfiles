# DaisyUI Feedback

## alert

Informs users about important events.
[docs](https://daisyui.com/components/alert/)

### Class names

- component: `alert`
- style: `alert-outline`, `alert-dash`, `alert-soft`
- color: `alert-info`, `alert-success`, `alert-warning`, `alert-error`
- direction: `alert-vertical`, `alert-horizontal`

### Syntax

```html
<div role="alert" class="alert {MODIFIER}">
  <svg>{icon}</svg>
  <span>Alert message</span>
</div>
```

### Rules

- Always add `role="alert"` for accessibility
- Use `sm:alert-horizontal` for responsive layout

---

## loading

Animated indicator for loading states.
[docs](https://daisyui.com/components/loading/)

### Class names

- component: `loading`
- style: `loading-spinner`, `loading-dots`, `loading-ring`, `loading-ball`, `loading-bars`, `loading-infinity`
- size: `loading-xs`, `loading-sm`, `loading-md`, `loading-lg`, `loading-xl`

### Syntax

```html
<span class="loading {MODIFIER}"></span>
```

---

## progress

Progress bar showing task completion or time passing.
[docs](https://daisyui.com/components/progress/)

### Class names

- component: `progress`
- color: `progress-neutral`, `progress-primary`, `progress-secondary`, `progress-accent`, `progress-info`, `progress-success`, `progress-warning`, `progress-error`

### Syntax

```html
<progress class="progress {MODIFIER}" value="50" max="100"></progress>
```

### Rules

- Must specify `value` and `max` attributes
- For indeterminate state, omit `value`

---

## radial-progress

Circular progress indicator.
[docs](https://daisyui.com/components/radial-progress/)

### Class names

- component: `radial-progress`

### Syntax

```html
<div
  class="radial-progress"
  style="--value:70;"
  aria-valuenow="70"
  role="progressbar"
>
  70%
</div>
```

### Rules

- `--value` must be 0–100
- Use `div` (not `<progress>`) because browsers cannot show text inside `<progress>`
- Required accessibility: `aria-valuenow="{value}"` and `role="progressbar"`
- `--size` sets the size (default `5rem`); `--thickness` sets the stroke width

---

## skeleton

Placeholder loading animation mimicking content shape.
[docs](https://daisyui.com/components/skeleton/)

### Class names

- component: `skeleton`

### Syntax

```html
<div class="skeleton h-32 w-32"></div>
```

### Rules

- Apply `skeleton` to the placeholder element and size it with `h-*` / `w-*`
- Can be shaped using `rounded-*` classes

---

## toast

Stacks notification elements in a corner of the page.
[docs](https://daisyui.com/components/toast/)

### Class names

- component: `toast`
- placement: `toast-start`, `toast-center`, `toast-end`, `toast-top`, `toast-middle`, `toast-bottom`

### Syntax

```html
<div class="toast toast-end toast-bottom">
  <div class="alert alert-success"><span>Message sent!</span></div>
  <div class="alert alert-error"><span>Error occurred.</span></div>
</div>
```

### Rules

- Default position is bottom-end
- Nest `alert` components inside `toast` for styled notifications
