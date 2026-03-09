# Reactivity

Svelte 5 uses a push-pull reactivity model. When state changes, dependents are immediately notified (push), but derived values are only recalculated when actually read (pull).

## Deep State Proxies

`$state` wraps objects and arrays in a deep reactive `Proxy`. Reading or writing properties — including through array methods — is tracked and triggers fine-grained updates.

```ts
let todos = $state([
  { id: 1, done: false, text: "buy groceries" },
  { id: 2, done: false, text: "write code" },
]);

// All of these trigger reactivity:
todos[0].done = true; // property mutation
todos.push({ id: 3, done: false, text: "sleep" }); // array method
todos.splice(1, 1); // array method
```

### What Is Not Proxied

- Class instances
- Values created with `Object.create`
- Anything other than plain arrays and plain objects

```ts
class User {
  // Use $state on class fields instead
  name = $state("");
  age = $state(0);
}
```

### Proxy Identity

Proxies are distinct from the original objects. Do not compare proxy identity to source objects. Use `$state.snapshot` to get a plain copy when needed.

---

## $state.raw

Declares state that is **not** deeply proxied. Can only be replaced (reassigned), not mutated. Useful for large immutable data structures or performance-sensitive cases.

```ts
let list = $state.raw<string[]>([]);

// BAD — mutation has no effect
list.push("item"); // won't trigger reactivity

// GOOD — reassignment triggers reactivity
list = [...list, "item"];
```

Raw state can contain reactive state inside it:

```ts
// A raw array of reactive objects
let rows = $state.raw([$state({ name: "Alice" }), $state({ name: "Bob" })]);
```

---

## $state.snapshot

Converts a reactive proxy to a plain, non-reactive snapshot. Useful for serialization, `console.log`, `structuredClone`, or passing to third-party APIs.

```ts
let cart = $state({ items: [{ id: 1, qty: 2 }] });

// Without snapshot: logs `Proxy { ... }`
console.log(cart);

// With snapshot: logs `{ items: [...] }`
console.log($state.snapshot(cart));

// Safe to clone
const copy = structuredClone($state.snapshot(cart));
```

---

## $state.eager

Forces the UI to update immediately when state changes, bypassing Svelte's normal async coordination. Use only for immediate user feedback during async operations.

```svelte
<nav>
  <a href="/" aria-current={$state.eager(pathname) === '/' ? 'page' : null}>home</a>
  <a href="/about" aria-current={$state.eager(pathname) === '/about' ? 'page' : null}>about</a>
</nav>
```

---

## $derived.by

For complex derivations that require multiple statements:

```ts
let numbers = $state([1, 2, 3, 4, 5]);

let stats = $derived.by(() => {
  const sorted = [...numbers].sort((a, b) => a - b);
  const min = sorted[0];
  const max = sorted[sorted.length - 1];
  const sum = sorted.reduce((acc, n) => acc + n, 0);
  const avg = sum / sorted.length;
  return { min, max, sum, avg };
});
```

---

## untrack

Reads reactive state without registering it as a dependency. Imported from `'svelte'`.

```ts
import { untrack } from "svelte";

$effect(() => {
  // `a` is tracked — effect re-runs when `a` changes
  console.log(a);

  // `b` is NOT tracked — changes to `b` don't trigger re-runs
  const bValue = untrack(() => b);
  console.log(bValue);
});
```

Useful when you need to read state in an effect without making it a reactive dependency, or when breaking circular dependencies.

---

## Passing State Into Functions

JavaScript is pass-by-value. When you pass a `$state` variable to a function, it passes the current value — not a live reference.

```ts
// BAD — `total` is 3 forever, never updates
function add(a: number, b: number) {
  return a + b;
}
let a = $state(1),
  b = $state(2);
let total = add(a, b); // total = 3

// GOOD — pass getter functions for live access
function add(getA: () => number, getB: () => number) {
  return () => getA() + getB();
}
let total = add(
  () => a,
  () => b,
);
total(); // always current
```

Or pass the reactive object directly (since object properties are tracked via the proxy):

```ts
let input = $state({ a: 1, b: 2 });

function add(input: { a: number; b: number }) {
  return {
    get value() {
      return input.a + input.b;
    },
  };
}

let result = add(input);
result.value; // reactive — updates when input.a or input.b changes
```

---

## Passing State Across Modules

State declared in `.svelte.js`/`.svelte.ts` files can be shared, but **you cannot directly export a reassignable `$state` variable**.

### Option 1 — Export a reactive object (not reassigned)

```ts
// counter.svelte.ts
export const counter = $state({ count: 0 });

export function increment() {
  counter.count += 1; // mutating .count is fine
}
```

```svelte
<script lang="ts">
  import { counter, increment } from './counter.svelte.ts';
</script>

<button onclick={increment}>{counter.count}</button>
```

### Option 2 — Export getter/setter functions

```ts
// count.svelte.ts
let count = $state(0);

export const getCount = () => count;
export const increment = () => (count += 1);
export const reset = () => (count = 0);
```

### Why Direct Export Fails

The Svelte compiler transforms `$state` references in the same file, but it cannot transform references in other files importing the exported binding. This causes the imported value to be the raw signal object, not the unwrapped value.

```ts
// BROKEN — do not do this
export let count = $state(0); // ❌ importing modules get the signal, not the number

export function increment() {
  count += 1; // this works in this file
}
```

---

## Reactive Update Propagation

Svelte skips downstream updates when the new derived value is referentially identical to the previous value:

```svelte
<script lang="ts">
  let count = $state(0);
  let large = $derived(count > 10); // boolean
</script>

<!-- Only re-renders when `large` changes (false→true or true→false),
     NOT on every count increment -->
<button onclick={() => count++}>{large}</button>
```

This optimization means fine-grained reactivity — components only update when the specific values they read actually change.

---

## Svelte Reactivity Built-ins

Svelte provides reactive wrappers for built-in JavaScript classes. Import from `svelte/reactivity`.

```ts
import {
  SvelteMap,
  SvelteSet,
  SvelteDate,
  SvelteURL,
  SvelteURLSearchParams,
} from "svelte/reactivity";
```

### SvelteMap

```ts
let map = new SvelteMap<string, number>();
map.set("a", 1); // triggers reactivity
map.delete("a"); // triggers reactivity
map.size; // reactive
map.get("a"); // reactive
```

### SvelteSet

```ts
let set = new SvelteSet<string>();
set.add("hello"); // triggers reactivity
set.has("hello"); // reactive
set.size; // reactive
```

### SvelteDate

```ts
let date = new SvelteDate();
date.setFullYear(2026); // triggers reactivity
date.getFullYear(); // reactive
```

### SvelteURL

```ts
let url = new SvelteURL("https://example.com/path?q=1");
url.pathname; // reactive
url.searchParams.get("q"); // reactive (SvelteURLSearchParams)
url.pathname = "/new"; // triggers reactivity
```

### createSubscriber

Advanced pattern for wrapping external event sources as reactive values:

```ts
import { createSubscriber } from "svelte/reactivity";

function createOnlineStatus() {
  const subscribe = createSubscriber((update) => {
    window.addEventListener("online", update);
    window.addEventListener("offline", update);
    return () => {
      window.removeEventListener("online", update);
      window.removeEventListener("offline", update);
    };
  });

  return {
    get online() {
      subscribe(); // registers dependency when read in reactive context
      return navigator.onLine;
    },
  };
}

export const network = createOnlineStatus();
```

```svelte
<p>Status: {network.online ? 'online' : 'offline'}</p>
```
