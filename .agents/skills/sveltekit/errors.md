# Errors

SvelteKit distinguishes between expected errors (thrown intentionally with `error()`) and unexpected errors (unhandled exceptions).

## error()

Throws an expected HTTP error from a `load` function or server route. SvelteKit renders `+error.svelte` instead of the normal page.

```ts
import { error } from "@sveltejs/kit";

export const load: PageServerLoad = async ({ params, locals }) => {
  const post = await locals.db.posts.findOne(params.slug);

  if (!post) {
    error(404, "Post not found");
  }

  if (!post.published && !locals.user?.isAdmin) {
    error(403, "Access denied");
  }

  return { post };
};
```

### Error with Object

Pass an object for structured error data (accessible in `+error.svelte` via `page.error`):

```ts
error(422, {
  message: "Validation failed",
  fields: { email: "Invalid email format" },
});
```

### App.Error Type

Extend `App.Error` in `src/app.d.ts` for typed error data:

```ts
// src/app.d.ts
declare global {
  namespace App {
    interface Error {
      message: string;
      code?: string;
      fields?: Record<string, string>;
    }
  }
}
export {};
```

---

## redirect()

Throws a redirect response from a `load` function or server route:

```ts
import { redirect } from "@sveltejs/kit";

export const load: PageServerLoad = async ({ locals }) => {
  if (!locals.user) {
    redirect(302, "/login");
  }
  return { user: locals.user };
};
```

### Redirect Status Codes

| Code  | Meaning            | Use Case                               |
| ----- | ------------------ | -------------------------------------- |
| `301` | Moved Permanently  | SEO-safe URL changes                   |
| `302` | Found (Temporary)  | Most redirects (default choice)        |
| `303` | See Other          | After POST (post-redirect-get pattern) |
| `307` | Temporary Redirect | Method-preserving temporary redirect   |
| `308` | Permanent Redirect | Method-preserving permanent redirect   |

> **Note**: `redirect()` and `error()` throw — they don't return. You don't need a `return` after them.

---

## +error.svelte

The error page for a route segment. SvelteKit uses the nearest `+error.svelte` up the tree.

```svelte
<!-- src/routes/+error.svelte (root error page) -->
<script lang="ts">
  import { page } from '$app/state';
</script>

<svelte:head>
  <title>{page.status} Error</title>
</svelte:head>

<main>
  <h1>{page.status}</h1>
  <p>{page.error?.message ?? 'An error occurred'}</p>

  {#if page.status === 404}
    <a href="/">Go home</a>
  {:else}
    <button onclick={() => location.reload()}>Try again</button>
  {/if}
</main>
```

### Nested Error Pages

```
src/routes/
  +error.svelte          ← catches errors from all routes
  admin/
    +error.svelte        ← catches errors from /admin/* routes only
    dashboard/
      +page.svelte
```

### Layout Error Boundary

If an error occurs in a `+layout.svelte`, the `+error.svelte` at the same level cannot render (the layout is broken). It falls back to the parent level's `+error.svelte`.

---

## Unexpected Errors

Errors that are not thrown with `error()` are unexpected errors. They are:

1. Caught by `handleError` in `src/hooks.server.ts`
2. Logged (in development, the full error is shown)
3. Replaced with a safe message for the client

```ts
// src/hooks.server.ts
import type { HandleServerError } from "@sveltejs/kit";

export const handleError: HandleServerError = async ({
  error,
  event,
  status,
  message,
}) => {
  // Log to error tracking (e.g., Sentry)
  if (error instanceof Error) {
    console.error(`[${status}] ${event.url.pathname}: ${error.message}`);
  }

  return {
    message: status === 404 ? "Page not found" : "An unexpected error occurred",
  };
};
```

---

## Errors in +server.ts

API routes use standard Response or `error()`:

```ts
// src/routes/api/items/+server.ts
import type { RequestHandler } from "./$types";
import { json, error } from "@sveltejs/kit";

export const GET: RequestHandler = async ({ url, locals }) => {
  if (!locals.user) {
    error(401, "Unauthorized");
  }

  const id = url.searchParams.get("id");
  if (!id) {
    error(400, "id parameter required");
  }

  const item = await locals.db.items.findOne(id);
  if (!item) {
    error(404, "Item not found");
  }

  return json(item);
};
```

---

## Errors in Form Actions

Use `fail()` (not `error()`) for validation errors in form actions — `fail` keeps the user on the same page with the form data:

```ts
import { fail, error } from "@sveltejs/kit";

export const actions = {
  create: async ({ request, locals }) => {
    if (!locals.user) {
      error(401, "Unauthorized"); // hard error — shows error page
    }

    const data = await request.formData();
    const title = data.get("title");

    if (!title) {
      return fail(400, { title, error: "Title is required" }); // soft error — stays on page
    }

    await locals.db.posts.create({ title, userId: locals.user.id });
    return { success: true };
  },
};
```

---

## isHttpError / isRedirect

Type guards for catching specific error types:

```ts
import { isHttpError, isRedirect } from "@sveltejs/kit";

try {
  await someOperation();
} catch (err) {
  if (isHttpError(err, 404)) {
    // handle 404 specifically
  } else if (isHttpError(err)) {
    // handle any HTTP error
    console.log(err.status, err.body.message);
  } else if (isRedirect(err)) {
    // handle redirect
    console.log(err.status, err.location);
  } else {
    throw err; // re-throw unexpected errors
  }
}
```
