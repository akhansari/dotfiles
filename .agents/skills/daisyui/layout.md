# DaisyUI Layout

## calendar

Styles for third-party calendar libraries (Cally, Pikaday, React Day Picker).
[docs](https://daisyui.com/components/calendar/)

### Class names

- `cally` — for [Cally](https://wicky.nillia.ms/cally/) web component
- `pika-single` — for [Pikaday](https://pikaday.com/) input
- `react-day-picker` — for [React DayPicker](https://daypicker.dev/)

### Syntax

Cally:

```html
<calendar-date class="cally">{CONTENT}</calendar-date>
```

Pikaday:

```html
<input type="text" class="input pika-single" />
```

React DayPicker:

```html
<DayPicker className="react-day-picker" />
```

---

## divider

Separates content vertically or horizontally with an optional label.
[docs](https://daisyui.com/components/divider/)

### Class names

- component: `divider`
- color: `divider-neutral`, `divider-primary`, `divider-secondary`, `divider-accent`, `divider-success`, `divider-warning`, `divider-info`, `divider-error`
- direction: `divider-vertical`, `divider-horizontal`
- placement: `divider-start`, `divider-end`

### Syntax

```html
<div class="divider {MODIFIER}">OR</div>
```

### Rules

- Omit text for a plain line divider

---

## fieldset

Container for grouping related form elements with a title and description.
[docs](https://daisyui.com/components/fieldset/)

### Class names

- component: `fieldset`, `label`
- part: `fieldset-legend`

### Syntax

```html
<fieldset class="fieldset">
  <legend class="fieldset-legend">Account</legend>
  <label class="input">
    <span class="label">Email</span>
    <input type="email" placeholder="user@example.com" />
  </label>
  <p class="label">Description or hint text</p>
</fieldset>
```

---

## hero

Large banner section with a title, description, and optional background image.
[docs](https://daisyui.com/components/hero/)

### Class names

- component: `hero`
- part: `hero-content`, `hero-overlay`

### Syntax

```html
<div class="hero min-h-screen" style="background-image: url({image-url})">
  <div class="hero-overlay"></div>
  <div class="hero-content text-center text-neutral-content">
    <div class="max-w-md">
      <h1 class="text-5xl font-bold">Hello there</h1>
      <p class="py-6">Description text.</p>
      <button class="btn btn-primary">Get Started</button>
    </div>
  </div>
</div>
```

### Rules

- `hero-overlay` overlays the background image with a semi-transparent color
- `hero-content` can be `text-center` or use `flex` children for side-by-side layouts

---

## join

Groups multiple items (buttons, inputs, etc.) with shared border radius.
[docs](https://daisyui.com/components/join/)

### Class names

- component: `join`, `join-item`
- direction: `join-vertical`, `join-horizontal`

### Syntax

```html
<div class="join {MODIFIER}">
  <button class="join-item btn">Left</button>
  <button class="join-item btn btn-active">Middle</button>
  <button class="join-item btn">Right</button>
</div>
```

Input group:

```html
<div class="join">
  <input class="join-item input" placeholder="Search" />
  <button class="join-item btn btn-primary">Go</button>
</div>
```

### Rules

- Any direct child of `join` is joined; use `join-item` to explicitly mark joined children
- Default direction is horizontal; add `join-vertical` for vertical stacking
- Use `lg:join-horizontal` for responsive layouts

---

## mask

Clips an element into a predefined shape.
[docs](https://daisyui.com/components/mask/)

### Class names

- component: `mask`
- style: `mask-squircle`, `mask-heart`, `mask-hexagon`, `mask-hexagon-2`, `mask-decagon`, `mask-pentagon`, `mask-diamond`, `mask-square`, `mask-circle`, `mask-star`, `mask-star-2`, `mask-triangle`, `mask-triangle-2`, `mask-triangle-3`, `mask-triangle-4`
- modifier: `mask-half-1`, `mask-half-2`

### Syntax

```html
<img class="mask mask-squircle w-24" src="{image-url}" />
```

### Rules

- A shape style class is required alongside `mask`
- Set size with `w-*` / `h-*`
- `mask-half-1` and `mask-half-2` clip to the left/right half of the shape respectively (useful for half-star ratings)

---

## text-rotate

Animates through up to 6 lines of text in an infinite loop.
[docs](https://daisyui.com/components/text-rotate/)

### Class names

- component: `text-rotate`

### Syntax

```html
<span class="text-rotate">
  <span>
    <span>Word 1</span>
    <span>Word 2</span>
    <span>Word 3</span>
  </span>
</span>
```

Inline in a sentence:

```html
<span>
  Built for
  <span class="text-rotate">
    <span>
      <span class="bg-primary text-primary-content px-2">Designers</span>
      <span class="bg-secondary text-secondary-content px-2">Developers</span>
    </span>
  </span>
</span>
```

### Rules

- Must have exactly one inner wrapper span/div containing 2–6 text spans
- Total loop duration is 10 000 ms by default
- Override with `duration-{ms}` utility (e.g. `duration-12000`)
