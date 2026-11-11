# TanStack Start + MongoDB Sample Application

A full-stack restaurant directory built with [TanStack Start](https://tanstack.com/start/latest),
[TanStack Query](https://tanstack.com/query/latest), and the
[MongoDB Node.js Driver](https://www.mongodb.com/docs/drivers/node/current/). It reads restaurant
data from the `sample_restaurants` database in your MongoDB Atlas deployment.

## Prerequisites

- Node.js 20 or later
- An Atlas deployment with the `sample_restaurants` sample dataset loaded. If you don't have one,
  follow the [MongoDB Get Started guide](https://www.mongodb.com/docs/get-started/) to create a free
  cluster and load the sample data.

## Installation

Clone this repository and install the sample's dependencies:

```bash
git clone https://github.com/mongodb/docs-get-started
cd docs-get-started/node/frameworks/tanstack
npm install
```

## Connect to MongoDB

The application reads your Atlas connection string from the `MONGODB_URI` environment variable and
connects to the `sample_restaurants` database.

On macOS or Linux, run:

```bash
export MONGODB_URI="<connection string>"
```

On Windows PowerShell, run:

```powershell
$env:MONGODB_URI = "<connection string>"
```

Keep your connection string private. Do not commit it to your repository.

## Run the Application

Start the development server:

```bash
npm run dev
```

Open [http://localhost:3000](http://localhost:3000). The home page displays restaurants from the
`sample_restaurants` database. Select **Browse** to view restaurants in Queens whose names contain
"Moon".

## Run the Tests

This sample includes a [Vitest](https://vitest.dev/) test suite in the `tests/` directory.

Run the unit tests (no database required):

```bash
npm run test:unit
```

Run the integration tests (requires a MongoDB instance with the `sample_restaurants` dataset
loaded):

```bash
MONGODB_URI="<connection string>" npm run test:integration
```

## Project Structure

```
tanstack/
├── src/
│   ├── lib/
│   │   └── db.ts                  # MongoDB connection
│   ├── server/
│   │   └── restaurants.ts         # Server functions that query MongoDB
│   ├── routes/
│   │   ├── __root.tsx             # Root layout with TanStack Query provider
│   │   ├── index.tsx              # Home page (all restaurants)
│   │   └── browse.tsx             # Browse page (Queens restaurants with "Moon")
│   └── components/
│       ├── Header.tsx             # App header with navigation
│       └── RestaurantList.tsx     # Table that renders restaurant data
└── tests/                         # Unit and integration tests
```

## Learn More

- [TanStack Start documentation](https://tanstack.com/start/latest)
- [MongoDB Node.js Driver documentation](https://www.mongodb.com/docs/drivers/node/current/)
