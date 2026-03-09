# Schema: Validation & Errors

## Error Messages

### Default Error Messages

By default, when a parsing error occurs, the system automatically generates an informative message based on the schema's structure and the nature of the error (see [TreeFormatter](#treeformatter-default) for more informations).
For example, if a required property is missing or a data type does not match, the error message will clearly state the expectation versus the actual input.

**Example** (Type Mismatch)

```ts
import { Schema } from "effect";

const Person = Schema.Struct({
  name: Schema.String,
  age: Schema.Number,
});

Schema.decodeUnknownSync(Person)(null);
// Output: ParseError: Expected { readonly name: string; readonly age: number }, actual null
```

**Example** (Missing Properties)

```ts
import { Schema } from "effect";

const Person = Schema.Struct({
  name: Schema.String,
  age: Schema.Number,
});

Schema.decodeUnknownSync(Person)({}, { errors: "all" });
/*
throws:
ParseError: { readonly name: string; readonly age: number }
├─ ["name"]
│  └─ is missing
└─ ["age"]
   └─ is missing
*/
```

**Example** (Incorrect Property Type)

```ts
import { Schema } from "effect";

const Person = Schema.Struct({
  name: Schema.String,
  age: Schema.Number,
});

Schema.decodeUnknownSync(Person)({ name: null, age: "age" }, { errors: "all" });
/*
throws:
ParseError: { readonly name: string; readonly age: number }
├─ ["name"]
│  └─ Expected string, actual null
└─ ["age"]
   └─ Expected number, actual "age"
*/
```

### Enhancing Clarity in Error Messages with Identifiers

In scenarios where a schema has multiple fields or nested structures, the default error messages can become overly complex and verbose.
To address this, you can enhance the clarity and brevity of these messages by utilizing annotations such as `identifier`, `title`, and `description`.

**Example** (Using Identifiers for Clarity)

```ts
import { Schema } from "effect";

const Name = Schema.String.annotations({ identifier: "Name" });

const Age = Schema.Number.annotations({ identifier: "Age" });

const Person = Schema.Struct({
  name: Name,
  age: Age,
}).annotations({ identifier: "Person" });

Schema.decodeUnknownSync(Person)(null);
/*
throws:
ParseError: Expected Person, actual null
*/

Schema.decodeUnknownSync(Person)({}, { errors: "all" });
/*
throws:
ParseError: Person
├─ ["name"]
│  └─ is missing
└─ ["age"]
   └─ is missing
*/

Schema.decodeUnknownSync(Person)({ name: null, age: null }, { errors: "all" });
/*
throws:
ParseError: Person
├─ ["name"]
│  └─ Expected Name, actual null
└─ ["age"]
   └─ Expected Age, actual null
*/
```

### Refinements

When a refinement fails, the default error message indicates whether the failure occurred in the "from" part or within the predicate defining the refinement:

**Example** (Refinement Errors)

```ts
import { Schema } from "effect";

const Name = Schema.NonEmptyString.annotations({ identifier: "Name" });

const Age = Schema.Positive.pipe(Schema.int({ identifier: "Age" }));

const Person = Schema.Struct({
  name: Name,
  age: Age,
}).annotations({ identifier: "Person" });

// From side failure
Schema.decodeUnknownSync(Person)({ name: null, age: 18 });
/*
throws:
ParseError: Person
└─ ["name"]
   └─ Name
      └─ From side refinement failure
         └─ Expected string, actual null
*/

// Predicate refinement failure
Schema.decodeUnknownSync(Person)({ name: "", age: 18 });
/*
throws:
ParseError: Person
└─ ["name"]
   └─ Name
      └─ Predicate refinement failure
         └─ Expected a non empty string, actual ""
*/
```

In the first example, the error message indicates a "from side" refinement failure in the `name` property, specifying that a string was expected but received `null`.
In the second example, a "predicate" refinement failure is reported, indicating that a non-empty string was expected for `name` but an empty string was provided.

### Transformations

Transformations between different types or formats can occasionally result in errors.
The system provides a structured error message to specify where the error occurred:

- **Encoded Side Failure:** Errors on this side typically indicate that the input to the transformation does not match the expected initial type or format. For example, receiving a `null` when a `string` is expected.
- **Transformation Process Failure:** This type of error arises when the transformation logic itself fails, such as when the input does not meet the criteria specified within the transformation functions.
- **Type Side Failure:** Occurs when the output of a transformation does not meet the schema requirements on the decoded side. This can happen if the transformed value fails subsequent validations or conditions.

**Example** (Transformation Errors)

