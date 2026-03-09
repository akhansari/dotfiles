# DaisyUI Navigation

## breadcrumbs

Helps users understand their location in the hierarchy.
[docs](https://daisyui.com/components/breadcrumbs/)

### Class names

- component: `breadcrumbs`

### Syntax

```html
<div class="breadcrumbs">
  <ul>
    <li><a>Home</a></li>
    <li><a>Section</a></li>
    <li>Current</li>
  </ul>
</div>
```

### Rules

- Can contain icons inside links
- If the list exceeds the container width it will scroll

---

## dock

Bottom navigation bar that sticks to the bottom of the screen.
[docs](https://daisyui.com/components/dock/)

### Class names

- component: `dock`
- part: `dock-label`
- modifier: `dock-active`
- size: `dock-xs`, `dock-sm`, `dock-md`, `dock-lg`, `dock-xl`

### Syntax

```html
<div class="dock {MODIFIER}">
  <button type="button" class="dock-active">
    <svg>{icon}</svg>
    <span class="dock-label">Home</span>
  </button>
  <button type="button">
    <svg>{icon}</svg>
    <span class="dock-label">Search</span>
  </button>
</div>
```

### Rules

- Add `dock-active` to the active button
- Add `<meta name="viewport" content="viewport-fit=cover">` for proper iOS safe area handling

---

## drawer

Grid layout that shows/hides a sidebar on the left or right.
[docs](https://daisyui.com/components/drawer/)

### Class names

- component: `drawer`
- part: `drawer-toggle`, `drawer-content`, `drawer-side`, `drawer-overlay`
- placement: `drawer-end`
- modifier: `drawer-open`
- variant: `is-drawer-open:`, `is-drawer-close:`

### Syntax

```html
<div class="drawer lg:drawer-open">
  <input id="my-drawer" type="checkbox" class="drawer-toggle" />
  <div class="drawer-content">
    <!-- Page content (navbar, main, footer, etc.) -->
    <label for="my-drawer" class="btn drawer-button lg:hidden">Open</label>
  </div>
  <div class="drawer-side">
    <label
      for="my-drawer"
      aria-label="close sidebar"
      class="drawer-overlay"
    ></label>
    <ul class="menu bg-base-200 min-h-full w-80 p-4">
      <li><button type="button">Item 1</button></li>
      <li><button type="button">Item 2</button></li>
    </ul>
  </div>
</div>
```

Icon-only collapsed / full expanded sidebar:

```html
<div class="drawer lg:drawer-open">
  <input id="my-drawer-4" type="checkbox" class="drawer-toggle" />
  <div class="drawer-content"><!-- page --></div>
  <div class="drawer-side is-drawer-close:overflow-visible">
    <label
      for="my-drawer-4"
      aria-label="close sidebar"
      class="drawer-overlay"
    ></label>
    <div
      class="is-drawer-close:w-14 is-drawer-open:w-64 bg-base-200 flex flex-col items-start min-h-full"
    >
      <ul class="menu w-full grow">
        <li>
          <button
            type="button"
            class="is-drawer-close:tooltip is-drawer-close:tooltip-right"
            data-tip="Home"
          >
            🏠<span class="is-drawer-close:hidden">Home</span>
          </button>
        </li>
      </ul>
    </div>
  </div>
</div>
```

### Rules

- The `drawer-toggle` input is a hidden checkbox; use `<label for="{id}">` to toggle
- **All** page content must be inside `drawer-content` (navbar, footer, main)
- `lg:drawer-open` makes the sidebar always visible on large screens
- `drawer-end` moves the sidebar to the right side

---

## footer

Page footer with logo, copyright, and navigation links.
[docs](https://daisyui.com/components/footer/)

### Class names

- component: `footer`
- part: `footer-title`
- placement: `footer-center`
- direction: `footer-horizontal`, `footer-vertical`

### Syntax

```html
<footer class="footer bg-base-200 p-10">
  <nav>
    <h6 class="footer-title">Services</h6>
    <a class="link link-hover">Branding</a>
    <a class="link link-hover">Design</a>
  </nav>
  <nav>
    <h6 class="footer-title">Company</h6>
    <a class="link link-hover">About</a>
  </nav>
</footer>
```

### Rules

- Use `sm:footer-horizontal` for responsive layout
- Use `base-200` for background color

---

## link

Adds underline styling to anchor tags.
[docs](https://daisyui.com/components/link/)

### Class names

- component: `link`
- style: `link-hover`
- color: `link-neutral`, `link-primary`, `link-secondary`, `link-accent`, `link-success`, `link-info`, `link-warning`, `link-error`

### Syntax

```html
<a class="link {MODIFIER}">Click me</a>
```

### Rules

- `link-hover` only shows underline on hover (default shows always)

---

## menu

Vertical or horizontal list of navigation links.
[docs](https://daisyui.com/components/menu/)

### Class names

- component: `menu`
- part: `menu-title`, `menu-dropdown`, `menu-dropdown-toggle`
- modifier: `menu-disabled`, `menu-active`, `menu-focus`, `menu-dropdown-show`
- size: `menu-xs`, `menu-sm`, `menu-md`, `menu-lg`, `menu-xl`
- direction: `menu-vertical`, `menu-horizontal`

### Syntax

```html
<ul class="menu {MODIFIER}">
  <li><button type="button">Item</button></li>
  <li>
    <details>
      <summary>Parent</summary>
      <ul>
        <li><button type="button">Child</button></li>
      </ul>
    </details>
  </li>
</ul>
```

### Rules

- Use `lg:menu-horizontal` for responsive navigation
- Use `<details>` for collapsible submenus
- Use `menu-title` for non-interactive section headers
- Use `menu-dropdown` and `menu-dropdown-toggle` to control submenus via JS

---

## navbar

Navigation bar at the top of the page.
[docs](https://daisyui.com/components/navbar/)

### Class names

- component: `navbar`
- part: `navbar-start`, `navbar-center`, `navbar-end`

### Syntax

```html
<div class="navbar bg-base-200">
  <div class="navbar-start">
    <a class="btn btn-ghost text-xl">Logo</a>
  </div>
  <div class="navbar-center">
    <ul class="menu menu-horizontal">
      <li><button type="button">Link</button></li>
    </ul>
  </div>
  <div class="navbar-end">
    <button type="button" class="btn btn-primary">Action</button>
  </div>
</div>
```

### Rules

- Use `navbar-start`, `navbar-center`, `navbar-end` to position content
- Use `base-200` for background color

---

## pagination

Group of buttons for page navigation.
[docs](https://daisyui.com/components/pagination/)

### Class names

- Uses `join` and `join-item` (see Layout > join)

### Syntax

```html
<div class="join">
  <button type="button" class="join-item btn">«</button>
  <button type="button" class="join-item btn btn-active">1</button>
  <button type="button" class="join-item btn">2</button>
  <button type="button" class="join-item btn">3</button>
  <button type="button" class="join-item btn">»</button>
</div>
```

### Rules

- Use `btn-active` for the current page button

---

## steps

Shows a sequence of steps in a process.
[docs](https://daisyui.com/components/steps/)

### Class names

- component: `steps`
- part: `step`
- color: `step-neutral`, `step-primary`, `step-secondary`, `step-accent`, `step-info`, `step-success`, `step-warning`, `step-error`
- direction: `steps-horizontal`, `steps-vertical`

### Syntax

```html
<ul class="steps {MODIFIER}">
  <li class="step step-primary">Register</li>
  <li class="step step-primary">Choose plan</li>
  <li class="step">Purchase</li>
  <li class="step">Receive Product</li>
</ul>
```

### Rules

- Apply a color class to `step` to mark it as completed/active
- Add `data-content="{text}"` to customize the step marker text

---

## tab

Tabs to switch between sections of content.
[docs](https://daisyui.com/components/tab/)

### Class names

- component: `tabs`
- part: `tab`, `tab-content`
- style: `tabs-border`, `tabs-lift`, `tabs-box`
- modifier: `tab-active`, `tab-disabled`
- size: `tabs-xs`, `tabs-sm`, `tabs-md`, `tabs-lg`, `tabs-xl`

### Syntax

Radio-based tabs (no JS required):

```html
<div class="tabs tabs-lift">
  <label class="tab">
    <input type="radio" name="tabs" checked />
    Tab 1
  </label>
  <div class="tab-content">{CONTENT 1}</div>

  <label class="tab">
    <input type="radio" name="tabs" />
    Tab 2
  </label>
  <div class="tab-content">{CONTENT 2}</div>
</div>
```

### Rules

- All radio inputs in a tab group must share the same `name`
- `tab-content` follows immediately after its `tab` label
- Use `checked` on the default active tab
