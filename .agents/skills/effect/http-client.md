# Http Client

> **Note**: `HttpClient` is part of `@effect/platform` and is marked as unstable. The API may change between minor versions.

## Overview

`@effect/platform` provides a type-safe, Effect-native HTTP client. Requests are values; execution is an effect. Errors are typed. The client is provided as a service, making it easy to mock in tests.

```ts
// pnpm add @effect/platform @effect/platform-node
```

---

## Making Requests

Build request values with `HttpClientRequest`:

```ts
import { HttpClientRequest } from "@effect/platform";

// GET
const getReq = HttpClientRequest.get("https://api.example.com/users");

// POST with JSON body
const postReq = HttpClientRequest.post("https://api.example.com/users").pipe(
  HttpClientRequest.bodyJson({ name: "Alice", role: "admin" }),
);

// PUT
const putReq = HttpClientRequest.put("https://api.example.com/users/1").pipe(
  HttpClientRequest.bodyJson({ name: "Alice" }),
);

// DELETE
const deleteReq = HttpClientRequest.del("https://api.example.com/users/1");

// Set headers
const withHeaders = HttpClientRequest.get("https://api.example.com/me").pipe(
  HttpClientRequest.setHeader("Authorization", "Bearer token123"),
  HttpClientRequest.setHeader("Accept", "application/json"),
);

// Set multiple headers at once
const withManyHeaders = HttpClientRequest.get(
  "https://api.example.com/me",
).pipe(
  HttpClientRequest.setHeaders({
    Authorization: "Bearer token123",
    Accept: "application/json",
  }),
);

// Query parameters
const withParams = HttpClientRequest.get("https://api.example.com/search").pipe(
  HttpClientRequest.setUrlParam("q", "effect"),
  HttpClientRequest.setUrlParam("page", "1"),
);

// Form-encoded body
const formReq = HttpClientRequest.post("https://api.example.com/login").pipe(
  HttpClientRequest.bodyUrlParams({ username: "alice", password: "secret" }),
);
```

---

## Executing Requests

Use the `HttpClient` service to execute requests:

```ts
import { HttpClient, HttpClientRequest } from "@effect/platform";
import { Effect } from "effect";

const program = Effect.gen(function* () {
  const client = yield* HttpClient.HttpClient;

  // Execute any request
  const response = yield* client.execute(
    HttpClientRequest.get("https://api.example.com/users"),
  );

  // Shorthand methods on the client
  const getResp = yield* client.get("https://api.example.com/users");
  const postResp = yield* client.post("https://api.example.com/users");
});
```

---

## Decoding Responses

```ts
import {
  HttpClient,
  HttpClientRequest,
  HttpClientResponse,
} from "@effect/platform";
import { Effect, Schema } from "effect";

const UserSchema = Schema.Struct({
  id: Schema.Number,
  name: Schema.String,
  email: Schema.String,
});

const program = Effect.gen(function* () {
  const client = yield* HttpClient.HttpClient;

  // JSON (unknown)
  const json = yield* client
    .get("https://api.example.com/users/1")
    .pipe(Effect.andThen(HttpClientResponse.json));

  // Text
  const text = yield* client
    .get("https://api.example.com/health")
    .pipe(Effect.andThen(HttpClientResponse.text));

  // Schema-validated JSON (decode + validate)
  const user = yield* client
    .get("https://api.example.com/users/1")
    .pipe(Effect.andThen(HttpClientResponse.schemaBodyJson(UserSchema)));

  // Array of items
  const UsersSchema = Schema.Array(UserSchema);
  const users = yield* client
    .get("https://api.example.com/users")
    .pipe(Effect.andThen(HttpClientResponse.schemaBodyJson(UsersSchema)));
});
```

---

## Error Handling

The client surfaces two error types:

| Error                           | When                                             |
| ------------------------------- | ------------------------------------------------ |
| `HttpClientError.RequestError`  | Network failure, timeout, connection refused     |
| `HttpClientError.ResponseError` | Got a response but something went wrong decoding |

