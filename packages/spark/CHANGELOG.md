## 1.0.0-alpha.7

### Features

- Improved VDOM hydration by ignoring comment nodes and preserving input state.
- Added `onHydrating` lifecycle hook.
- Refactored `ContentType.from` to use strict MIME type matching.

### Bug Fixes

- Fixed Stored XSS in static file handler directory listing.
- Fixed memory leak in `vdom_web.dart` by cleaning up listeners on node removal.
- Removed redundant `simpleStaticHandler`.

### Performance

- Optimized static file serving with streaming and non-blocking Gzip.
- Optimized static handler directory listing.
- Optimized `Style.toCss` with caching.
- Optimized CSS serialization in `SparkComponent`.
- Removed repeated VDOM traversal in `SparkComponent.update`.

## 1.0.0-alpha.6

- Fixed SVG element hydration by properly using `createElementNS` and ensuring context-aware element creation.
- **Breaking Change**: Renamed `Node` to `VNode` to avoid conflict with `dart:html` Node.
- Improve vdom attribute patching
- Improve clientIp getter

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
