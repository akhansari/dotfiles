# Effect AI

> **Note**: `@effect/ai` is experimental/alpha. APIs may change between releases.

## Overview

`@effect/ai` provides a provider-agnostic AI abstraction layer built on Effect. Programs are written against abstract services (`LanguageModel`, `EmbeddingsModel`); the concrete provider (OpenAI, Anthropic, etc.) is injected via a layer at the edge.

**Packages:**

| Package                     | Description                           |
| --------------------------- | ------------------------------------- |
| `@effect/ai`                | Core abstractions (provider-agnostic) |
| `@effect/ai-openai`         | OpenAI + Azure OpenAI providers       |
| `@effect/ai-anthropic`      | Anthropic (Claude) provider           |
| `@effect/ai-amazon-bedrock` | Amazon Bedrock provider               |
| `@effect/ai-google`         | Google Gemini provider                |

```bash
pnpm add @effect/ai @effect/ai-openai
```

---

## Generating Text

```ts
import { LanguageModel } from "@effect/ai";
import { OpenAiClient, OpenAiLanguageModel } from "@effect/ai-openai";
import { Config, Effect } from "effect";

const program = Effect.gen(function* () {
  const response = yield* LanguageModel.generateText({
    prompt: "Explain Effect in one sentence.",
  });

  console.log(response.text);
  console.log(response.usage); // { inputTokens, outputTokens, totalTokens }
});

// Wire up the provider
const model = OpenAiLanguageModel.model("gpt-4o");

const OpenAiLayer = OpenAiClient.layerConfig({
  apiKey: Config.redacted("OPENAI_API_KEY"),
});

Effect.runPromise(
  program.pipe(Effect.provide(model), Effect.provide(OpenAiLayer)),
);
```

### With system prompt and messages

```ts
import { LanguageModel } from "@effect/ai";
import { Effect } from "effect";

const response =
  yield *
  LanguageModel.generateText({
    system: "You are a helpful assistant that speaks like a pirate.",
    prompt: "What is the capital of France?",
    maxTokens: 256,
    temperature: 0.7,
  });
```

---

## The Model Type

A `Model` is a layer factory. It encapsulates which model to use and how to connect to the provider.

```ts
import { OpenAiLanguageModel } from "@effect/ai-openai";
import { AnthropicLanguageModel } from "@effect/ai-anthropic";

// OpenAI
const Gpt4o = OpenAiLanguageModel.model("gpt-4o");
const Gpt4oMini = OpenAiLanguageModel.model("gpt-4o-mini", {
  temperature: 0.2,
  maxTokens: 1024,
});

// Anthropic
const Claude = AnthropicLanguageModel.model("claude-opus-4-5");
```

Provide the model to an effect using `Effect.provide`:

```ts
const result = yield * program.pipe(Effect.provide(Gpt4o));
```

---

## Streaming Text

```ts
import { LanguageModel } from "@effect/ai";
import { OpenAiClient, OpenAiLanguageModel } from "@effect/ai-openai";
import { Config, Effect, Stream } from "effect";

const program = Effect.gen(function* () {
  const stream = yield* LanguageModel.generateTextStream({
    prompt: "Write a haiku about functional programming.",
  });

  yield* stream.pipe(
    Stream.map((chunk) => chunk.text),
    Stream.runForEach((text) => Effect.sync(() => process.stdout.write(text))),
  );
});
```

---

## Embeddings

```ts
import { EmbeddingsModel } from "@effect/ai";
import { OpenAiClient, OpenAiEmbeddingsModel } from "@effect/ai-openai";
import { Config, Effect } from "effect";

const program = Effect.gen(function* () {
  const response = yield* EmbeddingsModel.generate([
    "What is Effect?",
    "How does dependency injection work?",
  ]);

  // response.embeddings: Array<{ input: string; vector: number[] }>
  for (const { input, vector } of response.embeddings) {
    console.log(`"${input}" → [${vector.length} dimensions]`);
  }
});

const embeddingsModel = OpenAiEmbeddingsModel.model("text-embedding-3-small");

const OpenAiLayer = OpenAiClient.layerConfig({
  apiKey: Config.redacted("OPENAI_API_KEY"),
});

Effect.runPromise(
  program.pipe(Effect.provide(embeddingsModel), Effect.provide(OpenAiLayer)),
);
```

---

## Tool Use

Define tools with `AiToolkit` and pass them to `generateText`:

```ts
import { AiToolkit, LanguageModel } from "@effect/ai";
import { OpenAiClient, OpenAiLanguageModel } from "@effect/ai-openai";
import { Config, Effect, Schema } from "effect";

// Define a tool
const WeatherTool = AiToolkit.makeTool("getWeather", {
  description: "Get the current weather for a city",
  input: Schema.Struct({ city: Schema.String }),
  output: Schema.Struct({
    temperature: Schema.Number,
    condition: Schema.String,
  }),
});

// Implement the tool handler
const weatherHandler = WeatherTool.implement(({ city }) =>
  Effect.succeed({ temperature: 22, condition: "sunny" }),
);

// Build the toolkit
const toolkit = AiToolkit.make(weatherHandler);

const program = Effect.gen(function* () {
  const response = yield* LanguageModel.generateText({
    prompt: "What is the weather in Paris?",
    tools: toolkit,
  });

  console.log(response.text);
});
```

