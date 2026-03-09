# Modules

Complete reference for SvelteKit's virtual modules and `@sveltejs/kit` exports.

## $app/state

Reactive application state. Values update automatically on navigation.

```ts
import { page, navigating, updated } from "$app/state";
```

### page

| Property        | Type                      | Description                           |
| --------------- | ------------------------- | ------------------------------------- |
| `page.url`      | `URL`                     | The current URL                       |
| `page.params`   | `Record<string, string>`  | Current route params                  |
| `page.route.id` | `string \| null`          | Current route file path               |
| `page.status`   | `number`                  | HTTP status code                      |
| `page.error`    | `App.Error \| null`       | Current error (null if no error)      |
| `page.data`     | `App.PageData`            | Combined data from all load functions |
| `page.form`     | `unknown`                 | Latest form action result             |
| `page.state`    | `Record<string, unknown>` | History state object                  |

### navigating

`null` when not navigating. During navigation:

```ts
{
  from: { url, params, route } | null;
  to:   { url, params, route } | null;
  type: 'link' | 'popstate' | 'goto';
  delta?: number;
}
```

### updated

```ts
updated.current; // boolean — true if new app version is available
await updated.check(); // manually check for updates
```

---

## $app/navigation

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

### goto(url, options?)

Navigate programmatically. Returns a Promise that resolves when navigation completes.

```ts
await goto("/path");
await goto(new URL("/path", location.href));
await goto("/path", {
  replaceState: false, // push to history (default false)
  noScroll: false, // scroll to top on navigation (default false)
  keepFocus: false, // keep current focus target (default false)
  invalidateAll: false, // also run invalidateAll (default false)
  state: {}, // history state
});
```

### back() / forward()

```ts
await back(); // go back in history
await forward(); // go forward in history
```

### pushState(url, state) / replaceState(url, state)

Shallow routing — update URL without navigation:

```ts
pushState("?modal=photo-123", { modal: "photo-123" });
replaceState("?q=new-query", {});
```

### preloadData(href) / preloadCode(href)

```ts
await preloadData("/about"); // pre-run load function
await preloadCode("/dashboard"); // pre-load JS bundle
```

### invalidate(resource) / invalidateAll()

```ts
await invalidate("/api/user"); // re-run loads that fetched this URL
await invalidate("custom:key"); // re-run loads that called depends('custom:key')
await invalidateAll(); // re-run all load functions
```

### beforeNavigate(callback)

```ts
beforeNavigate(({ cancel, type, from, to, delta, complete }) => {
  if (hasUnsavedChanges) cancel();
});
```

### afterNavigate(callback)

```ts
afterNavigate(({ type, from, to }) => {
  analytics.pageView(to?.url.pathname);
});
```

### onNavigate(callback)

Runs during navigation before new page renders. Return a Promise to delay the transition.

```ts
onNavigate((navigation) => {
  // View Transitions API
  if (!document.startViewTransition) return;
  return new Promise((resolve) => {
    document.startViewTransition(async () => {
      resolve();
      await navigation.complete;
    });
  });
});
```

---

## $app/forms

```ts
import { enhance, applyAction, deserialize } from "$app/forms";
```

### enhance

Svelte action that progressively enhances `<form>` elements:

```svelte
<form method="POST" use:enhance>...</form>

<!-- With callback -->
<form method="POST" use:enhance={({ cancel, formData }) => {
  return async ({ result, update }) => {
    await update();
  };
}}>
```

### applyAction

Apply an `ActionResult` to the page:

```ts
import { applyAction } from "$app/forms";
await applyAction(result);
```

### deserialize

Deserialize a form action response string:

```ts
import { deserialize } from "$app/forms";
const result = deserialize(await response.text());
```

---

## $app/environment

```ts
import { browser, dev, building, version } from "$app/environment";
```

| Export     | Type      | Description                              |
| ---------- | --------- | ---------------------------------------- |
| `browser`  | `boolean` | `true` in the browser, `false` on server |
| `dev`      | `boolean` | `true` during development                |
| `building` | `boolean` | `true` during `vite build`               |
| `version`  | `string`  | App version from `kit.version.name`      |

```ts
if (browser) {
  // browser-only code
}
if (dev) {
  console.log("Development mode");
}
```

---

## $app/paths

```ts
import { base, assets, resolveRoute } from "$app/paths";
```

| Export         | Description                                              |
| -------------- | -------------------------------------------------------- |
| `base`         | The `kit.paths.base` value (e.g., `'/myapp'`)            |
| `assets`       | The `kit.paths.assets` value (CDN URL or same as `base`) |
| `resolveRoute` | Fills in route params to produce a URL string            |

