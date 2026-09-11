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

The commands in this guide assume a Bash compatible shell.

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

On Windows, PIE is distributed as a PHAR rather than an executable, so
run it through `php` from the directory containing `pie.phar`:

```bash
php pie.phar install mongodb/mongodb-extension
```

PIE requires elevated privileges to write the extension into your PHP
installation, so it might prompt you for your password.

On success, PIE prints a line confirming the extension is loaded,
followed by the path to your PHP binary:

```
✅ Extension is enabled and loaded in <path to your PHP binary>
```

Verify that the extension is enabled:

```bash
php -m | grep mongodb
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

## Connect to MongoDB

Set your connection string as an environment variable, replacing
`<connection string uri>` with your connection string:

```bash
export MONGODB_URI="<connection string uri>"
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

## Troubleshooting

### PIE fails to download the extension

PIE downloads the extension over HTTPS, which requires the `openssl`
extension. If `pie install` fails with a download or TLS error, confirm
that `openssl` is enabled:

```bash
php -m
```

If openssl is not enabled, find your configuration file:

```bash
php --ini
```

Open the file listed as `Loaded Configuration File` in a text editor. On
Windows, you can use Notepad. Find the following line:

```ini
;extension=openssl
```

Remove the leading semicolon so that it reads:

```ini
extension=openssl
```

Save the file, then run the install command again.

### Connection fails with "SSL not enabled in this build"

Atlas requires TLS. If connecting fails with
`Can't create SSL client, SSL not enabled in this build`, the extension
was built without TLS support. This can happen on Linux when the OpenSSL
development headers are missing at build time: the extension still
compiles, installs, and loads, so `php -m` lists it, but it cannot
connect.

Check how the extension was built:

```bash
php --ri mongodb | grep SSL
```

If it reports `libmongoc SSL => disabled`, install the OpenSSL
development headers:

```bash
sudo apt-get install libssl-dev
```

Then rebuild the extension:

```bash
pie install --force mongodb/mongodb-extension
```

`php --ri mongodb | grep SSL` should now report
`libmongoc SSL => enabled`.
