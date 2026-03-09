# Platform

## Overview

`@effect/platform` provides cross-platform abstractions for file system, command execution, key-value storage, paths, terminal, and logging. Programs are written against abstract services; the concrete implementation is provided at the edge via platform-specific layers.

```ts
// Install
// pnpm add @effect/platform @effect/platform-node

import { NodeContext, NodeRuntime } from "@effect/platform-node";

NodeRuntime.runMain(program.pipe(Effect.provide(NodeContext.layer)));
```

`NodeContext.layer` bundles all Node.js service implementations (FileSystem, CommandExecutor, Path, Terminal, etc.).

---

## Command

Execute child processes. Requires `CommandExecutor` (provided by `NodeContext.layer`).

```ts
import { Command } from "@effect/platform";
import { NodeContext, NodeRuntime } from "@effect/platform-node";
import { Effect } from "effect";

const program = Effect.gen(function* () {
  // Basic command
  const output = yield* Command.make("ls", "-al").pipe(Command.string);
  console.log(output);

  // Lines output
  const lines = yield* Command.make("cat", "/etc/hosts").pipe(Command.lines);

  // Stream output (for large outputs)
  const stream = Command.make("find", "/usr").pipe(Command.streamLines);

  // Exit code only
  const code = yield* Command.make("test", "-f", "/etc/hosts").pipe(
    Command.exitCode,
  );

  // Set env vars
  const withEnv = Command.make("printenv", "MY_VAR").pipe(
    Command.env({ MY_VAR: "hello" }),
    Command.string,
  );

  // Feed stdin
  const result = yield* Command.make("wc", "-l").pipe(
    Command.feed("line1\nline2\nline3"),
    Command.string,
  );

  // Run in shell
  const shellResult = yield* Command.make("echo $HOME").pipe(
    Command.runInShell(true),
    Command.string,
  );
});

NodeRuntime.runMain(program.pipe(Effect.provide(NodeContext.layer)));
```

### Output methods

| Method                | Returns                           | Description                     |
| --------------------- | --------------------------------- | ------------------------------- |
| `Command.string`      | `Effect<string>`                  | Collect all stdout as a string  |
| `Command.lines`       | `Effect<string[]>`                | Collect stdout split into lines |
| `Command.stream`      | `Stream<Uint8Array>`              | Raw byte stream of stdout       |
| `Command.streamLines` | `Stream<string>`                  | Line-by-line stream of stdout   |
| `Command.exitCode`    | `Effect<number>`                  | Only the exit code              |
| `Command.start`       | `Effect<CommandExecutor.Process>` | Start without waiting           |

---

## FileSystem

Access the local file system. Requires `FileSystem` service (provided by `NodeContext.layer`).

```ts
import { FileSystem } from "@effect/platform";
import { NodeContext, NodeRuntime } from "@effect/platform-node";
import { Effect } from "effect";

const program = Effect.gen(function* () {
  const fs = yield* FileSystem.FileSystem;

  // Read/write text
  const content = yield* fs.readFileString("./data.json");
  yield* fs.writeFileString("./output.txt", "hello world");

  // Read/write bytes
  const bytes = yield* fs.readFile("./image.png");
  yield* fs.writeFile("./copy.png", bytes);

  // Directory operations
  yield* fs.makeDirectory("./tmp", { recursive: true });
  const entries = yield* fs.readDirectory("./src");

  // File metadata
  const stat = yield* fs.stat("./package.json");
  console.log(stat.size, stat.mtime);

  // Existence check
  const exists = yield* fs.exists("./optional.txt");

  // Copy, move, remove
  yield* fs.copy("./src", "./dst", { overwrite: true });
  yield* fs.rename("./old.txt", "./new.txt");
  yield* fs.remove("./tmp", { recursive: true });

  // Symbolic links
  yield* fs.symlink("./target", "./link");
  const target = yield* fs.readLink("./link");

  // Temporary files
  const tmpFile = yield* fs.makeTempFile();
  const tmpDir = yield* fs.makeTempDirectory();

  // Streaming read/write (integrates with Stream/Sink)
  const readStream = fs.stream("./large-file.bin");
  const writeSink = fs.sink("./output.bin");
});

NodeRuntime.runMain(program.pipe(Effect.provide(NodeContext.layer)));
```

### Key operations

| Operation           | Description                               |
| ------------------- | ----------------------------------------- |
| `readFileString`    | Read file as UTF-8 string                 |
| `writeFileString`   | Write string to file                      |
| `readFile`          | Read file as `Uint8Array`                 |
| `writeFile`         | Write `Uint8Array` to file                |
| `exists`            | Check if path exists                      |
| `stat`              | Get file metadata (`size`, `mtime`, etc.) |
| `makeDirectory`     | Create directory, optionally recursive    |
| `readDirectory`     | List directory entries                    |
| `copy`              | Copy file or directory                    |
| `rename`            | Rename/move file or directory             |
| `remove`            | Delete file or directory                  |
| `symlink`           | Create symbolic link                      |
| `stream`            | `Stream<Uint8Array>` for reading          |
| `sink`              | `Sink` for writing                        |
| `makeTempFile`      | Create temporary file, returns path       |
| `makeTempDirectory` | Create temporary directory, returns path  |