```ts
import { ParseResult, Schema } from "effect";

const schema = Schema.transformOrFail(
  Schema.String,
  Schema.String.pipe(Schema.minLength(2)),
  {
    strict: true,
    decode: (s, _, ast) =>
      s.length > 0
        ? ParseResult.succeed(s)
        : ParseResult.fail(new ParseResult.Type(ast, s)),
    encode: ParseResult.succeed,
  },
);

// Encoded side failure
Schema.decodeUnknownSync(schema)(null);
/*
throws:
ParseError: (string <-> minLength(2))
└─ Encoded side transformation failure
   └─ Expected string, actual null
*/

// transformation failure
Schema.decodeUnknownSync(schema)("");
/*
throws:
ParseError: (string <-> minLength(2))
└─ Transformation process failure
   └─ Expected (string <-> minLength(2)), actual ""
*/

// Type side failure
Schema.decodeUnknownSync(schema)("a");
/*
throws:
ParseError: (string <-> minLength(2))
└─ Type side transformation failure
   └─ minLength(2)
      └─ Predicate refinement failure
         └─ Expected a string at least 2 character(s) long, actual "a"
*/
```

### Custom Error Messages

You have the capability to define custom error messages specifically tailored for different parts of your schema using the `message` annotation.
This allows developers to provide more context-specific feedback which can improve the debugging and validation processes.

Here's an overview of the `MessageAnnotation` type, which you can use to craft these messages:

```ts
type MessageAnnotation = (issue: ParseIssue) =>
  | string
  | Effect<string>
  | {
      readonly message: string | Effect<string>;
      readonly override: boolean;
    };
```

| Return Type                            | Description                                                                                                                                                                                                                                                  |
| -------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `string`                               | Provides a static message that directly describes the error.                                                                                                                                                                                                 |
| `Effect<string>`                       | Utilizes dynamic messages that can incorporate results from **synchronous** processes or rely on **optional** dependencies.                                                                                                                                  |
| Object (with `message` and `override`) | Allows you to define a specific error message along with a boolean flag (`override`). This flag determines if the custom message should supersede any default or nested custom messages, providing precise control over the error output displayed to users. |

**Example** (Adding a Custom Error Message to a String Schema)

```ts
import { Schema } from "effect";

// Define a string schema without a custom message
const MyString = Schema.String;

// Attempt to decode `null`, resulting in a default error message
Schema.decodeUnknownSync(MyString)(null);
/*
throws:
ParseError: Expected string, actual null
*/

// Define a string schema with a custom error message
const MyStringWithMessage = Schema.String.annotations({
  message: () => "not a string",
});

// Decode with the custom schema, showing the new error message
Schema.decodeUnknownSync(MyStringWithMessage)(null);
/*
throws:
ParseError: not a string
*/
```

**Example** (Custom Error Message for a Union Schema with Override Option)

```ts
import { Schema } from "effect";

// Define a union schema without a custom message
const MyUnion = Schema.Union(Schema.String, Schema.Number);

// Decode `null`, resulting in default union error messages
Schema.decodeUnknownSync(MyUnion)(null);
/*
throws:
ParseError: string | number
├─ Expected string, actual null
└─ Expected number, actual null
*/

// Define a union schema with a custom message and override flag
const MyUnionWithMessage = Schema.Union(
  Schema.String,
  Schema.Number,
).annotations({
  message: () => ({
    message: "Please provide a string or a number",
    // Ensures this message replaces all nested messages
    override: true,
  }),
});

// Decode with the custom schema, showing the new error message
Schema.decodeUnknownSync(MyUnionWithMessage)(null);
/*
throws:
ParseError: Please provide a string or a number
*/
```

### General Guidelines for Messages

The general logic followed to determine the messages is as follows:

1. If no custom messages are set, the default message related to the innermost schema where the operation (i.e., decoding or encoding) failed is used.

2. If custom messages are set, then the message corresponding to the **first** failed schema is used, starting from the innermost schema to the outermost. However, if the failing schema does not have a custom message, then **the default message is used**.

3. As an opt-in feature, **you can override guideline 2** by setting the `override` flag to `true`. This allows the custom message to take precedence over all other custom messages from inner schemas. This is to address the scenario where a user wants to define a single cumulative custom message describing the properties that a valid value must have and does not want to see default messages.

Let's see some practical examples.

### Scalar Schemas

**Example** (Simple Custom Message for Scalar Schema)

```ts
import { Schema } from "effect";

const MyString = Schema.String.annotations({
  message: () => "my custom message",
});

const decode = Schema.decodeUnknownSync(MyString);

try {
  decode(null);
} catch (e: any) {
  console.log(e.message); // "my custom message"
}
```

### Refinements