```ts
import {
  HttpClient,
  HttpClientError,
  HttpClientRequest,
  HttpClientResponse,
} from "@effect/platform";
import { Effect } from "effect";

const program = Effect.gen(function* () {
  const client = yield* HttpClient.HttpClient;

  const result = yield* client.get("https://api.example.com/users/1").pipe(
    Effect.andThen(HttpClientResponse.json),
    Effect.catchTag("RequestError", (e) =>
      Effect.fail(`Network error: ${e.message}`),
    ),
    Effect.catchTag("ResponseError", (e) =>
      Effect.fail(`Bad response: ${e.response.status}`),
    ),
  );
});
```

### Filter by status

`filterStatusOk` makes the request fail with a `ResponseError` when the response status is not 2xx:

```ts
import { HttpClient, HttpClientRequest } from "@effect/platform";
import { Effect } from "effect";

const program = Effect.gen(function* () {
  const client = yield* HttpClient.HttpClient.pipe(
    // All requests on this client will fail on non-2xx
    HttpClient.filterStatusOk,
  );

  const resp = yield* client.get("https://api.example.com/users/999");
  // Fails with ResponseError if status is 404
});
```

---

## Providing the Client

Choose the right layer for your runtime:

```ts
import { FetchHttpClient } from "@effect/platform";
import { NodeHttpClient } from "@effect/platform-node";
import { Effect, Layer } from "effect";

// Universal (browser + Node.js via fetch)
const universalLayer = FetchHttpClient.layer;

// Node.js native HTTP (better performance, no fetch overhead)
const nodeLayer = NodeHttpClient.layer;

// Run with the chosen layer
Effect.runPromise(program.pipe(Effect.provide(FetchHttpClient.layer)));
```

---

## Transforming Clients

You can derive a modified client from an existing one without recreating it:

```ts
import { HttpClient, HttpClientRequest } from "@effect/platform";
import { Effect } from "effect";

const program = Effect.gen(function* () {
  const baseClient = yield* HttpClient.HttpClient;

  // Add base URL and auth header to every request
  const apiClient = baseClient.pipe(
    HttpClient.mapRequest(
      HttpClientRequest.prependUrl("https://api.example.com"),
    ),
    HttpClient.mapRequest(
      HttpClientRequest.setHeader("Authorization", "Bearer token"),
    ),
    // Auto-retry transient errors (network issues, 5xx) with default schedule
    HttpClient.retryTransient({ times: 3 }),
    // Fail on non-2xx
    HttpClient.filterStatusOk,
  );

  const users = yield* apiClient.get("/users");
});
```

---

## Full Example

```ts
import {
  FetchHttpClient,
  HttpClient,
  HttpClientRequest,
  HttpClientResponse,
} from "@effect/platform";
import { Effect, Layer, Schema } from "effect";

const PostSchema = Schema.Struct({
  id: Schema.Number,
  title: Schema.String,
  body: Schema.String,
  userId: Schema.Number,
});

const makePostsService = Effect.gen(function* () {
  const client = yield* HttpClient.HttpClient.pipe(
    HttpClient.mapRequest(
      HttpClientRequest.prependUrl("https://jsonplaceholder.typicode.com"),
    ),
    HttpClient.filterStatusOk,
  );

  const getPost = (id: number) =>
    client
      .get(`/posts/${id}`)
      .pipe(Effect.andThen(HttpClientResponse.schemaBodyJson(PostSchema)));

  const createPost = (data: { title: string; body: string; userId: number }) =>
    client.post("/posts").pipe(
      Effect.tap(() => HttpClientRequest.bodyJson(data)),
      Effect.andThen(HttpClientResponse.schemaBodyJson(PostSchema)),
    );

  return { getPost, createPost };
});

const program = Effect.gen(function* () {
  const posts = yield* makePostsService;
  const post = yield* posts.getPost(1);
  console.log(post.title);
});

Effect.runPromise(program.pipe(Effect.provide(FetchHttpClient.layer)));
```
