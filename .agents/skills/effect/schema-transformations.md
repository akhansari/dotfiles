# Schema: Transformations & Filters

## Transformations

### Overview

Transformations are important when working with schemas. They allow you to change data from one type to another. For example, you might parse a string into a number or convert a date string into a `Date` object.

The [Schema.transform](#transform) and [Schema.transformOrFail](#transformorfail) functions help you connect two schemas so you can convert data between them.

### transform

`Schema.transform` creates a new schema by taking the output of one schema (the "source") and making it the input of another schema (the "target"). Use this when you know the transformation will always succeed. If it might fail, use [Schema.transformOrFail](#transformorfail) instead.

#### Understanding Input and Output

"Output" and "input" depend on what you are doing (decoding or encoding):

**When decoding:**

- The source schema `Schema<SourceType, SourceEncoded>` produces a `SourceType`.
- The target schema `Schema<TargetType, TargetEncoded>` expects a `TargetEncoded`.
- The decoding path looks like this: `SourceEncoded` → `TargetType`.

If `SourceType` and `TargetEncoded` differ, you can provide a `decode` function to convert the source schema's output into the target schema's input.

**When encoding:**

- The target schema `Schema<TargetType, TargetEncoded>` produces a `TargetEncoded`.
- The source schema `Schema<SourceType, SourceEncoded>` expects a `SourceType`.
- The encoding path looks like this: `TargetType` → `SourceEncoded`.

If `TargetEncoded` and `SourceType` differ, you can provide an `encode` function to convert the target schema's output into the source schema's input.

#### Combining Two Primitive Schemas

In this example, we start with a schema that accepts `"on"` or `"off"` and transform it into a boolean schema. The `decode` function turns `"on"` into `true` and `"off"` into `false`. The `encode` function does the reverse. This gives us a `Schema<boolean, "on" | "off">`.

**Example** (Converting a String to a Boolean)

```ts
import { Schema } from "effect";

// Convert "on"/"off" to boolean and back
const BooleanFromString = Schema.transform(
  // Source schema: "on" or "off"
  Schema.Literal("on", "off"),
  // Target schema: boolean
  Schema.Boolean,
  {
    // optional but you get better error messages from TypeScript
    strict: true,
    // Transformation to convert the output of the
    // source schema ("on" | "off") into the input of the
    // target schema (boolean)
    decode: (literal) => literal === "on", // Always succeeds here
    // Reverse transformation
    encode: (bool) => (bool ? "on" : "off"),
  },
);

//     ┌─── "on" | "off"
//     ▼
type Encoded = typeof BooleanFromString.Encoded;

//     ┌─── boolean
//     ▼
type Type = typeof BooleanFromString.Type;

console.log(Schema.decodeUnknownSync(BooleanFromString)("on"));
// Output: true
```

The `decode` function above never fails by itself. However, the full decoding process can still fail if the input does not fit the source schema. For example, if you provide `"wrong"` instead of `"on"` or `"off"`, the source schema will fail before calling `decode`.

**Example** (Handling Invalid Input)

```ts
import { Schema } from "effect";

// Convert "on"/"off" to boolean and back
const BooleanFromString = Schema.transform(
  Schema.Literal("on", "off"),
  Schema.Boolean,
  {
    strict: true,
    decode: (s) => s === "on",
    encode: (bool) => (bool ? "on" : "off"),
  },
);

// Providing input not allowed by the source schema
Schema.decodeUnknownSync(BooleanFromString)("wrong");
/*
throws:
ParseError: ("on" | "off" <-> boolean)
└─ Encoded side transformation failure
   └─ "on" | "off"
      ├─ Expected "on", actual "wrong"
      └─ Expected "off", actual "wrong"
*/
```

#### Combining Two Transformation Schemas

Below is an example where both the source and target schemas transform their data:

- The source schema is `Schema.NumberFromString`, which is `Schema<number, string>`.
- The target schema is `BooleanFromString` (defined above), which is `Schema<boolean, "on" | "off">`.

This example involves four types and requires two conversions:

- When decoding, convert a `number` into `"on" | "off"`. For example, treat any positive number as `"on"`.
- When encoding, convert `"on" | "off"` back into a `number`. For example, treat `"on"` as `1` and `"off"` as `-1`.

By composing these transformations, we get a schema that decodes a string into a boolean and encodes a boolean back into a string. The resulting schema is `Schema<boolean, string>`.

**Example** (Combining Two Transformation Schemas)

```ts
import { Schema } from "effect";

// Convert "on"/"off" to boolean and back
const BooleanFromString = Schema.transform(
  Schema.Literal("on", "off"),
  Schema.Boolean,
  {
    strict: true,
    decode: (s) => s === "on",
    encode: (bool) => (bool ? "on" : "off"),
  },
);

const BooleanFromNumericString = Schema.transform(
  // Source schema: Convert string -> number
  Schema.NumberFromString,
  // Target schema: Convert "on"/"off" -> boolean
  BooleanFromString,
  {
    strict: true,
    // If number is positive, use "on", otherwise "off"
    decode: (n) => (n > 0 ? "on" : "off"),
    // If boolean is "on", use 1, otherwise -1
    encode: (bool) => (bool === "on" ? 1 : -1),
  },
);

//     ┌─── string
//     ▼
type Encoded = typeof BooleanFromNumericString.Encoded;

//     ┌─── boolean
//     ▼
type Type = typeof BooleanFromNumericString.Type;

console.log(Schema.decodeUnknownSync(BooleanFromNumericString)("100"));
// Output: true
```

**Example** (Converting an array to a ReadonlySet)

In this example, we convert an array into a `ReadonlySet`. The `decode` function takes an array and creates a new `ReadonlySet`. The `encode` function converts the set back into an array. We also provide the schema of the array items so they are properly validated.

```ts
import { Schema } from "effect";

// This function builds a schema that converts between a readonly array
// and a readonly set of items
const ReadonlySetFromArray = <A, I, R>(
  itemSchema: Schema.Schema<A, I, R>,
): Schema.Schema<ReadonlySet<A>, ReadonlyArray<I>, R> =>
  Schema.transform(
    // Source schema: array of items
    Schema.Array(itemSchema),
    // Target schema: readonly set of items
    // **IMPORTANT** We use `Schema.typeSchema` here to obtain the schema
    // of the items to avoid decoding the elements twice
    Schema.ReadonlySetFromSelf(Schema.typeSchema(itemSchema)),
    {
      strict: true,
      decode: (items) => new Set(items),
      encode: (set) => Array.from(set.values()),
    },
  );

const schema = ReadonlySetFromArray(Schema.String);

//     ┌─── readonly string[]
//     ▼
type Encoded = typeof schema.Encoded;

//     ┌─── ReadonlySet<string>
//     ▼
type Type = typeof schema.Type;

console.log(Schema.decodeUnknownSync(schema)(["a", "b", "c"]));
// Output: Set(3) { 'a', 'b', 'c' }

console.log(Schema.encodeSync(schema)(new Set(["a", "b", "c"])));
// Output: [ 'a', 'b', 'c' ]
```

> **Note**: Why Schema.typeSchema is used
> Please note that to define the target schema, we used
> [Schema.typeSchema](/docs/schema/projections/#typeschema). This is
> because the decoding/encoding of the elements is already handled by the
> `from` schema: `Schema.Array(itemSchema)`, avoiding double decoding.

#### Non-strict option

In some cases, strict type checking can create issues during data transformations, especially when the types might slightly differ in specific transformations. To address these scenarios, `Schema.transform` offers the option `strict: false`, which relaxes type constraints and allows more flexible transformations.

**Example** (Creating a Clamping Constructor)

Let's consider the scenario where you need to define a constructor `clamp` that ensures a number falls within a specific range. This function returns a schema that "clamps" a number to a specified minimum and maximum range:

```ts
import { Schema, Number } from "effect";

const clamp =
  (minimum: number, maximum: number) =>
  <A extends number, I, R>(self: Schema.Schema<A, I, R>) =>
    Schema.transform(
      // Source schema
      self,
      // Target schema: filter based on min/max range
      self.pipe(
        Schema.typeSchema,
        Schema.filter((a) => a <= minimum || a >= maximum),
      ),
      {
        strict: true,
        // Clamp the number within the specified range
        decode: (a) => Number.clamp(a, { minimum, maximum }),
        encode: (a) => a,
      },
    );
```

In this example, `Number.clamp` returns a `number` that might not be recognized as the specific `A` type, which leads to a type mismatch under strict checking.

There are two ways to resolve this issue:

1. **Using Type Assertion**:
   Adding a type cast can enforce the return type to be treated as type `A`:

   ```ts
   decode: (a) => Number.clamp(a, { minimum, maximum }) as A;
   ```

2. **Using the Non-Strict Option**:
   Setting `strict: false` in the transformation options allows the schema to bypass some of TypeScript's type-checking rules, accommodating the type discrepancy:

   ```ts
   import { Schema, Number } from "effect";

   const clamp =
     (minimum: number, maximum: number) =>
     <A extends number, I, R>(self: Schema.Schema<A, I, R>) =>
       Schema.transform(
         self,
         self.pipe(
           Schema.typeSchema,
           Schema.filter((a) => a >= minimum && a <= maximum),
         ),
         {
           strict: false,
           decode: (a) => Number.clamp(a, { minimum, maximum }),
           encode: (a) => a,
         },
       );
   ```

### transformOrFail

While the [Schema.transform](#transform) function is suitable for error-free transformations,
the `Schema.transformOrFail` function is designed for more complex scenarios where **transformations
can fail** during the decoding or encoding stages.

This function enables decoding/encoding functions to return either a successful result or an error,
making it particularly useful for validating and processing data that might not always conform to expected formats.

#### Error Handling

The `Schema.transformOrFail` function utilizes the ParseResult module to manage potential errors:

| Constructor           | Description                                                                                      |
| --------------------- | ------------------------------------------------------------------------------------------------ |
| `ParseResult.succeed` | Indicates a successful transformation, where no errors occurred.                                 |
| `ParseResult.fail`    | Signals a failed transformation, creating a new `ParseError` based on the provided `ParseIssue`. |

Additionally, the ParseResult module provides constructors for dealing with various types of parse issues, such as:

| Parse Issue Type | Description                                                                                   |
| ---------------- | --------------------------------------------------------------------------------------------- |
| `Type`           | Indicates a type mismatch error.                                                              |
| `Missing`        | Used when a required field is missing.                                                        |
| `Unexpected`     | Used for unexpected fields that are not allowed in the schema.                                |
| `Forbidden`      | Flags the decoding or encoding operation being forbidden by the schema.                       |
| `Pointer`        | Points to a specific location in the data where an issue occurred.                            |
| `Refinement`     | Used when a value does not meet a specific refinement or constraint.                          |
| `Transformation` | Flags issues that occur during transformation from one type to another.                       |
| `Composite`      | Represents a composite error, combining multiple issues into one, helpful for grouped errors. |

These tools allow for detailed and specific error handling, enhancing the reliability of data processing operations.

**Example** (Converting a String to a Number)

A common use case for `Schema.transformOrFail` is converting string representations of numbers into actual numeric types. This scenario is typical when dealing with user inputs or data from external sources.

```ts
import { ParseResult, Schema } from "effect";

export const NumberFromString = Schema.transformOrFail(
  // Source schema: accepts any string
  Schema.String,
  // Target schema: expects a number
  Schema.Number,
  {
    // optional but you get better error messages from TypeScript
    strict: true,
    decode: (input, options, ast) => {
      const parsed = parseFloat(input);
      // If parsing fails (NaN), return a ParseError with a custom error
      if (isNaN(parsed)) {
        return ParseResult.fail(
          // Create a Type Mismatch error
          new ParseResult.Type(
            // Provide the schema's abstract syntax tree for context
            ast,
            // Include the problematic input
            input,
            // Optional custom error message
            "Failed to convert string to number",
          ),
        );
      }
      return ParseResult.succeed(parsed);
    },
    encode: (input, options, ast) => ParseResult.succeed(input.toString()),
  },
);

//     ┌─── string
//     ▼
type Encoded = typeof NumberFromString.Encoded;

//     ┌─── number
//     ▼
type Type = typeof NumberFromString.Type;

console.log(Schema.decodeUnknownSync(NumberFromString)("123"));
// Output: 123

console.log(Schema.decodeUnknownSync(NumberFromString)("-"));
/*
throws:
ParseError: (string <-> number)
└─ Transformation process failure
   └─ Failed to convert string to number
*/
```

Both `decode` and `encode` functions not only receive the value to transform (`input`), but also the [parse options](/docs/schema/getting-started/#parse-options) that the user sets when using the resulting schema, and the `ast`, which represents the low level definition of the schema you're transforming.

#### Async Transformations

In modern applications, especially those interacting with external APIs, you might need to transform data asynchronously. `Schema.transformOrFail` supports asynchronous transformations by allowing you to return an `Effect`.

**Example** (Validating Data with an API Call)

Consider a scenario where you need to validate a person's ID by making an API call. Here's how you can implement it:

```ts
import { Effect, Schema, ParseResult } from "effect";

// Define a function to make API requests
const get = (url: string): Effect.Effect<unknown, Error> =>
  Effect.tryPromise({
    try: () =>
      fetch(url).then((res) => {
        if (res.ok) {
          return res.json() as Promise<unknown>;
        }
        throw new Error(String(res.status));
      }),
    catch: (e) => new Error(String(e)),
  });

// Create a branded schema for a person's ID
const PeopleId = Schema.String.pipe(Schema.brand("PeopleId"));

// Define a schema with async transformation
const PeopleIdFromString = Schema.transformOrFail(Schema.String, PeopleId, {
  strict: true,
  decode: (s, _, ast) =>
    // Make an API call to validate the ID
    Effect.mapBoth(get(`https://swapi.dev/api/people/${s}`), {
      // Error handling for failed API call
      onFailure: (e) => new ParseResult.Type(ast, s, e.message),
      // Return the ID if the API call succeeds
      onSuccess: () => s,
    }),
  encode: ParseResult.succeed,
});

//     ┌─── string
//     ▼
type Encoded = typeof PeopleIdFromString.Encoded;

//     ┌─── string & Brand<"PeopleId">
//     ▼
type Type = typeof PeopleIdFromString.Type;

//     ┌─── never
//     ▼
type Context = typeof PeopleIdFromString.Context;

// Run a successful decode operation
Effect.runPromiseExit(Schema.decodeUnknown(PeopleIdFromString)("1")).then(
  console.log,
);
/*
Output:
{ _id: 'Exit', _tag: 'Success', value: '1' }
*/

// Run a decode operation that will fail
Effect.runPromiseExit(Schema.decodeUnknown(PeopleIdFromString)("fail")).then(
  console.log,
);
/*
Output:
{
  _id: 'Exit',
  _tag: 'Failure',
  cause: {
    _id: 'Cause',
    _tag: 'Fail',
    failure: {
      _id: 'ParseError',
      message: '(string <-> string & Brand<"PeopleId">)\n' +
        '└─ Transformation process failure\n' +
        '   └─ Error: 404'
    }
  }
}
*/
```

#### Declaring Dependencies

In cases where your transformation depends on external services, you can inject these services in the `decode` or `encode` functions. These dependencies are then tracked in the `Requirements` channel of the schema:

```text
Schema<Type, Encoded, Requirements>
```

**Example** (Validating Data with a Service)

```ts
import { Context, Effect, Schema, ParseResult, Layer } from "effect";

// Define a Validation service for dependency injection
class Validation extends Context.Tag("Validation")<
  Validation,
  {
    readonly validatePeopleid: (s: string) => Effect.Effect<void, Error>;
  }
>() {}

// Create a branded schema for a person's ID
const PeopleId = Schema.String.pipe(Schema.brand("PeopleId"));

// Transform a string into a validated PeopleId,
// using an external validation service
const PeopleIdFromString = Schema.transformOrFail(Schema.String, PeopleId, {
  strict: true,
  decode: (s, _, ast) =>
    // Asynchronously validate the ID using the injected service
    Effect.gen(function* () {
      // Access the validation service
      const validator = yield* Validation;
      // Use service to validate ID
      yield* validator.validatePeopleid(s);
      return s;
    }).pipe(Effect.mapError((e) => new ParseResult.Type(ast, s, e.message))),
  encode: ParseResult.succeed, // Encode by simply returning the string
});

//     ┌─── string
//     ▼
type Encoded = typeof PeopleIdFromString.Encoded;

//     ┌─── string & Brand<"PeopleId">
//     ▼
type Type = typeof PeopleIdFromString.Type;

//     ┌─── Validation
//     ▼
type Context = typeof PeopleIdFromString.Context;

// Layer to provide a successful validation service
const SuccessTest = Layer.succeed(Validation, {
  validatePeopleid: (_) => Effect.void,
});

// Run a successful decode operation
Effect.runPromiseExit(
  Schema.decodeUnknown(PeopleIdFromString)("1").pipe(
    Effect.provide(SuccessTest),
  ),
).then(console.log);
/*
Output:
{ _id: 'Exit', _tag: 'Success', value: '1' }
*/

// Layer to provide a failing validation service
const FailureTest = Layer.succeed(Validation, {
  validatePeopleid: (_) => Effect.fail(new Error("404")),
});

// Run a decode operation that will fail
Effect.runPromiseExit(
  Schema.decodeUnknown(PeopleIdFromString)("fail").pipe(
    Effect.provide(FailureTest),
  ),
).then(console.log);
/*
Output:
{
  _id: 'Exit',
  _tag: 'Failure',
  cause: {
    _id: 'Cause',
    _tag: 'Fail',
    failure: {
      _id: 'ParseError',
      message: '(string <-> string & Brand<"PeopleId">)\n' +
        '└─ Transformation process failure\n' +
        '   └─ Error: 404'
    }
  }
}
*/
```

### One-Way Transformations with Forbidden Encoding

In some cases, encoding a value back to its original form may not make sense or may be undesirable. You can use `Schema.transformOrFail` to define a one-way transformation and explicitly return a `Forbidden` parse error during the encoding process. This ensures that once a value is transformed, it cannot be reverted to its original form.

**Example** (Password Hashing with Forbidden Encoding)

Consider a scenario where you need to hash a user's plain text password for secure storage. It is important that the hashed password cannot be reversed back to plain text. By using `Schema.transformOrFail`, you can enforce this restriction, ensuring a one-way transformation from plain text to a hashed password.

```ts
import { Schema, ParseResult, Redacted } from "effect";
import { createHash } from "node:crypto";

// Define a schema for plain text passwords
// with a minimum length requirement
const PlainPassword = Schema.String.pipe(
  Schema.minLength(6),
  Schema.brand("PlainPassword", { identifier: "PlainPassword" }),
);

// Define a schema for hashed passwords as a separate branded type
const HashedPassword = Schema.String.pipe(
  Schema.brand("HashedPassword", { identifier: "HashedPassword" }),
);

// Define a one-way transformation from plain passwords to hashed passwords
export const PasswordHashing = Schema.transformOrFail(
  PlainPassword,
  // Wrap the output in Redacted for added safety
  Schema.RedactedFromSelf(HashedPassword),
  {
    strict: true,
    // Decode: Transform a plain password into a hashed password
    decode: (plainPassword) => {
      const hash = createHash("sha256").update(plainPassword).digest("hex");
      // Wrap the hash in Redacted
      return ParseResult.succeed(Redacted.make(hash));
    },
    // Encode: Forbid reversing the hashed password back to plain text
    encode: (hashedPassword, _, ast) =>
      ParseResult.fail(
        new ParseResult.Forbidden(
          ast,
          hashedPassword,
          "Encoding hashed passwords back to plain text is forbidden.",
        ),
      ),
  },
);

//     ┌─── string
//     ▼
type Encoded = typeof PasswordHashing.Encoded;

//     ┌─── Redacted<string & Brand<"HashedPassword">>
//     ▼
type Type = typeof PasswordHashing.Type;

// Example: Decoding a plain password into a hashed password
console.log(Schema.decodeUnknownSync(PasswordHashing)("myPlainPassword123"));
// Output: <redacted>

// Example: Attempting to encode a hashed password back to plain text
console.log(
  Schema.encodeUnknownSync(PasswordHashing)(Redacted.make("2ef2b7...")),
);
/*
throws:
ParseError: (PlainPassword <-> Redacted(<redacted>))
└─ Transformation process failure
   └─ (PlainPassword <-> Redacted(<redacted>))
      └─ Encoding hashed passwords back to plain text is forbidden.
*/
```

### Composition

Combining and reusing schemas is often needed in complex applications, and the `Schema.compose` combinator provides an efficient way to do this. With `Schema.compose`, you can chain two schemas, `Schema<B, A, R1>` and `Schema<C, B, R2>`, into a single schema `Schema<C, A, R1 | R2>`:

**Example** (Composing Schemas to Parse a Delimited String into Numbers)

```ts
import { Schema } from "effect";

// Schema to split a string by commas into an array of strings
//
//     ┌─── Schema<readonly string[], string, never>
//     ▼
const schema1 = Schema.asSchema(Schema.split(","));

// Schema to convert an array of strings to an array of numbers
//
//     ┌─── Schema<readonly number[], readonly string[], never>
//     ▼
const schema2 = Schema.asSchema(Schema.Array(Schema.NumberFromString));

// Composed schema that takes a string, splits it by commas,
// and converts the result into an array of numbers
//
//     ┌─── Schema<readonly number[], string, never>
//     ▼
const ComposedSchema = Schema.asSchema(Schema.compose(schema1, schema2));
```

#### Non-strict Option

When composing schemas, you may encounter cases where the output of one schema does not perfectly match the input of the next, for example, if you have `Schema<R1, A, B>` and `Schema<R2, C, D>` where `C` differs from `B`. To handle these cases, you can use the `{ strict: false }` option to relax type constraints.

**Example** (Using Non-strict Option in Composition)

```ts
import { Schema } from "effect";

// Without the `strict: false` option,
// this composition raises a TypeScript error
Schema.compose(
  Schema.Union(Schema.Null, Schema.Literal("0")),
  Schema.NumberFromString,
);

// Use `strict: false` to allow type flexibility
Schema.compose(
  Schema.Union(Schema.Null, Schema.Literal("0")),
  Schema.NumberFromString,
  { strict: false },
);
```

### Effectful Filters

The `Schema.filterEffect` function enables validations that require asynchronous or dynamic scenarios, making it suitable for cases where validations involve side effects like network requests or database queries. For simple synchronous validations, see [`Schema.filter`](/docs/schema/filters/#declaring-filters).

**Example** (Asynchronous Username Validation)

```ts
import { Effect, Schema } from "effect";

// Mock async function to validate a username
async function validateUsername(username: string) {
  return Promise.resolve(username === "gcanti");
}

// Define a schema with an effectful filter
const ValidUsername = Schema.String.pipe(
  Schema.filterEffect((username) =>
    Effect.promise(() =>
      // Validate the username asynchronously,
      // returning an error message if invalid
      validateUsername(username).then((valid) => valid || "Invalid username"),
    ),
  ),
).annotations({ identifier: "ValidUsername" });

Effect.runPromise(Schema.decodeUnknown(ValidUsername)("xxx")).then(console.log);
/*
ParseError: ValidUsername
└─ Transformation process failure
   └─ Invalid username
*/
```

### String Transformations

#### split

Splits a string by a specified delimiter into an array of substrings.

**Example** (Splitting a String by Comma)

```ts
import { Schema } from "effect";

const schema = Schema.split(",");

const decode = Schema.decodeUnknownSync(schema);

console.log(decode("")); // [""]
console.log(decode(",")); // ["", ""]
console.log(decode("a,")); // ["a", ""]
console.log(decode("a,b")); // ["a", "b"]
```

#### Trim

Removes whitespace from the beginning and end of a string.

**Example** (Trimming Whitespace)

```ts
import { Schema } from "effect";

const decode = Schema.decodeUnknownSync(Schema.Trim);

console.log(decode("a")); // "a"
console.log(decode(" a")); // "a"
console.log(decode("a ")); // "a"
console.log(decode(" a ")); // "a"
```

> **Tip**: Trimmed Check
> If you were looking for a combinator to check if a string is trimmed,
> check out the `Schema.trimmed` filter.

#### Lowercase

Converts a string to lowercase.

**Example** (Converting to Lowercase)

```ts
import { Schema } from "effect";

const decode = Schema.decodeUnknownSync(Schema.Lowercase);

console.log(decode("A")); // "a"
console.log(decode(" AB")); // " ab"
console.log(decode("Ab ")); // "ab "
console.log(decode(" ABc ")); // " abc "
```

> **Tip**: Lowercase And Lowercased
> If you were looking for a combinator to check if a string is lowercased,
> check out the `Schema.Lowercased` schema or the `Schema.lowercased`
> filter.

#### Uppercase

Converts a string to uppercase.

**Example** (Converting to Uppercase)

```ts
import { Schema } from "effect";

const decode = Schema.decodeUnknownSync(Schema.Uppercase);

console.log(decode("a")); // "A"
console.log(decode(" ab")); // " AB"
console.log(decode("aB ")); // "AB "
console.log(decode(" abC ")); // " ABC "
```

> **Tip**: Uppercase And Uppercased
> If you were looking for a combinator to check if a string is uppercased,
> check out the `Schema.Uppercased` schema or the `Schema.uppercased`
> filter.

#### Capitalize

Converts the first character of a string to uppercase.

**Example** (Capitalizing a String)

```ts
import { Schema } from "effect";

const decode = Schema.decodeUnknownSync(Schema.Capitalize);

console.log(decode("aa")); // "Aa"
console.log(decode(" ab")); // " ab"
console.log(decode("aB ")); // "AB "
console.log(decode(" abC ")); // " abC "
```

> **Tip**: Capitalize And Capitalized
> If you were looking for a combinator to check if a string is
> capitalized, check out the `Schema.Capitalized` schema or the
> `Schema.capitalized` filter.

#### Uncapitalize

Converts the first character of a string to lowercase.

**Example** (Uncapitalizing a String)

```ts
import { Schema } from "effect";

const decode = Schema.decodeUnknownSync(Schema.Uncapitalize);

console.log(decode("AA")); // "aA"
console.log(decode(" AB")); // " AB"
console.log(decode("Ab ")); // "ab "
console.log(decode(" AbC ")); // " AbC "
```

> **Tip**: Uncapitalize And Uncapitalized
> If you were looking for a combinator to check if a string is
> uncapitalized, check out the `Schema.Uncapitalized` schema or the
> `Schema.uncapitalized` filter.

#### parseJson

The `Schema.parseJson` constructor offers a method to convert JSON strings into the `unknown` type using the underlying functionality of `JSON.parse`.
It also employs `JSON.stringify` for encoding.

**Example** (Parsing JSON Strings)

```ts
import { Schema } from "effect";

const schema = Schema.parseJson();
const decode = Schema.decodeUnknownSync(schema);

// Parse valid JSON strings
console.log(decode("{}")); // Output: {}
console.log(decode(`{"a":"b"}`)); // Output: { a: "b" }

// Attempting to decode an empty string results in an error
decode("");
/*
throws:
ParseError: (JsonString <-> unknown)
└─ Transformation process failure
   └─ Unexpected end of JSON input
*/
```

To further refine the result of JSON parsing, you can provide a schema to the `Schema.parseJson` constructor. This schema will validate that the parsed JSON matches a specific structure.

**Example** (Parsing JSON with Structured Validation)

In this example, `Schema.parseJson` uses a struct schema to ensure the parsed JSON is an object with a numeric property `a`. This adds validation to the parsed data, confirming that it follows the expected structure.

```ts
import { Schema } from "effect";

//     ┌─── SchemaClass<{ readonly a: number; }, string, never>
//     ▼
const schema = Schema.parseJson(Schema.Struct({ a: Schema.Number }));
```

#### StringFromBase64

Decodes a base64 (RFC4648) encoded string into a UTF-8 string.

**Example** (Decoding Base64)

```ts
import { Schema } from "effect";

const decode = Schema.decodeUnknownSync(Schema.StringFromBase64);

console.log(decode("Zm9vYmFy"));
// Output: "foobar"
```

#### StringFromBase64Url

Decodes a base64 (URL) encoded string into a UTF-8 string.

**Example** (Decoding Base64 URL)

```ts
import { Schema } from "effect";

const decode = Schema.decodeUnknownSync(Schema.StringFromBase64Url);

console.log(decode("Zm9vYmFy"));
// Output: "foobar"
```

#### StringFromHex

Decodes a hex encoded string into a UTF-8 string.

**Example** (Decoding Hex String)

```ts
import { Schema } from "effect";

const decode = Schema.decodeUnknownSync(Schema.StringFromHex);

console.log(new TextEncoder().encode(decode("0001020304050607")));
/*
Output:
Uint8Array(8) [
  0, 1, 2, 3,
  4, 5, 6, 7
]
*/
```

#### StringFromUriComponent

Decodes a URI-encoded string into a UTF-8 string. It is useful for encoding and decoding data in URLs.

**Example** (Decoding URI Component)

```ts
import { Schema } from "effect";

const PaginationSchema = Schema.Struct({
  maxItemPerPage: Schema.Number,
  page: Schema.Number,
});

const UrlSchema = Schema.compose(
  Schema.StringFromUriComponent,
  Schema.parseJson(PaginationSchema),
);

console.log(Schema.encodeSync(UrlSchema)({ maxItemPerPage: 10, page: 1 }));
// Output: %7B%22maxItemPerPage%22%3A10%2C%22page%22%3A1%7D
```

### Number Transformations

#### NumberFromString

Transforms a string into a number by parsing the string using the `parse` function of the `effect/Number` module.

It returns an error if the value can't be converted (for example when non-numeric characters are provided).

The following special string values are supported: "NaN", "Infinity", "-Infinity".

**Example** (Parsing Number from String)

```ts
import { Schema } from "effect";

const schema = Schema.NumberFromString;

const decode = Schema.decodeUnknownSync(schema);

// success cases
console.log(decode("1")); // 1
console.log(decode("-1")); // -1
console.log(decode("1.5")); // 1.5
console.log(decode("NaN")); // NaN
console.log(decode("Infinity")); // Infinity
console.log(decode("-Infinity")); // -Infinity

// failure cases
decode("a");
/*
throws:
ParseError: NumberFromString
└─ Transformation process failure
   └─ Expected NumberFromString, actual "a"
*/
```

#### clamp

Restricts a number within a specified range.

**Example** (Clamping a Number)

```ts
import { Schema } from "effect";

// clamps the input to -1 <= x <= 1
const schema = Schema.Number.pipe(Schema.clamp(-1, 1));

const decode = Schema.decodeUnknownSync(schema);

console.log(decode(-3)); // -1
console.log(decode(0)); // 0
console.log(decode(3)); // 1
```

#### parseNumber

Transforms a string into a number by parsing the string using the `parse` function of the `effect/Number` module.

It returns an error if the value can't be converted (for example when non-numeric characters are provided).

The following special string values are supported: "NaN", "Infinity", "-Infinity".

**Example** (Parsing and Validating Numbers)

```ts
import { Schema } from "effect";

const schema = Schema.String.pipe(Schema.parseNumber);

const decode = Schema.decodeUnknownSync(schema);

console.log(decode("1")); // 1
console.log(decode("Infinity")); // Infinity
console.log(decode("NaN")); // NaN
console.log(decode("-"));
/*
throws
ParseError: (string <-> number)
└─ Transformation process failure
   └─ Expected (string <-> number), actual "-"
*/
```

### Boolean Transformations

#### Not

Negates a boolean value.

**Example** (Negating Boolean)

```ts
import { Schema } from "effect";

const decode = Schema.decodeUnknownSync(Schema.Not);

console.log(decode(true)); // false
console.log(decode(false)); // true
```

### Symbol transformations

#### Symbol

Converts a string to a symbol using `Symbol.for`.

**Example** (Creating Symbols from Strings)

```ts
import { Schema } from "effect";

const decode = Schema.decodeUnknownSync(Schema.Symbol);

console.log(decode("a")); // Symbol(a)
```

### BigInt transformations

#### BigInt

Converts a string to a `BigInt` using the `BigInt` constructor.

**Example** (Parsing BigInt from String)

```ts
import { Schema } from "effect";

const decode = Schema.decodeUnknownSync(Schema.BigInt);

// success cases
console.log(decode("1")); // 1n
console.log(decode("-1")); // -1n

// failure cases
decode("a");
/*
throws:
ParseError: bigint
└─ Transformation process failure
   └─ Expected bigint, actual "a"
*/
decode("1.5"); // throws
decode("NaN"); // throws
decode("Infinity"); // throws
decode("-Infinity"); // throws
```

#### BigIntFromNumber

Converts a number to a `BigInt` using the `BigInt` constructor.

**Example** (Parsing BigInt from Number)

```ts
import { Schema } from "effect";

const decode = Schema.decodeUnknownSync(Schema.BigIntFromNumber);
const encode = Schema.encodeSync(Schema.BigIntFromNumber);

// success cases
console.log(decode(1)); // 1n
console.log(decode(-1)); // -1n
console.log(encode(1n)); // 1
console.log(encode(-1n)); // -1

// failure cases
decode(1.5);
/*
throws:
ParseError: BigintFromNumber
└─ Transformation process failure
   └─ Expected BigintFromNumber, actual 1.5
*/

decode(NaN); // throws
decode(Infinity); // throws
decode(-Infinity); // throws
encode(BigInt(Number.MAX_SAFE_INTEGER) + 1n); // throws
encode(BigInt(Number.MIN_SAFE_INTEGER) - 1n); // throws
```

#### clampBigInt

Restricts a `BigInt` within a specified range.

**Example** (Clamping BigInt)

```ts
import { Schema } from "effect";

// clamps the input to -1n <= x <= 1n
const schema = Schema.BigIntFromSelf.pipe(Schema.clampBigInt(-1n, 1n));

const decode = Schema.decodeUnknownSync(schema);

console.log(decode(-3n));
// Output: -1n

console.log(decode(0n));
// Output: 0n

console.log(decode(3n));
// Output: 1n
```

### Date transformations

#### Date

Converts a string into a **valid** `Date`, ensuring that invalid dates, such as `new Date("Invalid Date")`, are rejected.

**Example** (Parsing and Validating Date)

```ts
import { Schema } from "effect";

const decode = Schema.decodeUnknownSync(Schema.Date);

console.log(decode("1970-01-01T00:00:00.000Z"));
// Output: 1970-01-01T00:00:00.000Z

decode("a");
/*
throws:
ParseError: Date
└─ Predicate refinement failure
   └─ Expected Date, actual Invalid Date
*/

const validate = Schema.validateSync(Schema.Date);

console.log(validate(new Date(0)));
// Output: 1970-01-01T00:00:00.000Z

console.log(validate(new Date("Invalid Date")));
/*
throws:
ParseError: Date
└─ Predicate refinement failure
   └─ Expected Date, actual Invalid Date
*/
```

### BigDecimal Transformations

#### BigDecimal

Converts a string to a `BigDecimal`.

**Example** (Parsing BigDecimal from String)

```ts
import { Schema } from "effect";

const decode = Schema.decodeUnknownSync(Schema.BigDecimal);

console.log(decode(".124"));
// Output: { _id: 'BigDecimal', value: '124', scale: 3 }
```

#### BigDecimalFromNumber

Converts a number to a `BigDecimal`.

> **Caution**: Invalid Range
> When encoding, this Schema will produce incorrect results if the
> BigDecimal exceeds the 64-bit range of a number.

**Example** (Parsing BigDecimal from Number)

```ts
import { Schema } from "effect";

const decode = Schema.decodeUnknownSync(Schema.BigDecimalFromNumber);

console.log(decode(0.111));
// Output: { _id: 'BigDecimal', value: '111', scale: 3 }
```

#### clampBigDecimal

Clamps a `BigDecimal` within a specified range.

**Example** (Clamping BigDecimal)

```ts
import { Schema } from "effect";
import { BigDecimal } from "effect";

const schema = Schema.BigDecimal.pipe(
  Schema.clampBigDecimal(BigDecimal.fromNumber(-1), BigDecimal.fromNumber(1)),
);

const decode = Schema.decodeUnknownSync(schema);

console.log(decode("-2"));
// Output: { _id: 'BigDecimal', value: '-1', scale: 0 }

console.log(decode("0"));
// Output: { _id: 'BigDecimal', value: '0', scale: 0 }

console.log(decode("3"));
// Output: { _id: 'BigDecimal', value: '1', scale: 0 }
```

## Filters

### Overview

Developers can define custom validation logic beyond basic type checks, giving more control over how data is validated.

### Declaring Filters

Filters are declared using the `Schema.filter` function. This function requires two arguments: the schema to be validated and a predicate function. The predicate function is user-defined and determines whether the data satisfies the condition. If the data fails the validation, an error message can be provided.

**Example** (Defining a Minimum String Length Filter)

```ts
import { Schema } from "effect";

// Define a string schema with a filter to ensure the string
// is at least 10 characters long
const LongString = Schema.String.pipe(
  Schema.filter(
    // Custom error message for strings shorter than 10 characters
    (s) => s.length >= 10 || "a string at least 10 characters long",
  ),
);

//     ┌─── string
//     ▼
type Type = typeof LongString.Type;

console.log(Schema.decodeUnknownSync(LongString)("a"));
/*
throws:
ParseError: { string | filter }
└─ Predicate refinement failure
   └─ a string at least 10 characters long
*/
```

Note that the filter does not alter the schema's `Type`:

```ts
//     ┌─── string
//     ▼
type Type = typeof LongString.Type;
```

Filters add additional validation constraints without modifying the schema's underlying type.

> **Tip**: If you need to modify the `Type`, consider using [Branded
> types](/docs/schema/advanced-usage/#branded-types).

### The Predicate Function

The predicate function in a filter follows this structure:

```ts
type Predicate = (
  a: A,
  options: ParseOptions,
  self: AST.Refinement,
) => FilterReturnType;
```

where

```ts
interface FilterIssue {
  readonly path: ReadonlyArray<PropertyKey>;
  readonly issue: string | ParseResult.ParseIssue;
}

type FilterOutput =
  | undefined
  | boolean
  | string
  | ParseResult.ParseIssue
  | FilterIssue;

type FilterReturnType = FilterOutput | ReadonlyArray<FilterOutput>;
```

The filter's predicate can return several types of values, each affecting validation in a different way:

| Return Type                   | Behavior                                                                                         |
| ----------------------------- | ------------------------------------------------------------------------------------------------ |
| `true` or `undefined`         | The data satisfies the filter's condition and passes validation.                                 |
| `false`                       | The data does not meet the condition, and no specific error message is provided.                 |
| `string`                      | The validation fails, and the provided string is used as the error message.                      |
| `ParseResult.ParseIssue`      | The validation fails with a detailed error structure, specifying where and why it failed.        |
| `FilterIssue`                 | Allows for more detailed error messages with specific paths, providing enhanced error reporting. |
| `ReadonlyArray<FilterOutput>` | An array of issues can be returned if multiple validation errors need to be reported.            |

> **Tip**: Effectful Filters
> Normal filters only handle synchronous, non-effectful validations. If
> you need filters that involve asynchronous logic or side effects,
> consider using
> [Schema.filterEffect](/docs/schema/transformations/#effectful-filters).

### Adding Annotations

Embedding metadata within the schema, such as identifiers, JSON schema specifications, and descriptions, enhances understanding and analysis of the schema's constraints and purpose.

**Example** (Adding Metadata with Annotations)

```ts
import { Schema, JSONSchema } from "effect";

const LongString = Schema.String.pipe(
  Schema.filter(
    (s) =>
      s.length >= 10 ? undefined : "a string at least 10 characters long",
    {
      identifier: "LongString",
      jsonSchema: { minLength: 10 },
      description: "Lorem ipsum dolor sit amet, ...",
    },
  ),
);

console.log(Schema.decodeUnknownSync(LongString)("a"));
/*
throws:
ParseError: LongString
└─ Predicate refinement failure
   └─ a string at least 10 characters long
*/

console.log(JSON.stringify(JSONSchema.make(LongString), null, 2));
/*
Output:
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$defs": {
    "LongString": {
      "type": "string",
      "description": "Lorem ipsum dolor sit amet, ...",
      "minLength": 10
    }
  },
  "$ref": "#/$defs/LongString"
}
*/
```

### Specifying Error Paths

When validating forms or structured data, it's possible to associate specific error messages with particular fields or paths. This enhances error reporting and is especially useful when integrating with libraries like [react-hook-form](https://react-hook-form.com/).

**Example** (Matching Passwords)

```ts
import { Either, Schema, ParseResult } from "effect";

const Password = Schema.Trim.pipe(Schema.minLength(2));

const MyForm = Schema.Struct({
  password: Password,
  confirm_password: Password,
}).pipe(
  // Add a filter to ensure that passwords match
  Schema.filter((input) => {
    if (input.password !== input.confirm_password) {
      // Return an error message associated
      // with the "confirm_password" field
      return {
        path: ["confirm_password"],
        message: "Passwords do not match",
      };
    }
  }),
);

console.log(
  JSON.stringify(
    Schema.decodeUnknownEither(MyForm)({
      password: "abc",
      confirm_password: "abd", // Confirm password does not match
    }).pipe(
      Either.mapLeft((error) =>
        ParseResult.ArrayFormatter.formatErrorSync(error),
      ),
    ),
    null,
    2,
  ),
);
/*
  "_id": "Either",
  "_tag": "Left",
  "left": [
    {
      "_tag": "Type",
      "path": [
        "confirm_password"
      ],
      "message": "Passwords do not match"
    }
  ]
}
*/
```

In this example, we define a `MyForm` schema with two password fields (`password` and `confirm_password`). We use `Schema.filter` to check that both passwords match. If they don't, an error message is returned, specifically associated with the `confirm_password` field. This makes it easier to pinpoint the exact location of the validation failure.

The error is formatted in a structured way using `ArrayFormatter`, allowing for easier post-processing and integration with form libraries.

> **Tip**: Using ArrayFormatter for Structured Errors
> The `ArrayFormatter` provides a detailed and structured error format
> rather than a simple error string. This is especially useful when
> handling complex forms or structured data. For more information, see
> [ArrayFormatter](/docs/schema/error-formatters/#arrayformatter).

### Multiple Error Reporting

The `Schema.filter` API supports reporting multiple validation issues at once, which is especially useful in scenarios like form validation where several checks might fail simultaneously.

**Example** (Reporting Multiple Validation Errors)

```ts
import { Either, Schema, ParseResult } from "effect";

const Password = Schema.Trim.pipe(Schema.minLength(2));
const OptionalString = Schema.optional(Schema.String);

const MyForm = Schema.Struct({
  password: Password,
  confirm_password: Password,
  name: OptionalString,
  surname: OptionalString,
}).pipe(
  Schema.filter((input) => {
    const issues: Array<Schema.FilterIssue> = [];

    // Check if passwords match
    if (input.password !== input.confirm_password) {
      issues.push({
        path: ["confirm_password"],
        message: "Passwords do not match",
      });
    }

    // Ensure either name or surname is present
    if (!input.name && !input.surname) {
      issues.push({
        path: ["surname"],
        message: "Surname must be present if name is not present",
      });
    }
    return issues;
  }),
);

console.log(
  JSON.stringify(
    Schema.decodeUnknownEither(MyForm)({
      password: "abc",
      confirm_password: "abd", // Confirm password does not match
    }).pipe(
      Either.mapLeft((error) =>
        ParseResult.ArrayFormatter.formatErrorSync(error),
      ),
    ),
    null,
    2,
  ),
);
/*
{
  "_id": "Either",
  "_tag": "Left",
  "left": [
    {
      "_tag": "Type",
      "path": [
        "confirm_password"
      ],
      "message": "Passwords do not match"
    },
    {
      "_tag": "Type",
      "path": [
        "surname"
      ],
      "message": "Surname must be present if name is not present"
    }
  ]
}
*/
```

In this example, we define a `MyForm` schema with fields for password validation and optional name/surname fields. The `Schema.filter` function checks if the passwords match and ensures that either a name or surname is provided. If either validation fails, the corresponding error message is associated with the relevant field and both errors are returned in a structured format.

> **Tip**: Using ArrayFormatter for Structured Errors
> The `ArrayFormatter` provides a detailed and structured error format
> rather than a simple error string. This is especially useful when
> handling complex forms or structured data. For more information, see
> [ArrayFormatter](/docs/schema/error-formatters/#arrayformatter).

### Exposed Values

For schemas with filters, you can access the base schema (the schema before the filter was applied) using the `from` property:

```ts
import { Schema } from "effect";

const LongString = Schema.String.pipe(Schema.filter((s) => s.length >= 10));

// Access the base schema, which is the string schema
// before the filter was applied
//
//      ┌─── typeof Schema.String
//      ▼
const From = LongString.from;
```

### Built-in Filters

#### String Filters

Here is a list of useful string filters provided by the Schema module:

```ts
import { Schema } from "effect";

// Specifies maximum length of a string
Schema.String.pipe(Schema.maxLength(5));

// Specifies minimum length of a string
Schema.String.pipe(Schema.minLength(5));

// Equivalent to minLength(1)
Schema.String.pipe(Schema.nonEmptyString());
// or
Schema.NonEmptyString;

// Specifies exact length of a string
Schema.String.pipe(Schema.length(5));

// Specifies a range for the length of a string
Schema.String.pipe(Schema.length({ min: 2, max: 4 }));

// Matches a string against a regular expression pattern
Schema.String.pipe(Schema.pattern(/^[a-z]+$/));

// Ensures a string starts with a specific substring
Schema.String.pipe(Schema.startsWith("prefix"));

// Ensures a string ends with a specific substring
Schema.String.pipe(Schema.endsWith("suffix"));

// Checks if a string includes a specific substring
Schema.String.pipe(Schema.includes("substring"));

// Validates that a string has no leading or trailing whitespaces
Schema.String.pipe(Schema.trimmed());

// Validates that a string is entirely in lowercase
Schema.String.pipe(Schema.lowercased());

// Validates that a string is entirely in uppercase
Schema.String.pipe(Schema.uppercased());

// Validates that a string is capitalized
Schema.String.pipe(Schema.capitalized());

// Validates that a string is uncapitalized
Schema.String.pipe(Schema.uncapitalized());
```

> **Tip**: Trim vs Trimmed
> The `trimmed` combinator does not make any transformations, it only
> validates. If what you were looking for was a combinator to trim
> strings, then check out the `trim` combinator or the `Trim` schema.

#### Number Filters

Here is a list of useful number filters provided by the Schema module:

```ts
import { Schema } from "effect";

// Specifies a number greater than 5
Schema.Number.pipe(Schema.greaterThan(5));

// Specifies a number greater than or equal to 5
Schema.Number.pipe(Schema.greaterThanOrEqualTo(5));

// Specifies a number less than 5
Schema.Number.pipe(Schema.lessThan(5));

// Specifies a number less than or equal to 5
Schema.Number.pipe(Schema.lessThanOrEqualTo(5));

// Specifies a number between -2 and 2, inclusive
Schema.Number.pipe(Schema.between(-2, 2));

// Specifies that the value must be an integer
Schema.Number.pipe(Schema.int());
// or
Schema.Int;

// Ensures the value is not NaN
Schema.Number.pipe(Schema.nonNaN());
// or
Schema.NonNaN;

// Ensures that the provided value is a finite number
// (excluding NaN, +Infinity, and -Infinity)
Schema.Number.pipe(Schema.finite());
// or
Schema.Finite;

// Specifies a positive number (> 0)
Schema.Number.pipe(Schema.positive());
// or
Schema.Positive;

// Specifies a non-negative number (>= 0)
Schema.Number.pipe(Schema.nonNegative());
// or
Schema.NonNegative;

// A non-negative integer
Schema.NonNegativeInt;

// Specifies a negative number (< 0)
Schema.Number.pipe(Schema.negative());
// or
Schema.Negative;

// Specifies a non-positive number (<= 0)
Schema.Number.pipe(Schema.nonPositive());
// or
Schema.NonPositive;

// Specifies a number that is evenly divisible by 5
Schema.Number.pipe(Schema.multipleOf(5));

// A 8-bit unsigned integer (0 to 255)
Schema.Uint8;
```

#### ReadonlyArray Filters

Here is a list of useful array filters provided by the Schema module:

```ts
import { Schema } from "effect";

// Specifies the maximum number of items in the array
Schema.Array(Schema.Number).pipe(Schema.maxItems(2));

// Specifies the minimum number of items in the array
Schema.Array(Schema.Number).pipe(Schema.minItems(2));

// Specifies the exact number of items in the array
Schema.Array(Schema.Number).pipe(Schema.itemsCount(2));
```

#### Date Filters

```ts
import { Schema } from "effect";

// Specifies a valid date (rejects values like `new Date("Invalid Date")`)
Schema.DateFromSelf.pipe(Schema.validDate());
// or
Schema.ValidDateFromSelf;

// Specifies a date greater than the current date
Schema.Date.pipe(Schema.greaterThanDate(new Date()));

// Specifies a date greater than or equal to the current date
Schema.Date.pipe(Schema.greaterThanOrEqualToDate(new Date()));

// Specifies a date less than the current date
Schema.Date.pipe(Schema.lessThanDate(new Date()));

// Specifies a date less than or equal to the current date
Schema.Date.pipe(Schema.lessThanOrEqualToDate(new Date()));

// Specifies a date between two dates
Schema.Date.pipe(Schema.betweenDate(new Date(0), new Date()));
```

#### BigInt Filters

Here is a list of useful `BigInt` filters provided by the Schema module:

```ts
import { Schema } from "effect";

// Specifies a BigInt greater than 5
Schema.BigInt.pipe(Schema.greaterThanBigInt(5n));

// Specifies a BigInt greater than or equal to 5
Schema.BigInt.pipe(Schema.greaterThanOrEqualToBigInt(5n));

// Specifies a BigInt less than 5
Schema.BigInt.pipe(Schema.lessThanBigInt(5n));

// Specifies a BigInt less than or equal to 5
Schema.BigInt.pipe(Schema.lessThanOrEqualToBigInt(5n));

// Specifies a BigInt between -2n and 2n, inclusive
Schema.BigInt.pipe(Schema.betweenBigInt(-2n, 2n));

// Specifies a positive BigInt (> 0n)
Schema.BigInt.pipe(Schema.positiveBigInt());
// or
Schema.PositiveBigIntFromSelf;

// Specifies a non-negative BigInt (>= 0n)
Schema.BigInt.pipe(Schema.nonNegativeBigInt());
// or
Schema.NonNegativeBigIntFromSelf;

// Specifies a negative BigInt (< 0n)
Schema.BigInt.pipe(Schema.negativeBigInt());
// or
Schema.NegativeBigIntFromSelf;

// Specifies a non-positive BigInt (<= 0n)
Schema.BigInt.pipe(Schema.nonPositiveBigInt());
// or
Schema.NonPositiveBigIntFromSelf;
```

#### BigDecimal Filters

Here is a list of useful `BigDecimal` filters provided by the Schema module:

```ts
import { Schema, BigDecimal } from "effect";

// Specifies a BigDecimal greater than 5
Schema.BigDecimal.pipe(
  Schema.greaterThanBigDecimal(BigDecimal.unsafeFromNumber(5)),
);

// Specifies a BigDecimal greater than or equal to 5
Schema.BigDecimal.pipe(
  Schema.greaterThanOrEqualToBigDecimal(BigDecimal.unsafeFromNumber(5)),
);
// Specifies a BigDecimal less than 5
Schema.BigDecimal.pipe(
  Schema.lessThanBigDecimal(BigDecimal.unsafeFromNumber(5)),
);

// Specifies a BigDecimal less than or equal to 5
Schema.BigDecimal.pipe(
  Schema.lessThanOrEqualToBigDecimal(BigDecimal.unsafeFromNumber(5)),
);

// Specifies a BigDecimal between -2 and 2, inclusive
Schema.BigDecimal.pipe(
  Schema.betweenBigDecimal(
    BigDecimal.unsafeFromNumber(-2),
    BigDecimal.unsafeFromNumber(2),
  ),
);

// Specifies a positive BigDecimal (> 0)
Schema.BigDecimal.pipe(Schema.positiveBigDecimal());

// Specifies a non-negative BigDecimal (>= 0)
Schema.BigDecimal.pipe(Schema.nonNegativeBigDecimal());

// Specifies a negative BigDecimal (< 0)
Schema.BigDecimal.pipe(Schema.negativeBigDecimal());

// Specifies a non-positive BigDecimal (<= 0)
Schema.BigDecimal.pipe(Schema.nonPositiveBigDecimal());
```

#### Duration Filters

Here is a list of useful [Duration](/docs/data-types/duration/) filters provided by the Schema module:

```ts
import { Schema } from "effect";

// Specifies a duration greater than 5 seconds
Schema.Duration.pipe(Schema.greaterThanDuration("5 seconds"));

// Specifies a duration greater than or equal to 5 seconds
Schema.Duration.pipe(Schema.greaterThanOrEqualToDuration("5 seconds"));

// Specifies a duration less than 5 seconds
Schema.Duration.pipe(Schema.lessThanDuration("5 seconds"));

// Specifies a duration less than or equal to 5 seconds
Schema.Duration.pipe(Schema.lessThanOrEqualToDuration("5 seconds"));

// Specifies a duration between 5 seconds and 10 seconds, inclusive
Schema.Duration.pipe(Schema.betweenDuration("5 seconds", "10 seconds"));
```
