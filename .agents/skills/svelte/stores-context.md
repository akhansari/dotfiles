# Stores & Context

Svelte provides two mechanisms for sharing state: **stores** (observable values from `svelte/store`) and **context** (tree-scoped values via `setContext`/`getContext`). In Svelte 5, reactive state in `.svelte.ts` modules is often preferred over stores for new code.

## Stores (svelte/store)

Stores are observable objects with a `subscribe` method. Any component can subscribe to a store.

### writable

A store with `set` and `update` methods.

```ts
import { writable } from "svelte/store";

const count = writable(0);

// Set a value
count.set(5);

// Update based on current value
count.update((n) => n + 1);

// Subscribe
const unsubscribe = count.subscribe((value) => {
  console.log("count is", value);
});

// Clean up
unsubscribe();
```

### readable

A store that can only be set from inside its initializer. Use for values sourced from external events.

```ts
import { readable } from "svelte/store";

const time = readable(new Date(), (set) => {
  const id = setInterval(() => set(new Date()), 1000);
  return () => clearInterval(id); // cleanup
});
```

### derived

A store derived from one or more other stores:

```ts
import { derived } from "svelte/store";

const doubled = derived(count, ($count) => $count * 2);

// Multiple source stores
const summary = derived(
  [firstName, lastName],
  ([$first, $last]) => `${$first} ${$last}`,
);

// Async derived (set manually)
const delayed = derived(
  count,
  ($count, set) => {
    const timer = setTimeout(() => set($count), 1000);
    return () => clearTimeout(timer);
  },
  0,
); // initial value
```

### get

Reads the current value of any store synchronously without subscribing. Avoid in hot paths — prefer subscriptions.

```ts
import { get } from "svelte/store";

const currentCount = get(count);
```

---

## Using Stores in Svelte Components

### Auto-subscription with $

In `.svelte` files, prefix a store with `$` to auto-subscribe and auto-unsubscribe. The `$` prefix is reserved for stores in Svelte templates.

```svelte
<script lang="ts">
  import { count } from './stores';
</script>

<!-- $count auto-subscribes and unsubscribes -->
<p>Count: {$count}</p>
<button onclick={() => count.update(n => n + 1)}>+</button>
```

### Binding to Stores

```svelte
<input bind:value={$name} />
```

This calls `name.set` when the input changes.

---

## Custom Stores

Any object with a `subscribe` method conforming to the store contract is a valid store:

```ts
import { writable } from "svelte/store";

function createCounter(initial = 0) {
  const { subscribe, set, update } = writable(initial);

  return {
    subscribe,
    increment: () => update((n) => n + 1),
    decrement: () => update((n) => n - 1),
    reset: () => set(0),
  };
}

export const counter = createCounter();
```

```svelte
<script lang="ts">
  import { counter } from './counter';
</script>

<p>{$counter}</p>
<button onclick={counter.increment}>+</button>
<button onclick={counter.decrement}>-</button>
<button onclick={counter.reset}>Reset</button>
```

---

## Context API

Context passes data through the component tree without prop drilling. Unlike stores, context is:

- **Scoped to a component subtree** (not global)
- **Instance-level** (each component instance has its own context)
- Set during component initialization only

### setContext

```svelte
<!-- Parent.svelte -->
<script lang="ts">
  import { setContext } from 'svelte';

  const THEME_KEY = Symbol('theme');

  type Theme = { primary: string; accent: string };
  const theme: Theme = { primary: '#ff3e00', accent: '#40b3ff' };

  setContext(THEME_KEY, theme);
</script>
```

### getContext

```svelte
<!-- Descendant.svelte (any depth) -->
<script lang="ts">
  import { getContext } from 'svelte';

  type Theme = { primary: string; accent: string };
  const THEME_KEY = Symbol('theme'); // same key

  const theme = getContext<Theme>(THEME_KEY);
</script>

<button style:background-color={theme.primary}>Themed</button>
```

### Reactive Context

Context values can be reactive `$state` objects. Since context is passed by reference, mutations to reactive objects in context are reflected everywhere the context is read.

```svelte
<!-- Parent.svelte -->
<script lang="ts">
  import { setContext } from 'svelte';

  const user = $state({ name: 'Alice', role: 'admin' });
  setContext('user', user);
</script>
```

```svelte
<!-- Child.svelte -->
<script lang="ts">
  import { getContext } from 'svelte';
  const user = getContext<{ name: string; role: string }>('user');
</script>

<p>Hello, {user.name} ({user.role})</p>
```

### hasContext / getAllContexts

```ts
import { hasContext, getAllContexts } from "svelte";

if (hasContext("user")) {
  const user = getContext("user");
}

const allContexts: Map<unknown, unknown> = getAllContexts();
```

---

## Stores vs Reactive State Modules

In Svelte 5, prefer reactive state in `.svelte.ts` modules over stores for new code:

```ts
// stores.svelte.ts — Svelte 5 preferred approach
export const counter = $state({ count: 0 });
export const increment = () => (counter.count += 1);
```

vs

```ts
// stores.ts — Svelte 4 pattern (still valid)
import { writable } from "svelte/store";
export const count = writable(0);
```

Key differences:

- Reactive state modules use `counter.count` (direct property access), no `$` prefix in templates
- Stores use `$count` auto-subscription syntax in templates
- Reactive state modules cannot export directly reassignable values (see [Reactivity](./reactivity.md#passing-state-across-modules))
- Stores have explicit `subscribe`/`set`/`update` API, making them interoperable with non-Svelte code
