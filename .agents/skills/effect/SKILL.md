---
name: effect
description: Use Effect for functional TypeScript with type-safe errors, dependency injection, concurrency, and Schema validation
---

# Effect

Effect is a powerful TypeScript library for building type-safe, composable, concurrent applications using functional programming patterns. It provides a robust effect system with typed errors, dependency injection via services/layers, resource management, concurrency primitives, streaming, and schema validation.

- [Effect docs](https://effect.website)
- [Effect API reference](https://effect-ts.github.io/effect/)

## Core Concepts

### The Effect Type

```ts
Effect<Success, Error, Requirements>;
```

- `Success`: The type of value the effect produces on success
- `Error`: The type of expected (recoverable) errors
- `Requirements`: The services/context the effect needs to run

### Creating Effects

```ts
import { Effect } from "effect";

// From synchronous values
const success = Effect.succeed(42);
const fail = Effect.fail("something went wrong");

// From synchronous code that may throw
const sync = Effect.sync(() => someComputation());
const trySync = Effect.try({
  try: () => JSON.parse(input),
  catch: (e) => new ParseError({ cause: e }),
});

// From async code
const promise = Effect.tryPromise({
  try: (signal) => fetch(url, { signal }),
  catch: (e) => new FetchError({ cause: e }),
});
```

### Running Effects

```ts
// Run and get a Promise
Effect.runPromise(effect);

// Run synchronously (if the effect is synchronous)
Effect.runSync(effect);
```

### Using Generators

```ts
const program = Effect.gen(function* () {
  const user = yield* getUser(id);
  const posts = yield* getPosts(user.id);
  return { user, posts };
});
```

### Pipe and Composition

```ts
const result = pipe(
  Effect.succeed(1),
  Effect.map((n) => n + 1),
  Effect.flatMap((n) => Effect.succeed(n * 2)),
);

// Or using the fluent .pipe() method
const result2 = Effect.succeed(1).pipe(
  Effect.map((n) => n + 1),
  Effect.flatMap((n) => Effect.succeed(n * 2)),
);
```

## Topic Reference

Documentation is split by topic. Read the relevant file when working in that area:

### Error Handling & Recovery

- **[Error Management](./error-management.md)** — Expected/unexpected errors, error channel operations, accumulation, fallback, retrying, timing out, sandboxing, pattern matching

### Dependency Injection

- **[Requirements Management](./requirements-management.md)** — Services (Context.Tag), Layers, layer memoization, default services

### Resources & Lifecycle

- **[Resource Management](./resource-management.md)** — Scope, acquireRelease, ensuring safe cleanup

### Observability

- **[Observability](./observability.md)** — Logging, metrics, tracing, supervisor

### Configuration

- **[Configuration](./configuration.md)** — Config types, providers, custom types, nested config, testing config

### Runtime

- **[Runtime](./runtime.md)** — ManagedRuntime, runtime creation, default runtime, layers in runtime

### Scheduling

- **[Scheduling](./scheduling.md)** — Schedules, built-in schedules, combinators, repetition, cron

### State Management

- **[State Management](./state-management.md)** — Ref, SubscriptionRef, SynchronizedRef

### Batching & Caching

- **[Batching](./batching.md)** — Request batching, resolvers, declaring requests/queries
- **[Caching](./caching.md)** — Cache, caching effects, TTL, capacity

### Concurrency

- **[Concurrency](./concurrency.md)** — Fibers, Deferred, Queue, PubSub, Semaphore, Latch, basic concurrency operators

### Streaming

- **[Stream](./stream.md)** — Creating streams, operations, error handling, resourceful streams, consuming
- **[Sink](./sink.md)** — Creating sinks, operations, leftovers, concurrency

### Testing

- **[Testing](./testing.md)** — TestClock, controlling time in tests

### Code Style

- **[Code Style](./code-style.md)** — Guidelines, branded types, pattern matching, dual APIs, do notation

### Data Types

- **[Data Types](./data-types.md)** — Option, Either, Data, Cause, Exit, Chunk, Duration, DateTime, BigDecimal, HashSet, Redacted

### Traits & Behaviours

- **[Traits](./traits.md)** — Equal, Hash
- **[Behaviours](./behaviours.md)** — Equivalence, Order

### Platform & HTTP

- **[Platform](./platform.md)** — `@effect/platform` stable modules: Command, FileSystem, KeyValueStore, Path, Terminal, PlatformLogger, NodeRuntime
- **[Http Client](./http-client.md)** — Making HTTP requests, decoding responses, error handling, client transformations (`@effect/platform`, unstable)

### AI

- **[Effect AI](./ai.md)** — `@effect/ai` provider-agnostic language models, embeddings, tool use; OpenAI, Anthropic, Bedrock, Google provider packages

### Schema

Schema reference is split by topic area:

- **[Schema: Introduction & Getting Started](./schema-intro.md)** — Overview, installation, defining schemas, decoding/encoding basics
- **[Schema: Basic Usage](./schema-basic.md)** — Primitives, literals, enums, unions, tuples, arrays, structs, records, optionality, renaming
- **[Schema: Advanced Usage](./schema-advanced.md)** — Declaring new data types, recursive schemas, mutual recursion, template literals, TemplateLiteralParser, tagged unions, discriminated unions
- **[Schema: Transformations](./schema-transformations.md)** — transform, transformOrFail, composition, effectful filters, type-specific transforms, Filters
- **[Schema: Classes & Constructors](./schema-classes.md)** — Class APIs, default constructors, Effect data types (Config, Option, Either, Exit, Cause, Chunk, Defect, etc.)
- **[Schema: Validation & Errors](./schema-validation.md)** — Error messages, error formatters, annotations
- **[Schema: Utilities](./schema-utilities.md)** — JSON Schema generation, Arbitrary (fast-check), Pretty printer, Projections, Equivalence, Standard Schema