### Mocking in tests

```ts
import { FileSystem } from "@effect/platform";

const testLayer = FileSystem.layerNoop({
  readFileString: () => Effect.succeed('{"key": "value"}'),
  exists: () => Effect.succeed(true),
});

const result = await Effect.runPromise(program.pipe(Effect.provide(testLayer)));
```

---

## KeyValueStore

A simple key-value storage abstraction. Requires `KeyValueStore` service.

```ts
import { KeyValueStore } from "@effect/platform";
import { NodeContext, NodeRuntime } from "@effect/platform-node";
import { Effect, Schema } from "effect";

const program = Effect.gen(function* () {
  const store = yield* KeyValueStore.KeyValueStore;

  // Basic operations
  yield* store.set("user:1", JSON.stringify({ name: "Alice" }));
  const raw = yield* store.get("user:1"); // Option<string>
  const has = yield* store.has("user:1"); // boolean
  yield* store.remove("user:1");
  const size = yield* store.size; // number
  yield* store.clear;
});

NodeRuntime.runMain(program.pipe(Effect.provide(NodeContext.layer)));
```

### Schema-typed sub-store

`forSchema` narrows a store to a specific value type with automatic encode/decode.

```ts
import { KeyValueStore } from "@effect/platform";
import { Effect, Schema } from "effect";

const UserSchema = Schema.Struct({ id: Schema.Number, name: Schema.String });

const program = Effect.gen(function* () {
  const store = yield* KeyValueStore.KeyValueStore;
  const users = store.forSchema(UserSchema);

  yield* users.set("user:1", { id: 1, name: "Alice" });
  const user = yield* users.get("user:1"); // Option<{ id: number; name: string }>
});
```

### Layers

| Layer                                | Description                        |
| ------------------------------------ | ---------------------------------- |
| `KeyValueStore.layerMemory`          | In-memory store (useful for tests) |
| `KeyValueStore.layerFileSystem(dir)` | Persist to directory on disk       |

---

## Path

Cross-platform path utilities. Requires `Path` service.

```ts
import { Path } from "@effect/platform";
import { NodeContext, NodeRuntime } from "@effect/platform-node";
import { Effect } from "effect";

const program = Effect.gen(function* () {
  const path = yield* Path.Path;

  const full = path.join("src", "components", "Button.svelte");
  const abs = path.resolve("../config.json");
  const dir = path.dirname("/usr/local/bin/node"); // "/usr/local/bin"
  const base = path.basename("/usr/local/bin/node"); // "node"
  const ext = path.extname("index.ts"); // ".ts"
  const parsed = path.parse("/usr/local/bin/node");
  const isAbs = path.isAbsolute("/usr/local"); // true
  const rel = path.relative("/usr/local", "/usr/local/bin"); // "bin"
});

NodeRuntime.runMain(program.pipe(Effect.provide(NodeContext.layer)));
```

---

## Terminal

Interactive terminal I/O. Requires `Terminal` service.

```ts
import { Terminal } from "@effect/platform";
import { NodeContext, NodeRuntime } from "@effect/platform-node";
import { Effect } from "effect";

const program = Effect.gen(function* () {
  const terminal = yield* Terminal.Terminal;

  yield* terminal.display("What is your name? ");
  const name = yield* terminal.readLine;
  yield* terminal.display(`Hello, ${name}!\n`);
});

NodeRuntime.runMain(program.pipe(Effect.provide(NodeContext.layer)));
```

---

## PlatformLogger

Write log output to a file instead of (or in addition to) stdout.

```ts
import { PlatformLogger } from "@effect/platform";
import { NodeContext, NodeRuntime } from "@effect/platform-node";
import { Effect, Logger } from "effect";

const fileLogger = PlatformLogger.toFile("/var/log/app.log");

// Replace the default logger entirely
const loggerLayer = Logger.replace(Logger.defaultLogger, fileLogger).pipe(
  Layer.provide(NodeContext.layer),
);

// Or add alongside default logger
const bothLoggers = Logger.add(fileLogger).pipe(
  Layer.provide(NodeContext.layer),
);

const program = Effect.gen(function* () {
  yield* Effect.log("This goes to the file");
});

NodeRuntime.runMain(program.pipe(Effect.provide(loggerLayer)));
```

---

## NodeRuntime

Entry point for Node.js applications.

```ts
import { NodeRuntime } from "@effect/platform-node";
import { Effect } from "effect";

const program = Effect.gen(function* () {
  yield* Effect.log("Starting...");
});

// Basic usage — pretty-prints errors, sets up signal handling
NodeRuntime.runMain(program);

// With options
NodeRuntime.runMain(program, {
  disableErrorReporting: false, // default: false — logs unhandled errors
  disablePrettyLogger: false, // default: false — uses pretty logger
});
```

`NodeRuntime.runMain` differs from `Effect.runPromise` in that it:

- Installs `SIGINT`/`SIGTERM` handlers that interrupt the main fiber gracefully
- Reports unhandled defects to stderr
- Exits the process with a non-zero code on failure
