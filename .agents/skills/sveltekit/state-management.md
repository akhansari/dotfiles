# State Management

SvelteKit provides reactive state via `$app/state` that reflects the current page, navigation, and app version. This integrates with Svelte 5's reactivity model.

## $app/state

The primary module for accessing current application state. Values are reactive — using them in templates automatically updates when they change.

```ts
import { page, navigating, updated } from "$app/state";
```

### page

Contains information about the current page. Reactive — updates on every navigation.

```svelte
<script lang="ts">
  import { page } from '$app/state';
</script>

<!-- URL info -->
<p>Path: {page.url.pathname}</p>
<p>Query: {page.url.searchParams.get('q')}</p>

<!-- Route info -->
<p>Route ID: {page.route.id}</p>

<!-- Params -->
<p>Slug: {page.params.slug}</p>

<!-- Page data (from load functions) -->
<p>Title: {page.data.title}</p>

<!-- Error info (in +error.svelte) -->
<p>{page.status}: {page.error?.message}</p>
```

**page properties:**
| Property | Type | Description |
|---|---|---|
| `page.url` | `URL` | Current URL object |
| `page.params` | `Record<string, string>` | Route parameters |
| `page.route.id` | `string \| null` | Route ID (file path from src/routes) |
| `page.status` | `number` | HTTP status code |
| `page.error` | `App.Error \| null` | Error object (in error pages) |
| `page.data` | `App.PageData` | Merged data from all `load` functions |
| `page.form` | `unknown` | Most recent form action result |
| `page.state` | `Record<string, unknown>` | History state (for shallow routing) |

### navigating

Contains information about an in-progress navigation, or `null` when not navigating.

```svelte
<script lang="ts">
  import { navigating } from '$app/state';
</script>

{#if navigating.to}
  <div class="loading-bar" />
{/if}
```

**navigating properties (when not null):**

```ts
{
  from: { url: URL; params: Record<string, string>; route: { id: string | null } } | null;
  to:   { url: URL; params: Record<string, string>; route: { id: string | null } } | null;
  type: 'link' | 'popstate' | 'goto';
  delta: number; // for popstate navigations
}
```

### updated

`updated.current` is `true` when a new version of the app has been deployed (detected via polling):

```svelte
<script lang="ts">
  import { updated } from '$app/state';
</script>

{#if updated.current}
  <div class="banner">
    A new version is available.
    <button onclick={() => location.reload()}>Refresh</button>
  </div>
{/if}
```

Check manually:

```ts
import { updated } from "$app/state";
const hasUpdate = await updated.check();
```

---

## $app/navigation

Functions for programmatic navigation and lifecycle.

```ts
import {
  goto,
  back,
  forward,
  pushState,
  replaceState,
  preloadData,
  preloadCode,
  invalidate,
  invalidateAll,
  beforeNavigate,
  afterNavigate,
  onNavigate,
} from "$app/navigation";
```

### goto

```ts
// Basic navigation
await goto("/dashboard");

// With query params
await goto("/search?" + new URLSearchParams({ q: "svelte" }));

// Options
await goto("/page", {
  replaceState: false, // add to history (default)
  noScroll: false, // scroll to top (default)
  keepFocus: false, // reset focus (default)
  invalidateAll: false, // don't re-run load functions (default)
  state: { key: "value" }, // push to history state
});
```

### pushState / replaceState (Shallow Routing)

Update the URL without triggering navigation or re-running `load` functions. Useful for modals, drawers, and URL-encoded UI state.

```svelte
<script lang="ts">
  import { pushState, replaceState } from '$app/navigation';
  import { page } from '$app/state';

  function openModal(photoId: string) {
    // Push new state — back button returns to previous URL
    pushState(`?photo=${photoId}`, { showingModal: true });
  }

  function closeModal() {
    // Go back to remove the modal URL state
    history.back();
  }

  // Restore modal state from URL on page load / forward navigation
  $effect(() => {
    if (page.url.searchParams.has('photo')) {
      // show modal
    }
  });
</script>

<button onclick={() => openModal('123')}>Open Photo</button>

{#if page.url.searchParams.has('photo')}
  <Modal onclose={closeModal} />
{/if}
```

### invalidate / invalidateAll

Re-run `load` functions without a full navigation:

```ts
// Invalidate loads that depend on this URL
await invalidate("/api/user");

// Invalidate loads that called `depends('app:user')`
await invalidate("app:user");

// Invalidate everything
await invalidateAll();
```

### preloadData / preloadCode

Pre-fetch a route's data and/or code bundle:

```ts
await preloadData("/about"); // fetches data
await preloadCode("/admin"); // fetches JS bundle
```

---

## Snapshots

Preserve ephemeral UI state (scroll position, form values, accordion state) across navigations.

```svelte
<!-- +page.svelte -->
<script lang="ts">
  import type { Snapshot } from './$types';

  let expanded = $state(false);
  let scrollTop = $state(0);

  export const snapshot: Snapshot<{ expanded: boolean; scrollTop: number }> = {
    capture: () => ({ expanded, scrollTop }),
    restore: (value) => {
      expanded = value.expanded;
      scrollTop = value.scrollTop;
    }
  };
</script>
```

Snapshots are stored in `sessionStorage` and restored when the user navigates back.

---

## URL State Patterns

### Syncing UI with URL Search Params

```svelte
<script lang="ts">
  import { goto } from '$app/navigation';
  import { page } from '$app/state';

  // Derive filter from URL
  let filter = $derived(page.url.searchParams.get('filter') ?? 'all');
  let search = $derived(page.url.searchParams.get('q') ?? '');

  function setFilter(value: string) {
    const url = new URL(page.url);
    url.searchParams.set('filter', value);
    goto(url, { replaceState: true, noScroll: true, keepFocus: true });
  }
</script>

<div>
  <input value={search} oninput={(e) => setSearch(e.currentTarget.value)} />
  <button class:active={filter === 'all'} onclick={() => setFilter('all')}>All</button>
  <button class:active={filter === 'active'} onclick={() => setFilter('active')}>Active</button>
</div>
```

### Modal via Shallow Routing

```svelte
<script lang="ts">
  import { pushState } from '$app/navigation';
  import { page } from '$app/state';
  import Modal from './Modal.svelte';

  function openPhoto(id: string) {
    pushState('', { selectedPhoto: id });
  }
</script>

{#each photos as photo}
  <img src={photo.thumbnail} onclick={() => openPhoto(photo.id)} />
{/each}

{#if page.state.selectedPhoto}
  <Modal
    photoId={page.state.selectedPhoto}
    onclose={() => history.back()}
  />
{/if}
```

---

## $app/stores (Legacy)

> **Note**: `$app/stores` is the Svelte 4 API. Prefer `$app/state` in Svelte 5 projects.

```ts
// Legacy — still works but not recommended for new code
import { page, navigating, updated } from "$app/stores";

// Requires store subscription syntax ($page, $navigating, etc.)
```

```svelte
<!-- Legacy usage -->
<p>{$page.url.pathname}</p>

<!-- Modern equivalent -->
<p>{page.url.pathname}</p>
```
