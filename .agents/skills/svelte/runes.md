# Runes

Runes are compiler-level keywords in Svelte 5, prefixed with `$`. They are not values — you cannot assign them to variables or pass them as arguments to functions. They are only valid in `.svelte`, `.svelte.js`, and `.svelte.ts` files.

## $state

Declares reactive state. When it changes, the UI re-renders.

```svelte
<script lang="ts">
  let count = $state(0);
</script>

<button onclick={() => count++}>clicks: {count}</button>
```

### Deep State

When `$state` wraps an array or plain object, it becomes a deeply reactive proxy. Mutations trigger fine-grained updates.

```ts
let todos = $state([{ done: false, text: "add more todos" }]);

// Mutating a nested property triggers reactivity
todos[0].done = !todos[0].done;

// Pushing also triggers reactivity
todos.push({ done: false, text: "eat lunch" });
```

> **Note**: Destructuring a reactive value gives non-reactive references — they are evaluated at the time of destructuring, not tracked thereafter.
>
> ```ts
> let { done, text } = todos[0]; // NOT reactive
> todos[0].done = true; // does NOT update `done` above
> ```

### Classes

Class instances are not proxied. Use `$state` in class fields or in `constructor` property assignments:

```ts
class Todo {
  done = $state(false);
  text = $state("");

  constructor(text: string) {
    this.text = text;
  }

  // Use arrow functions when methods are used as event handlers
  reset = () => {
    this.text = "";
    this.done = false;
  };
}
```

### $state.raw

For large objects/arrays you do not intend to mutate. Cannot be mutated — only reassigned. Better performance since no proxy overhead.

```ts
let person = $state.raw({
  name: "Heraclitus",
  age: 49,
});

// This has NO effect
person.age += 1;

// This works — full reassignment
person = { name: "Heraclitus", age: 50 };
```

### $state.snapshot

Takes a static, non-proxy copy of a reactive state value. Useful when passing state to external libraries.

```svelte
<script lang="ts">
  let counter = $state({ count: 0 });

  function onclick() {
    console.log($state.snapshot(counter)); // plain object, not a Proxy
  }
</script>
```

### $state.eager

Forces the UI to update immediately when state changes, rather than waiting for async coordination. Use sparingly — only for user-facing feedback while awaiting async work.

```svelte
<nav>
  <a href="/" aria-current={$state.eager(pathname) === '/' ? 'page' : null}>home</a>
  <a href="/about" aria-current={$state.eager(pathname) === '/about' ? 'page' : null}>about</a>
</nav>
```

---

## $derived

Declares a computed value that automatically recalculates when its reactive dependencies change. The expression must be free of side effects — state changes inside `$derived` are disallowed.

```svelte
<script lang="ts">
  let count = $state(0);
  let doubled = $derived(count * 2);
</script>

<p>{count} doubled is {doubled}</p>
```

### $derived.by

For complex derivations that require a function body:

```svelte
<script lang="ts">
  let numbers = $state([1, 2, 3]);
  let total = $derived.by(() => {
    let sum = 0;
    for (const n of numbers) sum += n;
    return sum;
  });
</script>

<button onclick={() => numbers.push(numbers.length + 1)}>
  {numbers.join(' + ')} = {total}
</button>
```

`$derived(expr)` is exactly equivalent to `$derived.by(() => expr)`.

### Understanding Dependencies

Any reactive value read **synchronously** inside the `$derived` expression or `$derived.by` function body is registered as a dependency. When those dependencies change, the derived is marked dirty and recalculated on next read (pull-based).

