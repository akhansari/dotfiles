# Schema: Classes & Constructors

## Class APIs

### Overview

When working with schemas, you have a choice beyond the [Schema.Struct](/docs/schema/basic-usage/#structs) constructor.
You can leverage the power of classes through the `Schema.Class` utility, which comes with its own set of advantages tailored to common use cases:

Classes offer several features that simplify the schema creation process:

- **All-in-One Definition**: With classes, you can define both a schema and an opaque type simultaneously.
- **Shared Functionality**: You can incorporate shared functionality using class methods or getters.
- **Value Hashing and Equality**: Utilize the built-in capability for checking value equality and applying hashing (thanks to `Class` implementing [Data.Class](/docs/data-types/data/#class)).

> **Caution**: Class Schemas Are Transformations
>
> Classes defined with `Schema.Class` act as
> [transformations](/docs/schema/transformations/). See [Class Schemas are
> Transformations](#class-schemas-are-transformations) for details.

### Definition

To define a class using `Schema.Class`, you need to specify:

- The **type** of the class being created.
- A unique **identifier** for the class.
- The desired **fields**.

**Example** (Defining a Schema Class)

```ts
import { Schema } from "effect";

class Person extends Schema.Class<Person>("Person")({
  id: Schema.Number,
  name: Schema.NonEmptyString,
}) {}
```

In this example, `Person` is both a schema and a TypeScript class. Instances of `Person` are created using the defined schema, ensuring compliance with the specified fields.

**Example** (Creating Instances)

```ts
import { Schema } from "effect";

class Person extends Schema.Class<Person>("Person")({
  id: Schema.Number,
  name: Schema.NonEmptyString,
}) {}

console.log(new Person({ id: 1, name: "John" }));
/*
Output:
Person { id: 1, name: 'John' }
*/

// Using the factory function
console.log(Person.make({ id: 1, name: "John" }));
/*
Output:
Person { id: 1, name: 'John' }
*/
```

> **Note**: Why Use Identifiers?
>
> You need to specify an identifier to make the class global. This ensures that two classes with the same identifier refer to the same instance, avoiding reliance on `instanceof` checks.
>
> This behavior is similar to how we handle other class-based APIs like [Context.Tag](/docs/requirements-management/services/#creating-a-service).
>
> Using a unique identifier is particularly useful in scenarios where live reloads can occur, as it helps preserve the instance across reloads. It ensures there is no duplication of instances (although it shouldn't happen, some bundlers and frameworks can behave unpredictably).

### Class Schemas are Transformations

Class schemas [transform](/docs/schema/transformations/) a struct schema into a [declaration](/docs/schema/advanced-usage/#declaring-new-data-types) schema that represents a class type.

- When decoding, a plain object is converted into an instance of the class.
- When encoding, a class instance is converted back into a plain object.

**Example** (Decoding and Encoding a Class)

```ts
import { Schema } from "effect";

class Person extends Schema.Class<Person>("Person")({
  id: Schema.Number,
  name: Schema.NonEmptyString,
}) {}

const person = Person.make({ id: 1, name: "John" });

// Decode from a plain object into a class instance
const decoded = Schema.decodeUnknownSync(Person)({ id: 1, name: "John" });
console.log(decoded);
// Output: Person { id: 1, name: 'John' }

// Encode a class instance back into a plain object
const encoded = Schema.encodeUnknownSync(Person)(person);
console.log(encoded);
// Output: { id: 1, name: 'John' }
```

### Defining Classes Without Fields

When your schema does not require any fields, you can define a class with an empty object.

**Example** (Defining and Using a Class Without Arguments)

```ts
import { Schema } from "effect";

// Define a class with no fields
class NoArgs extends Schema.Class<NoArgs>("NoArgs")({}) {}

// Create an instance using the default constructor
const noargs1 = new NoArgs();

// Alternatively, create an instance by explicitly passing an empty object
const noargs2 = new NoArgs({});
```

### Defining Classes With Filters

Filters allow you to validate input when decoding, encoding, or creating an instance. Instead of specifying raw fields, you can pass a `Schema.Struct` with a filter applied.

**Example** (Applying a Filter to a Schema Class)

```ts
import { Schema } from "effect";

class WithFilter extends Schema.Class<WithFilter>("WithFilter")(
  Schema.Struct({
    a: Schema.NumberFromString,
    b: Schema.NumberFromString,
  }).pipe(Schema.filter(({ a, b }) => a >= b || "a must be greater than b")),
) {}

// Constructor
console.log(new WithFilter({ a: 1, b: 2 }));
/*
throws:
ParseError: WithFilter (Constructor)
└─ Predicate refinement failure
   └─ a must be greater than b
*/

// Decoding
console.log(Schema.decodeUnknownSync(WithFilter)({ a: "1", b: "2" }));
/*
throws:
ParseError: (WithFilter (Encoded side) <-> WithFilter)
└─ Encoded side transformation failure
   └─ WithFilter (Encoded side)
      └─ Predicate refinement failure
         └─ a must be greater than b
*/
```

### Validating Properties via Class Constructors

When you define a class using `Schema.Class`, the constructor automatically checks that the provided properties adhere to the schema's rules.

#### Defining and Instantiating a Valid Class Instance

The constructor ensures that each property, like `id` and `name`, adheres to the schema. For instance, `id` must be a number, and `name` must be a non-empty string.

**Example** (Creating a Valid Instance)

```ts
import { Schema } from "effect";

class Person extends Schema.Class<Person>("Person")({
  id: Schema.Number,
  name: Schema.NonEmptyString,
}) {}

// Create an instance with valid properties
const john = new Person({ id: 1, name: "John" });
```

#### Handling Invalid Properties

If invalid properties are provided during instantiation, the constructor throws an error, explaining why the validation failed.

**Example** (Creating an Instance with Invalid Properties)

```ts
import { Schema } from "effect";

class Person extends Schema.Class<Person>("Person")({
  id: Schema.Number,
  name: Schema.NonEmptyString,
}) {}

// Attempt to create an instance with an invalid `name`
new Person({ id: 1, name: "" });
/*
throws:
ParseError: Person (Constructor)
└─ ["name"]
   └─ NonEmptyString
      └─ Predicate refinement failure
         └─ Expected NonEmptyString, actual ""
*/
```

The error clearly specifies that the `name` field failed to meet the `NonEmptyString` requirement.

#### Bypassing Validation

In some scenarios, you might want to bypass the validation logic. While not generally recommended, the library provides an option to do so.

**Example** (Bypassing Validation)

```ts
import { Schema } from "effect";

class Person extends Schema.Class<Person>("Person")({
  id: Schema.Number,
  name: Schema.NonEmptyString,
}) {}

// Bypass validation during instantiation
const john = new Person({ id: 1, name: "" }, true);

// Or use the `disableValidation` option explicitly
new Person({ id: 1, name: "" }, { disableValidation: true });
```

### Automatic Hashing and Equality in Classes

Instances of classes created with `Schema.Class` support the [Equal](/docs/trait/equal/) trait through their integration with [Data.Class](/docs/data-types/data/#class). This enables straightforward value comparisons, even across different instances.

#### Basic Equality Check

Two class instances are considered equal if their properties have identical values.

**Example** (Comparing Instances with Equal Properties)

```ts
import { Schema } from "effect";
import { Equal } from "effect";

class Person extends Schema.Class<Person>("Person")({
  id: Schema.Number,
  name: Schema.NonEmptyString,
}) {}

const john1 = new Person({ id: 1, name: "John" });
const john2 = new Person({ id: 1, name: "John" });

// Compare instances
console.log(Equal.equals(john1, john2));
// Output: true
```

#### Nested or Complex Properties

The `Equal` trait performs comparisons at the first level. If a property is a more complex structure, such as an array, instances may not be considered equal, even if the arrays themselves have identical values.

**Example** (Shallow Equality for Arrays)

```ts
import { Schema } from "effect";
import { Equal } from "effect";

class Person extends Schema.Class<Person>("Person")({
  id: Schema.Number,
  name: Schema.NonEmptyString,
  hobbies: Schema.Array(Schema.String), // Standard array schema
}) {}

const john1 = new Person({
  id: 1,
  name: "John",
  hobbies: ["reading", "coding"],
});
const john2 = new Person({
  id: 1,
  name: "John",
  hobbies: ["reading", "coding"],
});

// Equality fails because `hobbies` are not deeply compared
console.log(Equal.equals(john1, john2));
// Output: false
```

To achieve deep equality for nested structures like arrays, use `Schema.Data` in combination with `Data.array`. This enables the library to compare each element of the array rather than treating it as a single entity.

**Example** (Using `Schema.Data` for Deep Equality)

```ts
import { Schema } from "effect";
import { Data, Equal } from "effect";

class Person extends Schema.Class<Person>("Person")({
  id: Schema.Number,
  name: Schema.NonEmptyString,
  hobbies: Schema.Data(Schema.Array(Schema.String)), // Enable deep equality
}) {}

const john1 = new Person({
  id: 1,
  name: "John",
  hobbies: Data.array(["reading", "coding"]),
});
const john2 = new Person({
  id: 1,
  name: "John",
  hobbies: Data.array(["reading", "coding"]),
});

// Equality succeeds because `hobbies` are deeply compared
console.log(Equal.equals(john1, john2));
// Output: true
```

### Extending Classes with Custom Logic

Schema classes provide the flexibility to include custom getters and methods, allowing you to extend their functionality beyond the defined fields.

#### Adding Custom Getters

A getter can be used to derive computed values from the fields of the class. For example, a `Person` class can include a getter to return the `name` property in uppercase.

**Example** (Adding a Getter for Uppercase Name)

```ts
import { Schema } from "effect";

class Person extends Schema.Class<Person>("Person")({
  id: Schema.Number,
  name: Schema.NonEmptyString,
}) {
  // Custom getter to return the name in uppercase
  get upperName() {
    return this.name.toUpperCase();
  }
}

const john = new Person({ id: 1, name: "John" });

// Use the custom getter
console.log(john.upperName);
// Output: "JOHN"
```

#### Adding Custom Methods

In addition to getters, you can define methods to encapsulate more complex logic or operations involving the class's fields.

**Example** (Adding a Method)

```ts
import { Schema } from "effect";

class Person extends Schema.Class<Person>("Person")({
  id: Schema.Number,
  name: Schema.NonEmptyString,
}) {
  // Custom method to return a greeting
  greet() {
    return `Hello, my name is ${this.name}.`;
  }
}

const john = new Person({ id: 1, name: "John" });

// Use the custom method
console.log(john.greet());
// Output: "Hello, my name is John."
```

### Leveraging Classes as Schema Definitions

When you define a class with `Schema.Class`, it serves both as a schema and as a class. This dual functionality allows the class to be used wherever a schema is required.

**Example** (Using a Class in an Array Schema)

```ts
import { Schema } from "effect";

class Person extends Schema.Class<Person>("Person")({
  id: Schema.Number,
  name: Schema.NonEmptyString,
}) {}

// Use the Person class in an array schema
const Persons = Schema.Array(Person);

//     ┌─── readonly Person[]
//     ▼
type Type = typeof Persons.Type;
```

#### Exposed Values

The class also includes a `fields` static property, which outlines the fields defined during the class creation.

**Example** (Accessing the `fields` Property)

```ts
import { Schema } from "effect";

class Person extends Schema.Class<Person>("Person")({
  id: Schema.Number,
  name: Schema.NonEmptyString,
}) {}

//       ┌─── {
//       |      readonly id: typeof Schema.Number;
//       |      readonly name: typeof Schema.NonEmptyString;
//       |    }
//       ▼
Person.fields;
```

### Adding Annotations

Defining a class with `Schema.Class` is similar to creating a [transformation](/docs/schema/transformations/) schema that converts a struct schema into a [declaration](/docs/schema/advanced-usage/#declaring-new-data-types) schema representing the class type.

For example, consider the following class definition:

```ts
import { Schema } from "effect";

class Person extends Schema.Class<Person>("Person")({
  id: Schema.Number,
  name: Schema.NonEmptyString,
}) {}
```

Under the hood, this definition creates a transformation schema that maps:

```ts
Schema.Struct({
  id: Schema.Number,
  name: Schema.NonEmptyString,
});
```

to a schema representing the `Person` class:

```ts
Schema.declare((input) => input instanceof Person);
```

So, defining a schema with `Schema.Class` involves three schemas:

- The "from" schema (the struct)
- The "to" schema (the class)
- The "transformation" schema (struct -> class)

You can annotate each of these schemas by passing a tuple as the second argument to the `Schema.Class` API.

**Example** (Annotating Different Parts of the Class Schema)

```ts
import { Schema, SchemaAST } from "effect";

class Person extends Schema.Class<Person>("Person")(
  {
    id: Schema.Number,
    name: Schema.NonEmptyString,
  },
  [
    // Annotations for the "to" schema
    { description: `"to" description` },

    // Annotations for the "transformation schema
    { description: `"transformation" description` },

    // Annotations for the "from" schema
    { description: `"from" description` },
  ],
) {}

console.log(SchemaAST.getDescriptionAnnotation(Person.ast.to));
// Output: { _id: 'Option', _tag: 'Some', value: '"to" description' }

console.log(SchemaAST.getDescriptionAnnotation(Person.ast));
// Output: { _id: 'Option', _tag: 'Some', value: '"transformation" description' }

console.log(SchemaAST.getDescriptionAnnotation(Person.ast.from));
// Output: { _id: 'Option', _tag: 'Some', value: '"from" description' }
```

If you do not want to annotate all three schemas, you can pass `undefined` for the ones you wish to skip.

**Example** (Skipping Annotations)

```ts
import { Schema, SchemaAST } from "effect";

class Person extends Schema.Class<Person>("Person")(
  {
    id: Schema.Number,
    name: Schema.NonEmptyString,
  },
  [
    // No annotations for the "to" schema
    undefined,

    // Annotations for the "transformation schema
    { description: `"transformation" description` },
  ],
) {}

console.log(SchemaAST.getDescriptionAnnotation(Person.ast.to));
// Output: { _id: 'Option', _tag: 'None' }

console.log(SchemaAST.getDescriptionAnnotation(Person.ast));
// Output: { _id: 'Option', _tag: 'Some', value: '"transformation" description' }

console.log(SchemaAST.getDescriptionAnnotation(Person.ast.from));
// Output: { _id: 'Option', _tag: 'None' }
```

By default, the unique identifier used to define the class is also applied as the default `identifier` annotation for the Class Schema.

**Example** (Default Identifier Annotation)

```ts
import { Schema, SchemaAST } from "effect";

// Used as default identifier annotation ────┐
//                                           |
//                                           ▼
class Person extends Schema.Class<Person>("Person")({
  id: Schema.Number,
  name: Schema.NonEmptyString,
}) {}

console.log(SchemaAST.getIdentifierAnnotation(Person.ast.to));
// Output: { _id: 'Option', _tag: 'Some', value: 'Person' }
```

### Recursive Schemas

The `Schema.suspend` combinator is useful when you need to define a schema that depends on itself, like in the case of recursive data structures.
In this example, the `Category` schema depends on itself because it has a field `subcategories` that is an array of `Category` objects.

**Example** (Self-Referencing Schema)

```ts
import { Schema } from "effect";

// Define a Category schema with a recursive subcategories field
class Category extends Schema.Class<Category>("Category")({
  name: Schema.String,
  subcategories: Schema.Array(
    Schema.suspend((): Schema.Schema<Category> => Category),
  ),
}) {}
```

> **Note**: Correct Inference
>
> It is necessary to add an explicit type annotation because otherwise
> TypeScript would struggle to infer types correctly. Without this
> annotation, you might encounter this error message:

**Example** (Missing Type Annotation Error)

```ts
import { Schema } from "effect";

// @errors: 2506 7024
class Category extends Schema.Class<Category>("Category")({
  name: Schema.String,
  subcategories: Schema.Array(Schema.suspend(() => Category)),
}) {}
```

#### Mutually Recursive Schemas

Sometimes, schemas depend on each other in a mutually recursive way. For instance, an arithmetic expression tree might include `Expression` nodes that can either be numbers or `Operation` nodes, which in turn reference `Expression` nodes.

**Example** (Arithmetic Expression Tree)

```ts
import { Schema } from "effect";

class Expression extends Schema.Class<Expression>("Expression")({
  type: Schema.Literal("expression"),
  value: Schema.Union(
    Schema.Number,
    Schema.suspend((): Schema.Schema<Operation> => Operation),
  ),
}) {}

class Operation extends Schema.Class<Operation>("Operation")({
  type: Schema.Literal("operation"),
  operator: Schema.Literal("+", "-"),
  left: Expression,
  right: Expression,
}) {}
```

#### Recursive Types with Different Encoded and Type

Defining recursive schemas where the `Encoded` type differs from the `Type` type introduces additional complexity. For instance, if a schema includes fields that transform data (e.g., `NumberFromString`), the `Encoded` and `Type` types may not align.

In such cases, we need to define an interface for the `Encoded` type.

Let's consider an example: suppose we want to add an `id` field to the `Category` schema, where the schema for `id` is `NumberFromString`.
It's important to note that `NumberFromString` is a schema that transforms a string into a number, so the `Type` and `Encoded` types of `NumberFromString` differ, being `number` and `string` respectively.
When we add this field to the `Category` schema, TypeScript raises an error:

```ts
import { Schema } from "effect";

class Category extends Schema.Class<Category>("Category")({
  id: Schema.NumberFromString,
  name: Schema.String,
  subcategories: Schema.Array(
    // @errors: 2322
    Schema.suspend((): Schema.Schema<Category> => Category),
  ),
}) {}
```

This error occurs because the explicit annotation `S.suspend((): S.Schema<Category> => Category` is no longer sufficient and needs to be adjusted by explicitly adding the `Encoded` type:

**Example** (Adjusting the Schema with Explicit `Encoded` Type)

```ts
import { Schema } from "effect";

interface CategoryEncoded {
  readonly id: string;
  readonly name: string;
  readonly subcategories: ReadonlyArray<CategoryEncoded>;
}

class Category extends Schema.Class<Category>("Category")({
  id: Schema.NumberFromString,
  name: Schema.String,
  subcategories: Schema.Array(
    Schema.suspend((): Schema.Schema<Category, CategoryEncoded> => Category),
  ),
}) {}
```

As we've observed, it's necessary to define an interface for the `Encoded` of the schema to enable recursive schema definition, which can complicate things and be quite tedious.
One pattern to mitigate this is to **separate the field responsible for recursion** from all other fields.

**Example** (Separating Recursive Field)

```ts
import { Schema } from "effect";

const fields = {
  id: Schema.NumberFromString,
  name: Schema.String,
  // ...possibly other fields
};

interface CategoryEncoded extends Schema.Struct.Encoded<typeof fields> {
  // Define `subcategories` using recursion
  readonly subcategories: ReadonlyArray<CategoryEncoded>;
}

class Category extends Schema.Class<Category>("Category")({
  ...fields, // Include the fields
  subcategories: Schema.Array(
    // Define `subcategories` using recursion
    Schema.suspend((): Schema.Schema<Category, CategoryEncoded> => Category),
  ),
}) {}
```

### Tagged Class variants

You can also create classes that extend [TaggedClass](/docs/data-types/data/#taggedclass) and [TaggedError](/docs/data-types/data/#taggederror) from the `effect/Data` module.

**Example** (Creating Tagged Classes and Errors)

```ts
import { Schema } from "effect";

// Define a tagged class with a "name" field
class TaggedPerson extends Schema.TaggedClass<TaggedPerson>()("TaggedPerson", {
  name: Schema.String,
}) {}

// Define a tagged error with a "status" field
class HttpError extends Schema.TaggedError<HttpError>()("HttpError", {
  status: Schema.Number,
}) {}

const joe = new TaggedPerson({ name: "Joe" });
console.log(joe._tag);
// Output: "TaggedPerson"

const error = new HttpError({ status: 404 });
console.log(error._tag);
// Output: "HttpError"

console.log(error.stack); // access the stack trace
```

### Extending existing Classes

The `extend` static utility allows you to enhance an existing schema class by adding **additional** fields and functionality. This approach helps in building on top of existing schemas without redefining them from scratch.

**Example** (Extending a Schema Class)

```ts
import { Schema } from "effect";

// Define the base class
class Person extends Schema.Class<Person>("Person")({
  id: Schema.Number,
  name: Schema.NonEmptyString,
}) {
  // A custom getter that converts the name to uppercase
  get upperName() {
    return this.name.toUpperCase();
  }
}

// Extend the base class to include an "age" field
class PersonWithAge extends Person.extend<PersonWithAge>("PersonWithAge")({
  age: Schema.Number,
}) {
  // A custom getter to check if the person is an adult
  get isAdult() {
    return this.age >= 18;
  }
}

// Usage
const john = new PersonWithAge({ id: 1, name: "John", age: 25 });
console.log(john.upperName); // Output: "JOHN"
console.log(john.isAdult); // Output: true
```

Note that you can only add additional fields when extending a class.

**Example** (Attempting to Overwrite Existing Fields)

```ts
import { Schema } from "effect";

class Person extends Schema.Class<Person>("Person")({
  id: Schema.Number,
  name: Schema.NonEmptyString,
}) {
  get upperName() {
    return this.name.toUpperCase();
  }
}

class BadExtension extends Person.extend<BadExtension>("BadExtension")({
  name: Schema.Number,
}) {}
/*
throws:
Error: Duplicate property signature
details: Duplicate key "name"
*/
```

This error occurs because allowing fields to be overwritten is not safe. It could interfere with any getters or methods defined on the class that rely on the original definition. For example, in this case, the `upperName` getter would break if the `name` field was changed to a number.

### Transformations

You can enhance schema classes with effectful transformations to enrich or validate entities, particularly when working with data sourced from external systems like databases or APIs.

**Example** (Effectful Transformation)

The following example demonstrates adding an `age` field to a `Person` class. The `age` value is derived asynchronously based on the `id` field.

```ts
import { Effect, Option, Schema, ParseResult } from "effect";

// Base class definition
class Person extends Schema.Class<Person>("Person")({
  id: Schema.Number,
  name: Schema.String,
}) {}

console.log(Schema.decodeUnknownSync(Person)({ id: 1, name: "name" }));
/*
Output:
Person { id: 1, name: 'name' }
*/

// Simulate fetching age asynchronously based on id
function getAge(id: number): Effect.Effect<number, Error> {
  return Effect.succeed(id + 2);
}

// Extended class with a transformation
class PersonWithTransform extends Person.transformOrFail<PersonWithTransform>(
  "PersonWithTransform",
)(
  {
    age: Schema.optionalWith(Schema.Number, { exact: true, as: "Option" }),
  },
  {
    // Decoding logic for the new field
    decode: (input) =>
      Effect.mapBoth(getAge(input.id), {
        onFailure: (e) =>
          new ParseResult.Type(Schema.String.ast, input.id, e.message),
        // Must return { age: Option<number> }
        onSuccess: (age) => ({ ...input, age: Option.some(age) }),
      }),
    encode: ParseResult.succeed,
  },
) {}

Schema.decodeUnknownPromise(PersonWithTransform)({
  id: 1,
  name: "name",
}).then(console.log);
/*
Output:
PersonWithTransform {
  id: 1,
  name: 'name',
  age: { _id: 'Option', _tag: 'Some', value: 3 }
}
*/

// Extended class with a conditional Transformation
class PersonWithTransformFrom extends Person.transformOrFailFrom<PersonWithTransformFrom>(
  "PersonWithTransformFrom",
)(
  {
    age: Schema.optionalWith(Schema.Number, { exact: true, as: "Option" }),
  },
  {
    decode: (input) =>
      Effect.mapBoth(getAge(input.id), {
        onFailure: (e) =>
          new ParseResult.Type(Schema.String.ast, input, e.message),
        // Must return { age?: number }
        onSuccess: (age) => (age > 18 ? { ...input, age } : { ...input }),
      }),
    encode: ParseResult.succeed,
  },
) {}

Schema.decodeUnknownPromise(PersonWithTransformFrom)({
  id: 1,
  name: "name",
}).then(console.log);
/*
Output:
PersonWithTransformFrom {
  id: 1,
  name: 'name',
  age: { _id: 'Option', _tag: 'None' }
}
*/
```

The decision of which API to use, either `transformOrFail` or `transformOrFailFrom`, depends on when you wish to execute the transformation:

1. Using `transformOrFail`:
   - The transformation occurs at the end of the process.
   - It expects you to provide a value of type `{ age: Option<number> }`.
   - After processing the initial input, the new transformation comes into play, and you need to ensure the final output adheres to the specified structure.

2. Using `transformOrFailFrom`:
   - The new transformation starts as soon as the initial input is handled.
   - You should provide a value `{ age?: number }`.
   - Based on this fresh input, the subsequent transformation `Schema.optionalWith(Schema.Number, { exact: true, as: "Option" })` is executed.
   - This approach allows for immediate handling of the input, potentially influencing the subsequent transformations.

## Default Constructors

### Overview

When working with data structures, it can be helpful to create values that conform to a schema with minimal effort.
For this purpose, the Schema module provides default constructors for various schema types, including `Structs`, `Records`, `filters`, and `brands`.

> **Note**: Constructor Scope
>
> Default constructors associated with a schema of type `Schema<A, I, R>` operate specifically on the **decoded type** (`A`), not the encoded type (`I`).
>
> - **`A` (Decoded Type)**: This is the type produced after decoding and validation. The constructor creates values of this type.
> - `I` (Encoded Type): This is the type expected when decoding raw input. The constructor does not accept this type directly.
>
> This distinction is important when working with schemas that transform data. For example, if a schema **decodes a string into a number**, the default constructor will only accept **numbers**, not strings.

Default constructors are **unsafe**, meaning they **throw an error** if the input does not conform to the schema.
If you need a safer alternative, consider using [Schema.validateEither](#error-handling-in-constructors), which returns a result indicating success or failure instead of throwing an error.

**Example** (Using a Refinement Default Constructor)

```ts
import { Schema } from "effect";

const schema = Schema.NumberFromString.pipe(Schema.between(1, 10));

// The constructor only accepts numbers
console.log(schema.make(5));
// Output: 5

// This will throw an error because the number is outside the valid range
console.log(schema.make(20));
/*
throws:
ParseError: between(1, 10)
└─ Predicate refinement failure
   └─ Expected a number between 1 and 10, actual 20
*/
```

### Structs

Struct schemas allow you to define objects with specific fields and constraints. The `make` function can be used to create instances of a struct schema.

**Example** (Creating Struct Instances)

```ts
import { Schema } from "effect";

const Struct = Schema.Struct({
  name: Schema.NonEmptyString,
});

// Successful creation
Struct.make({ name: "a" });

// This will throw an error because the name is empty
Struct.make({ name: "" });
/*
throws
ParseError: { readonly name: NonEmptyString }
└─ ["name"]
   └─ NonEmptyString
      └─ Predicate refinement failure
         └─ Expected NonEmptyString, actual ""
*/
```

In some cases, you might need to bypass validation. While not recommended in most scenarios, `make` provides an option to disable validation.

**Example** (Bypassing Validation)

```ts
import { Schema } from "effect";

const Struct = Schema.Struct({
  name: Schema.NonEmptyString,
});

// Bypass validation during instantiation
Struct.make({ name: "" }, true);

// Or use the `disableValidation` option explicitly
Struct.make({ name: "" }, { disableValidation: true });
```

### Records

Record schemas allow you to define key-value mappings where the keys and values must meet specific criteria.

**Example** (Creating Record Instances)

```ts
import { Schema } from "effect";

const Record = Schema.Record({
  key: Schema.String,
  value: Schema.NonEmptyString,
});

// Successful creation
Record.make({ a: "a", b: "b" });

// This will throw an error because 'b' is empty
Record.make({ a: "a", b: "" });
/*
throws
ParseError: { readonly [x: string]: NonEmptyString }
└─ ["b"]
   └─ NonEmptyString
      └─ Predicate refinement failure
         └─ Expected NonEmptyString, actual ""
*/

// Bypasses validation
Record.make({ a: "a", b: "" }, { disableValidation: true });
```

### Filters

Filters allow you to define constraints on individual values.

**Example** (Using Filters to Enforce Ranges)

```ts
import { Schema } from "effect";

const MyNumber = Schema.Number.pipe(Schema.between(1, 10));

// Successful creation
const n = MyNumber.make(5);

// This will throw an error because the number is outside the valid range
MyNumber.make(20);
/*
throws
ParseError: a number between 1 and 10
└─ Predicate refinement failure
   └─ Expected a number between 1 and 10, actual 20
*/

// Bypasses validation
MyNumber.make(20, { disableValidation: true });
```

### Branded Types

Branded schemas add metadata to a value to give it a more specific type, while still retaining its original type.

**Example** (Creating Branded Values)

```ts
import { Schema } from "effect";

const BrandedNumberSchema = Schema.Number.pipe(
  Schema.between(1, 10),
  Schema.brand("MyNumber"),
);

// Successful creation
const n = BrandedNumberSchema.make(5);

// This will throw an error because the number is outside the valid range
BrandedNumberSchema.make(20);
/*
throws
ParseError: a number between 1 and 10 & Brand<"MyNumber">
└─ Predicate refinement failure
   └─ Expected a number between 1 and 10 & Brand<"MyNumber">, actual 20
*/

// Bypasses validation
BrandedNumberSchema.make(20, { disableValidation: true });
```

When using default constructors, it is helpful to understand the type of value they produce.

For instance, in the `BrandedNumberSchema` example, the return type of the constructor is `number & Brand<"MyNumber">`. This indicates that the resulting value is a `number` with additional branding information, `"MyNumber"`.

This behavior contrasts with the filter example, where the return type is simply `number`. Branding adds an extra layer of type information, which can assist in identifying and working with your data more effectively.

### Error Handling in Constructors

Default constructors are considered "unsafe" because they throw an error if the input does not conform to the schema. This error includes a detailed description of what went wrong. The intention behind default constructors is to provide a straightforward way to create valid values, such as for tests or configurations, where invalid inputs are expected to be exceptional cases.

If you need a "safe" constructor that does not throw errors but instead returns a result indicating success or failure, you can use `Schema.validateEither`.

**Example** (Using `Schema.validateEither` for Safe Validation)

```ts
import { Schema } from "effect";

const schema = Schema.NumberFromString.pipe(Schema.between(1, 10));

// Create a safe constructor that validates an unknown input
const safeMake = Schema.validateEither(schema);

// Valid input returns a Right value
console.log(safeMake(5));
/*
Output:
{ _id: 'Either', _tag: 'Right', right: 5 }
*/

// Invalid input returns a Left value with detailed error information
console.log(safeMake(20));
/*
Output:
{
  _id: 'Either',
  _tag: 'Left',
  left: {
    _id: 'ParseError',
    message: 'between(1, 10)\n' +
      '└─ Predicate refinement failure\n' +
      '   └─ Expected a number between 1 and 10, actual 20'
  }
}
*/

// This will throw an error because it's unsafe
schema.make(20);
/*
throws:
ParseError: between(1, 10)
└─ Predicate refinement failure
   └─ Expected a number between 1 and 10, actual 20
*/
```

### Setting Default Values

When creating objects, you might want to assign default values to certain fields to simplify object construction. The `Schema.withConstructorDefault` function lets you handle default values, making fields optional in the default constructor.

**Example** (Struct with Required Fields)

In this example, all fields are required when creating a new instance.

```ts
import { Schema } from "effect";

const Person = Schema.Struct({
  name: Schema.NonEmptyString,
  age: Schema.Number,
});

// Both name and age must be provided
console.log(Person.make({ name: "John", age: 30 }));
/*
Output: { name: 'John', age: 30 }
*/
```

**Example** (Struct with Default Value)

Here, the `age` field is optional because it has a default value of `0`.

```ts
import { Schema } from "effect";

const Person = Schema.Struct({
  name: Schema.NonEmptyString,
  age: Schema.Number.pipe(
    Schema.propertySignature,
    Schema.withConstructorDefault(() => 0),
  ),
});

// The age field is optional and defaults to 0
console.log(Person.make({ name: "John" }));
/*
Output:
{ name: 'John', age: 0 }
*/

console.log(Person.make({ name: "John", age: 30 }));
/*
Output:
{ name: 'John', age: 30 }
*/
```

#### Nested Structs and Shallow Defaults

Default values in schemas are shallow, meaning that defaults defined in nested structs do not automatically propagate to the top-level constructor.

**Example** (Shallow Defaults in Nested Structs)

```ts
import { Schema } from "effect";

const Config = Schema.Struct({
  // Define a nested struct with a default value
  web: Schema.Struct({
    application_url: Schema.String.pipe(
      Schema.propertySignature,
      Schema.withConstructorDefault(() => "http://localhost"),
    ),
    application_port: Schema.Number,
  }),
});

// This will cause a type error because `application_url`
// is missing in the nested struct
// @errors: 2741
Config.make({ web: { application_port: 3000 } });
```

This behavior occurs because the `Schema` interface does not include a type parameter to carry over default constructor types from nested structs.

To work around this limitation, extract the constructor for the nested struct and apply it to its fields directly. This ensures that the nested defaults are respected.

**Example** (Using Nested Struct Constructors)

```ts
import { Schema } from "effect";

const Config = Schema.Struct({
  web: Schema.Struct({
    application_url: Schema.String.pipe(
      Schema.propertySignature,
      Schema.withConstructorDefault(() => "http://localhost"),
    ),
    application_port: Schema.Number,
  }),
});

// Extract the nested struct constructor
const { web: Web } = Config.fields;

// Use the constructor for the nested struct
console.log(Config.make({ web: Web.make({ application_port: 3000 }) }));
/*
Output:
{
  web: {
    application_url: 'http://localhost',
    application_port: 3000
  }
}
*/
```

#### Lazy Evaluation of Defaults

Defaults are lazily evaluated, meaning that a new instance of the default is generated every time the constructor is called:

**Example** (Lazy Evaluation of Defaults)

In this example, the `timestamp` field generates a new value for each instance.

```ts
import { Schema } from "effect";

const Person = Schema.Struct({
  name: Schema.NonEmptyString,
  age: Schema.Number.pipe(
    Schema.propertySignature,
    Schema.withConstructorDefault(() => 0),
  ),
  timestamp: Schema.Number.pipe(
    Schema.propertySignature,
    Schema.withConstructorDefault(() => new Date().getTime()),
  ),
});

console.log(Person.make({ name: "name1" }));
/*
Example Output:
{ age: 0, timestamp: 1714232909221, name: 'name1' }
*/

console.log(Person.make({ name: "name2" }));
/*
Example Output:
{ age: 0, timestamp: 1714232909227, name: 'name2' }
*/
```

#### Reusing Defaults Across Schemas

Default values are also "portable", meaning that if you reuse the same property signature in another schema, the default is carried over:

**Example** (Reusing Defaults in Another Schema)

```ts
import { Schema } from "effect";

const Person = Schema.Struct({
  name: Schema.NonEmptyString,
  age: Schema.Number.pipe(
    Schema.propertySignature,
    Schema.withConstructorDefault(() => 0),
  ),
  timestamp: Schema.Number.pipe(
    Schema.propertySignature,
    Schema.withConstructorDefault(() => new Date().getTime()),
  ),
});

const AnotherSchema = Schema.Struct({
  foo: Schema.String,
  age: Person.fields.age,
});

console.log(AnotherSchema.make({ foo: "bar" }));
/*
Output:
{ foo: 'bar', age: 0 }
*/
```

#### Using Defaults in Classes

Default values can also be applied when working with the `Class` API, ensuring consistency across class-based schemas.

**Example** (Defaults in a Class)

```ts
import { Schema } from "effect";

class Person extends Schema.Class<Person>("Person")({
  name: Schema.NonEmptyString,
  age: Schema.Number.pipe(
    Schema.propertySignature,
    Schema.withConstructorDefault(() => 0),
  ),
  timestamp: Schema.Number.pipe(
    Schema.propertySignature,
    Schema.withConstructorDefault(() => new Date().getTime()),
  ),
}) {}

console.log(new Person({ name: "name1" }));
/*
Example Output:
Person { age: 0, timestamp: 1714400867208, name: 'name1' }
*/

console.log(new Person({ name: "name2" }));
/*
Example Output:
Person { age: 0, timestamp: 1714400867215, name: 'name2' }
*/
```

## Effect Data Types

### Overview

### Interop With Data

The [Data](/docs/data-types/data/) module in the Effect ecosystem simplifies value comparison by automatically implementing the [Equal](/docs/trait/equal/) and [Hash](/docs/trait/hash/) traits. This eliminates the need for manual implementations, making equality checks straightforward.

**Example** (Comparing Structs with Data)

```ts
import { Data, Equal } from "effect";

const person1 = Data.struct({ name: "Alice", age: 30 });
const person2 = Data.struct({ name: "Alice", age: 30 });

console.log(Equal.equals(person1, person2));
// Output: true
```

By default, schemas like `Schema.Struct` do not implement the `Equal` and `Hash` traits. This means that two decoded objects with identical values will not be considered equal.

**Example** (Default Behavior Without `Equal` and `Hash`)

```ts
import { Schema } from "effect";
import { Equal } from "effect";

const schema = Schema.Struct({
  name: Schema.String,
  age: Schema.Number,
});

const decode = Schema.decode(schema);

const person1 = decode({ name: "Alice", age: 30 });
const person2 = decode({ name: "Alice", age: 30 });

console.log(Equal.equals(person1, person2));
// Output: false
```

The `Schema.Data` function can be used to enhance a schema by including the `Equal` and `Hash` traits. This allows the resulting objects to support value-based equality.

**Example** (Using `Schema.Data` to Add Equality)

```ts
import { Schema } from "effect";
import { Equal } from "effect";

const schema = Schema.Data(
  Schema.Struct({
    name: Schema.String,
    age: Schema.Number,
  }),
);

const decode = Schema.decode(schema);

const person1 = decode({ name: "Alice", age: 30 });
const person2 = decode({ name: "Alice", age: 30 });

console.log(Equal.equals(person1, person2));
// Output: true
```

### Config

The `Schema.Config` function allows you to decode and manage application configuration settings using structured schemas.
It ensures consistency in configuration data and provides detailed feedback for decoding errors.

**Syntax**

```ts
Config: <A, I extends string>(name: string, schema: Schema<A, I>) => Config<A>;
```

This function takes two arguments:

- `name`: Identifier for the configuration setting.
- `schema`: Schema describing the expected data type and structure.

It returns a [Config](/docs/configuration/) object that integrates with your application's configuration system.

The Encoded type `I` must extend `string`, so the schema must be able to decode from a string, this includes schemas like `Schema.String`, `Schema.Literal("...")`, or `Schema.NumberFromString`, possibly with refinements applied.

Behind the scenes, `Schema.Config` follows these steps:

1. **Fetch the value** using the provided name (e.g. from an environment variable).
2. **Decode the value** using the given schema. If the value is invalid, decoding fails.
3. **Format any errors** using [TreeFormatter.formatErrorSync](/docs/schema/error-formatters/#treeformatter-default), which helps produce readable and detailed error messages.

**Example** (Decoding a Configuration Value)

```ts
import { Effect, Schema } from "effect";

// Define a config that expects a string with at least 4 characters
const myConfig = Schema.Config("Foo", Schema.String.pipe(Schema.minLength(4)));

const program = Effect.gen(function* () {
  const foo = yield* myConfig;
  console.log(`ok: ${foo}`);
});

Effect.runSync(program);
```

To test the configuration, execute the following commands:

**Test** (with Missing Configuration Data)

```sh
npx tsx config.ts
# Output:
# [(Missing data at Foo: "Expected Foo to exist in the process context")]
```

**Test** (with Invalid Data)

```sh
Foo=bar npx tsx config.ts
# Output:
# [(Invalid data at Foo: "a string at least 4 character(s) long
# └─ Predicate refinement failure
#    └─ Expected a string at least 4 character(s) long, actual "bar"")]
```

**Test** (with Valid Data)

```sh
Foo=foobar npx tsx config.ts
# Output:
# ok: foobar
```

### Option

#### Option

The `Schema.Option` function is useful for converting an `Option` into a JSON-serializable format.

**Syntax**

```ts
Schema.Option(schema: Schema<A, I, R>)
```

##### Decoding

| Input                        | Output                                                                              |
| ---------------------------- | ----------------------------------------------------------------------------------- |
| `{ _tag: "None" }`           | Converted to `Option.none()`                                                        |
| `{ _tag: "Some", value: I }` | Converted to `Option.some(a)`, where `I` is decoded into `A` using the inner schema |

##### Encoding

| Input            | Output                                                                                          |
| ---------------- | ----------------------------------------------------------------------------------------------- |
| `Option.none()`  | Converted to `{ _tag: "None" }`                                                                 |
| `Option.some(A)` | Converted to `{ _tag: "Some", value: I }`, where `A` is encoded into `I` using the inner schema |

**Example**

```ts
import { Schema } from "effect";
import { Option } from "effect";

const schema = Schema.Option(Schema.NumberFromString);

//     ┌─── OptionEncoded<string>
//     ▼
type Encoded = typeof schema.Encoded;

//     ┌─── Option<number>
//     ▼
type Type = typeof schema.Type;

const decode = Schema.decodeUnknownSync(schema);
const encode = Schema.encodeSync(schema);

// Decoding examples

console.log(decode({ _tag: "None" }));
// Output: { _id: 'Option', _tag: 'None' }

console.log(decode({ _tag: "Some", value: "1" }));
// Output: { _id: 'Option', _tag: 'Some', value: 1 }

// Encoding examples

console.log(encode(Option.none()));
// Output: { _tag: 'None' }

console.log(encode(Option.some(1)));
// Output: { _tag: 'Some', value: '1' }
```

#### OptionFromSelf

The `Schema.OptionFromSelf` function is designed for scenarios where `Option` values are already in the `Option` format and need to be decoded or encoded while transforming the inner value according to the provided schema.

**Syntax**

```ts
Schema.OptionFromSelf(schema: Schema<A, I, R>)
```

##### Decoding

| Input            | Output                                                                              |
| ---------------- | ----------------------------------------------------------------------------------- |
| `Option.none()`  | Remains as `Option.none()`                                                          |
| `Option.some(I)` | Converted to `Option.some(A)`, where `I` is decoded into `A` using the inner schema |

##### Encoding

| Input            | Output                                                                              |
| ---------------- | ----------------------------------------------------------------------------------- |
| `Option.none()`  | Remains as `Option.none()`                                                          |
| `Option.some(A)` | Converted to `Option.some(I)`, where `A` is encoded into `I` using the inner schema |

**Example**

```ts
import { Schema } from "effect";
import { Option } from "effect";

const schema = Schema.OptionFromSelf(Schema.NumberFromString);

//     ┌─── Option<string>
//     ▼
type Encoded = typeof schema.Encoded;

//     ┌─── Option<number>
//     ▼
type Type = typeof schema.Type;

const decode = Schema.decodeUnknownSync(schema);
const encode = Schema.encodeSync(schema);

// Decoding examples

console.log(decode(Option.none()));
// Output: { _id: 'Option', _tag: 'None' }

console.log(decode(Option.some("1")));
// Output: { _id: 'Option', _tag: 'Some', value: 1 }

// Encoding examples

console.log(encode(Option.none()));
// Output: { _id: 'Option', _tag: 'None' }

console.log(encode(Option.some(1)));
// Output: { _id: 'Option', _tag: 'Some', value: '1' }
```

#### OptionFromUndefinedOr

The `Schema.OptionFromUndefinedOr` function handles cases where `undefined` is treated as `Option.none()`, and all other values are interpreted as `Option.some()` based on the provided schema.

**Syntax**

```ts
Schema.OptionFromUndefinedOr(schema: Schema<A, I, R>)
```

##### Decoding

| Input       | Output                                                                              |
| ----------- | ----------------------------------------------------------------------------------- |
| `undefined` | Converted to `Option.none()`                                                        |
| `I`         | Converted to `Option.some(A)`, where `I` is decoded into `A` using the inner schema |

##### Encoding

| Input            | Output                                                                 |
| ---------------- | ---------------------------------------------------------------------- |
| `Option.none()`  | Converted to `undefined`                                               |
| `Option.some(A)` | Converted to `I`, where `A` is encoded into `I` using the inner schema |

**Example**

```ts
import { Schema } from "effect";
import { Option } from "effect";

const schema = Schema.OptionFromUndefinedOr(Schema.NumberFromString);

//     ┌─── string | undefined
//     ▼
type Encoded = typeof schema.Encoded;

//     ┌─── Option<number>
//     ▼
type Type = typeof schema.Type;

const decode = Schema.decodeUnknownSync(schema);
const encode = Schema.encodeSync(schema);

// Decoding examples

console.log(decode(undefined));
// Output: { _id: 'Option', _tag: 'None' }

console.log(decode("1"));
// Output: { _id: 'Option', _tag: 'Some', value: 1 }

// Encoding examples

console.log(encode(Option.none()));
// Output: undefined

console.log(encode(Option.some(1)));
// Output: "1"
```

#### OptionFromNullOr

The `Schema.OptionFromUndefinedOr` function handles cases where `null` is treated as `Option.none()`, and all other values are interpreted as `Option.some()` based on the provided schema.

**Syntax**

```ts
Schema.OptionFromNullOr(schema: Schema<A, I, R>)
```

##### Decoding

| Input  | Output                                                                              |
| ------ | ----------------------------------------------------------------------------------- |
| `null` | Converted to `Option.none()`                                                        |
| `I`    | Converted to `Option.some(A)`, where `I` is decoded into `A` using the inner schema |

##### Encoding

| Input            | Output                                                                 |
| ---------------- | ---------------------------------------------------------------------- |
| `Option.none()`  | Converted to `null`                                                    |
| `Option.some(A)` | Converted to `I`, where `A` is encoded into `I` using the inner schema |

**Example**

```ts
import { Schema } from "effect";
import { Option } from "effect";

const schema = Schema.OptionFromNullOr(Schema.NumberFromString);

//     ┌─── string | null
//     ▼
type Encoded = typeof schema.Encoded;

//     ┌─── Option<number>
//     ▼
type Type = typeof schema.Type;

const decode = Schema.decodeUnknownSync(schema);
const encode = Schema.encodeSync(schema);

// Decoding examples

console.log(decode(null));
// Output: { _id: 'Option', _tag: 'None' }

console.log(decode("1"));
// Output: { _id: 'Option', _tag: 'Some', value: 1 }

// Encoding examples

console.log(encode(Option.none()));
// Output: null
console.log(encode(Option.some(1)));
// Output: "1"
```

#### OptionFromNullishOr

The `Schema.OptionFromNullishOr` function handles cases where `null` or `undefined` are treated as `Option.none()`, and all other values are interpreted as `Option.some()` based on the provided schema. Additionally, it allows customization of how `Option.none()` is encoded (`null` or `undefined`).

**Syntax**

```ts
Schema.OptionFromNullishOr(
  schema: Schema<A, I, R>,
  onNoneEncoding: null | undefined
)
```

##### Decoding

| Input       | Output                                                                              |
| ----------- | ----------------------------------------------------------------------------------- |
| `undefined` | Converted to `Option.none()`                                                        |
| `null`      | Converted to `Option.none()`                                                        |
| `I`         | Converted to `Option.some(A)`, where `I` is decoded into `A` using the inner schema |

##### Encoding

| Input            | Output                                                                     |
| ---------------- | -------------------------------------------------------------------------- |
| `Option.none()`  | Converted to `undefined` or `null` based on user choice (`onNoneEncoding`) |
| `Option.some(A)` | Converted to `I`, where `A` is encoded into `I` using the inner schema     |

**Example**

```ts
import { Schema } from "effect";
import { Option } from "effect";

const schema = Schema.OptionFromNullishOr(
  Schema.NumberFromString,
  undefined, // Encode Option.none() as undefined
);

//     ┌─── string | null | undefined
//     ▼
type Encoded = typeof schema.Encoded;

//     ┌─── Option<number>
//     ▼
type Type = typeof schema.Type;

const decode = Schema.decodeUnknownSync(schema);
const encode = Schema.encodeSync(schema);

// Decoding examples

console.log(decode(null));
// Output: { _id: 'Option', _tag: 'None' }

console.log(decode(undefined));
// Output: { _id: 'Option', _tag: 'None' }

console.log(decode("1"));
// Output: { _id: 'Option', _tag: 'Some', value: 1 }

// Encoding examples

console.log(encode(Option.none()));
// Output: undefined

console.log(encode(Option.some(1)));
// Output: "1"
```

#### OptionFromNonEmptyTrimmedString

The `Schema.OptionFromNonEmptyTrimmedString` schema is designed for handling strings where trimmed empty strings are treated as `Option.none()`, and all other strings are converted to `Option.some()`.

##### Decoding

| Input       | Output                                                  |
| ----------- | ------------------------------------------------------- |
| `s: string` | Converted to `Option.some(s)`, if `s.trim().length > 0` |
|             | Converted to `Option.none()` otherwise                  |

##### Encoding

| Input                    | Output            |
| ------------------------ | ----------------- |
| `Option.none()`          | Converted to `""` |
| `Option.some(s: string)` | Converted to `s`  |

**Example**

```ts
import { Schema, Option } from "effect";

//     ┌─── string
//     ▼
type Encoded = typeof Schema.OptionFromNonEmptyTrimmedString;

//     ┌─── Option<string>
//     ▼
type Type = typeof Schema.OptionFromNonEmptyTrimmedString;

const decode = Schema.decodeUnknownSync(Schema.OptionFromNonEmptyTrimmedString);
const encode = Schema.encodeSync(Schema.OptionFromNonEmptyTrimmedString);

// Decoding examples

console.log(decode(""));
// Output: { _id: 'Option', _tag: 'None' }

console.log(decode(" a "));
// Output: { _id: 'Option', _tag: 'Some', value: 'a' }

console.log(decode("a"));
// Output: { _id: 'Option', _tag: 'Some', value: 'a' }

// Encoding examples

console.log(encode(Option.none()));
// Output: ""

console.log(encode(Option.some("example")));
// Output: "example"
```

### Either

#### Either

The `Schema.Either` function is useful for converting an `Either` into a JSON-serializable format.

**Syntax**

```ts
Schema.Either(options: {
  left: Schema<LA, LI, LR>,
  right: Schema<RA, RI, RR>
})
```

##### Decoding

| Input                          | Output                                                                                          |
| ------------------------------ | ----------------------------------------------------------------------------------------------- |
| `{ _tag: "Left", left: LI }`   | Converted to `Either.left(LA)`, where `LI` is decoded into `LA` using the inner `left` schema   |
| `{ _tag: "Right", right: RI }` | Converted to `Either.right(RA)`, where `RI` is decoded into `RA` using the inner `right` schema |

##### Encoding

| Input              | Output                                                                                                      |
| ------------------ | ----------------------------------------------------------------------------------------------------------- |
| `Either.left(LA)`  | Converted to `{ _tag: "Left", left: LI }`, where `LA` is encoded into `LI` using the inner `left` schema    |
| `Either.right(RA)` | Converted to `{ _tag: "Right", right: RI }`, where `RA` is encoded into `RI` using the inner `right` schema |

**Example**

```ts
import { Schema, Either } from "effect";

const schema = Schema.Either({
  left: Schema.Trim,
  right: Schema.NumberFromString,
});

//     ┌─── EitherEncoded<string, string>
//     ▼
type Encoded = typeof schema.Encoded;

//     ┌─── Either<number, string>
//     ▼
type Type = typeof schema.Type;

const decode = Schema.decodeUnknownSync(schema);
const encode = Schema.encodeSync(schema);

// Decoding examples

console.log(decode({ _tag: "Left", left: " a " }));
// Output: { _id: 'Either', _tag: 'Left', left: 'a' }

console.log(decode({ _tag: "Right", right: "1" }));
// Output: { _id: 'Either', _tag: 'Right', right: 1 }

// Encoding examples

console.log(encode(Either.left("a")));
// Output: { _tag: 'Left', left: 'a' }

console.log(encode(Either.right(1)));
// Output: { _tag: 'Right', right: '1' }
```

#### EitherFromSelf

The `Schema.EitherFromSelf` function is designed for scenarios where `Either` values are already in the `Either` format and need to be decoded or encoded while transforming the inner valued according to the provided schemas.

**Syntax**

```ts
Schema.EitherFromSelf(options: {
  left: Schema<LA, LI, LR>,
  right: Schema<RA, RI, RR>
})
```

##### Decoding

| Input              | Output                                                                                          |
| ------------------ | ----------------------------------------------------------------------------------------------- |
| `Either.left(LI)`  | Converted to `Either.left(LA)`, where `LI` is decoded into `LA` using the inner `left` schema   |
| `Either.right(RI)` | Converted to `Either.right(RA)`, where `RI` is decoded into `RA` using the inner `right` schema |

##### Encoding

| Input              | Output                                                                                          |
| ------------------ | ----------------------------------------------------------------------------------------------- |
| `Either.left(LA)`  | Converted to `Either.left(LI)`, where `LA` is encoded into `LI` using the inner `left` schema   |
| `Either.right(RA)` | Converted to `Either.right(RI)`, where `RA` is encoded into `RI` using the inner `right` schema |

**Example**

```ts
import { Schema, Either } from "effect";

const schema = Schema.EitherFromSelf({
  left: Schema.Trim,
  right: Schema.NumberFromString,
});

//     ┌─── Either<string, string>
//     ▼
type Encoded = typeof schema.Encoded;

//     ┌─── Either<number, string>
//     ▼
type Type = typeof schema.Type;

const decode = Schema.decodeUnknownSync(schema);
const encode = Schema.encodeSync(schema);

// Decoding examples

console.log(decode(Either.left(" a ")));
// Output: { _id: 'Either', _tag: 'Left', left: 'a' }

console.log(decode(Either.right("1")));
// Output: { _id: 'Either', _tag: 'Right', right: 1 }

// Encoding examples

console.log(encode(Either.left("a")));
// Output: { _id: 'Either', _tag: 'Left', left: 'a' }

console.log(encode(Either.right(1)));
// Output: { _id: 'Either', _tag: 'Right', right: '1' }
```

#### EitherFromUnion

The `Schema.EitherFromUnion` function is designed to decode and encode `Either` values where the `left` and `right` sides are represented as distinct types. This schema enables conversions between raw union types and structured `Either` types.

**Syntax**

```ts
Schema.EitherFromUnion(options: {
  left: Schema<LA, LI, LR>,
  right: Schema<RA, RI, RR>
})
```

##### Decoding

| Input | Output                                                                                          |
| ----- | ----------------------------------------------------------------------------------------------- |
| `LI`  | Converted to `Either.left(LA)`, where `LI` is decoded into `LA` using the inner `left` schema   |
| `RI`  | Converted to `Either.right(RA)`, where `RI` is decoded into `RA` using the inner `right` schema |

##### Encoding

| Input              | Output                                                                            |
| ------------------ | --------------------------------------------------------------------------------- |
| `Either.left(LA)`  | Converted to `LI`, where `LA` is encoded into `LI` using the inner `left` schema  |
| `Either.right(RA)` | Converted to `RI`, where `RA` is encoded into `RI` using the inner `right` schema |

**Example**

```ts
import { Schema, Either } from "effect";

const schema = Schema.EitherFromUnion({
  left: Schema.Boolean,
  right: Schema.NumberFromString,
});

//     ┌─── string | boolean
//     ▼
type Encoded = typeof schema.Encoded;

//     ┌─── Either<number, boolean>
//     ▼
type Type = typeof schema.Type;

const decode = Schema.decodeUnknownSync(schema);
const encode = Schema.encodeSync(schema);

// Decoding examples

console.log(decode(true));
// Output: { _id: 'Either', _tag: 'Left', left: true }

console.log(decode("1"));
// Output: { _id: 'Either', _tag: 'Right', right: 1 }

// Encoding examples

console.log(encode(Either.left(true)));
// Output: true

console.log(encode(Either.right(1)));
// Output: "1"
```

### Exit

#### Exit

The `Schema.Exit` function is useful for converting an `Exit` into a JSON-serializable format.

**Syntax**

```ts
Schema.Exit(options: {
  failure: Schema<FA, FI, FR>,
  success: Schema<SA, SI, SR>,
  defect: Schema<DA, DI, DR>
})
```

##### Decoding

| Input                                              | Output                                                                                                                                            |
| -------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------- |
| `{ _tag: "Failure", cause: CauseEncoded<FI, DI> }` | Converted to `Exit.failCause(Cause<FA>)`, where `CauseEncoded<FI, DI>` is decoded into `Cause<FA>` using the inner `failure` and `defect` schemas |
| `{ _tag: "Success", value: SI }`                   | Converted to `Exit.succeed(SA)`, where `SI` is decoded into `SA` using the inner `success` schema                                                 |

##### Encoding

| Input                       | Output                                                                                                                                                                   |
| --------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `Exit.failCause(Cause<FA>)` | Converted to `{ _tag: "Failure", cause: CauseEncoded<FI, DI> }`, where `Cause<FA>` is encoded into `CauseEncoded<FI, DI>` using the inner `failure` and `defect` schemas |
| `Exit.succeed(SA)`          | Converted to `{ _tag: "Success", value: SI }`, where `SA` is encoded into `SI` using the inner `success` schema                                                          |

**Example**

```ts
import { Schema, Exit } from "effect";

const schema = Schema.Exit({
  failure: Schema.String,
  success: Schema.NumberFromString,
  defect: Schema.String,
});

//     ┌─── ExitEncoded<string, string, string>
//     ▼
type Encoded = typeof schema.Encoded;

//     ┌─── Exit<number, string>
//     ▼
type Type = typeof schema.Type;

const decode = Schema.decodeUnknownSync(schema);
const encode = Schema.encodeSync(schema);

// Decoding examples

console.log(decode({ _tag: "Failure", cause: { _tag: "Fail", error: "a" } }));
/*
Output:
{
  _id: 'Exit',
  _tag: 'Failure',
  cause: { _id: 'Cause', _tag: 'Fail', failure: 'a' }
}
*/

console.log(decode({ _tag: "Success", value: "1" }));
/*
Output:
{ _id: 'Exit', _tag: 'Success', value: 1 }
*/

// Encoding examples

console.log(encode(Exit.fail("a")));
/*
Output:
{ _tag: 'Failure', cause: { _tag: 'Fail', error: 'a' } }
 */

console.log(encode(Exit.succeed(1)));
/*
Output:
{ _tag: 'Success', value: '1' }
*/
```

#### Handling Defects in Serialization

Effect provides a built-in `Defect` schema to handle JavaScript errors (`Error` instances) and other types of unrecoverable defects.

- When decoding, it reconstructs `Error` instances if the input has a `message` and optionally a `name` and `stack`.
- When encoding, it converts `Error` instances into plain objects that retain only essential properties.

This is useful when transmitting errors across network requests or logging systems where `Error` objects do not serialize by default.

**Example** (Encoding and Decoding Defects)

```ts
import { Schema, Exit } from "effect";

const schema = Schema.Exit({
  failure: Schema.String,
  success: Schema.NumberFromString,
  defect: Schema.Defect,
});

const decode = Schema.decodeSync(schema);
const encode = Schema.encodeSync(schema);

console.log(encode(Exit.die(new Error("Message"))));
/*
Output:
{
  _tag: 'Failure',
  cause: { _tag: 'Die', defect: { name: 'Error', message: 'Message' } }
}
*/

console.log(encode(Exit.fail("a")));

console.log(
  decode({
    _tag: "Failure",
    cause: { _tag: "Die", defect: { name: "Error", message: "Message" } },
  }),
);
/*
Output:
{
  _id: 'Exit',
  _tag: 'Failure',
  cause: {
    _id: 'Cause',
    _tag: 'Die',
    defect: [Error: Message] { [cause]: [Object] }
  }
}
*/
```

#### ExitFromSelf

The `Schema.ExitFromSelf` function is designed for scenarios where `Exit` values are already in the `Exit` format and need to be decoded or encoded while transforming the inner valued according to the provided schemas.

**Syntax**

```ts
Schema.ExitFromSelf(options: {
  failure: Schema<FA, FI, FR>,
  success: Schema<SA, SI, SR>,
  defect: Schema<DA, DI, DR>
})
```

##### Decoding

| Input                       | Output                                                                                                                                 |
| --------------------------- | -------------------------------------------------------------------------------------------------------------------------------------- |
| `Exit.failCause(Cause<FI>)` | Converted to `Exit.failCause(Cause<FA>)`, where `Cause<FI>` is decoded into `Cause<FA>` using the inner `failure` and `defect` schemas |
| `Exit.succeed(SI)`          | Converted to `Exit.succeed(SA)`, where `SI` is decoded into `SA` using the inner `success` schema                                      |

##### Encoding

| Input                       | Output                                                                                                                                 |
| --------------------------- | -------------------------------------------------------------------------------------------------------------------------------------- |
| `Exit.failCause(Cause<FA>)` | Converted to `Exit.failCause(Cause<FI>)`, where `Cause<FA>` is decoded into `Cause<FI>` using the inner `failure` and `defect` schemas |
| `Exit.succeed(SA)`          | Converted to `Exit.succeed(SI)`, where `SA` is encoded into `SI` using the inner `success` schema                                      |

**Example**

```ts
import { Schema, Exit } from "effect";

const schema = Schema.ExitFromSelf({
  failure: Schema.String,
  success: Schema.NumberFromString,
  defect: Schema.String,
});

//     ┌─── Exit<string, string>
//     ▼
type Encoded = typeof schema.Encoded;

//     ┌─── Exit<number, string>
//     ▼
type Type = typeof schema.Type;

const decode = Schema.decodeUnknownSync(schema);
const encode = Schema.encodeSync(schema);

// Decoding examples

console.log(decode(Exit.fail("a")));
/*
Output:
{
  _id: 'Exit',
  _tag: 'Failure',
  cause: { _id: 'Cause', _tag: 'Fail', failure: 'a' }
}
*/

console.log(decode(Exit.succeed("1")));
/*
Output:
{ _id: 'Exit', _tag: 'Success', value: 1 }
*/

// Encoding examples

console.log(encode(Exit.fail("a")));
/*
Output:
{
  _id: 'Exit',
  _tag: 'Failure',
  cause: { _id: 'Cause', _tag: 'Fail', failure: 'a' }
}
*/

console.log(encode(Exit.succeed(1)));
/*
Output:
{ _id: 'Exit', _tag: 'Success', value: '1' }
*/
```

### ReadonlySet

#### ReadonlySet

The `Schema.ReadonlySet` function is useful for converting a `ReadonlySet` into a JSON-serializable format.

**Syntax**

```ts
Schema.ReadonlySet(schema: Schema<A, I, R>)
```

##### Decoding

| Input              | Output                                                                              |
| ------------------ | ----------------------------------------------------------------------------------- |
| `ReadonlyArray<I>` | Converted to `ReadonlySet<A>`, where `I` is decoded into `A` using the inner schema |

##### Encoding

| Input            | Output                                                                   |
| ---------------- | ------------------------------------------------------------------------ |
| `ReadonlySet<A>` | `ReadonlyArray<I>`, where `A` is encoded into `I` using the inner schema |

**Example**

```ts
import { Schema } from "effect";

const schema = Schema.ReadonlySet(Schema.NumberFromString);

//     ┌─── readonly string[]
//     ▼
type Encoded = typeof schema.Encoded;

//     ┌─── ReadonlySet<number>
//     ▼
type Type = typeof schema.Type;

const decode = Schema.decodeUnknownSync(schema);
const encode = Schema.encodeSync(schema);

// Decoding examples

console.log(decode(["1", "2", "3"]));
// Output: Set(3) { 1, 2, 3 }

// Encoding examples

console.log(encode(new Set([1, 2, 3])));
// Output: [ '1', '2', '3' ]
```

#### ReadonlySetFromSelf

The `Schema.ReadonlySetFromSelf` function is designed for scenarios where `ReadonlySet` values are already in the `ReadonlySet` format and need to be decoded or encoded while transforming the inner values according to the provided schema.

**Syntax**

```ts
Schema.ReadonlySetFromSelf(schema: Schema<A, I, R>)
```

##### Decoding

| Input            | Output                                                                              |
| ---------------- | ----------------------------------------------------------------------------------- |
| `ReadonlySet<I>` | Converted to `ReadonlySet<A>`, where `I` is decoded into `A` using the inner schema |

##### Encoding

| Input            | Output                                                                 |
| ---------------- | ---------------------------------------------------------------------- |
| `ReadonlySet<A>` | `ReadonlySet<I>`, where `A` is encoded into `I` using the inner schema |

**Example**

```ts
import { Schema } from "effect";

const schema = Schema.ReadonlySetFromSelf(Schema.NumberFromString);

//     ┌─── ReadonlySet<string>
//     ▼
type Encoded = typeof schema.Encoded;

//     ┌─── ReadonlySet<number>
//     ▼
type Type = typeof schema.Type;

const decode = Schema.decodeUnknownSync(schema);
const encode = Schema.encodeSync(schema);

// Decoding examples

console.log(decode(new Set(["1", "2", "3"])));
// Output: Set(3) { 1, 2, 3 }

// Encoding examples

console.log(encode(new Set([1, 2, 3])));
// Output: Set(3) { '1', '2', '3' }
```

### ReadonlyMap

The `Schema.ReadonlyMap` function is useful for converting a `ReadonlyMap` into a JSON-serializable format.

#### ReadonlyMap

**Syntax**

```ts
Schema.ReadonlyMap(options: {
  key: Schema<KA, KI, KR>,
  value: Schema<VA, VI, VR>
})
```

##### Decoding

| Input                              | Output                                                                                                                                                        |
| ---------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `ReadonlyArray<readonly [KI, VI]>` | Converted to `ReadonlyMap<KA, VA>`, where `KI` is decoded into `KA` using the inner `key` schema and `VI` is decoded into `VA` using the inner `value` schema |

##### Encoding

| Input                 | Output                                                                                                                                                                     |
| --------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `ReadonlyMap<KA, VA>` | Converted to `ReadonlyArray<readonly [KI, VI]>`, where `KA` is decoded into `KI` using the inner `key` schema and `VA` is decoded into `VI` using the inner `value` schema |

**Example**

```ts
import { Schema } from "effect";

const schema = Schema.ReadonlyMap({
  key: Schema.String,
  value: Schema.NumberFromString,
});

//     ┌─── readonly (readonly [string, string])[]
//     ▼
type Encoded = typeof schema.Encoded;

//     ┌─── ReadonlyMap<string, number>
//     ▼
type Type = typeof schema.Type;

const decode = Schema.decodeUnknownSync(schema);
const encode = Schema.encodeSync(schema);

// Decoding examples

console.log(
  decode([
    ["a", "2"],
    ["b", "2"],
    ["c", "3"],
  ]),
);
// Output: Map(3) { 'a' => 2, 'b' => 2, 'c' => 3 }

// Encoding examples

console.log(
  encode(
    new Map([
      ["a", 1],
      ["b", 2],
      ["c", 3],
    ]),
  ),
);
// Output: [ [ 'a', '1' ], [ 'b', '2' ], [ 'c', '3' ] ]
```

#### ReadonlyMapFromSelf

The `Schema.ReadonlyMapFromSelf` function is designed for scenarios where `ReadonlyMap` values are already in the `ReadonlyMap` format and need to be decoded or encoded while transforming the inner values according to the provided schemas.

**Syntax**

```ts
Schema.ReadonlyMapFromSelf(options: {
  key: Schema<KA, KI, KR>,
  value: Schema<VA, VI, VR>
})
```

##### Decoding

| Input                 | Output                                                                                                                                                        |
| --------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `ReadonlyMap<KI, VI>` | Converted to `ReadonlyMap<KA, VA>`, where `KI` is decoded into `KA` using the inner `key` schema and `VI` is decoded into `VA` using the inner `value` schema |

##### Encoding

| Input                 | Output                                                                                                                                                        |
| --------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `ReadonlyMap<KA, VA>` | Converted to `ReadonlyMap<KI, VI>`, where `KA` is decoded into `KI` using the inner `key` schema and `VA` is decoded into `VI` using the inner `value` schema |

**Example**

```ts
import { Schema } from "effect";

const schema = Schema.ReadonlyMapFromSelf({
  key: Schema.String,
  value: Schema.NumberFromString,
});

//     ┌─── ReadonlyMap<string, string>
//     ▼
type Encoded = typeof schema.Encoded;

//     ┌─── ReadonlyMap<string, number>
//     ▼
type Type = typeof schema.Type;

const decode = Schema.decodeUnknownSync(schema);
const encode = Schema.encodeSync(schema);

// Decoding examples

console.log(
  decode(
    new Map([
      ["a", "2"],
      ["b", "2"],
      ["c", "3"],
    ]),
  ),
);
// Output: Map(3) { 'a' => 2, 'b' => 2, 'c' => 3 }

// Encoding examples

console.log(
  encode(
    new Map([
      ["a", 1],
      ["b", 2],
      ["c", 3],
    ]),
  ),
);
// Output: Map(3) { 'a' => '1', 'b' => '2', 'c' => '3' }
```

#### ReadonlyMapFromRecord

The `Schema.ReadonlyMapFromRecord` function is a utility to transform a `ReadonlyMap` into an object format, where keys are strings and values are serializable, and vice versa.

**Syntax**

```ts
Schema.ReadonlyMapFromRecord({
  key: Schema<KA, KI, KR>,
  value: Schema<VA, VI, VR>,
});
```

##### Decoding

| Input                          | Output                                                                                                                               |
| ------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------ |
| `{ readonly [x: string]: VI }` | Converts to `ReadonlyMap<KA, VA>`, where `x` is decoded into `KA` using the `key` schema and `VI` into `VA` using the `value` schema |

##### Encoding

| Input                 | Output                                                                                                                                        |
| --------------------- | --------------------------------------------------------------------------------------------------------------------------------------------- |
| `ReadonlyMap<KA, VA>` | Converts to `{ readonly [x: string]: VI }`, where `KA` is encoded into `x` using the `key` schema and `VA` into `VI` using the `value` schema |

**Example**

```ts
import { Schema } from "effect";

const schema = Schema.ReadonlyMapFromRecord({
  key: Schema.NumberFromString,
  value: Schema.NumberFromString,
});

//     ┌─── { readonly [x: string]: string; }
//     ▼
type Encoded = typeof schema.Encoded;

//     ┌─── ReadonlyMap<number, number>
//     ▼
type Type = typeof schema.Type;

const decode = Schema.decodeUnknownSync(schema);
const encode = Schema.encodeSync(schema);

// Decoding examples

console.log(
  decode({
    "1": "4",
    "2": "5",
    "3": "6",
  }),
);
// Output: Map(3) { 1 => 4, 2 => 5, 3 => 6 }

// Encoding examples

console.log(
  encode(
    new Map([
      [1, 4],
      [2, 5],
      [3, 6],
    ]),
  ),
);
// Output: { '1': '4', '2': '5', '3': '6' }
```

### HashSet

#### HashSet

The `Schema.HashSet` function provides a way to map between `HashSet` and an array representation, allowing for JSON serialization and deserialization.

**Syntax**

```ts
Schema.HashSet(schema: Schema<A, I, R>)
```

##### Decoding

| Input              | Output                                                                                              |
| ------------------ | --------------------------------------------------------------------------------------------------- |
| `ReadonlyArray<I>` | Converts to `HashSet<A>`, where each element in the array is decoded into type `A` using the schema |

##### Encoding

| Input        | Output                                                                                                        |
| ------------ | ------------------------------------------------------------------------------------------------------------- |
| `HashSet<A>` | Converts to `ReadonlyArray<I>`, where each element in the `HashSet` is encoded into type `I` using the schema |

**Example**

```ts
import { Schema } from "effect";
import { HashSet } from "effect";

const schema = Schema.HashSet(Schema.NumberFromString);

//     ┌─── readonly string[]
//     ▼
type Encoded = typeof schema.Encoded;

//     ┌─── HashSet<number>
//     ▼
type Type = typeof schema.Type;

const decode = Schema.decodeUnknownSync(schema);
const encode = Schema.encodeSync(schema);

// Decoding examples

console.log(decode(["1", "2", "3"]));
// Output: { _id: 'HashSet', values: [ 1, 2, 3 ] }

// Encoding examples

console.log(encode(HashSet.fromIterable([1, 2, 3])));
// Output: [ '1', '2', '3' ]
```

#### HashSetFromSelf

The `Schema.HashSetFromSelf` function is designed for scenarios where `HashSet` values are already in the `HashSet` format and need to be decoded or encoded while transforming the inner values according to the provided schema.

**Syntax**

```ts
Schema.HashSetFromSelf(schema: Schema<A, I, R>)
```

##### Decoding

| Input        | Output                                                                                     |
| ------------ | ------------------------------------------------------------------------------------------ |
| `HashSet<I>` | Converts to `HashSet<A>`, decoding each element from type `I` to type `A` using the schema |

##### Encoding

| Input        | Output                                                                                     |
| ------------ | ------------------------------------------------------------------------------------------ |
| `HashSet<A>` | Converts to `HashSet<I>`, encoding each element from type `A` to type `I` using the schema |

**Example**

```ts
import { Schema } from "effect";
import { HashSet } from "effect";

const schema = Schema.HashSetFromSelf(Schema.NumberFromString);

//     ┌─── HashSet<string>
//     ▼
type Encoded = typeof schema.Encoded;

//     ┌─── HashSet<number>
//     ▼
type Type = typeof schema.Type;

const decode = Schema.decodeUnknownSync(schema);
const encode = Schema.encodeSync(schema);

// Decoding examples

console.log(decode(HashSet.fromIterable(["1", "2", "3"])));
// Output: { _id: 'HashSet', values: [ 1, 2, 3 ] }

// Encoding examples

console.log(encode(HashSet.fromIterable([1, 2, 3])));
// Output: { _id: 'HashSet', values: [ '1', '3', '2' ] }
```

### HashMap

#### HashMap

The `Schema.HashMap` function is useful for converting a `HashMap` into a JSON-serializable format.

**Syntax**

```ts
Schema.HashMap(options: {
  key: Schema<KA, KI, KR>,
  value: Schema<VA, VI, VR>
})
```

| Input                              | Output                                                                                                                   |
| ---------------------------------- | ------------------------------------------------------------------------------------------------------------------------ |
| `ReadonlyArray<readonly [KI, VI]>` | Converts to `HashMap<KA, VA>`, where `KI` is decoded into `KA` and `VI` is decoded into `VA` using the specified schemas |

##### Encoding

| Input             | Output                                                                                                                                    |
| ----------------- | ----------------------------------------------------------------------------------------------------------------------------------------- |
| `HashMap<KA, VA>` | Converts to `ReadonlyArray<readonly [KI, VI]>`, where `KA` is encoded into `KI` and `VA` is encoded into `VI` using the specified schemas |

**Example**

```ts
import { Schema } from "effect";
import { HashMap } from "effect";

const schema = Schema.HashMap({
  key: Schema.String,
  value: Schema.NumberFromString,
});

//     ┌─── readonly (readonly [string, string])[]
//     ▼
type Encoded = typeof schema.Encoded;

//     ┌─── HashMap<string, number>
//     ▼
type Type = typeof schema.Type;

const decode = Schema.decodeUnknownSync(schema);
const encode = Schema.encodeSync(schema);

// Decoding examples

console.log(
  decode([
    ["a", "2"],
    ["b", "2"],
    ["c", "3"],
  ]),
);
// Output: { _id: 'HashMap', values: [ [ 'a', 2 ], [ 'c', 3 ], [ 'b', 2 ] ] }

// Encoding examples

console.log(
  encode(
    HashMap.fromIterable([
      ["a", 1],
      ["b", 2],
      ["c", 3],
    ]),
  ),
);
// Output: [ [ 'a', '1' ], [ 'c', '3' ], [ 'b', '2' ] ]
```

#### HashMapFromSelf

The `Schema.HashMapFromSelf` function is designed for scenarios where `HashMap` values are already in the `HashMap` format and need to be decoded or encoded while transforming the inner values according to the provided schemas.

**Syntax**

```ts
Schema.HashMapFromSelf(options: {
  key: Schema<KA, KI, KR>,
  value: Schema<VA, VI, VR>
})
```

##### Decoding

| Input             | Output                                                                                                                   |
| ----------------- | ------------------------------------------------------------------------------------------------------------------------ |
| `HashMap<KI, VI>` | Converts to `HashMap<KA, VA>`, where `KI` is decoded into `KA` and `VI` is decoded into `VA` using the specified schemas |

##### Encoding

| Input             | Output                                                                                                                   |
| ----------------- | ------------------------------------------------------------------------------------------------------------------------ |
| `HashMap<KA, VA>` | Converts to `HashMap<KI, VI>`, where `KA` is encoded into `KI` and `VA` is encoded into `VI` using the specified schemas |

**Example**

```ts
import { Schema } from "effect";
import { HashMap } from "effect";

const schema = Schema.HashMapFromSelf({
  key: Schema.String,
  value: Schema.NumberFromString,
});

//     ┌─── HashMap<string, string>
//     ▼
type Encoded = typeof schema.Encoded;

//     ┌─── HashMap<string, number>
//     ▼
type Type = typeof schema.Type;

const decode = Schema.decodeUnknownSync(schema);
const encode = Schema.encodeSync(schema);

// Decoding examples

console.log(
  decode(
    HashMap.fromIterable([
      ["a", "2"],
      ["b", "2"],
      ["c", "3"],
    ]),
  ),
);
// Output: { _id: 'HashMap', values: [ [ 'a', 2 ], [ 'c', 3 ], [ 'b', 2 ] ] }

// Encoding examples

console.log(
  encode(
    HashMap.fromIterable([
      ["a", 1],
      ["b", 2],
      ["c", 3],
    ]),
  ),
);
// Output: { _id: 'HashMap', values: [ [ 'a', '1' ], [ 'c', '3' ], [ 'b', '2' ] ] }
```

### SortedSet

#### SortedSet

The `Schema.SortedSet` function provides a way to map between `SortedSet` and an array representation, allowing for JSON serialization and deserialization.

**Syntax**

```ts
Schema.SortedSet(schema: Schema<A, I, R>, order: Order<A>)
```

##### Decoding

| Input              | Output                                                                                                |
| ------------------ | ----------------------------------------------------------------------------------------------------- |
| `ReadonlyArray<I>` | Converts to `SortedSet<A>`, where each element in the array is decoded into type `A` using the schema |

##### Encoding

| Input          | Output                                                                                                          |
| -------------- | --------------------------------------------------------------------------------------------------------------- |
| `SortedSet<A>` | Converts to `ReadonlyArray<I>`, where each element in the `SortedSet` is encoded into type `I` using the schema |

**Example**

```ts
import { Schema } from "effect";
import { Number, SortedSet } from "effect";

const schema = Schema.SortedSet(Schema.NumberFromString, Number.Order);

//     ┌─── readonly string[]
//     ▼
type Encoded = typeof schema.Encoded;

//     ┌─── SortedSet<number>
//     ▼
type Type = typeof schema.Type;

const decode = Schema.decodeUnknownSync(schema);
const encode = Schema.encodeSync(schema);

// Decoding examples

console.log(decode(["1", "2", "3"]));
// Output: { _id: 'SortedSet', values: [ 1, 2, 3 ] }

// Encoding examples

console.log(encode(SortedSet.fromIterable(Number.Order)([1, 2, 3])));
// Output: [ '1', '2', '3' ]
```

#### SortedSetFromSelf

The `Schema.SortedSetFromSelf` function is designed for scenarios where `SortedSet` values are already in the `SortedSet` format and need to be decoded or encoded while transforming the inner values according to the provided schema.

**Syntax**

```ts
Schema.SortedSetFromSelf(
  schema: Schema<A, I, R>,
  decodeOrder: Order<A>,
  encodeOrder: Order<I>
)
```

##### Decoding

| Input          | Output                                                                                       |
| -------------- | -------------------------------------------------------------------------------------------- |
| `SortedSet<I>` | Converts to `SortedSet<A>`, decoding each element from type `I` to type `A` using the schema |

##### Encoding

| Input          | Output                                                                                       |
| -------------- | -------------------------------------------------------------------------------------------- |
| `SortedSet<A>` | Converts to `SortedSet<I>`, encoding each element from type `A` to type `I` using the schema |

**Example**

```ts
import { Schema } from "effect";
import { Number, SortedSet, String } from "effect";

const schema = Schema.SortedSetFromSelf(
  Schema.NumberFromString,
  Number.Order,
  String.Order,
);

//     ┌─── SortedSet<string>
//     ▼
type Encoded = typeof schema.Encoded;

//     ┌─── SortedSet<number>
//     ▼
type Type = typeof schema.Type;

const decode = Schema.decodeUnknownSync(schema);
const encode = Schema.encodeSync(schema);

// Decoding examples

console.log(decode(SortedSet.fromIterable(String.Order)(["1", "2", "3"])));
// Output: { _id: 'SortedSet', values: [ 1, 2, 3 ] }

// Encoding examples

console.log(encode(SortedSet.fromIterable(Number.Order)([1, 2, 3])));
// Output: { _id: 'SortedSet', values: [ '1', '2', '3' ] }
```

### Duration

The `Duration` schema family enables the transformation and validation of duration values across various formats, including `hrtime`, milliseconds, and nanoseconds.

#### Duration

Converts an hrtime(i.e. `[seconds: number, nanos: number]`) into a `Duration`.

**Example**

```ts
import { Schema } from "effect";

const schema = Schema.Duration;

//     ┌─── readonly [seconds: number, nanos: number]
//     ▼
type Encoded = typeof schema.Encoded;

//     ┌─── Duration
//     ▼
type Type = typeof schema.Type;

const decode = Schema.decodeUnknownSync(schema);

// Decoding examples

console.log(decode([0, 0]));
// Output: { _id: 'Duration', _tag: 'Millis', millis: 0 }

console.log(decode([5000, 0]));
// Output: { _id: 'Duration', _tag: 'Nanos', hrtime: [ 5000, 0 ] }
```

#### DurationFromSelf

The `DurationFromSelf` schema is designed to validate that a given value conforms to the `Duration` type.

**Example**

```ts
import { Schema, Duration } from "effect";

const schema = Schema.DurationFromSelf;

//     ┌─── Duration
//     ▼
type Encoded = typeof schema.Encoded;

//     ┌─── Duration
//     ▼
type Type = typeof schema.Type;

const decode = Schema.decodeUnknownSync(schema);

// Decoding examples

console.log(decode(Duration.seconds(2)));
// Output: { _id: 'Duration', _tag: 'Millis', millis: 2000 }

console.log(decode(null));
/*
throws:
ParseError: Expected DurationFromSelf, actual null
*/
```

#### DurationFromMillis

Converts a `number` into a `Duration` where the number represents the number of milliseconds.

**Example**

```ts
import { Schema } from "effect";

const schema = Schema.DurationFromMillis;

//     ┌─── number
//     ▼
type Encoded = typeof schema.Encoded;

//     ┌─── Duration
//     ▼
type Type = typeof schema.Type;

const decode = Schema.decodeUnknownSync(schema);

// Decoding examples

console.log(decode(0));
// Output: { _id: 'Duration', _tag: 'Millis', millis: 0 }

console.log(decode(5000));
// Output: { _id: 'Duration', _tag: 'Millis', millis: 5000 }
```

#### DurationFromNanos

Converts a `BigInt` into a `Duration` where the number represents the number of nanoseconds.

**Example**

```ts
import { Schema } from "effect";

const schema = Schema.DurationFromNanos;

//     ┌─── bigint
//     ▼
type Encoded = typeof schema.Encoded;

//     ┌─── Duration
//     ▼
type Type = typeof schema.Type;

const decode = Schema.decodeUnknownSync(schema);

// Decoding examples

console.log(decode(0n));
// Output: { _id: 'Duration', _tag: 'Millis', millis: 0 }

console.log(decode(5000000000n));
// Output: { _id: 'Duration', _tag: 'Nanos', hrtime: [ 5, 0 ] }
```

#### clampDuration

Clamps a `Duration` between a minimum and a maximum value.

**Example**

```ts
import { Schema, Duration } from "effect";

const schema = Schema.DurationFromSelf.pipe(
  Schema.clampDuration("5 seconds", "10 seconds"),
);

//     ┌─── Duration
//     ▼
type Encoded = typeof schema.Encoded;

//     ┌─── Duration
//     ▼
type Type = typeof schema.Type;

const decode = Schema.decodeUnknownSync(schema);

// Decoding examples

console.log(decode(Duration.decode("2 seconds")));
// Output: { _id: 'Duration', _tag: 'Millis', millis: 5000 }

console.log(decode(Duration.decode("6 seconds")));
// Output: { _id: 'Duration', _tag: 'Millis', millis: 6000 }

console.log(decode(Duration.decode("11 seconds")));
// Output: { _id: 'Duration', _tag: 'Millis', millis: 10000 }
```

### Redacted

#### Redacted

The `Schema.Redacted` function is specifically designed to handle sensitive information by converting a `string` into a [Redacted](/docs/data-types/redacted/) object.
This transformation ensures that the sensitive data is not exposed in the application's output.

**Example** (Basic Redacted Schema)

```ts
import { Schema } from "effect";

const schema = Schema.Redacted(Schema.String);

//     ┌─── string
//     ▼
type Encoded = typeof schema.Encoded;

//     ┌─── Redacted<string>
//     ▼
type Type = typeof schema.Type;

const decode = Schema.decodeUnknownSync(schema);

// Decoding examples

console.log(decode("keep it secret, keep it safe"));
// Output: <redacted>
```

It's important to note that when successfully decoding a `Redacted`, the output is intentionally obscured (`<redacted>`) to prevent the actual secret from being revealed in logs or console outputs.

> **Caution**: Potential Risks
>
> When composing the `Redacted` schema with other schemas, care must be
> taken as decoding or encoding errors could potentially expose sensitive
> information.

**Example** (Exposure Risks During Errors)

In the example below, if the input string does not meet the criteria (e.g., contains spaces), the error message generated might inadvertently expose sensitive information included in the input.

```ts
import { Schema } from "effect";
import { Redacted } from "effect";

const schema = Schema.Trimmed.pipe(
  Schema.compose(Schema.Redacted(Schema.String)),
);

console.log(Schema.decodeUnknownEither(schema)(" SECRET"));
/*
{
  _id: 'Either',
  _tag: 'Left',
  left: {
    _id: 'ParseError',
    message: '(Trimmed <-> (string <-> Redacted(<redacted>)))\n' +
      '└─ Encoded side transformation failure\n' +
      '   └─ Trimmed\n' +
      '      └─ Predicate refinement failure\n' +
      '         └─ Expected Trimmed (a string with no leading or trailing whitespace), actual " SECRET"'
  }
}
*/

console.log(Schema.encodeEither(schema)(Redacted.make(" SECRET")));
/*
{
  _id: 'Either',
  _tag: 'Left',
  left: {
    _id: 'ParseError',
    message: '(Trimmed <-> (string <-> Redacted(<redacted>)))\n' +
      '└─ Encoded side transformation failure\n' +
      '   └─ Trimmed\n' +
      '      └─ Predicate refinement failure\n' +
      '         └─ Expected Trimmed (a string with no leading or trailing whitespace), actual " SECRET"'
  }
}
*/
```

##### Mitigating Exposure Risks

To reduce the risk of sensitive information leakage in error messages, you can customize the error messages to obscure sensitive details:

**Example** (Customizing Error Messages)

```ts
import { Schema } from "effect";
import { Redacted } from "effect";

const schema = Schema.Trimmed.annotations({
  message: () => "Expected Trimmed, actual <redacted>",
}).pipe(Schema.compose(Schema.Redacted(Schema.String)));

console.log(Schema.decodeUnknownEither(schema)(" SECRET"));
/*
{
  _id: 'Either',
  _tag: 'Left',
  left: {
    _id: 'ParseError',
    message: '(Trimmed <-> (string <-> Redacted(<redacted>)))\n' +
      '└─ Encoded side transformation failure\n' +
      '   └─ Expected Trimmed, actual <redacted>'
  }
}
*/

console.log(Schema.encodeEither(schema)(Redacted.make(" SECRET")));
/*
{
  _id: 'Either',
  _tag: 'Left',
  left: {
    _id: 'ParseError',
    message: '(Trimmed <-> (string <-> Redacted(<redacted>)))\n' +
      '└─ Encoded side transformation failure\n' +
      '   └─ Expected Trimmed, actual <redacted>'
  }
}
*/
```

#### RedactedFromSelf

The `Schema.RedactedFromSelf` schema is designed to validate that a given value conforms to the `Redacted` type from the `effect` library.

**Example**

```ts
import { Schema } from "effect";
import { Redacted } from "effect";

const schema = Schema.RedactedFromSelf(Schema.String);

//     ┌─── Redacted<string>
//     ▼
type Encoded = typeof schema.Encoded;

//     ┌─── Redacted<string>
//     ▼
type Type = typeof schema.Type;

const decode = Schema.decodeUnknownSync(schema);

// Decoding examples

console.log(decode(Redacted.make("mysecret")));
// Output: <redacted>

console.log(decode(null));
/*
throws:
ParseError: Expected Redacted(<redacted>), actual null
*/
```

It's important to note that when successfully decoding a `Redacted`, the output is intentionally obscured (`<redacted>`) to prevent the actual secret from being revealed in logs or console outputs.
