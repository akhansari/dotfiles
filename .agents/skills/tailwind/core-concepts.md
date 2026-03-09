# Core Concepts

## Utility-first

Every utility applies one CSS property. Instead of naming abstractions, compose utilities directly in HTML.

```html
<button
  class="bg-sky-500 hover:bg-sky-700 text-white font-semibold px-4 py-2 rounded"
>
  Save
</button>
```

Prefer real HTML elements over `before:`/`after:` pseudo-elements when possible — they're easier to read and select.

## Variant syntax

`{variant}:{utility}` — apply a utility conditionally.

```html
<button
  class="bg-violet-500 hover:bg-violet-600 focus:outline-2 active:bg-violet-700"
></button>
```

## Pseudo-class variants

| Variant          | CSS                          |
| ---------------- | ---------------------------- |
| `hover:`         | `:hover`                     |
| `focus:`         | `:focus`                     |
| `focus-within:`  | `:focus-within`              |
| `focus-visible:` | `:focus-visible`             |
| `active:`        | `:active`                    |
| `visited:`       | `:visited`                   |
| `disabled:`      | `:disabled`                  |
| `required:`      | `:required`                  |
| `invalid:`       | `:invalid`                   |
| `checked:`       | `:checked`                   |
| `indeterminate:` | `:indeterminate`             |
| `read-only:`     | `:read-only`                 |
| `first:`         | `:first-child`               |
| `last:`          | `:last-child`                |
| `only:`          | `:only-child`                |
| `odd:`           | `:nth-child(odd)`            |
| `even:`          | `:nth-child(even)`           |
| `first-of-type:` | `:first-of-type`             |
| `last-of-type:`  | `:last-of-type`              |
| `only-of-type:`  | `:only-of-type`              |
| `empty:`         | `:empty`                     |
| `open:`          | `:is([open], :popover-open)` |
| `inert:`         | `[inert]`                    |

### nth-\* variants

```html
<div class="nth-3:underline">...</div>
<div class="nth-last-5:underline">...</div>
<div class="nth-of-type-4:underline">...</div>
<div class="nth-last-of-type-6:underline">...</div>
<!-- Arbitrary: -->
<div class="nth-[2n+1_of_li]:underline">...</div>
```

### has-\* variant

Style an element based on state/content of its descendants:

```html
<label class="has-checked:bg-indigo-50 has-checked:ring-indigo-200">
  <input type="radio" class="checked:border-indigo-500" />
</label>
```

### not-\* variant

Style when a condition is NOT true:

```html
<!-- Only show hover when not focused -->
<button class="hover:not-focus:bg-indigo-700">...</button>
<!-- Only when feature is not supported -->
<div class="not-supports-[display:grid]:flex">...</div>
```

## group / peer

### group

Mark parent with `group`, style children with `group-{variant}:`:

```html
<a class="group">
  <h3 class="group-hover:text-white">Title</h3>
  <p class="group-hover:text-white">Body</p>
</a>
```

**Named groups** — for nested groups:

```html
<li class="group/item">
  <a class="group/edit invisible group-hover/item:visible">
    <span class="group-hover/edit:text-gray-700">Edit</span>
  </a>
</li>
```

**Arbitrary groups:**

```html
<div class="group is-published">
  <div class="hidden group-[.is-published]:block">Published</div>
</div>
```

### peer

Mark sibling with `peer`, style later siblings with `peer-{variant}:`. The `peer` marker only works on **previous** siblings.

```html
<input type="email" class="peer" />
<p class="invisible peer-invalid:visible text-red-500">Invalid email</p>
```

**Named peers:**

```html
<input id="draft" class="peer/draft" type="radio" />
<input id="published" class="peer/published" type="radio" />
<div class="hidden peer-checked/draft:block">Draft info</div>
<div class="hidden peer-checked/published:block">Published info</div>
```

### in-\* (implicit group)

Like `group-*` but without needing to add `group` to the parent. Responds to any parent:

```html
<div tabindex="0">
  <div class="opacity-50 in-focus:opacity-100">...</div>
</div>
```

### group-has-_ / peer-has-_

Style based on descendants of a group/peer:

```html
<div class="group">
  <svg class="hidden group-has-[a]:block">...</svg>
  <p>Text with <a href="#">a link</a></p>
</div>
```

## Pseudo-element variants

| Variant         | Pseudo-element                  |
| --------------- | ------------------------------- |
| `before:`       | `::before` (auto `content: ''`) |
| `after:`        | `::after` (auto `content: ''`)  |
| `placeholder:`  | `::placeholder`                 |
| `file:`         | `::file-selector-button`        |
| `marker:`       | `::marker` (inheritable)        |
| `selection:`    | `::selection` (inheritable)     |
| `first-line:`   | `::first-line`                  |
| `first-letter:` | `::first-letter`                |
| `backdrop:`     | `::backdrop`                    |

