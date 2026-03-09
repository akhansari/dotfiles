# Special Elements

Svelte provides several built-in special elements that integrate with the browser environment or provide advanced component behaviors.

## \<svelte:boundary\>

An error boundary that catches errors thrown during rendering or in effects inside it, preventing the entire app from crashing.

```svelte
<svelte:boundary>
  <PotentiallyBrokenComponent />

  {#snippet failed(error, reset)}
    <p>Something went wrong: {error.message}</p>
    <button onclick={reset}>Try again</button>
  {/snippet}
</svelte:boundary>
```

The `failed` snippet receives:

- `error` — the caught error
- `reset` — a function that clears the error and re-renders children

If no `failed` snippet is provided, errors propagate to the nearest parent boundary.

### onerror Handler

```svelte
<svelte:boundary onerror={(error, reset) => reportError(error)}>
  <Component />
</svelte:boundary>
```

---

## \<svelte:window\>

Binds to `window` event listeners and properties without `addEventListener`/`removeEventListener` boilerplate. Listeners are automatically removed when the component is destroyed.

```svelte
<svelte:window onkeydown={handleKeydown} />
```

### Window Property Bindings

```svelte
<svelte:window
  bind:scrollX={x}
  bind:scrollY={y}
  bind:innerWidth={width}
  bind:innerHeight={height}
  bind:outerWidth
  bind:outerHeight
  bind:online
/>
```

All bindings except `scrollX` and `scrollY` are read-only.

---

## \<svelte:document\>

Binds to events on `document`. Only events that don't fire on `window` need to be bound here (e.g., `visibilitychange`, `selectionchange`).

```svelte
<svelte:document onvisibilitychange={handleVisibilityChange} />
```

### Document Property Bindings

```svelte
<svelte:document bind:fullscreenElement bind:visibilityState />
```

---

## \<svelte:body\>

Binds to events on `document.body`. Useful for `mouseenter`/`mouseleave` which don't fire on `window`.

```svelte
<svelte:body
  onmouseenter={() => (hoveringDocument = true)}
  onmouseleave={() => (hoveringDocument = false)}
/>
```

---

## \<svelte:head\>

Inserts elements into `<head>` — useful for `<title>`, `<meta>`, `<link>`, and `<script>` tags.

```svelte
<svelte:head>
  <title>{pageTitle} | My App</title>
  <meta name="description" content={description} />
  <link rel="canonical" href={canonicalUrl} />
</svelte:head>
```

During SSR, `<svelte:head>` content is rendered separately from the body HTML and can be injected into the document head by SvelteKit.

---

## \<svelte:element\>

Renders an element whose tag name is determined at runtime.

```svelte
<script lang="ts">
  let tag: 'h1' | 'h2' | 'h3' | 'p' = $props().tag ?? 'p';
</script>

<svelte:element this={tag} class="prose">
  Dynamic element
</svelte:element>
```

- If `this` is `null` or `undefined`, nothing is rendered
- Event listeners and bindings work on `<svelte:element>` but you only get the common DOM interface (not element-specific APIs)
- For known elements you can cast: `<svelte:element this={'input' as 'input'} bind:value />`

---

## \<svelte:options\>

Sets per-component compiler options. Must appear at the top level of the component, before `<script>` or markup.

```svelte
<svelte:options runes={true} />
```

### Options

| Option          | Values                        | Description                                                |
| --------------- | ----------------------------- | ---------------------------------------------------------- |
| `runes`         | `true \| false`               | Force runes or legacy mode for this component              |
| `immutable`     | `true \| false`               | Tells compiler props won't be mutated (performance hint)   |
| `accessors`     | `true \| false`               | Add getters/setters for component props (legacy API)       |
| `customElement` | string or object              | Compile as a custom element with the given tag name        |
| `css`           | `'injected'`                  | Inject CSS into the component shadow DOM (custom elements) |
| `namespace`     | `'html' \| 'svg' \| 'mathml'` | Namespace for the component's content                      |

### Custom Element Configuration

```svelte
<svelte:options
  customElement={{
    tag: 'my-counter',
    shadow: 'none',
    props: {
      count: { reflect: true, type: 'Number', attribute: 'count' }
    }
  }}
/>
```

---

## \<svelte:component\> (Legacy)

> **Legacy Svelte 4 API** — in Svelte 5, use `{@render}` with snippets, or a regular variable for dynamic components.

```svelte
<!-- Legacy: -->
<svelte:component this={CurrentComponent} {props} />

<!-- Svelte 5 equivalent — just use the variable directly: -->
<CurrentComponent {props} />
```

When `this` is falsy, no component is rendered. In Svelte 5 runes mode, a plain `{#if}` block is preferred.
