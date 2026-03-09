# Page Options

Page options control how SvelteKit renders and delivers each route. They can be set per-page or per-layout (in which case child routes inherit the setting).

## Setting Options

Export options from `+page.ts`, `+page.server.ts`, `+layout.ts`, or `+layout.server.ts`:

```ts
// +page.ts or +page.server.ts
export const ssr = false;
export const csr = true;
export const prerender = false;
export const trailingSlash = "never";
```

Layout options apply to the layout and all its child routes. A `+page` option overrides the layout option for that specific page.

---

## ssr

Controls whether the page is rendered on the server.

```ts
export const ssr = true; // default — render HTML on server
export const ssr = false; // skip SSR — render only in browser
```

**When to set `ssr = false`**:

- Components that use browser-only APIs (`window`, `document`, `navigator`) at the top level
- Components that are incompatible with SSR (certain third-party libraries)

> **Prefer SSR when possible** — it improves initial load performance, SEO, and accessibility. Disabling SSR should be a last resort.

---

## csr

Controls whether JavaScript is sent to the browser.

```ts
export const csr = true; // default — send JS bundle, enable client-side navigation
export const csr = false; // no JS bundle for this route — purely server-rendered HTML
```

**When to set `csr = false`**:

- Static content pages with no interactivity
- Pages where you want zero JavaScript overhead

> **Note**: `csr = false` disables `use:enhance`, `goto`, and all interactive Svelte features. The page is a static HTML document.

---

## prerender

Controls whether the page is pre-rendered to static HTML at build time.

```ts
export const prerender = true; // pre-render to static HTML
export const prerender = false; // default — render on request
export const prerender = "auto"; // prerender if no form actions exist
```

**When to use `prerender = true`**:

- Content that doesn't change per-request (blog posts, marketing pages, docs)
- Pages with no dynamic data depending on request context (cookies, headers, etc.)

### Prerender Configuration in svelte.config.js

```js
// svelte.config.js
export default {
  kit: {
    prerender: {
      handleHttpError: "warn", // or 'fail', or a function
      handleMissingId: "warn",
      crawl: true, // auto-discover routes by crawling links
      entries: ["*"], // routes to prerender
      origin: "https://example.com",
    },
  },
};
```

---

## trailingSlash

Controls whether URLs have a trailing slash.

```ts
export const trailingSlash = "never"; // /about (default)
export const trailingSlash = "always"; // /about/
export const trailingSlash = "ignore"; // both /about and /about/ work
```

For static adapters, `'always'` or `'ignore'` is recommended (static files are served as `about/index.html`).

---

## config

Adapter-specific configuration:

```ts
export const config = {
  runtime: "edge", // for Vercel adapter
};
```

Config values vary by adapter. Refer to your adapter's documentation.

---

## Common Patterns

### Full SPA (disable SSR globally)

```ts
// src/routes/+layout.ts
export const ssr = false;
export const csr = true;
```

### Static Site

```ts
// src/routes/+layout.ts
export const prerender = true;
export const trailingSlash = "always";
```

With individual dynamic routes opting out:

```ts
// src/routes/profile/+page.ts
export const prerender = false; // this page is dynamic
```

### Static Blog with Dynamic Search

```ts
// src/routes/+layout.ts
export const prerender = "auto";

// src/routes/blog/[slug]/+page.ts
export const prerender = true; // individual post pages are pre-rendered

// src/routes/search/+page.ts
export const prerender = false; // search page is dynamic
```

### Server-Only Route (no client JS)

```ts
// src/routes/print/+page.ts
export const csr = false;
export const ssr = true;
```
