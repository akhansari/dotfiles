# Schema: Utilities

## JSON Schema

The `JSONSchema.make` function allows you to generate a JSON Schema from a schema.

**Example** (Creating a JSON Schema for a Struct)

The following example defines a `Person` schema with properties for `name` (a string) and `age` (a number). It then generates the corresponding JSON Schema.

```ts
import { JSONSchema, Schema } from "effect";

const Person = Schema.Struct({
  name: Schema.String,
  age: Schema.Number,
});

const jsonSchema = JSONSchema.make(Person);

console.log(JSON.stringify(jsonSchema, null, 2));
/*
Output:
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "required": [
    "name",
    "age"
  ],
  "properties": {
    "name": {
      "type": "string"
    },
    "age": {
      "type": "number"
    }
  },
  "additionalProperties": false
}
*/
```

The `JSONSchema.make` function aims to produce an optimal JSON Schema representing the input part of the decoding phase.
It does this by traversing the schema from the most nested component, incorporating each refinement, and **stops at the first transformation** encountered.

**Example** (Excluding Transformations in JSON Schema)

Consider modifying the `age` field to include both a refinement and a transformation. Only the refinement is reflected in the JSON Schema.

```ts
import { JSONSchema, Schema } from "effect";

const Person = Schema.Struct({
  name: Schema.String,
  age: Schema.Number.pipe(
    // Refinement included in the JSON Schema
    Schema.int(),
    // Transformation excluded from the JSON Schema
    Schema.clamp(1, 10),
  ),
});

const jsonSchema = JSONSchema.make(Person);

console.log(JSON.stringify(jsonSchema, null, 2));
/*
Output:
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "required": [
    "name",
    "age"
  ],
  "properties": {
    "name": {
      "type": "string"
    },
    "age": {
      "type": "integer",
      "description": "an integer",
      "title": "integer"
    }
  },
  "additionalProperties": false
}
*/
```

In this case, the JSON Schema reflects the integer refinement but does not include the transformation that clamps the value.

### Targeting a Specific JSON Schema Version

By default, `JSONSchema.make` generates a JSON Schema compatible with **Draft 07**. You can change the target schema version by passing an options object with a `target` property. The supported targets are:

- `"jsonSchema7"` (default) - JSON Schema Draft 07
- `"jsonSchema2019-09"` - JSON Schema Draft 2019-09
- `"jsonSchema2020-12"` - JSON Schema Draft 2020-12
- `"openApi3.1"` - OpenAPI 3.1

Changing the target can affect the generated output. For example, tuple schemas use `items` and `additionalItems` in Draft 07, whereas Draft 2020-12 uses `prefixItems` and `items`.

**Example** (Using JSON Schema 2020-12 for a Tuple)

```ts
import { JSONSchema, Schema } from "effect";

const schema = Schema.Tuple(Schema.String, Schema.Number);

const jsonSchema = JSONSchema.make(schema, {
  target: "jsonSchema2020-12",
});

console.log(JSON.stringify(jsonSchema, null, 2));
/*
Output:
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "type": "array",
  "minItems": 2,
  "prefixItems": [
    {
      "type": "string"
    },
    {
      "type": "number"
    }
  ],
  "items": false
}
*/
```

### Specific Outputs for Schema Types

### Literals

Literals are transformed into `enum` types within JSON Schema.

**Example** (Single Literal)

```ts
import { JSONSchema, Schema } from "effect";

const schema = Schema.Literal("a");

console.log(JSON.stringify(JSONSchema.make(schema), null, 2));
/*
Output:
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "string",
  "enum": [
    "a"
  ]
}
*/
```

**Example** (Union of literals)

```ts
import { JSONSchema, Schema } from "effect";

const schema = Schema.Literal("a", "b");

console.log(JSON.stringify(JSONSchema.make(schema), null, 2));
/*
Output:
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "string",
  "enum": [
    "a",
    "b"
  ]
}
*/
```

### Void

```ts
import { JSONSchema, Schema } from "effect";

const schema = Schema.Void;

console.log(JSON.stringify(JSONSchema.make(schema), null, 2));
/*
Output:
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "/schemas/void",
  "title": "void"
}
*/
```

### Any

```ts
import { JSONSchema, Schema } from "effect";

const schema = Schema.Any;

console.log(JSON.stringify(JSONSchema.make(schema), null, 2));
/*
Output:
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "/schemas/any",
  "title": "any"
}
*/
```

### Unknown

```ts
import { JSONSchema, Schema } from "effect";

const schema = Schema.Unknown;

console.log(JSON.stringify(JSONSchema.make(schema), null, 2));
/*
Output:
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "/schemas/unknown",
  "title": "unknown"
}
*/
```

