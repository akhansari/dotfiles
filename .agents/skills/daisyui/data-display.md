# DaisyUI Data Display

## accordion

Shows and hides content; only one item open at a time.
[docs](https://daisyui.com/components/accordion/)

### Class names

- component: `collapse`
- part: `collapse-title`, `collapse-content`
- modifier: `collapse-arrow`, `collapse-plus`, `collapse-open`, `collapse-close`

### Syntax

```html
<div class="collapse {MODIFIER}">
  <input type="radio" name="{name}" checked="{checked}" />
  <div class="collapse-title">{title}</div>
  <div class="collapse-content">{CONTENT}</div>
</div>
```

### Rules

- Uses radio inputs — all radios with the same `name` work as a group (only one open)
- Use different `name` values for multiple independent accordion groups on the same page
- Use `checked="checked"` on a radio to open that item by default

---

## avatar

Shows a user thumbnail.
[docs](https://daisyui.com/components/avatar/)

### Class names

- component: `avatar`, `avatar-group`
- modifier: `avatar-online`, `avatar-offline`, `avatar-placeholder`

### Syntax

```html
<div class="avatar {MODIFIER}">
  <div>
    <img src="{image-url}" />
  </div>
</div>
```

### Rules

- Use `avatar-group` to wrap multiple avatars
- Set size via `w-*` and `h-*` utilities
- Use mask classes for shapes: `mask-squircle`, `mask-hexagon`, `mask-triangle`

---

## badge

Communicates status or metadata inline.
[docs](https://daisyui.com/components/badge/)

### Class names

- component: `badge`
- style: `badge-outline`, `badge-dash`, `badge-soft`, `badge-ghost`
- color: `badge-neutral`, `badge-primary`, `badge-secondary`, `badge-accent`, `badge-info`, `badge-success`, `badge-warning`, `badge-error`
- size: `badge-xs`, `badge-sm`, `badge-md`, `badge-lg`, `badge-xl`

### Syntax

```html
<span class="badge {MODIFIER}">Badge</span>
```

### Rules

- Can be embedded inside text or buttons
- Empty badge (dot): remove the text content

---

## card

Groups and displays content with optional image.
[docs](https://daisyui.com/components/card/)

### Class names

- component: `card`
- part: `card-title`, `card-body`, `card-actions`
- style: `card-border`, `card-dash`
- modifier: `card-side`, `image-full`
- size: `card-xs`, `card-sm`, `card-md`, `card-lg`, `card-xl`

### Syntax

```html
<div class="card {MODIFIER}">
  <figure><img src="{image-url}" alt="{alt-text}" /></figure>
  <div class="card-body">
    <h2 class="card-title">{title}</h2>
    <p>{CONTENT}</p>
    <div class="card-actions">{actions}</div>
  </div>
</div>
```

### Rules

- `<figure>` and `card-body` are optional
- Use `sm:card-side` for responsive horizontal layout
- Image placed after `card-body` renders at the bottom

---

## carousel

Scrollable area for images or content.
[docs](https://daisyui.com/components/carousel/)

### Class names

- component: `carousel`
- part: `carousel-item`
- modifier: `carousel-start`, `carousel-center`, `carousel-end`
- direction: `carousel-horizontal`, `carousel-vertical`

### Syntax

```html
<div class="carousel {MODIFIER}">
  <div class="carousel-item">{ITEM}</div>
  <div class="carousel-item">{ITEM}</div>
</div>
```

### Rules

- Add `w-full` to each `carousel-item` for a full-width carousel

---

## chat

Chat bubble showing a message with author info.
[docs](https://daisyui.com/components/chat/)

### Class names

- component: `chat`
- part: `chat-image`, `chat-header`, `chat-footer`, `chat-bubble`
- placement: `chat-start`, `chat-end`
- color: `chat-bubble-neutral`, `chat-bubble-primary`, `chat-bubble-secondary`, `chat-bubble-accent`, `chat-bubble-info`, `chat-bubble-success`, `chat-bubble-warning`, `chat-bubble-error`

### Syntax

```html
<div class="chat {PLACEMENT}">
  <div class="chat-image"></div>
  <div class="chat-header"></div>
  <div class="chat-bubble {COLOR}">Message text</div>
  <div class="chat-footer"></div>
</div>
```

### Rules

- `{PLACEMENT}` is required: `chat-start` or `chat-end`
- For an avatar, use `<div class="chat-image avatar">` with avatar content inside

---

## collapse

Shows and hides content (single item, not accordion).
[docs](https://daisyui.com/components/collapse/)

### Class names

- component: `collapse`
- part: `collapse-title`, `collapse-content`
- modifier: `collapse-arrow`, `collapse-plus`, `collapse-open`, `collapse-close`

### Syntax

```html
<div tabindex="0" class="collapse {MODIFIER}">
  <div class="collapse-title">{title}</div>
  <div class="collapse-content">{CONTENT}</div>
</div>
```

### Rules

- Use `tabindex="0"` or a `<input type="checkbox">` as first child to toggle
- Can also use `<details>` / `<summary>` tags

---

## countdown

Animated number transition (0–999).
[docs](https://daisyui.com/components/countdown/)

### Class names

- component: `countdown`

### Syntax

```html
<span class="countdown">
  <span style="--value:{number};">{number}</span>
</span>
```

### Rules

- `--value` and text content must be a number between 0 and 999
- Update both `--value` and the text via JS to animate
- Add `aria-live="polite"` and `aria-label="{number}"` for accessibility

---

## diff

Side-by-side comparison of two items with a draggable resizer.
[docs](https://daisyui.com/components/diff/)

### Class names

- component: `diff`
- part: `diff-item-1`, `diff-item-2`, `diff-resizer`

### Syntax

```html
<figure class="diff">
  <div class="diff-item-1">{item1}</div>
  <div class="diff-item-2">{item2}</div>
  <div class="diff-resizer"></div>
</figure>
```

### Rules

- Add `aspect-16/9` (or other aspect ratio class) to `<figure>` to maintain ratio

---

## hover-3d

Wrapper that adds an interactive 3D tilt effect on mouse hover.
[docs](https://daisyui.com/components/hover-3d/)

### Class names

- component: `hover-3d`

### Syntax

```html
<div class="hover-3d my-12 mx-2">
  <!-- first child: main content -->
  <figure class="max-w-100 rounded-2xl">
    <img src="{image-url}" alt="{alt}" />
  </figure>
  <!-- exactly 8 empty divs for hover zones -->
  <div></div>
  <div></div>
  <div></div>
  <div></div>
  <div></div>
  <div></div>
  <div></div>
  <div></div>
</div>
```

### Rules

- Must have **exactly 9** direct children: first is main content, remaining 8 are empty hover-zone divs
- Content inside must be non-interactive (no buttons, links, inputs)
- Can use `<a>` as the wrapper element if the whole card should be a link

---

## hover-gallery

Image gallery that reveals additional images on horizontal hover.
[docs](https://daisyui.com/components/hover-gallery/)

### Class names

- component: `hover-gallery`

### Syntax

```html
<figure class="hover-gallery max-w-60">
  <img src="{image-1}" />
  <img src="{image-2}" />
  <img src="{image-3}" />
</figure>
```

### Rules

- Can be a `<div>` or `<figure>`
- Supports up to 10 images
- Requires a `max-width` — otherwise fills the container
- All images must be the same dimensions

---

## indicator

Positions a small element on the corner of another element.
[docs](https://daisyui.com/components/indicator/)

### Class names

- component: `indicator`
- part: `indicator-item`
- placement: `indicator-start`, `indicator-center`, `indicator-end`, `indicator-top`, `indicator-middle`, `indicator-bottom`

### Syntax

```html
<div class="indicator">
  <span class="indicator-item {PLACEMENT}">{indicator content}</span>
  <div>{main content}</div>
</div>
```

### Rules

- Place all `indicator-item` elements **before** the main content
- Default placement is `indicator-end indicator-top`

---

## kbd

Displays keyboard shortcut keys.
[docs](https://daisyui.com/components/kbd/)

### Class names

- component: `kbd`
- size: `kbd-xs`, `kbd-sm`, `kbd-md`, `kbd-lg`, `kbd-xl`

### Syntax

```html
<kbd class="kbd {MODIFIER}">K</kbd>
```

---

## list

Vertical layout for displaying information in rows.
[docs](https://daisyui.com/components/list/)

### Class names

- component: `list`, `list-row`
- modifier: `list-col-wrap`, `list-col-grow`

### Syntax

```html
<ul class="list">
  <li class="list-row">{CONTENT}</li>
</ul>
```

### Rules

- By default the second child of `list-row` fills remaining space
- Use `list-col-grow` on another child to override which one fills space
- Use `list-col-wrap` to force an item to wrap to the next line

---

## stat

Displays a single statistic with optional label, description, and figure.
[docs](https://daisyui.com/components/stat/)

### Class names

- component: `stats`
- part: `stat`, `stat-title`, `stat-value`, `stat-desc`, `stat-figure`, `stat-actions`
- direction: `stats-horizontal`, `stats-vertical`

### Syntax

```html
<div class="stats {MODIFIER}">
  <div class="stat">
    <div class="stat-figure">{icon}</div>
    <div class="stat-title">{label}</div>
    <div class="stat-value">{value}</div>
    <div class="stat-desc">{description}</div>
  </div>
</div>
```

### Rules

- Wrap multiple `stat` items inside `stats`
- Use `sm:stats-horizontal` for responsive layouts

---

## table

Styled HTML table.
[docs](https://daisyui.com/components/table/)

### Class names

- component: `table`
- modifier: `table-zebra`, `table-pin-rows`, `table-pin-cols`
- size: `table-xs`, `table-sm`, `table-md`, `table-lg`, `table-xl`

### Syntax

```html
<div class="overflow-x-auto">
  <table class="table {MODIFIER}">
    <thead>
      <tr>
        <th></th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <th></th>
      </tr>
    </tbody>
  </table>
</div>
```

### Rules

- Wrap in `overflow-x-auto` to make it horizontally scrollable on small screens

---

## timeline

Displays events in chronological order.
[docs](https://daisyui.com/components/timeline/)

### Class names

- component: `timeline`
- part: `timeline-start`, `timeline-middle`, `timeline-end`
- modifier: `timeline-snap-icon`, `timeline-box`, `timeline-compact`
- direction: `timeline-vertical`, `timeline-horizontal`

### Syntax

```html
<ul class="timeline {MODIFIER}">
  <li>
    <div class="timeline-start">{start}</div>
    <div class="timeline-middle">{icon}</div>
    <div class="timeline-end timeline-box">{end}</div>
    <hr />
  </li>
</ul>
```

### Rules

- Default direction is vertical — `timeline-vertical` is optional
- `timeline-snap-icon` snaps the icon to the start instead of center
- `timeline-compact` forces all items to one side
