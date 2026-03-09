# Caching

## Cache

### Overview

In many applications, handling overlapping work is common. For example, in services that process incoming requests, it's important to avoid redundant work like handling the same request multiple times. The Cache module helps improve performance by preventing duplicate work.

Key Features of Cache:

| Feature                           | Description                                                                                                            |
| --------------------------------- | ---------------------------------------------------------------------------------------------------------------------- |
| **Compositionality**              | Allows overlapping work across different parts of the application while preserving compositional programming.          |
| **Unified Sync and Async Caches** | Integrates both synchronous and asynchronous caches through a unified lookup function that computes values either way. |
| **Effect Integration**            | Works natively with the Effect library, supporting concurrent lookups, failure handling, and interruption.             |
| **Cache Metrics**                 | Tracks key metrics like entries, hits, and misses, providing insights for performance optimization.                    |

### Creating a Cache

A cache is defined by a lookup function that computes the value for a given key if it's not already cached:

```ts
type Lookup<Key, Value, Error, Requirements> = (
  key: Key,
) => Effect<Value, Error, Requirements>;
```

The lookup function takes a `Key` and returns an `Effect`, which describes how to compute the value (`Value`). This `Effect` may require an environment (`Requirements`), can fail with an `Error`, and succeed with a `Value`. Since it returns an `Effect`, it can handle both synchronous and asynchronous workflows.

You create a cache by providing a lookup function along with a maximum size and a time-to-live (TTL) for cached values.

```ts
declare const make: <Key, Value, Error, Requirements>(options: {
  readonly capacity: number;
  readonly timeToLive: Duration.DurationInput;
  readonly lookup: Lookup<Key, Value, Error, Requirements>;
}) => Effect<Cache<Key, Value, Error>, never, Requirements>;
```

Once a cache is created, the most idiomatic way to work with it is the `get` method.
The `get` method returns the current value in the cache if it exists, or computes a new value, puts it in the cache, and returns it.

If multiple concurrent processes request the same value, it will only be computed once. All other processes will receive the computed value as soon as it is available. This is managed using Effect's fiber-based concurrency model without blocking the underlying thread.

**Example** (Concurrent Cache Lookups)

In this example, we call `timeConsumingEffect` three times concurrently with the same key.
The cache runs this effect only once, so concurrent lookups will wait until the value is available:

```ts
import { Effect, Cache, Duration } from "effect";

// Simulating an expensive lookup with a delay
const expensiveLookup = (key: string) =>
  Effect.sleep("2 seconds").pipe(Effect.as(key.length));

const program = Effect.gen(function* () {
  // Create a cache with a capacity of 100 and an infinite TTL
  const cache = yield* Cache.make({
    capacity: 100,
    timeToLive: Duration.infinity,
    lookup: expensiveLookup,
  });

  // Perform concurrent lookups using the same key
  const result = yield* Effect.all(
    [cache.get("key1"), cache.get("key1"), cache.get("key1")],
    { concurrency: "unbounded" },
  );
  console.log(
    "Result of parallel execution of three effects" +
      `with the same key: ${result}`,
  );

  // Fetch and display cache stats
  const hits = yield* cache.cacheStats.pipe(Effect.map((stats) => stats.hits));
  console.log(`Number of cache hits: ${hits}`);
  const misses = yield* cache.cacheStats.pipe(
    Effect.map((stats) => stats.misses),
  );
  console.log(`Number of cache misses: ${misses}`);
});

Effect.runPromise(program);
/*
Output:
Result of parallel execution of three effects with the same key: 4,4,4
Number of cache hits: 2
Number of cache misses: 1
*/
```

### Concurrent Access

The cache is designed to be safe for concurrent access and efficient under concurrent conditions. If two concurrent processes request the same value and it is not in the cache, the value will be computed once and provided to both processes as soon as it is available. Concurrent processes will wait for the value without blocking the underlying thread.

If the lookup function fails or is interrupted, the error will be propagated to all concurrent processes waiting for the value. Failures are cached to prevent repeated computation of the same failed value. If interrupted, the key will be removed from the cache, so subsequent calls will attempt to compute the value again.

### Capacity

A cache is created with a specified capacity. When the cache reaches capacity, the least recently accessed values will be removed first. The cache size may slightly exceed the specified capacity between operations.

### Time To Live (TTL)

A cache can also have a specified time to live (TTL). Values older than the TTL will not be returned. The age is calculated from when the value was loaded into the cache.

### Methods

In addition to `get`, the cache provides several other methods:

| Method          | Description                                                                                                                                                                |
| --------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `refresh`       | Triggers a recomputation of the value for a key without removing the old value, allowing continued access.                                                                 |
| `size`          | Returns the current size of the cache. The size is approximate under concurrent conditions.                                                                                |
| `contains`      | Checks if a value associated with a specified key exists in the cache. Under concurrent access, the result is valid as of the check time but may change immediately after. |
| `invalidate`    | Evicts the value associated with a specific key.                                                                                                                           |
| `invalidateAll` | Evicts all values from the cache.                                                                                                                                          |

## Caching Effects

### Overview

This section covers several functions from the library that help manage caching and memoization in your application.