### Object

```ts
import { JSONSchema, Schema } from "effect";

const schema = Schema.Object;

console.log(JSON.stringify(JSONSchema.make(schema), null, 2));
/*
Output:
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "/schemas/object",
  "anyOf": [
    {
      "type": "object"
    },
    {
      "type": "array"
    }
  ],
  "description": "an object in the TypeScript meaning, i.e. the `object` type",
  "title": "object"
}
*/
```

### String

```ts
import { JSONSchema, Schema } from "effect";

const schema = Schema.String;

console.log(JSON.stringify(JSONSchema.make(schema), null, 2));
/*
Output:
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "string"
}
*/
```

### Number

```ts
import { JSONSchema, Schema } from "effect";

const schema = Schema.Number;

console.log(JSON.stringify(JSONSchema.make(schema), null, 2));
/*
Output:
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "number"
}
*/
```

### Boolean

```ts
import { JSONSchema, Schema } from "effect";

const schema = Schema.Boolean;

console.log(JSON.stringify(JSONSchema.make(schema), null, 2));
/*
Output:
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "boolean"
}
*/
```

### Tuples

```ts
import { JSONSchema, Schema } from "effect";

const schema = Schema.Tuple(Schema.String, Schema.Number);

console.log(JSON.stringify(JSONSchema.make(schema), null, 2));
/*
Output:
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "array",
  "minItems": 2,
  "items": [
    {
      "type": "string"
    },
    {
      "type": "number"
    }
  ],
  "additionalItems": false
}
*/
```

### Arrays

```ts
import { JSONSchema, Schema } from "effect";

const schema = Schema.Array(Schema.String);

console.log(JSON.stringify(JSONSchema.make(schema), null, 2));
/*
Output:
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "array",
  "items": {
    "type": "string"
  }
}
*/
```

### Non Empty Arrays

Represents an array with at least one element.

**Example**

```ts
import { JSONSchema, Schema } from "effect";

const schema = Schema.NonEmptyArray(Schema.String);

console.log(JSON.stringify(JSONSchema.make(schema), null, 2));
/*
Output:
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "array",
  "minItems": 1,
  "items": {
    "type": "string"
  }
}
*/
```

### Structs

```ts
import { JSONSchema, Schema } from "effect";

const schema = Schema.Struct({
  name: Schema.String,
  age: Schema.Number,
});

console.log(JSON.stringify(JSONSchema.make(schema), null, 2));
/*
Output:
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "required": [
    "name",
    "age"
  ],
  "properties": {
    "name": {
      "type": "string"
    },
    "age": {
      "type": "number"
    }
  },
  "additionalProperties": false
}
*/
```

### Records

```ts
import { JSONSchema, Schema } from "effect";

const schema = Schema.Record({
  key: Schema.String,
  value: Schema.Number,
});

console.log(JSON.stringify(JSONSchema.make(schema), null, 2));
/*
Output:
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "required": [],
  "properties": {},
  "patternProperties": {
    "": {
      "type": "number"
    }
  }
}
*/
```

### Mixed Structs with Records

Combines fixed properties from a struct with dynamic properties from a record.

**Example**

```ts
import { JSONSchema, Schema } from "effect";

const schema = Schema.Struct(
  {
    name: Schema.String,
    age: Schema.Number,
  },
  Schema.Record({
    key: Schema.String,
    value: Schema.Union(Schema.String, Schema.Number),
  }),
);

console.log(JSON.stringify(JSONSchema.make(schema), null, 2));
/*
Output:
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "required": [
    "name",
    "age"
  ],
  "properties": {
    "name": {
      "type": "string"
    },
    "age": {
      "type": "number"
    }
  },
  "patternProperties": {
    "": {
      "anyOf": [
        {
          "type": "string"
        },
        {
          "type": "number"
        }
      ]
    }
  }
}
*/
```

### Enums

```ts
import { JSONSchema, Schema } from "effect";

enum Fruits {
  Apple,
  Banana,
}

const schema = Schema.Enums(Fruits);

console.log(JSON.stringify(JSONSchema.make(schema), null, 2));
/*
Output:
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$comment": "/schemas/enums",
  "anyOf": [
    {
      "type": "number",
      "title": "Apple",
      "enum": [
        0
      ]
    },
    {
      "type": "number",
      "title": "Banana",
      "enum": [
        1
      ]
    }
  ]
}
*/
```

### Template Literals

```ts
import { JSONSchema, Schema } from "effect";

const schema = Schema.TemplateLiteral(Schema.Literal("a"), Schema.Number);

console.log(JSON.stringify(JSONSchema.make(schema), null, 2));
/*
Output:
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "string",
  "title": "`a${number}`",
  "description": "a template literal",
  "pattern": "^a[+-]?\\d*\\.?\\d+(?:[Ee][+-]?\\d+)?$"
}
*/
```

