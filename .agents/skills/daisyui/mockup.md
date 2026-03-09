# DaisyUI Mockup

## mockup-browser

A box styled to look like a browser window.
[docs](https://daisyui.com/components/mockup-browser/)

### Class names

- component: `mockup-browser`
- part: `mockup-browser-toolbar`

### Syntax

```html
<div class="mockup-browser border border-base-300">
  <div class="mockup-browser-toolbar">
    <div class="input">https://example.com</div>
  </div>
  <div class="flex justify-center px-4 py-10 border-t border-base-300">
    {CONTENT}
  </div>
</div>
```

### Rules

- Add a `div` with class `input` inside the toolbar to display a URL bar

---

## mockup-code

A box styled to look like a code editor / terminal.
[docs](https://daisyui.com/components/mockup-code/)

### Class names

- component: `mockup-code`

### Syntax

```html
<div class="mockup-code">
  <pre data-prefix="$"><code>npm install daisyui</code></pre>
  <pre data-prefix=">" class="text-success"><code>Done!</code></pre>
</div>
```

### Rules

- Use `data-prefix="{text}"` on `<pre>` to set a prefix for each line
- Wrap code in `<code>` for syntax highlighting (requires an additional library)
- Apply background or text color classes to highlight specific lines

---

## mockup-phone

A box styled to look like an iPhone.
[docs](https://daisyui.com/components/mockup-phone/)

### Class names

- component: `mockup-phone`
- part: `mockup-phone-camera`, `mockup-phone-display`

### Syntax

```html
<div class="mockup-phone">
  <div class="mockup-phone-camera"></div>
  <div class="mockup-phone-display">{CONTENT}</div>
</div>
```

### Rules

- Put any content inside `mockup-phone-display`

---

## mockup-window

A box styled to look like a desktop OS window.
[docs](https://daisyui.com/components/mockup-window/)

### Class names

- component: `mockup-window`

### Syntax

```html
<div class="mockup-window border border-base-300">
  <div class="flex justify-center px-4 py-10 border-t border-base-300">
    {CONTENT}
  </div>
</div>
```