This example demonstrates setting a custom message on the last refinement in a chain of refinements. As you can see, the custom message is only used if the refinement related to `maxLength` fails; otherwise, default messages are used.

**Example** (Custom Message on Last Refinement in Chain)

```ts
import { Schema } from "effect";

const MyString = Schema.String.pipe(
  Schema.minLength(1),
  Schema.maxLength(2),
).annotations({
  // This message is displayed only if the last filter (`maxLength`) fails
  message: () => "my custom message",
});

const decode = Schema.decodeUnknownSync(MyString);

try {
  decode(null);
} catch (e: any) {
  console.log(e.message);
  /*
   minLength(1) & maxLength(2)
   └─ From side refinement failure
      └─ minLength(1)
         └─ From side refinement failure
            └─ Expected string, actual null
  */
}

try {
  decode("");
} catch (e: any) {
  console.log(e.message);
  /*
   minLength(1) & maxLength(2)
   └─ From side refinement failure
      └─ minLength(1)
         └─ Predicate refinement failure
            └─ Expected a string at least 1 character(s) long, actual ""
  */
}

try {
  decode("abc");
} catch (e: any) {
  console.log(e.message);
  // "my custom message"
}
```

When setting multiple custom messages, the one corresponding to the **first** failed predicate is used, starting from the innermost refinement to the outermost:

**Example** (Custom Messages for Multiple Refinements)

```ts
import { Schema } from "effect";

const MyString = Schema.String
  // This message is displayed only if a non-String is passed as input
  .annotations({ message: () => "String custom message" })
  .pipe(
    // This message is displayed only if the filter `minLength` fails
    Schema.minLength(1, { message: () => "minLength custom message" }),
    // This message is displayed only if the filter `maxLength` fails
    Schema.maxLength(2, { message: () => "maxLength custom message" }),
  );

const decode = Schema.decodeUnknownSync(MyString);

try {
  decode(null);
} catch (e: any) {
  console.log(e.message); // String custom message
}

try {
  decode("");
} catch (e: any) {
  console.log(e.message); // minLength custom message
}

try {
  decode("abc");
} catch (e: any) {
  console.log(e.message); // maxLength custom message
}
```

You have the option to change the default behavior by setting the `override` flag to `true`. This is useful when you want to create a single comprehensive custom message that describes the required properties of a valid value without displaying default messages.

**Example** (Overriding Default Messages)

```ts
import { Schema } from "effect";

const MyString = Schema.String.pipe(
  Schema.minLength(1),
  Schema.maxLength(2),
).annotations({
  // By setting the `override` flag to `true`, this message will always be shown for any error
  message: () => ({ message: "my custom message", override: true }),
});

const decode = Schema.decodeUnknownSync(MyString);

try {
  decode(null);
} catch (e: any) {
  console.log(e.message); // my custom message
}

try {
  decode("");
} catch (e: any) {
  console.log(e.message); // my custom message
}

try {
  decode("abc");
} catch (e: any) {
  console.log(e.message); // my custom message
}
```

### Transformations

In this example, `IntFromString` is a transformation schema that converts strings to integers. It applies specific validation messages based on different scenarios.

**Example** (Custom Error Messages for String-to-Integer Transformation)

```ts
import { ParseResult, Schema } from "effect";

const IntFromString = Schema.transformOrFail(
  // This message is displayed only if the input is not a string
  Schema.String.annotations({ message: () => "please enter a string" }),
  // This message is displayed only if the input can be converted
  // to a number but it's not an integer
  Schema.Int.annotations({ message: () => "please enter an integer" }),
  {
    strict: true,
    decode: (s, _, ast) => {
      const n = Number(s);
      return Number.isNaN(n)
        ? ParseResult.fail(new ParseResult.Type(ast, s))
        : ParseResult.succeed(n);
    },
    encode: (n) => ParseResult.succeed(String(n)),
  },
)
  // This message is displayed only if the input
  // cannot be converted to a number
  .annotations({ message: () => "please enter a parseable string" });

const decode = Schema.decodeUnknownSync(IntFromString);

try {
  decode(null);
} catch (e: any) {
  console.log(e.message); // please enter a string
}

try {
  decode("1.2");
} catch (e: any) {
  console.log(e.message); // please enter an integer
}

try {
  decode("not a number");
} catch (e: any) {
  console.log(e.message); // please enter a parseable string
}
```

### Compound Schemas

The custom message system becomes especially handy when dealing with complex schemas, unlike simple scalar values like `string` or `number`. For instance, consider a schema comprising nested structures, such as a struct containing an array of other structs. Let's explore an example demonstrating the advantage of default messages in handling decoding errors within such nested structures:

**Example** (Custom Error Messages in Nested Schemas)