### Unions

Unions are expressed using `anyOf` or `enum`, depending on the types involved:

**Example** (Generic Union)

```ts
import { JSONSchema, Schema } from "effect";

const schema = Schema.Union(Schema.String, Schema.Number);

console.log(JSON.stringify(JSONSchema.make(schema), null, 2));
/*
Output:
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "anyOf": [
    {
      "type": "string"
    },
    {
      "type": "number"
    }
  ]
}
*/
```

**Example** (Union of literals)

```ts
import { JSONSchema, Schema } from "effect";

const schema = Schema.Literal("a", "b");

console.log(JSON.stringify(JSONSchema.make(schema), null, 2));
/*
Output:
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "string",
  "enum": [
    "a",
    "b"
  ]
}
*/
```

### Identifier Annotations

You can add `identifier` annotations to schemas to improve structure and maintainability. Annotated schemas are included in a `$defs` object in the root of the JSON Schema and referenced from there.

**Example** (Using Identifier Annotations)

```ts
import { JSONSchema, Schema } from "effect";

const Name = Schema.String.annotations({ identifier: "Name" });

const Age = Schema.Number.annotations({ identifier: "Age" });

const Person = Schema.Struct({
  name: Name,
  age: Age,
});

const jsonSchema = JSONSchema.make(Person);

console.log(JSON.stringify(jsonSchema, null, 2));
/*
Output:
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$defs": {
    "Name": {
      "type": "string",
      "description": "a string",
      "title": "string"
    },
    "Age": {
      "type": "number",
      "description": "a number",
      "title": "number"
    }
  },
  "type": "object",
  "required": [
    "name",
    "age"
  ],
  "properties": {
    "name": {
      "$ref": "#/$defs/Name"
    },
    "age": {
      "$ref": "#/$defs/Age"
    }
  },
  "additionalProperties": false
}
*/
```

By using identifier annotations, schemas can be reused and referenced more easily, especially in complex JSON Schemas.

### Standard JSON Schema Annotations

Standard JSON Schema annotations such as `title`, `description`, `default`, and `examples` are supported.
These annotations allow you to enrich your schemas with metadata that can enhance readability and provide additional information about the data structure.

**Example** (Using Annotations for Metadata)

```ts
import { JSONSchema, Schema } from "effect";

const schema = Schema.String.annotations({
  description: "my custom description",
  title: "my custom title",
  default: "",
  examples: ["a", "b"],
});

const jsonSchema = JSONSchema.make(schema);

console.log(JSON.stringify(jsonSchema, null, 2));
/*
Output:
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "string",
  "description": "my custom description",
  "title": "my custom title",
  "examples": [
    "a",
    "b"
  ],
  "default": ""
}
*/
```

### Adding annotations to Struct properties

To enhance the clarity of your JSON schemas, it's advisable to add annotations directly to the property signatures rather than to the type itself.
This method is more semantically appropriate as it links descriptive titles and other metadata specifically to the properties they describe, rather than to the generic type.

**Example** (Annotated Struct Properties)

```ts
import { JSONSchema, Schema } from "effect";

const Person = Schema.Struct({
  firstName: Schema.propertySignature(Schema.String).annotations({
    title: "First name",
  }),
  lastName: Schema.propertySignature(Schema.String).annotations({
    title: "Last Name",
  }),
});

const jsonSchema = JSONSchema.make(Person);

console.log(JSON.stringify(jsonSchema, null, 2));
/*
Output:
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "required": [
    "firstName",
    "lastName"
  ],
  "properties": {
    "firstName": {
      "type": "string",
      "title": "First name"
    },
    "lastName": {
      "type": "string",
      "title": "Last Name"
    }
  },
  "additionalProperties": false
}
*/
```

### Recursive and Mutually Recursive Schemas

Recursive and mutually recursive schemas are supported, however it's **mandatory** to use `identifier` annotations for these types of schemas to ensure correct references and definitions within the generated JSON Schema.

**Example** (Recursive Schema with Identifier Annotations)

In this example, the `Category` schema refers to itself, making it necessary to use an `identifier` annotation to facilitate the reference.

