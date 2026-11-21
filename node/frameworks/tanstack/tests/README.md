# Testing Documentation

Vitest test suite for the TanStack Start + MongoDB sample application.

| Type | Files | Tests | Database |
|------|-------|-------|----------|
| **Unit** | 2 | 10 | Mocked |
| **Integration** | 1 | 7 | Real MongoDB |

## Running Tests

All test commands are run from the sample root:

```bash
cd docs-get-started/node/frameworks/tanstack
```

Run the unit tests (no database required):

```bash
npm run test:unit
```

Run the integration tests (requires a MongoDB instance with the `sample_restaurants` dataset
loaded and `MONGODB_URI` set):

```bash
MONGODB_URI="<connection string>" npm run test:integration
```

Run all tests:

```bash
npm run test:all
```

Integration tests skip automatically when `MONGODB_URI` is not set.

## Test Structure

```
tests/
├── unit/                              # Unit tests (mocked MongoDB)
│   ├── db.test.ts                    # Database module exports
│   └── restaurants.test.ts           # Server function behavior
├── integration/                       # Integration tests (real MongoDB)
│   ├── setup.ts                      # Conditional suite + connect hook
│   ├── tanstack-react-start.mock.ts  # createServerFn passthrough
│   └── restaurants.integration.test.ts
└── utils/
    └── testHelpers.ts                # Sample data and helpers
```

## Mocking Strategy

Unit tests mock the application boundary, not the MongoDB driver. The `#/lib/db` module is mocked
with `vi.mock` to return a chainable fake collection, and `@tanstack/react-start` aliases to
`tests/integration/tanstack-react-start.mock.ts` so `createServerFn().handler(fn)` returns `fn`
directly, letting server functions run in a plain Node/Vitest environment.

## Integration Tests

Integration tests use a real MongoDB connection to verify the queries the application runs:

- `getAllRestaurants()` returns up to 100 restaurants with the expected document shape.
- `getRestaurantsByBorough()` returns only Queens restaurants whose names contain "Moon"
  (case-insensitive).

They require the `sample_restaurants` database with a `restaurants` collection.
