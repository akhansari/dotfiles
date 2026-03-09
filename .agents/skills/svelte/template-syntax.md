# Template Syntax

Svelte's markup is HTML with superpowers. Lowercase tags are HTML elements; capitalised tags or dot-notation tags are components.

## Basic Markup

### Element Attributes

Standard HTML attributes work as-is. Attribute values can be JavaScript expressions:

```svelte
<a href="/page/{p}">page {p}</a>
<button disabled={!clickable}>click</button>
<input required={false} placeholder="optional" />
<div title={null}>no title attribute rendered</div>
```

Shorthand when name and value match:

```svelte
<button {disabled}>...</button>
<!-- equivalent to: <button disabled={disabled}>...</button> -->
```

### Spread Attributes

Pass many attributes at once. Order matters — later values win:

```svelte
<Widget a="b" {...things} c="d" />
```

### Text Expressions

Any JavaScript expression wrapped in `{}`:

```svelte
<h1>Hello {name}!</h1>
<p>{a} + {b} = {a + b}</p>
```

Null and undefined values are omitted. To render literal braces: `&lbrace;` and `&rbrace;`.

### Events

Event attributes start with `on`. They are case-sensitive:

```svelte
<button onclick={() => console.log('clicked')}>click me</button>
<input oninput={(e) => (value = e.currentTarget.value)} />
```

Shorthand form works too:

```svelte
<button {onclick}>click me</button>
```

Event attributes can be spread:

```svelte
<button {...handlers}>click me</button>
```

> **Note**: Common events (`click`, `input`, `keydown`, `mousedown`, etc.) are _delegated_ — a single listener at the app root handles them. When manually dispatching delegated events, use `{ bubbles: true }`.

---

## {#if ...}

Conditional rendering:

```svelte
{#if answer === 42}
  <p>what was the question?</p>
{/if}
```

With `{:else if}` and `{:else}`:

```svelte
{#if temperature > 100}
  <p>too hot!</p>
{:else if temperature < 80}
  <p>too cold!</p>
{:else}
  <p>just right!</p>
{/if}
```

Blocks can wrap text within elements, not just elements themselves.

---

## {#each ...}

Iterates over arrays, array-like objects, or iterables (`Map`, `Set`, etc.):

```svelte
<ul>
  {#each items as item}
    <li>{item.name} x {item.qty}</li>
  {/each}
</ul>
```

With index:

```svelte
{#each items as item, i}
  <li>{i + 1}: {item.name}</li>
{/each}
```

### Keyed Each Blocks

Provide a key to help Svelte efficiently update the list:

```svelte
{#each items as item (item.id)}
  <li>{item.name}</li>
{/each}

<!-- With index -->
{#each items as item, i (item.id)}
  <li>{i + 1}: {item.name}</li>
{/each}
```

Keys should be strings or numbers (primitives persist identity across object changes).

### Destructuring in Each

```svelte
{#each items as { id, name, qty } (id)}
  <li>{name} x {qty}</li>
{/each}

{#each objects as { id, ...rest }}
  <MyComponent {id} {...rest} />
{/each}
```

### Else Block

Rendered when the iterable is empty or null/undefined:

```svelte
{#each todos as todo}
  <p>{todo.text}</p>
{:else}
  <p>No todos yet!</p>
{/each}
```

### Each Without Item

Repeat a block N times:

```svelte
{#each { length: 3 } as _, i}
  <p>item {i}</p>
{/each}
```

---

## {#key ...}

Forces re-creation of its contents when the key expression changes. Useful to re-trigger transitions:

```svelte
{#key value}
  <div transition:fade>{value}</div>
{/key}
```

When used around a component, it destroys and re-creates the component instance:

```svelte
{#key $page.url.pathname}
  <PageView />
{/key}
```

---

## {#await ...}

Renders different content based on a Promise's state:

```svelte
{#await promise}
  <p>loading...</p>
{:then value}
  <p>the value is {value}</p>
{:catch error}
  <p>something went wrong: {error.message}</p>
{/await}
```

Skip the loading state:

```svelte
{#await promise then value}
  <p>{value}</p>
{/await}
```

Skip the error state:

```svelte
{#await promise then value}
  <p>{value}</p>
{/await}
```

### Inline await Expressions (Svelte 5)

In async components (requires `experimental.async` in `svelte.config.js`), you can use `await` directly in markup:

```svelte
<script lang="ts">
  async function getUser() { /* ... */ }
</script>

<p>Hello, {await getUser()}!</p>
```

---

## {#snippet ...} and {@render ...}

Snippets define reusable chunks of markup within (or passed to) a component. They replace Svelte 4 `<slot>`.

### Defining a Snippet

```svelte
{#snippet figure(image)}
  <figure>
    <img src={image.src} alt={image.caption} width={image.width} height={image.height} />
    <figcaption>{image.caption}</figcaption>
  </figure>
{/snippet}
```

### Rendering a Snippet

```svelte
{@render figure({ src: '/img.jpg', caption: 'A photo', width: 800, height: 600 })}
```

### Passing Snippets as Props

Snippets defined in a component's markup are accessible as props by child components:

