# Get Started with the MongoDB C++ Driver

This sample application connects to a MongoDB deployment, seeds a small
set of sample product documents, and retrieves one of them. Because the
app inserts its own data, you don't need to load an external dataset.

## Prerequisites

Before you begin, complete the [Atlas Get Started guide](https://www.mongodb.com/docs/get-started/)
to create a free Atlas deployment and save your database user
credentials.

You also need the following components installed in your development environment:

- A C++17-compatible compiler
- CMake 3.15 or later

## Installation

Clone this repository:

```bash
git clone https://github.com/mongodb/docs-get-started
```

### Install the MongoDB C++ Driver

This project requires MongoDB C++ driver (mongocxx) 4.0 or later. Install
it with your platform's package manager.

On macOS, use [Homebrew](https://brew.sh/):

```bash
brew install mongo-cxx-driver
```

On Windows, use [vcpkg](https://vcpkg.io/):

```powershell
vcpkg install mongo-cxx-driver
```

On Linux, most distribution packages are too old to satisfy this
requirement. Use vcpkg instead:

```bash
vcpkg install mongo-cxx-driver
```

For other installation methods, see the
[C++ driver installation guide](https://www.mongodb.com/docs/languages/cpp/cpp-driver/current/installation/).

### Build the Application

Navigate into the project directory, then configure and build:

```bash
cd docs-get-started/cpp/hello-world
cmake -S . -B build
cmake --build build
```

On Windows, use the following commands instead:

```powershell
cd docs-get-started\cpp\hello-world
cmake -S . -B build
cmake --build build --config Release
```

If you installed the driver with vcpkg, add the vcpkg toolchain file to
the configure step so CMake can locate it, replacing `<vcpkg root>` with
your vcpkg installation path:

```bash
cmake -S . -B build -DCMAKE_TOOLCHAIN_FILE=<vcpkg root>/scripts/buildsystems/vcpkg.cmake
```

## Connect to MongoDB

Set your connection string as an environment variable, replacing
`<connection string uri>` with your connection string:

```bash
export MONGODB_URI="<connection string uri>"
```

On Windows, use the following command instead:

```powershell
$Env:MONGODB_URI = "<connection string uri>"
```

## Run the Application

```bash
./build/hello-world
```

On Windows, use the following command instead:

```powershell
.\build\Release\hello-world.exe
```

When you run the app, it inserts a few product documents into the
`get_started.products` collection, then queries and prints one of them:

```
{ "_id" : { "$oid" : "..." }, "name" : "Wireless Mouse", "category" : "Electronics", "price" : 24.99, "tags" : [ "wireless", "usb", "ergonomic" ] }
```

You can run the app more than once. It clears the collection before
each run, so the results stay consistent.

If you encounter an error or see no output, verify that you set the
`MONGODB_URI` environment variable correctly.
