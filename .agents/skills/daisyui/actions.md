# DaisyUI Actions

## button

Buttons allow the user to take actions.
[docs](https://daisyui.com/components/button/)

### Class names

- component: `btn`
- color: `btn-neutral`, `btn-primary`, `btn-secondary`, `btn-accent`, `btn-info`, `btn-success`, `btn-warning`, `btn-error`
- style: `btn-outline`, `btn-dash`, `btn-soft`, `btn-ghost`, `btn-link`
- behavior: `btn-active`, `btn-disabled`
- size: `btn-xs`, `btn-sm`, `btn-md`, `btn-lg`, `btn-xl`
- modifier: `btn-wide`, `btn-block`, `btn-square`, `btn-circle`

### Syntax

```html
<button type="button" class="btn {MODIFIER}">Button</button>
```

### Rules

- `btn` works on any tag: `<button>`, `<a>`, `<input>`
- Can contain an icon before or after the text
- To disable via class: set `tabindex="-1" role="button" aria-disabled="true"`

---

## dropdown

Dropdown opens a menu or any element when a button is clicked.
[docs](https://daisyui.com/components/dropdown/)

### Class names

- component: `dropdown`
- part: `dropdown-content`
- placement: `dropdown-start`, `dropdown-center`, `dropdown-end`, `dropdown-top`, `dropdown-bottom`, `dropdown-left`, `dropdown-right`
- modifier: `dropdown-hover`, `dropdown-open`, `dropdown-close`

### Syntax

Using `<details>` / `<summary>` (recommended):

```html
<details class="dropdown">
  <summary>Button</summary>
  <ul class="dropdown-content">
    {CONTENT}
  </ul>
</details>
```

Using Popover API:

```html
<button type="button" popovertarget="{id}" style="anchor-name:--{anchor}">
  {button}
</button>
<ul
  class="dropdown-content"
  popover
  id="{id}"
  style="position-anchor:--{anchor}"
>
  {CONTENT}
</ul>
```

Using CSS focus:

```html
<div class="dropdown">
  <div tabindex="0" role="button">Button</div>
  <ul tabindex="-1" class="dropdown-content">
    {CONTENT}
  </ul>
</div>
```

### Rules

- Replace `{id}` and `{anchor}` with unique names when using the Popover API
- For CSS focus dropdowns, use `tabindex="0"` and `role="button"` on the trigger
- Content can be any HTML element, not just `<ul>`

---

## fab

FAB (Floating Action Button) stays in the bottom corner of the screen. Clicking or focusing it shows additional speed-dial buttons.
[docs](https://daisyui.com/components/fab/)

### Class names

- component: `fab`
- part: `fab-close`, `fab-main-action`
- modifier: `fab-flower`

### Syntax

Single FAB:

```html
<div class="fab">
  <button type="button" class="btn btn-lg btn-circle">{Icon}</button>
</div>
```

FAB with speed-dial (vertical):

```html
<div class="fab">
  <div tabindex="0" role="button" class="btn btn-lg btn-circle btn-primary">
    {IconOriginal}
  </div>
  <button type="button" class="btn btn-lg btn-circle">{Icon1}</button>
  <button type="button" class="btn btn-lg btn-circle">{Icon2}</button>
  <button type="button" class="btn btn-lg btn-circle">{Icon3}</button>
</div>
```

FAB with close button:

```html
<div class="fab">
  <div tabindex="0" role="button" class="btn btn-lg btn-circle btn-primary">
    {IconOriginal}
  </div>
  <div class="fab-close">
    Close <span class="btn btn-circle btn-lg btn-error">✕</span>
  </div>
  <div>
    {Label1}<button type="button" class="btn btn-lg btn-circle">{Icon1}</button>
  </div>
</div>
```

FAB flower (quarter-circle layout):

```html
<div class="fab fab-flower">
  <div tabindex="0" role="button" class="btn btn-lg btn-circle btn-primary">
    {IconOriginal}
  </div>
  <button type="button" class="fab-main-action btn btn-circle btn-lg">
    {IconMainAction}
  </button>
  <button type="button" class="btn btn-lg btn-circle">{Icon1}</button>
  <button type="button" class="btn btn-lg btn-circle">{Icon2}</button>
</div>
```

### Rules

- `fab-flower` opens buttons in a quarter-circle arrangement instead of vertical — use tooltips for labels
- `fab-close` replaces the original button with a close button when FAB is open
- `fab-main-action` replaces the original button with a primary action button when open
- SVG icons are recommended for `{Icon*}` placeholders

---

## modal

Modal shows a dialog box when triggered.
[docs](https://daisyui.com/components/modal/)

### Class names

- component: `modal`
- part: `modal-box`, `modal-action`, `modal-backdrop`, `modal-toggle`
- modifier: `modal-open`
- placement: `modal-top`, `modal-middle`, `modal-bottom`, `modal-start`, `modal-end`

### Syntax

Using HTML `<dialog>` (recommended):

```html
<button type="button" onclick="my_modal.showModal()">Open modal</button>
<dialog id="my_modal" class="modal">
  <div class="modal-box">{CONTENT}</div>
  <form method="dialog" class="modal-backdrop"><button>close</button></form>
</dialog>
```

Using checkbox (legacy):

```html
<label for="my-modal" class="btn">Open modal</label>
<input type="checkbox" id="my-modal" class="modal-toggle" />
<div class="modal">
  <div class="modal-box">{CONTENT}</div>
  <label class="modal-backdrop" for="my-modal">Close</label>
</div>
```

### Rules

- Prefer `<dialog>` element approach
- Use unique IDs for each modal
- Add `<form method="dialog">` inside the dialog to close it on submit
- Add `tabindex="0"` to make the modal focusable

---

## swap

Swap toggles the visibility of two elements using a checkbox.
[docs](https://daisyui.com/components/swap/)

### Class names

- component: `swap`
- part: `swap-on`, `swap-off`, `swap-indeterminate`
- modifier: `swap-active`
- style: `swap-rotate`, `swap-flip`

### Syntax

```html
<label class="swap {MODIFIER}">
  <input type="checkbox" />
  <div class="swap-on">{ON_CONTENT}</div>
  <div class="swap-off">{OFF_CONTENT}</div>
</label>
```

### Rules

- `swap-on` is shown when the checkbox is checked; `swap-off` when unchecked
- `swap-indeterminate` is shown when the checkbox is indeterminate
- Add `swap-rotate` or `swap-flip` for transition animations
- Can be used for theme toggles, play/pause buttons, hamburger menus, etc.
