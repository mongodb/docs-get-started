# Get Started with the MongoDB PHP Library

This sample application connects to a MongoDB deployment, seeds a small
set of sample product documents, and retrieves one of them. Because the
app inserts its own data, you don't need to load an external dataset.

## Prerequisites

Before you begin, complete the [Atlas Get Started guide](https://www.mongodb.com/docs/get-started/)
to create a free Atlas deployment and save your database user
credentials.

You also need the following components installed in your development environment:

- PHP version 8.2 or later
- Composer version 2.0 or later
- PIE version 1.4 or later

## Installation

Clone this repository:

```bash
git clone https://github.com/mongodb/docs-get-started
```

### Install the MongoDB PHP Extension

The `mongodb` extension is a native PHP extension, so Composer can't
install it for you. Install it with PIE:

```bash
pie install mongodb/mongodb-extension
```

PIE requires elevated privileges to write the extension into your PHP
installation, so it might prompt you for your password.

On success, PIE prints a line confirming the extension is loaded:

```
✅ Extension is enabled and loaded in /usr/local/bin/php
```

Verify that the extension is enabled:

```bash
php -m | grep mongodb
```

On Windows, use the following command instead:

```powershell
php -m | Select-String mongodb
```

For more details, see the
[PHP library installation guide](https://www.mongodb.com/docs/php-library/current/get-started/).

### Install the Project Dependencies

Navigate into the `php/hello-world` project directory and install the
MongoDB PHP library with Composer:

```bash
cd docs-get-started/php/hello-world
composer install
```

On Windows, use the following commands instead:

```powershell
cd docs-get-started\php\hello-world
composer install
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
php src/HelloWorld.php
```

When you run the app, it inserts a few product documents into the
`get_started.products` collection, then queries and prints one of them:

```
{"_id":{"$oid":"..."},"name":"Wireless Mouse","category":"Electronics","price":24.99,"tags":["wireless","usb","ergonomic"]}
```

You can run the app more than once. It clears the collection before
each run, so the results stay consistent.

If you encounter an error or see no output, verify that you set the
`MONGODB_URI` environment variable correctly.
