---
name: svelte
description: Write idiomatic Svelte 5 components using runes, reactivity, template syntax, snippets, transitions, and TypeScript
---

# Svelte 5

Svelte is a compiler-based UI framework. Components are written in `.svelte` files using a superset of HTML. The compiler turns declarative components into lean, optimized JavaScript — there is no virtual DOM.

- [Svelte docs](https://svelte.dev/docs/svelte)
- [Svelte playground](https://svelte.dev/playground)

## Project Rules

- **Never use `bind:this`** — use attachments (`{@attach}`) or actions (`use:`) instead for imperative DOM access
- Always use Svelte 5 runes syntax — never use legacy Svelte 4 patterns (`$:`, `export let`, `on:`, `<slot>`)
- Prefer `$derived` over `$effect` for computed values — effects are escape hatches, not data flow tools
- Use `lang="ts"` in `<script>` blocks and type all props

## Component File Structure

```svelte
<script module>
  // Module-level logic: runs once when the module first evaluates
  // Exports here become exports of the compiled module
</script>

<script lang="ts">
  // Instance-level logic: runs for each component instance
  // Runes, props, local state, effects go here
</script>

<!-- Markup: HTML superset with template syntax -->

<style>
  /* Scoped CSS: only applies to elements in this component */
</style>
```

All three sections are optional. `.svelte.ts` and `.svelte.js` files can use runes but contain no markup.

## Runes Overview

Runes are compiler keywords prefixed with `$`. They are not functions — you cannot assign them to variables or pass them as arguments.

| Rune        | Purpose                                                    |
| ----------- | ---------------------------------------------------------- |
| `$state`    | Reactive state (deeply proxied for objects/arrays)         |
| `$derived`  | Computed value that updates when dependencies change       |
| `$effect`   | Side effect that re-runs when reactive dependencies change |
| `$props`    | Declare component input properties                         |
| `$bindable` | Mark a prop as two-way bindable                            |
| `$inspect`  | Dev-only reactive `console.log`                            |
| `$host`     | Access host element when compiled as a custom element      |

```svelte
<script lang="ts">
  let count = $state(0);
  let doubled = $derived(count * 2);

  $effect(() => {
    console.log('count is', count);
  });
</script>

<button onclick={() => count++}>
  {count} × 2 = {doubled}
</button>
```

## Quick Reference: Template Syntax

```svelte
<!-- Conditional -->
{#if condition}...{:else if other}...{:else}...{/if}

<!-- List iteration -->
{#each items as item (item.id)}...{:else}...{/each}

<!-- Await async values -->
{#await promise}loading...{:then value}{value}{:catch error}{error}{/await}

<!-- Reusable markup chunks -->
{#snippet mySnippet(arg)}...{/snippet}
{@render mySnippet(value)}

<!-- Raw HTML (XSS risk — sanitize input) -->
{@html trustedHtmlString}

<!-- Local constant -->
{@const x = y * 2}
```

## Topic Reference

Read the relevant file when working in that area:

### Reactivity & State

- **[Runes](./runes.md)** — `$state`, `$derived`, `$effect`, `$props`, `$bindable`, `$inspect`, `$host` — all rune APIs with full examples
- **[Reactivity](./reactivity.md)** — Deep state proxies, `$state.raw`, `$state.snapshot`, `$state.eager`, `$derived.by`, `untrack`, passing state across modules

### Template & Markup

- **[Template Syntax](./template-syntax.md)** — `{#if}`, `{#each}`, `{#key}`, `{#await}`, `{#snippet}`, `{@render}`, `{@html}`, `{@attach}`, `{@const}`, `{@debug}`, events, spread attributes, basic markup

### Styling

- **[Styling](./styling.md)** — Scoped styles, `:global()`, `style:` directive, `class` directive, CSS custom properties, nested style elements

### Lifecycle & Runtime

- **[Lifecycle](./lifecycle.md)** — `onMount`, `onDestroy`, `tick`, `getContext`/`setContext`, imperative component API, `svelte/reactivity` built-in reactive classes (`SvelteMap`, `SvelteSet`, `SvelteDate`, `SvelteURL`)

### Shared State

- **[Stores & Context](./stores-context.md)** — `writable`, `readable`, `derived` stores from `svelte/store`, `setContext`/`getContext` for passing data through the component tree

### Special Elements

- **[Special Elements](./special-elements.md)** — `<svelte:boundary>`, `<svelte:window>`, `<svelte:document>`, `<svelte:body>`, `<svelte:head>`, `<svelte:element>`, `<svelte:options>`

### TypeScript

- **[TypeScript](./typescript.md)** — Typing props, typing snippets, wrapper component types, `svelte/elements` module, event handler types

### Animations & Actions

- **[Transitions & Animations](./transitions-animations.md)** — `transition:`, `in:`/`out:`, `animate:`, `use:` actions, built-in transitions (`fade`, `fly`, `slide`, `blur`, `scale`), easing functions, `tweened`/`spring` motion stores