```ts
import { JSONSchema, Schema } from "effect";

// Define the interface representing a category structure
interface Category {
  readonly name: string;
  readonly categories: ReadonlyArray<Category>;
}

// Define a recursive schema with a required identifier annotation
const Category = Schema.Struct({
  name: Schema.String,
  categories: Schema.Array(
    // Recursive reference to the Category schema
    Schema.suspend((): Schema.Schema<Category> => Category),
  ),
}).annotations({ identifier: "Category" });

const jsonSchema = JSONSchema.make(Category);

console.log(JSON.stringify(jsonSchema, null, 2));
/*
Output:
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$defs": {
    "Category": {
      "type": "object",
      "required": [
        "name",
        "categories"
      ],
      "properties": {
        "name": {
          "type": "string"
        },
        "categories": {
          "type": "array",
          "items": {
            "$ref": "#/$defs/Category"
          }
        }
      },
      "additionalProperties": false
    }
  },
  "$ref": "#/$defs/Category"
}
*/
```

### Customizing JSON Schema Generation

When working with JSON Schema certain data types, such as `bigint`, lack a direct representation because JSON Schema does not natively support them.
This absence typically leads to an error when the schema is generated.

**Example** (Error Due to Missing Annotation)

Attempting to generate a JSON Schema for unsupported types like `bigint` will lead to a missing annotation error:

```ts
import { JSONSchema, Schema } from "effect";

const schema = Schema.Struct({
  a_bigint_field: Schema.BigIntFromSelf,
});

const jsonSchema = JSONSchema.make(schema);

console.log(JSON.stringify(jsonSchema, null, 2));
/*
throws:
Error: Missing annotation
at path: ["a_bigint_field"]
details: Generating a JSON Schema for this schema requires a "jsonSchema" annotation
schema (BigIntKeyword): bigint
*/
```

To address this, you can enhance the schema with a custom `jsonSchema` annotation, defining how you intend to represent such types in JSON Schema:

**Example** (Using Custom Annotation for Unsupported Type)

```ts
import { JSONSchema, Schema } from "effect";

const schema = Schema.Struct({
  // Adding a custom JSON Schema annotation for the `bigint` type
  a_bigint_field: Schema.BigIntFromSelf.annotations({
    jsonSchema: {
      type: "some custom way to represent a bigint in JSON Schema",
    },
  }),
});

const jsonSchema = JSONSchema.make(schema);

console.log(JSON.stringify(jsonSchema, null, 2));
/*
Output:
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "required": [
    "a_bigint_field"
  ],
  "properties": {
    "a_bigint_field": {
      "type": "some custom way to represent a bigint in JSON Schema"
    }
  },
  "additionalProperties": false
}
*/
```

### Refinements

When defining a refinement (e.g., through the `Schema.filter` function), you can include a JSON Schema annotation to describe the refinement. This annotation is added as a "fragment" that becomes part of the generated JSON Schema. If a schema contains multiple refinements, their respective annotations are merged into the output.

**Example** (Using Refinements with Merged Annotations)

```ts
import { JSONSchema, Schema } from "effect";

// Define a schema with a refinement for positive numbers
const Positive = Schema.Number.pipe(
  Schema.filter((n) => n > 0, {
    jsonSchema: { minimum: 0 },
  }),
);

// Add an upper bound refinement to the schema
const schema = Positive.pipe(
  Schema.filter((n) => n <= 10, {
    jsonSchema: { maximum: 10 },
  }),
);

const jsonSchema = JSONSchema.make(schema);

console.log(JSON.stringify(jsonSchema, null, 2));
/*
Output:
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "number",
  "minimum": 0,
  "maximum": 10
}
*/
```

The `jsonSchema` annotation is defined as a generic object, allowing it to represent non-standard extensions. This flexibility leaves the responsibility of enforcing type constraints to the user.

If you prefer stricter type enforcement or need to support non-standard extensions, you can introduce a `satisfies` constraint on the object literal. This constraint should be used in conjunction with the typing library of your choice.

**Example** (Ensuring Type Correctness)

In the following example, we've used the `@types/json-schema` package to provide TypeScript definitions for JSON Schema. This approach not only ensures type correctness but also enables autocomplete suggestions in your IDE.

```ts
import { JSONSchema, Schema } from "effect";
import type { JSONSchema7 } from "json-schema";

const Positive = Schema.Number.pipe(
  Schema.filter((n) => n > 0, {
    jsonSchema: { minimum: 0 }, // Generic object, no type enforcement
  }),
);

const schema = Positive.pipe(
  Schema.filter((n) => n <= 10, {
    jsonSchema: { maximum: 10 } satisfies JSONSchema7, // Enforces type constraints
  }),
);

const jsonSchema = JSONSchema.make(schema);

console.log(JSON.stringify(jsonSchema, null, 2));
/*
Output:
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "number",
  "minimum": 0,
  "maximum": 10
}
*/
```

For schema types other than refinements, you can override the default generated JSON Schema by providing a custom `jsonSchema` annotation. The content of this annotation will replace the system-generated schema.

**Example** (Custom Annotation for a Struct)

