---
name: sveltekit
description: Build full-stack SvelteKit apps with file-based routing, load functions, form actions, hooks, adapters, and $app/* modules
---

# SvelteKit

SvelteKit is the official full-stack application framework for Svelte, powered by Vite. It handles routing, data loading, server-side rendering, form handling, and deployment.

- [SvelteKit docs](https://svelte.dev/docs/kit)

## Project Structure

```
src/
  routes/           ← file-based routing
    +layout.svelte  ← root layout (wraps all pages)
    +layout.ts      ← universal layout load function
    +layout.server.ts ← server-only layout load function
    +page.svelte    ← page component
    +page.ts        ← universal page load function
    +page.server.ts ← server-only load + form actions
    +error.svelte   ← error page
    [param]/        ← dynamic route segment
  lib/              ← shared code (aliased as $lib)
    index.ts
  app.html          ← HTML template
  app.css           ← global styles
static/             ← static assets (served at /)
svelte.config.js    ← SvelteKit + Svelte config
vite.config.ts      ← Vite config
```

## File Naming Conventions

| File                | Purpose                                             |
| ------------------- | --------------------------------------------------- |
| `+page.svelte`      | The page UI component                               |
| `+page.ts`          | Universal `load` function (runs on server + client) |
| `+page.server.ts`   | Server-only `load` + `actions`                      |
| `+layout.svelte`    | Layout wrapping child routes                        |
| `+layout.ts`        | Universal layout `load`                             |
| `+layout.server.ts` | Server-only layout `load`                           |
| `+error.svelte`     | Error page for this route segment                   |
| `+server.ts`        | API endpoint (GET/POST/etc. handlers)               |

## Quick Start

```svelte
<!-- src/routes/+page.svelte -->
<script lang="ts">
  import type { PageData } from './$types';

  let { data }: { data: PageData } = $props();
</script>

<h1>{data.title}</h1>
```

```ts
// src/routes/+page.server.ts
import type { PageServerLoad } from "./$types";

export const load: PageServerLoad = async ({ params, fetch, locals }) => {
  return { title: "Hello SvelteKit" };
};
```

## Topic Reference

### Core Concepts

- **[Routing](./routing.md)** — File-based routing, `+page.svelte`, `+layout.svelte`, `+error.svelte`, route params, parameter matching, route groups
- **[Loading Data](./loading-data.md)** — `load` functions, `+page.ts` vs `+page.server.ts`, `PageData`/`LayoutData` types, streaming with promises, `depends`/`invalidate`
- **[Form Actions](./form-actions.md)** — `actions` in `+page.server.ts`, `use:enhance`, `fail`, `applyAction`, progressive enhancement

### Configuration

- **[Page Options](./page-options.md)** — `ssr`, `csr`, `prerender`, `trailingSlash`, per-page and per-layout configuration

### Server & Infrastructure

- **[Hooks](./hooks.md)** — `handle`, `handleFetch`, `handleError` server hooks; `onNavigate`, `beforeNavigate`, `afterNavigate` client hooks; `sequence` helper
- **[Errors](./errors.md)** — `error()`, `redirect()`, `+error.svelte`, `handleError`, expected vs unexpected errors
- **[Adapters](./adapters.md)** — `adapter-auto`, `adapter-node`, `adapter-static`, deployment targets

### Client Navigation & State

- **[State Management](./state-management.md)** — `$app/state` (`page`, `navigating`, `updated`), `$app/navigation`, shallow routing, snapshots, URL state
- **[Advanced Routing](./advanced-routing.md)** — Optional params, rest segments, route matchers, layout groups, breaking out of layouts

### Module Reference

- **[Modules](./modules.md)** — All `$app/state`, `$app/navigation`, `$app/forms`, `$app/environment`, `$app/paths`, `$env/*`, `@sveltejs/kit` exports