To read a value without registering it as a dependency, use [`untrack`](./reactivity.md#untrack).

### Overriding Derived Values

Derived values can be temporarily overridden via reassignment (since Svelte 5.25). Useful for optimistic UI:

```svelte
<script lang="ts">
  let { post, like } = $props();
  let likes = $derived(post.likes);

  async function onclick() {
    likes += 1; // optimistic increment
    try {
      await like();
    } catch {
      likes -= 1; // rollback on failure
    }
  }
</script>

<button {onclick}>🧡 {likes}</button>
```

### Destructuring $derived

Destructuring a `$derived` declaration produces individual reactive variables:

```ts
// This...
let { a, b, c } = $derived(stuff());

// ...is equivalent to this:
let _stuff = $derived(stuff());
let a = $derived(_stuff.a);
let b = $derived(_stuff.b);
let c = $derived(_stuff.c);
```

---

## $effect

Runs a side-effect function after the component mounts and after reactive state it reads changes. Runs only in the browser — not during SSR.

```svelte
<script lang="ts">
  let size = $state(50);
  let color = $state('#ff3e00');
  let canvas: HTMLCanvasElement;

  $effect(() => {
    const ctx = canvas.getContext('2d')!;
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    ctx.fillStyle = color;
    ctx.fillRect(0, 0, size, size);
  });
</script>

<canvas bind:this={canvas} width="100" height="100" />
```

> **Important**: Do NOT use `bind:this` in new code. This example shows the canvas pattern for illustration — prefer `{@attach}` for DOM access.

### Teardown

An effect can return a cleanup function that runs before the effect re-runs or when the component is destroyed:

```svelte
<script lang="ts">
  let milliseconds = $state(1000);
  let count = $state(0);

  $effect(() => {
    const interval = setInterval(() => count += 1, milliseconds);
    return () => clearInterval(interval); // cleanup
  });
</script>
```

### Understanding Dependencies

`$effect` tracks reactive values read **synchronously** inside the function body. Values read asynchronously (after `await` or inside `setTimeout`) are **not** tracked.

```ts
$effect(() => {
  // `color` IS tracked — synchronous read
  ctx.fillStyle = color;

  setTimeout(() => {
    // `size` is NOT tracked — asynchronous read
    ctx.fillRect(0, 0, size, size);
  }, 0);
});
```

### $effect.pre

Runs before DOM updates instead of after. Rare — only needed when you must read DOM state before it changes.

```svelte
<script lang="ts">
  let div = $state<HTMLDivElement>();
  let messages = $state<string[]>([]);

  $effect.pre(() => {
    if (!div) return;
    messages.length; // track length changes
    // autoscroll if near the bottom
    if (div.offsetHeight + div.scrollTop > div.scrollHeight - 20) {
      tick().then(() => div!.scrollTo(0, div!.scrollHeight));
    }
  });
</script>
```

### $effect.tracking

Returns `true` if called inside a tracking context (an effect or template). Used to implement reactive subscriptions that only activate when being observed.

```svelte
<script lang="ts">
  console.log($effect.tracking()); // false — component setup

  $effect(() => {
    console.log($effect.tracking()); // true
  });
</script>

<p>{$effect.tracking()}</p> <!-- true -->
```

### $effect.pending

When using `await` in components, returns the count of pending promises in the current boundary. Useful for showing loading states.

```svelte
{#if $effect.pending()}
  <p>Loading ({$effect.pending()} pending)...</p>
{/if}
```

### $effect.root

Creates a non-tracked scope with manual cleanup. Useful for effects outside component initialization.

```ts
const destroy = $effect.root(() => {
  $effect(() => {
    // setup
  });
  return () => {
    // manual cleanup
  };
});

// later
destroy();
```

### When NOT to Use $effect

Avoid using `$effect` to synchronize state — use `$derived` instead:

```ts
// BAD — unnecessary effect
let doubled = $state(0);
$effect(() => {
  doubled = count * 2;
});

// GOOD — use $derived
let doubled = $derived(count * 2);
```

Avoid linking two pieces of state through effects (infinite loop risk):

```ts
// BAD — two effects linking spent/left create infinite loops
$effect(() => {
  left = total - spent;
});
$effect(() => {
  spent = total - left;
});

// GOOD — derive one from the other and use function binding
let left = $derived(total - spent);
```

---

## $props

Declares component input properties. Destructure to access individual props.

```svelte
<!-- MyComponent.svelte -->
<script lang="ts">
  let { adjective = 'happy', name }: { adjective?: string; name: string } = $props();
</script>

<p>{name} is {adjective}</p>
```

```svelte
<!-- Parent -->
<MyComponent name="world" adjective="cool" />
```

### Fallback Values

```ts
let { count = 0, label = "Click me" } = $props();
```

Fallback values are **not** turned into reactive proxies.

### Renaming Props

Necessary when prop names are JavaScript keywords or invalid identifiers:

```ts
let { super: trouper = "lights are gonna find me" } = $props();
```

### Rest Props

Capture all remaining props — useful for wrapper components:

```ts
let { class: className, style, ...attrs } = $props();
```

### Type Safety

```svelte
<script lang="ts">
  type Props = {
    name: string;
    count?: number;
    onclick?: (e: MouseEvent) => void;
  };

  let { name, count = 0, onclick }: Props = $props();
</script>
```

### $props.id()

Generates a unique ID per component instance, consistent between server and client during hydration. Useful for `for`/`id` associations.

```svelte
<script lang="ts">
  const uid = $props.id();
</script>

<label for="{uid}-name">Name</label>
<input id="{uid}-name" type="text" />
```

---

## $bindable

Marks a prop as two-way bindable, allowing the child to update the parent's value. Use sparingly.

```svelte
<!-- FancyInput.svelte -->
<script lang="ts">
  let { value = $bindable(''), ...props }: { value?: string; [key: string]: unknown } = $props();
</script>

<input bind:value {...props} />
```

```svelte
<!-- Parent -->
<script lang="ts">
  let message = $state('hello');
</script>

<FancyInput bind:value={message} />
<p>{message}</p>
```

The parent does not have to use `bind:` — it can pass a regular prop. The `$bindable` fallback value is used only when no prop is passed.

---

## $inspect

Dev-only reactive logger. Re-fires whenever any of its arguments change. Removed from production builds.

```svelte
<script lang="ts">
  let count = $state(0);
  let message = $state('hello');

  $inspect(count, message); // console.log on every change
</script>
```

### $inspect(...).with

Provide a custom callback instead of `console.log`:

```ts
$inspect(count).with((type, value) => {
  if (type === "update") debugger;
});
```

First argument is `'init'` or `'update'`. Subsequent arguments are the inspected values.

### $inspect.trace()

Traces which reactive state triggered an effect re-run. Must be the first statement in a function body.

```svelte
<script lang="ts">
  $effect(() => {
    $inspect.trace('my-effect'); // optional label
    doSomeWork();
  });
</script>
```

---

## $host

When compiling a component as a custom element, provides access to the host element.

```svelte
<!-- Stepper.svelte -->
<svelte:options customElement="my-stepper" />

<script lang="ts">
  function dispatch(type: string) {
    $host().dispatchEvent(new CustomEvent(type));
  }
</script>

<button onclick={() => dispatch('decrement')}>-</button>
<button onclick={() => dispatch('increment')}>+</button>
```

```svelte
<!-- Usage -->
<my-stepper
  ondecrement={() => count -= 1}
  onincrement={() => count += 1}
/>
```
