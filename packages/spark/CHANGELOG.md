## 1.0.0-alpha.6

- Fixed SVG element hydration by properly using `createElementNS` and ensuring context-aware element creation.

## 1.0.0-alpha.5

- Implement CSS minification logic and enable it during the build process for server and client compilation.
- Switch CSS minification to use the `dart.vm.product` flag, remove custom build flags, and add new tests for minification behavior.

## 1.0.0-alpha.4 - 30-01-2026

### Features

- Added `clientIp` extension to `shelf.Request`.
- Added `onClick` event support to Anchor (`a`) tag in DSL.

### Bug Fixes & Refactors

- Fixed CSP nonce injection for scripts and styles to support strict CSP headers.

## 1.0.0-alpha.3 - 27-01-2026

- Updated spark_generator to 1.0.0-alpha.4. This allows using `dart:io` in Pages.

### Breaking changes

- `SparkPage.components` getter now returns `List<Type>` instead of ComponentInfo list. This simplifies usage: `[Counter]` instead of `[ComponentInfo(Counter.tag, Counter.new)]`.

## 1.0.0-alpha.2 - 22-01-2025

### Breaking changes

- There is a new way to write Components. Please refer to the [documentation](https://spark.kleak.dev/docs/components) for more information.

### Features

- Add type to input element onInput event based on the type of the input
- Added support for cookies
- Added support for csp nonce on scripts and styles
- Fix @Component

## 1.0.0-alpha.1

- Initial version
