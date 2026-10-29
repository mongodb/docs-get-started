# Get Started with the MongoDB C Driver

This sample application connects to a MongoDB deployment, seeds a small
set of sample product documents, and retrieves one of them. Because the
app inserts its own data, you don't need to load an external dataset.

## Prerequisites

Before you begin, complete the [Atlas Get Started guide](https://www.mongodb.com/docs/get-started/)
to create a free Atlas deployment and save your database user
credentials.

You also need the following components installed in your development environment:

- CMake 3.15 or later
- A C11-compatible compiler
- [vcpkg](https://github.com/microsoft/vcpkg) (Windows and Linux)

The commands in this guide assume a Bash compatible shell.

## Installation

Clone this repository:

```bash
git clone https://github.com/mongodb/docs-get-started
```

### Install the MongoDB C Driver

This project requires MongoDB C driver 2.5 or later. Install it with
Homebrew on macOS, or vcpkg on Linux and Windows.

<details open>
<summary><strong>macOS / Linux </strong></summary>

On macOS, install the MongoDB C driver with [Homebrew](https://brew.sh/):

```bash
brew install mongo-c-driver
```

Then, configure and build:

```bash
cd docs-get-started/c/hello-world
cmake -S . -B build
cmake --build build
```

On Linux, use vcpkg to install the MongoDB C driver, replacing
`<vcpkg root>` with your vcpkg installation path:

```bash
cd docs-get-started/c/hello-world
<vcpkg root>/vcpkg install
```

Then configure and build:

```bash
cmake -S . -B build -DCMAKE_TOOLCHAIN_FILE=<vcpkg root>/scripts/buildsystems/vcpkg.cmake
cmake --build build
```
</details>

<details open>
<summary><strong>Windows </strong></summary>

On Windows, use vcpkg to install the MongoDB C driver, replacing
`<vcpkg root>` with your vcpkg installation path:

```bash
cd docs-get-started/c/hello-world
<vcpkg root>/vcpkg install
```

Then configure and build:

```bash
cmake -S . -B build -DCMAKE_TOOLCHAIN_FILE=<vcpkg root>/scripts/buildsystems/vcpkg.cmake
cmake --build build --config Release
```
</details>

## Connect to MongoDB

Set your connection string as an environment variable, replacing
`<connection string uri>` with your connection string:

```bash
export MONGODB_URI="<connection string uri>"
```

## Run the Application

On macOS and Linux, run the following command:

```bash
./build/hello-world
```

On Windows, use the following command instead:

```bash
./build/Release/hello-world.exe
```

When you run the app, it inserts a few product documents into the
`get_started.products` collection, then queries and prints one of them:

```
{ "_id" : { "$oid" : "..." }, "name" : "Wireless Mouse", "category" : "Electronics", "price" : { "$numberDecimal" : "24.99" }, "tags" : [ "wireless", "usb", "ergonomic" ] }
```

If you encounter an error or see no output, verify that you set the
`MONGODB_URI` environment variable correctly.

## Additional Resources

For other installation methods, such as building from source, see
the C driver's [Custom Installation](https://www.mongodb.com/docs/languages/c/c-driver/current/install-from-source/)
guide.