### cachedFunction

Memoizes a function with effects, caching results for the same inputs to avoid recomputation.

**Example** (Memoizing a Random Number Generator)

```ts
import { Effect, Random } from "effect";

const program = Effect.gen(function* () {
  const randomNumber = (n: number) => Random.nextIntBetween(1, n);
  console.log("non-memoized version:");
  console.log(yield* randomNumber(10)); // Generates a new random number
  console.log(yield* randomNumber(10)); // Generates a different number

  console.log("memoized version:");
  const memoized = yield* Effect.cachedFunction(randomNumber);
  console.log(yield* memoized(10)); // Generates and caches the result
  console.log(yield* memoized(10)); // Reuses the cached result
});

Effect.runFork(program);
/*
Example Output:
non-memoized version:
2
8
memoized version:
5
5
*/
```

### once

Ensures an effect is executed only once, even if invoked multiple times.

**Example** (Single Execution of an Effect)

```ts
import { Effect, Console } from "effect";

const program = Effect.gen(function* () {
  const task1 = Console.log("task1");

  // Repeats task1 three times
  yield* Effect.repeatN(task1, 2);

  // Ensures task2 is executed only once
  const task2 = yield* Effect.once(Console.log("task2"));

  // Attempts to repeat task2, but it will only execute once
  yield* Effect.repeatN(task2, 2);
});

Effect.runFork(program);
/*
Output:
task1
task1
task1
task2
*/
```

### cached

Returns an effect that computes a result lazily and caches it. Subsequent evaluations of this effect will return the cached result without re-executing the logic.

**Example** (Lazy Caching of an Expensive Task)

```ts
import { Effect, Console } from "effect";

let i = 1;

// Simulating an expensive task with a delay
const expensiveTask = Effect.promise<string>(() => {
  console.log("expensive task...");
  return new Promise((resolve) => {
    setTimeout(() => {
      resolve(`result ${i++}`);
    }, 100);
  });
});

const program = Effect.gen(function* () {
  // Without caching, the task is executed each time
  console.log("-- non-cached version:");
  yield* expensiveTask.pipe(Effect.andThen(Console.log));
  yield* expensiveTask.pipe(Effect.andThen(Console.log));

  // With caching, the result is reused after the first run
  console.log("-- cached version:");
  const cached = yield* Effect.cached(expensiveTask);
  yield* cached.pipe(Effect.andThen(Console.log));
  yield* cached.pipe(Effect.andThen(Console.log));
});

Effect.runFork(program);
/*
Output:
-- non-cached version:
expensive task...
result 1
expensive task...
result 2
-- cached version:
expensive task...
result 3
result 3
*/
```

### cachedWithTTL

Returns an effect that caches its result for a specified duration, known as the `timeToLive`. When the cache expires after the duration, the effect will be recomputed upon next evaluation.

**Example** (Caching with Time-to-Live)

```ts
import { Effect, Console } from "effect";

let i = 1;

// Simulating an expensive task with a delay
const expensiveTask = Effect.promise<string>(() => {
  console.log("expensive task...");
  return new Promise((resolve) => {
    setTimeout(() => {
      resolve(`result ${i++}`);
    }, 100);
  });
});

const program = Effect.gen(function* () {
  // Caches the result for 150 milliseconds
  const cached = yield* Effect.cachedWithTTL(expensiveTask, "150 millis");

  // First evaluation triggers the task
  yield* cached.pipe(Effect.andThen(Console.log));

  // Second evaluation returns the cached result
  yield* cached.pipe(Effect.andThen(Console.log));

  // Wait for 100 milliseconds, ensuring the cache expires
  yield* Effect.sleep("100 millis");

  // Recomputes the task after cache expiration
  yield* cached.pipe(Effect.andThen(Console.log));
});

Effect.runFork(program);
/*
Output:
expensive task...
result 1
result 1
expensive task...
result 2
*/
```

### cachedInvalidateWithTTL

Similar to `Effect.cachedWithTTL`, this function caches an effect's result for a specified duration. It also includes an additional effect for manually invalidating the cached value before it naturally expires.

**Example** (Invalidating Cache Manually)

```ts
import { Effect, Console } from "effect";

let i = 1;

// Simulating an expensive task with a delay
const expensiveTask = Effect.promise<string>(() => {
  console.log("expensive task...");
  return new Promise((resolve) => {
    setTimeout(() => {
      resolve(`result ${i++}`);
    }, 100);
  });
});

const program = Effect.gen(function* () {
  // Caches the result for 150 milliseconds
  const [cached, invalidate] = yield* Effect.cachedInvalidateWithTTL(
    expensiveTask,
    "150 millis",
  );

  // First evaluation triggers the task
  yield* cached.pipe(Effect.andThen(Console.log));

  // Second evaluation returns the cached result
  yield* cached.pipe(Effect.andThen(Console.log));

  // Invalidate the cache before it naturally expires
  yield* invalidate;

  // Third evaluation triggers the task again
  // since the cache was invalidated
  yield* cached.pipe(Effect.andThen(Console.log));
});

Effect.runFork(program);
/*
Output:
expensive task...
result 1
result 1
expensive task...
result 2
*/
```