```ts
import { Schema, pipe } from "effect";

const schema = Schema.Struct({
  outcomes: pipe(
    Schema.Array(
      Schema.Struct({
        id: Schema.String,
        text: pipe(
          Schema.String.annotations({
            message: () => "error_invalid_outcome_type",
          }),
          Schema.minLength(1, { message: () => "error_required_field" }),
          Schema.maxLength(50, {
            message: () => "error_max_length_field",
          }),
        ),
      }),
    ),
    Schema.minItems(1, { message: () => "error_min_length_field" }),
  ),
});

Schema.decodeUnknownSync(schema, { errors: "all" })({
  outcomes: [],
});
/*
throws
ParseError: { readonly outcomes: minItems(1) }
└─ ["outcomes"]
   └─ error_min_length_field
*/

Schema.decodeUnknownSync(schema, { errors: "all" })({
  outcomes: [
    { id: "1", text: "" },
    { id: "2", text: "this one is valid" },
    { id: "3", text: "1234567890".repeat(6) },
  ],
});
/*
throws
ParseError: { readonly outcomes: minItems(1) }
└─ ["outcomes"]
   └─ minItems(1)
      └─ From side refinement failure
         └─ ReadonlyArray<{ readonly id: string; readonly text: minLength(1) & maxLength(50) }>
            ├─ [0]
            │  └─ { readonly id: string; readonly text: minLength(1) & maxLength(50) }
            │     └─ ["text"]
            │        └─ error_required_field
            └─ [2]
               └─ { readonly id: string; readonly text: minLength(1) & maxLength(50) }
                  └─ ["text"]
                     └─ error_max_length_field
*/
```

### Effectful messages

Error messages can go beyond simple strings by returning an `Effect`, allowing them to access dependencies, such as an internationalization service. This approach lets messages dynamically adjust based on external context or services. Below is an example illustrating how to create effect-based messages.

**Example** (Effect-Based Message with Internationalization Service)

```ts
import { Context, Effect, Either, Option, Schema, ParseResult } from "effect";

// Define an internationalization service for custom messages
class Messages extends Context.Tag("Messages")<
  Messages,
  {
    NonEmpty: string;
  }
>() {}

// Define a schema with an effect-based message
// that depends on the Messages service
const Name = Schema.NonEmptyString.annotations({
  message: () =>
    Effect.gen(function* () {
      // Attempt to retrieve the Messages service
      const service = yield* Effect.serviceOption(Messages);
      // Use a fallback message if the service is not available
      return Option.match(service, {
        onNone: () => "Invalid string",
        onSome: (messages) => messages.NonEmpty,
      });
    }),
});

// Attempt to decode an empty string without providing the Messages service
Schema.decodeUnknownEither(Name)("").pipe(
  Either.mapLeft((error) =>
    ParseResult.TreeFormatter.formatError(error).pipe(
      Effect.runSync,
      console.log,
    ),
  ),
);
// Output: Invalid string

// Provide the Messages service to customize the error message
Schema.decodeUnknownEither(Name)("").pipe(
  Either.mapLeft((error) =>
    ParseResult.TreeFormatter.formatError(error).pipe(
      Effect.provideService(Messages, {
        NonEmpty: "should be non empty",
      }),
      Effect.runSync,
      console.log,
    ),
  ),
);
// Output: should be non empty
```

### Missing messages

You can provide custom messages for missing fields or tuple elements using the `missingMessage` annotation.

**Example** (Custom Message for Missing Property)

In this example, a custom message is defined for a missing `name` property in the `Person` schema.

```ts
import { Schema } from "effect";

const Person = Schema.Struct({
  name: Schema.propertySignature(Schema.String).annotations({
    // Custom message if "name" is missing
    missingMessage: () => "Name is required",
  }),
});

Schema.decodeUnknownSync(Person)({});
/*
throws:
ParseError: { readonly name: string }
└─ ["name"]
   └─ Name is required
*/
```

**Example** (Custom Message for Missing Tuple Elements)

Here, each element in the `Point` tuple schema has a specific custom message if the element is missing.

```ts
import { Schema } from "effect";

const Point = Schema.Tuple(
  Schema.element(Schema.Number).annotations({
    // Message if X is missing
    missingMessage: () => "X coordinate is required",
  }),
  Schema.element(Schema.Number).annotations({
    // Message if Y is missing
    missingMessage: () => "Y coordinate is required",
  }),
);

Schema.decodeUnknownSync(Point)([], { errors: "all" });
/*
throws:
ParseError: readonly [number, number]
├─ [0]
│  └─ X coordinate is required
└─ [1]
   └─ Y coordinate is required
*/
```

## Error Formatters

