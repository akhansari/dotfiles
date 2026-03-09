# Advanced Routing

## Optional Parameters

Wrap a parameter in double square brackets to make it optional:

```
src/routes/
  [[lang]]/+page.svelte     → / or /en or /fr
  [[lang]]/about/+page.svelte → /about or /en/about
```

```ts
// +page.server.ts
export const load: PageServerLoad = async ({ params }) => {
  const lang = params.lang ?? "en"; // lang is string | undefined
  return { lang };
};
```

---

## Rest Parameters

Capture multiple path segments with `[...rest]`:

```
src/routes/
  docs/[...path]/+page.svelte → /docs/a/b/c → params.path = 'a/b/c'
  [...404]/+page.svelte       → catch-all for unmatched routes
```

```ts
export const load: PageServerLoad = async ({ params }) => {
  const segments = params.path.split("/");
  return { segments };
};
```

### 404 Catch-All

```svelte
<!-- src/routes/[...404]/+page.svelte -->
<script lang="ts">
  import { page } from '$app/state';
</script>

<h1>404 — Page not found</h1>
<p>Could not find: {page.url.pathname}</p>
```

---

## Route Matchers

Constrain dynamic parameters with a custom matcher function. Place matchers in `src/params/`:

```ts
// src/params/uuid.ts
import type { ParamMatcher } from "@sveltejs/kit";

export const match: ParamMatcher = (param) =>
  /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(param);
```

```ts
// src/params/integer.ts
import type { ParamMatcher } from "@sveltejs/kit";

export const match: ParamMatcher = (param) => /^\d+$/.test(param);
```

Apply matchers with `=`:

```
src/routes/
  users/[id=uuid]/+page.svelte     → only matches valid UUIDs
  items/[id=integer]/+page.svelte  → only matches integers
```

When a matcher fails, SvelteKit falls through to the next matching route (or 404).

---

## Route Groups

Parenthetical directories group routes for shared layouts without affecting the URL:

```
src/routes/
  (authenticated)/
    +layout.server.ts  ← auth check for all routes in this group
    +layout.svelte     ← authenticated layout (nav, sidebar)
    dashboard/
      +page.svelte     → /dashboard
    profile/
      +page.svelte     → /profile
  (public)/
    +layout.svelte     ← minimal public layout
    +page.svelte       → /
    login/
      +page.svelte     → /login
```

```ts
// src/routes/(authenticated)/+layout.server.ts
import type { LayoutServerLoad } from "./$types";
import { redirect } from "@sveltejs/kit";

export const load: LayoutServerLoad = async ({ locals }) => {
  if (!locals.user) {
    redirect(302, "/login");
  }
  return { user: locals.user };
};
```

---

## Breaking Out of Layouts

Use `@` to reset to a specific layout:

```
src/routes/
  +layout.svelte              ← root layout
  (app)/
    +layout.svelte            ← app layout
    settings/
      +page.svelte            ← uses (app) layout
      +page@.svelte           ← uses root layout (skips (app))
      +page@(app).svelte      ← explicitly uses (app) layout
  admin/
    +page@.svelte             ← uses root layout only
```

The segment after `@` is the name of the group whose layout to use. `.` means the root (unnamed) layout.

---

## Parallel Routes (Route Slots)

SvelteKit does not natively support parallel routes, but you can achieve similar patterns with layouts and load function composition.

---

## Route Resolution Order

When multiple routes could match a URL, SvelteKit uses this priority:

1. More specific routes over less specific (static segments before dynamic)
2. Dynamic params `[param]` before rest params `[...rest]`
3. Routes with matchers `[id=uuid]` before plain `[id]`
4. Within the same specificity, lexicographic order (alphabetical)

```
/blog/new    → matches /blog/new (static) over /blog/[slug] (dynamic)
/blog/123    → matches /blog/[id=integer] over /blog/[slug] if integer matcher exists
```

---

## Preloading Routes

Use `data-sveltekit-preload-data` and `data-sveltekit-preload-code` on links for faster navigation:

```svelte
<!-- Preload data when hovering -->
<a href="/dashboard" data-sveltekit-preload-data="hover">Dashboard</a>

<!-- Preload on tap start (mobile-friendly) -->
<a href="/profile" data-sveltekit-preload-data="tap">Profile</a>

<!-- Preload JS bundle only (not data) -->
<a href="/admin" data-sveltekit-preload-code="hover">Admin</a>

<!-- Disable preloading for this link -->
<a href="/download" data-sveltekit-preload-data="off">Download</a>
```

Apply to a container to affect all links inside:

```svelte
<nav data-sveltekit-preload-data="hover">
  <a href="/">Home</a>
  <a href="/about">About</a>
  <a href="/blog">Blog</a>
</nav>
```

---

## Link Options Summary

| Attribute                     | Values                                     | Description                           |
| ----------------------------- | ------------------------------------------ | ------------------------------------- |
| `data-sveltekit-preload-data` | `hover`, `tap`, `off`                      | When to preload route data            |
| `data-sveltekit-preload-code` | `eager`, `viewport`, `hover`, `tap`, `off` | When to preload JS bundle             |
| `data-sveltekit-reload`       | (present/absent)                           | Force full page reload                |
| `data-sveltekit-replacestate` | (present/absent)                           | Replace history entry instead of push |
| `data-sveltekit-noscroll`     | (present/absent)                           | Don't scroll to top after navigation  |
| `data-sveltekit-keepfocus`    | (present/absent)                           | Keep focus on current element         |
