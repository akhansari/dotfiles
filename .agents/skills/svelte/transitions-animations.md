# Transitions & Animations

Svelte provides built-in support for element transitions, animations on keyed lists, element actions, and motion stores for smooth interpolated values.

## transition:

Plays a transition when an element enters or leaves the DOM (i.e., inside `{#if}`, `{#each}`, `{#key}` blocks).

```svelte
<script lang="ts">
  import { fade } from 'svelte/transition';
  let visible = $state(true);
</script>

<button onclick={() => (visible = !visible)}>Toggle</button>

{#if visible}
  <p transition:fade>Fades in and out</p>
{/if}
```

### Transition Parameters

```svelte
<script lang="ts">
  import { fly } from 'svelte/transition';
  let visible = $state(true);
</script>

{#if visible}
  <div transition:fly={{ y: 200, duration: 300 }}>
    Flies in from below
  </div>
{/if}
```

---

## in: and out:

Separate directives for enter and leave transitions:

```svelte
<script lang="ts">
  import { fade, fly } from 'svelte/transition';
</script>

{#if visible}
  <div in:fly={{ y: -20 }} out:fade>
    Different enter and leave
  </div>
{/if}
```

### transition:local vs transition:

By default, transitions play when their containing `{#if}` toggles AND when a parent block causes them to be added/removed. Add `|local` to only play when the immediate block toggles:

```svelte
<div transition:fade|local>...</div>
```

### global Modifier

Conversely, `|global` makes transitions play even when a parent `{#if}` is responsible:

```svelte
{#if visible}
  {#if moreVisible}
    <div transition:fade|global>...</div>
  {/if}
{/if}
```

---

## Built-in Transitions (svelte/transition)

```ts
import {
  fade,
  blur,
  fly,
  slide,
  scale,
  draw,
  crossfade,
} from "svelte/transition";
```

### fade

```svelte
<div transition:fade={{ duration: 300, easing: cubicOut }}>...</div>
```

Parameters: `delay`, `duration`, `easing`

### blur

```svelte
<div transition:blur={{ amount: 10, duration: 300 }}>...</div>
```

Parameters: `delay`, `duration`, `easing`, `opacity`, `amount`

### fly

```svelte
<div transition:fly={{ x: 0, y: 100, duration: 400 }}>...</div>
```

Parameters: `delay`, `duration`, `easing`, `x`, `y`, `opacity`

### slide

```svelte
<div transition:slide={{ duration: 300, axis: 'y' }}>...</div>
```

Parameters: `delay`, `duration`, `easing`, `axis` (`'x' | 'y'`)

### scale

```svelte
<div transition:scale={{ start: 0.5, duration: 300 }}>...</div>
```

Parameters: `delay`, `duration`, `easing`, `start`, `opacity`

### draw (for SVG paths)

```svelte
<svg viewBox="0 0 5 5">
  {#if visible}
    <path transition:draw={{ duration: 1000 }} d="M2,1 L3,3 L1,3 Z" />
  {/if}
</svg>
```

Parameters: `delay`, `speed`, `duration`, `easing`

### crossfade

Creates a pair of transitions for elements moving between two locations:

```svelte
<script lang="ts">
  import { crossfade } from 'svelte/transition';
  import { quintOut } from 'svelte/easing';

  const [send, receive] = crossfade({
    duration: 400,
    easing: quintOut
  });
</script>

<!-- Sending element -->
{#if !done}
  <li in:receive={{ key: item.id }} out:send={{ key: item.id }}>
    {item.text}
  </li>
{/if}

<!-- Receiving element -->
{#if done}
  <li in:receive={{ key: item.id }} out:send={{ key: item.id }}>
    {item.text}
  </li>
{/if}
```

---

## animate:

Animates elements in a keyed `{#each}` block when they are reordered. Uses the FLIP technique.

```svelte
<script lang="ts">
  import { flip } from 'svelte/animate';
</script>

{#each items as item (item.id)}
  <div animate:flip={{ duration: 300 }}>
    {item.text}
  </div>
{/each}
```

`flip` calculates start and end positions and animates between them. Parameters: `delay`, `duration`, `easing`.

---

## Custom Transitions

A transition is a function `(node: Element, params: object) => TransitionConfig`:

```ts
import type { TransitionConfig } from "svelte/transition";

function typewriter(
  node: HTMLElement,
  { speed = 50 }: { speed?: number } = {},
): TransitionConfig {
  const text = node.textContent ?? "";
  const duration = text.length * speed;

  return {
    duration,
    tick(t) {
      const i = Math.trunc(text.length * t);
      node.textContent = text.slice(0, i);
    },
  };
}
```

