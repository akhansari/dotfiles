# TypeScript

Svelte has first-class TypeScript support. Add `lang="ts"` to `<script>` blocks and use `.svelte` files with full type checking via `svelte-check`.

## Basic TypeScript in Components

```svelte
<script lang="ts">
  type Status = 'idle' | 'loading' | 'success' | 'error';

  let status = $state<Status>('idle');
  let data = $state<string[]>([]);

  async function load() {
    status = 'loading';
    try {
      const res = await fetch('/api/items');
      data = await res.json();
      status = 'success';
    } catch {
      status = 'error';
    }
  }
</script>
```

---

## Typing Props

### Inline Type Annotation

```svelte
<script lang="ts">
  let {
    name,
    count = 0,
    variant = 'primary'
  }: {
    name: string;
    count?: number;
    variant?: 'primary' | 'secondary' | 'ghost';
  } = $props();
</script>
```

### Separate Type Declaration

```svelte
<script lang="ts">
  type Props = {
    title: string;
    description?: string;
    tags: string[];
    onclick?: (e: MouseEvent) => void;
  };

  let { title, description = '', tags, onclick }: Props = $props();
</script>
```

### Generic Components

```svelte
<script lang="ts" generics="T extends { id: string }">
  let { items, selected }: { items: T[]; selected: T | null } = $props();
</script>

{#each items as item}
  <div class:active={item === selected}>{item.id}</div>
{/each}
```

The `generics` attribute on `<script>` allows declaring generic type parameters for the component.

---

## Typing Snippets

Use the `Snippet` type from `'svelte'`:

```svelte
<script lang="ts">
  import type { Snippet } from 'svelte';

  let {
    children,
    header,
    row
  }: {
    children: Snippet;
    header?: Snippet<[string]>;      // snippet with one string argument
    row: Snippet<[{ id: string; name: string }]>; // snippet with one object argument
  } = $props();
</script>

{@render children()}
{@render header?.('Title')}
```

### Snippet with Multiple Parameters

```svelte
<script lang="ts">
  import type { Snippet } from 'svelte';

  type Cell<T> = Snippet<[value: T, row: T, index: number]>;

  let { cell }: { cell: Cell<string> } = $props();
</script>
```

---

## Wrapper Component Typing

When wrapping a native element to pass through all its attributes:

```svelte
<!-- Button.svelte -->
<script lang="ts">
  import type { HTMLButtonAttributes } from 'svelte/elements';

  let { children, class: className, ...attrs }: HTMLButtonAttributes & {
    children: import('svelte').Snippet;
  } = $props();
</script>

<button class="btn {className ?? ''}" {...attrs}>
  {@render children()}
</button>
```

### svelte/elements

The `svelte/elements` module exports TypeScript types for all HTML elements and their attributes:

```ts
import type {
  HTMLAttributes, // all HTML element attributes
  HTMLButtonAttributes, // <button> specific
  HTMLInputAttributes, // <input> specific
  HTMLAnchorAttributes, // <a> specific
  HTMLImgAttributes, // <img> specific
  HTMLFormAttributes, // <form> specific
  HTMLSelectAttributes, // <select> specific
  HTMLTextareaAttributes, // <textarea> specific
  SVGAttributes, // SVG element attributes
  MouseEventHandler, // event handler type
  KeyboardEventHandler,
  ChangeEventHandler,
  FocusEventHandler,
  FormEventHandler,
} from "svelte/elements";
```

**Example** — typed input wrapper:

```svelte
<!-- Input.svelte -->
<script lang="ts">
  import type { HTMLInputAttributes } from 'svelte/elements';

  let {
    label,
    error,
    ...attrs
  }: HTMLInputAttributes & {
    label: string;
    error?: string;
  } = $props();
</script>

<div class="field">
  <label>{label}</label>
  <input {...attrs} class:error={!!error} />
  {#if error}<p class="error-msg">{error}</p>{/if}
</div>
```

---

## Event Handler Types

```svelte
<script lang="ts">
  import type { MouseEventHandler, KeyboardEventHandler } from 'svelte/elements';

  const handleClick: MouseEventHandler<HTMLButtonElement> = (e) => {
    console.log(e.currentTarget.textContent);
  };

  const handleKey: KeyboardEventHandler<HTMLInputElement> = (e) => {
    if (e.key === 'Enter') submit();
  };
</script>

<button onclick={handleClick}>Click</button>
<input onkeydown={handleKey} />
```

Or inline without explicit types (TypeScript infers correctly):

```svelte
<button onclick={(e) => console.log(e.currentTarget)}>Click</button>
```

---

## Component Type Exports

Export types that consumers of your component can use:

```svelte
<!-- Counter.svelte -->
<script lang="ts" module>
  // Exported from the module — available to importers
  export type CounterProps = {
    initial?: number;
    step?: number;
  };
</script>

<script lang="ts">
  let { initial = 0, step = 1 }: CounterProps = $props();
  let count = $state(initial);
</script>
```

```ts
// consumer.ts
import type { CounterProps } from "./Counter.svelte";
```

---

## Typing Context

Use typed context with Symbol keys for type safety:

```ts
// context.ts
import { setContext, getContext } from "svelte";

type UserContext = {
  id: string;
  name: string;
  role: "admin" | "user";
};

const USER_KEY = Symbol("user");

export const setUserContext = (user: UserContext) => setContext(USER_KEY, user);

export const getUserContext = () => getContext<UserContext>(USER_KEY);
```

---

## Running Type Checks

```sh
# Check the project for type errors
npx svelte-check

# Or via mise (project-specific)
mise run check-frontend
```

`svelte-check` reports errors in `.svelte`, `.ts`, and `.js` files.

---

## tsconfig.json Recommendations

```json
{
  "compilerOptions": {
    "target": "ESNext",
    "module": "ESNext",
    "moduleResolution": "bundler",
    "strict": true,
    "verbatimModuleSyntax": true,
    "isolatedModules": true
  }
}
```

SvelteKit generates a `tsconfig.json` automatically — prefer extending it rather than replacing it.
