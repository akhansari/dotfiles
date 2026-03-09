# Lifecycle

Svelte provides lifecycle hooks for running code at specific points in a component's life, as well as an imperative API for mounting components programmatically.

## onMount

Runs after the component is first mounted to the DOM. Only runs in the browser — never during SSR.

```svelte
<script lang="ts">
  import { onMount } from 'svelte';

  let data = $state<string[]>([]);

  onMount(async () => {
    const res = await fetch('/api/items');
    data = await res.json();
  });
</script>
```

If `onMount` returns a function, it is called when the component is destroyed (equivalent to `onDestroy`):

```svelte
<script lang="ts">
  import { onMount } from 'svelte';

  onMount(() => {
    const id = setInterval(() => tick(), 1000);
    return () => clearInterval(id); // cleanup on destroy
  });
</script>
```

---

## onDestroy

Runs when the component is unmounted from the DOM. Can be called in any context during component initialization — including in helper functions called from `<script>`.

```svelte
<script lang="ts">
  import { onDestroy } from 'svelte';

  let count = $state(0);
  const id = setInterval(() => count += 1, 1000);

  onDestroy(() => clearInterval(id));
</script>
```

---

## tick

Returns a Promise that resolves after Svelte applies any pending state changes to the DOM. Use when you need to read updated DOM values after a state change.

```svelte
<script lang="ts">
  import { tick } from 'svelte';

  let text = $state('hello');

  async function handleInput() {
    text = 'world';
    await tick(); // wait for DOM to update
    // now DOM reflects new `text`
  }
</script>
```

---

## setContext / getContext

`setContext` and `getContext` allow passing data through the component tree without prop drilling. Context is set during component initialization and is available to all descendant components.

```ts
import { setContext, getContext } from "svelte";
```

### setContext

```svelte
<!-- Parent.svelte -->
<script lang="ts">
  import { setContext } from 'svelte';
  import { SvelteMap } from 'svelte/reactivity';

  type Theme = { primary: string; secondary: string };

  // Context value can be reactive
  const theme = $state<Theme>({ primary: '#ff3e00', secondary: '#40b3ff' });

  setContext('theme', theme);
</script>

<slot />
```

### getContext

```svelte
<!-- Child.svelte (any depth below Parent) -->
<script lang="ts">
  import { getContext } from 'svelte';

  type Theme = { primary: string; secondary: string };
  const theme = getContext<Theme>('theme');
</script>

<button style="background: {theme.primary}">Themed button</button>
```

### hasContext / getAllContexts

```ts
import { hasContext, getAllContexts } from "svelte";

if (hasContext("theme")) {
  // context exists
}

const allContexts = getAllContexts(); // Map of all contexts in scope
```

> **Tip**: Use a Symbol as the context key to avoid name collisions:
>
> ```ts
> const THEME_KEY = Symbol("theme");
> setContext(THEME_KEY, theme);
> const theme = getContext<Theme>(THEME_KEY);
> ```

---

## svelte/reactivity Built-in Classes

Reactive wrappers for JavaScript built-ins. See [Reactivity](./reactivity.md#svelte-reactivity-built-ins) for full docs.

```ts
import {
  SvelteMap,
  SvelteSet,
  SvelteDate,
  SvelteURL,
  SvelteURLSearchParams,
  createSubscriber,
  MediaQuery,
} from "svelte/reactivity";
```

### MediaQuery

```svelte
<script lang="ts">
  import { MediaQuery } from 'svelte/reactivity';

  const mobile = new MediaQuery('(max-width: 768px)');
</script>

{#if mobile.current}
  <MobileLayout />
{:else}
  <DesktopLayout />
{/if}
```

### svelte/reactivity/window

Reactive window properties:

```svelte
<script lang="ts">
  import { innerWidth, innerHeight, scrollX, scrollY, online } from 'svelte/reactivity/window';
</script>

<p>Window: {innerWidth.current} × {innerHeight.current}</p>
<p>Scroll: ({scrollX.current}, {scrollY.current})</p>
<p>Online: {online.current}</p>
```

---

## Imperative Component API

Mount and unmount components programmatically using the `mount` and `unmount` functions from `svelte`.

```ts
import { mount, unmount } from "svelte";
import App from "./App.svelte";

const app = mount(App, {
  target: document.getElementById("app")!,
  props: {
    name: "world",
  },
});

// later
unmount(app);
```

### hydrate

For hydrating server-rendered HTML:

```ts
import { hydrate } from "svelte";
import App from "./App.svelte";

const app = hydrate(App, {
  target: document.getElementById("app")!,
  props: { name: "world" },
});
```

### render (SSR)

Render a component to HTML strings on the server:

```ts
import { render } from "svelte/server";
import App from "./App.svelte";

const { html, head } = render(App, {
  props: { name: "world" },
});
```

---

## flushSync

Forces all pending state updates to be applied synchronously. Use sparingly — mainly in tests or when you need immediate DOM reads after a state change without `await tick()`.

```ts
import { flushSync } from "svelte";

flushSync(() => {
  count += 1;
});
// DOM is now updated synchronously
```

---

## createRawSnippet

Creates a snippet programmatically from a render function. Useful for advanced component libraries.

```ts
import { createRawSnippet } from "svelte";

const mySnippet = createRawSnippet((getLabel: () => string) => ({
  render: () => `<span>${getLabel()}</span>`,
  setup(node) {
    // imperative setup
  },
}));
```
