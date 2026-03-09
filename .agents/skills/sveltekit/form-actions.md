# Form Actions

SvelteKit's form actions handle form submissions on the server. They provide progressive enhancement — forms work without JavaScript and are enhanced with `use:enhance` for a seamless SPA-like experience.

## Defining Actions

Actions are exported from `+page.server.ts`:

```ts
// src/routes/login/+page.server.ts
import type { Actions } from "./$types";
import { fail, redirect } from "@sveltejs/kit";

export const actions: Actions = {
  // Default action (for forms without `action` attribute)
  default: async ({ request, cookies, locals }) => {
    const data = await request.formData();
    const email = data.get("email") as string;
    const password = data.get("password") as string;

    if (!email || !password) {
      return fail(400, { email, missing: true });
    }

    const user = await locals.auth.signIn(email, password);

    if (!user) {
      return fail(401, { email, incorrect: true });
    }

    cookies.set("session", user.sessionToken, { path: "/" });
    redirect(302, "/dashboard");
  },
};
```

## Named Actions

Multiple actions per page using `?/actionName`:

```ts
// src/routes/settings/+page.server.ts
import type { Actions } from "./$types";
import { fail } from "@sveltejs/kit";

export const actions: Actions = {
  updateName: async ({ request, locals }) => {
    const data = await request.formData();
    const name = data.get("name") as string;

    if (!name?.trim()) {
      return fail(400, { name, error: "Name is required" });
    }

    await locals.db.user.update({ name });
    return { success: true };
  },

  updateEmail: async ({ request, locals }) => {
    const data = await request.formData();
    const email = data.get("email") as string;
    // ...
    return { success: true };
  },

  deleteAccount: async ({ locals }) => {
    await locals.db.user.delete();
    redirect(302, "/");
  },
};
```

## Using Forms in +page.svelte

### Default Action

```svelte
<form method="POST">
  <input type="email" name="email" />
  <input type="password" name="password" />
  <button>Log in</button>
</form>
```

### Named Actions

```svelte
<form method="POST" action="?/updateName">
  <input name="name" />
  <button>Update name</button>
</form>

<form method="POST" action="?/updateEmail">
  <input name="email" type="email" />
  <button>Update email</button>
</form>
```

### Accessing Action Result

The form action result is available as `form` in the page data:

```svelte
<script lang="ts">
  import type { PageData, ActionData } from './$types';

  let { data, form }: { data: PageData; form: ActionData } = $props();
</script>

{#if form?.missing}
  <p class="error">Email and password are required</p>
{/if}
{#if form?.incorrect}
  <p class="error">Invalid credentials</p>
{/if}

<form method="POST">
  <input type="email" name="email" value={form?.email ?? ''} />
  <input type="password" name="password" />
  <button>Log in</button>
</form>
```

---

## fail()

Returns a non-2xx response with data. The page re-renders with the `form` prop set to this data.

```ts
import { fail } from "@sveltejs/kit";

// fail(status, data) — data must be JSON-serializable
return fail(400, {
  field: "email",
  message: "Invalid email format",
  values: { email }, // repopulate form fields
});
```

---

## use:enhance

Progressive enhancement for forms — handles submission via `fetch` instead of a full page reload.

### Basic Usage

```svelte
<script lang="ts">
  import { enhance } from '$app/forms';
</script>

<form method="POST" use:enhance>
  <!-- form content -->
</form>
```

Without a callback, `use:enhance` will:

- Prevent default form submission
- Submit via `fetch`
- Update `form`, `data`, and `page` state
- Reset the form on success
- Call `invalidateAll()` to re-run load functions

### Custom Callback

```svelte
<script lang="ts">
  import { enhance } from '$app/forms';
  import type { SubmitFunction } from '@sveltejs/kit';

  let loading = $state(false);

  const handleSubmit: SubmitFunction = ({ formData, cancel }) => {
    loading = true;

    // You can cancel the submission
    if (!formData.get('email')) {
      cancel();
      loading = false;
      return;
    }

    // Return a callback for after the server responds
    return async ({ result, update }) => {
      loading = false;

      if (result.type === 'success') {
        // Custom success handling
        await update(); // apply default update behavior
      } else if (result.type === 'redirect') {
        await applyAction(result);
      } else {
        await update({ reset: false }); // don't reset form on error
      }
    };
  };
</script>

<form method="POST" use:enhance={handleSubmit}>
  <input name="email" disabled={loading} />
  <button disabled={loading}>
    {loading ? 'Submitting...' : 'Submit'}
  </button>
</form>
```

### SubmitFunction Parameters

```ts
type SubmitFunction = (input: {
  action: URL; // the action URL
  formData: FormData; // the form data
  formElement: HTMLFormElement;
  controller: AbortController;
  submitter: HTMLElement | null;
  cancel(): void; // call to cancel submission
}) =>
  | void
  | ((opts: {
      result: ActionResult; // the server response
      update(opts?: {
        reset?: boolean;
        invalidateAll?: boolean;
      }): Promise<void>;
    }) => void);
```

---

## applyAction

Apply an action result manually (used with custom `use:enhance` callbacks):

```ts
import { applyAction } from "$app/forms";
import type { ActionResult } from "@sveltejs/kit";

const result: ActionResult = await fetch(url, { method: "POST", body }).then(
  (r) => r.json(),
);
await applyAction(result);
```

`applyAction` handles:

- `success` → updates `form` prop, optionally invalidates
- `failure` → updates `form` prop with failure data
- `redirect` → calls `goto`
- `error` → renders error page

---

## File Upload

```svelte
<form method="POST" enctype="multipart/form-data" use:enhance>
  <input type="file" name="avatar" accept="image/*" />
  <button>Upload</button>
</form>
```

```ts
export const actions: Actions = {
  default: async ({ request }) => {
    const data = await request.formData();
    const file = data.get("avatar") as File;

    if (!file || file.size === 0) {
      return fail(400, { error: "No file provided" });
    }

    const buffer = await file.arrayBuffer();
    // save buffer...

    return { success: true };
  },
};
```

---

## Combining Load and Actions

Load and actions are commonly combined in `+page.server.ts`:

```ts
import type { PageServerLoad, Actions } from "./$types";
import { fail } from "@sveltejs/kit";

export const load: PageServerLoad = async ({ locals }) => {
  return {
    todos: await locals.db.todos.findAll({ userId: locals.user.id }),
  };
};

export const actions: Actions = {
  create: async ({ request, locals }) => {
    const data = await request.formData();
    const text = data.get("text") as string;

    if (!text?.trim()) return fail(400, { error: "Text is required" });

    await locals.db.todos.create({ text, userId: locals.user.id });
    // SvelteKit automatically invalidates the page data after a successful action
    return { success: true };
  },

  delete: async ({ request, locals }) => {
    const data = await request.formData();
    const id = data.get("id") as string;
    await locals.db.todos.delete(id);
  },
};
```