```ts
import { base } from '$app/paths';

// Prefix internal links with base when using a base path
<a href="{base}/about">About</a>
```

```ts
import { resolveRoute } from "$app/paths";

const url = resolveRoute("/blog/[slug]", { slug: "hello-world" });
// → '/blog/hello-world'
```

---

## $app/server

```ts
import { read } from "$app/server";
```

### read

Read a static asset file. Only available on the server.

```ts
import { read } from "$app/server";

export const load: PageServerLoad = async () => {
  const file = read("/data/content.json");
  const data = await file.json();
  return { data };
};
```

---

## $env/static/public

Build-time public environment variables. Values are inlined at build time. Safe for client-side use.

```ts
import { PUBLIC_API_URL, PUBLIC_APP_NAME } from "$env/static/public";
```

Defined in `.env`, `.env.local`, `.env.production`, etc. Must be prefixed with `PUBLIC_` (configurable via `kit.env.publicPrefix`).

---

## $env/static/private

Build-time private environment variables. Server-only — importing in client code throws an error.

```ts
// Only valid in server-side files (+page.server.ts, +server.ts, hooks.server.ts)
import { DATABASE_URL, JWT_SECRET } from "$env/static/private";
```

---

## $env/dynamic/public

Runtime public environment variables. Values are available at runtime, not inlined.

```ts
import { env } from "$env/dynamic/public";

console.log(env.PUBLIC_API_URL);
```

---

## $env/dynamic/private

Runtime private environment variables. Server-only.

```ts
import { env } from "$env/dynamic/private";

const db = createClient(env.DATABASE_URL);
```

---

## $lib

Alias for `src/lib`. Shared utilities and components.

```ts
import { myUtil } from "$lib/utils";
import MyComponent from "$lib/components/MyComponent.svelte";
```

---

## @sveltejs/kit

Core exports for server-side use:

```ts
import {
  // Error handling
  error,
  redirect,
  isHttpError,
  isRedirect,
  fail,

  // Response helpers
  json,
  text,

  // Hooks
  // (see $app/navigation for client hooks)
} from "@sveltejs/kit";
```

### error(status, message | body)

```ts
error(404, "Not found");
error(403, { message: "Forbidden", code: "NO_PERMISSION" });
```

### redirect(status, location)

```ts
redirect(302, "/login");
redirect(301, `https://example.com${url.pathname}`);
```

### fail(status, data)

For form action validation failures:

```ts
fail(400, { email, error: "Invalid email" });
```

### json(data, init?)

```ts
return json({ id: 1, name: "item" });
return json({ error: "not found" }, { status: 404 });
```

### text(body, init?)

```ts
return text("Hello, world!");
return text("Forbidden", { status: 403 });
```

### isHttpError(err, status?)

```ts
if (isHttpError(err, 404)) {
  /* handle 404 */
}
if (isHttpError(err)) {
  console.log(err.status, err.body.message);
}
```

### isRedirect(err)

```ts
if (isRedirect(err)) {
  console.log(err.status, err.location);
}
```

---

## @sveltejs/kit/hooks

```ts
import { sequence } from "@sveltejs/kit/hooks";
```

### sequence(...handlers)

Compose multiple `handle` functions into one:

```ts
export const handle = sequence(authenticate, authorize, setSecurityHeaders);
```

---

## Types Reference

Key types from `@sveltejs/kit`:

```ts
import type {
  // Route-level types (from ./$types)
  PageServerLoad,
  PageLoad,
  LayoutServerLoad,
  LayoutLoad,
  Actions,
  RequestHandler,
  RouteParams,
  PageData,
  LayoutData,
  ActionData,

  // Hook types
  Handle,
  HandleFetch,
  HandleServerError,
  HandleClientError,
  Reroute,
  Transport,

  // Navigation types
  BeforeNavigate,
  AfterNavigate,
  NavigationTarget,
  Navigation,

  // Form types
  ActionResult,
  SubmitFunction,

  // Adapter types
  Adapter,
  Builder,

  // Config
  Config,
  KitConfig,
} from "@sveltejs/kit";
```

---

## app.d.ts — Global Type Declarations

```ts
// src/app.d.ts
declare global {
  namespace App {
    interface Error {
      message: string;
      code?: string;
    }

    interface Locals {
      user: { id: string; name: string; role: string } | null;
      // add your server-side locals here
    }

    interface PageData {
      // common data available everywhere via page.data
    }

    interface PageState {
      // history state shape for pushState/replaceState
      modal?: string;
    }

    interface Platform {
      // adapter-specific platform bindings (e.g., Cloudflare)
    }
  }
}

export {};
```