```html
<!-- required asterisk after label -->
<span class="after:content-['*'] after:ml-0.5 after:text-red-500">Email</span>

<!-- styled placeholder -->
<input class="placeholder:text-gray-400 placeholder:italic" />

<!-- styled file button -->
<input
  type="file"
  class="file:rounded-full file:border-0 file:bg-violet-50 file:px-4"
/>

<!-- inheritable marker color -->
<ul class="marker:text-sky-400 list-disc">
  ...
</ul>

<!-- inheritable selection color -->
<div class="selection:bg-fuchsia-300">...</div>
```

## Media and feature query variants

| Variant               | Condition                               |
| --------------------- | --------------------------------------- |
| `dark:`               | `prefers-color-scheme: dark`            |
| `motion-reduce:`      | `prefers-reduced-motion: reduce`        |
| `motion-safe:`        | `prefers-reduced-motion: no-preference` |
| `contrast-more:`      | `prefers-contrast: more`                |
| `contrast-less:`      | `prefers-contrast: less`                |
| `forced-colors:`      | `forced-colors: active`                 |
| `not-forced-colors:`  | `forced-colors: none`                   |
| `inverted-colors:`    | `inverted-colors: inverted`             |
| `portrait:`           | `orientation: portrait`                 |
| `landscape:`          | `orientation: landscape`                |
| `pointer-fine:`       | `pointer: fine` (mouse/trackpad)        |
| `pointer-coarse:`     | `pointer: coarse` (touchscreen)         |
| `pointer-none:`       | no pointing device                      |
| `any-pointer-fine:`   | any fine pointing device                |
| `any-pointer-coarse:` | any coarse pointing device              |
| `print:`              | print media                             |
| `noscript:`           | scripting disabled                      |
| `starting:`           | `@starting-style`                       |

### supports-[...] / not-supports-[...]

```html
<div class="flex supports-[display:grid]:grid">...</div>
<div class="not-supports-[display:grid]:flex">...</div>
<!-- Shorthand (property only): -->
<div
  class="supports-backdrop-filter:bg-black/25 supports-backdrop-filter:backdrop-blur"
>
  ...
</div>
```

Custom `supports-*` shorthand:

```css
@custom-variant supports-grid {
  @supports (display: grid) {
    @slot;
  }
}
```

### starting: variant

Apply styles when element first renders or transitions from `display: none`:

```html
<div
  popover
  class="opacity-0 starting:open:opacity-0 open:opacity-100 transition-opacity"
>
  ...
</div>
```

## Attribute selectors

### aria-\* variants

```html
<div aria-checked="true" class="bg-gray-600 aria-checked:bg-sky-700">...</div>
```

Default boolean `aria-*` variants: `aria-busy`, `aria-checked`, `aria-disabled`, `aria-expanded`, `aria-hidden`, `aria-pressed`, `aria-readonly`, `aria-required`, `aria-selected`.

Arbitrary ARIA values:

```html
<th class="aria-[sort=ascending]:bg-[url('/img/down-arrow.svg')]">...</th>
```

Custom ARIA variants:

```css
@custom-variant aria-asc (&[aria-sort="ascending"]);
@custom-variant aria-desc (&[aria-sort="descending"]);
```

`group-aria-*` and `peer-aria-*` also work.

### data-\* variants

```html
<!-- Checks existence -->
<div data-active class="data-active:border-purple-500">...</div>
<!-- Checks value -->
<div data-size="large" class="data-[size=large]:p-8">...</div>
```

Custom `data-*` shorthand:

```css
@custom-variant data-checked (&[data-ui~="checked"]);
```

### rtl: / ltr:

```html
<div class="ltr:ml-3 rtl:mr-3">...</div>
```

## Child selectors

### \* (direct children)

```html
<ul class="*:rounded-full *:border *:bg-sky-50 *:px-2">
  <li>Sales</li>
  <li>Marketing</li>
</ul>
```

Note: child styles cannot be overridden by utilities on the child itself (same specificity, children rules come after).

### \*\* (all descendants)

```html
<ul class="**:data-avatar:size-12 **:data-avatar:rounded-full">
  <li>
    <img src="..." data-avatar />
    <p>Name</p>
  </li>
</ul>
```

## Stacking variants

Stack any number of variants from left to right:

```html
<button class="dark:md:hover:bg-fuchsia-600">...</button>
```

## Arbitrary variants

Custom selector variants inline — wrap selector in `[...]`:

```html
<li class="[&:nth-child(-n+3)]:underline">...</li>
<li class="lg:[&:nth-child(-n+3)]:hover:underline">...</li>
```

Use `&` to control where the class appears in the selector:

```html
<div class="group-[:nth-of-type(3)_&]:block">...</div>
```

## Important modifier

Suffix any utility with `!` to make it `!important`:

```html
<div class="!font-bold">...</div>
```
