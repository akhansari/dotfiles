# Routing

SvelteKit uses a file-based router. Each `+page.svelte` file inside `src/routes/` corresponds to a URL.

## Basic Routes

```
src/routes/
  +page.svelte        → /
  about/
    +page.svelte      → /about
  blog/
    +page.svelte      → /blog
    [slug]/
      +page.svelte    → /blog/:slug
```

## +page.svelte

The page UI component. Receives `data` from the `load` function.

```svelte
<!-- src/routes/blog/[slug]/+page.svelte -->
<script lang="ts">
  import type { PageData } from './$types';

  let { data }: { data: PageData } = $props();
</script>

<article>
  <h1>{data.post.title}</h1>
  <div>{@html data.post.content}</div>
</article>
```

## +layout.svelte

Wraps child routes. The `children` snippet renders the current page.

```svelte
<!-- src/routes/+layout.svelte -->
<script lang="ts">
  import type { LayoutData } from './$types';
  import type { Snippet } from 'svelte';

  let { data, children }: { data: LayoutData; children: Snippet } = $props();
</script>

<nav>
  <a href="/">Home</a>
  <a href="/about">About</a>
</nav>

{@render children()}
```

Layouts are nested: a route inside `blog/` inherits both the root layout and any `blog/+layout.svelte`.

## +error.svelte

Rendered when an error occurs in the route segment or any child route. Receives the error via `$app/state`.

```svelte
<!-- src/routes/+error.svelte -->
<script lang="ts">
  import { page } from '$app/state';
</script>

<h1>{page.status}: {page.error?.message}</h1>
```

---

## Dynamic Route Segments

Square brackets create dynamic parameters:

```
src/routes/
  [slug]/+page.svelte        → /any-string → params.slug
  [category]/[id]/+page.svelte → /a/123 → params.category, params.id
  [...rest]/+page.svelte      → /a/b/c → params.rest = 'a/b/c'
  [[optional]]/+page.svelte  → / or /value → params.optional
```

### Accessing params

```ts
// +page.server.ts
import type { PageServerLoad } from "./$types";

export const load: PageServerLoad = async ({ params }) => {
  const { slug } = params;
  return { slug };
};
```

### Parameter Matching

Constrain dynamic params with a matcher in `src/params/`:

```ts
// src/params/integer.ts
import type { ParamMatcher } from "@sveltejs/kit";

export const match: ParamMatcher = (param) => /^\d+$/.test(param);
```

```
src/routes/
  [id=integer]/+page.svelte  → only matches if id is an integer
```

---

## Route Groups

Parenthetical directories group routes without affecting the URL:

```
src/routes/
  (app)/
    +layout.svelte    ← layout for app routes (doesn't add to URL)
    dashboard/
      +page.svelte    → /dashboard
    settings/
      +page.svelte    → /settings
  (marketing)/
    +layout.svelte    ← different layout for marketing pages
    +page.svelte      → /
    about/
      +page.svelte    → /about
```

Groups are useful for applying different layouts to routes without nesting the URL.

---

## Breaking Out of Layouts

To escape a parent layout, use a `@` segment:

```
src/routes/
  +layout.svelte          ← root layout
  (app)/
    +layout.svelte        ← app layout
    admin/
      +page@.svelte       ← uses root layout only (skips app layout)
      +page@(app).svelte  ← uses (app) layout (same behavior here)
```

`+page@(group).svelte` resets to the specified group's layout. `+page@.svelte` resets to the root layout.

---

## +server.ts (API Routes)

Define HTTP endpoint handlers. Useful for REST APIs or webhooks.

```ts
// src/routes/api/items/+server.ts
import type { RequestHandler } from "./$types";
import { json } from "@sveltejs/kit";

export const GET: RequestHandler = async ({ url, locals }) => {
  const items = await locals.db.getItems();
  return json(items);
};

export const POST: RequestHandler = async ({ request }) => {
  const body = await request.json();
  // handle creation...
  return json({ success: true }, { status: 201 });
};
```

Available methods: `GET`, `POST`, `PUT`, `PATCH`, `DELETE`, `OPTIONS`, `HEAD`.

### Returning Responses

```ts
import { json, text, error, redirect } from "@sveltejs/kit";

return json({ key: "value" });
return text("plain text");
return new Response("custom", { headers: { "content-type": "text/plain" } });
return error(400, "Bad request");
return redirect(302, "/login");
```

---

## $types

SvelteKit generates types in `./$types.d.ts` for every route. Always import from `./$types`:

```ts
import type {
  PageData, // data returned by +page.ts load
  PageServerData, // data returned by +page.server.ts load
  LayoutData, // data returned by +layout.ts load
  PageServerLoad, // type for the load function in +page.server.ts
  PageLoad, // type for the load function in +page.ts
  LayoutServerLoad, // type for the load function in +layout.server.ts
  LayoutLoad, // type for the load function in +layout.ts
  Actions, // type for the actions export in +page.server.ts
  RequestHandler, // type for handlers in +server.ts
  RouteParams, // params object type for this route
} from "./$types";
```

---

## Navigation

### \<a\> Tags

Standard `<a>` tags trigger SvelteKit client-side navigation automatically. The router intercepts clicks on same-origin links.

```svelte
<a href="/about">About</a>
<a href="/blog/{post.slug}">{post.title}</a>
```

### Data Attributes

Control navigation behavior per-link:

```svelte
<!-- Disable prefetching -->
<a href="/heavy-page" data-sveltekit-preload-data="off">Heavy page</a>

<!-- Force full page reload -->
<a href="/legacy" data-sveltekit-reload>Legacy page</a>

<!-- Prevent navigation (e.g., in a nav item) -->
<a href="/" data-sveltekit-noscroll>No scroll reset</a>
```

### Programmatic Navigation

```ts
import { goto, back, forward, preloadData, preloadCode } from "$app/navigation";

// Navigate to a URL
await goto("/dashboard");
await goto("/search?q=svelte", { replaceState: true });
await goto("/page", { noScroll: true, invalidateAll: true });

// Navigate back/forward
await back();
await forward();

// Prefetch
await preloadData("/about");
await preloadCode("/admin");
```