When working with Effect Schema, errors encountered during decoding or encoding operations can be formatted using two built-in methods: `TreeFormatter` and `ArrayFormatter`. These formatters help structure and present errors in a readable and actionable manner.

### TreeFormatter (default)

The `TreeFormatter` is the default method for formatting errors. It organizes errors in a tree structure, providing a clear hierarchy of issues.

**Example** (Decoding with Missing Properties)

```ts
import { Either, Schema, ParseResult } from "effect";

const Person = Schema.Struct({
  name: Schema.String,
  age: Schema.Number,
});

const decode = Schema.decodeUnknownEither(Person);

const result = decode({});
if (Either.isLeft(result)) {
  console.error("Decoding failed:");
  console.error(ParseResult.TreeFormatter.formatErrorSync(result.left));
}
/*
Decoding failed:
{ readonly name: string; readonly age: number }
└─ ["name"]
   └─ is missing
*/
```

In this example:

- `{ readonly name: string; readonly age: number }` describes the schema's expected structure.
- `["name"]` identifies the specific field causing the error.
- `is missing` explains the issue for the `"name"` field.

### Customizing the Output

You can make the error output more concise and meaningful by annotating the schema with annotations like `identifier`, `title`, or `description`. These annotations replace the default TypeScript-like representation in the error messages.

**Example** (Using `title` Annotation for Clarity)

Adding a `title` annotation replaces the schema structure in the error message with the more human-readable "Person" making it easier to understand.

```ts
import { Either, Schema, ParseResult } from "effect";

const Person = Schema.Struct({
  name: Schema.String,
  age: Schema.Number,
}).annotations({ title: "Person" }); // Add a title annotation

const result = Schema.decodeUnknownEither(Person)({});
if (Either.isLeft(result)) {
  console.error(ParseResult.TreeFormatter.formatErrorSync(result.left));
}
/*
Person
└─ ["name"]
   └─ is missing
*/
```

### Handling Multiple Errors

By default, decoding functions like `Schema.decodeUnknownEither` report only the first error. To list all errors, use the `{ errors: "all" }` option.

**Example** (Listing All Errors)

```ts
import { Either, Schema, ParseResult } from "effect";

const Person = Schema.Struct({
  name: Schema.String,
  age: Schema.Number,
});

const decode = Schema.decodeUnknownEither(Person, { errors: "all" });

const result = decode({});
if (Either.isLeft(result)) {
  console.error("Decoding failed:");
  console.error(ParseResult.TreeFormatter.formatErrorSync(result.left));
}
/*
Decoding failed:
{ readonly name: string; readonly age: number }
├─ ["name"]
│  └─ is missing
└─ ["age"]
   └─ is missing
*/
```

### ParseIssueTitle Annotation

The `parseIssueTitle` annotation allows you to add dynamic context to error messages by generating titles based on the value being validated. For instance, it can include an ID from the validated object, making it easier to identify specific issues in complex or nested data structures.

**Annotation Type**

```ts
export type ParseIssueTitleAnnotation = (
  issue: ParseIssue,
) => string | undefined;
```

**Return Value**:

- If the function returns a `string`, the `TreeFormatter` uses it as the title unless a `message` annotation is present (which takes precedence).
- If the function returns `undefined`, the `TreeFormatter` determines the title based on the following priority:
  1. `identifier` annotation
  2. `title` annotation
  3. `description` annotation
  4. Default TypeScript-like schema representation

**Example** (Dynamic Titles Using `parseIssueTitle`)

```ts
import type { ParseResult } from "effect";
import { Schema } from "effect";

// Function to generate titles for OrderItem issues
const getOrderItemId = ({ actual }: ParseResult.ParseIssue) => {
  if (Schema.is(Schema.Struct({ id: Schema.String }))(actual)) {
    return `OrderItem with id: ${actual.id}`;
  }
};

const OrderItem = Schema.Struct({
  id: Schema.String,
  name: Schema.String,
  price: Schema.Number,
}).annotations({
  identifier: "OrderItem",
  parseIssueTitle: getOrderItemId,
});

// Function to generate titles for Order issues
const getOrderId = ({ actual }: ParseResult.ParseIssue) => {
  if (Schema.is(Schema.Struct({ id: Schema.Number }))(actual)) {
    return `Order with id: ${actual.id}`;
  }
};

const Order = Schema.Struct({
  id: Schema.Number,
  name: Schema.String,
  items: Schema.Array(OrderItem),
}).annotations({
  identifier: "Order",
  parseIssueTitle: getOrderId,
});

const decode = Schema.decodeUnknownSync(Order, { errors: "all" });

// Case 1: No id available, uses the `identifier` annotation
decode({});
/*
throws
ParseError: Order
├─ ["id"]
│  └─ is missing
├─ ["name"]
│  └─ is missing
└─ ["items"]
   └─ is missing
*/

// Case 2: ID present, uses the dynamic `parseIssueTitle` annotation
decode({ id: 1 });
/*
throws
ParseError: Order with id: 1
├─ ["name"]
│  └─ is missing
└─ ["items"]
   └─ is missing
*/

// Case 3: Nested issues with IDs for both Order and OrderItem
decode({ id: 1, items: [{ id: "22b", price: "100" }] });
/*
throws
ParseError: Order with id: 1
├─ ["name"]
│  └─ is missing
└─ ["items"]
   └─ ReadonlyArray<OrderItem>
      └─ [0]
         └─ OrderItem with id: 22b
            ├─ ["name"]
            │  └─ is missing
            └─ ["price"]
               └─ Expected a number, actual "100"
*/
```