```svelte
{#if visible}
  <p transition:typewriter={{ speed: 30 }}>Hello world!</p>
{/if}
```

A transition can also return a CSS-based config:

```ts
function fade(
  node: Element,
  { duration = 400 }: { duration?: number } = {},
): TransitionConfig {
  return {
    duration,
    css: (t, u) => `opacity: ${t}; transform: scale(${0.8 + 0.2 * t})`,
  };
}
```

`t` goes from `0→1` for intro and `1→0` for outro. `u = 1 - t`.

---

## use: (Actions)

Actions are functions that attach imperative behavior to a DOM element. They receive the element and optional parameters, and optionally return an object with `update` and `destroy` methods.

```ts
// action.ts
import type { Action } from "svelte/action";

export const tooltip: Action<HTMLElement, string> = (node, text) => {
  let tooltipEl: HTMLElement | null = null;

  function show() {
    tooltipEl = document.createElement("div");
    tooltipEl.textContent = text;
    document.body.appendChild(tooltipEl);
  }

  function hide() {
    tooltipEl?.remove();
    tooltipEl = null;
  }

  node.addEventListener("mouseenter", show);
  node.addEventListener("mouseleave", hide);

  return {
    update(newText) {
      text = newText; // called when parameter changes
    },
    destroy() {
      node.removeEventListener("mouseenter", show);
      node.removeEventListener("mouseleave", hide);
    },
  };
};
```

```svelte
<script lang="ts">
  import { tooltip } from './action.ts';
  let message = $state('Hello!');
</script>

<button use:tooltip={message}>Hover me</button>
```

### Action Type

```ts
import type { Action } from "svelte/action";

// Action<Element, Params, Events>
const myAction: Action<HTMLButtonElement, { color: string }> = (
  node,
  params,
) => {
  // ...
};
```

### Actions with Custom Events

```ts
import type { Action } from "svelte/action";

const longpress: Action<
  HTMLElement,
  number,
  { onlongpress: (e: CustomEvent<null>) => void }
> = (node, duration = 500) => {
  let timer: ReturnType<typeof setTimeout>;

  node.addEventListener("mousedown", () => {
    timer = setTimeout(() => {
      node.dispatchEvent(new CustomEvent("longpress"));
    }, duration);
  });

  node.addEventListener("mouseup", () => clearTimeout(timer));
};
```

```svelte
<button use:longpress={800} onlongpress={() => alert('long press!')}>
  Hold me
</button>
```

---

## Easing Functions (svelte/easing)

```ts
import {
  linear,
  quadIn,
  quadOut,
  quadInOut,
  cubicIn,
  cubicOut,
  cubicInOut,
  quartIn,
  quartOut,
  quartInOut,
  quintIn,
  quintOut,
  quintInOut,
  sineIn,
  sineOut,
  sineInOut,
  expoIn,
  expoOut,
  expoInOut,
  circIn,
  circOut,
  circInOut,
  elasticIn,
  elasticOut,
  elasticInOut,
  backIn,
  backOut,
  backInOut,
  bounceIn,
  bounceOut,
  bounceInOut,
} from "svelte/easing";
```

All easing functions take `t` (0–1) and return a number (0–1).

---

## Motion Stores (svelte/motion)

### tweened

Creates a store that smoothly interpolates to new values:

```svelte
<script lang="ts">
  import { tweened } from 'svelte/motion';
  import { cubicOut } from 'svelte/easing';

  const progress = tweened(0, {
    duration: 400,
    easing: cubicOut
  });
</script>

<progress value={$progress} />
<button onclick={() => progress.set(1)}>Animate to 100%</button>
```

`tweened` options: `delay`, `duration`, `easing`, `interpolate`. `set` and `update` return Promises that resolve when the animation completes.

### spring

Creates a store that uses a spring physics model:

```svelte
<script lang="ts">
  import { spring } from 'svelte/motion';

  const coords = spring({ x: 50, y: 50 }, {
    stiffness: 0.1,
    damping: 0.25
  });
</script>

<svg onmousemove={(e) => coords.set({ x: e.clientX, y: e.clientY })}>
  <circle cx={$coords.x} cy={$coords.y} r="10" />
</svg>
```

Spring options: `stiffness` (0–1, default 0.15), `damping` (0–1, default 0.8), `precision` (default 0.01).
