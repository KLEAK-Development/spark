# Changelog

## 1.0.0-alpha.2

- **Feat**: Added dependency on `spark_web` for isomorphic web types.
- **Refactor**: Updated element helpers to use strict `spark_web` event types (e.g. `MouseEvent`, `InputEvent`) instead of dynamic.

## 1.0.0-alpha.1

- Initial release extracted from `spark` framework package.
- Core node types: `Node`, `Text`, `RawHtml`, `Element`.
- HTML DSL helpers: `h()`, `div()`, `span()`, `p()`, `a()`, `button()`, `input()`, and more.
- CSP nonce injection support via Dart Zones.
- `Element.eventWrapper` static hook for framework reactivity integration.
- Pure Dart package with zero runtime dependencies.
