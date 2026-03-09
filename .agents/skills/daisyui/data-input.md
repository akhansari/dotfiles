# DaisyUI Data Input

## checkbox

Checkbox for selecting or deselecting a value.
[docs](https://daisyui.com/components/checkbox/)

### Class names

- component: `checkbox`
- color: `checkbox-primary`, `checkbox-secondary`, `checkbox-accent`, `checkbox-neutral`, `checkbox-success`, `checkbox-warning`, `checkbox-info`, `checkbox-error`
- size: `checkbox-xs`, `checkbox-sm`, `checkbox-md`, `checkbox-lg`, `checkbox-xl`

### Syntax

```html
<input type="checkbox" class="checkbox {MODIFIER}" />
```

---

## file-input

Input field for uploading files.
[docs](https://daisyui.com/components/file-input/)

### Class names

- component: `file-input`
- style: `file-input-ghost`
- color: `file-input-neutral`, `file-input-primary`, `file-input-secondary`, `file-input-accent`, `file-input-info`, `file-input-success`, `file-input-warning`, `file-input-error`
- size: `file-input-xs`, `file-input-sm`, `file-input-md`, `file-input-lg`, `file-input-xl`

### Syntax

```html
<input type="file" class="file-input {MODIFIER}" />
```

---

## filter

Group of radio buttons where selecting one hides the others and shows a reset button.
[docs](https://daisyui.com/components/filter/)

### Class names

- component: `filter`
- part: `filter-reset`

### Syntax

```html
<form class="filter">
  <input class="btn btn-square" type="reset" value="×" />
  <input class="btn" type="radio" name="{NAME}" aria-label="All" />
  <input class="btn" type="radio" name="{NAME}" aria-label="Popular" />
  <input class="btn" type="radio" name="{NAME}" aria-label="Recent" />
</form>
```

Without `<form>`:

```html
<div class="filter">
  <input class="btn filter-reset" type="radio" name="{NAME}" aria-label="×" />
  <input class="btn" type="radio" name="{NAME}" aria-label="All" />
</div>
```

### Rules

- Prefer `<form>` tag; use `<div>` only when a form element is not possible
- Each filter group needs a unique `name`
- Use `filter-reset` class on the reset button when not using `<form>`

---

## input

Text input field.
[docs](https://daisyui.com/components/input/)

### Class names

- component: `input`
- style: `input-ghost`
- color: `input-neutral`, `input-primary`, `input-secondary`, `input-accent`, `input-info`, `input-success`, `input-warning`, `input-error`
- size: `input-xs`, `input-sm`, `input-md`, `input-lg`, `input-xl`

### Syntax

```html
<input type="text" placeholder="Type here" class="input {MODIFIER}" />
```

Input with icon/prefix inside:

```html
<label class="input {MODIFIER}">
  <svg>{icon}</svg>
  <input type="text" placeholder="Search" />
</label>
```

### Rules

- Use `input` on the wrapper `<label>` when nesting icons or other elements alongside the input
- Works with any input type: text, password, email, number, etc.

---

## label

Provides a name or description for form fields.
[docs](https://daisyui.com/components/label/)

### Class names

- component: `label`, `floating-label`

### Syntax

Regular label:

```html
<label class="input {MODIFIER}">
  <span class="label">Username</span>
  <input type="text" placeholder="Type here" />
</label>
```

Floating label:

```html
<label class="floating-label">
  <input type="text" placeholder="Username" class="input" />
  <span>Username</span>
</label>
```

### Rules

- `input` class goes on the wrapper element, not on the label itself
- `floating-label` wraps the input first, then the span (span floats above input on focus)

---

## radio

Radio button for selecting one option from a group.
[docs](https://daisyui.com/components/radio/)

### Class names

- component: `radio`
- color: `radio-neutral`, `radio-primary`, `radio-secondary`, `radio-accent`, `radio-success`, `radio-warning`, `radio-info`, `radio-error`
- size: `radio-xs`, `radio-sm`, `radio-md`, `radio-lg`, `radio-xl`

### Syntax

```html
<input type="radio" name="{name}" class="radio {MODIFIER}" />
```

### Rules

- All radios in a group must share the same `name`
- Use different `name` values for independent groups on the same page

---

## range

Slider for selecting a value by dragging a handle.
[docs](https://daisyui.com/components/range/)

### Class names

- component: `range`
- color: `range-neutral`, `range-primary`, `range-secondary`, `range-accent`, `range-success`, `range-warning`, `range-info`, `range-error`
- size: `range-xs`, `range-sm`, `range-md`, `range-lg`, `range-xl`

### Syntax

```html
<input type="range" min="0" max="100" value="40" class="range {MODIFIER}" />
```

### Rules

- Must specify `min` and `max` attributes

---

## rating

A set of radio inputs styled as star ratings.
[docs](https://daisyui.com/components/rating/)

### Class names

- component: `rating`
- modifier: `rating-half`, `rating-hidden`
- size: `rating-xs`, `rating-sm`, `rating-md`, `rating-lg`, `rating-xl`

### Syntax

```html
<div class="rating {MODIFIER}">
  <input type="radio" name="rating-1" class="rating-hidden" />
  <input type="radio" name="rating-1" class="mask mask-star" />
  <input type="radio" name="rating-1" class="mask mask-star" />
  <input type="radio" name="rating-1" class="mask mask-star" checked />
  <input type="radio" name="rating-1" class="mask mask-star" />
  <input type="radio" name="rating-1" class="mask mask-star" />
</div>
```

### Rules

- Each rating group needs a unique `name`
- Add `rating-hidden` to the first radio so users can clear the selection
- Use `mask-star-2` for filled stars; `mask-star` for outlined

---

## select

Dropdown for picking a value from a list.
[docs](https://daisyui.com/components/select/)

### Class names

- component: `select`
- style: `select-ghost`
- color: `select-neutral`, `select-primary`, `select-secondary`, `select-accent`, `select-info`, `select-success`, `select-warning`, `select-error`
- size: `select-xs`, `select-sm`, `select-md`, `select-lg`, `select-xl`

### Syntax

```html
<select class="select {MODIFIER}">
  <option disabled selected>Pick a color</option>
  <option>Red</option>
  <option>Blue</option>
</select>
```

---

## textarea

Multi-line text input.
[docs](https://daisyui.com/components/textarea/)

### Class names

- component: `textarea`
- style: `textarea-ghost`
- color: `textarea-neutral`, `textarea-primary`, `textarea-secondary`, `textarea-accent`, `textarea-info`, `textarea-success`, `textarea-warning`, `textarea-error`
- size: `textarea-xs`, `textarea-sm`, `textarea-md`, `textarea-lg`, `textarea-xl`

### Syntax

```html
<textarea class="textarea {MODIFIER}" placeholder="Bio"></textarea>
```

---

## toggle

Checkbox styled as a switch button.
[docs](https://daisyui.com/components/toggle/)

### Class names

- component: `toggle`
- color: `toggle-primary`, `toggle-secondary`, `toggle-accent`, `toggle-neutral`, `toggle-success`, `toggle-warning`, `toggle-info`, `toggle-error`
- size: `toggle-xs`, `toggle-sm`, `toggle-md`, `toggle-lg`, `toggle-xl`

### Syntax

```html
<input type="checkbox" class="toggle {MODIFIER}" />
```

---

## validator

Changes form element color to error/success based on HTML validation rules.
[docs](https://daisyui.com/components/validator/)

### Class names

- component: `validator`
- part: `validator-hint`

### Syntax

```html
<input type="email" class="input validator" required />
<p class="validator-hint">Must be a valid email address</p>
```

### Rules

- `validator` reads the browser's native validation state (`:valid` / `:invalid`)
- `validator-hint` shows the error hint — hidden when input is valid, visible on invalid
- Works with any input that supports HTML validation attributes (`required`, `minlength`, `pattern`, etc.)