```ts
import { JSONSchema, Schema } from "effect";

// Define a struct with a custom JSON Schema annotation
const schema = Schema.Struct({ foo: Schema.String }).annotations({
  jsonSchema: { type: "object" },
});

const jsonSchema = JSONSchema.make(schema);

console.log(JSON.stringify(jsonSchema, null, 2));
/*
Output
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object"
}
the default would be:
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "required": [
    "foo"
  ],
  "properties": {
    "foo": {
      "type": "string"
    }
  },
  "additionalProperties": false
}
*/
```

### Specialized JSON Schema Generation with Schema.parseJson

The `Schema.parseJson` function provides a unique approach to JSON Schema generation. Instead of defaulting to a schema for a plain string, which represents the "from" side of the transformation, it generates a schema based on the structure provided within the argument.

This behavior ensures that the generated JSON Schema reflects the intended structure of the parsed data, rather than the raw JSON input.

**Example** (Generating JSON Schema for a Parsed Object)

```ts
import { JSONSchema, Schema } from "effect";

// Define a schema that parses a JSON string into a structured object
const schema = Schema.parseJson(
  Schema.Struct({
    // Nested parsing: JSON string to a number
    a: Schema.parseJson(Schema.NumberFromString),
  }),
);

const jsonSchema = JSONSchema.make(schema);

console.log(JSON.stringify(jsonSchema, null, 2));
/*
Output:
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "required": [
    "a"
  ],
  "properties": {
    "a": {
      "type": "string",
      "contentMediaType": "application/json"
    }
  },
  "additionalProperties": false
}
*/
```

## Arbitrary