### ArrayFormatter

The `ArrayFormatter` provides a structured, array-based approach to formatting errors. It represents each error as an object, making it easier to analyze and address multiple issues during data decoding or encoding. Each error object includes properties like `_tag`, `path`, and `message` for clarity.

**Example** (Single Error in Array Format)

```ts
import { Either, Schema, ParseResult } from "effect";

const Person = Schema.Struct({
  name: Schema.String,
  age: Schema.Number,
});

const decode = Schema.decodeUnknownEither(Person);

const result = decode({});
if (Either.isLeft(result)) {
  console.error("Decoding failed:");
  console.error(ParseResult.ArrayFormatter.formatErrorSync(result.left));
}
/*
Decoding failed:
[ { _tag: 'Missing', path: [ 'name' ], message: 'is missing' } ]
*/
```

In this example:

- `_tag`: Indicates the type of error (`Missing`).
- `path`: Specifies the location of the error in the data (`['name']`).
- `message`: Describes the issue (`'is missing'`).

### Handling Multiple Errors

By default, decoding functions like `Schema.decodeUnknownEither` report only the first error. To list all errors, use the `{ errors: "all" }` option.

**Example** (Listing All Errors)

```ts
import { Either, Schema, ParseResult } from "effect";

const Person = Schema.Struct({
  name: Schema.String,
  age: Schema.Number,
});

const decode = Schema.decodeUnknownEither(Person, { errors: "all" });

const result = decode({});
if (Either.isLeft(result)) {
  console.error("Decoding failed:");
  console.error(ParseResult.ArrayFormatter.formatErrorSync(result.left));
}
/*
Decoding failed:
[
  { _tag: 'Missing', path: [ 'name' ], message: 'is missing' },
  { _tag: 'Missing', path: [ 'age' ], message: 'is missing' }
]
*/
```

### React Hook Form

If you are working with React and need form validation, `@hookform/resolvers` offers an adapter for `effect/Schema`, which can be integrated with React Hook Form for enhanced form validation processes. This integration allows you to leverage the powerful features of `effect/Schema` within your React applications.

