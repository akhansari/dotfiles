# Adapters

Adapters convert a SvelteKit build output to run on a specific deployment platform. Configure the adapter in `svelte.config.js`.

## adapter-auto

The default adapter. Automatically detects the deployment platform and uses the appropriate adapter.

```js
// svelte.config.js
import adapter from "@sveltejs/adapter-auto";

export default {
  kit: {
    adapter: adapter(),
  },
};
```

**Supported platforms**: Vercel, Netlify, Cloudflare Pages, Azure Static Web Apps.

For platforms not auto-detected, specify an explicit adapter.

---

## adapter-node

Deploys to a Node.js server. Outputs a self-contained Node.js application.

```sh
pnpm add -D @sveltejs/adapter-node
```

```js
import adapter from "@sveltejs/adapter-node";

export default {
  kit: {
    adapter: adapter({
      out: "build", // output directory (default: 'build')
      precompress: false, // pre-compress with gzip/brotli
      envPrefix: "", // env var prefix (e.g., 'MY_APP_')
    }),
  },
};
```

### Running the Node Server

```sh
# Build
pnpm build

# Run
node build/index.js

# With custom port
PORT=3000 node build/index.js
```

### Environment Variables

```
HOST=0.0.0.0         # bind address (default: 0.0.0.0)
PORT=3000            # port (default: 3000)
SOCKET_PATH=/tmp/app.sock  # Unix socket (overrides HOST/PORT)
ORIGIN=https://myapp.com   # required when behind a proxy
BODY_SIZE_LIMIT=512k        # max request body size
```

---

## adapter-static

Pre-renders the entire site to static files. No server-side rendering at runtime.

```sh
pnpm add -D @sveltejs/adapter-static
```

```js
import adapter from "@sveltejs/adapter-static";

export default {
  kit: {
    adapter: adapter({
      pages: "build", // output for HTML pages
      assets: "build", // output for static assets
      fallback: undefined, // fallback page for SPA (e.g., '200.html')
      precompress: false,
      strict: true, // fail build if any page can't be prerendered
    }),
  },
};
```

All pages must be prerenderable. Set `export const prerender = true` in the root layout:

```ts
// src/routes/+layout.ts
export const prerender = true;
```

### SPA Fallback

For single-page apps, set a fallback page:

```js
adapter: adapter({ fallback: "200.html" });
```

Combined with `export const ssr = false` in the root layout for a full SPA.

---

## adapter-cloudflare

Deploys to Cloudflare Pages (with Workers for SSR).

```sh
pnpm add -D @sveltejs/adapter-cloudflare
```

```js
import adapter from "@sveltejs/adapter-cloudflare";

export default {
  kit: {
    adapter: adapter({
      routes: {
        include: ["/*"],
        exclude: ["<all>"],
      },
    }),
  },
};
```

### Cloudflare-Specific Platform

Access Cloudflare bindings (KV, D1, R2, etc.) via `event.platform`:

```ts
// src/app.d.ts
declare global {
  namespace App {
    interface Platform {
      env: {
        COUNTER: KVNamespace;
        DB: D1Database;
      };
      context: ExecutionContext;
      caches: CacheStorage;
    }
  }
}
```

```ts
// +page.server.ts
export const load: PageServerLoad = async ({ platform }) => {
  const value = await platform?.env.COUNTER.get("visits");
  return { visits: Number(value ?? 0) };
};
```

---

## adapter-vercel

Deploys to Vercel. Supports Serverless Functions and Edge Functions.

```sh
pnpm add -D @sveltejs/adapter-vercel
```

```js
import adapter from "@sveltejs/adapter-vercel";

export default {
  kit: {
    adapter: adapter({
      runtime: "nodejs22.x", // or 'edge'
      regions: "all",
      isr: false,
    }),
  },
};
```

### Per-Route Runtime

```ts
// +page.server.ts
export const config = {
  runtime: "edge", // run this route on edge
  regions: ["iad1"], // specific regions
};
```

---

## adapter-netlify

Deploys to Netlify.

```sh
pnpm add -D @sveltejs/adapter-netlify
```

```js
import adapter from "@sveltejs/adapter-netlify";

export default {
  kit: {
    adapter: adapter({
      edge: false, // use Netlify Functions (default) vs Edge Functions
      split: false, // split into separate functions per route
    }),
  },
};
```

---

## Writing Custom Adapters

An adapter is a function that receives the Builder object and outputs the deployment artifact:

```ts
import type { Adapter } from "@sveltejs/kit";

const myAdapter: Adapter = {
  name: "my-adapter",
  async adapt(builder) {
    // Copy static files
    builder.writeClient("output/client");
    builder.writePrerendered("output/prerendered");

    // Write server entry
    builder.writeServer("output/server");

    // Copy app
    builder.copy("my-runtime.js", "output/index.js", {
      replace: {
        SERVER: "./server/index.js",
        MANIFEST: "./server/manifest.js",
      },
    });
  },
};
```

---

## svelte.config.js Reference

```js
// svelte.config.js
import adapter from "@sveltejs/adapter-auto";

/** @type {import('@sveltejs/kit').Config} */
export default {
  kit: {
    adapter: adapter(),
    alias: {
      $components: "src/components",
      $utils: "src/utils",
    },
    appDir: "_app", // where to put JS/CSS bundles
    csrf: {
      checkOrigin: true, // CSRF protection (default: true)
    },
    embedded: false, // embedded mode (no routing)
    env: {
      dir: ".", // directory for .env files
      publicPrefix: "PUBLIC_", // prefix for public env vars
      privatePrefix: "",
    },
    files: {
      assets: "static",
      hooks: {
        client: "src/hooks.client",
        server: "src/hooks.server",
        universal: "src/hooks",
      },
      lib: "src/lib",
      params: "src/params",
      routes: "src/routes",
      appTemplate: "src/app.html",
    },
    inlineStyleThreshold: 0, // inline CSS below this byte count
    paths: {
      assets: "", // CDN URL for assets
      base: "", // base path (e.g., '/app')
      relative: true,
    },
    prerender: {
      concurrency: 1,
      crawl: true,
      entries: ["*"],
      handleHttpError: "fail",
      handleMissingId: "warn",
      origin: "http://sveltekit-prerender",
    },
    serviceWorker: {
      register: true,
      files: (filepath) => !/\.DS_Store/.test(filepath),
    },
    version: {
      name: Date.now().toString(), // used for update detection
      pollInterval: 0, // ms between update checks (0 = off)
    },
  },
  preprocess: [],
};
```
