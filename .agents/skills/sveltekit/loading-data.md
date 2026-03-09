# Loading Data

SvelteKit uses `load` functions to fetch data for pages and layouts before they render. There are two types: **universal** (runs on both server and client) and **server** (runs only on server).

## Load Function Types

| File                | Runs on          | Access to DB/secrets | Returns            |
| ------------------- | ---------------- | -------------------- | ------------------ |
| `+page.ts`          | Server + Browser | No                   | `PageData`         |
| `+page.server.ts`   | Server only      | Yes                  | `PageServerData`   |
| `+layout.ts`        | Server + Browser | No                   | `LayoutData`       |
| `+layout.server.ts` | Server only      | Yes                  | `LayoutServerData` |

When both `+page.ts` and `+page.server.ts` exist, the server load runs first and its return value is available in the universal load as `data.serverData`.

---

## +page.server.ts Load

Runs exclusively on the server. Has access to `locals`, cookies, and server resources. Can return any serializable value.

```ts
// src/routes/blog/[slug]/+page.server.ts
import type { PageServerLoad } from "./$types";
import { error } from "@sveltejs/kit";

export const load: PageServerLoad = async ({
  params,
  locals,
  fetch,
  cookies,
}) => {
  const post = await locals.db.posts.findOne(params.slug);

  if (!post) {
    error(404, "Post not found");
  }

  return {
    post,
    views: post.views,
  };
};
```

### Load Function Parameters

```ts
export const load: PageServerLoad = async ({
  params, // route params { slug: string }
  url, // URL object
  route, // { id: string } — the route's file path
  fetch, // server-aware fetch (cookies, relative URLs)
  locals, // from hooks handle function (DB, auth, etc.)
  cookies, // server-side cookie access
  request, // Request object (headers, etc.)
  setHeaders, // set response headers
  depends, // declare dependencies for invalidation
  parent, // await parent layout data
  untrack, // read without registering as dependency
}) => {
  // ...
};
```

---

## +page.ts Universal Load

Runs on the server during SSR and in the browser during client navigation. Has access to `fetch` but not `locals`, cookies, or `request`.

```ts
// src/routes/blog/+page.ts
import type { PageLoad } from "./$types";

export const load: PageLoad = async ({ fetch, url, data }) => {
  // `data` is the merged data from +page.server.ts (if it exists)
  const page = parseInt(url.searchParams.get("page") ?? "1");
  const posts = await fetch(`/api/posts?page=${page}`).then((r) => r.json());

  return { posts, page };
};
```

---

## Accessing Data in Pages and Layouts

Data is passed automatically to the component as the `data` prop:

```svelte
<!-- +page.svelte -->
<script lang="ts">
  import type { PageData } from './$types';

  let { data }: { data: PageData } = $props();
</script>

<h1>{data.post.title}</h1>
```

```svelte
<!-- +layout.svelte -->
<script lang="ts">
  import type { LayoutData } from './$types';
  import type { Snippet } from 'svelte';

  let { data, children }: { data: LayoutData; children: Snippet } = $props();
</script>

<nav>Logged in as {data.user?.name}</nav>
{@render children()}
```

---

## Parent Layout Data

Access data from parent layouts using `await parent()`:

```ts
// src/routes/blog/[slug]/+page.server.ts
import type { PageServerLoad } from "./$types";

export const load: PageServerLoad = async ({ parent }) => {
  const { user } = await parent(); // from root +layout.server.ts

  return { canEdit: user?.role === "admin" };
};
```

> **Caution**: Calling `parent()` can create waterfalls. Only use it when you genuinely need parent data.

---

## setHeaders

Set response headers from `load`:

```ts
export const load: PageServerLoad = async ({ setHeaders }) => {
  setHeaders({
    "cache-control": "max-age=3600",
    "x-custom-header": "value",
  });

  return {
    /* ... */
  };
};
```

---

## Invalidation & Dependencies

### depends

Declare custom dependencies that can be invalidated:

```ts
export const load: PageLoad = async ({ depends }) => {
  depends("app:user"); // register custom dependency key

  const user = await getUser();
  return { user };
};
```

```ts
import { invalidate } from "$app/navigation";

// Invalidate all loads that depend on 'app:user'
await invalidate("app:user");

// Invalidate all loads that used a specific URL
await invalidate("/api/user");

// Invalidate everything
import { invalidateAll } from "$app/navigation";
await invalidateAll();
```

### URL-based Invalidation

Any URL fetched via the load's `fetch` parameter is automatically tracked. Calling `invalidate(url)` re-runs all loads that fetched that URL.

---

## Streaming with Promises

Return unresolved Promises from `load` to stream data to the client. The page renders immediately with the non-promise data, and updates when the promises resolve.

```ts
// +page.server.ts
export const load: PageServerLoad = async () => {
  return {
    // This resolves immediately — blocks render
    criticalData: await getCriticalData(),

    // These stream in — page renders without waiting
    slowData: getSlowData(), // Promise — NOT awaited
    moreData: getMoreData(), // Promise — NOT awaited
  };
};
```

```svelte
<!-- +page.svelte -->
<script lang="ts">
  import type { PageData } from './$types';
  let { data }: { data: PageData } = $props();
</script>

<h1>{data.criticalData.title}</h1>

{#await data.slowData}
  <p>Loading slow data...</p>
{:then slow}
  <p>{slow.result}</p>
{:catch error}
  <p>Error: {error.message}</p>
{/await}
```

> **Note**: Streaming requires a host that supports it (not static adapters). Server load functions only — universal loads cannot stream.

---

## Redirects and Errors in Load

```ts
import { error, redirect } from "@sveltejs/kit";

export const load: PageServerLoad = async ({ locals }) => {
  if (!locals.user) {
    redirect(302, "/login");
  }

  const resource = await getResource();
  if (!resource) {
    error(404, "Resource not found");
  }

  return { resource };
};
```

See [Errors](./errors.md) for full error handling documentation.

---

## Using $app/state in Load

The `page` store from `$app/state` is available in universal loads but **not** in server loads:

```ts
// +page.ts (universal — has access to browser state on client)
export const load: PageLoad = async ({ url }) => {
  // Use `url` parameter instead of page.url in load functions
  const query = url.searchParams.get("q");
  return { query };
};
```

In components, read page data reactively:

```svelte
<script lang="ts">
  import { page } from '$app/state';
</script>

<p>Current path: {page.url.pathname}</p>
<p>Params: {JSON.stringify(page.params)}</p>
```