The `Arbitrary.make` function allows for the creation of random values that align with a specific `Schema<A, I, R>`.
This function returns an `Arbitrary<A>` from the [fast-check](https://github.com/dubzzz/fast-check) library,
which is particularly useful for generating random test data that adheres to the defined schema constraints.

**Example** (Generating Arbitrary Data for a Schema)

```ts
import { Arbitrary, FastCheck, Schema } from "effect";

// Define a Person schema with constraints
const Person = Schema.Struct({
  name: Schema.NonEmptyString,
  age: Schema.Int.pipe(Schema.between(1, 80)),
});

// Create an Arbitrary based on the schema
const arb = Arbitrary.make(Person);

// Generate random samples from the Arbitrary
console.log(FastCheck.sample(arb, 2));
/*
Example Output:
[ { name: 'q r', age: 3 }, { name: '&|', age: 6 } ]
*/
```

To make the output more realistic, see the [Customizing Arbitrary Data Generation](#customizing-arbitrary-data-generation) section.

> **Tip**: Access FastCheck API
> The entirety of `fast-check`'s API is accessible via the `FastCheck`
> export, allowing direct use of all its functionalities within your
> projects.

### Filters

When generating random values, `Arbitrary` tries to follow the schema's constraints. It uses the most appropriate `fast-check` primitives and applies constraints if the primitive supports them.

For instance, if you define an `age` property as:

```ts
Schema.Int.pipe(Schema.between(1, 80));
```

the arbitrary generation will use:

```ts
FastCheck.integer({ min: 1, max: 80 });
```

to produce values within that range.

> **Note**: Avoiding Conflicts in Filters
> When using multiple filters, be aware that conflicting filters might lead to hangs during arbitrary data generation. This can occur when the constraints make it difficult or impossible to produce valid values.
>
> For guidance on mitigating these issues, refer to [this discussion](https://github.com/dubzzz/fast-check/discussions/4659).

### Patterns

To generate efficient arbitraries for strings that must match a certain pattern, use the `Schema.pattern` filter instead of writing a custom filter:

**Example** (Using `Schema.pattern` for Pattern Constraints)

```ts
import { Schema } from "effect";

// ❌ Without using Schema.pattern (less efficient)
const Bad = Schema.String.pipe(Schema.filter((s) => /^[a-z]+$/.test(s)));

// ✅ Using Schema.pattern (more efficient)
const Good = Schema.String.pipe(Schema.pattern(/^[a-z]+$/));
```

By using `Schema.pattern`, arbitrary generation will rely on `FastCheck.stringMatching(regexp)`, which is more efficient and directly aligned with the defined pattern.

When multiple patterns are used, they are combined into a union. For example:

```ts
(?:${pattern1})|(?:${pattern2})
```

This approach ensures all patterns have an equal chance of generating values when using `FastCheck.stringMatching`.

### Transformations and Arbitrary Generation

When generating arbitrary data, it is important to understand how transformations and filters are handled within a schema:

> **Caution**: Filters Ignored
> Filters applied before the last transformation in the transformation
> chain are not considered during the generation of arbitrary data.

**Example** (Filters and Transformations)

```ts
import { Arbitrary, FastCheck, Schema } from "effect";

// Schema with filters before the transformation
const schema1 = Schema.compose(Schema.NonEmptyString, Schema.Trim).pipe(
  Schema.maxLength(500),
);

// May produce empty strings due to ignored NonEmpty filter
console.log(FastCheck.sample(Arbitrary.make(schema1), 2));
/*
Example Output:
[ '', '"Ry' ]
*/

// Schema with filters applied after transformations
const schema2 = Schema.Trim.pipe(
  Schema.nonEmptyString(),
  Schema.maxLength(500),
);

// Adheres to all filters, avoiding empty strings
console.log(FastCheck.sample(Arbitrary.make(schema2), 2));
/*
Example Output:
[ ']H+MPXgZKz', 'SNS|waP~\\' ]
*/
```

**Explanation:**

- `schema1`: Takes into account `Schema.maxLength(500)` since it is applied after the `Schema.Trim` transformation, but ignores the `Schema.NonEmptyString` as it precedes the transformations.
- `schema2`: Adheres fully to all filters because they are correctly sequenced after transformations, preventing the generation of undesired data.

### Best Practices

To ensure consistent and valid arbitrary data generation, follow these guidelines:

1. **Apply Filters First**: Define filters for the initial type (`I`).
2. **Apply Transformations**: Add transformations to convert the data.
3. **Apply Final Filters**: Use filters for the transformed type (`A`).

This setup ensures that each stage of data processing is precise and well-defined.

**Example** (Avoid Mixed Filters and Transformations)

Avoid haphazard combinations of transformations and filters:

```ts
import { Schema } from "effect";

// Less optimal approach: Mixing transformations and filters
const problematic = Schema.compose(Schema.Lowercase, Schema.Trim);
```

Prefer a structured approach by separating transformation steps from filter applications:

**Example** (Preferred Structured Approach)

```ts
import { Schema } from "effect";

// Recommended: Separate transformations and filters
const improved = Schema.transform(
  Schema.String,
  Schema.String.pipe(Schema.trimmed(), Schema.lowercased()),
  {
    strict: true,
    decode: (s) => s.trim().toLowerCase(),
    encode: (s) => s,
  },
);
```

### Customizing Arbitrary Data Generation

You can customize how arbitrary data is generated using the `arbitrary` annotation in schema definitions.

**Example** (Custom Arbitrary Generator)

```ts
import { Arbitrary, FastCheck, Schema } from "effect";

const Name = Schema.NonEmptyString.annotations({
  arbitrary: () => (fc) =>
    fc.constantFrom("Alice Johnson", "Dante Howell", "Marta Reyes"),
});

const Age = Schema.Int.pipe(Schema.between(1, 80));

const Person = Schema.Struct({
  name: Name,
  age: Age,
});

const arb = Arbitrary.make(Person);

console.log(FastCheck.sample(arb, 2));
/*
Example Output:
[ { name: 'Dante Howell', age: 6 }, { name: 'Marta Reyes', age: 53 } ]
*/
```

The annotation allows access the complete export of the fast-check library (`fc`).
This setup enables you to return an `Arbitrary` that precisely generates the type of data desired.

### Integration with Fake Data Generators

When using mocking libraries like [@faker-js/faker](https://www.npmjs.com/package/@faker-js/faker),
you can combine them with `fast-check` to generate realistic data for testing purposes.

**Example** (Integrating with Faker)

```ts
import { Arbitrary, FastCheck, Schema } from "effect";
import { faker } from "@faker-js/faker";

const Name = Schema.NonEmptyString.annotations({
  arbitrary: () => (fc) =>
    fc.constant(null).map(() => {
      // Each time the arbitrary is sampled, faker generates a new name
      return faker.person.fullName();
    }),
});

const Age = Schema.Int.pipe(Schema.between(1, 80));

const Person = Schema.Struct({
  name: Name,
  age: Age,
});

const arb = Arbitrary.make(Person);

console.log(FastCheck.sample(arb, 2));
/*
Example Output:
[
  { name: 'Henry Dietrich', age: 68 },
  { name: 'Lucas Haag', age: 52 }
]
*/
```

## Pretty Printer

The `Pretty.make` function is used to create pretty printers that generate a formatted string representation of values based on a schema.

**Example** (Pretty Printer for a Struct Schema)

```ts
import { Pretty, Schema } from "effect";

const Person = Schema.Struct({
  name: Schema.String,
  age: Schema.Number,
});

// Create a pretty printer for the schema
const PersonPretty = Pretty.make(Person);

// Format and print a Person object
console.log(PersonPretty({ name: "Alice", age: 30 }));
/*
Output:
'{ "name": "Alice", "age": 30 }'
*/
```

### Customizing Pretty Printer Generation

You can customize how the pretty printer formats output by using the `pretty` annotation within your schema definition.

The `pretty` annotation takes any type parameters provided (`typeParameters`) and formats the value into a string.

**Example** (Custom Pretty Printer for Numbers)

```ts
import { Pretty, Schema } from "effect";

// Define a schema with a custom pretty annotation
const schema = Schema.Number.annotations({
  pretty: (/**typeParameters**/) => (value) => `my format: ${value}`,
});

// Create the pretty printer
const customPrettyPrinter = Pretty.make(schema);

// Format and print a value
console.log(customPrettyPrinter(1));
// Output: "my format: 1"
```

## Projections

Sometimes, you may want to create a new schema based on an existing one, focusing specifically on either its `Type` or `Encoded` aspect. The Schema module provides several functions to make this possible.

### typeSchema

The `Schema.typeSchema` function is used to extract the `Type` portion of a schema, resulting in a new schema that retains only the type-specific properties from the original schema. This excludes any initial encoding or transformation logic applied to the original schema.

**Function Signature**

```ts
declare const typeSchema: <A, I, R>(schema: Schema<A, I, R>) => Schema<A>;
```

**Example** (Extracting Only Type-Specific Properties)

```ts
import { Schema } from "effect";

const Original = Schema.Struct({
  quantity: Schema.NumberFromString.pipe(Schema.greaterThanOrEqualTo(2)),
});

// This creates a schema where 'quantity' is defined as a number
// that must be greater than or equal to 2.
const TypeSchema = Schema.typeSchema(Original);

// TypeSchema is equivalent to:
const TypeSchema2 = Schema.Struct({
  quantity: Schema.Number.pipe(Schema.greaterThanOrEqualTo(2)),
});
```

### encodedSchema

The `Schema.encodedSchema` function enables you to extract the `Encoded` portion of a schema, creating a new schema that matches the original properties but **omits any refinements or transformations** applied to the schema.

**Function Signature**

```ts
declare const encodedSchema: <A, I, R>(schema: Schema<A, I, R>) => Schema<I>;
```

**Example** (Extracting Encoded Properties Only)

```ts
import { Schema } from "effect";

const Original = Schema.Struct({
  quantity: Schema.String.pipe(Schema.minLength(3)),
});

// This creates a schema where 'quantity' is just a string,
// disregarding the minLength refinement.
const Encoded = Schema.encodedSchema(Original);

// Encoded is equivalent to:
const Encoded2 = Schema.Struct({
  quantity: Schema.String,
});
```

### encodedBoundSchema

The `Schema.encodedBoundSchema` function is similar to `Schema.encodedSchema` but preserves the refinements up to the first transformation point in the
original schema.

**Function Signature**

```ts
declare const encodedBoundSchema: <A, I, R>(
  schema: Schema<A, I, R>,
) => Schema<I>;
```

The term "bound" in this context refers to the boundary up to which refinements are preserved when extracting the encoded form of a schema. It essentially marks the limit to which initial validations and structure are maintained before any transformations are applied.

**Example** (Retaining Initial Refinements Only)

```ts
import { Schema } from "effect";

const Original = Schema.Struct({
  foo: Schema.String.pipe(Schema.minLength(3), Schema.compose(Schema.Trim)),
});

// The EncodedBoundSchema schema preserves the minLength(3) refinement,
// ensuring the string length condition is enforced
// but omits the Schema.Trim transformation.
const EncodedBoundSchema = Schema.encodedBoundSchema(Original);

// EncodedBoundSchema is equivalent to:
const EncodedBoundSchema2 = Schema.Struct({
  foo: Schema.String.pipe(Schema.minLength(3)),
});
```

## Equivalence

The `Schema.equivalence` function allows you to generate an Equivalence based on a schema definition.
This function is designed to compare data structures for equivalence according to the rules defined in the schema.

**Example** (Comparing Structs for Equivalence)

```ts
import { Schema } from "effect";

const Person = Schema.Struct({
  name: Schema.String,
  age: Schema.Number,
});

// Generate an equivalence function based on the schema
const PersonEquivalence = Schema.equivalence(Person);

const john = { name: "John", age: 23 };
const alice = { name: "Alice", age: 30 };

// Use the equivalence function to compare objects

console.log(PersonEquivalence(john, { name: "John", age: 23 }));
// Output: true

console.log(PersonEquivalence(john, alice));
// Output: false
```

### Equivalence for Any, Unknown, and Object

When working with the following schemas:

- `Schema.Any`
- `Schema.Unknown`
- `Schema.Object`
- `Schema.Struct({})` (representing the broad `{}` TypeScript type)

the most sensible form of equivalence is to use `Equal.equals` from the Equal module, which defaults to reference equality (`===`).
This is because these types can hold almost any kind of value.

**Example** (Comparing Empty Objects Using Reference Equality)

```ts
import { Schema } from "effect";

const schema = Schema.Struct({});

const input1 = {};
const input2 = {};

console.log(Schema.equivalence(schema)(input1, input2));
// Output: false (because they are different references)
```

### Customizing Equivalence Generation

You can customize the equivalence logic by providing an `equivalence` annotation in the schema definition.

The `equivalence` annotation takes any type parameters provided (`typeParameters`) and two values for comparison, returning a boolean based on the desired condition of equivalence.

**Example** (Custom Equivalence for Strings)

```ts
import { Schema } from "effect";

// Define a schema with a custom equivalence annotation
const schema = Schema.String.annotations({
  equivalence: (/**typeParameters**/) => (s1, s2) =>
    // Custom rule: Compare only the first character of the strings
    s1.charAt(0) === s2.charAt(0),
});

// Generate the equivalence function
const customEquivalence = Schema.equivalence(schema);

// Use the custom equivalence function
console.log(customEquivalence("aaa", "abb"));
// Output: true (both start with 'a')

console.log(customEquivalence("aaa", "bba"));
// Output: false (strings start with different characters)
```

## Standard Schema

The `Schema.standardSchemaV1` API allows you to generate a [Standard Schema v1](https://standardschema.dev/) object from an Effect `Schema`.

**Example** (Generating a Standard Schema V1)

```ts
import { Schema } from "effect";

const schema = Schema.Struct({
  name: Schema.String,
});

// Convert an Effect schema into a Standard Schema V1 object
//
//      ┌─── StandardSchemaV1<{ readonly name: string; }>
//      ▼
const standardSchema = Schema.standardSchemaV1(schema);
```

> **Note**: Schema Restrictions
> Only schemas that do not have dependencies (i.e., `R = never`) can be
> converted to a Standard Schema V1 object.

### Sync vs Async Validation

The `Schema.standardSchemaV1` API creates a schema whose `validate` method attempts to decode and validate the provided input synchronously. If the underlying `Schema` includes any asynchronous components (e.g., asynchronous message resolutions
or checks), then validation will necessarily return a `Promise` instead.

**Example** (Handling Synchronous and Asynchronous Validation)

```ts
import { Effect, Schema } from "effect";

// Utility function to display sync and async results
const print = <T>(t: T) =>
  t instanceof Promise
    ? t.then((x) => console.log("Promise", JSON.stringify(x, null, 2)))
    : console.log("Value", JSON.stringify(t, null, 2));

// Define a synchronous schema
const sync = Schema.Struct({
  name: Schema.String,
});

// Generate a Standard Schema V1 object
const syncStandardSchema = Schema.standardSchemaV1(sync);

// Validate synchronously
print(syncStandardSchema["~standard"].validate({ name: null }));
/*
Output:
{
  "issues": [
    {
      "path": [
        "name"
      ],
      "message": "Expected string, actual null"
    }
  ]
}
*/

// Define an asynchronous schema with a transformation
const async = Schema.transformOrFail(
  sync,
  Schema.Struct({
    name: Schema.NonEmptyString,
  }),
  {
    // Simulate an asynchronous validation delay
    decode: (x) => Effect.sleep("100 millis").pipe(Effect.as(x)),
    encode: Effect.succeed,
  },
);

// Generate a Standard Schema V1 object
const asyncStandardSchema = Schema.standardSchemaV1(async);

// Validate asynchronously
print(asyncStandardSchema["~standard"].validate({ name: "" }));
/*
Output:
Promise {
  "issues": [
    {
      "path": [
        "name"
      ],
      "message": "Expected a non empty string, actual \"\""
    }
  ]
}
*/
```

### Defects

If an unexpected defect occurs during validation, it is reported as a single issue without a `path`. This ensures that unexpected errors do not disrupt schema validation but are still captured and reported.

**Example** (Handling Defects)

```ts
import { Effect, Schema } from "effect";

// Define a schema with a defect in the decode function
const defect = Schema.transformOrFail(Schema.String, Schema.String, {
  // Simulate an internal failure
  decode: () => Effect.die("Boom!"),
  encode: Effect.succeed,
});

// Generate a Standard Schema V1 object
const defectStandardSchema = Schema.standardSchemaV1(defect);

// Validate input, triggering a defect
console.log(defectStandardSchema["~standard"].validate("a"));
/*
Output:
{ issues: [ { message: 'Error: Boom!' } ] }
*/
```