---

## Provider Clients

### OpenAI

```ts
import { OpenAiClient } from "@effect/ai-openai";
import { Config } from "effect";

// From environment variable
const layer = OpenAiClient.layerConfig({
  apiKey: Config.redacted("OPENAI_API_KEY"),
});

// Explicit value (not recommended in production)
const layerDirect = OpenAiClient.layer({
  apiKey: Redacted.make("sk-..."),
});

// Azure OpenAI
const azureLayer = OpenAiClient.layerConfig({
  apiKey: Config.redacted("AZURE_OPENAI_API_KEY"),
  baseUrl: Config.string("AZURE_OPENAI_ENDPOINT"),
});
```

### Anthropic

```ts
import { AnthropicClient } from "@effect/ai-anthropic";
import { Config } from "effect";

const layer = AnthropicClient.layerConfig({
  apiKey: Config.redacted("ANTHROPIC_API_KEY"),
});
```

### Amazon Bedrock

```ts
import { BedrockClient } from "@effect/ai-amazon-bedrock";
import { Config } from "effect";

const layer = BedrockClient.layerConfig({
  region: Config.string("AWS_REGION"),
});
```

### Google

```ts
import { GoogleClient } from "@effect/ai-google";
import { Config } from "effect";

const layer = GoogleClient.layerConfig({
  apiKey: Config.redacted("GOOGLE_API_KEY"),
});
```

---

## Provider-Agnostic Services

Write business logic against abstract services; inject the provider at the edge.

```ts
import { LanguageModel } from "@effect/ai";
import { AnthropicClient, AnthropicLanguageModel } from "@effect/ai-anthropic";
import { OpenAiClient, OpenAiLanguageModel } from "@effect/ai-openai";
import { Config, Effect, Layer } from "effect";

// ─── Business logic (no provider coupling) ───────────────────────────────────

const summarize = (text: string) =>
  LanguageModel.generateText({
    system: "You are a summarization assistant. Be concise.",
    prompt: `Summarize this text:\n\n${text}`,
    maxTokens: 200,
  }).pipe(Effect.map((r) => r.text));

// ─── Provider wiring (at the edge) ───────────────────────────────────────────

const OpenAiLayer = Layer.provide(
  OpenAiLanguageModel.model("gpt-4o-mini"),
  OpenAiClient.layerConfig({ apiKey: Config.redacted("OPENAI_API_KEY") }),
);

const AnthropicLayer = Layer.provide(
  AnthropicLanguageModel.model("claude-haiku-4-5"),
  AnthropicClient.layerConfig({ apiKey: Config.redacted("ANTHROPIC_API_KEY") }),
);

// ─── Run with either provider ─────────────────────────────────────────────────

const withOpenAi = summarize("...long text...").pipe(
  Effect.provide(OpenAiLayer),
);

const withAnthropic = summarize("...long text...").pipe(
  Effect.provide(AnthropicLayer),
);
```

---

## Full Example

```ts
import { AiToolkit, LanguageModel } from "@effect/ai";
import { OpenAiClient, OpenAiLanguageModel } from "@effect/ai-openai";
import { NodeRuntime } from "@effect/platform-node";
import { Config, Effect, Layer, Redacted, Schema } from "effect";

// Tool definition
const SearchTool = AiToolkit.makeTool("searchDocs", {
  description: "Search the documentation for a query",
  input: Schema.Struct({ query: Schema.String }),
  output: Schema.Struct({ results: Schema.Array(Schema.String) }),
});

const searchHandler = SearchTool.implement(({ query }) =>
  // Simulate a search
  Effect.succeed({
    results: [`Result 1 for "${query}"`, `Result 2 for "${query}"`],
  }),
);

const toolkit = AiToolkit.make(searchHandler);

// Main program
const program = Effect.gen(function* () {
  const response = yield* LanguageModel.generateText({
    system: "You are a helpful assistant with access to documentation search.",
    prompt: "Find information about Effect Schema.",
    tools: toolkit,
    maxTokens: 512,
  });

  console.log(response.text);
  console.log("Tokens used:", response.usage.totalTokens);
});

// Layers
const OpenAiLayer = Layer.provide(
  OpenAiLanguageModel.model("gpt-4o"),
  OpenAiClient.layerConfig({ apiKey: Config.redacted("OPENAI_API_KEY") }),
);

NodeRuntime.runMain(program.pipe(Effect.provide(OpenAiLayer)));
```