For more detailed instructions and examples on how to integrate `effect/Schema` with React Hook Form using `@hookform/resolvers`, you can visit the official npm package page:
[React Hook Form Resolvers](https://www.npmjs.com/package/@hookform/resolvers#effect-ts)

## Annotations

One of the key features of the Schema design is its flexibility and ability to be customized.
This is achieved through "annotations."
Each node in the `ast` field of a schema has an `annotations: Record<string | symbol, unknown>` field,
which allows you to attach additional information to the schema.
You can manage these annotations using the `annotations` method or the `Schema.annotations` API.

**Example** (Using Annotations to Customize Schema)

```ts
import { Schema } from "effect";

// Define a Password schema, starting with a string type
const Password = Schema.String
  // Add a custom error message for non-string values
  .annotations({ message: () => "not a string" })
  .pipe(
    // Enforce non-empty strings and provide a custom error message
    Schema.nonEmptyString({ message: () => "required" }),
    // Restrict the string length to 10 characters or fewer
    // with a custom error message for exceeding length
    Schema.maxLength(10, {
      message: (issue) => `${issue.actual} is too long`,
    }),
  )
  .annotations({
    // Add a unique identifier for the schema
    identifier: "Password",
    // Provide a title for the schema
    title: "password",
    // Include a description explaining what this schema represents
    description: "A password is a secret string used to authenticate a user",
    // Add examples for better clarity
    examples: ["1Ki77y", "jelly22fi$h"],
    // Include any additional documentation
    documentation: `...technical information on Password schema...`,
  });
```

### Built-in Annotations

The following table provides an overview of common built-in annotations and their uses:

| Annotation         | Description                                                                                                                                                                                                      |
| ------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `identifier`       | Assigns a unique identifier to the schema, ideal for TypeScript identifiers and code generation purposes. Commonly used in tools like TreeFormatter to clarify output. Examples include `"Person"`, `"Product"`. |
| `title`            | Sets a short, descriptive title for the schema, similar to a JSON Schema title. Useful for documentation or UI headings. It is also used by TreeFormatter to enhance readability of error messages.              |
| `description`      | Provides a detailed explanation about the schema's purpose, akin to a JSON Schema description. Used by TreeFormatter to provide more detailed error messages.                                                    |
| `documentation`    | Extends detailed documentation for the schema, beneficial for developers or automated documentation generation.                                                                                                  |
| `examples`         | Lists examples of valid schema values, akin to the examples attribute in JSON Schema, useful for documentation and validation testing.                                                                           |
| `default`          | Defines a default value for the schema, similar to the default attribute in JSON Schema, to ensure schemas are pre-populated where applicable.                                                                   |
| `message`          | Customizes the error message for validation failures, improving clarity in outputs from tools like TreeFormatter and ArrayFormatter during decoding or validation errors.                                        |
| `jsonSchema`       | Specifies annotations that affect the generation of JSON Schema documents, customizing how schemas are represented.                                                                                              |
| `arbitrary`        | Configures settings for generating Arbitrary test data.                                                                                                                                                          |
| `pretty`           | Configures settings for generating Pretty output.                                                                                                                                                                |
| `equivalence`      | Configures settings for evaluating data Equivalence.                                                                                                                                                             |
| `concurrency`      | Controls concurrency behavior, ensuring schemas perform optimally under concurrent operations. Refer to Concurrency Annotation for detailed usage.                                                               |
| `batching`         | Manages settings for batching operations to enhance performance when operations can be grouped.                                                                                                                  |
| `parseIssueTitle`  | Provides a custom title for parsing issues, enhancing error descriptions in outputs from TreeFormatter. See ParseIssueTitle Annotation for more information.                                                     |
| `parseOptions`     | Allows overriding of parsing options at the schema level, offering granular control over parsing behaviors. See Customizing Parsing Behavior at the Schema Level for application details.                        |
| `decodingFallback` | Provides a way to define custom fallback behaviors that trigger when decoding operations fail. Refer to Handling Decoding Errors with Fallbacks for detailed usage.                                              |

### Concurrency Annotation

For more complex schemas like `Struct`, `Array`, or `Union` that contain multiple nested schemas, the `concurrency` annotation provides a way to control how validations are executed concurrently.

```ts
type ConcurrencyAnnotation = number | "unbounded" | "inherit" | undefined;
```

Here's a shorter version presented in a table:

| Value         | Description                                                     |
| ------------- | --------------------------------------------------------------- |
| `number`      | Limits the maximum number of concurrent tasks.                  |
| `"unbounded"` | All tasks run concurrently with no limit.                       |
| `"inherit"`   | Inherits concurrency settings from the parent context.          |
| `undefined`   | Tasks run sequentially, one after the other (default behavior). |

**Example** (Sequential Execution)

In this example, we define three tasks that simulate asynchronous operations with different durations. Since no concurrency is specified, the tasks are executed sequentially, one after the other.

```ts
import { Schema } from "effect";
import type { Duration } from "effect";
import { Effect } from "effect";

// Simulates an async task
const item = (id: number, duration: Duration.DurationInput) =>
  Schema.String.pipe(
    Schema.filterEffect(() =>
      Effect.gen(function* () {
        yield* Effect.sleep(duration);
        console.log(`Task ${id} done`);
        return true;
      }),
    ),
  );

const Sequential = Schema.Tuple(
  item(1, "30 millis"),
  item(2, "10 millis"),
  item(3, "20 millis"),
);

Effect.runPromise(Schema.decode(Sequential)(["a", "b", "c"]));
/*
Output:
Task 1 done
Task 2 done
Task 3 done
*/
```

**Example** (Concurrent Execution)

By adding a `concurrency` annotation set to `"unbounded"`, the tasks can now run concurrently, meaning they don't wait for one another to finish before starting. This allows faster execution when multiple tasks are involved.

```ts
import { Schema } from "effect";
import type { Duration } from "effect";
import { Effect } from "effect";

// Simulates an async task
const item = (id: number, duration: Duration.DurationInput) =>
  Schema.String.pipe(
    Schema.filterEffect(() =>
      Effect.gen(function* () {
        yield* Effect.sleep(duration);
        console.log(`Task ${id} done`);
        return true;
      }),
    ),
  );

const Concurrent = Schema.Tuple(
  item(1, "30 millis"),
  item(2, "10 millis"),
  item(3, "20 millis"),
).annotations({ concurrency: "unbounded" });

Effect.runPromise(Schema.decode(Concurrent)(["a", "b", "c"]));
/*
Output:
Task 2 done
Task 3 done
Task 1 done
*/
```

### Handling Decoding Errors with Fallbacks

The `DecodingFallbackAnnotation` allows you to handle decoding errors by providing a custom fallback logic.

```ts
type DecodingFallbackAnnotation<A> = (
  issue: ParseIssue,
) => Effect<A, ParseIssue>;
```

This annotation enables you to specify fallback behavior when decoding fails, making it possible to recover gracefully from errors.

**Example** (Basic Fallback)

In this basic example, when decoding fails (e.g., the input is `null`), the fallback value is returned instead of an error.

```ts
import { Schema } from "effect";
import { Either } from "effect";

// Schema with a fallback value
const schema = Schema.String.annotations({
  decodingFallback: () => Either.right("<fallback>"),
});

console.log(Schema.decodeUnknownSync(schema)("valid input"));
// Output: valid input

console.log(Schema.decodeUnknownSync(schema)(null));
// Output: <fallback>
```

**Example** (Advanced Fallback with Logging)

In this advanced example, when a decoding error occurs, the schema logs the issue and then returns a fallback value.
This demonstrates how you can incorporate logging and other side effects during error handling.

```ts
import { Schema } from "effect";
import { Effect } from "effect";

// Schema with logging and fallback
const schemaWithLog = Schema.String.annotations({
  decodingFallback: (issue) =>
    Effect.gen(function* () {
      // Log the error issue
      yield* Effect.log(issue._tag);
      // Simulate a delay
      yield* Effect.sleep(10);
      // Return a fallback value
      return yield* Effect.succeed("<fallback>");
    }),
});

// Run the effectful fallback logic
Effect.runPromise(Schema.decodeUnknown(schemaWithLog)(null)).then(console.log);
/*
Output:
timestamp=2024-07-25T13:22:37.706Z level=INFO fiber=#0 message=Type
<fallback>
*/
```

### Custom Annotations

In addition to built-in annotations, you can define custom annotations to meet specific requirements. For instance, here's how to create a `deprecated` annotation:

**Example** (Defining a Custom Annotation)

```ts
import { Schema } from "effect";

// Define a unique identifier for your custom annotation
const DeprecatedId = Symbol.for(
  "some/unique/identifier/for/your/custom/annotation",
);

// Apply the custom annotation to the schema
const MyString = Schema.String.annotations({ [DeprecatedId]: true });

console.log(MyString);
/*
Output:
[class SchemaClass] {
  ast: StringKeyword {
    annotations: {
      [Symbol(@effect/docs/schema/annotation/Title)]: 'string',
      [Symbol(@effect/docs/schema/annotation/Description)]: 'a string',
      [Symbol(some/unique/identifier/for/your/custom/annotation)]: true
    },
    _tag: 'StringKeyword'
  },
  ...
}
*/
```

To make your new custom annotation type-safe, you can use a module augmentation. In the next example, we want our custom annotation to be a boolean.

**Example** (Adding Type Safety to Custom Annotations)

```ts
import { Schema } from "effect";

const DeprecatedId = Symbol.for(
  "some/unique/identifier/for/your/custom/annotation",
);

// Module augmentation
declare module "effect/Schema" {
  namespace Annotations {
    interface GenericSchema<A> extends Schema<A> {
      [DeprecatedId]?: boolean;
    }
  }
}

const MyString = Schema.String.annotations({
  // @errors: 2418
  [DeprecatedId]: "bad value",
});
```

You can retrieve custom annotations using the `SchemaAST.getAnnotation` helper function.

**Example** (Retrieving a Custom Annotation)

```ts
import { SchemaAST, Schema } from "effect";
import { Option } from "effect";

const DeprecatedId = Symbol.for(
  "some/unique/identifier/for/your/custom/annotation",
);

declare module "effect/Schema" {
  namespace Annotations {
    interface GenericSchema<A> extends Schema<A> {
      [DeprecatedId]?: boolean;
    }
  }
}

const MyString = Schema.String.annotations({ [DeprecatedId]: true });

// Helper function to check if a schema is marked as deprecated
const isDeprecated = <A, I, R>(schema: Schema.Schema<A, I, R>): boolean =>
  SchemaAST.getAnnotation<boolean>(DeprecatedId)(schema.ast).pipe(
    Option.getOrElse(() => false),
  );

console.log(isDeprecated(Schema.String));
// Output: false

console.log(isDeprecated(MyString));
// Output: true
```