```svelte
<!-- Parent.svelte -->
<Table {data}>
  {#snippet header()}
    <th>Name</th><th>Age</th>
  {/snippet}
  {#snippet row(item)}
    <td>{item.name}</td><td>{item.age}</td>
  {/snippet}
</Table>
```

```svelte
<!-- Table.svelte -->
<script lang="ts">
  import type { Snippet } from 'svelte';

  type Row = { name: string; age: number };
  let { data, header, row }: {
    data: Row[];
    header: Snippet;
    row: Snippet<[Row]>;
  } = $props();
</script>

<table>
  <thead><tr>{@render header()}</tr></thead>
  <tbody>
    {#each data as item}
      <tr>{@render row(item)}</tr>
    {/each}
  </tbody>
</table>
```

### children Snippet (Default Slot Replacement)

Content placed between component tags becomes the `children` snippet prop:

```svelte
<!-- Usage -->
<Button>Click me</Button>

<!-- Button.svelte -->
<script lang="ts">
  import type { Snippet } from 'svelte';
  let { children }: { children: Snippet } = $props();
</script>

<button>{@render children()}</button>
```

### Optional Snippets

Check with `{#if}` before rendering:

```svelte
{#if header}
  {@render header()}
{/if}
```

Or use `?.()` in the render call (snippets are functions):

```svelte
{@render header?.()}
```

### Snippet Scope

Snippets have access to variables in their outer scope but not inside loops:

```svelte
{#each images as image}
  {#snippet caption()}
    <!-- `image` is accessible here -->
    <figcaption>{image.caption}</figcaption>
  {/snippet}
  <figure>
    <img src={image.src} />
    {@render caption()}
  </figure>
{/each}
```

---

## {@html ...}

Renders raw unescaped HTML. **XSS risk** — only use with trusted or sanitized content:

```svelte
<div class="prose">{@html sanitizedContent}</div>
```

---

## {@attach ...}

Attaches imperative DOM behavior to an element declaratively. The attachment function receives the element and can return a cleanup function.

```svelte
<script lang="ts">
  function tooltip(element: HTMLElement, text: string) {
    const tip = createTooltip(text);
    element.appendChild(tip);
    return () => tip.remove(); // cleanup
  }
</script>

<button {@attach tooltip('Hello!')}>Hover me</button>
```

Attachments created with `createAttachmentKey` can be passed around as props:

```ts
import { createAttachmentKey } from 'svelte/attachments';

const highlight = createAttachmentKey((node: HTMLElement) => {
  node.style.background = 'yellow';
});

// pass as a prop
<Component {[highlight]: true} />
```

---

## {@const ...}

Declares a local constant inside a block (each, if, snippet, etc.):

```svelte
{#each boxes as box}
  {@const area = box.width * box.height}
  <p>{box.width} × {box.height} = {area}</p>
{/each}
```

---

## {@debug ...}

Dev-only. Logs values to the console and triggers a breakpoint when they change:

```svelte
{@debug user}
<p>Hello, {user.name}!</p>
```

With multiple values:

```svelte
{@debug user, someOtherVariable}
```

`{@debug}` with no arguments pauses whenever any state in the component changes.

---

## bind:

Two-way binding between a variable and an element property.

### Form Elements

```svelte
<input bind:value={name} />
<input type="checkbox" bind:checked={subscribed} />
<input type="number" bind:value={count} />
<textarea bind:value={content} />
<select bind:value={selectedColor}>
  <option value="red">Red</option>
  <option value="green">Green</option>
</select>
```

Shorthand when the variable name matches:

```svelte
<input bind:value />
<!-- equivalent to: <input bind:value={value} /> -->
```

### Multiple Select

```svelte
<select multiple bind:value={selectedColors}>
  <option value="red">Red</option>
  <option value="green">Green</option>
  <option value="blue">Blue</option>
</select>
```

### Function Bindings (Svelte 5)

Provide separate getter and setter functions for full control:

```svelte
<input
  bind:value={() => name, (v) => (name = v.trim())}
/>
```

Useful for derived two-way bindings:

```svelte
<script lang="ts">
  const total = 100;
  let spent = $state(0);
  let left = $derived(total - spent);

  function updateLeft(val: number) {
    spent = total - val;
  }
</script>

<input type="range" bind:value={spent} max={total} />
<input type="range" bind:value={() => left, updateLeft} max={total} />
```

### DOM Properties

```svelte
<!-- Dimensions (read-only) -->
<div bind:clientWidth={w} bind:clientHeight={h} bind:offsetWidth bind:offsetHeight />

<!-- Scroll position -->
<div bind:scrollX={x} bind:scrollY={y} />

<!-- Media elements -->
<video
  bind:duration
  bind:currentTime
  bind:paused
  bind:muted
  bind:volume
/>

<!-- Contenteditable -->
<div contenteditable bind:textContent={text} bind:innerHTML={html} />

<!-- Details element -->
<details bind:open={isOpen}>...</details>
```

### Component Props

```svelte
<FancyInput bind:value={message} />
```

Only works if the child prop is declared with `$bindable`.
