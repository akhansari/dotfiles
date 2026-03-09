# Hooks

Hooks are module-level functions that intercept and modify SvelteKit's behavior. Server hooks run on every request; client hooks run in the browser.

## Server Hooks (src/hooks.server.ts)

### handle

Runs on every request to the server. Intercept, modify, or bypass the response. This is the core middleware function.

```ts
// src/hooks.server.ts
import type { Handle } from "@sveltejs/kit";

export const handle: Handle = async ({ event, resolve }) => {
  // Read/modify the request
  const sessionToken = event.cookies.get("session");

  if (sessionToken) {
    event.locals.user = await getUser(sessionToken);
  }

  // Continue processing
  const response = await resolve(event);

  // Modify the response
  response.headers.set("X-Custom-Header", "value");

  return response;
};
```

### handle with HTML Transformation

`resolve` accepts an optional `transformPageChunk` callback to modify the generated HTML:

```ts
export const handle: Handle = async ({ event, resolve }) => {
  return resolve(event, {
    transformPageChunk: ({ html }) =>
      html.replace("%lang%", event.locals.user?.lang ?? "en"),

    // Filter which response headers to include
    filterSerializedResponseHeaders: (name) =>
      name.startsWith("x-") || name === "content-type",

    // Disable preload link injection for this request
    preload: ({ type }) => type === "font",
  });
};
```

### event.locals

`locals` is an object for passing data from hooks to load functions and server routes. It is scoped to a single request.

```ts
// src/app.d.ts — declare the Locals type
declare global {
  namespace App {
    interface Locals {
      user: { id: string; name: string; role: string } | null;
      db: import("./lib/db").DB;
    }
  }
}
export {};
```

```ts
// src/hooks.server.ts
export const handle: Handle = async ({ event, resolve }) => {
  event.locals.db = createDB();
  event.locals.user = await authenticateRequest(event);
  return resolve(event);
};
```

### sequence

Compose multiple `handle` functions:

```ts
import { sequence } from "@sveltejs/kit/hooks";
import type { Handle } from "@sveltejs/kit";

const authenticate: Handle = async ({ event, resolve }) => {
  event.locals.user = await getUser(event.cookies.get("session"));
  return resolve(event);
};

const setHeaders: Handle = async ({ event, resolve }) => {
  const response = await resolve(event);
  response.headers.set("X-Frame-Options", "DENY");
  return response;
};

export const handle = sequence(authenticate, setHeaders);
```

### handleFetch

Intercept `fetch` calls made in `load` functions. Useful for transforming URLs, adding auth headers, or proxying requests.

```ts
import type { HandleFetch } from "@sveltejs/kit";

export const handleFetch: HandleFetch = async ({ request, fetch, event }) => {
  // Rewrite internal API calls to go direct to the API server
  if (request.url.startsWith("https://myapp.com/api/")) {
    const url = request.url.replace(
      "https://myapp.com/api/",
      "http://internal-api/",
    );
    request = new Request(url, request);
  }

  // Add auth header to API requests
  if (request.url.includes("/api/")) {
    request = new Request(request, {
      headers: {
        ...Object.fromEntries(request.headers),
        Authorization: `Bearer ${event.locals.user?.token}`,
      },
    });
  }

  return fetch(request);
};
```

### handleError

Catches unexpected errors (unhandled exceptions) during request handling. Use it for error reporting/logging. Do **not** use `error()` or `redirect()` here — they won't work.

```ts
import type { HandleServerError } from "@sveltejs/kit";

export const handleError: HandleServerError = async ({
  error,
  event,
  status,
  message,
}) => {
  // Log to error tracking service
  await reportError({ error, url: event.url.pathname, status });

  // Return safe error info for the client
  return {
    message: "An unexpected error occurred",
    code: (error as { code?: string }).code ?? "UNKNOWN",
  };
};
```

The return value populates `page.error` in `+error.svelte`.

---

## Client Hooks (src/hooks.client.ts)

### handleError (client)

Catches unexpected errors in the browser:

```ts
// src/hooks.client.ts
import type { HandleClientError } from "@sveltejs/kit";

export const handleError: HandleClientError = ({
  error,
  event,
  status,
  message,
}) => {
  reportError({ error, url: event.url.pathname });
  return { message: "Something went wrong" };
};
```

---

## Universal Hooks (src/hooks.ts)

### reroute

Redirects URLs before routing, without issuing an HTTP redirect:

```ts
// src/hooks.ts
import type { Reroute } from "@sveltejs/kit";

const translated: Record<string, string> = {
  "/en/about": "/about",
  "/de/ueber-uns": "/about",
  "/fr/a-propos": "/about",
};

export const reroute: Reroute = ({ url }) => {
  return translated[url.pathname] ?? url.pathname;
};
```

### transport

Encode and decode custom types for `load` function data transfer:

```ts
// src/hooks.ts
import type { Transport } from "@sveltejs/kit";
import { Vector } from "$lib/math";

export const transport: Transport = {
  Vector: {
    encode: (value) => value instanceof Vector && [value.x, value.y],
    decode: ([x, y]) => new Vector(x, y),
  },
};
```

---

## Navigation Hooks (client-side)

Import from `$app/navigation`:

```ts
import { beforeNavigate, afterNavigate, onNavigate } from "$app/navigation";
```

### beforeNavigate

```svelte
<script lang="ts">
  import { beforeNavigate } from '$app/navigation';

  let hasUnsavedChanges = $state(false);

  beforeNavigate(({ cancel, type, to }) => {
    if (hasUnsavedChanges) {
      if (!confirm('You have unsaved changes. Leave anyway?')) {
        cancel(); // prevent navigation
      }
    }
  });
</script>
```

### afterNavigate

```svelte
<script lang="ts">
  import { afterNavigate } from '$app/navigation';

  afterNavigate(({ type, from, to }) => {
    // Analytics
    trackPageView(to?.url.pathname);
  });
</script>
```

### onNavigate

Runs during navigation, before the new page renders. Can return a Promise to delay the transition (useful for View Transitions API):

```svelte
<script lang="ts">
  import { onNavigate } from '$app/navigation';

  onNavigate((navigation) => {
    if (!document.startViewTransition) return;

    return new Promise((resolve) => {
      document.startViewTransition(async () => {
        resolve(); // tell SvelteKit to proceed with the navigation
        await navigation.complete;
      });
    });
  });
</script>
```
